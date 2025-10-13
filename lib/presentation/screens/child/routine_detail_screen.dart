import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koa_app/core/models/routine_model.dart';
import 'package:koa_app/presentation/providers/routine_provider.dart';
import 'package:koa_app/presentation/widgets/routines/routine_task_widget.dart';
import 'package:koa_app/presentation/widgets/common/kova_mascot.dart';
import 'package:koa_app/presentation/screens/routines/add_edit_routine_screen.dart';

class RoutineDetailScreen extends StatefulWidget {
  final RoutineModel routine;

  const RoutineDetailScreen({super.key, required this.routine});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final routineProvider = context.read<RoutineProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine.name),
        backgroundColor: _getColorFromHex(widget.routine.color),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _navigateToEdit,
            icon: const Icon(Icons.edit),
            tooltip: 'Editar rutina',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header informativo
            _buildRoutineHeader(),
            const SizedBox(height: 24),

            // Progreso actual
            _buildProgressSection(),
            const SizedBox(height: 24),

            // Lista de tareas
            _buildTasksList(routineProvider),
            const SizedBox(height: 24),

            // Información de horario
            _buildScheduleInfo(),
            const SizedBox(height: 24),

            // Acciones
            _buildActionButtons(routineProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icono grande
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _getColorFromHex(widget.routine.color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  widget.routine.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.routine.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.routine.description,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusChip(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Wrap(
      spacing: 8,
      children: [
        // Estado activo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.routine.isActive
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.routine.isActive ? 'Activa' : 'Inactiva',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: widget.routine.isActive ? Colors.green : Colors.grey,
            ),
          ),
        ),

        // Completado hoy
        if (widget.routine.isCompletedToday)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Completado hoy',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progreso Actual',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Barra de progreso
            LinearProgressIndicator(
              value: widget.routine.progress,
              backgroundColor: Colors.grey[200],
              color: _getColorFromHex(widget.routine.color),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),

            // Estadísticas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.routine.completedTasksCount}/${widget.routine.tasks.length} tareas',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '${(widget.routine.progress * 100).toStringAsFixed(0)}% completado',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getColorFromHex(widget.routine.color),
                  ),
                ),
              ],
            ),

            // Tiempo total
            if (widget.routine.totalEstimatedMinutes > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Tiempo total: ${widget.routine.totalEstimatedMinutes} min',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(RoutineProvider routineProvider) {
    final sortedTasks = widget.routine.tasks.toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tareas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...sortedTasks.map((task) {
              return RoutineTaskWidget(
                task: task,
                showCompletion: true,
                onCompletedChanged: (completed) {
                  routineProvider.toggleTaskCompletion(
                    routineId: widget.routine.id,
                    taskId: task.id,
                    completed: completed,
                  );
                },
              );
            }).toList(),

            if (sortedTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    KovaMascot(expression: KovaExpression.thinking, size: 80),
                    SizedBox(height: 16),
                    Text(
                      'No hay tareas en esta rutina',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Horario',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Horario
            _buildScheduleItem(
              Icons.access_time,
              'Horario',
              '${_formatTime(widget.routine.schedule.startTime)} - ${_formatTime(widget.routine.schedule.endTime)}',
            ),
            const SizedBox(height: 8),

            // Días
            _buildScheduleItem(
              Icons.calendar_today,
              'Días',
              _getDaysText(widget.routine.schedule.daysOfWeek),
            ),
            const SizedBox(height: 8),

            // Recordatorio
            if (widget.routine.schedule.hasReminder)
              _buildScheduleItem(
                Icons.notifications,
                'Recordatorio',
                '${widget.routine.schedule.reminderMinutesBefore} min antes',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(RoutineProvider routineProvider) {
    return Row(
      children: [
        // Reiniciar rutina
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              routineProvider.resetRoutine(widget.routine.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rutina reiniciada para hoy')),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reiniciar Hoy'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Completar todas
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              _completeAllTasks(routineProvider);
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Completar Todo'),
            style: FilledButton.styleFrom(
              backgroundColor: _getColorFromHex(widget.routine.color),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _completeAllTasks(RoutineProvider routineProvider) {
    for (final task in widget.routine.tasks) {
      if (!task.completed) {
        routineProvider.toggleTaskCompletion(
          routineId: widget.routine.id,
          taskId: task.id,
          completed: true,
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todas las tareas marcadas como completadas'),
      ),
    );
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditRoutineScreen(
          childId: widget.routine.childId,
          routine: widget.routine,
        ),
      ),
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
