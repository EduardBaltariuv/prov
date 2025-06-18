import 'dart:convert';
import 'package:hospital_app/viewmodels/navigation_viewmodel.dart';
import 'package:hospital_app/widgets/custom_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

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
              const Text(
                'Crează un cont',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildTextField('Nume Utilizator', Icons.person, _usernameController),
              const SizedBox(height: 12),
              _buildTextField('Parolă', Icons.lock, _passwordController, obscureText: true),
              const SizedBox(height: 12),
              _buildRoleDropdown(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signup,  // Call the signup method
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Crează cont',
                  style: TextStyle(fontSize: 16, color: Colors.white),
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
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
      decoration: InputDecoration(
        labelText: 'Selectează rolul',
        prefixIcon: const Icon(Icons.account_circle),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
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
          child: Text(role),
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
