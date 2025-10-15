// IMPORTANTE: Si estás utilizando Firebase/Firestore, necesitas importar el paquete
// para que el método '.toDate()' funcione correctamente en 'fromMap'.
// import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos que representa una sesión de juego o actividad realizada por un niño.
///
/// Este modelo centraliza los datos de la sesión para ser utilizado por:
/// 1. La lógica de persistencia de datos (serialización).
/// 2. El servicio de análisis de la IA (`ai_service.dart`).
class GameSession {
  /// Identificador único de la sesión de juego.
  final String id;

  /// Identificador del niño que realizó la sesión.
  final String childId;

  /// Identificador del tipo de juego o actividad (e.g., 'puzzle_a').
  final String activityId;

  /// Fecha y hora en que comenzó la sesión.
  final DateTime startTime;

  /// Fecha y hora en que finalizó la sesión.
  final DateTime endTime;

  /// Puntuación obtenida durante la sesión.
  final int score;

  /// Número de estrellas o recompensa obtenida.
  final int stars;

  /// Métricas específicas del juego (ej. Map de aciertos/errores).
  final Map<String, dynamic> performance;

  /// Indica si la sesión fue completada exitosamente.
  final bool completed;

  GameSession({
    required this.id,
    required this.childId,
    required this.activityId,
    required this.startTime,
    required this.endTime,
    required this.score,
    required this.stars,
    required this.performance,
    required this.completed,
  });

  /// Propiedad calculada: Duración de la sesión en minutos.
  /// Se retorna como double para compatibilidad con la lógica de cálculo de la IA.
  double get durationInMinutes {
    // Diferencia total en minutos, convertida a double.
    return endTime.difference(startTime).inMinutes.toDouble();
  }

  /// Crea una instancia de GameSession a partir de un mapa (para lectura desde la base de datos).
  ///
  /// NOTA: Si usas Firebase, debes descomentar la importación de 'Timestamp'
  /// y usar el operador `as Timestamp` en los campos de fecha.
  factory GameSession.fromMap(Map<String, dynamic> map) {
    // Función auxiliar para manejar la conversión de Timestamp (si está disponible) o String/DateTime
    DateTime _parseTime(dynamic value) {
      if (value is String) return DateTime.parse(value);
      // Si el valor es de tipo Firebase Timestamp, usamos .toDate()
      // else if (value.runtimeType.toString() == 'Timestamp') return (value as Timestamp).toDate();
      // Usaremos un fallback seguro por defecto
      return value is DateTime ? value : DateTime.now();
    }

    return GameSession(
      id: map['id'] ?? '',
      childId: map['childId'] ?? '',
      activityId: map['activityId'] ?? '',
      startTime: _parseTime(map['startTime']),
      endTime: _parseTime(map['endTime']),
      score: map['score'] ?? 0,
      stars: map['stars'] ?? 0,
      performance: Map<String, dynamic>.from(map['performance'] ?? {}),
      completed: map['completed'] ?? false,
    );
  }

  /// Convierte la instancia de GameSession a un mapa (para escritura a la base de datos).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'activityId': activityId,
      // Se usan Strings ISO 8601, un formato estándar para guardar fechas en JSON/Mapas.
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'score': score,
      'stars': stars,
      'performance': performance,
      'completed': completed,
    };
  }
}
