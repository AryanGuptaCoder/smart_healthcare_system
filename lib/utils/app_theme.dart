import 'package:flutter/material.dart';

// Light Theme
final lightColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF4285F4),
  brightness: Brightness.light,
  primary: const Color(0xFF4285F4),
  onPrimary: Colors.white,
  secondary: const Color(0xFF34A853),
  onSecondary: Colors.white,
  tertiary: const Color(0xFFEA4335),
  onTertiary: Colors.white,
  error: const Color(0xFFEA4335),
  onError: Colors.white,
  background: Colors.white,
  onBackground: const Color(0xFF202124),
  surface: Colors.white,
  onSurface: const Color(0xFF202124),
);

// Dark Theme
final darkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF4285F4),
  brightness: Brightness.dark,
  primary: const Color(0xFF8AB4F8),
  onPrimary: const Color(0xFF0D2249),
  secondary: const Color(0xFF81C995),
  onSecondary: const Color(0xFF0F2817),
  tertiary: const Color(0xFFF28B82),
  onTertiary: const Color(0xFF3C0D09),
  error: const Color(0xFFF28B82),
  onError: const Color(0xFF3C0D09),
  background: const Color(0xFF121212),
  onBackground: const Color(0xFFE8EAED),
  surface: const Color(0xFF202124),
  onSurface: const Color(0xFFE8EAED),
);

// Text Styles
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
}

