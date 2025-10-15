import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koa_app/presentation/providers/child_provider.dart';
import 'package:koa_app/presentation/providers/auth_provider.dart';
import 'package:koa_app/presentation/widgets/common/kova_mascot.dart';
import 'package:koa_app/core/theme/colors.dart';
import 'package:koa_app/presentation/widgets/child/routine_card.dart';
import 'games_screen.dart';
import 'routines_screen.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos del niño al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final childProvider = Provider.of<ChildProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Si hay usuario actual, cargar datos del niño
      if (authProvider.currentUser != null) {
        childProvider.loadChildData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final childProvider = Provider.of<ChildProvider>(context);
    final currentChild = childProvider.currentChild;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con saludo y KOVA
              _buildHeader(context, currentChild?.name ?? 'Amigo'),
              const SizedBox(height: 24),

              // Sección de Rutinas del Día
              _buildRoutinesSection(context),
              const SizedBox(height: 24),

              // Sección de Actividades
              _buildActivitiesSection(context),
              const SizedBox(height: 24),

              // Progreso del Día
              _buildDailyProgress(context, currentChild),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String childName) {
    return Row(
      children: [
        const KovaMascot(size: 60, expression: KovaExpression.happy),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Hola, $childName!',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 24,
                      color: AppColors.textDark,
                    ),
              ),
              Text(
                '¿Qué vamos a aprender hoy?',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textGray),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoutinesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tus Rutinas de Hoy',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 20,
                    color: AppColors.textDark,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoutinesScreen(),
                  ),
                );
              },
              child: const Text(
                'Ver Todas',
                style: TextStyle(
                  color: AppColors.secondaryPurple,
                  fontFamily: 'OpenDyslexic',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const RoutineCard(), // Usar el widget de rutinas existente
      ],
    );
  }

  Widget _buildActivitiesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Actividades Divertidas',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 20,
                    color: AppColors.textDark,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GamesScreen()),
                );
              },
              child: const Text(
                'Ver Más',
                style: TextStyle(
                  color: AppColors.secondaryPurple,
                  fontFamily: 'OpenDyslexic',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildActivityCard(
              context,
              'Memory Cards',
              'Encuentra las parejas',
              Icons.memory,
              AppColors.primaryGreen,
              () {
                // Navegar al juego de memoria
                // Navigator.push(context, MaterialPageRoute(builder: (context) => MemoryGameScreen()));
              },
            ),
            _buildActivityCard(
              context,
              'Emociones',
              'Identifica emociones',
              Icons.emoji_emotions,
              AppColors.secondaryPurple,
              () {
                // Navegar al juego de emociones
                // Navigator.push(context, MaterialPageRoute(builder: (context) => EmotionalGameScreen()));
              },
            ),
            _buildActivityCard(
              context,
              'Patrones',
              'Sigue la secuencia',
              Icons.pattern,
              AppColors.kovaOrange,
              () {
                // Navegar al juego de patrones
                // Navigator.push(context, MaterialPageRoute(builder: (context) => PatternGameScreen()));
              },
            ),
            _buildActivityCard(
              context,
              'Colores',
              'Aprende colores',
              Icons.palette,
              AppColors.blueLight,
              () {
                // Navegar al juego de colores
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyProgress(BuildContext context, dynamic currentChild) {
    final totalStars = currentChild?.progress?.totalStars ?? 0;
    final totalPlayTime = currentChild?.progress?.totalPlayTime ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome,
            color: AppColors.primaryGreen,
            size: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Buen trabajo hoy!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Has completado $totalStars actividades',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.textGray),
                ),
                if (totalPlayTime > 0)
                  Text(
                    'Tiempo total: ${(totalPlayTime / 60).toStringAsFixed(0)} min',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textGray,
                          fontSize: 14,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenDyslexic',
                    ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textGray,
                      fontSize: 12,
                      fontFamily: 'OpenDyslexic',
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
