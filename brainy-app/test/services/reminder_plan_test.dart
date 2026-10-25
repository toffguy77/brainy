import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/shared/services/notification_service.dart';

final _noon = DateTime(2026, 10, 25, 12);

List<ReminderSlot> _plan({
  bool enabled = true,
  bool hasCustomTime = false,
  int hour = 7,
  int minute = 30,
  int streak = 0,
  bool playedToday = false,
  DateTime? now,
}) =>
    NotificationService.planReminders(
      enabled: enabled,
      hasCustomTime: hasCustomTime,
      hour: hour,
      minute: minute,
      currentStreak: streak,
      hasPlayedToday: playedToday,
      now: now ?? _noon,
    );

void main() {
  const days = AppConstants.reminderDaysAhead;

  test('disabled reminders schedule nothing', () {
    expect(_plan(enabled: false), isEmpty);
    expect(_plan(enabled: false, streak: 10), isEmpty);
  });

  test('not having played: today plus the following days, at the default time',
      () {
    final slots = _plan();
    expect(slots, hasLength(days));
    expect(slots.first.at,
        DateTime(2026, 10, 25, AppConstants.defaultReminderHour,
            AppConstants.defaultReminderMinute));
    expect(slots.last.at.day, 25 + days - 1);
  });

  test('having played today skips today but keeps reminding from tomorrow', () {
    final slots = _plan(playedToday: true);
    expect(slots, hasLength(days - 1));
    expect(slots.first.at, DateTime(2026, 10, 26, AppConstants.defaultReminderHour));
  });

  test("today's time already passed: start tomorrow", () {
    final late = DateTime(2026, 10, 25, 21);
    expect(_plan(now: late).first.at.day, 26);
  });

  test('a custom time wins only when the custom flag is set', () {
    final custom = _plan(hasCustomTime: true, hour: 13, minute: 30).first.at;
    expect((custom.hour, custom.minute), (13, 30));
    final ignored = _plan(hasCustomTime: false, hour: 13, minute: 30).first.at;
    expect((ignored.hour, ignored.minute),
        (AppConstants.defaultReminderHour, AppConstants.defaultReminderMinute));
  });

  test('only the first reminder warns about a streak above the threshold', () {
    const t = AppConstants.streakWarningThreshold;
    expect(_plan(streak: t).any((s) => s.isStreakWarning), isFalse);
    final slots = _plan(streak: t + 1);
    expect(slots.first.isStreakWarning, isTrue);
    expect(slots.skip(1).any((s) => s.isStreakWarning), isFalse);
  });

  test('each day gets its own text variant', () {
    final slots = _plan();
    final indices = slots.map((s) => s.variantIndex).toSet();
    expect(indices.length, slots.length);
  });

  test('reminders cross a month boundary', () {
    final slots = _plan(now: DateTime(2026, 10, 30, 12));
    expect(slots.last.at, DateTime(2026, 11, 5, AppConstants.defaultReminderHour));
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
