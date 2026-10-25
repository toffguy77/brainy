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

/// One scheduled reminder: when it fires (device wall-clock time) and which
/// message pool and variant it uses.
class ReminderSlot {
  final DateTime at;
  final bool isStreakWarning;
  final int variantIndex;

  const ReminderSlot({
    required this.at,
    required this.isStreakWarning,
    required this.variantIndex,
  });
}

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Reminder ids are [_firstNotificationId] + day offset.
  static const _firstNotificationId = 100;

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

  /// Pure scheduling decision: one-off reminders for the next
  /// [AppConstants.reminderDaysAhead] days at the reminder time. Today is
  /// skipped when the child already played or the time has passed. Only the
  /// first reminder can warn about the streak — if it is missed the streak is
  /// gone, so later days fall back to motivation.
  static List<ReminderSlot> planReminders({
    required bool enabled,
    required bool hasCustomTime,
    required int hour,
    required int minute,
    required int currentStreak,
    required bool hasPlayedToday,
    required DateTime now,
  }) {
    if (!enabled) return const [];
    final h = hasCustomTime ? hour : AppConstants.defaultReminderHour;
    final m = hasCustomTime ? minute : AppConstants.defaultReminderMinute;
    final streakAtRisk = currentStreak > AppConstants.streakWarningThreshold;

    final slots = <ReminderSlot>[];
    for (var d = 0; d < AppConstants.reminderDaysAhead; d++) {
      final at = DateTime(now.year, now.month, now.day + d, h, m);
      if (d == 0 && (hasPlayedToday || !at.isAfter(now))) continue;
      slots.add(ReminderSlot(
        at: at,
        isStreakWarning: streakAtRisk && slots.isEmpty,
        variantIndex: variantIndexFor(at),
      ));
    }
    return slots;
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

    final streak = progress?.currentStreak ?? 0;
    final slots = planReminders(
      enabled: box.get(AppConstants.notificationsEnabledKey) as bool? ?? false,
      hasCustomTime:
          box.get(AppConstants.hasCustomReminderTimeKey) as bool? ?? false,
      hour: box.get(AppConstants.customReminderHourKey) as int? ??
          AppConstants.defaultReminderHour,
      minute: box.get(AppConstants.customReminderMinuteKey) as int? ??
          AppConstants.defaultReminderMinute,
      currentStreak: streak,
      hasPlayedToday: hasPlayedOn(sessions.values.map((s) => s.playedAt), now),
      now: now,
    );

    for (var d = 0; d < AppConstants.reminderDaysAhead; d++) {
      await _plugin.cancel(id: _firstNotificationId + d);
    }
    if (slots.isEmpty) return;

    final language = AppConstants.resolveLanguage(
      WidgetsBinding.instance.platformDispatcher.locale.languageCode,
    );
    final l10n = await AppLocalizations.delegate.load(Locale(language));
    final today = DateTime(now.year, now.month, now.day);

    for (final slot in slots) {
      final dayOffset =
          DateTime(slot.at.year, slot.at.month, slot.at.day)
              .difference(today)
              .inDays;
      await _plugin.zonedSchedule(
        id: _firstNotificationId + dayOffset,
        title: l10n.appName,
        body: slot.isStreakWarning
            ? streakVariant(l10n, slot.variantIndex, streak)
            : motivationVariant(l10n, slot.variantIndex),
        scheduledDate: tz.TZDateTime(tz.local, slot.at.year, slot.at.month,
            slot.at.day, slot.at.hour, slot.at.minute),
        // Plain 'active' level: time-sensitive needs an entitlement the
        // app does not have.
        notificationDetails: const NotificationDetails(
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
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
}
