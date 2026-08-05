import 'package:flutter/material.dart';

/// Identidade visual SimProposta v2 — "Acordo Sólido" com suporte a Tema Claro e Tema Escuro.
abstract final class SimPropostaColors {
  // Paleta Base V2
  static const Color navy = Color(0xFF071A2B);        // Autoridade / Navy Profundo
  static const Color teal = Color(0xFF066B63);        // Ação / Teal Escuro
  static const Color mint = Color(0xFF12A89A);        // Progresso / Verde Mineral
  static const Color offWhite = Color(0xFFF3F7F8);    // Branco Frio

  // Tokens Tema Claro (Light)
  static const Color textPrimary = navy;
  static const Color textSecondary = Color(0xFF294858);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = offWhite;
  static const Color border = Color(0xFFB8CDD3);
  static const Color success = teal;
  static const Color focus = mint;
  static const Color error = Color(0xFFA61B1B);
  static const Color warning = Color(0xFF9A5B00);
  static const Color supervisor = Color(0xFF6D28D9);  // Roxo Corporativo

  // Tokens Tema Escuro (Dark — Derivado do Navy #071A2B)
  static const Color darkBackground = Color(0xFF051320);     // Fundo Navy Ultra Escuro
  static const Color darkSurface = Color(0xFF0A2136);        // Cartões Navy Elevados
  static const Color darkSurfaceSubtle = Color(0xFF0D2A44);  // Fundo de Campos de Entrada
  static const Color darkBorder = Color(0xFF1A3D5D);         // Borda Azul Navy Escuro
  static const Color darkTextPrimary = Color(0xFFF3F7F8);    // Texto Branco Frio
  static const Color darkTextSecondary = Color(0xFF8AA4B7);  // Texto Azul Prateado
  static const Color darkPrimary = mint;                     // Verde Mineral em Destaque
  static const Color darkSuccess = mint;
}

abstract final class SimPropostaTheme {
  // Esquema de Cores Claro
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

  // Esquema de Cores Escuro (Oficial Acordo Sólido)
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: SimPropostaColors.darkPrimary,
    onPrimary: SimPropostaColors.darkBackground,
    secondary: SimPropostaColors.teal,
    onSecondary: Colors.white,
    error: SimPropostaColors.error,
    onError: Colors.white,
    surface: SimPropostaColors.darkSurface,
    onSurface: SimPropostaColors.darkTextPrimary,
    outline: SimPropostaColors.darkBorder,
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        scaffoldBackgroundColor: SimPropostaColors.offWhite,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: SimPropostaColors.surface,
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

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        scaffoldBackgroundColor: SimPropostaColors.darkBackground,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: SimPropostaColors.darkSurface,
          foregroundColor: SimPropostaColors.darkTextPrimary,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: SimPropostaColors.darkSurfaceSubtle,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: SimPropostaColors.darkPrimary, width: 2),
          ),
        ),
      );
}
