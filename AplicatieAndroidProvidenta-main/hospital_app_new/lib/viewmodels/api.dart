import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://darkcyan-clam-483701.hostingersite.com/api.php';
static String? currentUsername;
static String? currentRole; // Adăugat lângă currentUsername

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    required String role
    
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: jsonEncode({
          'action': 'login',
          'username': username,
          'password': password, 
          'role': role
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        currentUsername = username;
        currentRole= role;
        
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }
}