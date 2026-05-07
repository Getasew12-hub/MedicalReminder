import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const rose = Color(0xFFE91E63);
  static const roseDark = Color(0xFFB8326A);
  static const roseLight = Color(0xFFFFEEF5);
  static const ink = Color(0xFF2E2B33);
  static const muted = Color(0xFF98939E);
  static const field = Color(0xFFF8F7F9);
  static const line = Color(0xFFEDE8EF);
  static const success = Color(0xFF4CAF7A);
  static const warning = Color(0xFFE3A23B);

  static const primaryGradient = LinearGradient(
    colors: [Color(0xFFE84A7A), Color(0xFFB8326A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
