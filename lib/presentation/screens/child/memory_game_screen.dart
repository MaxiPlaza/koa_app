import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koa_app/presentation/widgets/common/kova_mascot.dart';
import '../../providers/child_provider.dart';
import '../../providers/ai_provider.dart'; // ✅ Import agregado

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<MemoryCard> _cards = [];
  MemoryCard? _firstCard;
  MemoryCard? _secondCard;
  bool _isProcessing = false;
  int _moves = 0;
  int _matches = 0;
  DateTime _startTime = DateTime.now();
  int _currentDifficulty = 2; // ✅ Variable agregada para dificultad
  int _totalPairs = 6; // ✅ Variable para número total de pares

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // ✅ Obtener dificultad de IA
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    _currentDifficulty = aiProvider.getAdaptiveDifficulty('memory');

    _generateCards(_currentDifficulty);
    _startTime = DateTime.now();
  }

  // ✅ Método actualizado para generar cartas basado en dificultad
  void _generateCards(int difficulty) {
    final baseEmotions = [
      '😊',
      '😢',
      '😡',
      '😮',
      '😴',
      '😎',
      '🤔',
      '😍',
      '🥳',
      '😭',
    ];
    final pairCount = difficulty.clamp(2, 8); // 2-8 pares según dificultad

    // Para dificultades altas, agregar más emociones similares
    final selectedEmotions = baseEmotions.sublist(0, pairCount);

    // En dificultad 4+, duplicar algunas cartas para hacerlo más desafiante
    if (difficulty >= 4) {
      selectedEmotions.add(selectedEmotions[0]); // Emoción extra repetida
    }

    final cardPairs = [...selectedEmotions, ...selectedEmotions];
    cardPairs.shuffle();

    setState(() {
      _cards.clear();
      for (int i = 0; i < cardPairs.length; i++) {
        _cards.add(
          MemoryCard(
            id: i,
            emotion: cardPairs[i],
            isFlipped: false,
            isMatched: false,
          ),
        );
      }
      _moves = 0;
      _matches = 0;
      _totalPairs = cardPairs.length ~/ 2; // ✅ Calcular pares totales
    });
  }

  void _onCardTap(MemoryCard card) {
    if (_isProcessing || card.isFlipped || card.isMatched) return;

    setState(() {
      card.isFlipped = true;
    });

    if (_firstCard == null) {
      _firstCard = card;
    } else {
      _secondCard = card;
      _moves++;
      _checkForMatch();
    }
  }

  void _checkForMatch() {
    if (_firstCard?.emotion == _secondCard?.emotion) {
      setState(() {
        _firstCard?.isMatched = true;
        _secondCard?.isMatched = true;
        _matches++;
      });
      _resetSelection();

      // ✅ Condición actualizada para número dinámico de pares
      if (_matches == _totalPairs) {
        _endGame();
      }
    } else {
      _isProcessing = true;
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          _firstCard?.isFlipped = false;
          _secondCard?.isFlipped = false;
        });
        _resetSelection();
        _isProcessing = false;
      });
    }
  }

  void _resetSelection() {
    _firstCard = null;
    _secondCard = null;
  }

  void _endGame() {
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime);
    final score = _calculateScore();

    // ✅ Guardar sesión de juego con métricas de IA
    final childProvider = Provider.of<ChildProvider>(context, listen: false);
    final aiProvider = Provider.of<AIProvider>(context, listen: false);

    childProvider.saveGameSession(
      activityId: 'memory_1',
      score: score,
      stars: _calculateStars(),
      performance: {
        'moves': _moves,
        'matches': _matches,
        'duration': duration.inSeconds,
        'efficiency': (_matches / _moves).toStringAsFixed(2),
        'difficultyLevel': _currentDifficulty, // ✅ Dificultad usada
        'totalPairs': _totalPairs, // ✅ Número de pares
      },
    );

    // Mostrar diálogo de victoria
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameCompleteDialog(
        moves: _moves,
        duration: duration,
        stars: _calculateStars(),
        difficulty: _currentDifficulty, // ✅ Pasar dificultad al diálogo
        totalPairs: _totalPairs, // ✅ Pasar pares totales al diálogo
        onPlayAgain: _initializeGame,
      ),
    );
  }

  // ✅ Actualizado para incluir bonus por dificultad
  int _calculateScore() {
    final baseScore = 1000;
    final movePenalty = _moves * 10;
    final timeBonus =
        (300 - DateTime.now().difference(_startTime).inSeconds) * 2;
    final difficultyBonus = _currentDifficulty * 120; // ✅ Bonus por dificultad

    return (baseScore - movePenalty + timeBonus + difficultyBonus).clamp(
      0,
      1000,
    );
  }

  int _calculateStars() {
    final efficiency = _matches / _moves;
    if (efficiency >= 0.8) return 3;
    if (efficiency >= 0.6) return 2;
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
              color: Theme.of(context).colorScheme.primary,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const KovaMascot(expression: KovaExpression.happy, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Memory Cards',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        // ✅ Actualizado para mostrar número dinámico
                        Text(
                          'Movimientos: $_moves | Parejas: $_matches/$_totalPairs',
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

            // Tablero de juego
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getGridColumns(), // ✅ Columnas dinámicas
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    return MemoryCardWidget(
                      card: card,
                      onTap: () => _onCardTap(card),
                    );
                  },
                ),
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

  // ✅ Método para calcular columnas dinámicas según número de cartas
  int _getGridColumns() {
    if (_cards.length <= 12) return 3;
    if (_cards.length <= 20) return 4;
    return 5;
  }
}

class MemoryCard {
  final int id;
  final String emotion;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.emotion,
    required this.isFlipped,
    required this.isMatched,
  });
}

class MemoryCardWidget extends StatelessWidget {
  final MemoryCard card;
  final VoidCallback onTap;

  const MemoryCardWidget({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: card.isMatched
              ? Colors.green.withOpacity(0.3)
              : card.isFlipped
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
          border: Border.all(
            color: card.isMatched ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: card.isFlipped || card.isMatched
                ? Text(card.emotion, style: const TextStyle(fontSize: 24))
                : Icon(Icons.question_mark, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

// ✅ Diálogo actualizado para mostrar dificultad y pares
class GameCompleteDialog extends StatelessWidget {
  final int moves;
  final Duration duration;
  final int stars;
  final int difficulty;
  final int totalPairs;
  final VoidCallback onPlayAgain;

  const GameCompleteDialog({
    super.key,
    required this.moves,
    required this.duration,
    required this.stars,
    required this.difficulty,
    required this.totalPairs,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    final efficiency = (totalPairs / moves).toStringAsFixed(2);

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
              '¡Juego Completado!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            // ✅ Mostrar dificultad y eficiencia
            const SizedBox(height: 8),
            Text(
              'Nivel $difficulty • Eficiencia: $efficiency',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Movimientos', moves.toString()),
                _buildStat('Pares', '$totalPairs'),
                _buildStat('Estrellas', '⭐' * stars),
              ],
            ),

            const SizedBox(height: 12),
            _buildStat('Tiempo', '${duration.inSeconds}s'),

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
