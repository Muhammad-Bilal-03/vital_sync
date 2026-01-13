import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../widgets/vital_app_bar.dart';
import '../../../core/theme.dart';
import '../../../core/result.dart';
import '../../widgets/glass_card.dart';
import '../../../models/test_model.dart';
import '../../../models/user_model.dart';
import '../../../repositories/test_repository.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../repositories/notification_repository.dart';
import '../checkout/success_screen.dart';

class LabBookingScreen extends StatefulWidget {
  final String labName;
  final String labAddress;

  const LabBookingScreen({
    super.key,
    required this.labName,
    required this.labAddress,
  });

  @override
  State<LabBookingScreen> createState() => _LabBookingScreenState();
}

class _LabBookingScreenState extends State<LabBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  int _selectedDateIndex = 0;
  int _selectedTimeIndex = -1;
  String? _selectedTestId;
  bool _isLoading = false;

  final List<String> _timeSlots = [
    "08:00 AM",
    "09:00 AM",
    "10:00 AM",
    "11:00 AM",
    "01:00 PM",
    "02:00 PM",
    "04:00 PM",
    "06:00 PM"
  ];

  List<DateTime> get _nextDays {
    return List.generate(
        7, (index) => DateTime.now().add(Duration(days: index)));
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
      appBar: const VitalAppBar(title: "Book Lab Visit"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Lab Info (Display Only)
                    GlassCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  VitalColors.oceanTeal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(LucideIcons.building2,
                                color: VitalColors.oceanTeal),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.labName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text(widget.labAddress,
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(),

                    const SizedBox(height: 30),

                    // 2. Select Test
                    const Text("Select Test",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    FutureBuilder<List<TestModel>>(
                      future: TestRepository().getPopularTests(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return const LinearProgressIndicator();
                        final tests = snapshot.data!;
                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(LucideIcons.microscope),
                            hintText: "Choose a test...",
                          ),
                          items: tests.map((test) {
                            return DropdownMenuItem(
                              value: test.id,
                              child: Text(test.name,
                                  overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedTestId = val),
                          validator: (v) =>
                              v == null ? "Please select a test" : null,
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // 3. Select Date
                    const Text("Select Date",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _nextDays.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final date = _nextDays[index];
                          final isSelected = _selectedDateIndex == index;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedDateIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 70,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? VitalColors.oceanTeal
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: isSelected
                                        ? VitalColors.oceanTeal
                                        : Colors.grey[200]!,
                                    width: 2),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_getDayName(date.weekday),
                                      style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey[600])),
                                  Text(date.day.toString(),
                                      style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : VitalColors.midnightBlue,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 4. Time Slots
                    const Text("Available Slots",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(_timeSlots.length, (index) {
                          final isSelected = _selectedTimeIndex == index;
                          return ChoiceChip(
                            label: Text(_timeSlots[index]),
                            selected: isSelected,
                            onSelected: (val) => setState(
                                () => _selectedTimeIndex = val ? index : -1),
                            selectedColor: VitalColors.oceanTeal,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : VitalColors.midnightBlue,
                                fontWeight: FontWeight.w600),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 5. Confirm Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _handleBooking(user, orderProvider),
                        child: const Text("Confirm Lab Visit",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _handleBooking(
      UserModel? user, OrderProvider orderProvider) async {
    // 1. Validate Form
    if (!_formKey.currentState!.validate()) return;

    // 2. Validate Time Slot
    if (_selectedTimeIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a time slot")));
      return;
    }

    // 3. Validate User
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final date = _nextDays[_selectedDateIndex];
      final rawTime = _timeSlots[_selectedTimeIndex];

      // --- THE TRICK: Append Lab Name to Time Slot ---
      // This saves the location without needing new database fields
      final combinedTimeSlot = "$rawTime at ${widget.labName}";

      final result = await orderProvider.placeOrder(
        userId: user.uid,
        testIds: [_selectedTestId!],
        date: date,
        timeSlot: combinedTimeSlot, // Send the combined string
      );

      if (mounted) {
        if (result is Success) {
          NotificationRepository().createNotification(
              user.uid,
              "Lab Visit Confirmed",
              "Appointment at ${widget.labName} for $rawTime.");

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const SuccessScreen()));
        } else if (result is Failure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text((result).message), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
