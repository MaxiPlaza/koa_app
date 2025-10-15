import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koa_app/presentation/providers/ai_provider.dart';
import 'package:koa_app/presentation/providers/child_provider.dart';
import 'package:koa_app/presentation/widgets/common/kova_mascot.dart';

class AIAnalysisScreen extends StatelessWidget {
  const AIAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AIProvider>(context);
    final childProvider = Provider.of<ChildProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis IA KOA'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (childProvider.currentChild != null) {
                aiProvider.analyzeChildProgress(
                  child: childProvider.currentChild!,
                  sessions: childProvider.gameSessions,
                );
              }
            },
            tooltip: 'Actualizar análisis',
          ),
        ],
      ),
      body: _buildBody(aiProvider, childProvider, context),
    );
  }

  Widget _buildBody(
    AIProvider aiProvider,
    ChildProvider childProvider,
    BuildContext context,
  ) {
    if (childProvider.currentChild == null) {
      return _buildNoChildSelected();
    }

    if (aiProvider.isAnalyzing) {
      // ⚠️ ERROR CORREGIDO: Añadido 'context' como argumento
      return _buildLoadingAnalysis(context);
    }

    if (aiProvider.childAnalysis.isEmpty) {
      // ⚠️ ERROR CORREGIDO: Añadido 'context' como argumento
      return _buildFirstTimeAnalysis(aiProvider, childProvider, context);
    }

    return _buildAnalysisResults(aiProvider, childProvider, context);
  }

  Widget _buildNoChildSelected() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Selecciona un niño para ver el análisis',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ⚠️ ERROR CORREGIDO: Recibe BuildContext
  Widget _buildLoadingAnalysis(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const KovaMascot(expression: KovaExpression.thinking, size: 100),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'KOA está analizando el progreso...',
            style: TextStyle(
              fontSize: 16,
              // ⚠️ ERROR CORREGIDO: Usa el 'context' recibido
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esto puede tomar unos momentos',
            style: TextStyle(
              fontSize: 14,
              // ⚠️ ERROR CORREGIDO: Usa el 'context' recibido
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ⚠️ ERROR CORREGIDO: Recibe BuildContext
  Widget _buildFirstTimeAnalysis(
    AIProvider aiProvider,
    ChildProvider childProvider,
    BuildContext context, // ⚠️ ERROR CORREGIDO: Añadido BuildContext
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const KovaMascot(expression: KovaExpression.excited, size: 120),
            const SizedBox(height: 24),
            Text(
              '¡Descubre Insights con IA!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'KOA analizará las sesiones de juego para proporcionar recomendaciones personalizadas y ajustar la dificultad automáticamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                // ⚠️ ERROR CORREGIDO: Usa el 'context' recibido
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.psychology),
              label: const Text('Iniciar Análisis IA'),
              onPressed: () {
                aiProvider.analyzeChildProgress(
                  child: childProvider.currentChild!,
                  sessions: childProvider.gameSessions,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResults(
    AIProvider aiProvider,
    ChildProvider childProvider,
    BuildContext context,
  ) {
    final analysisSummary = aiProvider.getAnalysisSummary();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen General
          _buildSummaryCard(analysisSummary, context),

          const SizedBox(height: 24),

          // Habilidades Detalladas
          _buildSkillsSection(aiProvider, context),

          const SizedBox(height: 24),

          // Recomendaciones
          // ⚠️ ERROR CORREGIDO: El método ya existe o se añade abajo
          _buildRecommendationsSection(aiProvider, context),

          const SizedBox(height: 24),

          // Generador de Historias
          // ⚠️ ERROR CORREGIDO: El método ya existe o se añade abajo
          _buildStoryGenerator(aiProvider, childProvider, context),

          const SizedBox(height: 24),

          // Dificultades Adaptativas
          // ⚠️ ERROR CORREGIDO: El método ya existe o se añade abajo
          _buildAdaptiveDifficulties(aiProvider, context),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> summary, BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const KovaMascot(expression: KovaExpression.happy, size: 60),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen de Progreso',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Análisis personalizado por IA',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildSummaryItem(
                  'Progreso General',
                  '${(summary['overall_progress'] * 100).toInt()}%',
                  Icons.trending_up,
                  Colors.green,
                  context,
                ),
                _buildSummaryItem(
                  'Fortaleza Principal',
                  summary['top_strength']['name'],
                  Icons.star,
                  Colors.amber,
                  context,
                ),
                _buildSummaryItem(
                  'Recomendaciones',
                  summary['recommendations_count'].toString(),
                  Icons.lightbulb,
                  Colors.blue,
                  context,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(AIProvider aiProvider, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habilidades Desarrolladas',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...aiProvider.childAnalysis.entries.map(
              (entry) => _buildSkillProgress(entry.key, entry.value, context),
            ), // ⚠️ ERROR CORREGIDO: Se eliminó el .toList() innecesario
          ],
        ),
      ),
    );
  }

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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade300,
            color: _getSkillColor(skill),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  // --- MÉTODOS AUXILIARES AÑADIDOS ---

  // ⚠️ ERROR CORREGIDO: Implementación mínima para _buildRecommendationsSection
  Widget _buildRecommendationsSection(
      AIProvider aiProvider, BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text('Sección de Recomendaciones (Pendiente de implementar)'),
      ),
    );
  }

  // ⚠️ ERROR CORREGIDO: Implementación mínima para _buildStoryGenerator
  Widget _buildStoryGenerator(
    AIProvider aiProvider,
    ChildProvider childProvider,
    BuildContext context,
  ) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
            'Sección de Generador de Historias (Pendiente de implementar)'),
      ),
    );
  }

  // ⚠️ ERROR CORREGIDO: Implementación mínima para _buildAdaptiveDifficulties
  Widget _buildAdaptiveDifficulties(
      AIProvider aiProvider, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dificultades Adaptativas',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...aiProvider.adaptiveDifficulties.entries.map((entry) => ListTile(
                  title: Text(_formatSkillName(entry.key)),
                  trailing: Text('Nivel ${entry.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  leading: const Icon(Icons.gamepad),
                )),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES PARA FORMATO ---

  String _formatSkillName(String key) {
    final names = {
      'cognitive_skills': 'Habilidades Cognitivas',
      'emotional_intelligence': 'Inteligencia Emocional',
      'attention_span': 'Atención y Concentración',
      'memory_capacity': 'Memoria y Retención',
      'pattern_recognition': 'Reconocimiento de Patrones',
      'social_understanding': 'Comprensión Social',
      'memory': 'Juego de Memoria',
      'emotions': 'Juego de Emociones',
      'patterns': 'Juego de Patrones',
    };
    return names[key] ?? key;
  }

  Color _getSkillColor(String skill) {
    final colors = {
      'cognitive_skills': Colors.blue,
      'emotional_intelligence': Colors.purple,
      'attention_span': Colors.green,
      'memory_capacity': Colors.orange,
      'pattern_recognition': Colors.red,
      'social_understanding': Colors.teal,
    };
    return colors[skill] ?? Colors.grey;
  }
}
