import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hospital_app/services/notification_service.dart';
import 'package:hospital_app/viewmodels/auth_viewmodel.dart';
import 'package:hospital_app/viewmodels/image_picker_viewmodel.dart';
import 'package:hospital_app/viewmodels/navigation_viewmodel.dart';
import 'package:hospital_app/viewmodels/report_viewmodel.dart';
import 'package:hospital_app/views/login_screen.dart';
import 'package:hospital_app/views/main_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Create AuthViewModel instance first
  final authViewModel = AuthViewModel();
  bool firebaseInitialized = false;

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCYN032YLtcOzUZYYbcefiFojOmzTEAHQk',
        appId: '1:58666358662:android:6185e1e30cb2fb1366be07',
        messagingSenderId: '58666358662',
        projectId: 'aplicatieprovidenta',
        storageBucket: 'aplicatieprovidenta.firebasestorage.app',
      ),
    );
    firebaseInitialized = true;
    debugPrint('Firebase initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    // Continue with app initialization even if Firebase fails
  }

  // Initialize notifications if Firebase is available
  if (firebaseInitialized) {
    try {
      final notificationService = NotificationService();
      await notificationService.init();
      debugPrint('Notification service initialized successfully');

      // Load user data and set up subscriptions
      await authViewModel.loadUserData();
      if (authViewModel.getToken != null) {
        await _setupNotificationSubscriptions(notificationService, authViewModel);
      }
    } catch (e) {
      debugPrint('Notification setup failed: $e');
      // Continue even if notification setup fails
    }
  }

  // Run the app with proper error boundaries
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NavigationViewModel()),
        ChangeNotifierProvider(create: (context) => ReportViewModel()),
        ChangeNotifierProvider.value(value: authViewModel),
        ChangeNotifierProvider(create: (_) => ImagePickerViewModel()),
      ],
      child: MyApp(
        authViewModel: authViewModel,
        firebaseAvailable: firebaseInitialized,
      ),
    ),
  );
}

Future<void> _setupNotificationSubscriptions(NotificationService service, AuthViewModel auth) async {
  try {
    if (auth.getRole == 'admin') {
      await service.subscribeToTopic('admin');
    }
    if (auth.getUsername != null) {
      await service.subscribeToTopic('user_${auth.getUsername}');
    }
    if (auth.getRole != 'admin' && auth.getRole != 'reporter') {
      await service.subscribeToTopic(auth.getRole!.toLowerCase());
    }
  } catch (e) {
    debugPrint('Error setting up notification subscriptions: $e');
  }
}

class MyApp extends StatelessWidget {
  final AuthViewModel authViewModel;
  final bool firebaseAvailable;

  const MyApp({
    super.key,
    required this.authViewModel,
    required this.firebaseAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicatie Mentenanta',
      theme: ThemeData(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
      ),
      routes: {
        '/debug': (_) => Scaffold(
          appBar: AppBar(title: const Text('Debug')),
          body: const Center(child: Text('Navigation Test')),
        ),
      },
      home: Consumer<AuthViewModel>(
        builder: (context, auth, _) {
          return auth.getToken != null ? const MainScreen() : const LoginScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
