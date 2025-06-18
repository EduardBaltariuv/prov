import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hospital_app/services/notification_service.dart';
import 'package:hospital_app/services/api_service.dart';

class AuthViewModel extends ChangeNotifier {
  String? _token;
  String? _username;
  String? _role;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get getIsLoading => _isLoading;
  String? get getToken => _token;
  String? get getUsername => _username;
  String? get username => _username;
  String? get getRole => _role;
  String? get errorMessage => _errorMessage;
  
  Image get getProfileImage => Image.asset('assets/images/default_profile_pic.png');

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Load user data from shared preferences on app start
  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _username = prefs.getString('username');
      _role = prefs.getString('role');
      notifyListeners();
    } catch (e) {
      print('Error loading user data: $e');
      // Don't throw, just continue with null values
    }
  }

  // Save user data to shared_preferences
  Future<void> saveUserData(String token, String username, String? role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('username', username);
      if (role != null) {
        await prefs.setString('role', role);
      }
      
      _token = token;
      _username = username;
      _role = role;
      notifyListeners();
    } catch (e) {
      print('Error saving user data: $e');
      throw Exception('Failed to save user data');
    }
  }

  // Remove login data from shared_preferences (on logout)
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('username');
      await prefs.remove('role');
      
      // Unsubscribe from FCM topics
      await _unsubscribeFromPushNotifications();
      
      _token = null;
      _username = null;
      _role = null;
      notifyListeners();
    } catch (e) {
      print('Error clearing user data: $e');
      throw Exception('Failed to clear user data');
    }
  }

  // Subscribe to FCM topics based on role
  Future<void> _subscribeToPushNotifications(String role) async {
    try {
      final notificationService = NotificationService();
      await notificationService.subscribeToTopic(role);
      if (role != 'admin' && _username != null) {
        await notificationService.subscribeToTopic('user_$_username');
      }
      if (role == 'admin') {
        await notificationService.subscribeToTopic('all_reports');
      }
    } catch (e) {
      print('Error subscribing to notifications: $e');
      // Don't throw, continue without notifications
    }
  }

  // Unsubscribe from all topics on logout
  Future<void> _unsubscribeFromPushNotifications() async {
    try {
      final notificationService = NotificationService();
      if (_role != null) {
        await notificationService.unsubscribeFromTopic(_role!);
      }
      if (_username != null) {
        await notificationService.unsubscribeFromTopic('user_$_username');
      }
      if (_role == 'admin') {
        await notificationService.unsubscribeFromTopic('all_reports');
      }
    } catch (e) {
      print('Error unsubscribing from notifications: $e');
      // Don't throw, continue with logout
    }
  }

  Future<bool> login(String user, String pass) async {
    isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Attempting login for user: $user with role: ${_role ?? "reporter"}');
      
      final response = await ApiService.login(
        username: user,
        password: pass,
        role: _role ?? 'reporter',
      );

      print('Login response received: $response');

      if (response != null && response['success'] == true && response.containsKey('token')) {
        await saveUserData(
          response['token'],
          user,
          response['role'] ?? _role,
        );

        // Try to subscribe to notifications, but don't block login if it fails
        if (_role != null) {
          await _subscribeToPushNotifications(_role!).catchError((e) {
            print('Failed to subscribe to notifications: $e');
          });
        }

        _errorMessage = null;
        isLoading = false;
        return true;
      } else {
        // Check for specific error messages from server
        _errorMessage = response?['message'] ?? 'Nume de utilizator sau parolă incorectă';
        print('Login failed: $_errorMessage');
        isLoading = false;
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      _errorMessage = 'Connection error. Please check your internet connection.';
      isLoading = false;
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('username');
      await prefs.remove('role');
      
      _token = null;
      _username = null;
      _role = null;
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
