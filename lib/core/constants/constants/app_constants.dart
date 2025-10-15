// lib/core/constants/app_constants.dart
import 'package:flutter/material.dart';
import "package:koa_app/core/theme/colors.dart";

class AppConstants {
  // Configuración de la App
  static const String appName = 'KOVA';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Aprender juntos para un mundo más inclusivo';

  // Rutas de Navegación
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String parentDashboardRoute = '/parent/dashboard';
  static const String childHomeRoute = '/child/home';
  static const String professionalDashboardRoute = '/professional/dashboard';
  static const String settingsRoute = '/settings';
  static const String childProgressRoute = '/child/progress';
  static const String reportsRoute = '/reports';
  static const String routinesRoute = '/routines';
  static const String gamesRoute = '/games';
  static const String emotionalGameRoute = '/games/emotional';
  static const String memoryGameRoute = '/games/memory';
  static const String patternGameRoute = '/games/pattern';
  static const String aiAnalysisRoute = '/ai/analysis';

  // Colecciones de Firestore
  static const String usersCollection = 'users';
  static const String childrenCollection = 'children';
  static const String activitiesCollection = 'activities';
  static const String routinesCollection = 'routines';
  static const String reportsCollection = 'reports';
  static const String sessionsCollection = 'sessions';
  static const String subscriptionsCollection = 'subscriptions';

  // Configuración de Suscripciones
  static const double basicPlanPrice = 1.0;
  static const double familyPlanPrice = 3.0;
  static const double premiumPlanPrice = 5.0;
  static const int trialDays = 15;

  // Planes disponibles
  static const Map<String, double> subscriptionPlans = {
    'basic': basicPlanPrice,
    'family': familyPlanPrice,
    'premium': premiumPlanPrice,
  };

  // Límites de la aplicación
  static const int maxChildrenPerAccount = 5;
  static const int maxRoutinesPerChild = 10;
  static const int maxDailyActivities = 20;
  static const int sessionTimeoutMinutes = 30;

  // Configuración de IA
  static const int maxAiRequestsPerDay = 50;
  static const int maxOfflineActivities = 10;

  // Keys para almacenamiento local
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userTypeKey = 'user_type';
  static const String darkModeKey = 'dark_mode';
  static const String dyslexicFontKey = 'dyslexic_font';
  static const String reduceAnimationsKey = 'reduce_animations';
  static const String disableLoudSoundsKey = 'disable_loud_sounds';
  static const String notificationsKey = 'notifications';
  static const String aiSuggestionsKey = 'ai_suggestions';
  static const String weeklyReportsKey = 'weekly_reports';
  static const String progressAlertsKey = 'progress_alerts';
  static const String firstTimeKey = 'first_time';

  // Assets paths
  static const String kovaMascotPath = 'assets/images/kova/';
  static const String activitiesAssetsPath = 'assets/activities/';
  static const String iconsPath = 'assets/icons/';
  static const String soundsPath = 'assets/sounds/';

  // URLs y endpoints
  static const String privacyPolicyUrl = 'https://kova-app.com/privacy';
  static const String termsOfServiceUrl = 'https://kova-app.com/terms';
  static const String supportEmail = 'soporte@kova-app.com';

  // Tiempos y duraciones
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration connectionTimeout = Duration(seconds: 10);

  // Textos estáticos
  static const String welcomeMessage = '¡Bienvenido a KOVA!';
  static const String loadingMessage = 'Cargando...';
  static const String errorMessage = 'Ha ocurrido un error';
  static const String successMessage = 'Operación exitosa';

  // Colores específicos de la app (basados en colors.dart)
  static const Color primaryColor = AppColors.primaryGreen;
  static const Color secondaryColor = AppColors.secondaryPurple;
  static const Color accentColor = AppColors.kovaOrange;
  static const Color successColor = AppColors.success;
  static const Color warningColor = AppColors.warning;
  static const Color errorColor = AppColors.error;

  // Tamaños y dimensiones
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double buttonHeight = 50.0;
  static const double iconSize = 24.0;

  // Tipos de usuario
  static const String userTypeParent = 'parent';
  static const String userTypeProfessional = 'professional';
  static const String userTypeChild = 'child';

  // Categorías de actividades
  static const List<String> activityCategories = [
    'memoria',
    'emociones',
    'patrones',
    'matematica',
    'lenguaje',
    'social'
  ];

  // Síndromes soportados
  static const List<String> supportedSyndromes = [
    'TEA',
    'TDAH',
    'Síndrome de Down',
    'Discapacidad Intelectual',
    'Otro'
  ];

  // Estilos de aprendizaje
  static const List<String> learningStyles = [
    'visual',
    'auditivo',
    'kinestésico',
    'mixto'
  ];
}
