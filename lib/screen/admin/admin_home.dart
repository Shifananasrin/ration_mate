import 'package:flutter/material.dart';
import 'package:ration_mate/screen/admin/add_entitlement.dart';
import 'package:ration_mate/screen/admin/add_stock.dart';
import 'package:ration_mate/screen/admin/update_gov.dart';
import 'package:ration_mate/screen/admin/view_complaint.dart';
import 'package:ration_mate/screen/admin/update_shopstatus.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AdminHomePage(shopId: '1'),
  ));
}

class AdminHomePage extends StatefulWidget {
  final String shopId;
  const AdminHomePage({super.key, required this.shopId});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    final List<_MenuItem> menuItems = [
      _MenuItem(
        label: 'Add Entitlement',
        icon: Icons.add_box,
        onTap: _onAddEntitlement,
        color: Colors.teal,
      ),
      _MenuItem(
        label: 'Add Stock',
        icon: Icons.inventory, // ✅ Fixed icon
        onTap: _onAddStock,
        color: Colors.purple,
      ),
      _MenuItem(
        label: 'View Complaints',
        icon: Icons.report,
        onTap: _onViewComplaints,
        color: Colors.orange,
      ),
      _MenuItem(
        label: 'Update Shop Status',
        icon: Icons.store,
        onTap: _onUpdateStatus,
        color: Colors.blue,
      ),
      _MenuItem(
        label: 'Gov Updates',
        icon: Icons.campaign,
        onTap: _onGovUpdates,
        color: Colors.green,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home Page', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[800],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: menuItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return _buildMenuCard(item);
          },
        ),
      ),
    );
  }

  Widget _buildMenuCard(_MenuItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: item.color.withOpacity(0.15),
              child: Icon(item.icon, color: item.color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(item.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _onAddEntitlement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MonthlyEntitlementPage(shopId: widget.shopId)),
    );
  }

  void _onAddStock() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddStockItemPage(shopId: widget.shopId)),
    );
  }

  void _onViewComplaints() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewComplaintsPage(shopId: widget.shopId)),
    );
  }

  void _onUpdateStatus() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateShopStatusPage(shopId: widget.shopId)),
    );
  }

  void _onGovUpdates() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateGovPage(shopId: widget.shopId)),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  _MenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
  });
}
