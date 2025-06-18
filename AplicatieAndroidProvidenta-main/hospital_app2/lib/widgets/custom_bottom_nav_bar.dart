import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/navigation_viewmodel.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key, required this.role});

  final String? role;

  static const iconColor = Color.fromARGB(255, 0, 0, 0);

  @override
  Widget build(BuildContext context) {
    final navigationVM = Provider.of<NavigationViewModel>(context);

    if (role != null) {
      navigationVM.setRole(role);
    }

    return BottomNavigationBar(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      type: BottomNavigationBarType.fixed,
      currentIndex: navigationVM.currentIndex,
      onTap: navigationVM.setIndex,
      items: getNavBarItems(role ?? ''),
    );
  }

  List<BottomNavigationBarItem> getNavBarItems(String role) {
    switch (role) {
      case 'admin':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, color: iconColor),
            activeIcon: Icon(Icons.home, color: iconColor),
            label: 'Acasă',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined, color: iconColor),
            activeIcon: Icon(Icons.explore, color: iconColor),
            label: 'Rapoarte',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add, color: iconColor),
            activeIcon: Icon(Icons.add_circle, color: iconColor),
            label: 'Adaugă',
          ),
          // Removed Notifications tab
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined, color: iconColor),
            activeIcon: Icon(Icons.account_circle, color: iconColor),
            label: 'Profil',
          ),
        ];

      case 'reporter':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined, color: iconColor),
            activeIcon: Icon(Icons.explore, color: iconColor),
            label: 'Rapoarte',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add, color: iconColor),
            activeIcon: Icon(Icons.add_circle, color: iconColor),
            label: 'Adaugă',
          ),
          // Removed Notifications tab
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined, color: iconColor),
            activeIcon: Icon(Icons.account_circle, color: iconColor),
            label: 'Profil',
          ),
        ];

      case 'IT':
      case 'Instalatii Electrice':
      case 'Instalatii Sanitare':
      case 'Feronerie/Usi/Geamuri':
      case 'Mobilier/Paturi':
      case 'Aparatura medicala':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined, color: iconColor),
            activeIcon: Icon(Icons.explore, color: iconColor),
            label: 'Rapoarte',
          ),
          // Removed Notifications tab
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined, color: iconColor),
            activeIcon: Icon(Icons.account_circle, color: iconColor),
            label: 'Profil',
          ),
        ];

      default:
        return [];
    }
  }
}
