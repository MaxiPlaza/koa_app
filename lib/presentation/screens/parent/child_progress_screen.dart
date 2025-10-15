import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koa_app/presentation/providers/child_provider.dart';
import 'package:koa_app/core/theme/colors.dart';
import 'package:koa_app/data/models/child_model.dart';
import 'package:koa_app/presentation/widgets/common/kova_mascot.dart';
import 'package:koa_app/presentation/widgets/parent/progress_chart.dart';
import 'reports_screen.dart';
import 'package:koa_app/presentation/widgets/common/custom_button.dart';
import 'package:koa_app/presentation/widgets/common/loading_indicator.dart';

class ChildProgressScreen extends StatefulWidget {
  final String? childId;

  const ChildProgressScreen({super.key, this.childId});

  @override
  State<ChildProgressScreen> createState() => _ChildProgressScreenState();
}

class _ChildProgressScreenState extends State<ChildProgressScreen> {
  final List<String> _timeFilters = ['Semana', 'Mes', '3 Meses', 'Año'];
  String _selectedTimeFilter = 'Mes';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChildData();
  }

  Future<void> _loadChildData() async {
    setState(() => _isLoading = true);

    final childProvider = context.read<ChildProvider>();
    await childProvider.loadChildData();

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final childProvider = context.read<ChildProvider>();
    final currentChild = childProvider.currentChild;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _isLoading
          ? const LoadingIndicator()
          : currentChild == null
              ? _buildNoChildState()
              : _buildProgressContent(currentChild),
    );
  }

  Widget _buildNoChildState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const KovaMascot(size: 120, expression: KovaExpression.thinking),
          const SizedBox(height: 24),
          const Text(
            'No se encontró el niño',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textGray,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No hay datos de progreso disponibles\npara mostrar en este momento.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: _loadChildData,
            text: 'Reintentar',
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressContent(ChildModel child) {
    final progress = child.progress;
    final skillLevels = progress.skillLevels;

    return CustomScrollView(
      slivers: [
        // AppBar personalizado
        SliverAppBar(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          expandedHeight: 200,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Progreso de ${child.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            background: _buildAppBarBackground(child),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.assessment),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportsScreen(),
                  ),
                );
              },
              tooltip: 'Generar Reporte',
            ),
          ],
        ),

        // Filtros de tiempo
        SliverToBoxAdapter(child: _buildTimeFilters()),

        // Resumen de estadísticas
        SliverToBoxAdapter(child: _buildStatsSummary(progress)),

        // Gráfico de habilidades
        if (skillLevels.isNotEmpty)
          SliverToBoxAdapter(child: _buildSkillsChart(skillLevels)),

        // Actividades recientes
        SliverToBoxAdapter(child: _buildRecentActivities(progress)),

        // Espacio final
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildAppBarBackground(ChildModel child) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.greenLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: 20,
            bottom: 20,
            child: KovaMascot(size: 80, expression: KovaExpression.celebrating),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${child.age} años • ${_getLearningStyleText(child.learningStyle)}',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                if (child.syndrome != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    child.syndrome!,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLearningStyleText(String learningStyle) {
    switch (learningStyle) {
      case 'visual':
        return 'Visual';
      case 'auditory':
        return 'Auditivo';
      case 'kinesthetic':
        return 'Kinestésico';
      default:
        return 'Visual';
    }
  }

  Widget _buildTimeFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _timeFilters.map((filter) {
          final isSelected = filter == _selectedTimeFilter;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTimeFilter = filter;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryGreen : Colors.grey,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsSummary(ChildProgress progress) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.timer,
            '${(progress.totalPlayTime / 60).toStringAsFixed(0)}h',
            'Tiempo Total',
            AppColors.primaryBlue,
          ),
          _buildStatItem(
            Icons.star,
            '${progress.totalStars}',
            'Estrellas',
            AppColors.kovaOrange,
          ),
          _buildStatItem(
            Icons.emoji_events,
            '${progress.skillLevels.length}',
            'Habilidades',
            AppColors.secondaryPurple,
          ),
          _buildStatItem(
            Icons.calendar_today,
            '${progress.recentSessions.length}',
            'Sesiones',
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSkillsChart(Map<String, double> skillLevels) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso por Habilidad',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Icon(Icons.bar_chart, color: AppColors.primaryGreen),
            ],
          ),
          const SizedBox(height: 16),
          SkillProgressChart(
            skillProgress: skillLevels,
            height: 200,
            showLabels: true,
            showValues: true,
          ),
          const SizedBox(height: 16),
          _buildSkillDetails(skillLevels),
        ],
      ),
    );
  }

  Widget _buildSkillDetails(Map<String, double> skillLevels) {
    final topSkills = skillLevels.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Habilidades Principales',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        ...topSkills.take(3).map((skill) {
          return _buildSkillProgressRow(skill.key, skill.value);
        }),
      ],
    );
  }

  Widget _buildSkillProgressRow(String skill, double progress) {
    final percentage = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _getSkillDisplayName(skill),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: _getSkillColor(skill),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: Text(
              '$percentage%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getSkillColor(skill),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSkillDisplayName(String skill) {
    final names = {
      'matematica': 'Matemáticas',
      'lenguaje': 'Lenguaje',
      'social': 'Habilidades Sociales',
      'emocional': 'Inteligencia Emocional',
      'atencion': 'Atención',
      'memoria': 'Memoria',
      'pattern_recognition': 'Reconocimiento de Patrones',
      'emotional_intelligence': 'Inteligencia Emocional',
      'cognitive_skills': 'Habilidades Cognitivas',
    };
    return names[skill] ?? skill;
  }

  Color _getSkillColor(String skill) {
    final colors = {
      'matematica': AppColors.primaryBlue,
      'lenguaje': AppColors.secondaryPurple,
      'social': AppColors.success,
      'emocional': AppColors.kovaOrange,
      'atencion': AppColors.info,
      'memoria': AppColors.primaryGreen,
    };
    return colors[skill] ?? AppColors.primaryGreen;
  }

  Widget _buildRecentActivities(ChildProgress progress) {
    final recentSessions = progress.recentSessions;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Actividades Recientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Icon(Icons.history, color: AppColors.primaryGreen),
            ],
          ),
          const SizedBox(height: 16),
          if (recentSessions.isEmpty)
            _buildEmptyActivities()
          else
            ...recentSessions.take(5).map((session) {
              return _buildActivityItem(session);
            }),
          if (recentSessions.length > 5) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Y ${recentSessions.length - 5} actividades más...',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyActivities() {
    return Column(
      children: [
        Icon(Icons.incomplete_circle, size: 50, color: Colors.grey[300]),
        const SizedBox(height: 12),
        Text(
          'No hay actividades recientes',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          'Completa algunas actividades para ver tu progreso aquí',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Session session) {
    // Asumiendo que Session tiene propiedades como activityName, date, duration, score
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: AppColors.primaryGreen,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.activityName ?? 'Actividad',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDuration(session.duration ?? 0)} • ${session.date != null ? _formatDate(session.date!) : 'Fecha no disponible'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (session.score != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${session.score!.toStringAsFixed(1)}⭐',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}min';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      return 'Hace ${difference.inDays ~/ 7} semanas';
    } else {
      return 'Hace ${difference.inDays ~/ 30} meses';
    }
  }
}
