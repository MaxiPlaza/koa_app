import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:koa_app/data/models/routine_model.dart';

class RoutineNotificationService {
  static final RoutineNotificationService _instance =
      RoutineNotificationService._internal();
  factory RoutineNotificationService() => _instance;
  RoutineNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Inicializar timezone
    tz.initializeTimeZones();

    // Configuración para Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);
  }

  Future<void> scheduleRoutineNotifications(RoutineModel routine) async {
    if (!routine.schedule.hasReminder) return;

    // Programar notificación para cada día de la semana programado
    for (final dayOfWeek in routine.schedule.daysOfWeek) {
      await _scheduleDailyNotification(routine: routine, dayOfWeek: dayOfWeek);
    }
  }

  Future<void> _scheduleDailyNotification({
    required RoutineModel routine,
    required int dayOfWeek,
  }) async {
    // Calcular la hora de la notificación (minutos antes del inicio)
    final notificationTime = TimeOfDay(
      hour: routine.schedule.startTime.hour,
      minute: routine.schedule.startTime.minute -
          routine.schedule.reminderMinutesBefore,
    );

    // Convertir a TZDateTime
    final scheduledTime = _nextInstanceOfTime(
      hour: notificationTime.hour,
      minute: notificationTime.minute,
      dayOfWeek: dayOfWeek,
    );

    await _notificationsPlugin.zonedSchedule(
      _getNotificationId(routine.id, dayOfWeek),
      '🦊 Recordatorio de KOA',
      'Es casi hora de: ${routine.name}',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'routine_channel',
          'Recordatorios de Rutinas',
          channelDescription:
              'Notificaciones para recordar rutinas diarias de KOA',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 500, 500]),
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOfTime({
    required int hour,
    required int minute,
    required int dayOfWeek,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Ajustar al día de la semana correcto
    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Si la hora ya pasó hoy, programar para la próxima semana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  int _getNotificationId(String routineId, int dayOfWeek) {
    return '${routineId}_$dayOfWeek'.hashCode;
  }

  Future<void> cancelRoutineNotifications(String routineId) async {
    for (int dayOfWeek = 1; dayOfWeek <= 7; dayOfWeek++) {
      await _notificationsPlugin.cancel(
        _getNotificationId(routineId, dayOfWeek),
      );
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Mostrar notificación inmediata (para testing)
  Future<void> showInstantNotification(String title, String body) async {
    await _notificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_channel',
          'Notificaciones Instantáneas',
          channelDescription: 'Notificaciones inmediatas de KOA',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
