import 'package:flutter/material.dart';

class AppFonts {
  /// ضع اسم الخط هنا بعد إضافته في pubspec (مثلاً 'Cairo')
  static const String? family = null;

  static const title =
      TextStyle(fontFamily: family, fontSize: 22, fontWeight: FontWeight.w800);
  static const heading =
      TextStyle(fontFamily: family, fontSize: 16.5, fontWeight: FontWeight.w700);
  static const body = TextStyle(fontFamily: family, fontSize: 14);
  static const small = TextStyle(fontFamily: family, fontSize: 12);
}
