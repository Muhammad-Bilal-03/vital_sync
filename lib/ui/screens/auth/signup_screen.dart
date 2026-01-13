import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme.dart';
import '../../../core/strings.dart';
import '../../../providers/user_provider.dart';
import '../home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  String _gender = 'Male';
  String _bloodType = 'O+';
  DateTime _dob = DateTime(2000, 1, 1);
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft,
              color: VitalColors.midnightBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppStrings.signupTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: VitalColors.midnightBlue)),
                const SizedBox(height: 30),

                // Name Fields
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(_firstNameCtrl, "First Name")),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField(_lastNameCtrl, "Last Name")),
                  ],
                ),
                const SizedBox(height: 16),

                // Email & Mobile
                _buildTextField(_emailCtrl, AppStrings.emailHint,
                    icon: LucideIcons.mail, type: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField(_mobileCtrl, "Mobile",
                    icon: LucideIcons.smartphone, type: TextInputType.phone),
                const SizedBox(height: 16),

                // Gender & Blood
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _gender,
                        decoration: const InputDecoration(labelText: "Gender"),
                        items: ['Male', 'Female', 'Other']
                            .map((g) =>
                                DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (v) => setState(() => _gender = v!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _bloodType,
                        decoration:
                            const InputDecoration(labelText: "Blood Type"),
                        items: [
                          'A+',
                          'A-',
                          'B+',
                          'B-',
                          'O+',
                          'O-',
                          'AB+',
                          'AB-'
                        ]
                            .map((b) =>
                                DropdownMenuItem(value: b, child: Text(b)))
                            .toList(),
                        onChanged: (v) => setState(() => _bloodType = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Weight & Height
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(_weightCtrl, "Weight (kg)",
                            icon: LucideIcons.scale,
                            type: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField(_heightCtrl, "Height (cm)",
                            icon: LucideIcons.ruler,
                            type: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 16),

                // Date of Birth
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dob,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => _dob = date);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        labelText: "Birth Date",
                        prefixIcon: Icon(LucideIcons.calendar)),
                    child: Text("${_dob.day}/${_dob.month}/${_dob.year}"),
                  ),
                ),
                const SizedBox(height: 16),

                // Passwords
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    labelText: AppStrings.passwordHint,
                    prefixIcon: const Icon(LucideIcons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isObscure ? LucideIcons.eye : LucideIcons.eyeOff),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                  validator: (v) =>
                      (v != null && v.length < 6) ? AppStrings.weakPass : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPassCtrl,
                  obscureText: _isObscure,
                  decoration: const InputDecoration(
                    labelText: AppStrings.confirmPasswordHint,
                    prefixIcon: Icon(LucideIcons.lock),
                  ),
                  validator: (v) =>
                      v != _passCtrl.text ? AppStrings.passMismatch : null,
                ),
                const SizedBox(height: 30),

                // Submit
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: userProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final success = await userProvider.register(
                                firstName: _firstNameCtrl.text,
                                lastName: _lastNameCtrl.text,
                                email: _emailCtrl.text.trim(),
                                mobile: _mobileCtrl.text,
                                gender: _gender,
                                dob: _dob,
                                password: _passCtrl.text,
                                bloodType: _bloodType,
                                weight: _weightCtrl.text,
                                height: _heightCtrl.text,
                              );
                              if (success && mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const HomeScreen()),
                                  (route) => false,
                                );
                              }
                            }
                          },
                    child: userProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Create Account"),
                  ),
                ),
                if (userProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(userProvider.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label,
      {IconData? icon, TextInputType? type}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
          labelText: label, prefixIcon: icon != null ? Icon(icon) : null),
      validator: (v) => v!.isEmpty ? AppStrings.requiredField : null,
    );
  }
}
