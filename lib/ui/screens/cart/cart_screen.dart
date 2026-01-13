import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme.dart';
import '../../../providers/cart_provider.dart';
import '../../widgets/vital_app_bar.dart';
import '../../widgets/glass_card.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final items = cart.items;

    return Scaffold(
      appBar: const VitalAppBar(title: "My Cart"),
      body: items.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final test = items[index];
                      return Dismissible(
                        key: Key(test.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: VitalColors.error,
                          child: const Icon(LucideIcons.trash2,
                              color: Colors.white),
                        ),
                        onDismissed: (_) {
                          cart.removeTest(test.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GlassCard(
                            enableBlur: false, // PERFORMANCE FIX
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: VitalColors.oceanTeal
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(LucideIcons.testTube2,
                                      color: VitalColors.oceanTeal),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        test.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "TAT: ${test.tatHours} Hours",
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "PKR ${test.price.toInt()}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: VitalColors.midnightBlue),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (50 * index).ms).slideX();
                    },
                  ),
                ),
                _buildBillSummary(context, cart),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.shoppingCart,
                  size: 80, color: Colors.grey.withValues(alpha: 0.3))
              .animate()
              .scale(duration: 500.ms),
          const SizedBox(height: 20),
          Text(
            "Your Cart is Empty",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Browse Tests"),
          ),
        ],
      ),
    );
  }

  Widget _buildBillSummary(BuildContext context, CartProvider cart) {
    final double total = cart.totalAmount;
    final double discount = total * 0.10; // Mock 10% discount
    final double finalAmount = total - discount;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -5),
            blurRadius: 20,
          )
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _summaryRow("Subtotal", total),
          const SizedBox(height: 8),
          _summaryRow("Discount (10%)", -discount, isDiscount: true),
          const Divider(height: 24),
          _summaryRow("Total Payable", finalAmount, isBold: true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                );
              },
              child: const Text(
                "Proceed to Checkout",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 400.ms);
  }

  Widget _summaryRow(String label, double amount,
      {bool isBold = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[800],
          ),
        ),
        Text(
          "${isDiscount ? '-' : ''}PKR ${amount.abs().toInt()}",
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? VitalColors.success : VitalColors.midnightBlue,
          ),
        ),
      ],
    );
  }
}
