import 'package:flutter/material.dart';
import 'package:ration_mate/screen/user/card_details.dart';
import 'package:ration_mate/screen/user/entitlment.dart';
import 'package:ration_mate/screen/user/notification.dart';
import 'package:ration_mate/screen/user/stock_avaliablity.dart';
import 'package:ration_mate/screen/user/shop_status.dart';
import 'package:ration_mate/screen/user/complaint.dart';

class HomePage extends StatelessWidget {
  final String phoneNumber;
  final String userId;

  const HomePage({
    super.key,
    required this.phoneNumber,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    // English only
    const t = {
      'title': 'Home Page',
      'card': 'Card Details',
      'entitlement': 'Entitlements',
      'stock': 'Available Stock',
      'shop': 'Shop Status',
      'complaint': 'Submit Complaint',
      'notification': 'Notifications',
    };

    final List<_HomeItem> items = [
      _HomeItem(
        Icons.credit_card,
        t['card']!,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CardDetailsPage(
              userId: userId,
              phoneNumber: phoneNumber,
            ),
          ),
        ),
      ),
      _HomeItem(
        Icons.calendar_month,
        t['entitlement']!,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EntitlementsPage
            (
              userId: userId,
              phoneNumber: phoneNumber, cardType: '', month: '',
            ),
          ),
        ),
      ),
      _HomeItem(
        Icons.inventory,
        t['stock']!,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StockPage(),
          ),
        ),
      ),
      _HomeItem(
        Icons.store,
        t['shop']!,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShopStatusPage(
              userId: userId,
              phoneNumber: phoneNumber,
            ),
          ),
        ),
      ),
      _HomeItem(
        Icons.report_problem,
        t['complaint']!,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ComplaintPage(
              userId: userId,
              phoneNumber: phoneNumber,
            ),
          ),
        ),
      ),
      _HomeItem(
        Icons.notifications,
        t['notification']!,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationPage(
              userId: userId,
              phoneNumber: phoneNumber,
            ),
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: item.onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 40, color: Colors.green[700]),
                    const SizedBox(height: 10),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _HomeItem(this.icon, this.label, this.onTap);
}
