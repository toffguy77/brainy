import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/features/parent/providers/parent_provider.dart';

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hive_pin_');
    Hive.init(dir.path);
    await Hive.openBox(AppConstants.userBox);
  });

  setUp(() async {
    await Hive.box(AppConstants.userBox).clear();
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  ParentNotifier notifier() => container.read(parentProvider.notifier);

  group('PIN protection', () {
    test('no PIN is set on a fresh install', () {
      expect(container.read(parentProvider).hasPin, isFalse);
    });

    test('setting a PIN marks one as present', () async {
      await notifier().setPin('1234');
      expect(container.read(parentProvider).hasPin, isTrue);
    });

    test('the correct PIN verifies', () async {
      await notifier().setPin('1234');
      expect(notifier().verifyPin('1234'), isTrue);
    });

    test('an incorrect PIN is refused', () async {
      await notifier().setPin('1234');
      expect(notifier().verifyPin('9999'), isFalse);
    });

    test('verification fails when no PIN is stored', () {
      expect(notifier().verifyPin('1234'), isFalse);
    });

    test('the PIN is not stored in plain text', () async {
      await notifier().setPin('1234');
      final stored =
          Hive.box(AppConstants.userBox).get(AppConstants.parentPinHashKey);
      expect(stored, isNotNull);
      expect(stored, isNot('1234'));
    });

    test('changing the PIN invalidates the old one', () async {
      await notifier().setPin('1234');
      await notifier().setPin('5678');

      expect(notifier().verifyPin('1234'), isFalse);
      expect(notifier().verifyPin('5678'), isTrue);
    });

    test('a stored PIN survives a fresh provider container', () async {
      await notifier().setPin('4321');
      container.dispose();
      container = ProviderContainer();

      expect(container.read(parentProvider).hasPin, isTrue);
      expect(notifier().verifyPin('4321'), isTrue);
    });

    test('different PINs hash differently', () async {
      await notifier().setPin('1111');
      final a =
          Hive.box(AppConstants.userBox).get(AppConstants.parentPinHashKey);
      await notifier().setPin('2222');
      final b =
          Hive.box(AppConstants.userBox).get(AppConstants.parentPinHashKey);

      expect(a, isNot(b));
    });
  });

  group('lockout configuration', () {
    test('the attempt limit is small enough to matter', () {
      expect(AppConstants.parentMaxPinAttempts, greaterThan(0));
      expect(AppConstants.parentMaxPinAttempts, lessThanOrEqualTo(5));
    });

    test('the lockout is long enough to slow a guesser', () {
      expect(AppConstants.parentLockoutSeconds, greaterThanOrEqualTo(30));
    });

    test('the PIN length is fixed at four digits', () {
      expect(AppConstants.parentPinLength, 4);
    });
  });
}
