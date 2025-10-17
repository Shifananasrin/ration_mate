import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For formatting date

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  TextEditingController panchayathController = TextEditingController();
  List<dynamic> stockList = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchStock() async {
    final panchayath = panchayathController.text.trim();
    if (panchayath.isEmpty) {
      setState(() {
        errorMessage = "Please enter Panchayath name";
        stockList = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      stockList = [];
    });

    try {
      final response = await http.get(
        Uri.parse(
            "http://192.168.196.202:8000/api/user/view-stock/?panchayath=$panchayath"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["success"] == true && data["data"] != null) {
          setState(() {
            stockList = data["data"];
          });
        } else {
          setState(() {
            errorMessage = "No stock available for this Panchayath.";
          });
        }
      } else {
        setState(() {
          errorMessage =
              "Failed to fetch stock. Status: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching stock: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  void dispose() {
    panchayathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Stock by Panchayath")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: panchayathController,
              decoration: InputDecoration(
                labelText: "Enter Panchayath Name",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: fetchStock,
                ),
              ),
              onSubmitted: (value) => fetchStock(),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: stockList.length,
                          itemBuilder: (context, index) {
                            var item = stockList[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  "${item['item_name']} - Qty: ${item['quantity']}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "Shop: ${item['shop_id']} | shopowner: ${item['username']} | Added: ${formatDate(item['created_at'])}",
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
