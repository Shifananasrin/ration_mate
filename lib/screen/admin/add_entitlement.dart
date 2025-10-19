import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MonthlyEntitlementPage extends StatefulWidget {
  const MonthlyEntitlementPage({super.key, required String shopId});

  @override
  State<MonthlyEntitlementPage> createState() => _MonthlyEntitlementPageState();
}

class _MonthlyEntitlementPageState extends State<MonthlyEntitlementPage> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String? selectedCardType;

  bool _isLoading = false;

  final String baseUrl = 'http://10.102.138.202:8000/api/entitlement/';

  Future<void> _submitEntitlement() async {
    if (itemNameController.text.isEmpty ||
        selectedCardType == null ||
        quantityController.text.isEmpty ||
        monthController.text.isEmpty ||
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠ All fields are required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}add/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "item_name": itemNameController.text.trim(),
          "card_type": selectedCardType,
          "quantity": int.tryParse(quantityController.text.trim()) ?? 0,
          "month": monthController.text.trim(),
          "price": double.tryParse(priceController.text.trim()) ?? 0.0,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Entitlement added successfully')),
        );
        itemNameController.clear();
        quantityController.clear();
        monthController.clear();
        priceController.clear();
        setState(() => selectedCardType = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['detail'] ?? '❌ Failed to add entitlement')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Could not connect to server')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Monthly Entitlement'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(itemNameController, 'Item Name'),
            const SizedBox(height: 12),

            // ✅ Dropdown UI
            DropdownButtonFormField<String>(
              value: selectedCardType,
              decoration: _inputDecoration('Select Card Type'),
              items: ['APL', 'BPL', 'AAY', 'PHH']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCardType = value!;
                });
              },
            ),
            const SizedBox(height: 12),

            _buildTextField(quantityController, 'Quantity', isNumber: true),
            const SizedBox(height: 12),
            _buildTextField(monthController, 'Month (e.g., Jan, Feb)'),
            const SizedBox(height: 12),
            _buildTextField(priceController, 'Price', isNumber: true),
            const SizedBox(height: 20),

            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _submitEntitlement,
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // ✅ Reusable Input Field Builder
  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: _inputDecoration(label),
    );
  }

  // ✅ Consistent Styling
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
