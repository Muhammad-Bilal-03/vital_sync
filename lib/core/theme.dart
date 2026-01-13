import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VitalColors {
  // Neo-Medical Palette
  static const Color midnightBlue = Color(0xFF1A237E);
  static const Color oceanTeal = Color(0xFF009688);
  static const Color softTeal = Color(0xFFE0F2F1);
  static const Color electricBlue = Color(0xFF2979FF);

  // Functional Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [midnightBlue, Color(0xFF3949AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x99FFFFFF), Color(0x66FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class VitalTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: VitalColors.background,

      // Typography: "Outfit" for a modern, digital feel
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: VitalColors.midnightBlue,
        displayColor: VitalColors.midnightBlue,
      ),

      // Input Decoration (Clean, pill-shaped)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
              color: VitalColors.midnightBlue.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: VitalColors.oceanTeal, width: 2),
        ),
      ),

      // Button Styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VitalColors.midnightBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 4,
          shadowColor: VitalColors.midnightBlue.withValues(alpha: 0.4),
        ),
      ),

      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: VitalColors.midnightBlue,
        primary: VitalColors.midnightBlue,
        secondary: VitalColors.oceanTeal,
      ),
    );
  }
}
