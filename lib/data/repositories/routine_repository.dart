import 'package:koa_app/data/models/routine_model.dart';
import "package:flutter/material.dart";

class PredefinedRoutines {
  static final List<RoutineTask> morningRoutineTEA = [
    RoutineTask(
        id: 'task1', name: 'Despertar y vestirse', estimatedMinutes: 15),
    RoutineTask(id: 'task2', name: 'Desayunar', estimatedMinutes: 20),
    RoutineTask(
        id: 'task3', name: 'Cepillarse los dientes', estimatedMinutes: 5),
    RoutineTask(id: 'task4', name: 'Preparar mochila', estimatedMinutes: 10),
  ];

  static final List<RoutineTask> eveningRoutineTDAH = [
    RoutineTask(id: 'task5', name: 'Guardar juguetes', estimatedMinutes: 10),
    RoutineTask(id: 'task6', name: 'Tomar un baño', estimatedMinutes: 20),
    RoutineTask(id: 'task7', name: 'Cena', estimatedMinutes: 30),
    RoutineTask(id: 'task8', name: 'Leer un cuento', estimatedMinutes: 15),
    RoutineTask(id: 'task9', name: 'Dormir', estimatedMinutes: 5),
  ];

  static final List<RoutineTask> sensoryRoutine = [
    RoutineTask(id: 'task10', name: 'Estiramientos', estimatedMinutes: 5),
    RoutineTask(
        id: 'task11', name: 'Juego de presión profunda', estimatedMinutes: 10),
    RoutineTask(id: 'task12', name: 'Escucha tranquila', estimatedMinutes: 15),
  ];
}

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
