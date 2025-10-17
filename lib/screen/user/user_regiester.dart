import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ration_mate/screen/user/user_otp.dart';

class UserRegisterScreen extends StatefulWidget {
  final String phoneNumber;

  const UserRegisterScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> controllers = {
    'cardholder_name': TextEditingController(),
    'card_number': TextEditingController(),
    'address': TextEditingController(),
    'family_members': TextEditingController(),
    'taluk': TextEditingController(),
    'pincode': TextEditingController(),
    'district': TextEditingController(),
    'panchayath': TextEditingController(),
    'ward_no': TextEditingController(),
    'monthly_income': TextEditingController(),
  };

  String? selectedCardType;
  bool _isLoading = false;
  late AnimationController _controller;

  final List<String> cardTypes = ['APL', 'BPL', 'PHH', 'AAY'];

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
    controllers.forEach((_, c) => c.dispose());
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCardType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Card Type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Register User
      final response = await http.post(
        Uri.parse('http://10.132.92.202:8000/api/users/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "phone_number": widget.phoneNumber,
          "language_preference": "en",
          "cardholder_name": controllers['cardholder_name']!.text,
          "card_type": selectedCardType, // ✅ included properly
          "card_number": controllers['card_number']!.text,
          "address": controllers['address']!.text,
          "family_members":
              int.tryParse(controllers['family_members']!.text) ?? 0,
          "taluk": controllers['taluk']!.text,
          "pincode": controllers['pincode']!.text,
          "district": controllers['district']!.text,
          "panchayath": controllers['panchayath']!.text,
          "ward_no": int.tryParse(controllers['ward_no']!.text) ?? 0,
          "monthly_income":
              double.tryParse(controllers['monthly_income']!.text) ?? 0.0,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      print('📡 Register Response: $data');

      if (response.statusCode == 200 || response.statusCode == 201) {
        String otp = '';

        // Automatically request OTP after registration
        try {
          final otpResponse = await http.post(
            Uri.parse('http://10.147.146.202:8000/api/users/resend_otp/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phone_number': widget.phoneNumber}),
          );

          final otpData = jsonDecode(otpResponse.body);
          if (otpData['success'] == true) {
            otp = otpData['otp']?.toString() ?? '';
          }
        } catch (e) {
          print('❌ OTP fetch error: $e');
        }

        // Navigate to OTP page with the generated OTP
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OtpPage(
              phoneNumber: widget.phoneNumber,
              otp: otp,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Something went wrong')),
        );
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Server took too long to respond. Try again.'),
        ),
      );
    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not connect to the server'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: WavePainter())),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_add, size: 80, color: Colors.white),
                    const SizedBox(height: 20),
                    const Text(
                      'User Registration',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Card Type Dropdown
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: DropdownButtonFormField<String>(
                              value: selectedCardType,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'CARD TYPE',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 12),
                              ),
                              items: cardTypes
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedCardType = val;
                                });
                              },
                              validator: (val) =>
                                  val == null || val.isEmpty ? 'Required' : null,
                            ),
                          ),

                          // Other fields
                          ...controllers.entries.map((field) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: TextFormField(
                                controller: field.value,
                                keyboardType: (field.key == 'family_members' ||
                                        field.key == 'ward_no' ||
                                        field.key == 'monthly_income')
                                    ? TextInputType.number
                                    : TextInputType.text,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: field.key
                                      .replaceAll('_', ' ')
                                      .toUpperCase(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 12),
                                ),
                                validator: (val) =>
                                    val == null || val.isEmpty ? 'Required' : null,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green[800],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.green,
                              )
                            : const Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
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
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF4CAF50);
    final path = Path()
      ..lineTo(0, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.9,
        size.width,
        size.height * 0.75,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
