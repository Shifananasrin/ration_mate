import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddStockItemPage extends StatefulWidget {
  final String shopId; 

  const AddStockItemPage({super.key, required this.shopId});

  @override
  _AddStockPageState createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockItemPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController itemNameController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  bool isLoading = false;

  Future<void> addStock() async {
    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse("http://192.168.196.202:8000/api/shopadmin/add-stock-item/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "shop_id": widget.shopId, 
        "item_name": itemNameController.text,
        "quantity": qtyController.text,
      }),
    );

    final data = json.decode(response.body);
    setState(() => isLoading = false);

    if (data['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Stock Added Successfully ✅")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${data['error'] ?? data['errors']}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Stock Item")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Shop ID: ${widget.shopId}", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: itemNameController,
                decoration: const InputDecoration(labelText: "Item Name"),
              ),
              TextFormField(
                controller: qtyController,
                decoration: const InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: addStock,
                      child: const Text("Add Stock"),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
