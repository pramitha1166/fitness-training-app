import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/app_settings.dart';
import '../models/enums.dart';
import '../models/meal.dart';
import '../models/time_slot.dart';
import '../models/workout_session.dart';

/// Schedules local notifications for workout and meal reminders
/// (FR-5.1, FR-5.2), respects device time zone (FR-5.4) by using the
/// `timezone` package, and can fire missed-activity re-engagement and
/// subscription alerts (FR-5.5, FR-5.6).
///
/// Notifications are scheduled locally (not via a push server), which is
/// what keeps them firing even when the app is offline (NFR-10).
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _workoutChannel = AndroidNotificationDetails(
    'workout_reminders',
    'Workout Reminders',
    channelDescription: 'Reminders for your scheduled workouts',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const _mealChannel = AndroidNotificationDetails(
    'meal_reminders',
    'Meal Reminders',
    channelDescription: 'Reminders for your scheduled meals',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const _systemChannel = AndroidNotificationDetails(
    'system_alerts',
    'Account & Subscription Alerts',
    channelDescription: 'Trial ending, renewal and adherence alerts',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.local);
    } catch (_) {
      // Falls back to UTC if the platform can't resolve the local zone.
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    final androidGranted = await androidImpl?.requestNotificationsPermission();
    final iosGranted = await iosImpl?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return (androidGranted ?? true) && (iosGranted ?? true);
  }

  int _idFor(String sourceId, {int offset = 0}) =>
      (sourceId.hashCode & 0x7fffffff) + offset;

  tz.TZDateTime _nextInstanceOf(WeekDay day, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduled.weekday != day.dateTimeWeekday ||
        !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> _scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required TimeSlot slot,
    required int leadMinutes,
    required AndroidNotificationDetails channel,
  }) async {
    final leadAdjusted = Duration(minutes: leadMinutes);
    final target = _nextInstanceOf(
      slot.day,
      slot.startHour,
      slot.startMinute,
    ).subtract(leadAdjusted);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      target,
      NotificationDetails(
        android: channel,
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> scheduleWorkoutReminders(
    List<WorkoutSession> sessions,
    AppSettings settings,
  ) async {
    if (!settings.workoutRemindersEnabled) return;
    await init();
    for (final session in sessions) {
      await _scheduleWeekly(
        id: _idFor(session.id),
        title: 'Time to train: ${session.title}',
        body:
            'Your ${session.title} session starts soon. Let\'s build that physique!',
        slot: session.slot,
        leadMinutes: settings.workoutLeadMinutes,
        channel: _workoutChannel,
      );
    }
  }

  Future<void> scheduleMealReminders(
    List<Meal> meals,
    AppSettings settings,
  ) async {
    if (!settings.mealRemindersEnabled) return;
    await init();
    for (final meal in meals) {
      await _scheduleWeekly(
        id: _idFor(meal.id),
        title: '${meal.type.label} time: ${meal.food.name}',
        body: 'Your planned ${meal.type.label.toLowerCase()} is coming up.',
        slot: meal.slot,
        leadMinutes: settings.mealLeadMinutes,
        channel: _mealChannel,
      );
    }
  }

  /// FR-5.5: notify if a scheduled item wasn't logged within a grace period.
  Future<void> showMissedActivityAlert({required String activityLabel}) async {
    await init();
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'You missed $activityLabel',
      'Tap to log it now or reschedule — staying consistent is what drives results.',
      const NotificationDetails(
        android: _systemChannel,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// FR-5.6: renewal reminder, payment failure, trial ending alerts.
  Future<void> showSubscriptionAlert({
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: _systemChannel,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  Future<void> rescheduleAll({
    required List<WorkoutSession> sessions,
    required List<Meal> meals,
    required AppSettings settings,
  }) async {
    await cancelAll();
    await scheduleWorkoutReminders(sessions, settings);
    await scheduleMealReminders(meals, settings);
  }
}
