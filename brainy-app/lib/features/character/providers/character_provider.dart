import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../constants/app_constants.dart';
import '../../../models/accessory.dart';
import '../../../models/character.dart';
import '../../../models/user_progress.dart';
import '../../game/providers/user_progress_provider.dart';
import '../data/characters_data.dart';

class CharacterNotifier extends Notifier<List<CharacterData>> {
  Box<CharacterData> get _box =>
      Hive.box<CharacterData>(AppConstants.characterBox);

  @override
  List<CharacterData> build() {
    final existing = _box.values.toList();
    if (existing.isNotEmpty) return existing;

    // Initialize default characters — only Brainy unlocked
    for (final info in defaultCharacters) {
      final data = CharacterData(
        id: info.id,
        nameRu: info.nameRu,
        nameEn: info.nameEn,
        isUnlocked: info.unlockType == UnlockType.free,
      );
      _box.put(info.id, data);
    }
    return _box.values.toList();
  }

  CharacterData? getById(String id) {
    try {
      return state.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> selectCharacter(String id) async {
    final character = getById(id);
    if (character == null || !character.isUnlocked) return;

    final progress = ref.read(userProgressProvider.notifier);
    await progress.setActiveCharacter(id);
  }

  Future<void> unlockCharacter(String id) async {
    final character = getById(id);
    if (character == null || character.isUnlocked) return;

    character.isUnlocked = true;
    await _box.put(id, character);
    state = _box.values.toList();
  }

  Future<void> equipAccessory(
      String characterId, String accessoryId, AccessorySlot slot) async {
    final character = getById(characterId);
    if (character == null) return;

    switch (slot) {
      case AccessorySlot.hat:
        character.equippedHat = accessoryId;
      case AccessorySlot.glasses:
        character.equippedGlasses = accessoryId;
      case AccessorySlot.effect:
        character.equippedEffect = accessoryId;
      case AccessorySlot.cape:
        character.equippedCape = accessoryId;
    }

    await _box.put(characterId, character);
    state = _box.values.toList();
  }

  Future<void> unequipAccessory(
      String characterId, AccessorySlot slot) async {
    final character = getById(characterId);
    if (character == null) return;

    switch (slot) {
      case AccessorySlot.hat:
        character.equippedHat = null;
      case AccessorySlot.glasses:
        character.equippedGlasses = null;
      case AccessorySlot.effect:
        character.equippedEffect = null;
      case AccessorySlot.cape:
        character.equippedCape = null;
    }

    await _box.put(characterId, character);
    state = _box.values.toList();
  }

  String? getEquipped(String characterId, AccessorySlot slot) {
    final character = getById(characterId);
    if (character == null) return null;
    return switch (slot) {
      AccessorySlot.hat => character.equippedHat,
      AccessorySlot.glasses => character.equippedGlasses,
      AccessorySlot.effect => character.equippedEffect,
      AccessorySlot.cape => character.equippedCape,
    };
  }

  bool checkUnlockEligibility(CharacterInfo info, UserProgress progress) {
    switch (info.unlockType) {
      case UnlockType.free:
        return true;
      case UnlockType.level:
        return progress.level >= (info.requiredLevel ?? 0);
      case UnlockType.streak:
        return progress.longestStreak >= (info.requiredStreak ?? 0);
    }
  }
}

final characterProvider =
    NotifierProvider<CharacterNotifier, List<CharacterData>>(
        CharacterNotifier.new);
