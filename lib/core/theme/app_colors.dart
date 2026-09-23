import 'package:flutter/material.dart';

/// Bridgo Color Palette derived from brand identity:
/// Primary Navy: #1C538E
/// Secondary Cyan/Teal: #1E818E
/// Accent Green: #3CB065
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1C538E);
  static const Color primaryDark = Color(0xFF133B66);
  static const Color primaryLight = Color(0xFF386FA4);

  static const Color secondary = Color(0xFF1E818E);
  static const Color secondaryLight = Color(0xFF379EA8);

  static const Color accent = Color(0xFF3CB065);
  static const Color accentLight = Color(0xFF5BC47F);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
}
