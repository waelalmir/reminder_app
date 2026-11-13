import 'package:flutter/material.dart';

abstract class AppColors {
  static const seed = Color(0xFF4F46E5); // Indigo 600
  static const accent = Color(0xFF7C3AED); // Violet 600
  static const secondary = Color(0xFF0EA5E9); // Sky 500

  static const success = Color(0xFF10B981); // Emerald 500
  static const warning = Color(0xFFF59E0B); // Amber 500
  static const danger = Color(0xFFEF4444); // Red 500

  static const headerGradient = [
    Color(0xFF4338CA),
    Color(0xFF6D28D9),
    Color(0xFF7C3AED),
  ];

  static const lightBg = [
    Color(0xFFF4F6FF),
    Color(0xFFF8F9FE),
    Color(0xFFEEF2FF),
  ];

  static const darkBg = [
    Color(0xFF090D16),
    Color(0xFF0F172A),
    Color(0xFF131B2E),
  ];

  static const priorityColors = [
    Color(0xFF10B981), // 0: عادية
    Color(0xFFF59E0B), // 1: متوسطة
    Color(0xFFEF4444), // 2: قصوى
  ];
}
