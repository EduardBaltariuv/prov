import 'package:flutter/material.dart';
import 'package:hospital_app/viewmodels/auth_viewmodel.dart';
import 'package:hospital_app/viewmodels/navigation_viewmodel.dart';
import 'package:hospital_app/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // Profile Picture and Username
            profileDetails(username, role, profilePic),

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
            backgroundColor: Colors.transparent,
          ),
          // "Change Photo" button near the bottom-right of the profile picture
          GestureDetector(
            onTap: () {
              // Trigger image change logic here (e.g., open gallery)
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.edit,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      // Username text
      Text(
        username,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      // Role section
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          mapRoleToString(role),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
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
        await authVM.getProfileImage;
      },
    ),
  );
}


  Widget buildSignOutButton(AuthViewModel authVM, NavigationViewModel navigationVM) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: const Icon(Icons.logout, color: Colors.white),
      label: const Text(
        "Delogare",
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
      onPressed: () {
        navigationVM.setIndex(0);
        authVM.logout();
      },
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
