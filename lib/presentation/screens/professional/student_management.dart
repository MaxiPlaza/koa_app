import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/child_model.dart';
import '../../../providers/child_provider.dart';
import '../../../providers/ai_provider.dart';
import '../../widgets/common/kova_mascot.dart';

class StudentManagement extends StatefulWidget {
  const StudentManagement({super.key});

  @override
  State<StudentManagement> createState() => _StudentManagementState();
}

class _StudentManagementState extends State<StudentManagement> {
  late ChildModel _student;
  int _selectedTab = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener el estudiante de los argumentos de navegación
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is ChildModel) {
      _student = args;
    } else {
      // Fallback: usar el estudiante actual del provider
      final childProvider = Provider.of<ChildProvider>(context, listen: false);
      _student = childProvider.currentChild ?? _getDefaultStudent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final childProvider = Provider.of<ChildProvider>(context);
    final aiProvider = Provider.of<AIProvider>(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Gestión: ${_student.name}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          bottom: TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.person), text: 'Perfil'),
              Tab(icon: Icon(Icons.analytics), text: 'Progreso'),
              Tab(icon: Icon(Icons.settings), text: 'Configuración'),
              Tab(icon: Icon(Icons.history), text: 'Sesiones'),
            ],
            onTap: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () {
                _generateReport(context);
              },
              tooltip: 'Generar Reporte PDF',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                _shareProgress(context);
              },
              tooltip: 'Compartir Progreso',
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildProfileTab(_student, context),
            _buildProgressTab(_student, aiProvider, context),
            _buildSettingsTab(_student, context),
            _buildSessionsTab(_student, childProvider, context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(ChildModel student, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información Básica
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.child_care,
                      color: Theme.of(context).colorScheme.primary,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Edad', '${student.age} años'),
                        _buildInfoRow(
                          'Estilo de Aprendizaje',
                          student.learningStyle,
                        ),
                        if (student.syndrome != null)
                          _buildInfoRow('Diagnóstico', student.syndrome!),
                        _buildInfoRow(
                          'Tiempo Total de Juego',
                          '${student.progress.totalPlayTime ~/ 60} horas',
                        ),
                        _buildInfoRow(
                          'Estrellas Totales',
                          '${student.progress.totalStars} ⭐',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Observaciones del Profesional
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Observaciones del Profesional',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText:
                          'Agregar observaciones sobre el progreso, comportamientos, recomendaciones...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () {
                        _saveObservations(context);
                      },
                      child: const Text('Guardar Observaciones'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab(
    ChildModel student,
    AIProvider aiProvider,
    BuildContext context,
  ) {
    final analysis = aiProvider.childAnalysis.isNotEmpty
        ? aiProvider.childAnalysis
        : _getDefaultAnalysis();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen de Progreso
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const KovaMascot(
                        expression: KovaExpression.thinking,
                        size: 60,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Análisis de Progreso',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Análisis generado por IA KOA',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      aiProvider.analyzeChildProgress(
                        child: student,
                        sessions: Provider.of<ChildProvider>(
                          context,
                          listen: false,
                        ).gameSessions,
                      );
                    },
                    child: const Text('Actualizar Análisis IA'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Habilidades Detalladas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Habilidades Desarrolladas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...analysis.entries
                      .map(
                        (entry) => _buildSkillProgress(
                          entry.key,
                          entry.value,
                          context,
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recomendaciones de IA
          if (aiProvider.recommendations.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recomendaciones de IA',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...aiProvider.recommendations
                        .take(3)
                        .map(
                          (recommendation) =>
                              _buildRecommendationCard(recommendation, context),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsTab(ChildModel student, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Configuración de Dificultad
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuración de Dificultad',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingSlider(
                    'Dificultad Base',
                    'Ajusta el nivel de desafío inicial',
                    student.settings.difficultyLevel == 'easy'
                        ? 1.0
                        : student.settings.difficultyLevel == 'medium'
                        ? 2.0
                        : 3.0,
                    (value) {
                      // Actualizar configuración
                    },
                    context,
                  ),
                  _buildSettingSlider(
                    'Sensibilidad',
                    'Controla la intensidad de estímulos',
                    student.settings.sensitivity,
                    (value) {
                      // Actualizar configuración
                    },
                    context,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Áreas de Enfoque
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Áreas de Enfoque Personalizado',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                              'Memoria',
                              'Atención',
                              'Emociones',
                              'Patrones',
                              'Social',
                              'Lógica',
                            ]
                            .map(
                              (area) => FilterChip(
                                label: Text(area),
                                selected: student.settings.focusAreas.contains(
                                  area.toLowerCase(),
                                ),
                                onSelected: (selected) {
                                  // Actualizar áreas de enfoque
                                },
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Configuraciones de Accesibilidad
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accesibilidad',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingSwitch(
                    'Reducir Animaciones',
                    'Disminuye efectos visuales complejos',
                    student.settings.reduceAnimations,
                    (value) {
                      // Actualizar configuración
                    },
                    context,
                  ),
                  _buildSettingSwitch(
                    'Desactivar Sonidos Fuertes',
                    'Elimina sonidos que puedan molestar',
                    student.settings.disableLoudSounds,
                    (value) {
                      // Actualizar configuración
                    },
                    context,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsTab(
    ChildModel student,
    ChildProvider childProvider,
    BuildContext context,
  ) {
    final sessions = childProvider.gameSessions;

    return Column(
      children: [
        // Filtros y Estadísticas
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSessionStat('Total', '${sessions.length}', context),
                  _buildSessionStat(
                    'Completadas',
                    '${sessions.where((s) => s.completed).length}',
                    context,
                  ),
                  _buildSessionStat(
                    'Promedio',
                    '${sessions.isEmpty ? 0 : sessions.map((s) => s.score).reduce((a, b) => a + b) ~/ sessions.length}',
                    context,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Lista de Sesiones
        Expanded(
          child: sessions.isEmpty
              ? _buildNoSessionsState(context)
              : ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return _buildSessionItem(session, context);
                  },
                ),
        ),
      ],
    );
  } // Métodos auxiliares para _buildProfileTab

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _saveObservations(BuildContext context) {
    // En una app real, guardaríamos en Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Observaciones guardadas exitosamente')),
    );
  }

  // Métodos auxiliares para _buildProgressTab
  Widget _buildSkillProgress(String skill, double value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatSkillName(skill),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade300,
            color: _getProgressColor(value),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    AIRecommendation recommendation,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: _getRecommendationColor(recommendation.priority).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getRecommendationIcon(recommendation.type),
                  color: _getRecommendationColor(recommendation.priority),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getRecommendationColor(recommendation.priority),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPriorityText(recommendation.priority),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(recommendation.description),
            const SizedBox(height: 8),
            Text(
              'Razón: ${recommendation.reason}',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares para _buildSettingsTab
  Widget _buildSettingSlider(
    String title,
    String subtitle,
    double value,
    Function(double) onChanged,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Slider(
            value: value,
            min: 1,
            max: 5,
            divisions: 4,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    BuildContext context,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  // Métodos auxiliares para _buildSessionsTab
  Widget _buildSessionStat(String label, String value, BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildNoSessionsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const KovaMascot(expression: KovaExpression.thinking, size: 120),
          const SizedBox(height: 24),
          Text(
            'Aún no hay sesiones registradas',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Las sesiones de juego aparecerán aquí para que puedas revisar el desempeño.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(GameSession session, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getSessionColor(session.activityId),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getSessionIcon(session.activityId), color: Colors.white),
        ),
        title: Text(
          _getActivityName(session.activityId),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Puntuación: ${session.score}'),
            Text('Duración: ${session.durationInMinutes} min'),
            Text('Estrellas: ${session.stars} ⭐'),
            Text('Fecha: ${_formatSessionDate(session.startTime)}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.analytics),
          onPressed: () {
            _showSessionDetails(session, context);
          },
        ),
      ),
    );
  }

  void _showSessionDetails(GameSession session, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Detalles de Sesión - ${_getActivityName(session.activityId)}',
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSessionDetailRow('Puntuación', session.score.toString()),
              _buildSessionDetailRow(
                'Duración',
                '${session.durationInMinutes} minutos',
              ),
              _buildSessionDetailRow('Estrellas', '${session.stars} ⭐'),
              _buildSessionDetailRow(
                'Fecha',
                _formatSessionDate(session.startTime),
              ),
              _buildSessionDetailRow(
                'Completada',
                session.completed ? 'Sí' : 'No',
              ),
              const SizedBox(height: 16),
              if (session.performance.isNotEmpty) ...[
                Text(
                  'Métricas de Desempeño:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...session.performance.entries
                    .map(
                      (entry) => _buildSessionDetailRow(
                        _formatPerformanceKey(entry.key),
                        entry.value.toString(),
                      ),
                    )
                    .toList(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  // Métodos de utilidad
  String _formatSkillName(String skill) {
    final names = {
      'cognitive_skills': 'Habilidades Cognitivas',
      'emotional_intelligence': 'Inteligencia Emocional',
      'attention_span': 'Atención y Concentración',
      'memory_capacity': 'Memoria y Retención',
      'pattern_recognition': 'Reconocimiento de Patrones',
      'social_understanding': 'Comprensión Social',
    };
    return names[skill] ?? skill;
  }

  Color _getRecommendationColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.blue;
    }
  }

  IconData _getRecommendationIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.memory:
        return Icons.memory;
      case RecommendationType.emotional:
        return Icons.emoji_emotions;
      case RecommendationType.cognitive:
        return Icons.psychology;
      case RecommendationType.social:
        return Icons.group;
      case RecommendationType.learningStyle:
        return Icons.school;
      case RecommendationType.balance:
        return Icons.balance;
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'Alta';
      case Priority.medium:
        return 'Media';
      case Priority.low:
        return 'Baja';
    }
  }

  Color _getSessionColor(String activityId) {
    switch (activityId) {
      case 'memory_1':
        return Colors.blue;
      case 'emotional_1':
        return Colors.purple;
      case 'pattern_1':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getSessionIcon(String activityId) {
    switch (activityId) {
      case 'memory_1':
        return Icons.memory;
      case 'emotional_1':
        return Icons.emoji_emotions;
      case 'pattern_1':
        return Icons.pattern;
      default:
        return Icons.games;
    }
  }

  String _getActivityName(String activityId) {
    switch (activityId) {
      case 'memory_1':
        return 'Memory Cards';
      case 'emotional_1':
        return 'Emotional Match';
      case 'pattern_1':
        return 'Pattern Sequence';
      default:
        return 'Actividad Desconocida';
    }
  }

  String _formatSessionDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPerformanceKey(String key) {
    final names = {
      'moves': 'Movimientos',
      'matches': 'Aciertos',
      'duration': 'Duración (segundos)',
      'efficiency': 'Eficiencia',
      'correctMatches': 'Coincidencias Correctas',
      'totalAttempts': 'Intentos Totales',
      'accuracy': 'Precisión',
      'difficultyLevel': 'Nivel de Dificultad',
      'emotionalPairs': 'Pares de Emociones',
      'levelsCompleted': 'Niveles Completados',
      'finalPatternLength': 'Longitud del Patrón Final',
      'maxComplexity': 'Complejidad Máxima',
      'availableItemsCount': 'Número de Items Disponibles',
    };
    return names[key] ?? key;
  }

  void _generateReport(BuildContext context) {
    // En una app real, generaríamos un PDF
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Generando reporte PDF...')));
  }

  void _shareProgress(BuildContext context) {
    // En una app real, compartiríamos el progreso
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Compartiendo progreso...')));
  }

  // Datos de ejemplo
  ChildModel _getDefaultStudent() {
    return ChildModel(
      id: 'default',
      name: 'Alumno Ejemplo',
      age: 8,
      syndrome: 'TEA',
      learningStyle: 'visual',
      parentId: 'parent1',
      progress: ChildProgress(
        skillLevels: {
          'cognitive_skills': 0.5,
          'emotional_intelligence': 0.5,
          'attention_span': 0.5,
        },
        totalPlayTime: 0,
        totalStars: 0,
        lastSession: DateTime.now(),
        recentSessions: [],
      ),
      settings: ChildSettings(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
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
}

  // ... (métodos auxiliares continuarán en la siguiente respuesta debido a la longitud)