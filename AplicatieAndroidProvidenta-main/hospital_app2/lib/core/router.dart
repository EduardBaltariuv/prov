import 'package:flutter/material.dart';
import 'package:hospital_app/views/home/home_view.dart';
import '../views/reports/reports_view.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const PaginaAdmin());
      case '/reports':
        return MaterialPageRoute(builder: (_) => const ReportsListView());
      case '/profile':
        //return MaterialPageRoute(builder: (_) => const ProfileView());
        return MaterialPageRoute(builder: (_) => const ReportsListView());
      default:
        // return MaterialPageRoute(builder: (_) => const HomeView());
        return MaterialPageRoute(builder: (_) => const ReportsListView());
    }
  }
}
