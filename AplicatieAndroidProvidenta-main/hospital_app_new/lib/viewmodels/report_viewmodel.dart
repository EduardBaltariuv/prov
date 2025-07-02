import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/report.dart';
import 'package:hospital_app/services/api_service.dart';
import 'package:hospital_app/services/api_reportget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportViewModel extends ChangeNotifier {
  // Filter state
  ReportFilter _selectedFilter = ReportFilter.newReports;
  bool get isNewSelected => _selectedFilter == ReportFilter.newReports;
  bool get isResolvedSelected => _selectedFilter == ReportFilter.resolvedReports;
  bool get isInProgress => _selectedFilter == ReportFilter.InProgress;

  // Report data
  List<Report> _reports = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;
  String? _selectedLocation;
  Timer? _debounce;

  final String _notificationEndpoint = 'http://arabesque.go.ro/notification/send_notification.php';

  // Getters
  List<Report> get newReports => _reports.where((r) => r.status == 'Nou').toList();
  List<Report> get resolvedReports => _reports.where((r) => r.status == 'Rezolvat').toList();
  List<Report> get inProgressReports => _reports.where((r) => r.status == 'În Progres').toList();
  List<Report> get reports => _reports;

  List<Report> get filteredReports {
    switch (_selectedFilter) {
      case ReportFilter.newReports:
        return newReports;
      case ReportFilter.resolvedReports:
        return resolvedReports;
      case ReportFilter.InProgress:
        return inProgressReports;
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;
  String? get selectedLocation => _selectedLocation;
  
  List<String> get categories => const [
    'IT', 
    'Instalatii Electrice', 
    'Instalatii Sanitare', 
    'Feronerie/Usi/Geamuri',
    'Mobilier/Paturi',
    'Aparatura medicala'
  ];
  
  List<String> get locatii => const [
    'Subsol',
    'Demisol', 
    'Parter', 
    'Etaj 1', 
    'Etaj 2',
    'Etaj 3',
    'Birouri',
    'Laborator',
    'Curte exterioara',
    'Cabina portar',
    'Centru permanenta',
    'Containere-vestiar'
  ];

  // Reset form fields
 void resetSelections() {
  _selectedCategory = null;
  _selectedLocation = null;
  

  _safeNotify();
}

  // Fetch reports from API
  Future<void> fetchReports() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      final reports = await ApiReport.getReports();
      _reports = reports;
      print("Reports loaded successfully. Count: ${_reports.length}");
    } catch (e) {
      _error = 'Failed to load reports: ${e.toString()}';
      print("Error fetching reports: $_error");
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  // Filter management
  void toggleFilter(ReportFilter filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    _safeNotify();
  }

  // Selection management
  void setSelectedLocation(String? location) {
    if (_selectedLocation == location) return;
    _selectedLocation = location;
    _safeNotify();
  }

  void setSelectedCategory(String? category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _safeNotify();
  }

  // Create new report
  Future<Result<bool>> createReport({
    required String title,
    required String description,
    required String category,
    required String location,
    required List<XFile> images,
    required String username,
  }) async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      final response = await ApiService.createReport(
        title: title,
        description: description,
        category: category,
        location: location,
        username: username,
        images: images,
      );

      // Check if the API response indicates success
      if (response['success'] == true) {
        print('✅ Report created successfully with ID: ${response['id']}');
        
        // Try to refresh reports from server, but don't fail if it errors
        try {
          await fetchReports();
        } catch (e) {
          print('⚠️ Warning: Failed to refresh reports after creation: $e');
          // Don't fail the entire operation just because refresh failed
        }
        
        // Send notifications (don't fail if notifications fail)
        try {
          await _sendNotificationToTopic(
            category.toLowerCase(),
            'Raport nou: $title',
            'Un nou raport a fost creat în categoria $category'
          );
          
          await _sendNotificationToTopic(
            'admin',
            'Raport nou: $title',
            'Un nou raport a fost creat de $username'
          );
        } catch (e) {
          print('⚠️ Warning: Failed to send notifications: $e');
          // Don't fail the entire operation just because notifications failed
        }

        // Reset form selections
        resetSelections();
        
        return Success(true);
      } else {
        // API returned success=false
        final message = response['message'] ?? 'Eroare necunoscută';
        return Failure(message);
      }
    } catch (e) {
      return Failure(e.toString());
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<void> _sendNotification(String topic, String title, String body) async {
    try {
      final response = await http.post(
        Uri.parse(_notificationEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'topic': topic,
          'title': title,
          'body': body,
        },
      );

      final responseData = jsonDecode(response.body);
      if (!responseData['success']) {
        print('Failed to send notification: ${responseData['message']}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Update report status with notifications
  Future<void> updateReportStatus(String reportId, String newStatus) async {
    final url = Uri.parse('https://darkcyan-clam-483701.hostingersite.com/apigetreports.php');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'action': 'updateReportStatus',
          'reportId': reportId,
          'status': newStatus,
        },
      );

      if (response.statusCode == 200) {
        final index = _reports.indexWhere((r) => r.id == reportId);
        if (index != -1) {
          final report = _reports[index];
          _reports[index] = report.copyWith(status: newStatus);
          
          // Notify the report creator
          await _sendNotificationToTopic(
            'user_${report.username}',
            'Status actualizat',
            'Raportul "${report.title}" a fost marcat ca $newStatus'
          );
          
          print("✅ Updated report $reportId status to $newStatus");
          _safeNotify();
        }
      } else {
        _error = '❌ Server error: ${response.statusCode}';
        print("Error updating status: $_error");
      }
    } catch (e) {
      _error = '❌ Status update failed: ${e.toString()}';
      print("Error updating status: $_error");
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      final url = Uri.parse('https://darkcyan-clam-483701.hostingersite.com/delete_report.php');
      
      final response = await http.post(
        url,
        body: {
          'id': reportId,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final responseData = json.decode(response.body);
      if (responseData['success'] != true) {
        throw Exception(responseData['message']);
      }

      // Remove from local list
      _reports.removeWhere((r) => r.id == reportId);
      notifyListeners();
    } catch (e) {
      print('Error deleting report: $e');
      rethrow;
    }
  }

  Future<void> _sendNotificationToTopic(String topic, String title, String body) async {
    final url = Uri.parse('https://darkcyan-clam-483701.hostingersite.com/send_notification.php');
    try {
      await http.post(
        url,
        body: {
          'topic': topic,
          'title': title,
          'body': body,
        },
      );
    } catch (e) {
      print('Failed to send notification: $e');
    }
  }

  // Update existing report
  Future<Result<String>> updateReport({
    required String reportId,
    required String title,
    required String description,
    required String category,
    required String location,
    List<XFile>? newImages,
    required String username,
    bool keepExistingImages = true,
  }) async {
    try {
      print("🔄 Updating report $reportId...");
      
      final response = await ApiService.updateReport(
        reportId: reportId,
        title: title,
        description: description,
        category: category,
        location: location,
        newImages: newImages,
        username: username,
        keepExistingImages: keepExistingImages,
      );

      if (response['success'] == true) {
        print("✅ Report updated successfully!");
        
        // Refresh the reports list to get the updated data
        await fetchReports();
        
        return Success("Raportul a fost actualizat cu succes!");
      } else {
        final message = response['message'] ?? 'Unknown error occurred';
        print("❌ Update failed: $message");
        return Failure(message);
      }
    } catch (e) {
      final errorMessage = e.toString();
      print("❌ Exception during update: $errorMessage");
      
      // Handle specific error types
      if (errorMessage.contains('USER_NOT_AUTHENTICATED')) {
        return Failure('Sesiunea a expirat. Vă rugăm să vă reconectați.');
      } else if (errorMessage.contains('PERMISSION_DENIED')) {
        return Failure('Nu aveți permisiunea să modificați acest raport.');
      } else if (errorMessage.contains('REPORT_NOT_FOUND')) {
        return Failure('Raportul nu a fost găsit.');
      } else if (errorMessage.contains('MISSING_FIELDS')) {
        return Failure('Toate câmpurile sunt obligatorii.');
      } else {
        return Failure('Eroare la actualizarea raportului: $errorMessage');
      }
    }
  }

  // Debounced notification
  void _safeNotify() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {
      if (hasListeners) notifyListeners();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

enum ReportFilter { newReports, resolvedReports, InProgress }

sealed class Result<T> {}

class Success<T> extends Result<T> {
  final T data;
  Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  Failure(this.message);
}