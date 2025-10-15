import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koa_app/presentation/widgets/common/kova_mascot.dart';
import '../../providers/child_provider.dart';
import '../../providers/ai_provider.dart'; // ✅ Import agregado

class EmotionalGameScreen extends StatefulWidget {
  const EmotionalGameScreen({super.key});

  @override
  State<EmotionalGameScreen> createState() => _EmotionalGameScreenState();
}

class _EmotionalGameScreenState extends State<EmotionalGameScreen> {
  final List<EmotionCard> _emotionCards = [];
  final List<SituationCard> _situationCards = [];
  EmotionCard? _selectedEmotion;
  SituationCard? _selectedSituation;
  int _correctMatches = 0;
  int _attempts = 0;
  DateTime _startTime = DateTime.now();
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _currentDifficulty = 2; // ✅ Variable agregada para dificultad

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // ✅ Obtener dificultad de IA
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    _currentDifficulty = aiProvider.getAdaptiveDifficulty('emotions');

    _generateGameContent(_currentDifficulty);
    _startTime = DateTime.now();
  }

  // ✅ Método nuevo para generar contenido basado en dificultad
  void _generateGameContent(int difficulty) {
    // Definir emociones y situaciones base
    final baseEmotions = [
      EmotionCard(id: 1, emotion: '😊', emotionName: 'Feliz'),
      EmotionCard(id: 2, emotion: '😢', emotionName: 'Triste'),
      EmotionCard(id: 3, emotion: '😡', emotionName: 'Enojado'),
      EmotionCard(id: 4, emotion: '😮', emotionName: 'Sorprendido'),
      EmotionCard(id: 5, emotion: '😴', emotionName: 'Cansado'),
      EmotionCard(id: 6, emotion: '😎', emotionName: 'Seguro'),
      EmotionCard(id: 7, emotion: '😰', emotionName: 'Asustado'),
      EmotionCard(id: 8, emotion: '😍', emotionName: 'Enamorado'),
    ];

    final baseSituations = [
      SituationCard(
        id: 1,
        description: 'Ganaste un premio',
        correctEmotionId: 1, // Feliz
        imagePath: 'assets/emotions/win_prize.png',
      ),
      SituationCard(
        id: 2,
        description: 'Se rompió tu juguete favorito',
        correctEmotionId: 2, // Triste
        imagePath: 'assets/emotions/broken_toy.png',
      ),
      SituationCard(
        id: 3,
        description: 'Alguien tomó tu juguete sin permiso',
        correctEmotionId: 3, // Enojado
        imagePath: 'assets/emotions/taken_toy.png',
      ),
      SituationCard(
        id: 4,
        description: 'Viste algo increíble',
        correctEmotionId: 4, // Sorprendido
        imagePath: 'assets/emotions/surprise.png',
      ),
      SituationCard(
        id: 5,
        description: 'Es hora de dormir después de un día largo',
        correctEmotionId: 5, // Cansado
        imagePath: 'assets/emotions/sleepy.png',
      ),
      SituationCard(
        id: 6,
        description: 'Lograste algo muy difícil',
        correctEmotionId: 6, // Seguro
        imagePath: 'assets/emotions/confident.png',
      ),
      SituationCard(
        id: 7,
        description: 'Escuchaste un ruido fuerte en la noche',
        correctEmotionId: 7, // Asustado
        imagePath: 'assets/emotions/scared.png',
      ),
      SituationCard(
        id: 8,
        description: 'Ves a tu persona favorita',
        correctEmotionId: 8, // Enamorado
        imagePath: 'assets/emotions/loved.png',
      ),
    ];

    // ✅ Ajustar la cantidad según la dificultad
    final emotionCount = difficulty.clamp(4, 8);
    final situationCount = emotionCount;

    setState(() {
      _emotionCards.clear();
      _situationCards.clear();

      _emotionCards.addAll(baseEmotions.sublist(0, emotionCount));
      _situationCards.addAll(baseSituations.sublist(0, situationCount));

      _emotionCards.shuffle();
      _situationCards.shuffle();
      _correctMatches = 0;
      _attempts = 0;
      _startTime = DateTime.now();
      _selectedEmotion = null;
      _selectedSituation = null;
      _showFeedback = false;
    });
  }

  void _onEmotionTap(EmotionCard emotion) {
    if (_showFeedback) return;

    setState(() {
      _selectedEmotion = emotion;
      _checkMatch();
    });
  }

  void _onSituationTap(SituationCard situation) {
    if (_showFeedback) return;

    setState(() {
      _selectedSituation = situation;
      _checkMatch();
    });
  }

  void _checkMatch() {
    if (_selectedEmotion != null && _selectedSituation != null) {
      _attempts++;

      final isCorrect =
          _selectedEmotion!.id == _selectedSituation!.correctEmotionId;

      setState(() {
        _showFeedback = true;
        _isCorrect = isCorrect;
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        setState(() {
          if (isCorrect) {
            _correctMatches++;
            _emotionCards.remove(_selectedEmotion);
            _situationCards.remove(_selectedSituation);
          }

          _selectedEmotion = null;
          _selectedSituation = null;
          _showFeedback = false;

          if (_emotionCards.isEmpty) {
            _endGame();
          }
        });
      });
    }
  }

  void _endGame() {
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime);
    final score = _calculateScore();
    final accuracy = _correctMatches / _attempts;

    // ✅ Guardar sesión de juego con métricas de IA
    final childProvider = Provider.of<ChildProvider>(context, listen: false);
    final aiProvider = Provider.of<AIProvider>(context, listen: false);

    childProvider.saveGameSession(
      activityId: 'emotional_1',
      score: score,
      stars: _calculateStars(accuracy),
      performance: {
        'correctMatches': _correctMatches,
        'totalAttempts': _attempts,
        'accuracy': accuracy.toStringAsFixed(2),
        'duration': duration.inSeconds,
        'difficultyLevel': _currentDifficulty, // ✅ Dificultad usada
        'emotionalPairs': _situationCards.length, // ✅ Número de pares
      },
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EmotionalGameCompleteDialog(
        correctMatches: _correctMatches,
        totalAttempts: _attempts,
        accuracy: accuracy,
        duration: duration,
        stars: _calculateStars(accuracy),
        difficulty: _currentDifficulty, // ✅ Pasar dificultad al diálogo
        onPlayAgain: _initializeGame,
      ),
    );
  }

  // ✅ Actualizado para incluir bonus por dificultad
  int _calculateScore() {
    final baseScore = 1000;
    final accuracyBonus = (_correctMatches / _attempts) * 500;
    final timeBonus =
        (300 - DateTime.now().difference(_startTime).inSeconds) * 2;
    final difficultyBonus = _currentDifficulty * 100; // ✅ Bonus por dificultad

    return (baseScore + accuracyBonus + timeBonus + difficultyBonus)
        .toInt()
        .clamp(0, 2000);
  }

  int _calculateStars(double accuracy) {
    if (accuracy >= 0.8) return 3;
    if (accuracy >= 0.6) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.secondary,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const KovaMascot(
                    expression: KovaExpression.thinking,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emotional Match',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        // ✅ Actualizado para mostrar número dinámico
                        Text(
                          'Aciertos: $_correctMatches/${_situationCards.length}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        // ✅ Mostrar nivel de dificultad
                        Text(
                          'Nivel: $_currentDifficulty',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Instrucciones
            Container(
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Une cada situación con la emoción correcta',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

            // Área de Juego
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Cartas de Emociones
                    Text(
                      'Emociones',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      flex: 2,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: _emotionCards.length,
                        itemBuilder: (context, index) {
                          final emotion = _emotionCards[index];
                          return EmotionCardWidget(
                            emotion: emotion,
                            isSelected: _selectedEmotion?.id == emotion.id,
                            onTap: () => _onEmotionTap(emotion),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cartas de Situaciones
                    Text(
                      'Situaciones',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      flex: 3,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: _situationCards.length,
                        itemBuilder: (context, index) {
                          final situation = _situationCards[index];
                          return SituationCardWidget(
                            situation: situation,
                            isSelected: _selectedSituation?.id == situation.id,
                            onTap: () => _onSituationTap(situation),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Feedback
            if (_showFeedback)
              Container(
                padding: const EdgeInsets.all(16),
                color: _isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.error,
                      color: _isCorrect ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isCorrect ? '¡Correcto! 🎉' : 'Intenta otra vez 💪',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),

            // Botones
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reiniciar'),
                      onPressed: _initializeGame,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.home),
                      label: const Text('Salir'),
                      onPressed: () => Navigator.pop(context),
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
}

class EmotionCard {
  final int id;
  final String emotion;
  final String emotionName;
  bool isSelected;

  EmotionCard({
    required this.id,
    required this.emotion,
    required this.emotionName,
    this.isSelected = false,
  });
}

class SituationCard {
  final int id;
  final String description;
  final int correctEmotionId;
  final String imagePath;

  SituationCard({
    required this.id,
    required this.description,
    required this.correctEmotionId,
    required this.imagePath,
  });
}

class EmotionCardWidget extends StatelessWidget {
  final EmotionCard emotion;
  final bool isSelected;
  final VoidCallback onTap;

  const EmotionCardWidget({
    super.key,
    required this.emotion,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
            : Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emotion.emotion, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                emotion.emotionName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SituationCardWidget extends StatelessWidget {
  final SituationCard situation;
  final bool isSelected;
  final VoidCallback onTap;

  const SituationCardWidget({
    super.key,
    required this.situation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: isSelected
            ? Theme.of(context).colorScheme.secondary.withOpacity(0.3)
            : Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Placeholder para imagen - en una app real usarías Image.asset
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.photo,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                situation.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Diálogo actualizado para mostrar dificultad
class EmotionalGameCompleteDialog extends StatelessWidget {
  final int correctMatches;
  final int totalAttempts;
  final double accuracy;
  final Duration duration;
  final int stars;
  final int difficulty; // ✅ Nuevo parámetro
  final VoidCallback onPlayAgain;

  const EmotionalGameCompleteDialog({
    super.key,
    required this.correctMatches,
    required this.totalAttempts,
    required this.accuracy,
    required this.duration,
    required this.stars,
    required this.difficulty,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const KovaMascot(expression: KovaExpression.celebrating, size: 80),
            const SizedBox(height: 16),
            Text(
              '¡Emociones Reconocidas!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ✅ Mostrar dificultad en el diálogo
            Text(
              'Nivel de Dificultad: $difficulty',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Aciertos', '$correctMatches'),
                _buildStat('Precisión', '${(accuracy * 100).toInt()}%'),
                _buildStat('Estrellas', '⭐' * stars),
              ],
            ),

            const SizedBox(height: 12),
            _buildStat('Tiempo', '${duration.inSeconds} segundos'),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Salir'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onPlayAgain();
                    },
                    child: const Text('Jugar Otra Vez'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
