import 'package:flutter/material.dart';
import 'package:hospital_app/viewmodels/auth_viewmodel.dart';
import 'package:hospital_app/viewmodels/navigation_viewmodel.dart';
import 'package:hospital_app/widgets/custom_app_bar.dart';
import 'package:hospital_app/services/ota_update_service.dart';
import 'package:hospital_app/widgets/update_notification.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final navigationVM = Provider.of<NavigationViewModel>(context, listen: false);
    final Image profilePic = authVM.getProfileImage;
    final String role = authVM.getRole ?? "reporter";
    final String username = authVM.getUsername ?? "Utilizator necunoscut";

    return Scaffold(
      appBar: CustomAppBar(
        title: "Pagina de Profil",
        navigationIndex: PageKey.reports,
        useNavigator: false,
        actions: [
          const UpdateNotificationButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // Profile Picture and Username
            profileDetails(username, role, profilePic),

            const Divider(height: 32),
            
            // OTA Update Settings
            buildUpdateSettingsSection(),

            const Divider(height: 32),
            
            // Sign Out
            buildSignOutButton(authVM, navigationVM),
          ],
        ),
      ),
    );
  }

Widget profileDetails(String username, String role, Image profilePic) {
  return Column(
    children: [
      // Profile picture with "Change Photo" button at the bottom-right
      Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Profile picture
          CircleAvatar(
            radius: 50,
            backgroundImage: profilePic.image,
            backgroundColor: AppTheme.lightGray,
          ),
          // "Change Photo" button near the bottom-right of the profile picture
          GestureDetector(
            onTap: () {
              // Trigger image change logic here (e.g., open gallery)
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkGray.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.edit_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      // Username text
      Text(
        username,
        style: TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.bold,
          color: AppTheme.charcoal,
        ),
      ),
      const SizedBox(height: 12),
      // Role section
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppTheme.getCategoryIcon(role),
              size: 16,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 8),
            Text(
              mapRoleToString(role),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget buildChangePhotoButton(AuthViewModel authVM) {
  return Positioned(
    bottom: 0,
    right: 0,
    child: IconButton(
      icon: Icon(Icons.camera_alt, color: Colors.white),
      onPressed: () async {
        // TODO: Implement profile image change functionality
      },
    ),
  );
}


  Widget buildUpdateSettingsSection() {
    return Consumer<OTAUpdateService>(
      builder: (context, otaService, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lightGray.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.system_update,
                    color: AppTheme.primaryBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Actualizări aplicație',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.charcoal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Current version info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Versiunea curentă:',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.steelGray,
                    ),
                  ),
                  Text(
                    otaService.currentVersion ?? 'Necunoscută',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.charcoal,
                    ),
                  ),
                ],
              ),
              
              if (otaService.hasUpdate) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Versiune disponibilă:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.steelGray,
                      ),
                    ),
                    Text(
                      otaService.availableVersion ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Auto-update toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Actualizări automate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.charcoal,
                          ),
                        ),
                        Text(
                          'Verifică automat pentru actualizări',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.steelGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: otaService.autoUpdateEnabled,
                    onChanged: (value) async {
                      await otaService.setAutoUpdateEnabled(value);
                    },
                    activeColor: AppTheme.primaryBlue,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Manual check button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: AppTheme.primaryBlue.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: otaService.isCheckingForUpdates
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.refresh, color: Colors.white),
                  label: Text(
                    otaService.isCheckingForUpdates 
                        ? 'Se verifică...' 
                        : 'Verifică actualizări',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: otaService.isCheckingForUpdates 
                      ? null 
                      : () async {
                          await otaService.checkForUpdates();
                        },
                ),
              ),                    if (otaService.updateMessage != null)...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.errorRed.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppTheme.errorRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          otaService.updateMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.errorRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget buildSignOutButton(AuthViewModel authVM, NavigationViewModel navigationVM) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.errorRed,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppTheme.errorRed.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.logout_rounded, color: Colors.white),
        label: const Text(
          "Delogare",
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          navigationVM.setIndex(0);
          authVM.logout();
        },
      ),
    );
  }

  String mapRoleToString(String role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'reporter':
        return 'Reporter';
      case 'IT':
        return 'Tehnician IT';
      case 'Instalatii Electrice':
        return 'Electrician';
      case 'Instalatii Sanitare':
        return 'Instalator';
      case 'Feronerie/Usi/Geamuri':
        return 'Montator feronerie / uși / geamuri';
      case 'Mobilier/Paturi':
        return 'Montator mobilier / paturi';
      case 'Aparatura medicala':
        return 'Tehnician aparatură medicală';
      default:
        return 'Rol necunoscut';
    }
  }
}
