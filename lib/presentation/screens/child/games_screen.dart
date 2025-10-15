import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koa_app/presentation/widgets/common/kova_mascot.dart';
import 'package:koa_app/presentation/widgets/child/activity_card.dart';
import 'package:koa_app/data/models/activity_model.dart';
import '../../providers/child_provider.dart';
import '../../providers/ai_provider.dart'; // ✅ Import agregado // ✅ Import agregado

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final childProvider = Provider.of<ChildProvider>(context);
    final currentChild = childProvider.currentChild;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header con KOVA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Row(
                children: [
                  const KovaMascot(
                    expression: KovaExpression.excited,
                    size: 60,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Hola ${currentChild?.name ?? "Amigo"}!',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          'Elige un juego divertido',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Lista de Juegos
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Juegos Divertidos',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // ✅ GridView actualizado con Consumer para IA
                    Expanded(
                      child: Consumer<AIProvider>(
                        builder: (context, aiProvider, child) {
                          return GridView(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.9,
                            ),
                            children: [
                              // ✅ Memory Cards con dificultad adaptativa
                              ActivityCard(
                                activity: ActivityModel(
                                  id: 'memory_1',
                                  name: 'Memory Cards',
                                  description: 'Encuentra las parejas iguales',
                                  category: 'memory',
                                  difficulty: aiProvider.getAdaptiveDifficulty(
                                    'memory',
                                  ), // ✅ Dificultad IA
                                  estimatedDuration: 10,
                                  instructions:
                                      'Toca las cartas para encontrar parejas',
                                  assetPath: 'assets/games/memory/',
                                  skills: [
                                    'memoria',
                                    'atención',
                                    'concentración',
                                  ],
                                  minAge: 4,
                                  maxAge: 12,
                                ),
                                onTap: () => _navigateToMemoryGame(context),
                              ),

                              // ✅ Emotional Match con dificultad adaptativa
                              ActivityCard(
                                activity: ActivityModel(
                                  id: 'emotions_1',
                                  name: 'Emotional Match',
                                  description:
                                      'Combina emociones con situaciones',
                                  category: 'emotions',
                                  difficulty: aiProvider.getAdaptiveDifficulty(
                                    'emotions',
                                  ), // ✅ Dificultad IA
                                  estimatedDuration: 15,
                                  instructions:
                                      'Relaciona emociones con imágenes',
                                  assetPath: 'assets/games/emotions/',
                                  skills: ['inteligencia emocional', 'empatía'],
                                  minAge: 5,
                                  maxAge: 12,
                                ),
                                onTap: () => _navigateToEmotionalGame(context),
                              ),

                              // ✅ Pattern Sequence con dificultad adaptativa
                              ActivityCard(
                                activity: ActivityModel(
                                  id: 'patterns_1',
                                  name: 'Pattern Sequence',
                                  description:
                                      'Completa la secuencia de patrones',
                                  category: 'patterns',
                                  difficulty: aiProvider.getAdaptiveDifficulty(
                                    'patterns',
                                  ), // ✅ Dificultad IA
                                  estimatedDuration: 12,
                                  instructions:
                                      'Sigue el patrón y completa la secuencia',
                                  assetPath: 'assets/games/patterns/',
                                  skills: [
                                    'lógica',
                                    'secuenciación',
                                    'patrones',
                                  ],
                                  minAge: 6,
                                  maxAge: 12,
                                ),
                                onTap: () => _navigateToPatternGame(context),
                              ),

                              // ✅ Juego placeholder
                              ActivityCard(
                                activity: ActivityModel(
                                  id: 'coming_soon',
                                  name: 'Más Juegos',
                                  description: 'Próximamente...',
                                  category: 'coming_soon',
                                  difficulty: 1,
                                  estimatedDuration: 0,
                                  instructions: '',
                                  assetPath: 'assets/games/coming_soon/',
                                  skills: [],
                                  minAge: 3,
                                  maxAge: 12,
                                ),
                                onTap: () => _showComingSoon(context),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Rutas corregidas
  void _navigateToMemoryGame(BuildContext context) {
    Navigator.pushNamed(context, '/memory_game');
  }

  void _navigateToEmotionalGame(BuildContext context) {
    Navigator.pushNamed(context, '/emotional_game');
  }

  void _navigateToPatternGame(BuildContext context) {
    Navigator.pushNamed(context, '/pattern_game');
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Más juegos divertidos vienen en camino!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
