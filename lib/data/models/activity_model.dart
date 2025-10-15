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
