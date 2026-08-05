import 'package:flutter/material.dart';

/// Identidade visual SimProposta v2 — contraste reforçado.
abstract final class SimPropostaColors {
  static const Color navy = Color(0xFF071A2B);
  static const Color teal = Color(0xFF066B63);
  static const Color mint = Color(0xFF12A89A);
  static const Color offWhite = Color(0xFFF3F7F8);

  static const Color textPrimary = navy;
  static const Color textSecondary = Color(0xFF294858);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = offWhite;
  static const Color border = Color(0xFFB8CDD3);
  static const Color success = teal;
  static const Color focus = mint;
  static const Color error = Color(0xFFA61B1B);
  static const Color warning = Color(0xFF9A5B00);
}

abstract final class SimPropostaTheme {
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: SimPropostaColors.teal,
    onPrimary: Colors.white,
    secondary: SimPropostaColors.mint,
    onSecondary: SimPropostaColors.navy,
    error: SimPropostaColors.error,
    onError: Colors.white,
    surface: SimPropostaColors.surface,
    onSurface: SimPropostaColors.textPrimary,
    outline: SimPropostaColors.border,
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        scaffoldBackgroundColor: SimPropostaColors.offWhite,
        fontFamily: 'Manrope',
        appBarTheme: const AppBarTheme(
          backgroundColor: SimPropostaColors.offWhite,
          foregroundColor: SimPropostaColors.navy,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: SimPropostaColors.surface,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: SimPropostaColors.teal, width: 2),
          ),
        ),
      );
}
