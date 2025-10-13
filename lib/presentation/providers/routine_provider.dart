import 'package:flutter/foundation.dart';
import 'package:koa_app/core/models/routine_model.dart';
import 'package:koa_app/core/services/routine_repository.dart';

class RoutineProvider with ChangeNotifier {
  final RoutineRepository _routineRepository;

  RoutineProvider(this._routineRepository);

  List<RoutineModel> _routines = [];
  List<RoutineModel> get routines => _routines;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  RoutineModel? _currentRoutine;
  RoutineModel? get currentRoutine => _currentRoutine;

  // Cargar rutinas para un niño específico
  Future<void> loadRoutines(String childId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _routines = await _routineRepository.getRoutinesByChildId(childId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar nueva rutina
  Future<void> addRoutine(RoutineModel routine) async {
    try {
      await _routineRepository.saveRoutine(routine);
      _routines.add(routine);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Actualizar rutina existente
  Future<void> updateRoutine(RoutineModel routine) async {
    try {
      await _routineRepository.saveRoutine(routine);
      final index = _routines.indexWhere((r) => r.id == routine.id);
      if (index != -1) {
        _routines[index] = routine;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Eliminar rutina
  Future<void> deleteRoutine(String routineId) async {
    try {
      await _routineRepository.deleteRoutine(routineId);
      _routines.removeWhere((r) => r.id == routineId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Marcar tarea como completada
  Future<void> toggleTaskCompletion({
    required String routineId,
    required String taskId,
    required bool completed,
  }) async {
    try {
      final routine = _routines.firstWhere((r) => r.id == routineId);
      final updatedRoutine = routine.markTaskCompleted(taskId, completed);
      await updateRoutine(updatedRoutine);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Reiniciar rutina para nuevo día
  Future<void> resetRoutine(String routineId) async {
    try {
      final routine = _routines.firstWhere((r) => r.id == routineId);
      final resetRoutine = routine.resetForNewDay();
      await updateRoutine(resetRoutine);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Establecer rutina actual
  void setCurrentRoutine(RoutineModel? routine) {
    _currentRoutine = routine;
    notifyListeners();
  }

  // Obtener rutinas para hoy
  List<RoutineModel> get todayRoutines {
    return _routines
        .where((routine) => routine.schedule.isScheduledToday)
        .toList();
  }

  // Obtener rutinas activas
  List<RoutineModel> get activeRoutines {
    return _routines.where((routine) => routine.isActive).toList();
  }

  // Obtener rutinas completadas hoy
  List<RoutineModel> get completedTodayRoutines {
    return _routines.where((routine) => routine.isCompletedToday).toList();
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Buscar rutina por ID
  RoutineModel? getRoutineById(String routineId) {
    try {
      return _routines.firstWhere((r) => r.id == routineId);
    } catch (e) {
      return null;
    }
  }
}
