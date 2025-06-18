import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final List<String> _notifications = [];
  final StreamController<List<String>> _controller = StreamController<List<String>>.broadcast();
  bool _isInitialized = false;
  
  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  void add(String message) {
    _notifications.add(message);
    _controller.add(List.unmodifiable(_notifications));
  }

  void clear() {
    _notifications.clear();
    _controller.add([]);
  }

  void dispose() => _controller.close();

  Future<void> init() async {
    if (_isInitialized) {
      print('NotificationService already initialized');
      return;
    }

    try {
      // Request permission for notifications with proper error handling
      await _requestNotificationPermissions();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Set up FCM handlers
      await _setupFCMHandlers();
      
      _isInitialized = true;
      print('NotificationService initialization completed successfully');
    } catch (e, stackTrace) {
      print('Error initializing NotificationService: $e');
      print('Stack trace: $stackTrace');
      // Don't rethrow - handle gracefully in production
      _isInitialized = false;
    }
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        carPlay: false,
        criticalAlert: false,
        announcement: false,
      );
      
      print('User granted permission: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('User denied notification permissions');
        // Handle denied permissions gracefully
        return;
      }
    } catch (e) {
      print('Error requesting notification permissions: $e');
      // Continue initialization even if permission request fails
    }
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          _handleNotificationTap(details.payload);
        },
      );

      // Create notification channel with proper error handling
      const androidChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        enableVibration: true,
        enableLights: true,
        ledColor: Color.fromARGB(255, 255, 0, 0),
        showBadge: true,
      );

      try {
        await _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(androidChannel);
        print('Notification channel created successfully');
      } catch (e) {
        print('Error creating notification channel: $e');
        // Continue even if channel creation fails
      }
    } catch (e) {
      print('Error initializing local notifications: $e');
      // Continue even if local notifications fail
    }
  }

  Future<void> _setupFCMHandlers() async {
    try {
      // Get FCM token with retry logic
      String? token;
      for (int i = 0; i < 3; i++) {
        try {
          token = await _messaging.getToken();
          if (token != null) break;
        } catch (e) {
          print('Attempt ${i + 1} to get FCM token failed: $e');
          await Future.delayed(Duration(seconds: 1));
        }
      }
      print('FCM Token: $token');

      // Set up message handlers
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received foreground message: ${message.messageId}');
        _showLocalNotification(message);
      });
    } catch (e) {
      print('Error setting up FCM handlers: $e');
      // Continue even if FCM setup fails
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      // You can add navigation logic here if needed
      print('Notification tapped with payload: $payload');
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      channelShowBadge: true,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Method to check and request notification permissions on newer Android versions
  Future<void> checkAndRequestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notification permissions granted');
    } else {
      print('Notification permissions denied');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}