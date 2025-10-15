import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Providers
import 'package:koa_app/presentation/providers/theme_provider.dart';
import 'package:koa_app/presentation/providers/auth_provider.dart';
import 'package:koa_app/presentation/providers/child_provider.dart';
import 'package:koa_app/presentation/providers/ai_provider.dart';
import 'package:koa_app/presentation/providers/payment_provider.dart';
import 'package:koa_app/presentation/providers/routine_provider.dart';

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
import 'package:koa_app/presentation/screens/common/add_edit_routine_screen.dart';

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

// Services
import 'package:koa_app/core/services/mercado_pago_service.dart';
import 'package:koa_app/core/services/payment_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        // options: DefaultFirebaseOptions.currentPlatform,
        );
    print('✅ Firebase inicializado correctamente');
  } catch (e) {
    print('❌ Error inicializando Firebase: $e');
  }

  // 🔐 CONFIGURACIÓN DE CREDENCIALES - REEMPLAZA CON TUS CREDENCIALES REALES
  const String accessToken =
      'APP_USR-7255591479184386-101309-dfab2f93f4c50a5b0be7afad89a433d6-1309579932';
  const String publicKey = 'APP_USR-64000b7d-62ec-4fc2-b131-696a7943bd27';

  // Configurar servicios de pago
  MercadoPagoService.configure(accessToken: accessToken, publicKey: publicKey);

  PaymentService.configure(accessToken: accessToken, publicKey: publicKey);

  // Inicializar servicios
  await PaymentService.initialize();

  print('💰 Servicios de pago configurados correctamente');

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
            title: 'KOA - Aprendizaje Neuroinclusivo',
            theme: themeProvider.currentTheme,
            debugShowCheckedModeBanner: false,
            navigatorKey: AppNavigator.navigatorKey,
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

            initialRoute: '/splash',

            // 🎨 CONFIGURACIONES ADICIONALES
            builder: (context, child) {
              final themeProvider = Provider.of<ThemeProvider>(
                context,
                listen: false,
              );

              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: MediaQuery.of(
                    context,
                  ).textScaleFactor.clamp(0.8, 1.3),
                  alwaysUse24HourFormat: true,
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

            // 🔗 MANEJO DE DEEP LINKS PARA MERCADO PAGO
            onGenerateRoute: (settings) {
              // Manejar deep links de Mercado Pago
              if (settings.name != null &&
                  settings.name!.startsWith('koa://payment/')) {
                final uri = Uri.parse(settings.name!);
                print('🔗 Deep link recibido: $uri');

                // Obtener providers necesarios
                final paymentProvider = Provider.of<PaymentProvider>(
                  AppNavigator.navigatorKey.currentContext!,
                  listen: false,
                );

                final authProvider = Provider.of<AuthProvider>(
                  AppNavigator.navigatorKey.currentContext!,
                  listen: false,
                );

                // Manejar el retorno del pago
                paymentProvider.handlePaymentReturn(uri);

                // Si hay usuario logueado, sincronizar suscripción
                if (authProvider.currentUser != null) {
                  final user = authProvider.currentUser!;
                  PaymentService.syncUserSubscription(user.uid);
                }

                // Mostrar mensaje al usuario
                ScaffoldMessenger.of(
                  AppNavigator.navigatorKey.currentContext!,
                ).showSnackBar(
                  const SnackBar(
                    content: Text('Procesando resultado del pago...'),
                    duration: Duration(seconds: 3),
                  ),
                );

                // Navegar de vuelta a la pantalla de suscripción
                return MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                );
              }

              // ... resto del código de onGenerateRoute (igual que antes)
              // Manejar rutas con parámetros existentes
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

            // ... resto de configuraciones (igual que antes)
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

            showPerformanceOverlay: false,
            checkerboardRasterCacheImages: false,
            checkerboardOffscreenLayers: false,
            showSemanticsDebugger: false,
            debugShowMaterialGrid: false,

            locale: const Locale('es', 'ES'),
            supportedLocales: const [Locale('es', 'ES')],
          );
        },
      ),
    );
  }
}

// ... resto de clases y extensiones (igual que antes)
class _AppScrollBehavior extends ScrollBehavior {
  final bool reduceAnimations;
  const _AppScrollBehavior({this.reduceAnimations = false});

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (reduceAnimations) return child;
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      child: child,
    );
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return reduceAnimations
        ? const ClampingScrollPhysics()
        : const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  Duration get fadeDuration =>
      reduceAnimations ? Duration.zero : const Duration(milliseconds: 200);
  @override
  Duration get transitionDuration =>
      reduceAnimations ? Duration.zero : const Duration(milliseconds: 200);
}

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static Future<T?> push<T>(String routeName, {Object? arguments}) =>
      navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
  static void pop<T>([T? result]) => navigatorKey.currentState!.pop(result);
  static Future<T?> pushReplacement<T>(String routeName, {Object? arguments}) =>
      navigatorKey.currentState!.pushReplacementNamed<T>(
        routeName,
        arguments: arguments,
      );
  static Future<T?> pushAndRemoveUntil<T>(
    String routeName, {
    Object? arguments,
  }) =>
      navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
        routeName,
        (route) => false,
        arguments: arguments,
      );

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

extension NavigationExtension on BuildContext {
  Future<T?> push<T>(String routeName, {Object? arguments}) =>
      Navigator.pushNamed<T>(this, routeName, arguments: arguments);
  void pop<T>([T? result]) => Navigator.pop(this, result);
  Future<T?> pushReplacement<T>(String routeName, {Object? arguments}) =>
      Navigator.pushReplacementNamed<T>(this, routeName, arguments: arguments);
  Future<T?> pushAndRemoveUntil<T>(String routeName, {Object? arguments}) =>
      Navigator.pushNamedAndRemoveUntil<T>(
        this,
        routeName,
        (route) => false,
        arguments: arguments,
      );

  ThemeProvider get themeProvider =>
      Provider.of<ThemeProvider>(this, listen: false);
  AuthProvider get authProvider =>
      Provider.of<AuthProvider>(this, listen: false);
  ChildProvider get childProvider =>
      Provider.of<ChildProvider>(this, listen: false);
  AIProvider get aiProvider => Provider.of<AIProvider>(this, listen: false);
  PaymentProvider get paymentProvider =>
      Provider.of<PaymentProvider>(this, listen: false);

  void showSnackBar(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).colorScheme.primary,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: isError
            ? SnackBarAction(
                label: 'Cerrar',
                textColor: Theme.of(this).colorScheme.onError,
                onPressed: () =>
                    ScaffoldMessenger.of(this).hideCurrentSnackBar(),
              )
            : null,
      ),
    );
  }
}

extension ThemeExtension on ThemeData {
  Color get kovaPrimary => const Color(0xFF4CAF50);
  Color get kovaSecondary => const Color(0xFF2196F3);
  Color get kovaBackground => colorScheme.background;
  Color get kovaSurface => colorScheme.surface;
  Color get kovaError => colorScheme.error;
  TextStyle get kovaTitleLarge =>
      textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold);
  TextStyle get kovaBodyMedium => textTheme.bodyMedium!.copyWith(height: 1.5);
}

extension AccessibilityExtension on BuildContext {
  bool get isDarkMode => themeProvider.isDarkMode;
  bool get isDyslexicFont => themeProvider.isDyslexicFont;
  bool get reduceAnimations => themeProvider.reduceAnimations;
  bool get disableLoudSounds => themeProvider.disableLoudSounds;

  Widget withAccessibility(Widget child) {
    return AnimatedContainer(
      duration:
          reduceAnimations ? Duration.zero : const Duration(milliseconds: 300),
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

// 🔄 NUEVA EXTENSIÓN PARA SERVICIOS DE PAGO
extension PaymentServicesExtension on BuildContext {
  // Verificar estado de suscripción usando ambos servicios
  Future<void> checkFullSubscriptionStatus() async {
    final auth = authProvider;
    final payment = paymentProvider;

    if (auth.currentUser != null) {
      final user = auth.currentUser!;

      // Verificar con PaymentProvider (nueva estructura)
      await payment.checkUserSubscription(user.uid, userEmail: user.email);

      // Sincronizar con PaymentService (compatibilidad con estructura antigua)
      await PaymentService.syncUserSubscription(user.uid);

      showSnackBar('Estado de suscripción verificado y sincronizado');
    }
  }

  // Obtener historial de pagos
  Future<Map<String, dynamic>> getPaymentHistory() async {
    final auth = authProvider;
    if (auth.currentUser != null) {
      return await PaymentService.getPaymentHistory(auth.currentUser!.uid);
    }
    return {'success': false, 'error': 'Usuario no autenticado'};
  }
}
