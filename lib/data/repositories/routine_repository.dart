import 'package:koa_app/data/models/routine_model.dart';

abstract class RoutineRepository {
  Future<List<RoutineModel>> getRoutinesByChildId(String childId);
  Future<void> saveRoutine(RoutineModel routine);
  Future<void> deleteRoutine(String routineId);
  Future<List<RoutineModel>> getPredefinedRoutines();
}

// Implementación con Firebase y almacenamiento local
class RoutineRepositoryImpl implements RoutineRepository {
  // TODO: Inyectar Firebase Firestore y LocalStorage

  @override
  Future<List<RoutineModel>> getRoutinesByChildId(String childId) async {
    // TODO: Implementar obtención desde Firebase + LocalStorage
    // Por ahora retornamos datos de ejemplo
    return [
      RoutineModel(
        id: '1',
        childId: childId,
        name: 'Rutina Matutina',
        description: 'Para empezar el día con energía',
        icon: '🌅',
        color: '#10B981',
        tasks: PredefinedRoutines.morningRoutineTEA,
        schedule: RoutineSchedule(
          daysOfWeek: [1, 2, 3, 4, 5],
          startTime: const TimeOfDay(hour: 7, minute: 0),
          endTime: const TimeOfDay(hour: 8, minute: 30),
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      RoutineModel(
        id: '2',
        childId: childId,
        name: 'Rutina Nocturna',
        description: 'Para prepararse para dormir',
        icon: '🌙',
        color: '#7E22CE',
        tasks: PredefinedRoutines.eveningRoutineTDAH,
        schedule: RoutineSchedule(
          daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
          startTime: const TimeOfDay(hour: 20, minute: 0),
          endTime: const TimeOfDay(hour: 21, minute: 0),
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<void> saveRoutine(RoutineModel routine) async {
    // TODO: Implementar guardado en Firebase y LocalStorage
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> deleteRoutine(String routineId) async {
    // TODO: Implementar eliminación en Firebase y LocalStorage
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<List<RoutineModel>> getPredefinedRoutines() async {
    // Rutinas predefinidas para diferentes necesidades
    return [
      RoutineModel(
        id: 'predefined_morning',
        childId: 'predefined',
        name: 'Rutina Matutina Estándar',
        description: 'Ideal para empezar el día organizado',
        icon: '🌅',
        color: '#10B981',
        tasks: PredefinedRoutines.morningRoutineTEA,
        schedule: RoutineSchedule(
          daysOfWeek: [1, 2, 3, 4, 5],
          startTime: const TimeOfDay(hour: 7, minute: 0),
          endTime: const TimeOfDay(hour: 8, minute: 0),
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      RoutineModel(
        id: 'predefined_evening',
        childId: 'predefined',
        name: 'Rutina Nocturna Relajante',
        description: 'Para una transición suave al sueño',
        icon: '🌙',
        color: '#7E22CE',
        tasks: PredefinedRoutines.eveningRoutineTDAH,
        schedule: RoutineSchedule(
          daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
          startTime: const TimeOfDay(hour: 20, minute: 0),
          endTime: const TimeOfDay(hour: 21, minute: 0),
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      RoutineModel(
        id: 'predefined_sensory',
        childId: 'predefined',
        name: 'Rutina Sensorial',
        description: 'Para regular el sistema sensorial',
        icon: '👐',
        color: '#F97316',
        tasks: PredefinedRoutines.sensoryRoutine,
        schedule: RoutineSchedule(
          daysOfWeek: [1, 2, 3, 4, 5],
          startTime: const TimeOfDay(hour: 16, minute: 0),
          endTime: const TimeOfDay(hour: 16, minute: 30),
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
