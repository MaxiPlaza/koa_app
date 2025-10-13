class RoutineTask {
  final String id;
  final String title;
  final String description;
  final String? icon;
  final int estimatedMinutes;
  final bool completed;
  final DateTime? completedAt;
  final int order;
  final String? audioInstruction;
  final String? visualAid;
  final bool isSkippable;
  final int difficulty; // 1-5

  RoutineTask({
    required this.id,
    required this.title,
    required this.description,
    this.icon,
    required this.estimatedMinutes,
    this.completed = false,
    this.completedAt,
    required this.order,
    this.audioInstruction,
    this.visualAid,
    this.isSkippable = false,
    this.difficulty = 1,
  });

  factory RoutineTask.fromMap(Map<String, dynamic> map) {
    return RoutineTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'],
      estimatedMinutes: map['estimatedMinutes'] ?? 5,
      completed: map['completed'] ?? false,
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
      order: map['order'] ?? 0,
      audioInstruction: map['audioInstruction'],
      visualAid: map['visualAid'],
      isSkippable: map['isSkippable'] ?? false,
      difficulty: map['difficulty'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'estimatedMinutes': estimatedMinutes,
      'completed': completed,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'order': order,
      'audioInstruction': audioInstruction,
      'visualAid': visualAid,
      'isSkippable': isSkippable,
      'difficulty': difficulty,
    };
  }

  // Tiempo transcurrido desde completada (en minutos)
  int? get minutesSinceCompletion {
    if (completedAt == null) return null;
    return DateTime.now().difference(completedAt!).inMinutes;
  }

  // Verificar si fue completada hoy
  bool get completedToday {
    if (completedAt == null) return false;
    final now = DateTime.now();
    final completed = completedAt!;
    return now.year == completed.year &&
        now.month == completed.month &&
        now.day == completed.day;
  }

  RoutineTask copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? estimatedMinutes,
    bool? completed,
    DateTime? completedAt,
    int? order,
    String? audioInstruction,
    String? visualAid,
    bool? isSkippable,
    int? difficulty,
  }) {
    return RoutineTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      order: order ?? this.order,
      audioInstruction: audioInstruction ?? this.audioInstruction,
      visualAid: visualAid ?? this.visualAid,
      isSkippable: isSkippable ?? this.isSkippable,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

// Rutinas predefinidas para neurodivergencias comunes
class PredefinedRoutines {
  static List<RoutineTask> get morningRoutineTEA {
    return [
      RoutineTask(
        id: 'wake_up',
        title: 'Despertarse',
        description: 'Abrir los ojos y estirarse',
        icon: '⏰',
        estimatedMinutes: 5,
        order: 1,
        difficulty: 1,
      ),
      RoutineTask(
        id: 'brush_teeth',
        title: 'Cepillarse los dientes',
        description: 'Usar pasta dental y cepillo',
        icon: '🦷',
        estimatedMinutes: 5,
        order: 2,
        difficulty: 2,
      ),
      RoutineTask(
        id: 'get_dressed',
        title: 'Vestirse',
        description: 'Ponerse la ropa del día',
        icon: '👕',
        estimatedMinutes: 10,
        order: 3,
        difficulty: 3,
      ),
      RoutineTask(
        id: 'eat_breakfast',
        title: 'Desayunar',
        description: 'Comer algo nutritivo',
        icon: '🍳',
        estimatedMinutes: 20,
        order: 4,
        difficulty: 2,
      ),
    ];
  }

  static List<RoutineTask> get eveningRoutineTDAH {
    return [
      RoutineTask(
        id: 'homework',
        title: 'Tareas escolares',
        description: 'Completar deberes del colegio',
        icon: '📚',
        estimatedMinutes: 30,
        order: 1,
        difficulty: 4,
        isSkippable: true,
      ),
      RoutineTask(
        id: 'play_time',
        title: 'Tiempo de juego',
        description: 'Jugar libre o estructurado',
        icon: '🎮',
        estimatedMinutes: 30,
        order: 2,
        difficulty: 1,
      ),
      RoutineTask(
        id: 'bath_time',
        title: 'Bañarse',
        description: 'Ducha o baño relajante',
        icon: '🚿',
        estimatedMinutes: 15,
        order: 3,
        difficulty: 2,
      ),
      RoutineTask(
        id: 'brush_teeth_night',
        title: 'Cepillarse los dientes',
        description: 'Higiene antes de dormir',
        icon: '🦷',
        estimatedMinutes: 5,
        order: 4,
        difficulty: 2,
      ),
      RoutineTask(
        id: 'bedtime_story',
        title: 'Cuento antes de dormir',
        description: 'Leer o escuchar una historia',
        icon: '📖',
        estimatedMinutes: 10,
        order: 5,
        difficulty: 1,
      ),
    ];
  }

  static List<RoutineTask> get sensoryRoutine {
    return [
      RoutineTask(
        id: 'deep_pressure',
        title: 'Presión profunda',
        description: 'Abrazos fuertes o manta con peso',
        icon: '🤗',
        estimatedMinutes: 5,
        order: 1,
        difficulty: 1,
      ),
      RoutineTask(
        id: 'calming_breathing',
        title: 'Respiración calmante',
        description: 'Inhalar y exhalar lentamente',
        icon: '🌬️',
        estimatedMinutes: 3,
        order: 2,
        difficulty: 2,
      ),
      RoutineTask(
        id: 'sensory_play',
        title: 'Juego sensorial',
        description: 'Tocar diferentes texturas',
        icon: '👐',
        estimatedMinutes: 10,
        order: 3,
        difficulty: 1,
      ),
    ];
  }
}
