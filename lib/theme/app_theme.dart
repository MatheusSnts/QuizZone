
import 'package:flutter/material.dart';


/// Cores partilhadas pela aplicação.
class AppColors {


  static const Color seed = Color(0xFF6750A4);

  static const Color accent = Color(0xFFFFB74D);

  static const Color success = Color(0xFF10B981);

  static const Color error = Color(0xFFEF4444);
}

/// Classe responsável pela configuração global do tema da aplicação.
class AppTheme {

 /// Cria o tema Material 3 usado em todos os ecrãs.
  static ThemeData build() {

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: colorScheme.surface,

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
