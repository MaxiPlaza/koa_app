import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'routine_task_model.dart';

class RoutineModel {
  final String id;
  final String childId;
  final String name;
  final String description;
  final String icon;
  final String color;
  final List<RoutineTask> tasks; // La clase RoutineTask está definida al final
  final RoutineSchedule schedule;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalCompletions;
  final double successRate;

  RoutineModel({
    required this.id,
    required this.childId,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.tasks,
    required this.schedule,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.totalCompletions = 0,
    this.successRate = 0.0,
  });

  factory RoutineModel.fromMap(Map<String, dynamic> map) {
    return RoutineModel(
      id: map['id'] ?? '',
      childId: map['childId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '📝',
      color: map['color'] ?? '#10B981',
      tasks: (map['tasks'] as List<dynamic>?)
              ?.map((t) => RoutineTask.fromMap(t))
              .toList() ??
          [],
      schedule: RoutineSchedule.fromMap(
          map['schedule'] ?? RoutineSchedule.defaultMap),
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      totalCompletions: map['totalCompletions'] ?? 0,
      successRate: (map['successRate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'schedule': schedule.toMap(),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'totalCompletions': totalCompletions,
      'successRate': successRate,
    };
  }

  // --- NUEVOS MÉTODOS DE MANIPULACIÓN DE RUTINA ---

  /// Alterna el estado de completado de una tarea y recalcula la tasa de éxito.
  RoutineModel markTaskCompleted(String taskId, bool completed) {
    final updatedTasks = tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(
          completed: completed,
          completedAt: completed ? DateTime.now() : null,
        );
      }
      return task;
    }).toList();

    // Recalcular métricas de completado de la rutina
    final completedCount = updatedTasks.where((task) => task.completed).length;
    final totalTasks = updatedTasks.length;

    // Si se completó una tarea, se incrementa el contador global.
    // Esto es un enfoque simplificado. Se podría refinar para solo contar
    // una vez por día en la lógica del repositorio/provider.
    final newTotalCompletions = totalCompletions + (completed ? 1 : 0);

    final newSuccessRate =
        totalTasks == 0 ? 0.0 : (completedCount / totalTasks) * 100.0;

    return copyWith(
      tasks: updatedTasks,
      updatedAt: DateTime.now(),
      totalCompletions: newTotalCompletions,
      successRate: newSuccessRate,
    );
  }

  /// Reinicia el estado de completado de todas las tareas para un nuevo día.
  RoutineModel resetForNewDay() {
    final resetTasks = tasks.map((task) {
      return task.copyWith(
        completed: false,
        completedAt: null,
      );
    }).toList();

    return copyWith(
      tasks: resetTasks,
      updatedAt: DateTime.now(),
      // Las métricas globales (totalCompletions, successRate) no se tocan.
    );
  }

  /// Verifica si la rutina está totalmente completada hoy.
  bool get isCompletedToday {
    return schedule.isScheduledToday &&
        tasks.isNotEmpty &&
        tasks.every((task) => task.completed);
  }

  // --- COPYWITH PARA INMUTABILIDAD ---

  RoutineModel copyWith({
    String? id,
    String? childId,
    String? name,
    String? description,
    String? icon,
    String? color,
    List<RoutineTask>? tasks,
    RoutineSchedule? schedule,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalCompletions,
    double? successRate,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      tasks: tasks ?? this.tasks,
      schedule: schedule ?? this.schedule,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      successRate: successRate ?? this.successRate,
    );
  }
  // --- GETTERS COMPUTADOS (Para UI) ---

  /// Cuenta la cantidad de tareas completadas.
  int get completedTasksCount {
    return tasks.where((task) => task.completed).length;
  }

  /// Calcula el progreso como un valor entre 0.0 y 1.0.
  double get progress {
    if (tasks.isEmpty) return 0.0;
    return completedTasksCount / tasks.length;
  }

  /// Calcula el tiempo total estimado de la rutina sumando las tareas.
  // Nota: totalEstimatedMinutes asume que tienes un campo 'estimatedMinutes' en RoutineTask
  int get totalEstimatedMinutes {
    // Necesitas asegurarte de que RoutineTask tenga un getter 'estimatedMinutes'.
    // Si no está en RoutineTask, esta parte fallará.
    // Asumiendo que RoutineTask tiene un getter int 'estimatedMinutes'.
    return tasks.fold(0, (sum, task) => sum + task.estimatedMinutes);
  }
}

class RoutineSchedule {
  final List<int> daysOfWeek; // 1 (Lunes) a 7 (Domingo)
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool hasReminder;
  final int reminderMinutesBefore;

  RoutineSchedule({
    required this.daysOfWeek,
    required this.startTime,
    required this.endTime,
    this.hasReminder = false,
    this.reminderMinutesBefore = 15,
  });

  static Map<String, dynamic> get defaultMap => {
        'daysOfWeek': [1, 2, 3, 4, 5],
        'startTime': {'hour': 8, 'minute': 0},
        'endTime': {'hour': 9, 'minute': 0},
        'hasReminder': false,
        'reminderMinutesBefore': 15,
      };

  factory RoutineSchedule.fromMap(Map<String, dynamic> map) {
    return RoutineSchedule(
      daysOfWeek: List<int>.from(map['daysOfWeek'] ?? []),
      startTime: TimeOfDay(
          hour: map['startTime']['hour'] ?? 8,
          minute: map['startTime']['minute'] ?? 0),
      endTime: TimeOfDay(
          hour: map['endTime']['hour'] ?? 9,
          minute: map['endTime']['minute'] ?? 0),
      hasReminder: map['hasReminder'] ?? false,
      reminderMinutesBefore: map['reminderMinutesBefore'] ?? 15,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'daysOfWeek': daysOfWeek,
      'startTime': {'hour': startTime.hour, 'minute': startTime.minute},
      'endTime': {'hour': endTime.hour, 'minute': endTime.minute},
      'hasReminder': hasReminder,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }

  // Verificar si está programado para un día específico
  bool isScheduledForDay(int dayOfWeek) {
    return daysOfWeek.contains(dayOfWeek);
  }

  // Verificar si está programado para hoy
  bool get isScheduledToday {
    final today = DateTime.now().weekday;
    return isScheduledForDay(today);
  }

  // Obtener próxima fecha programada
  DateTime get nextScheduledDate {
    final now = DateTime.now();
    final today = now.weekday;

    for (int i = 0; i < 7; i++) {
      // El weekday de Dart es 1 (Lunes) a 7 (Domingo).
      // (today + i - 1) % 7 + 1 calcula el día de la semana.
      final day = (today + i - 1) % 7 + 1;
      if (daysOfWeek.contains(day)) {
        return now.add(Duration(days: i));
      }
    }

    return now.add(const Duration(days: 7));
  }

  RoutineSchedule copyWith({
    List<int>? daysOfWeek,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? hasReminder,
    int? reminderMinutesBefore,
  }) {
    return RoutineSchedule(
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
    );
  }
}
