// lib/core/theme/text_styles.dart
import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Estilos de texto para la app

  // Estilos para títulos
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  // Estilos para cuerpo de texto
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    color: AppColors.textDark,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    color: AppColors.textDark,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    color: AppColors.textDark,
  );

  // Estilos para etiquetas y botones
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  // Estilos para textos en modo oscuro
  static const TextStyle displayLargeDark = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
  );

  static const TextStyle bodyLargeDark = TextStyle(
    fontSize: 18,
    color: AppColors.textLight,
  );

  // Estilos para textos en colores específicos
  static TextStyle primaryText(BuildContext context) {
    return TextStyle(color: Theme.of(context).colorScheme.primary);
  }

  static TextStyle secondaryText(BuildContext context) {
    return TextStyle(color: Theme.of(context).colorScheme.secondary);
  }

  // Estilos para textos de error, éxito, etc.
  static const TextStyle errorText = TextStyle(
    color: AppColors.error,
    fontSize: 14,
  );

  static const TextStyle successText = TextStyle(
    color: AppColors.success,
    fontSize: 14,
  );

  static const TextStyle warningText = TextStyle(
    color: AppColors.warning,
    fontSize: 14,
  );

  // Estilos para textos en tarjetas
  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    color: AppColors.textGray,
  );

  // Estilos para textos en botones
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle outlinedButtonText(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  // Estilos para textos en campos de formulario
  static const TextStyle inputLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 16,
    color: AppColors.textGray,
  );

  // Estilos para textos en la barra de navegación
  static const TextStyle bottomNavBarSelected = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryGreen,
  );

  static const TextStyle bottomNavBarUnselected = TextStyle(
    fontSize: 12,
    color: AppColors.textGray,
  );
}
