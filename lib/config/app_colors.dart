import 'package:flutter/material.dart';

/// Màu sắc của ứng dụng - Material Design 3 inspired
class AppColors {
  // ============ PRIMARY COLORS ============
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  
  static const Color secondary = Color(0xFF26C6DA);
  static const Color secondaryDark = Color(0xFF00ACC1);
  static const Color secondaryLight = Color(0xFF4DD0E1);

  // ============ GRADIENT ============
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryLight],
  );

  // ============ ACCENT COLORS ============
  static const Color accent = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4ECDC4);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  // ============ NEUTRAL COLORS ============
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFEFEFE);
  static const Color divider = Color(0xFFE0E0E0);

  // ============ TEXT COLORS ============
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFF9E9E9E);

  // ============ DARK MODE ============
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // ============ OVERLAY ============
  static const Color overlay = Color(0x80000000);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ============ STATUS COLORS ============
  static const Color pending = Color(0xFFFFA726);
  static const Color confirmed = Color(0xFF66BB6A);
  static const Color cancelled = Color(0xFFEF5350);
  static const Color completed = Color(0xFF26C6DA);
}