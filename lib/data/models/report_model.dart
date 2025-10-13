import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koa_app/core/models/child_model.dart';
import 'package:koa_app/core/models/user_model.dart';

class ReportModel {
  final String id;
  final String childId;
  final String childName;
  final int childAge;
  final String? childSyndrome;
  final String generatedBy; // User ID
  final String generatedByName;
  final String userType; // 'parent' o 'professional'
  final DateTime reportDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final ReportData data;
  final ReportAnalysis analysis;
  final List<AIRecommendation> recommendations;
  final String? pdfUrl;
  final DateTime createdAt;
  final bool isSynced;

  ReportModel({
    required this.id,
    required this.childId,
    required this.childName,
    required this.childAge,
    this.childSyndrome,
    required this.generatedBy,
    required this.generatedByName,
    required this.userType,
    required this.reportDate,
    required this.periodStart,
    required this.periodEnd,
    required this.data,
    required this.analysis,
    required this.recommendations,
    this.pdfUrl,
    required this.createdAt,
    this.isSynced = false,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] ?? '',
      childId: map['childId'] ?? '',
      childName: map['childName'] ?? '',
      childAge: map['childAge'] ?? 0,
      childSyndrome: map['childSyndrome'],
      generatedBy: map['generatedBy'] ?? '',
      generatedByName: map['generatedByName'] ?? '',
      userType: map['userType'] ?? 'parent',
      reportDate: (map['reportDate'] as Timestamp).toDate(),
      periodStart: (map['periodStart'] as Timestamp).toDate(),
      periodEnd: (map['periodEnd'] as Timestamp).toDate(),
      data: ReportData.fromMap(map['data'] ?? {}),
      analysis: ReportAnalysis.fromMap(map['analysis'] ?? {}),
      recommendations: List<AIRecommendation>.from(
        (map['recommendations'] ?? []).map((x) => AIRecommendation.fromMap(x)),
      ),
      pdfUrl: map['pdfUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isSynced: map['isSynced'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'childName': childName,
      'childAge': childAge,
      'childSyndrome': childSyndrome,
      'generatedBy': generatedBy,
      'generatedByName': generatedByName,
      'userType': userType,
      'reportDate': Timestamp.fromDate(reportDate),
      'periodStart': Timestamp.fromDate(periodStart),
      'periodEnd': Timestamp.fromDate(periodEnd),
      'data': data.toMap(),
      'analysis': analysis.toMap(),
      'recommendations': recommendations.map((x) => x.toMap()).toList(),
      'pdfUrl': pdfUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isSynced': isSynced,
    };
  }

  // Crear reporte vacío
  factory ReportModel.empty() {
    final now = DateTime.now();
    return ReportModel(
      id: '',
      childId: '',
      childName: '',
      childAge: 0,
      generatedBy: '',
      generatedByName: '',
      userType: 'parent',
      reportDate: now,
      periodStart: now.subtract(const Duration(days: 30)),
      periodEnd: now,
      data: ReportData.empty(),
      analysis: ReportAnalysis.empty(),
      recommendations: [],
      createdAt: now,
    );
  }
}

class ReportData {
  final int totalPlayTime; // minutos
  final int sessionsCompleted;
  final int totalStars;
  final Map<String, double> skillProgress; // habilidades y su progreso
  final List<ActivitySummary> topActivities;
  final double completionRate;
  final double engagementScore;

  ReportData({
    required this.totalPlayTime,
    required this.sessionsCompleted,
    required this.totalStars,
    required this.skillProgress,
    required this.topActivities,
    required this.completionRate,
    required this.engagementScore,
  });

  factory ReportData.fromMap(Map<String, dynamic> map) {
    return ReportData(
      totalPlayTime: map['totalPlayTime'] ?? 0,
      sessionsCompleted: map['sessionsCompleted'] ?? 0,
      totalStars: map['totalStars'] ?? 0,
      skillProgress: Map<String, double>.from(map['skillProgress'] ?? {}),
      topActivities: List<ActivitySummary>.from(
        (map['topActivities'] ?? []).map((x) => ActivitySummary.fromMap(x)),
      ),
      completionRate: (map['completionRate'] ?? 0.0).toDouble(),
      engagementScore: (map['engagementScore'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalPlayTime': totalPlayTime,
      'sessionsCompleted': sessionsCompleted,
      'totalStars': totalStars,
      'skillProgress': skillProgress,
      'topActivities': topActivities.map((x) => x.toMap()).toList(),
      'completionRate': completionRate,
      'engagementScore': engagementScore,
    };
  }

  factory ReportData.empty() {
    return ReportData(
      totalPlayTime: 0,
      sessionsCompleted: 0,
      totalStars: 0,
      skillProgress: {},
      topActivities: [],
      completionRate: 0.0,
      engagementScore: 0.0,
    );
  }
}

class ReportAnalysis {
  final Map<String, double> strengths;
  final Map<String, double> areasForImprovement;
  final String learningInsight;
  final String behavioralObservation;
  final String overallProgress;

  ReportAnalysis({
    required this.strengths,
    required this.areasForImprovement,
    required this.learningInsight,
    required this.behavioralObservation,
    required this.overallProgress,
  });

  factory ReportAnalysis.fromMap(Map<String, dynamic> map) {
    return ReportAnalysis(
      strengths: Map<String, double>.from(map['strengths'] ?? {}),
      areasForImprovement: Map<String, double>.from(
        map['areasForImprovement'] ?? {},
      ),
      learningInsight: map['learningInsight'] ?? '',
      behavioralObservation: map['behavioralObservation'] ?? '',
      overallProgress: map['overallProgress'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'strengths': strengths,
      'areasForImprovement': areasForImprovement,
      'learningInsight': learningInsight,
      'behavioralObservation': behavioralObservation,
      'overallProgress': overallProgress,
    };
  }

  factory ReportAnalysis.empty() {
    return ReportAnalysis(
      strengths: {},
      areasForImprovement: {},
      learningInsight: '',
      behavioralObservation: '',
      overallProgress: '',
    );
  }
}

class AIRecommendation {
  final String type;
  final String priority; // 'high', 'medium', 'low'
  final String title;
  final String description;
  final List<String> suggestedActivities;
  final String reason;

  AIRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.suggestedActivities,
    required this.reason,
  });

  factory AIRecommendation.fromMap(Map<String, dynamic> map) {
    return AIRecommendation(
      type: map['type'] ?? '',
      priority: map['priority'] ?? 'medium',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      suggestedActivities: List<String>.from(map['suggestedActivities'] ?? []),
      reason: map['reason'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'priority': priority,
      'title': title,
      'description': description,
      'suggestedActivities': suggestedActivities,
      'reason': reason,
    };
  }
}

class ActivitySummary {
  final String activityId;
  final String activityName;
  final int sessions;
  final double avgScore;
  final double completionRate;

  ActivitySummary({
    required this.activityId,
    required this.activityName,
    required this.sessions,
    required this.avgScore,
    required this.completionRate,
  });

  factory ActivitySummary.fromMap(Map<String, dynamic> map) {
    return ActivitySummary(
      activityId: map['activityId'] ?? '',
      activityName: map['activityName'] ?? '',
      sessions: map['sessions'] ?? 0,
      avgScore: (map['avgScore'] ?? 0.0).toDouble(),
      completionRate: (map['completionRate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activityId': activityId,
      'activityName': activityName,
      'sessions': sessions,
      'avgScore': avgScore,
      'completionRate': completionRate,
    };
  }
}
