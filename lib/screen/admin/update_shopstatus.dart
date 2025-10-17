import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateShopStatusPage extends StatefulWidget {
  const UpdateShopStatusPage({super.key, required this.shopId});
  final String shopId;

  @override
  State<UpdateShopStatusPage> createState() => _UpdateShopStatusPageState();
}

class _UpdateShopStatusPageState extends State<UpdateShopStatusPage> {
  final TextEditingController _shopIdController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _selectedStatus = 'active';
  bool _loading = false;
  String _responseMessage = '';

  @override
  void initState() {
    super.initState();
    _shopIdController.text = widget.shopId;
  }

  Future<void> _updateStatus() async {
    final shopId = _shopIdController.text.trim();
    final location = _locationController.text.trim();

    if (shopId.isEmpty) {
      setState(() {
        _responseMessage = "Shop ID is required!";
      });
      return;
    }

    setState(() {
      _loading = true;
      _responseMessage = '';
    });

    final url = Uri.parse(
        'http://192.168.196.202:8000/api/shopadmin/update-shop-status/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'shop_id': _shopIdController.text.trim(),
          'status': _selectedStatus,
          'location': location,
        }),
      );

      // Decode JSON safely
      if (response.statusCode == 200 || response.statusCode == 400) {
        final data = json.decode(response.body);
        setState(() {
          if (data['success'] == true) {
            _responseMessage = "Status updated successfully!";
          } else {
            _responseMessage = data['error'] ?? "Something went wrong!";
          }
        });
      } else {
        setState(() {
          _responseMessage =
              "Server error: ${response.statusCode}\n${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = "Error: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Shop Status'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _shopIdController,
              decoration: InputDecoration(
                labelText: 'Shop ID',
                border: const OutlineInputBorder(),
                fillColor: Colors.green[50],
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                border: const OutlineInputBorder(),
                fillColor: Colors.green[50],
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: const [
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Status',
                border: const OutlineInputBorder(),
                fillColor: Colors.green[50],
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _updateStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Update Status',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _responseMessage,
              style: TextStyle(
                fontSize: 16,
                color: _responseMessage.contains("success")
                    ? Colors.green[700]
                    : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
