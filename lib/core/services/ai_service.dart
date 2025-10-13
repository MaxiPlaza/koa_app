import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tflite_flutter/tflite_flutter.dart';

class AIService {
  static const String _geminiApiKey =
      'TU_API_KEY_AQUI'; // Reemplazar con key real
  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  // Modelo de TensorFlow Lite para análisis offline
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/child_analysis.tflite',
      );
      _isModelLoaded = true;
      print('✅ Modelo de IA cargado exitosamente');
    } catch (e) {
      print('⚠️ Error cargando modelo TensorFlow Lite: $e');
      _isModelLoaded = false;
    }
  }

  // 🧠 Análisis de progreso OFFLINE usando TensorFlow Lite
  Map<String, double> analyzeProgressOffline(List<GameSession> sessions) {
    if (!_isModelLoaded || _interpreter == null) {
      return _getDefaultAnalysis();
    }

    try {
      // Preparar datos de entrada para el modelo
      final input = _prepareInputData(sessions);
      final output = List.filled(1 * 6, 0.0).reshape([1, 6]); // 6 métricas

      _interpreter!.run(input, output);

      return {
        'cognitive_skills': output[0][0].clamp(0.0, 1.0),
        'emotional_intelligence': output[0][1].clamp(0.0, 1.0),
        'attention_span': output[0][2].clamp(0.0, 1.0),
        'memory_capacity': output[0][3].clamp(0.0, 1.0),
        'pattern_recognition': output[0][4].clamp(0.0, 1.0),
        'social_understanding': output[0][5].clamp(0.0, 1.0),
      };
    } catch (e) {
      print('❌ Error en análisis offline: $e');
      return _getDefaultAnalysis();
    }
  }

  List<List<double>> _prepareInputData(List<GameSession> sessions) {
    if (sessions.isEmpty) {
      return List.filled(1 * 8, 0.5).reshape([1, 8]);
    }

    // Tomar las últimas 10 sesiones para el análisis
    final recentSessions = sessions.take(10).toList();
    final features = <double>[];

    // 1. Eficiencia general (score/tiempo)
    final avgEfficiency =
        recentSessions
            .map(
              (session) =>
                  session.score / session.durationInMinutes.clamp(1, 60),
            )
            .reduce((a, b) => a + b) /
        recentSessions.length;
    features.add((avgEfficiency / 50).clamp(0.0, 1.0)); // Normalizar

    // 2. Tasa de finalización
    final completionRate =
        recentSessions.where((s) => s.completed).length / recentSessions.length;
    features.add(completionRate);

    // 3. Consistencia en el desempeño
    final scores = recentSessions.map((s) => s.score.toDouble()).toList();
    final consistency = _calculateConsistency(scores);
    features.add(consistency);

    // 4. Mejora a lo largo del tiempo
    final improvement = _calculateImprovement(scores);
    features.add(improvement.clamp(0.0, 1.0));

    // 5. Distribución por tipo de juego
    final gameTypeDistribution = _calculateGameTypeDistribution(recentSessions);
    features.addAll(gameTypeDistribution);

    // Rellenar con valores predeterminados si es necesario
    while (features.length < 8) {
      features.add(0.5);
    }

    return [features.sublist(0, 8)].reshape([1, 8]);
  }

  double _calculateConsistency(List<double> scores) {
    if (scores.length < 2) return 0.5;

    final mean = scores.reduce((a, b) => a + b) / scores.length;
    final variance =
        scores.map((s) => pow(s - mean, 2)).reduce((a, b) => a + b) /
        scores.length;
    final standardDeviation = sqrt(variance);

    // Convertir a métrica de consistencia (menor desviación = mayor consistencia)
    return (1.0 - (standardDeviation / 500)).clamp(0.0, 1.0);
  }

  double _calculateImprovement(List<double> scores) {
    if (scores.length < 3) return 0.5;

    final firstHalf = scores.sublist(0, scores.length ~/ 2);
    final secondHalf = scores.sublist(scores.length ~/ 2);

    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

    return ((secondAvg - firstAvg) / 100).clamp(0.0, 1.0);
  }

  List<double> _calculateGameTypeDistribution(List<GameSession> sessions) {
    final distribution = <String, int>{};

    for (final session in sessions) {
      distribution[session.activityId] =
          (distribution[session.activityId] ?? 0) + 1;
    }

    // Normalizar a 3 características
    return [
      (distribution['memory_1'] ?? 0) / sessions.length,
      (distribution['emotional_1'] ?? 0) / sessions.length,
      (distribution['pattern_1'] ?? 0) / sessions.length,
    ];
  }

  Map<String, double> _getDefaultAnalysis() {
    return {
      'cognitive_skills': 0.5,
      'emotional_intelligence': 0.5,
      'attention_span': 0.5,
      'memory_capacity': 0.5,
      'pattern_recognition': 0.5,
      'social_understanding': 0.5,
    };
  }

  // 🎭 Generar historias personalizadas usando Gemini API
  Future<String> generatePersonalizedStory({
    required String childName,
    required String theme,
    required String learningStyle,
    required Map<String, double> strengths,
  }) async {
    try {
      final prompt =
          '''
Eres un asistente educativo especializado en niños neurodivergentes.
Genera una historia educativa personalizada con estas características:

- Niño: $childName
- Tema central: $theme
- Estilo de aprendizaje: $learningStyle
- Fortalezas detectadas: ${_formatStrengths(strengths)}

La historia debe:
- Ser corta (150-250 palabras)
- Incluir elementos interactivos simples
- Ser positiva, motivadora y validating
- Enseñar una habilidad social o emocional
- Usar lenguaje claro y concreto
- Incluir ejemplos visuales
- Tener un mensaje claro sobre aceptación y crecimiento

Formato: Inicia con "¡Hola $childName!" y termina con una pregunta reflexiva.

Historia:
''';

      final response = await http.post(
        Uri.parse('$_geminiBaseUrl?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.8,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final story = data['candidates'][0]['content']['parts'][0]['text'];
        return _cleanStory(story, childName);
      } else {
        throw Exception('Error de API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error generando historia: $e');
      return _getFallbackStory(childName, theme);
    }
  }

  String _formatStrengths(Map<String, double> strengths) {
    final topStrengths = strengths.entries
        .where((entry) => entry.value > 0.7)
        .take(2)
        .map((entry) => entry.key)
        .toList();

    return topStrengths.isEmpty ? 'gran potencial' : topStrengths.join(' y ');
  }

  String _cleanStory(String story, String childName) {
    // Limpiar y formatear la historia
    return story
        .replaceAll('**', '') // Remover markdown
        .replaceAll(RegExp(r'\n\s*\n'), '\n\n') // Normalizar saltos de línea
        .trim();
  }

  String _getFallbackStory(String childName, String theme) {
    return '''
¡Hola $childName! 

Esta es una historia especial sobre $theme, creada especialmente para ti.

Había una vez un explorador valiente llamado $childName que descubrió un mundo mágico lleno de aprendizajes. En cada aventura, $childName usaba sus habilidades únicas para resolver acertijos y ayudar a sus amigos.

Un día, mientras exploraba el Bosque de las Emociones, $childName encontró a un pequeño animal que parecía triste. En lugar de pasar de largo, $childName se detuvo y preguntó: "¿Estás bien?".

El animalito explicó que se sentía solo. $childName recordó que a veces todos nos sentimos así, y decidió ser su amigo. Juntos descubrieron que compartir momentos hace todo más divertido.

Al final del día, $childName aprendió que las pequeñas acciones de bondad pueden hacer una gran diferencia. 

¿Qué acto de bondad podrías hacer tú hoy?
''';
  }

  // 🎯 Generar recomendaciones inteligentes
  Future<List<AIRecommendation>> generateRecommendations({
    required Map<String, double> analysis,
    required String childName,
    required String learningStyle,
    required List<GameSession> recentSessions,
  }) async {
    final recommendations = <AIRecommendation>[];

    // Recomendaciones basadas en fortalezas y áreas de oportunidad
    if (analysis['memory_capacity']! < 0.4) {
      recommendations.add(
        AIRecommendation(
          type: RecommendationType.memory,
          priority: Priority.high,
          title: 'Fortalecer Memoria',
          description: 'Juegos de memoria con secuencias cortas y repetitivas',
          suggestedActivities: ['memory_1'],
          reason: 'Oportunidad de desarrollo en retención visual',
        ),
      );
    }

    if (analysis['emotional_intelligence']! < 0.4) {
      recommendations.add(
        AIRecommendation(
          type: RecommendationType.emotional,
          priority: Priority.high,
          title: 'Desarrollar Inteligencia Emocional',
          description: 'Actividades para identificar y expresar emociones',
          suggestedActivities: ['emotional_1'],
          reason: 'Beneficiaría el reconocimiento y gestión emocional',
        ),
      );
    }

    if (analysis['pattern_recognition']! > 0.7) {
      recommendations.add(
        AIRecommendation(
          type: RecommendationType.cognitive,
          priority: Priority.medium,
          title: 'Aprovechar Fortaleza en Patrones',
          description:
              'Introducir secuencias más complejas para mantener el interés',
          suggestedActivities: ['pattern_1'],
          reason: 'Fuerte habilidad natural que puede potenciarse',
        ),
      );
    }

    // Recomendación basada en estilo de aprendizaje
    if (learningStyle == 'visual') {
      recommendations.add(
        AIRecommendation(
          type: RecommendationType.learningStyle,
          priority: Priority.medium,
          title: 'Aprovechar Estilo Visual',
          description:
              'Incluir más elementos gráficos y colores en las actividades',
          suggestedActivities: ['memory_1', 'pattern_1'],
          reason: 'Coincide con tu estilo de aprendizaje preferido',
        ),
      );
    }

    // Recomendación de balance si hay mucho de un tipo de juego
    final activityDistribution = _calculateActivityDistribution(recentSessions);
    if (activityDistribution['memory_1']! > 0.6) {
      recommendations.add(
        AIRecommendation(
          type: RecommendationType.balance,
          priority: Priority.low,
          title: 'Variedad de Actividades',
          description:
              'Probar juegos diferentes para desarrollar habilidades diversas',
          suggestedActivities: ['emotional_1', 'pattern_1'],
          reason: 'Balancear el desarrollo de múltiples habilidades',
        ),
      );
    }

    // Ordenar por prioridad
    recommendations.sort(
      (a, b) => b.priority.index.compareTo(a.priority.index),
    );

    return recommendations;
  }

  Map<String, double> _calculateActivityDistribution(
    List<GameSession> sessions,
  ) {
    final distribution = <String, double>{};
    final total = sessions.length.toDouble();

    for (final session in sessions) {
      distribution[session.activityId] =
          (distribution[session.activityId] ?? 0) + 1;
    }

    // Normalizar
    for (final key in distribution.keys) {
      distribution[key] = distribution[key]! / total;
    }

    return distribution;
  }

  // 🎮 Calcular dificultad adaptativa para juegos
  int calculateAdaptiveDifficulty({
    required Map<String, double> analysis,
    required String gameType,
    required List<GameSession> gameHistory,
  }) {
    double baseDifficulty;

    switch (gameType) {
      case 'memory':
        baseDifficulty = analysis['memory_capacity']! * 4;
        break;
      case 'emotions':
        baseDifficulty = analysis['emotional_intelligence']! * 3;
        break;
      case 'patterns':
        baseDifficulty = analysis['pattern_recognition']! * 5;
        break;
      default:
        baseDifficulty = 2.0;
    }

    // Ajustar basado en historial de desempeño
    final performanceAdjustment = _calculatePerformanceAdjustment(
      gameHistory,
      gameType,
    );
    baseDifficulty += performanceAdjustment;

    return baseDifficulty.clamp(1, 5).round();
  }

  double _calculatePerformanceAdjustment(
    List<GameSession> history,
    String gameType,
  ) {
    final gameSessions = history
        .where((s) => s.activityId.contains(gameType))
        .toList();
    if (gameSessions.length < 3) return 0.0;

    final recentSessions = gameSessions.take(5).toList();
    final avgScore =
        recentSessions.map((s) => s.score).reduce((a, b) => a + b) /
        recentSessions.length;
    final completionRate =
        recentSessions.where((s) => s.completed).length / recentSessions.length;

    // Si tiene buen desempeño, aumentar dificultad; si no, mantener o disminuir
    if (avgScore > 700 && completionRate > 0.8) return 0.5;
    if (avgScore < 300 && completionRate < 0.4) return -0.5;

    return 0.0;
  }

  void dispose() {
    _interpreter?.close();
  }
}

class AIRecommendation {
  final RecommendationType type;
  final Priority priority;
  final String title;
  final String description;
  final List<String> suggestedActivities;
  final String reason;

  AIRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.suggestedActivities,
    required this.reason,
  });
}

enum RecommendationType {
  memory,
  emotional,
  cognitive,
  social,
  learningStyle,
  balance,
}

enum Priority {
  low, // Sugerencia opcional
  medium, // Recomendación beneficiosa
  high, // Recomendación importante
}
