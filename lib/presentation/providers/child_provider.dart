import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart'; // Mantener el import para Provider
import 'package:koa_app/data/models/child_model.dart';
import 'package:koa_app/data/models/game_session.dart'; // Asumiendo que GameSession es el modelo para sessions
// Importa las constantes de Firebase
import 'package:koa_app/core/constants/constants/firebase_constants.dart';

class ChildProvider with ChangeNotifier {
  ChildModel? _currentChild;
  // ADDED: Lista de niños para resolver los errores en routines_screen.dart
  List<ChildModel> _children = [];
  List<GameSession> _gameSessions = [];
  bool _isLoading = false;
  String? _error;

  ChildModel? get currentChild => _currentChild;
  List<ChildModel> get children => _children; // Getter corregido
  List<GameSession> get gameSessions => _gameSessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔴 IMPORTANTE: FUNCIÓN MARCADOR DE POSICIÓN
  // DEBES REEMPLAZAR ESTA FUNCIÓN CON TU LÓGICA DE AUTENTICACIÓN REAL
  // (e.g., usando FirebaseAuth.instance.currentUser!.uid)
  String _getCurrentUserId() {
    // El ID del padre debe obtenerse de tu AuthProvider
    return 'YOUR_CURRENT_PARENT_ID';
  }

// ----------------------------------------------------------------------
// MARKER: LÓGICA DE CARGA DE NIÑOS DESDE FIRESTORE (IMPLEMENTACIÓN COMPLETA)
// ----------------------------------------------------------------------

  Future<void> loadChildren() async {
    final parentId = _getCurrentUserId();

    // Validación básica
    if (parentId.isEmpty || parentId == 'YOUR_CURRENT_PARENT_ID') {
      _error = 'Error: ID del padre no disponible o no configurado.';
      if (kDebugMode) print(_error);
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Consulta a la colección 'children', filtrando por 'parentId'
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.childrenCollection)
          .where(FirebaseConstants.parentIdField, isEqualTo: parentId)
          .orderBy(FirebaseConstants.createdAtField, descending: false)
          .get();

      _children = querySnapshot.docs.map((doc) {
        // Mapear el ID del documento al campo 'id' de ChildModel
        final data = doc.data();
        final childMap = Map<String, dynamic>.from(data)..['id'] = doc.id;
        return ChildModel.fromMap(childMap);
      }).toList();

      // Si es la primera carga y hay niños, establecer el primer niño como el actual
      if (_children.isNotEmpty && _currentChild == null) {
        _currentChild = _children.first;
      }
      _error = null;
    } catch (e) {
      _error = 'Error al cargar los niños: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// ----------------------------------------------------------------------
// MARKER: MÉTODOS RELACIONADOS CON EL NIÑO
// ----------------------------------------------------------------------

  Future<void> setCurrentChild(ChildModel child) async {
    _currentChild = child;
    await _loadGameSessions();
    notifyListeners();
  }

  Future<void> loadChildData() async {
    if (_currentChild == null) {
      // Intenta cargar los niños si no hay uno actual
      if (_children.isEmpty) {
        await loadChildren();
        if (_currentChild == null) return;
      } else {
        return;
      }
    }
    await _loadGameSessions();
  }

// ----------------------------------------------------------------------
// MARKER: LÓGICA DE CARGA DE SESIONES DE JUEGO
// ----------------------------------------------------------------------

  Future<void> _loadGameSessions() async {
    if (_currentChild == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // Consulta a la colección 'sessions', filtrando por 'childId'
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.sessionsCollection)
          .where(FirebaseConstants.childIdField, isEqualTo: _currentChild!.id)
          .orderBy('startTime',
              descending: true) // 'startTime' no está en constantes
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

// ----------------------------------------------------------------------
// MARKER: LÓGICA DE GUARDAR SESIONES Y ACTUALIZAR PROGRESO
// ----------------------------------------------------------------------

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
        startTime: DateTime.now().subtract(const Duration(minutes: 5)),
        endTime: DateTime.now(),
        score: score,
        stars: stars,
        performance: performance,
        completed: true,
      );

      await _firestore
          .collection(FirebaseConstants.sessionsCollection)
          .doc(session.id)
          .set(session.toMap());

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
      final childRef = _firestore
          .collection(FirebaseConstants.childrenCollection)
          .doc(_currentChild!.id);

      // Usando las constantes para los campos de fecha y actualización
      await childRef.update({
        'progress.totalPlayTime': FieldValue.increment(
          session.durationInMinutes,
        ),
        'progress.totalStars': FieldValue.increment(session.stars),
        'progress.lastSession': Timestamp.now(),
        FirebaseConstants.updatedAtField: Timestamp.now(),
      });
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
    return 0.7;
  }
}
