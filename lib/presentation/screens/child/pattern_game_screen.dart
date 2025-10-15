import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koa_app/presentation/widgets/common/kova_mascot.dart';
import '../../providers/child_provider.dart';
import '../../providers/ai_provider.dart'; // ✅ Import agregado

class PatternGameScreen extends StatefulWidget {
  const PatternGameScreen({super.key});

  @override
  State<PatternGameScreen> createState() => _PatternGameScreenState();
}

class _PatternGameScreenState extends State<PatternGameScreen> {
  final List<PatternItem> _pattern = [];
  final List<PatternItem> _userPattern = [];
  final List<PatternItem> _availableItems = [];
  int _currentLevel = 1;
  bool _isShowingPattern = false;
  bool _isGameCompleted = false;
  DateTime _startTime = DateTime.now();
  int _currentDifficulty = 2; // ✅ Variable agregada para dificultad
  int _maxLevels = 5; // ✅ Variable para niveles máximos

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // ✅ Obtener dificultad de IA y ajustar niveles máximos
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    _currentDifficulty = aiProvider.getAdaptiveDifficulty('patterns');
    _maxLevels = _currentDifficulty.clamp(3, 8); // 3-8 niveles según dificultad

    // Ajustar nivel inicial basado en la dificultad calculada por IA
    _currentLevel = _currentDifficulty.clamp(1, _maxLevels - 2);

    _initializeAvailableItems();
    _generatePattern();
    _startTime = DateTime.now();
  }

  // ✅ Método para inicializar items disponibles según dificultad
  void _initializeAvailableItems() {
    _availableItems.clear();

    // Items base
    final baseItems = [
      PatternItem(id: 1, type: 'color', value: Colors.red, display: '🔴'),
      PatternItem(id: 2, type: 'color', value: Colors.blue, display: '🔵'),
      PatternItem(id: 3, type: 'color', value: Colors.green, display: '🟢'),
      PatternItem(id: 4, type: 'color', value: Colors.yellow, display: '🟡'),
      PatternItem(id: 5, type: 'shape', value: 'circle', display: '⭕'),
      PatternItem(id: 6, type: 'shape', value: 'square', display: '⬛'),
      PatternItem(id: 7, type: 'shape', value: 'triangle', display: '🔺'),
      PatternItem(id: 8, type: 'shape', value: 'star', display: '⭐'),
    ];

    // ✅ Ajustar items disponibles según dificultad
    if (_currentDifficulty <= 2) {
      _availableItems.addAll(baseItems.sublist(0, 4)); // Solo colores básicos
    } else if (_currentDifficulty <= 4) {
      _availableItems.addAll(
        baseItems.sublist(0, 6),
      ); // Colores + formas simples
    } else {
      _availableItems.addAll(baseItems); // Todos los elementos
    }
  }

  void _generatePattern() {
    setState(() {
      _pattern.clear();
      _userPattern.clear();
      _isGameCompleted = false;

      // ✅ Generar patrón basado en el nivel y dificultad
      final baseLength = _currentLevel + 2; // Nivel 1: 3 elementos, etc.
      final patternLength = baseLength.clamp(3, 8); // Mínimo 3, máximo 8

      for (int i = 0; i < patternLength; i++) {
        // ✅ Para mayor dificultad, usar patrones más complejos
        if (_currentDifficulty >= 4 && i > 0) {
          // Introducir patrones más complejos
          final previousItem = _pattern[i - 1];
          final nextItem = _getNextInSequence(previousItem, _availableItems);
          _pattern.add(nextItem);
        } else {
          final randomIndex = (i * 3) % _availableItems.length;
          _pattern.add(_availableItems[randomIndex]);
        }
      }

      _showPattern();
    });
  }

  // ✅ Método para generar secuencias más complejas
  PatternItem _getNextInSequence(
    PatternItem previous,
    List<PatternItem> available,
  ) {
    // Lógica simple de secuencia: alternar entre color y forma
    if (previous.type == 'color') {
      return available.firstWhere(
        (item) => item.type == 'shape',
        orElse: () => available[0],
      );
    } else {
      return available.firstWhere(
        (item) => item.type == 'color',
        orElse: () => available[1],
      );
    }
  }

  void _showPattern() {
    setState(() {
      _isShowingPattern = true;
    });

    // ✅ Ajustar velocidad de muestra según dificultad
    final displaySpeed = _currentDifficulty >= 4 ? 600 : 800;

    // Mostrar patrón elemento por elemento
    Future.delayed(const Duration(milliseconds: 500), () {
      for (int i = 0; i < _pattern.length; i++) {
        Future.delayed(Duration(milliseconds: displaySpeed * i), () {
          if (mounted) {
            setState(() {
              // Efecto visual para mostrar el patrón
            });
          }
        });
      }

      Future.delayed(
        Duration(milliseconds: displaySpeed * _pattern.length + 500),
        () {
          if (mounted) {
            setState(() {
              _isShowingPattern = false;
            });
          }
        },
      );
    });
  }

  void _onItemTap(PatternItem item) {
    if (_isShowingPattern || _isGameCompleted) return;

    setState(() {
      _userPattern.add(item);
    });

    // Verificar si el elemento es correcto
    final isCorrect = _userPattern.length <= _pattern.length &&
        _userPattern[_userPattern.length - 1].id ==
            _pattern[_userPattern.length - 1].id;

    if (!isCorrect) {
      _showIncorrectFeedback();
      return;
    }

    // Verificar si completó el patrón
    if (_userPattern.length == _pattern.length) {
      _levelCompleted();
    }
  }

  void _showIncorrectFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text('Intenta otra vez, observa el patrón cuidadosamente'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _userPattern.clear();
        _showPattern();
      });
    });
  }

  void _levelCompleted() {
    setState(() {
      _isGameCompleted = true;
    });

    // Efectos de celebración
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_currentLevel < _maxLevels) {
        _nextLevel();
      } else {
        _endGame();
      }
    });
  }

  void _nextLevel() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelCompleteDialog(
        level: _currentLevel,
        patternLength: _pattern.length, // ✅ Mostrar longitud del patrón
        onContinue: () {
          Navigator.pop(context);
          setState(() {
            _currentLevel++;
          });
          _generatePattern();
        },
      ),
    );
  }

  void _endGame() {
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime);
    final score = _calculateScore();

    // ✅ Guardar sesión de juego con métricas de IA
    final childProvider = Provider.of<ChildProvider>(context, listen: false);
    final aiProvider = Provider.of<AIProvider>(context, listen: false);

    childProvider.saveGameSession(
      activityId: 'pattern_1',
      score: score,
      stars: _currentLevel,
      performance: {
        'levelsCompleted': _currentLevel,
        'totalDuration': duration.inSeconds,
        'finalPatternLength': _pattern.length,
        'difficultyLevel': _currentDifficulty, // ✅ Dificultad usada
        'maxComplexity': _getMaxComplexity(), // ✅ Complejidad máxima
        'availableItemsCount': _availableItems.length, // ✅ Items disponibles
      },
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PatternGameCompleteDialog(
        levelsCompleted: _currentLevel,
        duration: duration,
        score: score,
        difficulty: _currentDifficulty, // ✅ Pasar dificultad al diálogo
        maxLevels: _maxLevels, // ✅ Pasar niveles máximos al diálogo
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() {
            _currentLevel = 1;
          });
          _initializeGame();
        },
      ),
    );
  }

  // ✅ Calcular complejidad máxima del patrón
  int _getMaxComplexity() {
    final types = _pattern.map((item) => item.type).toSet();
    return types.length;
  }

  // ✅ Actualizado para incluir bonus por dificultad
  int _calculateScore() {
    final baseScore = _currentLevel * 500;
    final timeBonus =
        (300 - DateTime.now().difference(_startTime).inSeconds) * 3;
    final difficultyBonus = _currentDifficulty * 150; // ✅ Bonus por dificultad
    final complexityBonus = _getMaxComplexity() * 50; // ✅ Bonus por complejidad

    return (baseScore + timeBonus + difficultyBonus + complexityBonus).clamp(
      0,
      3000,
    );
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
                          'Pattern Sequence',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        // ✅ Actualizado para mostrar progreso dinámico
                        Text(
                          'Nivel $_currentLevel/$_maxLevels',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        // ✅ Mostrar nivel de dificultad
                        Text(
                          'Dificultad: $_currentDifficulty',
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
                      _isShowingPattern
                          ? 'Observa el patrón cuidadosamente...'
                          : 'Repite el patrón en el mismo orden',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

            // Área de Patrón
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Patrón a Repetir',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < _pattern.length; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _isShowingPattern ||
                                          i < _userPattern.length
                                      ? _getItemColor(_pattern[i])
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _pattern[i].display,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Separador
            Container(
              height: 2,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),

            // Área de Selección del Usuario
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Tu Patrón',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Patrón del usuario
                    Container(
                      height: 60,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _userPattern.length,
                        itemBuilder: (context, index) {
                          final item = _userPattern[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _getItemColor(item),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  item.display,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Opciones disponibles
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: _availableItems.length,
                        itemBuilder: (context, index) {
                          final item = _availableItems[index];
                          return PatternItemWidget(
                            item: item,
                            onTap: () => _onItemTap(item),
                            isDisabled: _isShowingPattern || _isGameCompleted,
                          );
                        },
                      ),
                    ),
                  ],
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

  Color _getItemColor(PatternItem item) {
    if (item.type == 'color') {
      return item.value as Color;
    }
    return Colors.white;
  }
}

class PatternItem {
  final int id;
  final String type;
  final dynamic value;
  final String display;

  PatternItem({
    required this.id,
    required this.type,
    required this.value,
    required this.display,
  });
}

class PatternItemWidget extends StatelessWidget {
  final PatternItem item;
  final VoidCallback onTap;
  final bool isDisabled;

  const PatternItemWidget({
    super.key,
    required this.item,
    required this.onTap,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Card(
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              color: item.type == 'color' ? item.value as Color : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(item.display, style: const TextStyle(fontSize: 24)),
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ Diálogo actualizado para mostrar longitud del patrón
class LevelCompleteDialog extends StatelessWidget {
  final int level;
  final int patternLength;
  final VoidCallback onContinue;

  const LevelCompleteDialog({
    super.key,
    required this.level,
    required this.patternLength,
    required this.onContinue,
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
              '¡Nivel $level Completado!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Patrón de $patternLength elementos reconocido correctamente',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onContinue,
              child: const Text('Siguiente Nivel'),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Diálogo actualizado para mostrar dificultad
class PatternGameCompleteDialog extends StatelessWidget {
  final int levelsCompleted;
  final Duration duration;
  final int score;
  final int difficulty;
  final int maxLevels;
  final VoidCallback onPlayAgain;

  const PatternGameCompleteDialog({
    super.key,
    required this.levelsCompleted,
    required this.duration,
    required this.score,
    required this.difficulty,
    required this.maxLevels,
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
              '¡Juego Completado!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            // ✅ Mostrar dificultad y niveles
            const SizedBox(height: 8),
            Text(
              'Nivel $difficulty • $levelsCompleted/$maxLevels niveles',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Niveles', '$levelsCompleted'),
                _buildStat('Puntaje', '$score'),
                _buildStat('Tiempo', '${duration.inSeconds}s'),
              ],
            ),

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
                    onPressed: onPlayAgain,
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
