import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewComplaintsPage extends StatefulWidget {
  const ViewComplaintsPage({super.key, required String shopId});

  @override
  State<ViewComplaintsPage> createState() => _ViewComplaintsPageState();
}

class _ViewComplaintsPageState extends State<ViewComplaintsPage> {
  bool loading = true;
  String? error;
  List<dynamic> complaints = [];

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    final url = Uri.parse('http://10.147.146.202:8000/api/complaints/'); // Replace with your API endpoint

    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          complaints = data; // Assuming API returns a list
          loading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load complaints: ${response.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error connecting to server: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
        backgroundColor: Colors.redAccent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : complaints.isEmpty
                  ? const Center(child: Text('No complaints found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: complaints.length,
                      itemBuilder: (context, index) {
                        final complaint = complaints[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.redAccent.withOpacity(0.2),
                              child: const Icon(Icons.report_problem, color: Colors.red),
                            ),
                            title: Text(
                              complaint['title'] ?? 'No title',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(complaint['description'] ?? 'No description'),
                                const SizedBox(height: 4),
                                Text(
                                  'Status: ${complaint['status'] ?? 'Pending'}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
