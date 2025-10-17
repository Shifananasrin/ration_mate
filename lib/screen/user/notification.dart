import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  final String phoneNumber;
 
  final String userId;

  const NotificationPage({
    super.key,
    required this.phoneNumber,
    
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Center(
        child: Text(
          'User: $phoneNumber\nID: $userId',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
