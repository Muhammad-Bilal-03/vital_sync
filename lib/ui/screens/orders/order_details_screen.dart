import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:another_stepper/another_stepper.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../../../providers/order_provider.dart';
import '../../../models/order_model.dart';
import '../../widgets/glass_card.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // 1. Fetch the REAL order from the Provider using the ID
    final order = Provider.of<OrderProvider>(context)
        .orders
        .firstWhere((o) => o.id == orderId, orElse: () => _emptyOrder());

    if (order.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Order Details")),
        body: const Center(child: Text("Order not found")),
      );
    }

    final stepperData = _generateStepperData(order);

    return Scaffold(
      appBar: AppBar(
        title: Text("Order #${orderId.substring(0, 5).toUpperCase()}"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 2. Real Order Summary
            GlassCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: VitalColors.oceanTeal.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.testTube2,
                            color: VitalColors.oceanTeal),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.testName,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              "Date: ${DateFormat('MMM d, yyyy').format(order.date)}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const Divider(height: 30),

                  // --- NEW: Time / Location Row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Time / Location",
                          style: TextStyle(color: Colors.grey)),
                      Expanded(
                        child: Text(
                          order
                              .timeSlot, // Shows "09:00 AM" or "09:00 AM at Lab Name"
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Amount"),
                      Text("PKR ${order.totalAmount.toInt()}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("Status: ${order.status}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),

            // 3. Dynamic Stepper
            AnotherStepper(
              stepperList: stepperData,
              stepperDirection: Axis.vertical,
              iconWidth: 40,
              iconHeight: 40,
              activeBarColor: order.status == 'Cancelled'
                  ? Colors.red
                  : VitalColors.oceanTeal,
              inActiveBarColor: Colors.grey[300]!,
              verticalGap: 30,
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Logic to map Database Status -> UI Steps
  List<StepperData> _generateStepperData(OrderModel order) {
    bool isScheduled =
        ['Scheduled', 'Processing', 'Completed'].contains(order.status);
    bool isCollected = ['Processing', 'Completed'].contains(order.status);
    bool isProcessing = ['Processing', 'Completed'].contains(order.status);
    bool isCompleted = order.status == 'Completed';
    bool isCancelled = order.status == 'Cancelled';

    Color activeColor = isCancelled ? Colors.red : VitalColors.oceanTeal;

    return [
      StepperData(
        title: StepperText("Order Placed",
            textStyle: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: StepperText("Your appointment is confirmed."),
        iconWidget: _buildStepIcon(
            active: isScheduled || isCancelled,
            icon: LucideIcons.calendarCheck,
            color: activeColor),
      ),
      StepperData(
        title: StepperText("Sample Collected",
            textStyle: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: StepperText("Phlebotomist has collected the sample."),
        iconWidget: _buildStepIcon(
            active: isCollected, icon: LucideIcons.syringe, color: activeColor),
      ),
      StepperData(
        title: StepperText("Lab Processing",
            textStyle: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: StepperText("Sample is being analyzed."),
        iconWidget: _buildStepIcon(
            active: isProcessing,
            icon: LucideIcons.microscope,
            color: activeColor),
      ),
      StepperData(
        title: StepperText("Report Ready",
            textStyle: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: StepperText("Report generated and sent."),
        iconWidget: _buildStepIcon(
            active: isCompleted,
            icon: LucideIcons.fileCheck,
            color: activeColor),
      ),
    ];
  }

  Widget _buildStepIcon(
      {required bool active, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: active ? color : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  OrderModel _emptyOrder() {
    return OrderModel(
      id: '',
      userId: '',
      testName: '',
      date: DateTime.now(),
      status: '',
      totalAmount: 0,
      timeSlot: '', // Updated to match new model
    );
  }
}
