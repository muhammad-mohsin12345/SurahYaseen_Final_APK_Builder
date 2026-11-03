import 'package:flutter/material.dart';

class AppColors {
  static const emerald = Color(0xFF0B6B4F);
  static const emeraldDark = Color(0xFF064E3B);
  static const emeraldLight = Color(0xFF3FBF94);
  static const gold = Color(0xFFC9A227);
  static const cream = Color(0xFFFAF5E6);
  static const charcoal = Color(0xFF181B1A);
  static const charcoalLight = Color(0xFF242928);
}

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.emerald,
      brightness: b,
    ).copyWith(
      primary: dark ? AppColors.emeraldLight : AppColors.emerald,
      secondary: AppColors.gold,
      surface: dark ? AppColors.charcoal : AppColors.cream,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? AppColors.charcoal : AppColors.cream,
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? AppColors.charcoal : AppColors.cream,
        foregroundColor: dark ? Colors.white : AppColors.emeraldDark,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
