import 'package:flutter/material.dart';
import 'package:koa_app/data/models/activity_model.dart';

class ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback onTap;

  const ActivityCard({super.key, required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Icono del juego con badge de nivel IA
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: _getCategoryColor(activity.category),
                    ),
                    child: Icon(
                      _getCategoryIcon(activity.category),
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  // Badge de nivel adaptativo IA
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: _getDifficultyColor(activity.difficulty),
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Nvl ${activity.difficulty}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Nombre del juego
              Text(
                activity.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Descripción
              Text(
                activity.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // ✅ Dificultad y tiempo - ACTUALIZADO para 5 niveles
              Row(
                children: [
                  // Estrellas de dificultad (1-5 niveles)
                  ...List.generate(
                    5,
                    (index) => Icon(
                      Icons.star,
                      size: 16,
                      color: index < activity.difficulty
                          ? _getDifficultyColor(
                              activity.difficulty,
                            ) // ✅ Color dinámico
                          : Colors.grey[300],
                    ),
                  ),

                  const Spacer(),

                  // Tiempo estimado
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${activity.estimatedDuration}min',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'memory':
        return Colors.blue;
      case 'emotions':
        return Colors.purple;
      case 'patterns':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'memory':
        return Icons.memory;
      case 'emotions':
        return Icons.emoji_emotions;
      case 'patterns':
        return Icons.pattern;
      default:
        return Icons.games;
    }
  }

  // ✅ Método nuevo para colores de dificultad dinámicos
  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
