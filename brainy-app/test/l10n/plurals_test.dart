import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/l10n/app_localizations.dart';
import 'package:brainy/shared/services/notification_service.dart';

void main() {
  late AppLocalizations ru;
  setUpAll(() async {
    ru = await AppLocalizations.delegate.load(const Locale('ru'));
  });

  test('Russian day counts agree with the number', () {
    expect(ru.streakDays(1), 'Серия 1 день');
    expect(ru.streakDays(3), 'Серия 3 дня');
    expect(ru.streakDays(5), 'Серия 5 дней');
    expect(ru.streakDays(21), 'Серия 21 день');
    expect(ru.progressGoalStreak(14), 'Стрик 14 дней');
    expect(ru.progressStreakProgress(3, 30), '3 / 30 дней');
  });

  test('streak reminders never read "3 дней"', () {
    for (var i = 0; i < NotificationService.variantCount; i++) {
      final text = NotificationService.streakVariant(ru, i, 3);
      expect(text, isNot(contains('3 дней')), reason: 'variant $i');
    }
  });

  test('coin shortfall message declines the price', () {
    expect(ru.accessoriesNotEnoughCoinsMessage(1, 0), contains('1 монета'));
    expect(ru.accessoriesNotEnoughCoinsMessage(3, 0), contains('3 монеты'));
    expect(ru.accessoriesNotEnoughCoinsMessage(50, 10), contains('50 монет'));
  });
}
