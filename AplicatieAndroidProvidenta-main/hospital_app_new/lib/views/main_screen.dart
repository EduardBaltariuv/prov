import 'package:flutter/material.dart';
import 'package:hospital_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import '../viewmodels/navigation_viewmodel.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/update_notification.dart';
import '../theme/app_theme.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationVM = Provider.of<NavigationViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);

    // Load login state when the screen is built
    if (authVM.getToken == null) {
      // You can show a login page or splash screen if the user is not logged in
      // Here I'm assuming you want to show a login screen or redirect to login if no token exists.
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
              const SizedBox(height: 16),
              Text(
                'Se verifică starea autentificării...',
                style: TextStyle(
                  color: AppTheme.steelGray,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If the user is logged in, proceed with the main screen content
    final String role = authVM.getRole ?? "reporter";

    return Scaffold(
      body: Column(
        children: [
          const UpdateBanner(),
          Expanded(
            child: IndexedStack(
              index: navigationVM.currentIndex,
              children: navigationVM.getPages(role),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(role: role),
    );
  }
}
