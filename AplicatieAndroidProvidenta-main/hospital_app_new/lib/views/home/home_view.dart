import 'dart:convert';
import 'package:hospital_app/viewmodels/navigation_viewmodel.dart';
import 'package:hospital_app/widgets/custom_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PaginaAdmin extends StatefulWidget {
  const PaginaAdmin({super.key});

  @override
  _PaginaAdminState createState() => _PaginaAdminState();
}

class _PaginaAdminState extends State<PaginaAdmin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String selectedRole = 'IT';  // Default selected role

  // URL for the API
  final String apiUrl = 'https://darkcyan-clam-483701.hostingersite.com/signup.php';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Pagina Admin",
        navigationIndex: PageKey.reports,
        useNavigator: false,
        enableBackButton: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.admin_panel_settings_rounded,
                size: 64,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(height: 16),
              Text(
                'Crează un cont',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.charcoal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Adaugă un nou utilizator în sistem',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.steelGray,
                ),
              ),
              const SizedBox(height: 32),
              _buildTextField('Nume Utilizator', Icons.person_rounded, _usernameController),
              const SizedBox(height: 16),
              _buildTextField('Parolă', Icons.lock_rounded, _passwordController, obscureText: true),
              const SizedBox(height: 16),
              _buildRoleDropdown(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _signup,
                  icon: const Icon(Icons.person_add_rounded),
                  label: const Text('Crează cont'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to handle text field creation
  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: AppTheme.darkGray),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.steelGray),
        prefixIcon: Icon(icon, color: AppTheme.steelGray),
        filled: true,
        fillColor: AppTheme.lightGray.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  // Method to handle role dropdown
  Widget _buildRoleDropdown() {
    List<String> roles = [
      'IT',
      'Instalatii Electrice',
      'Instalatii Sanitare',
      'Feronerie/Usi/Geamuri',
      'Mobilier/Paturi',
      'Aparatura medicala',
      'Reporter'
    ];

    return DropdownButtonFormField<String>(
      value: selectedRole,
      style: TextStyle(color: AppTheme.darkGray),
      decoration: InputDecoration(
        labelText: 'Selectează rolul',
        labelStyle: TextStyle(color: AppTheme.steelGray),
        prefixIcon: Icon(Icons.work_rounded, color: AppTheme.steelGray),
        filled: true,
        fillColor: AppTheme.lightGray.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dropdownColor: AppTheme.surfaceWhite,
      onChanged: (String? newValue) {
        setState(() {
          if (newValue != null) {
            selectedRole = newValue;
          }
        });
      },
      items: roles.map<DropdownMenuItem<String>>((String role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Row(
            children: [
              Icon(
                AppTheme.getCategoryIcon(role),
                size: 20,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  role,
                  style: TextStyle(
                    color: AppTheme.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Method to handle signup logic and send data to the API
  Future<void> _signup() async {
    // Map the role to lowercase 'reporter' if it's 'Reporter'
    String roleToSend = selectedRole == 'Reporter' ? 'reporter' : selectedRole;

    try {
      // Prepare the data to send
      var data = {
        'username': _usernameController.text,
        'password': _passwordController.text,
        'role': roleToSend, // Send the transformed role
      };

      // Send data via HTTP POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        // If the server returns a successful response
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contul a fost creat!')),
        );
      } else {
        // If the server returns an error response
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eroare la crearea contului')),
        );
      }
    } catch (e) {
      // Handle any errors
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eroare la conectare la server')),
      );
    }
  }
}
