class ActivityModel {
  final String id;
  final String name;
  final String description;
  final String category; // 'memory', 'emotions', 'patterns'
  final int difficulty;
  final int estimatedDuration; // minutos
  final String instructions;
  final String assetPath;
  final List<String> skills; // habilidades que desarrolla
  final int minAge;
  final int maxAge;

  ActivityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.estimatedDuration,
    required this.instructions,
    required this.assetPath,
    required this.skills,
    required this.minAge,
    required this.maxAge,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? 1,
      estimatedDuration: map['estimatedDuration'] ?? 10,
      instructions: map['instructions'] ?? '',
      assetPath: map['assetPath'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      minAge: map['minAge'] ?? 3,
      maxAge: map['maxAge'] ?? 12,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'estimatedDuration': estimatedDuration,
      'instructions': instructions,
      'assetPath': assetPath,
      'skills': skills,
      'minAge': minAge,
      'maxAge': maxAge,
    };
  }
}

class GameSession {
  final String id;
  final String childId;
  final String activityId;
  final DateTime startTime;
  final DateTime endTime;
  final int score;
  final int stars;
  final Map<String, dynamic> performance; // métricas específicas del juego
  final bool completed;

  GameSession({
    required this.id,
    required this.childId,
    required this.activityId,
    required this.startTime,
    required this.endTime,
    required this.score,
    required this.stars,
    required this.performance,
    required this.completed,
  });

  int get durationInMinutes => endTime.difference(startTime).inMinutes;

  factory GameSession.fromMap(Map<String, dynamic> map) {
    return GameSession(
      id: map['id'] ?? '',
      childId: map['childId'] ?? '',
      activityId: map['activityId'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      score: map['score'] ?? 0,
      stars: map['stars'] ?? 0,
      performance: Map<String, dynamic>.from(map['performance'] ?? {}),
      completed: map['completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'activityId': activityId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'score': score,
      'stars': stars,
      'performance': performance,
      'completed': completed,
    };
  }
}
