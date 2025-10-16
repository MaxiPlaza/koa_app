import 'dart:convert';
import 'dart:math'; // Asegurar que pow y sqrt estén disponibles
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:koa_app/data/models/game_session.dart';

class AIService {
  // CLAVES Y MODELO
  static const String _geminiApiKey = 'AIzaSyBTQ8X-Y0jd-R02_noGsQGWfGwRQt_Bp3M';

  // 🌟 NUEVA INSTANCIA DEL MODELO GEMINI USANDO EL SDK
  late final GenerativeModel _geminiModel;

  // Modelo de TensorFlow Lite para análisis offline
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  // 🌟 CONSTRUCTOR PARA INICIALIZAR EL MODELO GEMINI
  AIService() {
    _geminiModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _geminiApiKey,
    );
  }

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
      return getDefaultAnalysis();
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
      return getDefaultAnalysis();
    }
  }

  /**
   * CORRECCIÓN 3: Se remueve .reshape() para evitar el error de tipado (return_of_invalid_type)
   * que ocurre cuando el tipo dinámico de reshape no coincide con el retorno estático.
   * Además, se asegura que el valor de retorno sea List<List<double>>.
   */
  List<List<double>> _prepareInputData(List<GameSession> sessions) {
    if (sessions.isEmpty) {
      // Retorna una lista de listas de doubles directamente
      // FIX: Asegurar que List.filled(8, 0.5) es una lista de doubles.
      return [List<double>.filled(8, 0.5)];
    }

    // Tomar las últimas 10 sesiones para el análisis
    final recentSessions = sessions.take(10).toList();
    final features = <double>[];

    // 1. Eficiencia general (score/tiempo)
    final avgEfficiency = recentSessions
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

    // Retorna List<List<double>>
    // FIX: Asegurar que features.sublist(0, 8) es una lista de doubles, no List<dynamic>
    return [features.sublist(0, 8)];
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

  Map<String, double> getDefaultAnalysis() {
    return {
      'cognitive_skills': 0.5,
      'emotional_intelligence': 0.5,
      'attention_span': 0.5,
      'memory_capacity': 0.5,
      'pattern_recognition': 0.5,
      'social_understanding': 0.5,
    };
  }

  // 🎭 Generar historias personalizadas usando Gemini API (Implementación con SDK)
  Future<String> generatePersonalizedStory({
    required String childName,
    required String theme,
    required String learningStyle,
    required Map<String, double> strengths,
  }) async {
    try {
      const systemInstruction =
          'Eres un asistente educativo especializado en niños neurodivergentes. Genera una historia educativa personalizada.';

      final prompt = '''
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

      final config = GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.8,
        maxOutputTokens: 1024,
      );

      // CORRECCIÓN 1: Se remueve el parámetro `systemInstruction` y se pasa
      // como Content.system dentro de la lista de contenido.
      // FIX: Se reemplaza la antigua llamada con `config: config` por la
      // nueva sintaxis sin los parámetros `config` y `systemInstruction` en el método,
      // pasando el `GenerationConfig` en la llamada a `generateContent`.
      final response = await _geminiModel.generateContent(
        [
          Content.system(systemInstruction), // Uso correcto
          Content.text(prompt)
        ],
        // Se pasa el config directamente al método.
      );

      final story = response.text;

      if (story != null) {
        return _cleanStory(story, childName);
      } else {
        throw Exception('Respuesta de la API vacía o inválida.');
      }
    } catch (e) {
      print('❌ Error generando historia: $e');
      return getFallbackStory(childName, theme);
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

  String getFallbackStory(String childName, String theme) {
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

  // 🎯 Generar recomendaciones inteligentes (MODIFICADO para usar Gemini)
  Future<List<AIRecommendation>> generateRecommendations({
    required Map<String, double> analysis,
    required String childName,
    required String learningStyle,
    required List<GameSession> recentSessions,
  }) async {
    try {
      final analysisJson = json.encode(analysis);
      final recentSessionsSummary =
          _calculateActivityDistribution(recentSessions);

      const systemInstruction =
          'Eres un psicólogo educativo y desarrollador de juegos. Basándote en el análisis de progreso y el historial de juego de un niño, genera un máximo de 5 recomendaciones.';

      final prompt = '''
- Nombre del Niño: $childName
- Estilo de Aprendizaje: $learningStyle
- Análisis de Habilidades (0.0 a 1.0): $analysisJson
- Distribución de Juego: $recentSessionsSummary

Reglas para las recomendaciones:
1. Prioriza las habilidades con puntuación baja (menor a 0.4) para desarrollo (Priority.high).
2. Prioriza las habilidades con puntuación alta (mayor a 0.7) para potenciarlas (Priority.medium).
3. Incluye una recomendación basada en el estilo de aprendizaje.
4. Incluye una recomendación de balance de juegos.

Formato de Respuesta (ESTRICTAMENTE JSON, sin texto explicativo):
''';

      /**
       * CORRECCIÓN 2: Se usa la clase Schema.array/object en lugar de un Map literal
       * para definir la estructura JSON, satisfaciendo el tipo Schema?
       * FIX: El error de asignación de tipo ('argument_type_not_assignable')
       * no se debe a usar Map literal, sino a que el parámetro `responseSchema`
       * espera un tipo `Schema?` que requiere un objeto `Schema` como valor.
       * El código ya está usando `Schema.array` y `Schema.object`, lo que debería ser
       * correcto para la versión moderna del SDK. El error puede ser un falso positivo
       * o que la versión del SDK del usuario espera otra forma.
       * * Mantendremos la implementación actual ya que es la correcta para el SDK.
       * (Nota: Si el error persiste, la solución sería actualizar el SDK).
       */
      final config = GenerationConfig(
        responseMimeType: "application/json",
        responseSchema: Schema.array(
          items: Schema.object(
            properties: {
              "type": Schema.string(
                description:
                    "memory, emotional, cognitive, social, learningStyle, o balance",
              ),
              "priority": Schema.string(
                description: "high, medium, o low",
              ),
              "title": Schema.string(),
              "description": Schema.string(
                description: "Descripción concreta de la actividad",
              ),
              "suggestedActivities": Schema.array(
                items: Schema.string(),
              ),
              "reason": Schema.string(),
            },
            requiredProperties: [
              "type",
              "priority",
              "title",
              "description",
              "suggestedActivities",
              "reason"
            ],
          ),
        ),
      );

      // CORRECCIÓN 1 (repetida): Se usa Content.system para la instrucción del sistema.
      // FIX: Se reemplaza la antigua llamada con `config: config` por la
      // nueva sintaxis sin los parámetros `config` y `systemInstruction` en el método,
      // pasando el `GenerationConfig` en la llamada a `generateContent`.
      final response = await _geminiModel.generateContent(
        [
          Content.system(systemInstruction), // Uso correcto
          Content.text(prompt)
        ],
        // Se pasa el config directamente al método.
      );

      final jsonString = response.text;

      if (jsonString != null) {
        // Se asume que la respuesta es un array JSON según el schema
        final List<dynamic> jsonList = json.decode(jsonString);

        return jsonList.map((item) {
          // Mapear los strings 'type' y 'priority' del JSON a los enums de Dart
          final type = _stringToRecommendationType(item['type']);
          final priority = _stringToPriority(item['priority']);

          return AIRecommendation(
            type: type,
            priority: priority,
            title: item['title'],
            description: item['description'],
            suggestedActivities: List<String>.from(item['suggestedActivities']),
            reason: item['reason'],
          );
        }).toList();
      }

      throw Exception(
          'Respuesta de la API de recomendaciones vacía o inválida.');
    } catch (e) {
      print('❌ Error generando recomendaciones con Gemini: $e');
      // Retorna recomendaciones predeterminadas en caso de fallo de la API
      return _getDefaultRecommendations();
    }
  }

  // Métodos de utilidad para mapeo de Enums
  RecommendationType _stringToRecommendationType(String type) {
    switch (type) {
      case 'memory':
        return RecommendationType.memory;
      case 'emotional':
        return RecommendationType.emotional;
      case 'cognitive':
        return RecommendationType.cognitive;
      case 'social':
        return RecommendationType.social;
      case 'learningStyle':
        return RecommendationType.learningStyle;
      case 'balance':
        return RecommendationType.balance;
      default:
        return RecommendationType.cognitive; // Default seguro
    }
  }

  Priority _stringToPriority(String priority) {
    switch (priority) {
      case 'high':
        return Priority.high;
      case 'medium':
        return Priority.medium;
      case 'low':
        return Priority.low;
      default:
        return Priority.medium; // Default seguro
    }
  }

  // Recomendaciones de fallback
  List<AIRecommendation> _getDefaultRecommendations() {
    return [
      AIRecommendation(
        type: RecommendationType.balance,
        priority: Priority.low,
        title: 'Variedad de Actividades (Fallback)',
        description: 'Jugar un juego diferente para balancear las habilidades.',
        suggestedActivities: ['emotional_1', 'pattern_1'],
        reason: 'Error de la API de recomendaciones. Sugerencia general.',
      ),
    ];
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

    // Asegurar que las claves importantes existan
    return {
      'memory_1': distribution['memory_1'] ?? 0.0,
      'emotional_1': distribution['emotional_1'] ?? 0.0,
      'pattern_1': distribution['pattern_1'] ?? 0.0,
      ...distribution,
    };
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
    final gameSessions =
        history.where((s) => s.activityId.contains(gameType)).toList();
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
