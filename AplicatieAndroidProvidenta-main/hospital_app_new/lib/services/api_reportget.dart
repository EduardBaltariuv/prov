import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report.dart';
import 'dart:async';

class ApiReport {
  static const String _baseUrl = 'https://darkcyan-clam-483701.hostingersite.com'; // Replace with your API URL
  static const int _timeoutSeconds = 30;
  static const int _intervalSeconds = 2; // Run every 2 seconds
  static Timer? _reportTimer;

  // Method to start the periodic fetch of reports
  static void startFetchingReports() {
    _reportTimer = Timer.periodic(
      Duration(seconds: _intervalSeconds),
      (_) => getReports(),
    );
  }

  // Method to stop the periodic fetching of reports
  static void stopFetchingReports() {
    if (_reportTimer != null) {
      _reportTimer?.cancel();
    }
  }

  static Future<List<Report>> getReports() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/apigetreports.php'),
        body: {'action': 'getReport'},
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ).timeout(const Duration(seconds: _timeoutSeconds));

      print("API Response: ${response.body}"); // Debug

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> reportsJson = responseData['reports'];
          return reportsJson.map((reportJson) => Report.fromJson({
            'id': reportJson['id'].toString(),
            'title': reportJson['title'],
            'description': reportJson['description'],
            'category': reportJson['category'],
            'location': reportJson['location'],
            'status': reportJson['status'] ?? 'Nou', // 👈 Aici luăm statusul din DB
            'image_paths': List<String>.from(reportJson['image_urls'] ?? []), // Use image_urls here
            'created_at': reportJson['created_at'],
            'username': reportJson['username'],
          })).toList();
        } else {
          throw Exception('API Error: ${responseData['message']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print("API Error: $e");
      throw Exception('Failed to fetch reports: $e');
    }
  }


  
}
