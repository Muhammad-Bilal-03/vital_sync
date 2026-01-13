import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../../../providers/order_provider.dart';
import '../../../models/order_model.dart';
import '../../widgets/glass_card.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reports",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: VitalColors.oceanTeal,
          unselectedLabelColor: Colors.grey,
          indicatorColor: VitalColors.oceanTeal,
          tabs: const [Tab(text: "Active"), Tab(text: "History")],
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final active = provider.orders
              .where((o) => o.status != 'Completed' && o.status != 'Cancelled')
              .toList();
          final history = provider.orders
              .where((o) => o.status == 'Completed' || o.status == 'Cancelled')
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(active, true),
              _buildList(history, false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<OrderModel> orders, bool isActive) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.clipboardList, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text("No records found", style: TextStyle(color: Colors.grey[600]))
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final dateStr = DateFormat('MMM d, yyyy').format(order.date);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassCard(
            enableBlur: false, // PERFORMANCE FIX
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => OrderDetailsScreen(orderId: order.id))),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? VitalColors.oceanTeal.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                      isActive ? LucideIcons.testTube2 : LucideIcons.fileCheck,
                      color: isActive ? VitalColors.oceanTeal : Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.testName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(dateStr,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(order.status,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(order.status))),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (100 * index).ms).slideX(),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Processing":
        return Colors.orange;
      case "Scheduled":
        return Colors.blue;
      case "Completed":
        return VitalColors.success;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
