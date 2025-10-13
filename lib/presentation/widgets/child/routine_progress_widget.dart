import 'package:flutter/material.dart';
import 'package:koa_app/core/models/routine_model.dart';
import 'package:koa_app/core/theme/colors.dart';

class RoutineProgressWidget extends StatelessWidget {
  final List<RoutineModel> routines;

  const RoutineProgressWidget({super.key, required this.routines});

  @override
  Widget build(BuildContext context) {
    final todayRoutines = routines
        .where((r) => r.schedule.isScheduledToday)
        .toList();
    final completedToday = todayRoutines
        .where((r) => r.isCompletedToday)
        .length;
    final totalTasks = routines.fold(
      0,
      (sum, routine) => sum + routine.tasks.length,
    );
    final completedTasks = routines.fold(
      0,
      (sum, routine) => sum + routine.completedTasksCount,
    );
    final totalTime = routines.fold(
      0,
      (sum, routine) => sum + routine.totalEstimatedMinutes,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso del Día',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Rutinas de hoy
          _buildProgressItem(
            icon: Icons.today,
            label: 'Rutinas de hoy',
            value: '$completedToday/${todayRoutines.length} completadas',
            color: AppColors.primaryGreen,
          ),
          const SizedBox(height: 12),

          // Tareas totales
          _buildProgressItem(
            icon: Icons.checklist,
            label: 'Tareas totales',
            value: '$completedTasks/$totalTasks completadas',
            color: AppColors.secondaryPurple,
          ),
          const SizedBox(height: 12),

          // Tiempo total
          _buildProgressItem(
            icon: Icons.timer,
            label: 'Tiempo estimado',
            value: '${totalTime ~/ 60}h ${totalTime % 60}min',
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: 16),

          // Barra de progreso general
          LinearProgressIndicator(
            value: totalTasks > 0 ? completedTasks / totalTasks : 0,
            backgroundColor: Colors.grey[200],
            color: AppColors.primaryGreen,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
