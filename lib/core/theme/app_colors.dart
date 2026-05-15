import 'package:flutter/material.dart';

/// SIANKES Color System - Modern Healthcare Theme
/// Inspired by Mobile JKN BPJS Kesehatan
class AppColors {
  AppColors._();

  // ─── Primary Colors ───
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primarySurface = Color(0xFFE3F2FD);

  // ─── Secondary / Accent ───
  static const Color secondary = Color(0xFF00BCD4);
  static const Color secondaryLight = Color(0xFF4DD0E1);
  static const Color secondaryDark = Color(0xFF00838F);

  // ─── Semantic Colors ───
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF0288D1);
  static const Color infoLight = Color(0xFFE1F5FE);

  // ─── Queue Status Colors ───
  static const Color statusWaiting = Color(0xFFFFA726);
  static const Color statusCalled = Color(0xFF66BB6A);
  static const Color statusDone = Color(0xFF78909C);
  static const Color statusSkipped = Color(0xFFEF5350);

  // ─── Neutral Colors ───
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F8);
  static const Color border = Color(0xFFE0E6ED);
  static const Color divider = Color(0xFFEEF2F6);

  // ─── Text Colors ───
  static const Color textPrimary = Color(0xFF1A2138);
  static const Color textSecondary = Color(0xFF6B7B8D);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ─── Shadow ───
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);

  // ─── Premium Gradients ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF0288D1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF57F17), Color(0xFFFFB300)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient onboardingGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Poli Colors ───
  static const List<Color> poliColors = [
    Color(0xFF1565C0), // Umum
    Color(0xFF00897B), // Gigi
    Color(0xFFE91E63), // Anak
    Color(0xFF7B1FA2), // Kandungan
    Color(0xFF00838F), // Mata
    Color(0xFFFF6F00), // THT
  ];
}
