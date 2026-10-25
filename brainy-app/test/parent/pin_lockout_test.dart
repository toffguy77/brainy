import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/features/parent/providers/pin_lockout.dart';

void main() {
  late Box box;
  late DateTime now;
  PinLockout lockout() => PinLockout(box, now: () => now);

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hive_lockout_');
    Hive.init(dir.path);
    box = await Hive.openBox(AppConstants.userBox);
  });

  setUp(() async {
    await box.clear();
    now = DateTime(2026, 10, 25, 12);
  });

  tearDownAll(() => Hive.close());

  Future<void> fail(int times) async {
    for (var i = 0; i < times; i++) {
      await lockout().recordFailure();
    }
  }

  test('attempts below the limit do not lock', () async {
    await fail(AppConstants.parentMaxPinAttempts - 1);
    expect(lockout().isLocked, isFalse);
    expect(lockout().failedAttempts, AppConstants.parentMaxPinAttempts - 1);
  });

  test('reaching the limit locks for the lockout duration and resets the count',
      () async {
    await fail(AppConstants.parentMaxPinAttempts);
    expect(lockout().isLocked, isTrue);
    expect(lockout().remainingSeconds, AppConstants.parentLockoutSeconds);
    expect(lockout().failedAttempts, 0);
  });

  test('the lockout expires after its duration', () async {
    await fail(AppConstants.parentMaxPinAttempts);
    now = now.add(const Duration(seconds: AppConstants.parentLockoutSeconds - 1));
    expect(lockout().isLocked, isTrue);
    expect(lockout().remainingSeconds, 1);
    now = now.add(const Duration(seconds: 1));
    expect(lockout().isLocked, isFalse);
    expect(lockout().remainingSeconds, 0);
  });

  test('the lockout survives a new instance (screen re-entry or restart)',
      () async {
    await fail(AppConstants.parentMaxPinAttempts);
    final reopened = PinLockout(box, now: () => now);
    expect(reopened.isLocked, isTrue);
  });

  test('a correct PIN clears the attempt count', () async {
    await fail(AppConstants.parentMaxPinAttempts - 1);
    await lockout().recordSuccess();
    expect(lockout().failedAttempts, 0);
    await fail(AppConstants.parentMaxPinAttempts - 1);
    expect(lockout().isLocked, isFalse);
  });
}
