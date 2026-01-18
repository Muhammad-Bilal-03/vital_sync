// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/result.dart'; // Import Result type
import '../../../core/theme.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../repositories/notification_repository.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/vital_app_bar.dart';
import 'success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Note: ideally inject this too, but for UI local state it's acceptable
  final NotificationRepository _notifRepo = NotificationRepository();

  int _selectedDateIndex = 0;
  String _selectedTimeSlot = "Morning (08:00 - 12:00)";
  String _paymentMethod = "Cash";
  bool _isLoading = false;

  final List<String> _timeSlots = [
    "Morning (08:00 - 12:00)",
    "Afternoon (12:00 - 04:00)",
    "Evening (04:00 - 08:00)"
  ];

  List<DateTime> get _nextDays =>
      List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final cart = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
      appBar: const VitalAppBar(title: "Checkout"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Info
                  Text("Patient",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GlassCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                          backgroundColor: VitalColors.softTeal,
                          child: Icon(LucideIcons.user,
                              color: VitalColors.oceanTeal)),
                      title: Text(user?.fullName ?? "Guest"),
                      subtitle: Text(user?.mobile ?? ""),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Schedule Summary
                  Text("Schedule",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GlassCard(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _nextDays.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final date = _nextDays[index];
                              final isSelected = _selectedDateIndex == index;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedDateIndex = index),
                                child: Container(
                                  width: 60,
                                  decoration: BoxDecoration(
                                      color: isSelected
                                          ? VitalColors.oceanTeal
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: isSelected
                                          ? null
                                          : Border.all(
                                              color: Colors.grey[300]!)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(_getDayName(date.weekday),
                                          style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.grey,
                                              fontSize: 12)),
                                      Text(date.day.toString(),
                                          style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : VitalColors.midnightBlue,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18))
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(),
                        DropdownButtonFormField<String>(
                          value: _selectedTimeSlot,
                          decoration: const InputDecoration(
                              prefixIcon: Icon(LucideIcons.clock),
                              border: InputBorder.none),
                          items: _timeSlots
                              .map((t) =>
                                  DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedTimeSlot = v!),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment
                  Text("Payment Method",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GlassCard(
                    child: Column(children: [
                      RadioListTile(
                          title: const Text("Cash on Collection"),
                          secondary: const Icon(LucideIcons.banknote,
                              color: VitalColors.oceanTeal),
                          value: "Cash",
                          groupValue: _paymentMethod,
                          activeColor: VitalColors.oceanTeal,
                          onChanged: (v) =>
                              setState(() => _paymentMethod = v.toString())),
                    ]),
                  ),
                  const SizedBox(height: 40),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (user == null) return;
                        setState(() => _isLoading = true);

                        final date = _nextDays[_selectedDateIndex];
                        final formattedDate = DateFormat('MMM d').format(date);

                        // 1. Convert Cart Items to ID List for Security
                        final testIds = cart.items.map((e) => e.id).toList();

                        // 2. Place Order via Provider (Returns Result<void>)
                        final result = await orderProvider.placeOrder(
                          userId: user.uid,
                          testIds: testIds,
                          date: date,
                          timeSlot: _selectedTimeSlot,
                        );

                        // 3. Handle Result
                        if (mounted) {
                          if (result is Success) {
                            // Add Notification
                            await _notifRepo.createNotification(
                                user.uid,
                                "Order Confirmed",
                                "Phlebotomist scheduled for $formattedDate during $_selectedTimeSlot.");

                            cart.clearCart();

                            if (mounted) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SuccessScreen()));
                            }
                          } else if (result is Failure) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text((result).message),
                                backgroundColor: VitalColors.error,
                                duration: const Duration(seconds: 3)));
                          }
                          setState(() => _isLoading = false);
                        }
                      },
                      child: const Text("Place Order",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
