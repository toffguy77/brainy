import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'brainy_reminders';
  static const _channelName = 'Training Reminders';
  static const _notificationId = 100;

  // Motivational messages (streak <= 2 or no streak)
  static const _motivationMessagesRu = [
    'Время потренировать мозг!',
    'Брейни ждёт тебя! Зайди на тренировку',
    'Несколько минут — и мозг станет быстрее!',
    'Зэп зовёт на тренировку!',
    'Сегодня ещё не тренировались. Начнём?',
    'Мозг любит тренировки. Не пропусти!',
    'Пора размять мозг! Таблица Шульте ждёт',
  ];

  static const _motivationMessagesEn = [
    'Time to train your brain!',
    'Brainy is waiting for you! Start training',
    'A few minutes and your brain gets faster!',
    'Zap is calling you to practice!',
    "Haven't trained today yet. Shall we start?",
    "Your brain loves training. Don't skip it!",
    'Time to exercise your brain! Schulte table awaits',
  ];

  // Streak warning messages (streak > 2, hasn't played today)
  static const _streakMessagesRu = [
    'Стрик {N} дней сгорит сегодня!',
    'Не потеряй свой стрик {N} дней!',
    '{N} дней подряд — не останавливайся!',
    'Стрик в опасности! Сыграй сегодня',
    'Осталось немного до конца дня. Сохрани стрик!',
    'Твой стрик {N} дней на волоске!',
    'Брейни переживает за стрик {N} дней!',
  ];

  static const _streakMessagesEn = [
    'Your {N}-day streak expires today!',
    "Don't lose your {N}-day streak!",
    "{N} days in a row — don't stop now!",
    'Streak in danger! Play today',
    'Day is almost over. Save your streak!',
    'Your {N}-day streak is hanging by a thread!',
    'Brainy is worried about your {N}-day streak!',
  ];

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings: settings);
  }

  static Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Single entry point for all notification scheduling.
  /// Called on app start, after game completion, and on settings change.
  static Future<void> reschedule({
    required bool enabled,
    required bool hasCustomTime,
    required int hour,
    required int minute,
    required int currentStreak,
    required bool hasPlayedToday,
    String locale = 'en',
  }) async {
    await _plugin.cancel(id: _notificationId);

    if (!enabled || hasPlayedToday) return;

    final effectiveHour = hasCustomTime ? hour : 20;
    final effectiveMinute = hasCustomTime ? minute : 0;

    final isStreakWarning = currentStreak > 2;
    final message = isStreakWarning
        ? _pickStreakMessage(currentStreak, locale)
        : _pickMotivationMessage(locale);

    await _plugin.zonedSchedule(
      id: _notificationId,
      title: 'Brainy',
      body: message,
      scheduledDate: _nextInstanceOfTime(effectiveHour, effectiveMinute),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance:
              isStreakWarning ? Importance.high : Importance.defaultImportance,
          priority:
              isStreakWarning ? Priority.high : Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static String _pickMotivationMessage(String locale) {
    final messages =
        locale == 'ru' ? _motivationMessagesRu : _motivationMessagesEn;
    final index =
        DateTime.now().difference(DateTime(2024)).inDays % messages.length;
    return messages[index];
  }

  static String _pickStreakMessage(int streakDays, String locale) {
    final messages =
        locale == 'ru' ? _streakMessagesRu : _streakMessagesEn;
    final index =
        DateTime.now().difference(DateTime(2024)).inDays % messages.length;
    return messages[index].replaceAll('{N}', '$streakDays');
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
