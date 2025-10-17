import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CardDetailsPage extends StatefulWidget {
  final String userId;
  final String phoneNumber;

  const CardDetailsPage({
    super.key,
    required this.userId,
    required this.phoneNumber,
  });

  @override
  State<CardDetailsPage> createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  Map<String, dynamic>? cardData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCardDetails();
  }

  Future<void> fetchCardDetails() async {
    if (widget.userId.isEmpty) {
      setState(() {
        errorMessage = 'Invalid User ID';
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
        'http://10.102.138.202:8000/api/users/${widget.userId}/card_details/');

    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("DEBUG JSON: $data"); // <-- check your JSON keys
        setState(() {
          cardData = data;
          isLoading = false;
        });
      } else if (response.statusCode == 400) {
        setState(() {
          errorMessage = 'Bad request – check user ID';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error connecting to server: $e';
        isLoading = false;
      });
    }
  }

  Widget buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700]),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.green),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Card Details'),
          backgroundColor: Colors.green,
        ),
        body: Center(child: Text(errorMessage!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Details'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          color: Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                buildInfoRow(Icons.person, 'Name',
                    cardData?['cardholder_name']?.toString() ?? 'N/A'),
                buildInfoRow(Icons.credit_card, 'Card Number',
                    cardData?['card_number']?.toString() ?? 'N/A'),
                buildInfoRow(Icons.card_membership, 'Card Type',
                    // ✅ ensure card type shows correctly
                    cardData?['card_type']?.toString().toUpperCase() ?? 'N/A'),
                buildInfoRow(Icons.phone, 'Phone',
                    cardData?['phone_number']?.toString() ?? 'N/A'),
                buildInfoRow(Icons.home, 'Address',
                    cardData?['address']?.toString() ?? 'N/A'),
                buildInfoRow(Icons.location_city, 'District',
                    cardData?['district']?.toString() ?? 'N/A'),
                buildInfoRow(Icons.map, 'Taluk',
                    cardData?['taluk']?.toString() ?? 'N/A'),
                buildInfoRow(Icons.pin_drop, 'Pincode',
                    cardData?['pincode']?.toString() ?? 'N/A'),
                buildInfoRow(Icons.family_restroom, 'Family Members',
                    cardData?['family_members']?.toString() ?? '0'),
                buildInfoRow(Icons.location_on, 'Panchayath',
                    cardData?['panchayath']?.toString() ?? 'N/A'),
                buildInfoRow(Icons.home_work, 'Ward No',
                    cardData?['ward_no']?.toString() ?? 'N/A'),
                buildInfoRow(Icons.money, 'Monthly Income',
                    cardData?['monthly_income']?.toString() ?? 'N/A'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
