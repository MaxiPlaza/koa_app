import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RoutineModel {
  final String id;
  final String childId;
  final String name;
  final String description;
  final String icon;
  final String color;
  final List<RoutineTask> tasks;
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
      tasks: List<RoutineTask>.from(
        (map['tasks'] ?? []).map((x) => RoutineTask.fromMap(x)),
      ),
      schedule: RoutineSchedule.fromMap(map['schedule'] ?? {}),
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
      'tasks': tasks.map((x) => x.toMap()).toList(),
      'schedule': schedule.toMap(),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'totalCompletions': totalCompletions,
      'successRate': successRate,
    };
  }

  // Calcular progreso actual de la rutina
  double get progress {
    if (tasks.isEmpty) return 0.0;
    final completedTasks = tasks.where((task) => task.completed).length;
    return completedTasks / tasks.length;
  }

  // Verificar si la rutina está completada hoy
  bool get isCompletedToday {
    return tasks.every((task) => task.completed);
  }

  // Total de minutos estimados
  int get totalEstimatedMinutes {
    return tasks.fold(0, (sum, task) => sum + task.estimatedMinutes);
  }

  // Tareas completadas
  int get completedTasksCount {
    return tasks.where((task) => task.completed).length;
  }

  // Tareas pendientes
  int get pendingTasksCount {
    return tasks.where((task) => !task.completed).length;
  }

  // Reiniciar rutina para un nuevo día
  RoutineModel resetForNewDay() {
    return copyWith(
      tasks: tasks
          .map((task) => task.copyWith(completed: false, completedAt: null))
          .toList(),
    );
  }

  // Marcar tarea como completada
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

    return copyWith(tasks: updatedTasks);
  }

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
}

class RoutineSchedule {
  final List<int> daysOfWeek; // 1 = Lunes, 7 = Domingo
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool hasReminder;
  final int reminderMinutesBefore;

  RoutineSchedule({
    this.daysOfWeek = const [1, 2, 3, 4, 5],
    required this.startTime,
    required this.endTime,
    this.hasReminder = true,
    this.reminderMinutesBefore = 15,
  });

  factory RoutineSchedule.fromMap(Map<String, dynamic> map) {
    return RoutineSchedule(
      daysOfWeek: List<int>.from(map['daysOfWeek'] ?? []),
      startTime: TimeOfDay(
        hour: map['startTime']['hour'] ?? 8,
        minute: map['startTime']['minute'] ?? 0,
      ),
      endTime: TimeOfDay(
        hour: map['endTime']['hour'] ?? 9,
        minute: map['endTime']['minute'] ?? 0,
      ),
      hasReminder: map['hasReminder'] ?? true,
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
      final day = (today + i - 1) % 7 + 1;
      if (daysOfWeek.contains(day)) {
        return now.add(Duration(days: i));
      }
    }

    return now.add(const Duration(days: 7));
  }
}
