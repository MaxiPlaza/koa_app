import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:koa_app/core/models/report_model.dart';

class LocalStorage {
  static const String _databaseName = 'KoaApp.db';
  static const int _databaseVersion = 1;

  // Singleton
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de reportes
    await db.execute('''
      CREATE TABLE reports (
        id TEXT PRIMARY KEY,
        childId TEXT NOT NULL,
        childName TEXT NOT NULL,
        childAge INTEGER NOT NULL,
        childSyndrome TEXT,
        generatedBy TEXT NOT NULL,
        generatedByName TEXT NOT NULL,
        userType TEXT NOT NULL,
        reportDate INTEGER NOT NULL,
        periodStart INTEGER NOT NULL,
        periodEnd INTEGER NOT NULL,
        totalPlayTime INTEGER NOT NULL,
        sessionsCompleted INTEGER NOT NULL,
        totalStars INTEGER NOT NULL,
        skillProgress TEXT NOT NULL,
        topActivities TEXT NOT NULL,
        completionRate REAL NOT NULL,
        engagementScore REAL NOT NULL,
        strengths TEXT NOT NULL,
        areasForImprovement TEXT NOT NULL,
        learningInsight TEXT NOT NULL,
        behavioralObservation TEXT NOT NULL,
        overallProgress TEXT NOT NULL,
        recommendations TEXT NOT NULL,
        pdfUrl TEXT,
        createdAt INTEGER NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabla de caché de datos para reportes
    await db.execute('''
      CREATE TABLE report_cache (
        childId TEXT PRIMARY KEY,
        progressData TEXT NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');
    await db.execute('''
  CREATE TABLE app_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
  )
''');
  }

  // ========== OPERACIONES DE REPORTES ==========

  Future<void> saveReport(ReportModel report) async {
    final db = await database;
    await db.insert(
      'reports',
      _reportToMap(report),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ReportModel>> getReports() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reports');
    return maps.map((map) => _reportFromMap(map)).toList();
  }

  Future<List<ReportModel>> getReportsByChildId(String childId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reports',
      where: 'childId = ?',
      whereArgs: [childId],
      orderBy: 'reportDate DESC',
    );
    return maps.map((map) => _reportFromMap(map)).toList();
  }

  Future<ReportModel?> getReportById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return _reportFromMap(maps.first);
  }

  Future<void> deleteReport(String id) async {
    final db = await database;
    await db.delete('reports', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateReportSyncStatus(String id, bool isSynced) async {
    final db = await database;
    await db.update(
      'reports',
      {'isSynced': isSynced ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CACHÉ DE DATOS PARA REPORTES ==========

  Future<void> cacheProgressData({
    required String childId,
    required Map<String, dynamic> progressData,
  }) async {
    final db = await database;
    await db.insert('report_cache', {
      'childId': childId,
      'progressData': _encodeJson(progressData),
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getCachedProgressData(String childId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'report_cache',
      where: 'childId = ?',
      whereArgs: [childId],
    );

    if (maps.isEmpty) return null;

    final data = maps.first;
    final lastUpdated = DateTime.fromMillisecondsSinceEpoch(
      data['lastUpdated'],
    );
    final now = DateTime.now();

    // Si los datos tienen más de 1 hora, considerarlos obsoletos
    if (now.difference(lastUpdated).inHours > 1) {
      await db.delete(
        'report_cache',
        where: 'childId = ?',
        whereArgs: [childId],
      );
      return null;
    }

    return _decodeJson(data['progressData']);
  }

  Future<void> saveSetting(String key, dynamic value) async {
    final db = await database;
    await db.insert('app_settings', {
      'key': key,
      'value': value.toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<dynamic> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isEmpty) return null;
    return maps.first['value'];
  }

  Future<bool> getBoolSetting(String key, {bool defaultValue = false}) async {
    final value = await getSetting(key);
    if (value == null) return defaultValue;
    return value == 'true';
  }
  // ========== MÉTODOS DE CONVERSIÓN ==========

  Map<String, dynamic> _reportToMap(ReportModel report) {
    return {
      'id': report.id,
      'childId': report.childId,
      'childName': report.childName,
      'childAge': report.childAge,
      'childSyndrome': report.childSyndrome,
      'generatedBy': report.generatedBy,
      'generatedByName': report.generatedByName,
      'userType': report.userType,
      'reportDate': report.reportDate.millisecondsSinceEpoch,
      'periodStart': report.periodStart.millisecondsSinceEpoch,
      'periodEnd': report.periodEnd.millisecondsSinceEpoch,
      'totalPlayTime': report.data.totalPlayTime,
      'sessionsCompleted': report.data.sessionsCompleted,
      'totalStars': report.data.totalStars,
      'skillProgress': _encodeJson(report.data.skillProgress),
      'topActivities': _encodeJson(
        report.data.topActivities.map((a) => a.toMap()).toList(),
      ),
      'completionRate': report.data.completionRate,
      'engagementScore': report.data.engagementScore,
      'strengths': _encodeJson(report.analysis.strengths),
      'areasForImprovement': _encodeJson(report.analysis.areasForImprovement),
      'learningInsight': report.analysis.learningInsight,
      'behavioralObservation': report.analysis.behavioralObservation,
      'overallProgress': report.analysis.overallProgress,
      'recommendations': _encodeJson(
        report.recommendations.map((r) => r.toMap()).toList(),
      ),
      'pdfUrl': report.pdfUrl,
      'createdAt': report.createdAt.millisecondsSinceEpoch,
      'isSynced': report.isSynced ? 1 : 0,
    };
  }

  ReportModel _reportFromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'],
      childId: map['childId'],
      childName: map['childName'],
      childAge: map['childAge'],
      childSyndrome: map['childSyndrome'],
      generatedBy: map['generatedBy'],
      generatedByName: map['generatedByName'],
      userType: map['userType'],
      reportDate: DateTime.fromMillisecondsSinceEpoch(map['reportDate']),
      periodStart: DateTime.fromMillisecondsSinceEpoch(map['periodStart']),
      periodEnd: DateTime.fromMillisecondsSinceEpoch(map['periodEnd']),
      data: ReportData(
        totalPlayTime: map['totalPlayTime'],
        sessionsCompleted: map['sessionsCompleted'],
        totalStars: map['totalStars'],
        skillProgress: Map<String, double>.from(
          _decodeJson(map['skillProgress']) ?? {},
        ),
        topActivities: List<ActivitySummary>.from(
          (_decodeJson(map['topActivities']) ?? []).map(
            (x) => ActivitySummary.fromMap(x),
          ),
        ),
        completionRate: map['completionRate'],
        engagementScore: map['engagementScore'],
      ),
      analysis: ReportAnalysis(
        strengths: Map<String, double>.from(
          _decodeJson(map['strengths']) ?? {},
        ),
        areasForImprovement: Map<String, double>.from(
          _decodeJson(map['areasForImprovement']) ?? {},
        ),
        learningInsight: map['learningInsight'],
        behavioralObservation: map['behavioralObservation'],
        overallProgress: map['overallProgress'],
      ),
      recommendations: List<AIRecommendation>.from(
        (_decodeJson(map['recommendations']) ?? []).map(
          (x) => AIRecommendation.fromMap(x),
        ),
      ),
      pdfUrl: map['pdfUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isSynced: map['isSynced'] == 1,
    );
  }

  String _encodeJson(dynamic data) {
    return const JsonEncoder().convert(data);
  }

  dynamic _decodeJson(String jsonString) {
    return const JsonDecoder().convert(jsonString);
  }

  // ========== MÉTODOS DE UTILIDAD ==========

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('reports');
    await db.delete('report_cache');
  }

  Future<int> getReportCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM reports'),
    );
    return count ?? 0;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
