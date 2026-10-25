import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/shared/services/notification_service.dart';

ReminderPlan? _plan({
  bool enabled = true,
  bool hasCustomTime = false,
  int hour = 7,
  int minute = 30,
  int streak = 0,
  bool playedToday = false,
}) =>
    NotificationService.planReminder(
      enabled: enabled,
      hasCustomTime: hasCustomTime,
      hour: hour,
      minute: minute,
      currentStreak: streak,
      hasPlayedToday: playedToday,
      now: DateTime(2026, 10, 25, 12),
    );

void main() {
  test('disabled reminders schedule nothing', () {
    expect(_plan(enabled: false), isNull);
    expect(_plan(enabled: false, playedToday: false, streak: 10), isNull);
  });

  test('having played today schedules nothing, even on a long streak', () {
    expect(_plan(playedToday: true), isNull);
    expect(_plan(playedToday: true, streak: 10), isNull);
  });

  test('not having played schedules at the default time', () {
    final p = _plan()!;
    expect(p.hour, AppConstants.defaultReminderHour);
    expect(p.minute, AppConstants.defaultReminderMinute);
  });

  test('a custom time wins only when the custom flag is set', () {
    final custom = _plan(hasCustomTime: true, hour: 7, minute: 30)!;
    expect((custom.hour, custom.minute), (7, 30));
    final ignored = _plan(hasCustomTime: false, hour: 7, minute: 30)!;
    expect((ignored.hour, ignored.minute),
        (AppConstants.defaultReminderHour, AppConstants.defaultReminderMinute));
  });

  test('the streak-warning pool starts above the threshold', () {
    const t = AppConstants.streakWarningThreshold;
    expect(_plan(streak: 0)!.isStreakWarning, isFalse);
    expect(_plan(streak: t)!.isStreakWarning, isFalse);
    expect(_plan(streak: t + 1)!.isStreakWarning, isTrue);
    expect(_plan(streak: 100)!.isStreakWarning, isTrue);
  });

  test('variant index is pinned to the calendar date', () {
    // 2024-01-01 is day 0 of the cycle.
    expect(NotificationService.variantIndexFor(DateTime(2024, 1, 1)), 0);
    expect(NotificationService.variantIndexFor(DateTime(2024, 1, 2)), 1);
    expect(NotificationService.variantIndexFor(DateTime(2024, 1, 8)), 0);
    // Time of day never changes the pick, even at 00:30 after a DST switch.
    expect(NotificationService.variantIndexFor(DateTime(2026, 3, 30, 0, 30)),
        NotificationService.variantIndexFor(DateTime(2026, 3, 30, 23, 59)));
  });

  test('hasPlayedOn matches the calendar day only', () {
    final now = DateTime(2026, 10, 25, 9);
    expect(NotificationService.hasPlayedOn([DateTime(2026, 10, 25, 0, 1)], now),
        isTrue);
    expect(
        NotificationService.hasPlayedOn([DateTime(2026, 10, 24, 23, 59)], now),
        isFalse);
    expect(NotificationService.hasPlayedOn(const [], now), isFalse);
  });

  test('unsupported device languages fall back to English', () {
    expect(AppConstants.resolveLanguage('ru'), 'ru');
    expect(AppConstants.resolveLanguage('en'), 'en');
    expect(AppConstants.resolveLanguage('de'), 'en');
    expect(AppConstants.resolveLanguage(null), 'en');
  });
}
