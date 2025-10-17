import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'admin_home.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

enum FormType { login, createPassword, changePassword }

class _AdminLoginPageState extends State<AdminLoginPage> {
  FormType currentForm = FormType.login;

  final TextEditingController adminNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool _isLoading = false;

  final String baseUrl = 'http://10.102.138.202:8000/api/owner/';

  // ---------------- LOGIN ----------------
  Future<void> _login() async {
    if (adminNameController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      _showSnackBar('Admin Name and Password are required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'admin_name': adminNameController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminHomePage(shopId: data['shop_id'] ?? ''),
          ),
        );
      } else {
        _showSnackBar(data['detail'] ?? 'Login failed');
      }
    } catch (e) {
      _showSnackBar('Could not connect to server');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ---------------- CREATE PASSWORD ----------------
  Future<void> _createPassword() async {
    if (adminNameController.text.trim().isEmpty || newPasswordController.text.trim().isEmpty) {
      _showSnackBar('Admin Name and New Password are required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}create-password/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'admin_name': adminNameController.text.trim(),
          'new_password': newPasswordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _showSnackBar('Password created successfully');
        setState(() => currentForm = FormType.login);
      } else {
        _showSnackBar(data['detail'] ?? 'Failed to create password');
      }
    } catch (e) {
      _showSnackBar('Could not connect to server');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ---------------- CHANGE PASSWORD ----------------
  Future<void> _changePassword() async {
    if (adminNameController.text.trim().isEmpty ||
        oldPasswordController.text.trim().isEmpty ||
        newPasswordController.text.trim().isEmpty) {
      _showSnackBar('All fields are required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}change-password/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'admin_name': adminNameController.text.trim(),
          'old_password': oldPasswordController.text.trim(),
          'new_password': newPasswordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _showSnackBar('Password changed successfully');
        setState(() => currentForm = FormType.login);
      } else {
        _showSnackBar(data['detail'] ?? 'Failed to change password');
      }
    } catch (e) {
      _showSnackBar('Could not connect to server');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ---------------- BUILD FORM ----------------
  Widget _buildForm() {
    switch (currentForm) {
      case FormType.login:
        return _loginForm();
      case FormType.createPassword:
        return _createPasswordForm();
      case FormType.changePassword:
        return _changePasswordForm();
    }
  }

  Widget _loginForm() {
    return Column(
      children: [
        _buildTextField(adminNameController, 'Admin Name', Icons.person),
        const SizedBox(height: 15),
        _buildTextField(passwordController, 'Password', Icons.lock, obscureText: true),
        const SizedBox(height: 20),
        _buildButton('Login', _login),
      ],
    );
  }

  Widget _createPasswordForm() {
    return Column(
      children: [
        _buildTextField(adminNameController, 'Admin Name', Icons.person),
        const SizedBox(height: 15),
        _buildTextField(newPasswordController, 'New Password', Icons.lock, obscureText: true),
        const SizedBox(height: 20),
        _buildButton('Create Password', _createPassword),
      ],
    );
  }

  Widget _changePasswordForm() {
    return Column(
      children: [
        _buildTextField(adminNameController, 'Admin Name', Icons.person),
        const SizedBox(height: 15),
        _buildTextField(oldPasswordController, 'Old Password', Icons.lock, obscureText: true),
        const SizedBox(height: 15),
        _buildTextField(newPasswordController, 'New Password', Icons.lock, obscureText: true),
        const SizedBox(height: 20),
        _buildButton('Change Password', _changePassword),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.admin_panel_settings, size: 80, color: Colors.green),
                  const SizedBox(height: 15),
                  Text(
                    currentForm == FormType.login
                        ? 'Admin Login'
                        : currentForm == FormType.createPassword
                            ? 'Create Password'
                            : 'Change Password',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 20),
                  _buildForm(),
                  const SizedBox(height: 15),
                  _buildFormSwitcher(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (currentForm != FormType.createPassword)
          TextButton(
            onPressed: () => setState(() => currentForm = FormType.createPassword),
            child: const Text('Create Password'),
          ),
        if (currentForm != FormType.changePassword)
          TextButton(
            onPressed: () => setState(() => currentForm = FormType.changePassword),
            child: const Text('Change Password'),
          ),
        if (currentForm != FormType.login)
          TextButton(
            onPressed: () => setState(() => currentForm = FormType.login),
            child: const Text('Back to Login'),
          ),
      ],
    );
  }
}
