import 'package:cloud_firestore/cloud_firestore.dart';

class ChildModel {
  final String id;
  final String name;
  final int age;
  final String? syndrome;
  final String learningStyle;
  final String parentId;
  final List<String> professionalIds;
  final ChildProgress progress;
  final ChildSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChildModel({
    required this.id,
    required this.name,
    required this.age,
    this.syndrome,
    required this.learningStyle,
    required this.parentId,
    this.professionalIds = const [],
    required this.progress,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      syndrome: map['syndrome'],
      learningStyle: map['learningStyle'] ?? 'visual',
      parentId: map['parentId'] ?? '',
      professionalIds: List<String>.from(map['professionalIds'] ?? []),
      progress: ChildProgress.fromMap(map['progress'] ?? {}),
      settings: ChildSettings.fromMap(map['settings'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'syndrome': syndrome,
      'learningStyle': learningStyle,
      'parentId': parentId,
      'professionalIds': professionalIds,
      'progress': progress.toMap(),
      'settings': settings.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class ChildProgress {
  final Map<String, double> skillLevels; // matematica: 0.8, lenguaje: 0.6
  final int totalPlayTime; // en minutos
  final int totalStars;
  final DateTime lastSession;
  final List<Session> recentSessions;

  ChildProgress({
    this.skillLevels = const {},
    this.totalPlayTime = 0,
    this.totalStars = 0,
    required this.lastSession,
    this.recentSessions = const [],
  });

  factory ChildProgress.fromMap(Map<String, dynamic> map) {
    return ChildProgress(
      skillLevels: Map<String, double>.from(map['skillLevels'] ?? {}),
      totalPlayTime: map['totalPlayTime'] ?? 0,
      totalStars: map['totalStars'] ?? 0,
      lastSession: (map['lastSession'] as Timestamp).toDate(),
      recentSessions: List<Session>.from(
        (map['recentSessions'] ?? []).map((x) => Session.fromMap(x)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'skillLevels': skillLevels,
      'totalPlayTime': totalPlayTime,
      'totalStars': totalStars,
      'lastSession': Timestamp.fromDate(lastSession),
      'recentSessions': recentSessions.map((x) => x.toMap()).toList(),
    };
  }
}

class ChildSettings {
  final String difficultyLevel;
  final List<String> focusAreas;
  final double sensitivity;
  final String feedbackType;
  final bool reduceAnimations;
  final bool disableLoudSounds;

  ChildSettings({
    this.difficultyLevel = 'medium',
    this.focusAreas = const [],
    this.sensitivity = 0.5,
    this.feedbackType = 'visual',
    this.reduceAnimations = false,
    this.disableLoudSounds = false,
  });

  factory ChildSettings.fromMap(Map<String, dynamic> map) {
    return ChildSettings(
      difficultyLevel: map['difficultyLevel'] ?? 'medium',
      focusAreas: List<String>.from(map['focusAreas'] ?? []),
      sensitivity: (map['sensitivity'] ?? 0.5).toDouble(),
      feedbackType: map['feedbackType'] ?? 'visual',
      reduceAnimations: map['reduceAnimations'] ?? false,
      disableLoudSounds: map['disableLoudSounds'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'difficultyLevel': difficultyLevel,
      'focusAreas': focusAreas,
      'sensitivity': sensitivity,
      'feedbackType': feedbackType,
      'reduceAnimations': reduceAnimations,
      'disableLoudSounds': disableLoudSounds,
    };
  }
}

class Session {
  final String? activityName;
  final String? activityId; // <--- CAMBIO: Agregado para GameSession mapping
  final DateTime? date;
  final int? duration; // en minutos
  final double? score;
  final bool? completed; // <--- CAMBIO: Agregado para cálculo de completionRate
  final Map<String, dynamic>? metadata;

  Session({
    this.activityName,
    this.activityId, // <--- Actualizar constructor
    this.date,
    this.duration,
    this.score,
    this.completed, // <--- Actualizar constructor
    this.metadata,
  });

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      activityName: map['activityName'],
      activityId: map['activityId'], // <--- Actualizar fromMap
      date: map['date'] != null ? (map['date'] as Timestamp).toDate() : null,
      duration: map['duration'],
      score: (map['score'] ?? 0.0).toDouble(),
      completed: map['completed'], // <--- Actualizar fromMap
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'activityName': activityName,
      'activityId': activityId,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'duration': duration,
      'score': score,
      'completed': completed,
      'metadata': metadata,
    };
  }
}
