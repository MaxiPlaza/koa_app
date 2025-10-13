import 'package:flutter/material.dart';
import 'package:koa_app/data/models/routine_model.dart';
import 'package:koa_app/core/theme/colors.dart';

class RoutineCard extends StatelessWidget {
  final RoutineModel routine;
  final VoidCallback onTap;
  final Function(bool)? onToggleStatus;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onTap,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con información principal
              _buildHeader(context),
              const SizedBox(height: 12),

              // Progreso y tareas
              _buildProgressSection(),
              const SizedBox(height: 12),

              // Horario y estado
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono de la rutina
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getColorFromHex(routine.color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(routine.icon, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 12),

        // Información principal
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                routine.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                routine.description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textGray),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Toggle de estado activo/inactivo
        if (onToggleStatus != null)
          Switch(
            value: routine.isActive,
            onChanged: onToggleStatus,
            activeColor: AppColors.primaryGreen,
          ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de progreso
        LinearProgressIndicator(
          value: routine.progress,
          backgroundColor: Colors.grey[200],
          color: _getColorFromHex(routine.color),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 8),

        // Información de progreso
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${routine.completedTasksCount}/${routine.tasks.length} tareas',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              '${(routine.progress * 100).toStringAsFixed(0)}% completado',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getColorFromHex(routine.color),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Horario
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${_formatTime(routine.schedule.startTime)} - ${_formatTime(routine.schedule.endTime)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),

        // Días programados
        Text(
          _getDaysText(routine.schedule.daysOfWeek),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),

        // Estado de completitud hoy
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: routine.isCompletedToday
                ? AppColors.success.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            routine.isCompletedToday ? 'Completado' : 'Pendiente',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: routine.isCompletedToday
                  ? AppColors.success
                  : Colors.orange,
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getDaysText(List<int> days) {
    if (days.length == 7) return 'Todos los días';
    if (days.length == 5 && !days.contains(6) && !days.contains(7)) {
      return 'Lunes a Viernes';
    }

    final dayNames = {
      1: 'Lun',
      2: 'Mar',
      3: 'Mié',
      4: 'Jue',
      5: 'Vie',
      6: 'Sáb',
      7: 'Dom',
    };

    return days.map((day) => dayNames[day]).join(', ');
  }
}
