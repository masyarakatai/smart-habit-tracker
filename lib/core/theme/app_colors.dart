import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Status & Accents
  static const Color streakFlame = Color(0xFFF97316); // Bright Flame Orange
  static const Color streakFlameYellow = Color(0xFFFBBF24);
  static const Color streakFreeze = Color(0xFF38BDF8); // Ice Blue
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color pending = Color(0xFF64748B); // Slate
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Backgrounds - Light Theme
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Backgrounds - Dark Theme
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF161E2E);
  static const Color darkSurfaceBorder = Color(0xFF26334D);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Pre-configured Habit Color Accents
  static const List<Color> habitPalette = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF0EA5E9), // Sky Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFFF97316), // Orange
    Color(0xFF14B8A6), // Teal
    Color(0xFFEAB308), // Yellow
  ];
}
