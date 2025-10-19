import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'admin_pass.dart';

class AdminRegisterPage extends StatefulWidget {
  const AdminRegisterPage({super.key, required this.shopId});

  final String shopId;

  @override
  State<AdminRegisterPage> createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage>
    with SingleTickerProviderStateMixin {  // Controllers
  final TextEditingController _fpsController = TextEditingController();
  final TextEditingController _shopIdController = TextEditingController();
  final TextEditingController _salesmanIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _thalukController = TextEditingController();
  final TextEditingController _panchayathController = TextEditingController();

  bool _isLoading = false;
  late AnimationController _controller;

  final String baseUrl =
      "http://192.168.196.202:8000/api/shopadmin/register/"; // API URL

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fpsController.dispose();
    _shopIdController.dispose();
    _salesmanIdController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _districtController.dispose();
    _thalukController.dispose();
    _panchayathController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _registerAdmin() async {
    final fpsCode = _fpsController.text.trim();
    final shopId = _shopIdController.text.trim();
    final salesmanId = _salesmanIdController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    final district = _districtController.text.trim();
    final thaluk = _thalukController.text.trim();
    final panchayath = _panchayathController.text.trim();

    // Check empty fields
    if (fpsCode.isEmpty ||
        shopId.isEmpty ||
        salesmanId.isEmpty ||
        name.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty ||
        district.isEmpty ||
        thaluk.isEmpty ||
        panchayath.isEmpty) {
      _showOverlayMessage("All fields are required", Colors.red, center: true);
      return;
    }

    // Password match
    if (password != confirm) {
      _showOverlayMessage("Passwords do not match", Colors.red, center: true);
      return;
    }

    // Phone validation: exactly 10 digits
    final phonePattern = RegExp(r'^\d{10}$');
    if (!phonePattern.hasMatch(phone)) {
      _showOverlayMessage("Phone number must be 10 digits", Colors.red,
          center: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fps_code": fpsCode,
          "shop_id": shopId,
          "salesman_id": salesmanId,
          "username": name,
          "phone_number": phone,
          "password": password,
          "district": district,
          "thaluk": thaluk,
          "panchayath": panchayath,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showOverlayMessage("Registration Successful!", Colors.green,
            center: false);

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminPasswordPage(shopId: shopId),
            ),
          );
        });
      } else {
        _showOverlayMessage(
          data['error'] ?? "Error during registration",
          Colors.red,
          center: true,
        );
      }
    } catch (e) {
      _showOverlayMessage("Error during registration: $e", Colors.red,
          center: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showOverlayMessage(String message, Color color, {bool center = false}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: center ? null : 50,
        left: 20,
        right: 20,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: 1,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800],
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: WavePainter())),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.admin_panel_settings,
                        size: 80, color: Colors.white),
                    const SizedBox(height: 20),
                    const Text(
                      'Admin Registration',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_fpsController, 'FPS Code'),
                    const SizedBox(height: 15),
                    _buildTextField(_shopIdController, 'Shop ID'),
                    const SizedBox(height: 15),
                    _buildTextField(_salesmanIdController, 'Salesman ID'),
                    const SizedBox(height: 15),
                    _buildTextField(_nameController, 'Enter Name'),
                    const SizedBox(height: 15),
                    _buildTextField(_phoneController, 'Phone Number',
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 15),
                    _buildTextField(_passwordController, 'Enter Password',
                        obscureText: true),
                    const SizedBox(height: 15),
                    _buildTextField(_confirmController, 'Confirm Password',
                        obscureText: true),
                    const SizedBox(height: 15),
                    _buildTextField(_districtController, 'District'),
                    const SizedBox(height: 15),
                    _buildTextField(_thalukController, 'Thaluk'),
                    const SizedBox(height: 15),
                    _buildTextField(_panchayathController, 'Panchayath'),
                    const SizedBox(height: 25),
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerAdmin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green[800],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.green)
                            : const Text(
                                'Register',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.characters, // optional
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF4CAF50).withOpacity(0.6);

    final path = Path()
      ..lineTo(0, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.70,
          size.width * 0.5, size.height * 0.80)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.90,
          size.width, size.height * 0.80)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    final paint2 = Paint()..color = const Color(0xFF66BB6A).withOpacity(0.4);

    final path2 = Path()
      ..lineTo(0, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.80,
          size.width * 0.5, size.height * 0.90)
      ..quadraticBezierTo(size.width * 0.75, size.height, size.width,
          size.height * 0.90)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
