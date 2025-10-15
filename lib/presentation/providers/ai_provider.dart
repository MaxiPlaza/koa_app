import 'package:flutter/foundation.dart';
import 'package:koa_app/core/services/ai_service.dart';
import 'package:koa_app/data/models/game_session.dart';
import 'package:koa_app/data/models/child_model.dart';

class AIProvider with ChangeNotifier {
  final AIService _aiService = AIService();

  bool _isAnalyzing = false;
  bool _isModelLoaded = false;
  Map<String, double> _childAnalysis = {};
  List<AIRecommendation> _recommendations = [];
  String _generatedStory = '';
  Map<String, int> _adaptiveDifficulties = {};

  // Getters
  bool get isAnalyzing => _isAnalyzing;
  bool get isModelLoaded => _isModelLoaded;
  Map<String, double> get childAnalysis => _childAnalysis;
  List<AIRecommendation> get recommendations => _recommendations;
  String get generatedStory => _generatedStory;
  Map<String, int> get adaptiveDifficulties => _adaptiveDifficulties;

  AIProvider() {
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    try {
      await _aiService.loadModel();
      _isModelLoaded = true;
      notifyListeners();
    } catch (e) {
      print('❌ Error inicializando IA: $e');
      _isModelLoaded = false;
    }
  }

  // 🧠 Análisis completo del progreso del niño
  Future<void> analyzeChildProgress({
    required ChildModel child,
    required List<GameSession> sessions,
  }) async {
    if (!_isModelLoaded) {
      print('⚠️ Modelo de IA no cargado, usando análisis básico');
      return;
    }

    _isAnalyzing = true;
    notifyListeners();

    try {
      // 1. Análisis offline con TensorFlow Lite
      _childAnalysis = _aiService.analyzeProgressOffline(sessions);

      // 2. Generar recomendaciones personalizadas
      _recommendations = await _aiService.generateRecommendations(
        analysis: _childAnalysis,
        childName: child.name,
        learningStyle: child.learningStyle,
        recentSessions: sessions.take(10).toList(),
      );

      // 3. Calcular dificultades adaptativas para cada juego
      _calculateAdaptiveDifficulties(sessions);

      print('✅ Análisis de IA completado para ${child.name}');
      print('📊 Análisis: $_childAnalysis');
      print('💡 Recomendaciones: ${_recommendations.length}');
    } catch (e) {
      print('❌ Error en análisis de IA: $e');
      _childAnalysis = _aiService.getDefaultAnalysis();
      _recommendations = [];
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  void _calculateAdaptiveDifficulties(List<GameSession> sessions) {
    _adaptiveDifficulties = {
      'memory': _aiService.calculateAdaptiveDifficulty(
        analysis: _childAnalysis,
        gameType: 'memory',
        gameHistory: sessions,
      ),
      'emotions': _aiService.calculateAdaptiveDifficulty(
        analysis: _childAnalysis,
        gameType: 'emotions',
        gameHistory: sessions,
      ),
      'patterns': _aiService.calculateAdaptiveDifficulty(
        analysis: _childAnalysis,
        gameType: 'patterns',
        gameHistory: sessions,
      ),
    };
  }

  // 📖 Generar historia personalizada
  Future<void> generatePersonalizedStory({
    required String childName,
    required String theme,
    required String learningStyle,
  }) async {
    _isAnalyzing = true;
    notifyListeners();

    try {
      _generatedStory = await _aiService.generatePersonalizedStory(
        childName: childName,
        theme: theme,
        learningStyle: learningStyle,
        strengths: _childAnalysis,
      );
    } catch (e) {
      print('❌ Error generando historia: $e');
      _generatedStory = _aiService.getFallbackStory(childName, theme);
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  // 🎮 Obtener dificultad adaptativa para un juego específico
  int getAdaptiveDifficulty(String gameType) {
    return _adaptiveDifficulties[gameType] ?? 2; // Default medium
  }

  // 📊 Obtener resumen del análisis para display
  Map<String, dynamic> getAnalysisSummary() {
    final topStrength = _childAnalysis.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    final areaForGrowth = _childAnalysis.entries.reduce(
      (a, b) => a.value < b.value ? a : b,
    );

    return {
      'top_strength': {
        'name': _formatSkillName(topStrength.key),
        'value': topStrength.value,
        'description': _getStrengthDescription(topStrength.key),
      },
      'area_for_growth': {
        'name': _formatSkillName(areaForGrowth.key),
        'value': areaForGrowth.value,
        'description': _getGrowthDescription(areaForGrowth.key),
      },
      'overall_progress': _calculateOverallProgress(),
      'recommendations_count': _recommendations.length,
    };
  }

  String _formatSkillName(String key) {
    final names = {
      'cognitive_skills': 'Habilidades Cognitivas',
      'emotional_intelligence': 'Inteligencia Emocional',
      'attention_span': 'Atención y Concentración',
      'memory_capacity': 'Memoria y Retención',
      'pattern_recognition': 'Reconocimiento de Patrones',
      'social_understanding': 'Comprensión Social',
    };
    return names[key] ?? key;
  }

  String _getStrengthDescription(String skill) {
    final descriptions = {
      'cognitive_skills':
          'Excelente capacidad para resolver problemas y pensar lógicamente',
      'emotional_intelligence':
          'Gran habilidad para entender y manejar emociones',
      'attention_span':
          'Notable capacidad para mantener la atención en actividades',
      'memory_capacity':
          'Memoria fuerte para recordar información y secuencias',
      'pattern_recognition':
          'Habilidad destacada para identificar patrones y relaciones',
      'social_understanding':
          'Buena comprensión de situaciones sociales y empatía',
    };
    return descriptions[skill] ?? 'Habilidad bien desarrollada';
  }

  String _getGrowthDescription(String skill) {
    final descriptions = {
      'cognitive_skills': 'Oportunidad para desarrollar pensamiento lógico',
      'emotional_intelligence': 'Área para crecer en manejo emocional',
      'attention_span': 'Potencial para mejorar la concentración',
      'memory_capacity': 'Espacio para fortalecer la memoria',
      'pattern_recognition':
          'Oportunidad para desarrollar reconocimiento de patrones',
      'social_understanding': 'Área para crecer en comprensión social',
    };
    return descriptions[skill] ?? 'Área con potencial de desarrollo';
  }

  double _calculateOverallProgress() {
    if (_childAnalysis.isEmpty) return 0.5;
    return _childAnalysis.values.reduce((a, b) => a + b) /
        _childAnalysis.length;
  }

  // 🎯 Obtener recomendaciones por prioridad
  List<AIRecommendation> getHighPriorityRecommendations() {
    return _recommendations.where((r) => r.priority == Priority.high).toList();
  }

  List<AIRecommendation> getMediumPriorityRecommendations() {
    return _recommendations
        .where((r) => r.priority == Priority.medium)
        .toList();
  }

  List<AIRecommendation> getLowPriorityRecommendations() {
    return _recommendations.where((r) => r.priority == Priority.low).toList();
  }

  @override
  void dispose() {
    _aiService.dispose();
    super.dispose();
  }
}
