import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Green Orchard palette — leaf green + citrus orange on a soft green-white.
class AppColors {
  static const leaf = Color(0xFF2F6B3A);
  static const leafDark = Color(0xFF1F4A28);
  static const leafTint = Color(0xFFE4EFD9);
  static const citrus = Color(0xFFE8892B);
  static const citrusTint = Color(0xFFFCE6CF);
  static const citrusDark = Color(0xFF7A3E06);
  static const ground = Color(0xFFF6F8F1);
  static const ink = Color(0xFF1E2B1F);
  static const muted = Color(0xFF5A6B5C);
  static const line = Color(0xFFDDE5D3);
  static const danger = Color(0xFFA33D19);
  static const sky = Color(0xFFDDEBF7);
  static const skyDark = Color(0xFF1E4A75);
}

class AppTheme {
  static ThemeData get light {
    final body = GoogleFonts.manropeTextTheme();
    final display = GoogleFonts.bricolageGrotesqueTextTheme();

    final text = body
        .copyWith(
          headlineLarge: display.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
          headlineMedium: display.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          headlineSmall: display.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        )
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

    OutlineInputBorder border(Color c, [double w = 1.5]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.ground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.leaf,
        primary: AppColors.leaf,
        secondary: AppColors.citrus,
        surface: Colors.white,
        error: AppColors.danger,
      ),
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ground,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.headlineSmall,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border(AppColors.line),
        enabledBorder: border(AppColors.line),
        focusedBorder: border(AppColors.leaf, 2),
        errorBorder: border(AppColors.danger),
        focusedErrorBorder: border(AppColors.danger, 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.leaf,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.leafTint,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
