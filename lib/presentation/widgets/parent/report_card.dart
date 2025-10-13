import 'package:flutter/material.dart';
import 'package:koa_app/core/models/report_model.dart';
import 'package:koa_app/core/theme/colors.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final bool isSynced;

  const ReportCard({
    super.key,
    required this.report,
    required this.onTap,
    required this.onShare,
    required this.onDelete,
    this.isSynced = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSynced ? Colors.transparent : AppColors.warning,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con información principal
              _buildHeader(context),
              const SizedBox(height: 12),

              // Estadísticas rápidas
              _buildQuickStats(),
              const SizedBox(height: 12),

              // Análisis resumido
              _buildAnalysisPreview(),
              const SizedBox(height: 12),

              // Footer con acciones y estado
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono de reporte
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.assessment,
            color: AppColors.primaryGreen,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),

        // Información principal
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.childName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatDate(report.periodStart)} - ${_formatDate(report.periodEnd)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textGray),
              ),
              if (report.childSyndrome != null) ...[
                const SizedBox(height: 2),
                Text(
                  report.childSyndrome!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Estado de sincronización
        if (!isSynced)
          Icon(Icons.cloud_off, color: AppColors.warning, size: 16),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          Icons.timer,
          '${report.data.totalPlayTime} min',
          'Tiempo',
        ),
        _buildStatItem(
          Icons.play_arrow,
          '${report.data.sessionsCompleted}',
          'Sesiones',
        ),
        _buildStatItem(Icons.star, '${report.data.totalStars}', 'Estrellas'),
        _buildStatItem(
          Icons.check_circle,
          '${(report.data.completionRate * 100).toStringAsFixed(0)}%',
          'Completado',
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryGreen),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textGray),
        ),
      ],
    );
  }

  Widget _buildAnalysisPreview() {
    final strengths = report.analysis.strengths.entries.take(2).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis Destacado',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          if (strengths.isNotEmpty) ...[
            ...strengths.map((strength) => _buildStrengthItem(strength)),
          ] else if (report.analysis.overallProgress.isNotEmpty) ...[
            Text(
              report.analysis.overallProgress.length > 100
                  ? '${report.analysis.overallProgress.substring(0, 100)}...'
                  : report.analysis.overallProgress,
              style: TextStyle(fontSize: 11, color: AppColors.textGray),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            Text(
              'Sin análisis disponible',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textGray,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStrengthItem(MapEntry<String, double> strength) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.thumb_up, size: 12, color: AppColors.success),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${_formatSkillName(strength.key)} (${(strength.value * 100).toStringAsFixed(0)}%)',
              style: TextStyle(fontSize: 11, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        // Botón de compartir
        IconButton(
          onPressed: onShare,
          icon: Icon(Icons.share, size: 20, color: AppColors.primaryBlue),
          tooltip: 'Compartir reporte',
        ),

        // Botón de vista previa
        Expanded(
          child: TextButton.icon(
            onPressed: onTap,
            icon: Icon(
              Icons.visibility,
              size: 16,
              color: AppColors.primaryGreen,
            ),
            label: Text(
              'Ver Detalles',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // Botón de eliminar
        IconButton(
          onPressed: onDelete,
          icon: Icon(Icons.delete_outline, size: 20, color: AppColors.error),
          tooltip: 'Eliminar reporte',
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatSkillName(String skill) {
    final names = {
      'matematica': 'Matemática',
      'lenguaje': 'Lenguaje',
      'social': 'Habilidades Sociales',
      'emocional': 'Inteligencia Emocional',
      'atencion': 'Atención',
      'memoria': 'Memoria',
      'pattern_recognition': 'Reconocimiento de Patrones',
      'emotional_intelligence': 'Inteligencia Emocional',
      'cognitive_skills': 'Habilidades Cognitivas',
      'attention_span': 'Atención',
      'memory_capacity': 'Memoria',
      'social_understanding': 'Comprensión Social',
    };

    return names[skill] ?? skill;
  }
}
