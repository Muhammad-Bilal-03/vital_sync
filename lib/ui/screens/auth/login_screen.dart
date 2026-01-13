import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme.dart';
import '../../../core/strings.dart'; // Ensure AppStrings is imported
import '../../../providers/user_provider.dart';
import '../home/home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // CHANGED: Renamed from _mobileCtrl to _emailCtrl for clarity
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Blob
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VitalColors.oceanTeal.withValues(alpha: 0.2),
              ),
            ).animate().scale(duration: 2.seconds, curve: Curves.easeInOut),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo / Header
                      const Icon(LucideIcons.activity,
                              size: 60, color: VitalColors.oceanTeal)
                          .animate()
                          .fadeIn()
                          .moveY(begin: -20, end: 0),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.loginTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: VitalColors.midnightBlue,
                            ),
                      ).animate().fadeIn(delay: 200.ms),
                      Text(
                        AppStrings.loginSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 40),

                      // Input Fields

                      // CHANGED: Now asks for Email Address instead of Mobile
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: "Email Address",
                          prefixIcon: Icon(LucideIcons.mail),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Required";
                          if (!v.contains('@')) return "Invalid Email";
                          return null;
                        },
                      )
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .moveX(begin: -20, end: 0),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: const Icon(LucideIcons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure ? LucideIcons.eye : LucideIcons.eyeOff,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      )
                          .animate()
                          .fadeIn(delay: 500.ms)
                          .moveX(begin: 20, end: 0),

                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text("Forgot Password?"),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Error Message
                      if (userProvider.error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: VitalColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            userProvider.error!,
                            style: const TextStyle(color: VitalColors.error),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Login Button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: userProvider.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    bool success = await userProvider.login(
                                      _emailCtrl.text.trim(), // Trim whitespace
                                      _passCtrl.text,
                                    );
                                    if (success && mounted) {
                                      // Navigation is now handled by RootWrapper stream,
                                      // but we can push replacement just in case or do nothing
                                      // and let the stream handle it.
                                      // For safety/UX, explicit push is fine:
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const HomeScreen()));
                                    }
                                  }
                                },
                          child: userProvider.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text("Sign In",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ).animate().fadeIn(delay: 600.ms).scale(),

                      const SizedBox(height: 20),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => const SignupScreen()));
                            },
                            child: const Text("Sign Up"),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
