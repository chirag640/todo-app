import 'package:flutter/material.dart';

/// App-wide color palette based on the design
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF007AFF); // Primary Blue
  static const Color primaryLight = Color(0xFF4DA3FF);
  static const Color primaryDark = Color(0xFF0051D5);

  // Background Colors
  static const Color background = Color(0xFFF5F5F7); // Light Gray Background
  static const Color cardBackground = Color(0xFFFFFFFF); // White Card
  static const Color surface = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1C1C1E); // Dark Text
  static const Color textSecondary = Color(0xFF8E8E93); // Gray Text
  static const Color textTertiary = Color(0xFFC7C7CC); // Light Gray Text

  // Priority/Status Colors
  static const Color priorityHigh = Color(0xFFFF3B30); // Red
  static const Color priorityMedium = Color(0xFFFFCC00); // Yellow
  static const Color priorityLow = Color(0xFF007AFF); // Blue
  static const Color completed = Color(0xFF34C759); // Green

  // UI Element Colors
  static const Color divider = Color(0xFFE5E5EA);
  static const Color border = Color(0xFFE5E5EA);
  static const Color shadow = Color(0x1A000000);

  // Icon Colors
  static const Color iconPrimary = Color(0xFF1C1C1E);
  static const Color iconSecondary = Color(0xFF8E8E93);

  // Button Colors
  static const Color buttonPrimary = Color(0xFF007AFF);
  static const Color buttonSecondary = Color(0xFFE5E5EA);
  static const Color buttonDisabled = Color(0xFFE5E5EA);

  // Status Colors
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFFCC00);
  static const Color info = Color(0xFF007AFF);

  // Additional Colors
  static const Color overlay = Color(0x4D000000);
  static const Color transparent = Colors.transparent;

  // Legacy support
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
