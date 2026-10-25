import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/app_localizations.dart';
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
        ? await _pickStreakMessage(currentStreak, locale)
        : await _pickMotivationMessage(locale);

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

  /// Number of variants in each pool. Both locales must define the same count,
  /// because the index is computed once and used for whichever locale is active.
  static const int variantCount = 7;

  /// Deterministic per-day choice, so the text changes daily but not per call.
  static int variantIndexFor(DateTime day) =>
      day.difference(DateTime(2024)).inDays % variantCount;

  static String motivationVariant(AppLocalizations l10n, int index) =>
      switch (index % variantCount) {
        0 => l10n.notificationMotivation1,
        1 => l10n.notificationMotivation2,
        2 => l10n.notificationMotivation3,
        3 => l10n.notificationMotivation4,
        4 => l10n.notificationMotivation5,
        5 => l10n.notificationMotivation6,
        _ => l10n.notificationMotivation7,
      };

  static String streakVariant(AppLocalizations l10n, int index, int days) =>
      switch (index % variantCount) {
        0 => l10n.notificationStreak1(days),
        1 => l10n.notificationStreak2(days),
        2 => l10n.notificationStreak3(days),
        3 => l10n.notificationStreak4(days),
        4 => l10n.notificationStreak5(days),
        5 => l10n.notificationStreak6(days),
        _ => l10n.notificationStreak7(days),
      };

  /// Resolves localizations without a widget tree — this service schedules from
  /// background contexts where no BuildContext exists.
  static Future<String> _pickMotivationMessage(String locale) async {
    final l10n = await AppLocalizations.delegate.load(Locale(locale));
    return motivationVariant(l10n, variantIndexFor(DateTime.now()));
  }

  static Future<String> _pickStreakMessage(int streakDays, String locale) async {
    final l10n = await AppLocalizations.delegate.load(Locale(locale));
    return streakVariant(l10n, variantIndexFor(DateTime.now()), streakDays);
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
