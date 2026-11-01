import 'package:flutter/material.dart';

/// Paleta oficial do ApoiaPet (seção 10 do levantamento de requisitos).
class AppColors {
  static const laranja = Color(0xFFE87532); // ações principais
  static const amarelo = Color(0xFFF4C95D); // destaques
  static const creme = Color(0xFFFFF4DF); // fundo
  static const cinza = Color(0xFF454545); // textos e ícones

  /// Tom auxiliar permitido apenas para estados de erro.
  static const erro = Color(0xFFB3261E);
}

class AppTheme {
  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.laranja,
      onPrimary: AppColors.cinza, // contraste 3,2:1 (texto grande/negrito)
      secondary: AppColors.amarelo,
      onSecondary: AppColors.cinza,
      error: AppColors.erro,
      onError: AppColors.creme,
      surface: AppColors.creme,
      onSurface: AppColors.cinza,
    );

    final borda = BorderSide(color: AppColors.cinza.withAlpha(60), width: 1.5);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.creme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.creme,
        foregroundColor: AppColors.cinza,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.cinza,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, fontSize: 28),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        bodyLarge: TextStyle(fontSize: 16, height: 1.4),
        bodyMedium: TextStyle(fontSize: 15, height: 1.4),
      ).apply(bodyColor: AppColors.cinza, displayColor: AppColors.cinza),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.laranja,
          foregroundColor: AppColors.cinza,
          minimumSize: const Size.fromHeight(54),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cinza,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: AppColors.cinza, width: 1.5),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.laranja,
        foregroundColor: AppColors.cinza,
        extendedTextStyle:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.creme,
        labelStyle: const TextStyle(color: AppColors.cinza),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: borda),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: borda),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.laranja, width: 2.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.erro, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.erro, width: 2.5)),
      ),
      // Cores do interruptor "Ponto ativo" (funciona em qualquer versão do Flutter).
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.creme
                : AppColors.cinza),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.laranja
                : AppColors.creme),
        trackOutlineColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.laranja
                : AppColors.cinza),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.cinza,
        contentTextStyle: const TextStyle(color: AppColors.creme, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerColor: AppColors.cinza.withAlpha(40),
    );
  }
}
