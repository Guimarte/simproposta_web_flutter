import 'package:flutter/material.dart';

/// Identidade visual SimProposta — tokens oficiais de cor.
abstract final class SimPropostaColors {
  static const Color navy = Color(0xFF0B1F33);
  static const Color teal = Color(0xFF0F766E);
  static const Color mint = Color(0xFF2DD4BF);
  static const Color offWhite = Color(0xFFF7FAFC);

  static const Color textPrimary = navy;
  static const Color textSecondary = Color(0xFF456071);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = offWhite;
  static const Color border = Color(0xFFD7E3E8);
  static const Color success = teal;
  static const Color focus = mint;
  static const Color error = Color(0xFFB42318);
  static const Color warning = Color(0xFFF59E0B);
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
