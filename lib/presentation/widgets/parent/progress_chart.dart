import 'package:flutter/material.dart';
import 'package:koa_app/core/theme/colors.dart';
import 'dart:math';

class SkillProgressChart extends StatelessWidget {
  final Map<String, double> skillProgress;
  final double height;
  final bool showLabels;
  final bool showValues;

  const SkillProgressChart({
    super.key,
    required this.skillProgress,
    this.height = 200,
    this.showLabels = true,
    this.showValues = true,
  });

  @override
  Widget build(BuildContext context) {
    final entries = skillProgress.entries.toList();

    if (entries.isEmpty) {
      return _buildEmptyChart();
    }

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (showLabels) ...[
            Text(
              'Progreso por Habilidad',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: entries.map((entry) {
                return _buildBar(entry.key, entry.value, entries.length);
              }).toList(),
            ),
          ),
          if (showLabels) ...[
            const SizedBox(height: 8),
            _buildSkillLabels(entries),
          ],
        ],
      ),
    );
  }

  Widget _buildBar(String skill, double progress, int totalBars) {
    final percentage = (progress * 100).clamp(0.0, 100.0);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            if (showValues) ...[
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Expanded(
              child: Container(
                width: double.infinity,
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  height: progress * 100, // Altura proporcional al progreso
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryGreen, AppColors.greenLight],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillLabels(List<MapEntry<String, double>> entries) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: entries.map((entry) {
        return Expanded(
          child: Text(
            _abbreviateSkill(entry.key),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textGray,
            ),
            maxLines: 2,
          ),
        );
      }).toList(),
    );
  }

  String _abbreviateSkill(String skill) {
    final abbreviations = {
      'matematica': 'Matemática',
      'lenguaje': 'Lenguaje',
      'social': 'Social',
      'emocional': 'Emocional',
      'atencion': 'Atención',
      'memoria': 'Memoria',
      'pattern_recognition': 'Patrones',
      'emotional_intelligence': 'Emociones',
      'cognitive_skills': 'Cognitivo',
      'attention_span': 'Atención',
      'memory_capacity': 'Memoria',
      'social_understanding': 'Social',
    };
    return abbreviations[skill] ?? skill;
  }

  Widget _buildEmptyChart() {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textGray.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 40,
              color: AppColors.textGray.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay datos de progreso',
              style: TextStyle(color: AppColors.textGray, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressTimelineChart extends StatelessWidget {
  final List<double> weeklyProgress;
  final Color lineColor;
  final double height;

  const ProgressTimelineChart({
    super.key,
    required this.weeklyProgress,
    this.lineColor = AppColors.primaryBlue,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    if (weeklyProgress.isEmpty) {
      return _buildEmptyTimeline();
    }

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evolución Semanal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              size: Size(double.infinity, height - 60),
              painter: _TimelineChartPainter(
                dataPoints: weeklyProgress,
                lineColor: lineColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTimeline() {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textGray.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          'No hay datos de evolución',
          style: TextStyle(color: AppColors.textGray, fontSize: 14),
        ),
      ),
    );
  }
}

class _TimelineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;

  _TimelineChartPainter({required this.dataPoints, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = AppColors.textGray.withOpacity(0.2)
      ..strokeWidth = 1;

    // Dibujar grid horizontal
    for (int i = 0; i <= 4; i++) {
      final y = size.height - (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();

    if (dataPoints.length == 1) {
      // Solo un punto
      final x = size.width / 2;
      final y = size.height - (dataPoints[0] * size.height);
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      return;
    }

    // Calcular puntos
    final points = List.generate(dataPoints.length, (index) {
      final x = (size.width / (dataPoints.length - 1)) * index;
      final y = size.height - (dataPoints[index] * size.height);
      return Offset(x, y);
    });

    // Dibujar línea
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Dibujar puntos
    for (final point in points) {
      canvas.drawCircle(point, 5, dotPaint);
      canvas.drawCircle(point, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ActivityDistributionChart extends StatelessWidget {
  final Map<String, int> activityDistribution;
  final double size;

  const ActivityDistributionChart({
    super.key,
    required this.activityDistribution,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    if (activityDistribution.isEmpty) {
      return _buildEmptyChart();
    }

    final total = activityDistribution.values.reduce((a, b) => a + b);
    final colors = [
      AppColors.primaryGreen,
      AppColors.secondaryPurple,
      AppColors.primaryBlue,
      AppColors.kovaOrange,
      AppColors.success,
    ];

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _PieChartPainter(
          distribution: activityDistribution,
          colors: colors,
          total: total.toDouble(),
        ),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      width: 150,
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textGray.withOpacity(0.3)),
      ),
      child: Center(
        child: Icon(
          Icons.pie_chart,
          size: 40,
          color: AppColors.textGray.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, int> distribution;
  final List<Color> colors;
  final double total;

  _PieChartPainter({
    required this.distribution,
    required this.colors,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;

    var startAngle = -pi / 2; // Comenzar desde la parte superior

    final entries = distribution.entries.toList();

    for (int i = 0; i < entries.length; i++) {
      final percentage = entries[i].value / total;
      final sweepAngle = 2 * pi * percentage;

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      // Dibujar segmento
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Dibujar círculo blanco en el centro para efecto donut
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
