import 'package:flutter/material.dart';

const green = Color(0xFF176B5B);
const primaryButton = ButtonStyle(
  minimumSize: WidgetStatePropertyAll(Size.fromHeight(56)),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
  ),
  textStyle: WidgetStatePropertyAll(
    TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  ),
);

ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final colors = ColorScheme.fromSeed(seedColor: green, brightness: brightness);
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color(0xFF101A17)
        : const Color(0xFFF7F8F4),
    colorScheme: colors,
    fontFamily: 'Cairo',
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.dark
          ? const Color(0xFF1A2823)
          : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
    ),
  );
}
