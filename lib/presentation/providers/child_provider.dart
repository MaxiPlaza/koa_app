import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/child_model.dart';
import '../data/models/activity_model.dart';
import '../data/models/game_session.dart';

class ChildProvider with ChangeNotifier {
  ChildModel? _currentChild;
  List<GameSession> _gameSessions = [];
  bool _isLoading = false;

  ChildModel? get currentChild => _currentChild;
  List<GameSession> get gameSessions => _gameSessions;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> setCurrentChild(ChildModel child) async {
    _currentChild = child;
    await _loadGameSessions();
    notifyListeners();
  }

  Future<void> _loadGameSessions() async {
    if (_currentChild == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('sessions')
          .where('childId', isEqualTo: _currentChild!.id)
          .orderBy('startTime', descending: true)
          .limit(50)
          .get();

      _gameSessions = querySnapshot.docs
          .map((doc) => GameSession.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading game sessions: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveGameSession({
    required String activityId,
    required int score,
    required int stars,
    required Map<String, dynamic> performance,
  }) async {
    if (_currentChild == null) return;

    try {
      final session = GameSession(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        childId: _currentChild!.id,
        activityId: activityId,
        startTime: DateTime.now().subtract(
          const Duration(minutes: 5),
        ), // Ejemplo
        endTime: DateTime.now(),
        score: score,
        stars: stars,
        performance: performance,
        completed: true,
      );

      await _firestore
          .collection('sessions')
          .doc(session.id)
          .set(session.toMap());

      // Actualizar progreso del niño
      await _updateChildProgress(session);

      _gameSessions.insert(0, session);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error saving game session: $e');
      }
    }
  }

  Future<void> _updateChildProgress(GameSession session) async {
    if (_currentChild == null) return;

    try {
      final childRef = _firestore.collection('children').doc(_currentChild!.id);

      await childRef.update({
        'progress.totalPlayTime': FieldValue.increment(
          session.durationInMinutes,
        ),
        'progress.totalStars': FieldValue.increment(session.stars),
        'progress.lastSession': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Aquí podrías agregar lógica para actualizar skillLevels basado en el performance
    } catch (e) {
      if (kDebugMode) {
        print('Error updating child progress: $e');
      }
    }
  }

  List<GameSession> getSessionsByActivity(String activityId) {
    return _gameSessions
        .where((session) => session.activityId == activityId)
        .toList();
  }

  double getProgressForSkill(String skill) {
    // Lógica para calcular progreso por habilidad
    // Basado en las sesiones de juego
    return 0.7; // Ejemplo
  }
}
