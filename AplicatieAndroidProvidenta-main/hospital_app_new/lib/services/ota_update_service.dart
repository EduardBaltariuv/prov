import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

class OTAUpdateService extends ChangeNotifier {
  // Configuration
  static const String _versionCheckUrl = 'https://darkcyan-clam-483701.hostingersite.com/ota_version_check.php';
  static const String _downloadBaseUrl = 'https://darkcyan-clam-483701.hostingersite.com/ota_download.php';
  static const String _autoUpdateKey = 'auto_update_enabled';
  static const String _lastCheckDateKey = 'last_update_check';
  
  static const MethodChannel _platform = MethodChannel('com.example.hospital_app/ota_update');

  // State variables
  bool _isCheckingForUpdates = false;
  bool _isDownloading = false;
  bool _autoUpdateEnabled = true;
  double _downloadProgress = 0.0;
  String? _currentVersion;
  Map<String, dynamic>? _availableUpdate;
  String? _updateMessage;

  // Getters
  bool get isCheckingForUpdates => _isCheckingForUpdates;
  bool get isDownloading => _isDownloading;
  bool get autoUpdateEnabled => _autoUpdateEnabled;
  double get downloadProgress => _downloadProgress;
  String? get currentVersion => _currentVersion;
  String? get updateMessage => _updateMessage;
  bool get hasUpdate => _availableUpdate != null;
  bool get isCriticalUpdate => _availableUpdate?['is_critical'] == true;
  String? get availableVersion => _availableUpdate?['latest_version'];
  String? get updateNotes => _availableUpdate?['release_notes'];

  // Constructor
  OTAUpdateService() {
    init();
  }

  Future<void> init() async {
    await _loadCurrentVersion();
    await _loadPreferences();
    
    if (_autoUpdateEnabled) {
      // Check for updates on initialization (without showing messages)
      await checkForUpdates(showMessage: false);
    }
  }

  Future<void> _loadCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _currentVersion = packageInfo.version;
    } catch (e) {
      debugPrint('Error loading current version: $e');
      _currentVersion = '1.0.0';
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _autoUpdateEnabled = prefs.getBool(_autoUpdateKey) ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading OTA preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoUpdateKey, _autoUpdateEnabled);
      await prefs.setString(_lastCheckDateKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error saving OTA preferences: $e');
    }
  }

  Future<void> setAutoUpdateEnabled(bool enabled) async {
    _autoUpdateEnabled = enabled;
    await _savePreferences();
    notifyListeners();
  }

  Future<bool> checkForUpdates({bool showMessage = true}) async {
    if (_isCheckingForUpdates) return false;
    
    _isCheckingForUpdates = true;
    _updateMessage = null;
    
    if (showMessage) {
      _updateMessage = 'Checking for updates...';
    }
    
    notifyListeners();
    
    try {
      final currentVersion = _currentVersion ?? await _getCurrentVersion();
      final packageInfo = await PackageInfo.fromPlatform();
      
      // Use GET request with version parameter as expected by the PHP endpoint
      final uri = Uri.parse(_versionCheckUrl).replace(queryParameters: {
        'version': currentVersion,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'package_name': packageInfo.packageName,
        'build_number': packageInfo.buildNumber,
      });
      
      final response = await http.get(uri).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['hasUpdate'] == true) {
          // Map the PHP response format to what the rest of the code expects
          _availableUpdate = {
            'latest_version': data['availableVersion'],
            'is_critical': data['isCritical'],
            'release_notes': data['updateNotes'],
            'download_url': data['downloadUrl'],
          };
          _updateMessage = showMessage 
              ? 'Update available: v${data['availableVersion']}' 
              : null;
          await _savePreferences();
          
          // Auto-download critical updates
          if (isCriticalUpdate) {
            await downloadAndInstallUpdate();
          }
          
          return true;
        } else {
          _availableUpdate = null;
          _updateMessage = showMessage ? 'You have the latest version' : null;
          return false;
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      _availableUpdate = null;
      _updateMessage = showMessage ? 'Failed to check for updates: ${e.toString()}' : null;
      debugPrint('Error checking for updates: $e');
      return false;
    } finally {
      _isCheckingForUpdates = false;
      notifyListeners();
    }
  }

  Future<String> _getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      debugPrint('Error getting current version: $e');
      return '1.0.0';
    }
  }

  Future<bool> downloadAndInstallUpdate() async {
    if (_isDownloading || _availableUpdate == null) return false;
    
    _isDownloading = true;
    _downloadProgress = 0.0;
    _updateMessage = 'Downloading update...';
    notifyListeners();
    
    try {
      // Use the ota_download.php endpoint instead of direct APK links
      final baseDownloadUrl = _downloadBaseUrl;
      
      // Create download URL with version parameter for the ota_download.php endpoint
      final downloadUri = Uri.parse(baseDownloadUrl).replace(queryParameters: {
        'version': _availableUpdate!['latest_version'],
      });
      
      final response = await http.Client().send(http.Request('GET', downloadUri));
      
      if (response.statusCode == 200) {
        final contentLength = response.contentLength ?? 0;
        final tempDir = await getTemporaryDirectory();
        final fileName = 'hospital_app_update.apk';
        final file = File('${tempDir.path}/$fileName');
        
        // Delete existing APK file if it exists
        if (await file.exists()) {
          await file.delete();
        }
        
        final sink = file.openWrite();
        var downloaded = 0;
        bool downloadCompleted = false;
        
        await response.stream.listen(
          (chunk) {
            downloaded += chunk.length;
            sink.add(chunk);
            
            if (contentLength > 0) {
              _downloadProgress = downloaded / contentLength;
              _updateMessage = 'Downloading... ${(_downloadProgress * 100).toStringAsFixed(1)}%';
              notifyListeners();
            }
          },
          onDone: () {
            downloadCompleted = true;
          },
          onError: (error) {
            _updateMessage = 'Download failed: $error';
            notifyListeners();
          },
        ).asFuture();
        
        await sink.close();
        
        if (downloadCompleted) {
          _downloadProgress = 1.0;
          _updateMessage = 'Download complete. Installing...';
          notifyListeners();
          
          // Install the APK (Android only)
          if (Platform.isAndroid) {
            await _installApk(file.path);
          } else {
            _updateMessage = 'Please manually install the downloaded update';
          }
        }
        
        return downloadCompleted;
      } else {
        throw Exception('Download failed with status ${response.statusCode}');
      }
    } catch (e) {
      _updateMessage = 'Update failed: ${e.toString()}';
      debugPrint('Error downloading update: $e');
      return false;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  Future<void> _installApk(String filePath) async {
    if (!Platform.isAndroid) return;
    
    try {
      // Verify the APK file exists and has content
      final apkFile = File(filePath);
      if (!await apkFile.exists()) {
        _updateMessage = 'Installation failed: APK file not found';
        notifyListeners();
        return;
      }
      
      final fileSize = await apkFile.length();
      if (fileSize == 0) {
        _updateMessage = 'Installation failed: APK file is empty';
        notifyListeners();
        return;
      }
      
      // Check if the app can install from unknown sources
      final canInstall = await _platform.invokeMethod('canInstallFromUnknownSources');
      
      if (!canInstall) {
        _updateMessage = 'Installation requires permission. Opening settings...';
        notifyListeners();
        
        // Open settings to allow user to enable installation from unknown sources
        await _platform.invokeMethod('openInstallPermissionSettings');
        
        // Update message with instructions
        _updateMessage = 'Please enable "Install from Unknown Sources" for this app, then try updating again.';
        notifyListeners();
        return;
      }
      
      // Attempt to install the APK
      await _platform.invokeMethod('installApk', {'apkPath': filePath});
      _updateMessage = 'Opening installer... Follow the prompts to complete the update.';
      
      // Schedule cleanup after installation attempt
      _scheduleCleanup(filePath);
      
    } catch (e) {
      debugPrint('Error installing APK: $e');
      
      // Provide user-friendly error messages
      if (e.toString().contains('INSTALL_ERROR')) {
        _updateMessage = 'Installation failed. Please ensure you have enabled "Install from Unknown Sources" in your device settings.';
      } else if (e.toString().contains('FILE_NOT_FOUND')) {
        _updateMessage = 'Installation failed: Update file not found. Please try downloading again.';
      } else {
        _updateMessage = 'Installation failed. Please try again or install manually.';
      }
    }
    notifyListeners();
  }
  
  // Schedule cleanup of downloaded APK file
  void _scheduleCleanup(String filePath) {
    Future.delayed(const Duration(minutes: 5), () async {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('Cleaned up downloaded APK: $filePath');
        }
      } catch (e) {
        debugPrint('Error cleaning up APK file: $e');
      }
    });
  }

  Future<void> performAutoUpdateCheck() async {
    if (!_autoUpdateEnabled) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckStr = prefs.getString(_lastCheckDateKey);
      
      if (lastCheckStr != null) {
        final lastCheck = DateTime.parse(lastCheckStr);
        final daysSinceCheck = DateTime.now().difference(lastCheck).inDays;
        
        // Check for updates if more than 1 day has passed
        if (daysSinceCheck < 1) return;
      }
      
      await checkForUpdates(showMessage: false);
    } catch (e) {
      debugPrint('Error in auto update check: $e');
    }
  }

  void clearUpdateState() {
    _availableUpdate = null;
    _updateMessage = null;
    _downloadProgress = 0.0;
    notifyListeners();
  }

  String getUpdateInfo() {
    if (_availableUpdate == null) return 'No updates available';
    
    final version = _availableUpdate!['latest_version'] ?? 'Unknown';
    final size = _availableUpdate!['file_size'] ?? 'Unknown';
    final releaseNotes = _availableUpdate!['release_notes'] ?? 'Bug fixes and improvements';
    
    return '''
Version: $version
Size: $size
Release Notes: $releaseNotes
''';
  }
  
  // Diagnostic method to check OTA readiness
  Future<Map<String, dynamic>> checkOTAReadiness() async {
    final results = <String, dynamic>{};
    
    try {
      // Check internet connectivity by testing version check endpoint
      final uri = Uri.parse(_versionCheckUrl).replace(queryParameters: {
        'version': _currentVersion ?? '1.0.0',
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      results['internet_connectivity'] = response.statusCode == 200;
      results['server_reachable'] = true;
    } catch (e) {
      results['internet_connectivity'] = false;
      results['server_reachable'] = false;
      results['connectivity_error'] = e.toString();
    }
    
    try {
      // Check available storage space
      final tempDir = await getTemporaryDirectory();
      final stat = await tempDir.stat();
      results['temp_directory_accessible'] = true;
    } catch (e) {
      results['temp_directory_accessible'] = false;
      results['storage_error'] = e.toString();
    }
    
    try {
      // Check Android permissions
      if (Platform.isAndroid) {
        final canInstall = await _platform.invokeMethod('canInstallFromUnknownSources');
        results['install_permission'] = canInstall;
      } else {
        results['install_permission'] = false;
        results['platform_note'] = 'OTA updates only supported on Android';
      }
    } catch (e) {
      results['install_permission'] = false;
      results['permission_error'] = e.toString();
    }
    
    results['current_version'] = _currentVersion;
    results['auto_update_enabled'] = _autoUpdateEnabled;
    results['has_pending_update'] = hasUpdate;
    
    return results;
  }
  
  // Method to clear any stuck download state
  Future<void> resetDownloadState() async {
    _isDownloading = false;
    _downloadProgress = 0.0;
    _updateMessage = null;
    
    // Clean up any existing APK files
    try {
      final tempDir = await getTemporaryDirectory();
      final apkFile = File('${tempDir.path}/hospital_app_update.apk');
      if (await apkFile.exists()) {
        await apkFile.delete();
        debugPrint('Cleaned up existing APK file');
      }
    } catch (e) {
      debugPrint('Error cleaning up APK file: $e');
    }
    
    notifyListeners();
  }
}
