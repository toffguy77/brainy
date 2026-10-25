import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../models/session.dart';
import '../../models/user_progress.dart';

/// What to schedule: the daily reminder time and which message pool to use.
class ReminderPlan {
  final int hour;
  final int minute;
  final bool isStreakWarning;
  final int variantIndex;

  const ReminderPlan({
    required this.hour,
    required this.minute,
    required this.isStreakWarning,
    required this.variantIndex,
  });
}

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _notificationId = 100;

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    // Without this tz.local stays UTC and a 20:00 reminder fires at 20:00 UTC.
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      // Unknown zone identifier: keep UTC rather than fail app start.
    }

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(iOS: iosSettings),
    );
  }

  static Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Pure scheduling decision. Returns null when nothing should be scheduled:
  /// reminders are off, or the player already trained today.
  static ReminderPlan? planReminder({
    required bool enabled,
    required bool hasCustomTime,
    required int hour,
    required int minute,
    required int currentStreak,
    required bool hasPlayedToday,
    required DateTime now,
  }) {
    if (!enabled || hasPlayedToday) return null;
    return ReminderPlan(
      hour: hasCustomTime ? hour : AppConstants.defaultReminderHour,
      minute: hasCustomTime ? minute : AppConstants.defaultReminderMinute,
      isStreakWarning: currentStreak > AppConstants.streakWarningThreshold,
      variantIndex: variantIndexFor(now),
    );
  }

  /// Whether any of [playedAt] falls on the same calendar day as [now].
  static bool hasPlayedOn(Iterable<DateTime> playedAt, DateTime now) =>
      playedAt.any((d) =>
          d.year == now.year && d.month == now.month && d.day == now.day);

  /// Single entry point for all notification scheduling: reads settings,
  /// streak and today's sessions from Hive and the language from the device.
  /// Called on app start, after a game, after onboarding and on settings change.
  static Future<void> rescheduleFromStorage() async {
    final box = Hive.box(AppConstants.userBox);
    final progress = Hive.box<UserProgress>(AppConstants.progressBox)
        .get(AppConstants.progressDataKey);
    final sessions = Hive.box<GameSession>(AppConstants.sessionsBox);
    final now = DateTime.now();

    final plan = planReminder(
      enabled: box.get(AppConstants.notificationsEnabledKey) as bool? ?? false,
      hasCustomTime:
          box.get(AppConstants.hasCustomReminderTimeKey) as bool? ?? false,
      hour: box.get(AppConstants.customReminderHourKey) as int? ??
          AppConstants.defaultReminderHour,
      minute: box.get(AppConstants.customReminderMinuteKey) as int? ??
          AppConstants.defaultReminderMinute,
      currentStreak: progress?.currentStreak ?? 0,
      hasPlayedToday: hasPlayedOn(sessions.values.map((s) => s.playedAt), now),
      now: now,
    );

    await _plugin.cancel(id: _notificationId);
    if (plan == null) return;

    final language = AppConstants.resolveLanguage(
      WidgetsBinding.instance.platformDispatcher.locale.languageCode,
    );
    final l10n = await AppLocalizations.delegate.load(Locale(language));
    final streak = progress?.currentStreak ?? 0;
    final message = plan.isStreakWarning
        ? streakVariant(l10n, plan.variantIndex, streak)
        : motivationVariant(l10n, plan.variantIndex);

    await _plugin.zonedSchedule(
      id: _notificationId,
      title: l10n.appName,
      body: message,
      scheduledDate: _nextInstanceOfTime(plan.hour, plan.minute),
      notificationDetails: NotificationDetails(
        iOS: DarwinNotificationDetails(
          interruptionLevel: plan.isStreakWarning
              ? InterruptionLevel.timeSensitive
              : InterruptionLevel.active,
        ),
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
  /// Computed on UTC calendar dates so a DST shift cannot make a day 23 hours.
  static int variantIndexFor(DateTime day) =>
      DateTime.utc(day.year, day.month, day.day)
          .difference(DateTime.utc(2024))
          .inDays %
      variantCount;

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
