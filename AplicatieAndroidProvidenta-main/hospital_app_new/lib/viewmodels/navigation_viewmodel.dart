import 'package:flutter/material.dart';
import 'package:hospital_app/views/home/home_view.dart';
import 'package:hospital_app/views/profile/profile_view.dart';
import 'package:hospital_app/views/reports/create_report_view.dart';
import 'package:hospital_app/views/reports/reports_view.dart';

enum PageKey {
  dashboard,
  reports,
  create,
  profile,
}

class NavigationViewModel extends ChangeNotifier {
  static const int homePageIndex = 0;
  static const int reportsListPageIndex = 1;
  static const int addReportPageIndex = 2;
  static const int profilePageIndex = 3;

  String? role;

  void setRole(String? userRole) {
    role = userRole;
  }

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  // Adjust this method to ensure that index is within bounds
  void setIndex(int index) {
    List<Widget> pages = getPages(role!);
    if (index < 0 || index >= pages.length) {
      print('Index invalid: $index');
      return;
    }
    _currentIndex = index;
    notifyListeners();
  }

  void navigateTo(PageKey key) {
    final indexMap = _getIndexMap(role!);
    if (indexMap.containsKey(key)) {
      _currentIndex = indexMap[key]!;
      notifyListeners();
    }
  }

  Map<PageKey, int> _getIndexMap(String role) {
    switch (role) {
      case 'admin':
        return {
          PageKey.dashboard: 0,
          PageKey.reports: 1,
          PageKey.create: 2,
          PageKey.profile: 3, // Removed notifications
        };
      case 'reporter':
        return {
          PageKey.reports: 0,
          PageKey.create: 1,
          PageKey.profile: 2, // Removed notifications
        };
      case 'IT':
      case 'Instalatii Electrice':
      case 'Instalatii Sanitare':
      case 'Feronerie/Usi/Geamuri':
      case 'Mobilier/Paturi':
      case 'Aparatura medicala':
        return {
          PageKey.reports: 0,
          PageKey.profile: 1, // Removed notifications
        };
      default:
        return {};
    }
  }

  List<Widget> getPages(String role) {
    switch (role) {
      case 'admin':
        return [
          PaginaAdmin(),
          ReportsListView(),
          CreateReportView(),
          ProfileView(),
        ];
      case 'reporter':
        return [
          ReportsListView(),
          CreateReportView(),
          ProfileView(),
        ];
      case 'IT':
      case 'Instalatii Electrice':
      case 'Instalatii Sanitare':
      case 'Feronerie/Usi/Geamuri':
      case 'Mobilier/Paturi':
      case 'Aparatura medicala':
        return [
          ReportsListView(),
          ProfileView(),
        ];
      default:
        return [];
    }
  }
}
