import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EntitlementsPage extends StatefulWidget {
  final String userId;
  const EntitlementsPage({super.key, required this.userId, required String phoneNumber, required String cardType, required String month});

  @override
  State<EntitlementsPage> createState() => _EntitlementsPageState();
}

class _EntitlementsPageState extends State<EntitlementsPage> {
  List<dynamic> entitlements = [];
  bool isLoading = true;
  String? error;

  String? selectedCardType;

  final String baseUrl = 'http://10.102.138.202:8000/api/entitlement/list/';

  @override
  void initState() {
    super.initState();
    selectedCardType = 'APL'; // default card type
    fetchEntitlements();
  }

  Future<void> fetchEntitlements() async {
    if (selectedCardType == null) {
      setState(() {
        error = 'Please select a card type';
        entitlements = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        'user_id': widget.userId,
        'card_type': selectedCardType!,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        setState(() {
          if (body is List) {
            entitlements = body;
          } else if (body is Map && body['entitlements'] is List) {
            entitlements = body['entitlements'];
          } else {
            entitlements = [];
          }
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error ${response.statusCode}: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to fetch data: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final itemName = item['item_name'] ?? 'Unnamed item';
    final quantity = item['quantity']?.toString() ?? 'N/A';
    final month = item['month'] ?? 'N/A';
    final cardType = item['card_type'] ?? 'N/A';
    final price = item['price']?.toString() ?? 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item: $itemName', style: const TextStyle(fontSize: 16)),
            Text('Quantity: $quantity', style: const TextStyle(fontSize: 16)),
            Text('Month: $month', style: const TextStyle(fontSize: 16)),
            Text('Card Type: $cardType', style: const TextStyle(fontSize: 16)),
            Text('Price: $price', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entitlements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // back to home page
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: selectedCardType,
              decoration: InputDecoration(
                labelText: 'Select Card Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: ['APL', 'BPL', 'AAY', 'PHH']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCardType = value;
                  fetchEntitlements(); // Fetch again when card type changes
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchEntitlements,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? _buildError()
                      : entitlements.isEmpty
                          ? _buildEmpty()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              itemCount: entitlements.length,
                              itemBuilder: (context, index) {
                                final item = entitlements[index] as Map<String, dynamic>;
                                return _buildCard(item);
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.error_outline, size: 54, color: Colors.red[400]),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(error ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: fetchEntitlements,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 60),
        const Icon(Icons.inbox_rounded, size: 64, color: Colors.green),
        const SizedBox(height: 12),
        const Center(child: Text('No entitlements found')),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: fetchEntitlements,
            child: const Text('Refresh'),
          ),
        ),
      ],
    );
  }
}
