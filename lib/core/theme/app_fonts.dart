import 'package:flutter/material.dart';

abstract class AppFonts {
  static const String family = 'Cairo';

  static const display = TextStyle(
    fontFamily: family,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const title = TextStyle(
    fontFamily: family,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const heading = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );

  static const subheading = TextStyle(
    fontFamily: family,
    fontSize: 14.5,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );

  static const body = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const small = TextStyle(
    fontFamily: family,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const caption = TextStyle(
    fontFamily: family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );
}
