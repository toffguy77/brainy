import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/features/character/data/accessories_data.dart';
import 'package:brainy/features/character/providers/character_provider.dart';
import 'package:brainy/features/game/providers/user_progress_provider.dart';
import 'package:brainy/models/accessory.dart';
import 'package:brainy/models/character.dart';
import 'package:brainy/models/user_progress.dart';

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hive_shop_');
    Hive.init(dir.path);
    Hive.registerAdapter(UserProgressAdapter());
    Hive.registerAdapter(CharacterDataAdapter());
    await Hive.openBox<UserProgress>(AppConstants.progressBox);
    await Hive.openBox<CharacterData>(AppConstants.characterBox);
  });

  setUp(() async {
    await Hive.box<UserProgress>(AppConstants.progressBox).clear();
    await Hive.box<CharacterData>(AppConstants.characterBox).clear();
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  Future<void> giveCoins(int amount) async {
    final progress = container.read(userProgressProvider.notifier);
    await progress.addCoins(amount);
  }

  group('accessory catalogue', () {
    test('every accessory has a positive coin price and something to draw',
        () {
      for (final a in defaultAccessories) {
        expect(a.price, greaterThan(0), reason: a.id);
        expect(a.glyph != null || a.tint != null, isTrue, reason: a.id);
      }
    });

    test('every accessory is named in both locales', () async {
      for (final code in ['ru', 'en']) {
        final l10n = await AppLocalizations.delegate.load(Locale(code));
        for (final a in defaultAccessories) {
          expect(a.name(l10n), isNot(a.id), reason: '${a.id} $code');
        }
      }
    });

    test('every slot has at least one accessory', () {
      for (final slot in AccessorySlot.values) {
        expect(defaultAccessories.where((a) => a.slot == slot), isNotEmpty,
            reason: 'no accessory for $slot');
      }
    });

    test('accessory ids are unique', () {
      final ids = defaultAccessories.map((a) => a.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('the cheapest accessory is reachable from a few sessions', () {
      final cheapest =
          defaultAccessories.map((a) => a.price).reduce((a, b) => a < b ? a : b);
      // Otherwise the shop opens with nothing a new player can afford.
      expect(cheapest, lessThanOrEqualTo(AppConstants.coinsPerSession * 20));
    });
  });

  group('purchase', () {
    test('an affordable accessory is bought and coins are deducted', () async {
      await giveCoins(500);
      final item = defaultAccessories.first;
      final progress = container.read(userProgressProvider.notifier);

      final ok = await progress.purchaseAccessory(item.id, item.price);

      expect(ok, isTrue);
      expect(progress.hasAccessory(item.id), isTrue);
      expect(container.read(userProgressProvider).coins, 500 - item.price);
    });

    test('an unaffordable accessory is refused and coins are untouched',
        () async {
      final item = defaultAccessories
          .firstWhere((a) => a.price > 0, orElse: () => defaultAccessories.first);
      await giveCoins(item.price - 1);
      final progress = container.read(userProgressProvider.notifier);

      final ok = await progress.purchaseAccessory(item.id, item.price);

      expect(ok, isFalse);
      expect(progress.hasAccessory(item.id), isFalse);
      expect(container.read(userProgressProvider).coins, item.price - 1);
    });

    test('balance never goes negative', () async {
      await giveCoins(10);
      final progress = container.read(userProgressProvider.notifier);
      for (final item in defaultAccessories) {
        await progress.purchaseAccessory(item.id, item.price);
      }
      expect(container.read(userProgressProvider).coins,
          greaterThanOrEqualTo(0));
    });

    test('buying the same accessory twice does not charge twice', () async {
      await giveCoins(500);
      final item = defaultAccessories.first;
      final progress = container.read(userProgressProvider.notifier);

      await progress.purchaseAccessory(item.id, item.price);
      final afterFirst = container.read(userProgressProvider).coins;
      await progress.purchaseAccessory(item.id, item.price);

      expect(container.read(userProgressProvider).coins, afterFirst);
    });
  });

  group('equip', () {
    test('an accessory can be equipped in each slot, capes included', () async {
      final characters = container.read(characterProvider.notifier);
      for (final slot in AccessorySlot.values) {
        final item = defaultAccessories.firstWhere((a) => a.slot == slot);
        await characters.equipAccessory('brainy', item.id, slot);
        expect(characters.getEquipped('brainy', slot), item.id,
            reason: 'slot $slot did not persist');
      }
    });

    test('equipping a second item in a slot replaces the first', () async {
      final slot = AccessorySlot.hat;
      final hats = defaultAccessories.where((a) => a.slot == slot).toList();
      if (hats.length < 2) return;
      final characters = container.read(characterProvider.notifier);

      await characters.equipAccessory('brainy', hats[0].id, slot);
      await characters.equipAccessory('brainy', hats[1].id, slot);

      expect(characters.getEquipped('brainy', slot), hats[1].id);
    });

    test('slots are independent', () async {
      final characters = container.read(characterProvider.notifier);
      final hat = defaultAccessories.firstWhere((a) => a.slot == AccessorySlot.hat);
      final cape =
          defaultAccessories.firstWhere((a) => a.slot == AccessorySlot.cape);

      await characters.equipAccessory('brainy', hat.id, AccessorySlot.hat);
      await characters.equipAccessory('brainy', cape.id, AccessorySlot.cape);

      expect(characters.getEquipped('brainy', AccessorySlot.hat), hat.id);
      expect(characters.getEquipped('brainy', AccessorySlot.cape), cape.id);
    });

    test('unequipping clears only its own slot', () async {
      final characters = container.read(characterProvider.notifier);
      final hat = defaultAccessories.firstWhere((a) => a.slot == AccessorySlot.hat);
      final cape =
          defaultAccessories.firstWhere((a) => a.slot == AccessorySlot.cape);

      await characters.equipAccessory('brainy', hat.id, AccessorySlot.hat);
      await characters.equipAccessory('brainy', cape.id, AccessorySlot.cape);
      await characters.unequipAccessory('brainy', AccessorySlot.hat);

      expect(characters.getEquipped('brainy', AccessorySlot.hat), isNull);
      expect(characters.getEquipped('brainy', AccessorySlot.cape), cape.id);
    });
  });

  group('persistence', () {
    test('ownership and coins survive a fresh provider container', () async {
      await giveCoins(500);
      final item = defaultAccessories.first;
      await container
          .read(userProgressProvider.notifier)
          .purchaseAccessory(item.id, item.price);
      final expected = container.read(userProgressProvider).coins;

      container.dispose();
      container = ProviderContainer();

      expect(container.read(userProgressProvider).coins, expected);
      expect(container.read(userProgressProvider.notifier).hasAccessory(item.id),
          isTrue);
    });

    test('equipment survives a fresh provider container', () async {
      final hat = defaultAccessories.firstWhere((a) => a.slot == AccessorySlot.hat);
      await container
          .read(characterProvider.notifier)
          .equipAccessory('brainy', hat.id, AccessorySlot.hat);

      container.dispose();
      container = ProviderContainer();

      expect(
          container
              .read(characterProvider.notifier)
              .getEquipped('brainy', AccessorySlot.hat),
          hat.id);
    });
  });
}
