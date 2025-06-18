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
      
      final requestBody = {
        'current_version': currentVersion,
        'build_number': packageInfo.buildNumber,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'package_name': packageInfo.packageName,
      };
      
      final response = await http.post(
        Uri.parse(_versionCheckUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['update_available'] == true) {
          _availableUpdate = data;
          _updateMessage = showMessage 
              ? 'Update available: v${data['latest_version']}' 
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
      // Get the download URL from the available update info
      final downloadUrl = _availableUpdate!['download_url'] ?? _downloadBaseUrl;
      
      // Create request with update info
      final requestBody = {
        'version': _availableUpdate!['latest_version'],
        'platform': Platform.isAndroid ? 'android' : 'ios',
      };
      
      final request = http.Request('POST', Uri.parse(downloadUrl));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(requestBody);
      
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final contentLength = response.contentLength ?? 0;
        final tempDir = await getTemporaryDirectory();
        final fileName = 'hospital_app_update.apk';
        final file = File('${tempDir.path}/$fileName');
        
        final sink = file.openWrite();
        var downloaded = 0;
        
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
          onDone: () async {
            await sink.close();
            _downloadProgress = 1.0;
            _updateMessage = 'Download complete. Installing...';
            notifyListeners();
            
            // Install the APK (Android only)
            if (Platform.isAndroid) {
              await _installApk(file.path);
            } else {
              _updateMessage = 'Please manually install the downloaded update';
            }
          },
          onError: (error) {
            _updateMessage = 'Download failed: $error';
            notifyListeners();
          },
        ).asFuture();
        
        return true;
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
      await _platform.invokeMethod('installApk', {'apkPath': filePath});
      _updateMessage = 'Update installed successfully. Please restart the app.';
    } catch (e) {
      _updateMessage = 'Installation failed: ${e.toString()}';
      debugPrint('Error installing APK: $e');
    }
    notifyListeners();
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
}
