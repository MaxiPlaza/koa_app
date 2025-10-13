// lib/core/constants/firebase_constants.dart

class FirebaseConstants {
  // Nombres de colecciones de Firestore
  static const String usersCollection = 'users';
  static const String childrenCollection = 'children';
  static const String activitiesCollection = 'activities';
  static const String routinesCollection = 'routines';
  static const String reportsCollection = 'reports';
  static const String sessionsCollection = 'sessions';
  static const String subscriptionsCollection = 'subscriptions';
  static const String paymentsCollection = 'payments';

  // Subcolecciones
  static const String progressSubcollection = 'progress';
  static const String settingsSubcollection = 'settings';
  static const String tasksSubcollection = 'tasks';
  static const String sessionsSubcollection = 'sessions';

  // Campos comunes
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
  static const String uidField = 'uid';
  static const String emailField = 'email';
  static const String nameField = 'name';
  static const String userTypeField = 'userType';

  // Tipos de usuario
  static const String userTypeParent = 'parent';
  static const String userTypeProfessional = 'professional';
  static const String userTypeChild = 'child';

  // Campos de niño
  static const String ageField = 'age';
  static const String syndromeField = 'syndrome';
  static const String learningStyleField = 'learningStyle';
  static const String parentIdField = 'parentId';
  static const String professionalIdsField = 'professionalIds';
  static const String skillLevelsField = 'skillLevels';

  // Campos de progreso
  static const String totalPlayTimeField = 'totalPlayTime';
  static const String totalStarsField = 'totalStars';
  static const String lastSessionField = 'lastSession';
  static const String recentSessionsField = 'recentSessions';

  // Campos de actividades
  static const String categoryField = 'category';
  static const String difficultyField = 'difficulty';
  static const String estimatedDurationField = 'estimatedDuration';
  static const String skillsField = 'skills';
  static const String minAgeField = 'minAge';
  static const String maxAgeField = 'maxAge';
  static const String assetPathField = 'assetPath';

  // Campos de rutinas
  static const String childIdField = 'childId';
  static const String scheduleField = 'schedule';
  static const String tasksField = 'tasks';
  static const String completedField = 'completed';
  static const String timeField = 'time';
  static const String iconField = 'icon';

  // Configuración de Firebase Storage paths
  static const String storageChildAvatars = 'child_avatars';
  static const String storageActivityAssets = 'activity_assets';
  static const String storageReports = 'reports';
  static const String storageKovaAnimations = 'kova_animations';

  // Nombres de documentos por defecto
  static const String defaultActivitiesDoc = 'default_activities';
  static const String appConfigDoc = 'app_config';

  // Límites y configuraciones
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxRetryAttempts = 3;
  static const Duration timeoutDuration = Duration(seconds: 30);
  static const Duration cacheDuration = Duration(hours: 1);

  // Errores y mensajes
  static const String networkError = 'Error de conexión';
  static const String permissionDenied = 'Permiso denegado';
  static const String documentNotFound = 'Documento no encontrado';

  // Configuración de consultas
  static const int defaultPageSize = 20;
  static const int maxQueryLimit = 100;

  // Nombres de índices (si usas composite indexes)
  static const String childProgressIndex = 'child_progress_index';
  static const String userActivitiesIndex = 'user_activities_index';
}

// Constantes para las reglas de seguridad (referencia)
class FirebaseRules {
  static const String usersReadRule = 'users_read';
  static const String usersWriteRule = 'users_write';
  static const String childrenReadRule = 'children_read';
  static const String childrenWriteRule = 'children_write';
}

// Constantes para Analytics
class FirebaseAnalyticsEvents {
  static const String userSignedUp = 'user_signed_up';
  static const String userLoggedIn = 'user_logged_in';
  static const String activityCompleted = 'activity_completed';
  static const String routineCompleted = 'routine_completed';
  static const String reportGenerated = 'report_generated';
  static const String subscriptionStarted = 'subscription_started';
  static const String paymentProcessed = 'payment_processed';

  static const String screenView = 'screen_view';
  static const String buttonClick = 'button_click';
  static const String errorOccurred = 'error_occurred';
}

class FirebaseAnalyticsParams {
  static const String userId = 'user_id';
  static const String userType = 'user_type';
  static const String activityId = 'activity_id';
  static const String activityType = 'activity_type';
  static const String difficulty = 'difficulty';
  static const String duration = 'duration';
  static const String starsEarned = 'stars_earned';
  static const String errorMessage = 'error_message';
  static const String screenName = 'screen_name';
  static const String buttonName = 'button_name';
  static const String subscriptionPlan = 'subscription_plan';
  static const String paymentAmount = 'payment_amount';
}

// Constantes para Performance Monitoring
class FirebasePerformanceTraces {
  static const String appStartTrace = 'app_start_trace';
  static const String screenLoadTrace = 'screen_load_trace';
  static const String apiCallTrace = 'api_call_trace';
  static const String activityLoadTrace = 'activity_load_trace';
  static const String reportGenerationTrace = 'report_generation_trace';
}
