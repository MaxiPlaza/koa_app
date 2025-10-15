import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:koa_app/data/models/child_model.dart';
import 'package:koa_app/data/models/user_model.dart';
import 'package:koa_app/data/models/report_model.dart';
import 'package:koa_app/core/services/ai_service.dart' as ai;
import 'package:koa_app/core/services/local_storage.dart';
import 'package:koa_app/data/models/game_session.dart';
import 'package:flutter/material.dart';

class PdfService {
  final ai.AIService _aiService = ai.AIService();
  final LocalStorage _localStorage = LocalStorage();

  // 🎯 Generar reporte completo
  Future<ReportModel> generateReport({
    required ChildModel child,
    required UserModel generatedBy,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    try {
      // Obtener datos para el reporte
      final reportData = await _collectReportData(
        child,
        periodStart,
        periodEnd,
      );

      // Generar análisis IA
      final aiAnalysis = await _generateAIAnalysis(child, reportData);

      // Generar PDF
      final pdfFile = await _createPdfDocument(
        child: child,
        generatedBy: generatedBy,
        periodStart: periodStart,
        periodEnd: periodEnd,
        data: reportData,
        aiData: aiAnalysis,
      );

      // Crear modelo del reporte
      final report = ReportModel(
        id: 'report_${DateTime.now().millisecondsSinceEpoch}',
        childId: child.id,
        childName: child.name,
        childAge: child.age,
        childSyndrome: child.syndrome,
        generatedBy: generatedBy.uid,
        generatedByName: generatedBy.name,
        userType: generatedBy.userType,
        reportDate: DateTime.now(),
        periodStart: periodStart,
        periodEnd: periodEnd,
        data: reportData,
        analysis: aiAnalysis.analysis,
        recommendations: aiAnalysis.recommendations,
        pdfUrl: pdfFile.path,
        createdAt: DateTime.now(),
        isSynced: false,
      );

      return report;
    } catch (e) {
      throw Exception('Error generando reporte PDF: $e');
    }
  }

  // CORRECCIÓN 16: Método _buildActivitiesSummary
  pw.Widget _buildActivitiesSummary(Map<String, int> topActivities) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 2,
          child: pw.Text(
            'RESUMEN DE ACTIVIDADES',
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey700),
          ),
        ),
        pw.SizedBox(height: 10),
        if (topActivities.isEmpty)
          pw.Text('No hay datos de actividades para este período.'),
        ...topActivities.entries
            .map((entry) => pw.Text('- ${entry.key}: ${entry.value} sesiones'))
            .toList(),
      ],
    );
  }

  // 📊 Recopilar datos para el reporte
  Future<ReportData> _collectReportData(
    ChildModel child,
    DateTime start,
    DateTime end,
  ) async {
    // En una implementación real, esto vendría de Firebase/local storage
    // Por ahora usamos datos de ejemplo basados en el progreso del niño

    final skillProgress = child.progress.skillLevels;

    // Calcular métricas adicionales
    final totalPlayTime = child.progress.totalPlayTime;
    final sessionsCompleted = child.progress.recentSessions.length;
    final totalStars = child.progress.totalStars;

    // Calcular tasa de finalización (ejemplo)
    final completedSessions = child.progress.recentSessions
        .where((session) => session.completed == true)
        .length;
    final completionRate =
        sessionsCompleted > 0 ? completedSessions / sessionsCompleted : 0.0;

    // Puntaje de engagement (ejemplo basado en estrellas y tiempo)
    final engagementScore = _calculateEngagementScore(
      totalPlayTime,
      totalStars,
      sessionsCompleted,
    );

    // Actividades más populares (ejemplo)
    final topActivities = _getTopActivities(child.progress.recentSessions);

    return ReportData(
      totalPlayTime: totalPlayTime,
      sessionsCompleted: sessionsCompleted,
      totalStars: totalStars,
      skillProgress: skillProgress,
      topActivities: topActivities,
      completionRate: completionRate,
      engagementScore: engagementScore,
    );
  }

  // 🧠 Generar análisis con IA
  Future<({ReportAnalysis analysis, List<AIRecommendation> recommendations})>
      _generateAIAnalysis(ChildModel child, ReportData data) async {
    try {
      // Convertir sesiones a formato que entienda AIService
      final sessions = child.progress.recentSessions.map((session) {
        return GameSession(
          activityId: session.activityId ?? 'unknown',
          score: ((session.score ?? 0.0) * 1000)
              .toInt(), // Convertir a escala similar
          durationInMinutes: session.duration ?? 0,
          completed: session.completed ?? false,
        );
      }).toList();

      // Análisis offline
      final progressAnalysis = _aiService.analyzeProgressOffline(sessions);

      // Generar recomendaciones
      final recommendations = await _aiService.generateRecommendations(
        analysis: progressAnalysis,
        childName: child.name,
        learningStyle: child.learningStyle,
        recentSessions: sessions,
      );

      // Crear análisis estructurado
      final analysis = ReportAnalysis(
        strengths: _extractStrengths(progressAnalysis),
        areasForImprovement: _extractAreasForImprovement(progressAnalysis),
        learningInsight: _generateLearningInsight(progressAnalysis, child),
        behavioralObservation: _generateBehavioralObservation(data, child),
        overallProgress: _generateOverallProgress(data, progressAnalysis),
      );

      return (analysis: analysis, recommendations: recommendations);
    } catch (e) {
      // Fallback si la IA falla
      return (
        analysis: ReportAnalysis(
          strengths: {'potencial': 0.7},
          areasForImprovement: {'desarrollo': 0.3},
          learningInsight:
              'El niño muestra buen progreso en las actividades realizadas.',
          behavioralObservation:
              'Se observa engagement positivo con las actividades.',
          overallProgress: 'Progreso constante en el período evaluado.',
        ),
        recommendations: [
          AIRecommendation(
            type: 'general',
            priority: 'medium',
            title: 'Continuar con actividades actuales',
            description: 'Mantener el ritmo actual de actividades',
            suggestedActivities: ['memory_1', 'emotional_1'],
            reason: 'Buena respuesta a las actividades actuales',
          ),
        ],
      );
    }
  }

  // 📄 Crear documento PDF
  Future<File> _createPdfDocument({
    required ChildModel child,
    required UserModel generatedBy,
    required DateTime periodStart,
    required DateTime periodEnd,
    required ReportData data,
    required ({
      ReportAnalysis analysis,
      List<AIRecommendation> recommendations
    }) aiData,
  }) async {
    final pdf = pw.Document();

    // Cargar logo KOVA (usaremos un placeholder por ahora)
    final Uint8List? kovaLogo = await _loadKovaLogo();

    // Página 1: Portada y Resumen Ejecutivo
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeaderPage(
            child: child,
            generatedBy: generatedBy,
            periodStart: periodStart,
            periodEnd: periodEnd,
            kovaLogo: kovaLogo,
          ),
          _buildExecutiveSummary(data, child),
          _buildSkillsOverview(data.skillProgress),
        ],
      ),
    );

    // Página 2: Análisis Detallado y Recomendaciones
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildDetailedAnalysis(aiData.analysis, data),
          _buildRecommendations(aiData.recommendations),
          _buildActivitiesSummary(data.topActivities),
        ],
      ),
    );

    // Página 3: Gráficos y Firma
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildChartsSection(data),
          _buildSignatureSection(generatedBy),
          _buildFooter(),
        ],
      ),
    );

    // Guardar PDF localmente
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/reporte_${child.name}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // 🎨 Construir página de encabezado
  pw.Widget _buildHeaderPage({
    required ChildModel child,
    required UserModel generatedBy,
    required DateTime periodStart,
    required DateTime periodEnd,
    required Uint8List? kovaLogo,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Logo y título
        pw.Row(
          children: [
            if (kovaLogo != null)
              pw.Image(pw.MemoryImage(kovaLogo), width: 60, height: 60),
            pw.SizedBox(width: 20),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'REPORTE DE PROGRESO KOA',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green,
                  ),
                ),
                pw.Text(
                  'Aprendizaje Neuroinclusivo',
                  style:
                      const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                ),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 30),

        // Información del niño
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            color: PdfColors.green.shade(100),
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'INFORMACIÓN DEL NIÑO',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green.shade(800),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Nombre:', child.name),
                      _buildInfoRow('Edad:', '${child.age} años'),
                      if (child.syndrome != null)
                        _buildInfoRow('Condición:', child.syndrome!),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        'Estilo de Aprendizaje:',
                        child.learningStyle,
                      ),
                      _buildInfoRow(
                        'Período:',
                        '${_formatDate(periodStart)} - ${_formatDate(periodEnd)}',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 20),

        // Generado por
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey.shade(300)),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'GENERADO POR',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey.shade(600),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                generatedBy.name,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '${generatedBy.userType.toUpperCase()} • ${_formatDate(DateTime.now())}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey.shade(600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 📊 Construir resumen ejecutivo
  pw.Widget _buildExecutiveSummary(ReportData data, ChildModel child) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue.shade(50),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RESUMEN EJECUTIVO',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue.shade(800),
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildMetricCard(
                'Tiempo Total',
                '${data.totalPlayTime} min',
                Icons.timer,
              ),
              _buildMetricCard(
                'Sesiones',
                '${data.sessionsCompleted}',
                Icons.play_arrow,
              ),
              _buildMetricCard('Estrellas', '${data.totalStars}', Icons.star),
              _buildMetricCard(
                'Completado',
                '${(data.completionRate * 100).toStringAsFixed(0)}%',
                Icons.check_circle,
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Text(
            _generateSummaryText(data, child),
            style: const pw.TextStyle(fontSize: 12),
            textAlign: pw.TextAlign.justify,
          ),
        ],
      ),
    );
  }

  // 🎯 Construir overview de habilidades
  pw.Widget _buildSkillsOverview(Map<String, double> skillProgress) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey.shade(300)),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PROGRESO POR HABILIDAD',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green.shade(800),
            ),
          ),
          pw.SizedBox(height: 15),
          ...skillProgress.entries.map((entry) {
            return pw.Column(
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        _formatSkillName(entry.key),
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Stack(
                        children: [
                          pw.Container(
                            height: 15,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey.shade(200),
                              borderRadius: pw.BorderRadius.circular(7),
                            ),
                          ),
                          pw.Container(
                            height: 15,
                            width: entry.value * 100, // Ancho proporcional
                            decoration: pw.BoxDecoration(
                              gradient: pw.LinearGradient(
                                colors: [
                                  PdfColors.green,
                                  PdfColors.green.shade(400),
                                ],
                              ),
                              borderRadius: pw.BorderRadius.circular(7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      '${(entry.value * 100).toStringAsFixed(0)}%',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }

  // 🔍 Construir análisis detallado
  pw.Widget _buildDetailedAnalysis(ReportAnalysis analysis, ReportData data) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.grey.shade(300)),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ANÁLISIS DETALLADO',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple.shade(800),
            ),
          ),
          pw.SizedBox(height: 15),

          // Fortalezas
          if (analysis.strengths.isNotEmpty) ...[
            pw.Text(
              'Fortalezas Destacadas:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green.shade(700),
              ),
            ),
            pw.SizedBox(height: 8),
            ...analysis.strengths.entries.map((strength) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Text(
                  '• ${_formatSkillName(strength.key)}: ${(strength.value * 100).toStringAsFixed(0)}%',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              );
            }),
            pw.SizedBox(height: 15),
          ],

          // Áreas de mejora
          if (analysis.areasForImprovement.isNotEmpty) ...[
            pw.Text(
              'Áreas de Oportunidad:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.orange.shade(700),
              ),
            ),
            pw.SizedBox(height: 8),
            ...analysis.areasForImprovement.entries.map((area) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Text(
                  '• ${_formatSkillName(area.key)}: ${(area.value * 100).toStringAsFixed(0)}%',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              );
            }),
            pw.SizedBox(height: 15),
          ],

          // Insight de aprendizaje
          pw.Text(
            'Observación de Aprendizaje:',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            analysis.learningInsight,
            style: const pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.justify,
          ),
          pw.SizedBox(height: 15),

          // Progreso general
          pw.Text(
            'Progreso General:',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            analysis.overallProgress,
            style: const pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.justify,
          ),
        ],
      ),
    );
  }

  // 💡 Construir recomendaciones
  pw.Widget _buildRecommendations(List<AIRecommendation> recommendations) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue.shade(50),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RECOMENDACIONES IA',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue.shade(800),
            ),
          ),
          pw.SizedBox(height: 15),
          ...recommendations.map((recommendation) {
            return pw.Container(
              width: double.infinity,
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey.shade(300)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: pw.BoxDecoration(
                          color: _getPriorityColor(recommendation.priority),
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Text(
                          recommendation.priority.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Text(
                          recommendation.title,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    recommendation.description,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Razón: ${recommendation.reason}',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey.shade(600),
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 📈 Construir sección de gráficos
  pw.Widget _buildChartsSection(ReportData data) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ANÁLISIS GRÁFICO',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green.shade(800),
            ),
          ),
          pw.SizedBox(height: 15),

          // Aquí irían los gráficos reales usando pw.Chart
          // Por ahora usamos representaciones simples
          _buildSimpleChart(data.skillProgress),
          pw.SizedBox(height: 20),
          _buildActivitiesChart(data.topActivities),
        ],
      ),
    );
  }

  // ✍️ Construir sección de firma
  pw.Widget _buildSignatureSection(UserModel generatedBy) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey.shade(300)),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'FIRMA Y VALIDACIÓN',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Generado por:',
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey),
                    ),
                    pw.Text(
                      generatedBy.name,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '${generatedBy.userType.toUpperCase()} • KOA App',
                      style: const pw.TextStyle(
                          fontSize: 9, color: PdfColors.grey),
                    ),
                  ],
                ),
              ),
              pw.Container(
                height: 50,
                child: pw.VerticalDivider(color: PdfColors.grey),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Fecha de generación:',
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey),
                    ),
                    pw.Text(
                      _formatDate(DateTime.now()),
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Container(
                      margin: const pw.EdgeInsets.only(top: 15),
                      height: 1,
                      color: PdfColors.grey,
                    ),
                    pw.Text(
                      'Firma',
                      style: const pw.TextStyle(
                          fontSize: 9, color: PdfColors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🦊 Construir pie de página
  pw.Widget _buildFooter() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.green.shade(50),
        borderRadius: const pw.BorderRadius.only(
          topLeft: pw.Radius.circular(10),
          topRight: pw.Radius.circular(10),
        ),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'KOA - Aprendizaje Neuroinclusivo',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green.shade(800),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Este reporte fue generado automáticamente por el sistema KOA. '
            'Para más información, contacte a soporte@koaapp.com',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey.shade(600)),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ========== MÉTODOS AUXILIARES ==========

  pw.Widget _buildInfoRow(String label, String value, pw.IconData icon) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey.shade(600),
            ),
          ),
          pw.SizedBox(width: 5),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _buildMetricCard(String label, String value, IconData icon) {
    return pw.Column(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue.shade(100),
            shape: pw.BoxShape.circle,
          ),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue.shade(800),
            ),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey.shade(600)),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  pw.Widget _buildSimpleChart(Map<String, double> data) {
    return pw.Container(
      height: 150,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey.shade(300)),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Distribución de Habilidades',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: data.entries.map((entry) {
              return pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Container(
                      height: entry.value * 100,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.green,
                        borderRadius: pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(3),
                          topRight: pw.Radius.circular(3),
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      _abbreviateSkill(entry.key),
                      style: const pw.TextStyle(fontSize: 6),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildActivitiesChart(List<ActivitySummary> activities) {
    return pw.Container(
      height: 120,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey.shade(300)),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Actividades Más Realizadas',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          ...activities.take(3).map((activity) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      activity.activityName,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      '${activity.sessions} sesiones',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      '${(activity.completionRate * 100).toStringAsFixed(0)}% completo',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<Uint8List?> _loadKovaLogo() async {
    try {
      // En una implementación real, cargaríamos el logo de KOVA
      // Por ahora retornamos null y usamos texto
      return null;
    } catch (e) {
      return null;
    }
  }

  // ========== MÉTODOS DE UTILIDAD ==========

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatSkillName(String skill) {
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
      'attention_span': 'Atención',
      'memory_capacity': 'Memoria',
      'social_understanding': 'Comprensión Social',
    };
    return names[skill] ?? skill;
  }

  String _abbreviateSkill(String skill) {
    final abbreviations = {
      'matematica': 'Mat',
      'lenguaje': 'Len',
      'social': 'Soc',
      'emocional': 'Emo',
      'atencion': 'Aten',
      'memoria': 'Mem',
      'pattern_recognition': 'Patr',
      'emotional_intelligence': 'Emo',
      'cognitive_skills': 'Cog',
      'attention_span': 'Aten',
      'memory_capacity': 'Mem',
      'social_understanding': 'Soc',
    };
    return abbreviations[skill] ?? skill.substring(0, 3);
  }

  PdfColor _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return PdfColors.red;
      case 'medium':
        return PdfColors.orange;
      case 'low':
        return PdfColors.blue;
      default:
        return PdfColors.grey;
    }
  }

  double _calculateEngagementScore(int playTime, int stars, int sessions) {
    if (sessions == 0) return 0.0;

    final timeScore = (playTime / sessions / 10).clamp(0.0, 1.0);
    final starScore = (stars / sessions / 5).clamp(0.0, 1.0);

    return (timeScore * 0.6 + starScore * 0.4).clamp(0.0, 1.0);
  }

  List<ActivitySummary> _getTopActivities(List<Session> sessions) {
    final activityCount = <String, int>{};
    final activityScores = <String, double>{};
    final activityCompletions = <String, int>{};

    for (final session in sessions) {
      activityCount[session.activityId] =
          (activityCount[session.activityId] ?? 0) + 1;
      activityScores[session.activityId] =
          (activityScores[session.activityId] ?? 0.0) + session.score;
      if (session.completed) {
        activityCompletions[session.activityId] =
            (activityCompletions[session.activityId] ?? 0) + 1;
      }
    }

    return activityCount.entries.map((entry) {
      final activityId = entry.key;
      final sessionsCount = entry.value;
      final avgScore = activityScores[activityId]! / sessionsCount;
      final completionRate = activityCompletions[activityId]! / sessionsCount;

      return ActivitySummary(
        activityId: activityId,
        activityName: _getActivityName(activityId),
        sessions: sessionsCount,
        avgScore: avgScore,
        completionRate: completionRate,
      );
    }).toList()
      ..sort((a, b) => b.sessions.compareTo(a.sessions))
      ..take(5);
  }

  String _getActivityName(String activityId) {
    final names = {
      'memory_1': 'Memory Cards - Emociones',
      'emotional_1': 'Encuentra la Emoción',
      'pattern_1': 'Secuencias de Patrones',
      'math_1': 'Juego de Matemáticas',
      'language_1': 'Juego de Lenguaje',
    };
    return names[activityId] ?? activityId;
  }

  String _generateSummaryText(ReportData data, ChildModel child) {
    final hours = data.totalPlayTime ~/ 60;
    final minutes = data.totalPlayTime % 60;

    return 'Durante el período evaluado, ${child.name} completó ${data.sessionsCompleted} sesiones '
        'con un total de ${hours}h ${minutes}min de tiempo de aprendizaje. '
        'Obtuvo ${data.totalStars} estrellas y mostró una tasa de finalización del ${(data.completionRate * 100).toStringAsFixed(0)}%. '
        'El nivel de engagement general fue del ${(data.engagementScore * 100).toStringAsFixed(0)}%.';
  }

  Map<String, double> _extractStrengths(Map<String, double> analysis) {
    return analysis.entries
        .where((entry) => entry.value > 0.7)
        .toList()
        .asMap()
        .map((key, value) => MapEntry(value.key, value.value));
  }

  Map<String, double> _extractAreasForImprovement(
    Map<String, double> analysis,
  ) {
    return analysis.entries
        .where((entry) => entry.value < 0.4)
        .toList()
        .asMap()
        .map((key, value) => MapEntry(value.key, value.value));
  }

  String _generateLearningInsight(
    Map<String, double> analysis,
    ChildModel child,
  ) {
    final strengths = _extractStrengths(analysis);
    if (strengths.isNotEmpty) {
      final topStrength = strengths.entries.first;
      return '${child.name} muestra una fortaleza notable en ${_formatSkillName(topStrength.key)} '
          'con un desempeño del ${(topStrength.value * 100).toStringAsFixed(0)}%. '
          'Esto sugiere que las actividades que involucran esta habilidad son especialmente efectivas.';
    }
    return 'El perfil de aprendizaje de ${child.name} muestra un desarrollo balanceado '
        'en las diferentes áreas evaluadas. Se recomienda continuar con la variedad actual de actividades.';
  }

  String _generateBehavioralObservation(ReportData data, ChildModel child) {
    if (data.engagementScore > 0.8) {
      return 'Se observa un alto nivel de engagement y motivación en las actividades. '
          '${child.name} mantiene atención sostenida y muestra interés activo.';
    } else if (data.engagementScore > 0.5) {
      return 'Nivel de engagement adecuado. ${child.name} participa consistentemente '
          'y completa las actividades con buena disposición.';
    } else {
      return 'Se sugiere explorar diferentes tipos de actividades para aumentar el engagement. '
          'La personalización basada en intereses podría mejorar la participación.';
    }
  }

  String _generateOverallProgress(
    ReportData data,
    Map<String, double> analysis,
  ) {
    final avgProgress =
        analysis.values.reduce((a, b) => a + b) / analysis.length;

    if (avgProgress > 0.7) {
      return 'Progreso excelente. El desarrollo en todas las áreas evaluadas muestra mejoras significativas '
          'y consistentes a lo largo del período.';
    } else if (avgProgress > 0.5) {
      return 'Progreso satisfactorio. Se observan mejoras constantes en la mayoría de las áreas '
          'con oportunidades de crecimiento identificadas.';
    } else {
      return 'Progreso en desarrollo. Se recomienda ajustar la dificultad y variedad de actividades '
          'para optimizar el ritmo de aprendizaje.';
    }
  }

  // 🚀 Funcionalidades adicionales

  Future<void> shareReport(ReportModel report) async {
    if (report.pdfUrl == null) {
      throw Exception('El reporte no tiene un PDF generado');
    }

    final file = File(report.pdfUrl!);
    if (!await file.exists()) {
      throw Exception('El archivo PDF no existe');
    }

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Reporte de Progreso - ${report.childName}',
      text: 'Te comparto el reporte de progreso de ${report.childName} '
          'generado con KOA App.',
    );
  }

  Future<void> printReport(ReportModel report) async {
    if (report.pdfUrl == null) {
      throw Exception('El reporte no tiene un PDF generado');
    }

    final file = File(report.pdfUrl!);
    final pdfData = await file.readAsBytes();

    await Printing.layoutPdf(onLayout: (format) => pdfData);
  }

  Future<Uint8List> previewReport(ReportModel report) async {
    if (report.pdfUrl == null) {
      throw Exception('El reporte no tiene un PDF generado');
    }

    final file = File(report.pdfUrl!);
    return await file.readAsBytes();
  }
}
