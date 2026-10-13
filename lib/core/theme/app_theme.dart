import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const sage = Color(0xFFBDCFB3);
  static ThemeData create(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
        seedColor: sage,
        brightness: brightness,
        surface: dark ? const Color(0xFF171B18) : const Color(0xFFF9F8F3),
        primary: dark ? sage : const Color(0xFF425B3B));
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Manrope',
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          dark ? const Color(0xFF101411) : const Color(0xFFF9F8F3),
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
          fontFamily: 'Manrope',
          bodyColor: dark ? const Color(0xFFECEBE1) : const Color(0xFF20291F),
          displayColor:
              dark ? const Color(0xFFECEBE1) : const Color(0xFF20291F)),
      appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false),
      cardTheme: CardTheme(
          elevation: 0,
          color: dark ? const Color(0xFF1C221D) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: dark ? const Color(0xFF222923) : const Color(0xFFEDEFE8),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.all(18)),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
              minimumSize: const Size(48, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)))),
      navigationBarTheme: NavigationBarThemeData(
          backgroundColor: scheme.surface,
          indicatorColor: scheme.primary.withOpacity(.18),
          height: 76),
      chipTheme: ChipThemeData(
          side: BorderSide(color: scheme.outlineVariant.withOpacity(.35)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
    );
  }
}
