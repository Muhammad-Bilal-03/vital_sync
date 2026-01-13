import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../screens/booking/booking_screen.dart'; // Imported BookingScreen

class SpeedDialFab extends StatefulWidget {
  const SpeedDialFab({super.key});

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isOpen) ...[
          _buildFabOption(
            icon: LucideIcons.phone,
            label: "Support",
            color: Colors.blue,
            delay: 200,
            onTap: () {
              // TODO: Launch dialer
            },
          ),
          const SizedBox(height: 12),
          _buildFabOption(
            icon: LucideIcons.uploadCloud,
            label: "Upload Rx",
            color: Colors.orange,
            delay: 100,
            onTap: () {
              // TODO: Open file picker
            },
          ),
          const SizedBox(height: 12),
          _buildFabOption(
            icon: LucideIcons.testTube2,
            label: "Book Test",
            color: VitalColors.oceanTeal,
            delay: 0,
            onTap: () {
              // FIX: Navigate to BookingScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _isOpen = !_isOpen;
            });
          },
          backgroundColor: _isOpen ? Colors.red : VitalColors.midnightBlue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Icon(
            _isOpen ? LucideIcons.x : LucideIcons.plus,
            color: Colors.white,
            size: 28,
          ).animate(target: _isOpen ? 1 : 0).rotate(begin: 0, end: 0.25),
        ),
      ],
    );
  }

  Widget _buildFabOption({
    required IconData icon,
    required String label,
    required Color color,
    required int delay,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
              )
            ],
          ),
          child:
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          onPressed: onTap,
          backgroundColor: color,
          heroTag: label, // Unique tag to prevent hero errors
          child: Icon(icon, color: Colors.white),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: delay.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack);
  }
}
