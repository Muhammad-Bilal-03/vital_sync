import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../providers/user_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../widgets/glass_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _pickImage(UserProvider provider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (image != null) {
      provider.updateProfileImage(image.path);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Profile image updated"),
        duration: Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    String displayValue(String? val, String suffix) {
      if (val == null || val.isEmpty) return "--";
      return "$val $suffix";
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header with Gradient
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                gradient: VitalColors.primaryGradient,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _pickImage(userProvider),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              backgroundImage: user?.profileImagePath != null
                                  ? FileImage(File(user!.profileImagePath!))
                                      as ImageProvider
                                  : null,
                              child: user?.profileImagePath == null
                                  ? Text(user?.firstName[0] ?? "G",
                                      style: const TextStyle(
                                          fontSize: 28,
                                          color: VitalColors.midnightBlue,
                                          fontWeight: FontWeight.bold))
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                    color: VitalColors.oceanTeal,
                                    shape: BoxShape.circle),
                                child: const Icon(LucideIcons.camera,
                                    size: 14, color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.fullName ?? "Guest User",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          Text(user?.mobile ?? "",
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- NEW: WALLET CARD ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(LucideIcons.wallet,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                Text("Your Balance",
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text("PKR 0.00",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text("Top Up",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: VitalColors.midnightBlue,
                                  fontSize: 12)),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bio Stats Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBioStat("Blood Type", user?.bloodType ?? "Not Set"),
                      _buildBioStat("Age", "${user?.age} Yrs"),
                      _buildBioStat("Gender", user?.gender ?? "--"),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Vitals Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildVitalItem(LucideIcons.ruler, "Height",
                        displayValue(user?.height, "cm")),
                    Container(height: 40, width: 1, color: Colors.grey[300]),
                    _buildVitalItem(LucideIcons.scale, "Weight",
                        displayValue(user?.weight, "kg")),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Settings List
            _buildSettingTile(
                context, "My Prescriptions", LucideIcons.fileText),
            _buildSettingTile(context, "Family Members", LucideIcons.users),
            _buildSettingTile(context, "Address Book", LucideIcons.mapPin),
            const Divider(height: 40),
            _buildSettingTile(
                context, "Help & Support", LucideIcons.helpCircle),

            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () {
                  userProvider.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.logOut, size: 20),
                    SizedBox(width: 8),
                    Text("Log Out")
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
      ],
    );
  }

  Widget _buildVitalItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: VitalColors.oceanTeal, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildSettingTile(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: VitalColors.oceanTeal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: VitalColors.oceanTeal, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing:
          const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
    );
  }
}
