import 'package:flutter/material.dart';
import 'package:koa_app/core/theme/colors.dart';
import 'package:koa_app/data/models/routine_task_model.dart';

class RoutineTaskWidget extends StatelessWidget {
  final RoutineTask task;
  final bool showCompletion;
  final Function(bool)? onCompletedChanged;
  final VoidCallback? onTap;

  const RoutineTaskWidget({
    super.key,
    required this.task,
    this.showCompletion = true,
    this.onCompletedChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox de completitud
              if (showCompletion)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildCompletionCheckbox(),
                ),

              // Icono de la tarea
              if (task.icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        task.icon!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),

              // Información de la tarea
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: task.completed
                            ? Colors.grey
                            : AppColors.textDark,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: task.completed
                              ? Colors.grey
                              : AppColors.textGray,
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    _buildTaskMetadata(),
                  ],
                ),
              ),

              // Indicadores adicionales
              _buildTaskIndicators(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionCheckbox() {
    return Checkbox(
      value: task.completed,
      onChanged: onCompletedChanged != null
          ? (value) => onCompletedChanged!(value ?? false)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryGreen;
        }
        return null;
      }),
    );
  }

  Widget _buildTaskMetadata() {
    return Wrap(
      spacing: 8,
      children: [
        // Tiempo estimado
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer, size: 12, color: Colors.grey[600]),
            const SizedBox(width: 2),
            Text(
              '${task.estimatedMinutes} min',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),

        // Dificultad
        if (task.difficulty > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                size: 12,
                color: _getDifficultyColor(task.difficulty),
              ),
              const SizedBox(width: 2),
              Text(
                'Nvl ${task.difficulty}',
                style: TextStyle(
                  fontSize: 10,
                  color: _getDifficultyColor(task.difficulty),
                ),
              ),
            ],
          ),

        // Omitible
        if (task.isSkippable)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Opcional',
              style: TextStyle(
                fontSize: 8,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTaskIndicators() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Completado recientemente
        if (task.completed && task.minutesSinceCompletion != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Hace ${task.minutesSinceCompletion} min',
              style: TextStyle(
                fontSize: 8,
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // Instrucciones de audio disponibles
        if (task.audioInstruction != null)
          Icon(Icons.volume_up, size: 16, color: AppColors.primaryBlue),
      ],
    );
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return AppColors.success;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.orange[700]!;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
