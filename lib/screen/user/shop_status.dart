import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShopStatusPage extends StatefulWidget {
  const ShopStatusPage({super.key, required String phoneNumber, required String userId});

  @override
  State<ShopStatusPage> createState() => _SearchShopByPanchayathPageState();
}

class _SearchShopByPanchayathPageState extends State<ShopStatusPage> {
  final TextEditingController _panchayathController = TextEditingController();
  bool _loading = false;
  List<dynamic> _shops = [];
  String _errorMessage = '';

  Future<void> _searchShops() async {
    final query = _panchayathController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _errorMessage = "Please enter a Panchayath to search!";
        _shops = [];
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = '';
      _shops = [];
    });

    final url = Uri.parse(
        'http://192.168.196.202:8000/api/user/view-shop-status/?panchayath=$query');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _shops = data;
          if (_shops.isEmpty) {
            _errorMessage = "No shops found for '$query'";
          }
        });
      } else {
        setState(() {
          _errorMessage = "Failed to fetch shops";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _shopCard(Map shop) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.green[50],
      child: ListTile(
        title: Text(
          'Shop ID: ${shop['shop_id']}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Status: ${shop['status']}', style: const TextStyle(color: Colors.black87)),
            Text('Location: ${shop['location'] ?? "Not set"}', style: const TextStyle(color: Colors.black87)),
            Text('Panchayath: ${shop['panchayath'] ?? "Not set"}', style: const TextStyle(color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Shops by Panchayath'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _panchayathController,
              decoration: InputDecoration(
                labelText: 'Enter Panchayath',
                labelStyle: const TextStyle(color: Colors.green),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.green),
                  borderRadius: BorderRadius.circular(12),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _searchShops,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Search', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            _errorMessage.isNotEmpty
                ? Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _shops.length,
                      itemBuilder: (context, index) => _shopCard(_shops[index]),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
