import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/result.dart'; // Import Result
import '../../../core/theme.dart';
import '../../../models/test_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../repositories/notification_repository.dart';
import '../../../repositories/test_repository.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/vital_app_bar.dart';
import '../checkout/success_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>(); // Added Form Key
  final _addressCtrl = TextEditingController();

  int _selectedDateIndex = 0;
  int _selectedTimeIndex = -1;
  String? _selectedTestId; // For Test Selection
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
      appBar: const VitalAppBar(title: "Book Appointment"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey, // Wrap in Form
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Select Test (New Feature)
                    const Text(
                      "Select Test",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<TestModel>>(
                      future: TestRepository().getPopularTests(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const LinearProgressIndicator();
                        }
                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(LucideIcons.microscope),
                            hintText: "Choose a test...",
                          ),
                          items: snapshot.data!.map((test) {
                            return DropdownMenuItem(
                              value: test.id,
                              child: Text(test.name,
                                  overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedTestId = val);
                          },
                          validator: (v) =>
                              v == null ? "Please select a test" : null,
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // 2. Select Date Section
                    const Text(
                      "Select Date",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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
                                  Text(
                                    _getDayName(date.weekday),
                                    style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    date.day.toString(),
                                    style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : VitalColors.midnightBlue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 3. Select Time Section
                    const Text(
                      "Available Slots",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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

                    const SizedBox(height: 30),

                    // 4. Address Section
                    const Text(
                      "Location",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(
                        hintText: "Enter complete home address",
                        prefixIcon: Icon(LucideIcons.mapPin),
                      ),
                      maxLines: 2,
                      // Validation Added
                      validator: (v) => (v == null || v.isEmpty)
                          ? "Address is required"
                          : null,
                    ),

                    const SizedBox(height: 40),

                    // 5. Confirm Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _handleBooking(user, orderProvider),
                        child: const Text(
                          "Confirm Appointment",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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
    // Validation Logic
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTimeIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please select a time slot"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final date = _nextDays[_selectedDateIndex];
      final timeSlot = _timeSlots[_selectedTimeIndex];

      // Call Provider to save order
      final result = await orderProvider.placeOrder(
        userId: user.uid,
        testIds: [_selectedTestId!],
        date: date,
        timeSlot: timeSlot,
      );

      if (mounted) {
        if (result is Success) {
          // Send notification
          NotificationRepository().createNotification(user.uid,
              "Booking Confirmed", "Home collection scheduled for $timeSlot.");

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const SuccessScreen()));
        } else if (result is Failure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text((result).message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2)));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error: $e"), duration: const Duration(seconds: 2)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
