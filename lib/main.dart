import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:koa_app/core/theme/app_theme.dart';
import 'package:koa_app/core/theme/colors.dart';

// Providers
import 'package:koa_app/core/providers/theme_provider.dart';
import 'package:koa_app/core/providers/auth_provider.dart';
import 'package:koa_app/core/providers/child_provider.dart';
import 'package:koa_app/core/providers/ai_provider.dart';
import 'package:koa_app/core/providers/payment_provider.dart';
import 'package:koa_app/core/providers/routine_provider.dart';

// Screens
import 'package:koa_app/presentation/screens/common/splash_screen.dart';
import 'package:koa_app/presentation/screens/common/onboarding_screen.dart';
import 'package:koa_app/presentation/screens/auth/login_screen.dart';
import 'package:koa_app/presentation/screens/auth/register_screen.dart';

// Child Screens
import 'package:koa_app/presentation/screens/child/child_home_screen.dart';
import 'package:koa_app/presentation/screens/child/games_screen.dart';
import 'package:koa_app/presentation/screens/child/memory_game_screen.dart';
import 'package:koa_app/presentation/screens/child/emotional_game_screen.dart';
import 'package:koa_app/presentation/screens/child/pattern_game_screen.dart';
import 'package:koa_app/presentation/screens/child/routines_screen.dart';
import 'package:koa_app/presentation/screens/child/routine_detail_screen.dart';
import 'package:koa_app/presentation/screens/child/add_edit_routine_screen.dart';

// Parent Screens
import 'package:koa_app/presentation/screens/parent/parent_dashboard.dart';
import 'package:koa_app/presentation/screens/parent/child_progress_screen.dart';
import 'package:koa_app/presentation/screens/parent/reports_screen.dart';
import 'package:koa_app/presentation/screens/parent/ai_analysis_screen.dart';

// Professional Screens
import 'package:koa_app/presentation/screens/professional/professional_dashboard.dart';
import 'package:koa_app/presentation/screens/professional/student_management.dart';

// Common Screens
import 'package:koa_app/presentation/screens/common/settings_screen.dart';
import 'package:koa_app/presentation/screens/subscription/subscription_screen.dart';

// Firebase Options (generado automáticamente)
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform, // Descomenta cuando tengas firebase_options.dart
    );
    print('✅ Firebase inicializado correctamente');
  } catch (e) {
    print('❌ Error inicializando Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChildProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'KOVA - Aprendizaje Neuroinclusivo',
            theme: themeProvider.currentTheme,
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),

            // 🎯 RUTAS COMPLETAS ACTUALIZADAS
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),

              // 🧒 RUTAS PARA NIÑOS
              '/child_home': (context) => const ChildHomeScreen(),
              '/games': (context) => const GamesScreen(),
              '/memory_game': (context) => const MemoryGameScreen(),
              '/emotional_game': (context) => const EmotionalGameScreen(),
              '/pattern_game': (context) => const PatternGameScreen(),
              '/child_routines': (context) => const RoutinesScreen(),
              '/routine_detail': (context) => const RoutineDetailScreen(),
              '/add_edit_routine': (context) => const AddEditRoutineScreen(),

              // 👨‍👩‍👧‍👦 RUTAS PARA PADRES
              '/parent_dashboard': (context) => const ParentDashboard(),
              '/child_progress': (context) => const ChildProgressScreen(),
              '/reports': (context) => const ReportsScreen(),
              '/ai_analysis': (context) => const AIAnalysisScreen(),

              // 👩‍🏫 RUTAS PARA PROFESIONALES
              '/professional_dashboard': (context) =>
                  const ProfessionalDashboard(),
              '/student_management': (context) => const StudentManagement(),

              // ⚙️ RUTAS COMUNES
              '/settings': (context) => const SettingsScreen(),
              '/subscription': (context) => const SubscriptionScreen(),
            },

            // 🚀 RUTA INICIAL
            initialRoute: '/splash',

            // 🎨 CONFIGURACIONES ADICIONALES MEJORADAS CON ACCESIBILIDAD
            builder: (context, child) {
              final themeProvider = Provider.of<ThemeProvider>(
                context,
                listen: false,
              );

              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  // Asegurar buen escalado de texto para accesibilidad
                  textScaleFactor: MediaQuery.of(
                    context,
                  ).textScaleFactor.clamp(0.8, 1.3),
                  // Asegurar tamaño mínimo de toque para accesibilidad
                  alwaysUse24HourFormat: true, // Formato de tiempo consistente
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ScrollConfiguration(
                    behavior: _AppScrollBehavior(
                      reduceAnimations: themeProvider.reduceAnimations,
                    ),
                    child: child!,
                  ),
                ),
              );
            },

            // 🏠 Página 404 personalizada
            onGenerateRoute: (settings) {
              // Manejar rutas con parámetros
              if (settings.name == '/routine_detail' &&
                  settings.arguments != null) {
                final arguments = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => RoutineDetailScreen(
                    routineId: arguments['routineId'],
                    routineName: arguments['routineName'],
                  ),
                );
              }

              if (settings.name == '/add_edit_routine' &&
                  settings.arguments != null) {
                final arguments = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => AddEditRoutineScreen(
                    routine: arguments['routine'],
                    isEditing: arguments['isEditing'] ?? false,
                  ),
                );
              }

              if (settings.name == '/child_progress' &&
                  settings.arguments != null) {
                final arguments = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => ChildProgressScreen(
                    childId: arguments['childId'],
                    childName: arguments['childName'],
                  ),
                );
              }

              // Manejar rutas no definidas
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  appBar: AppBar(
                    title: const Text('Página no encontrada'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80,
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withOpacity(0.5),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Página no encontrada',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'La ruta "${settings.name}" no existe en la aplicación.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/child_home',
                                      (route) => false,
                                    ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                                child: const Text('Ir al Inicio'),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: () => Navigator.maybePop(context),
                                child: const Text('Regresar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },

            // 🔧 Manejo de rutas no implementadas
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: const Text('Error'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning_amber,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Función no disponible',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Esta funcionalidad estará disponible en una futura actualización.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/child_home',
                            (route) => false,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                          child: const Text('Volver al Inicio'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },

            // 🎭 Configuración de rendimiento
            showPerformanceOverlay: false,
            checkerboardRasterCacheImages: false,
            checkerboardOffscreenLayers: false,
            showSemanticsDebugger: false,
            debugShowMaterialGrid: false,

            // 🎪 Configuración de localización
            locale: const Locale('es', 'ES'),
            supportedLocales: const [Locale('es', 'ES')],
            localizationsDelegates: const [
              // Agrega aquí tus delegados de localización si los tienes
              // DefaultMaterialLocalizations.delegate,
              // DefaultWidgetsLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}

// 🔧 Comportamiento de scroll personalizado para accesibilidad
class _AppScrollBehavior extends ScrollBehavior {
  final bool reduceAnimations;

  const _AppScrollBehavior({this.reduceAnimations = false});

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (reduceAnimations) {
      return child;
    }
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      child: child,
    );
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (reduceAnimations) {
      return const ClampingScrollPhysics();
    }
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  Duration get fadeDuration =>
      reduceAnimations ? Duration.zero : const Duration(milliseconds: 200);

  @override
  Duration get transitionDuration =>
      reduceAnimations ? Duration.zero : const Duration(milliseconds: 200);
}

// 🔧 Clase helper para navegación global
class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<T?> push<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static void pop<T>([T? result]) {
    navigatorKey.currentState!.pop(result);
  }

  static Future<T?> pushReplacement<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushAndRemoveUntil<T>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  // Método para mostrar diálogos globales
  static Future<T?> showDialog<T>({
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: navigatorKey.currentContext!,
      builder: builder,
      barrierDismissible: barrierDismissible,
    );
  }
}

// 🎯 Extensión para contextos de navegación
extension NavigationExtension on BuildContext {
  Future<T?> push<T>(String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(this, routeName, arguments: arguments);
  }

  void pop<T>([T? result]) {
    Navigator.pop(this, result);
  }

  Future<T?> pushReplacement<T>(String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed<T>(
      this,
      routeName,
      arguments: arguments,
    );
  }

  Future<T?> pushAndRemoveUntil<T>(String routeName, {Object? arguments}) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      this,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  // Métodos de ayuda para el ThemeProvider
  ThemeProvider get themeProvider =>
      Provider.of<ThemeProvider>(this, listen: false);
  AuthProvider get authProvider =>
      Provider.of<AuthProvider>(this, listen: false);
  ChildProvider get childProvider =>
      Provider.of<ChildProvider>(this, listen: false);
  AIProvider get aiProvider => Provider.of<AIProvider>(this, listen: false);

  // Método para mostrar snackbars consistentes
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).colorScheme.primary,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// 🎨 Extensión para temas personalizados
extension ThemeExtension on ThemeData {
  // Métodos de ayuda para colores específicos de la app
  Color get kovaPrimary => const Color(0xFF4CAF50); // Verde KOVA
  Color get kovaSecondary => const Color(0xFF2196F3); // Azul KOVA
  Color get kovaBackground => colorScheme.background;
  Color get kovaSurface => colorScheme.surface;
  Color get kovaError => colorScheme.error;

  // Métodos para textos accesibles
  TextStyle get kovaTitleLarge =>
      textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold);

  TextStyle get kovaBodyMedium => textTheme.bodyMedium!.copyWith(height: 1.5);
}

// 🔔 Extensión para notificaciones de accesibilidad
extension AccessibilityExtension on BuildContext {
  bool get isDarkMode => themeProvider.isDarkMode;
  bool get isDyslexicFont => themeProvider.isDyslexicFont;
  bool get reduceAnimations => themeProvider.reduceAnimations;
  bool get disableLoudSounds => themeProvider.disableLoudSounds;

  // Método para aplicar configuraciones de accesibilidad a cualquier widget
  Widget withAccessibility(Widget child) {
    return AnimatedContainer(
      duration: reduceAnimations
          ? Duration.zero
          : const Duration(milliseconds: 300),
      child: MediaQuery(
        data: MediaQuery.of(this).copyWith(
          textScaleFactor: isDyslexicFont
              ? MediaQuery.of(this).textScaleFactor.clamp(1.0, 1.2)
              : MediaQuery.of(this).textScaleFactor.clamp(0.8, 1.3),
        ),
        child: child,
      ),
    );
  }
}
