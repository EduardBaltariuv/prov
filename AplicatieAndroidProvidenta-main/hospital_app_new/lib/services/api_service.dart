import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';


class ApiService {
  static const String _baseUrl = 'https://darkcyan-clam-483701.hostingersite.com/apireports.php';

static Future<Map<String, dynamic>> createReport({
  required String title,
  required String description,
  required String category,
  required String location,
  required List<XFile> images,
  required String username,
}) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse(_baseUrl))
      ..fields['action'] = 'createReport'
      ..fields['title'] = title
      ..fields['description'] = description
      ..fields['category'] = category
      ..fields['location'] = location
      ..fields['username'] = username;

    // Add images as bytes
    for (var image in images) {
      final bytes = await image.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'images[]', // PHP expects this format for multiple files as an array
        bytes,
        filename: image.name,
        contentType: MediaType.parse(lookupMimeType(image.name) ?? 'image/jpeg'),
      )); 
    }

    // Added debug print
    print('Sending request to ${_baseUrl} with fields: ${request.fields} and ${request.files.length} files');

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final data = jsonDecode(responseData);

    print('Response status: ${response.statusCode}');
    print('Response data: $responseData');

    // Check for server-side errors first
    if (data != null && data['success'] == false) {
      // Handle specific error codes from our server-side fix
      final errorCode = data['error_code'] ?? '';
      final message = data['message'] ?? 'Unknown error';
      
      if (errorCode == 'USER_NOT_AUTHENTICATED' || errorCode == 'INVALID_USER') {
        throw Exception('USER_NOT_AUTHENTICATED: $message');
      } else if (errorCode == 'MISSING_REQUIRED_FIELDS') {
        throw Exception('MISSING_FIELDS: $message');
      } else {
        throw Exception('SERVER_ERROR: $message');
      }
    }

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception('HTTP_ERROR: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to submit report: ${e.toString()}');
  }
}

static Future<Map<String, dynamic>?> login({
  required String username,
  required String password,
  required String role,
}) async {
  // Use the correct API endpoint for login
  const String loginUrl = 'https://darkcyan-clam-483701.hostingersite.com/api.php';
  
  try {
    print('Attempting login to: $loginUrl');
    print('Login data: username=$username, role=$role');
    
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'login',
        'username': username,
        'password': password,
        'role': role,
      }),
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  } catch (e) {
    print('Login error: $e');
    return null;
  }
}
}