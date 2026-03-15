import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../constants/app_constants.dart';
import '../../../models/user_progress.dart';

class UserProgressNotifier extends Notifier<UserProgress> {
  Box<UserProgress> get _box =>
      Hive.box<UserProgress>(AppConstants.progressBox);

  @override
  UserProgress build() {
    final existing = _box.get(AppConstants.progressDataKey);
    if (existing != null) return existing;
    final fresh = UserProgress();
    _box.put(AppConstants.progressDataKey, fresh);
    return fresh;
  }

  Future<void> addCoins(int amount) async {
    state.coins += amount;
    await _persist();
  }

  Future<void> addXp(int amount) async {
    state.xp += amount;

    // Walk thresholds descending (map is insertion-ordered: 1,5,10,20)
    // to find the highest level the player qualifies for
    for (final entry in AppConstants.xpThresholds.entries.toList().reversed) {
      if (state.xp >= entry.value && entry.key > state.level) {
        state.level = entry.key;
        break;
      }
    }

    await _persist();
  }

  Future<void> updateStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = state.lastPlayedDate;

    if (last != null) {
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 0) {
        state.lastPlayedDate = now;
        await _persist();
        return;
      } else if (diff == 1) {
        state.currentStreak += 1;
      } else {
        state.currentStreak = 1;
      }
    } else {
      state.currentStreak = 1;
    }

    if (state.currentStreak > state.longestStreak) {
      state.longestStreak = state.currentStreak;
    }
    state.lastPlayedDate = now;

    // Streak bonuses
    if (state.currentStreak == 7) {
      state.coins += AppConstants.coinsForStreak7;
      // TODO: trigger 'week_streak' achievement
    } else if (state.currentStreak == 30) {
      state.coins += AppConstants.coinsForStreak30;
      // TODO: unlock Vortex character
    }

    await _persist();
  }

  bool canAfford(int price) => state.coins >= price;

  Future<bool> spendCoins(int amount) async {
    if (state.coins < amount) return false;
    state.coins -= amount;
    await _persist();
    return true;
  }

  Future<bool> purchaseAccessory(String accessoryId, int price) async {
    if (state.unlockedAccessories.contains(accessoryId)) return true;
    if (state.coins < price) return false;
    state.coins -= price;
    state.unlockedAccessories = List<String>.from(state.unlockedAccessories)
      ..add(accessoryId);
    await _persist();
    return true;
  }

  bool hasAccessory(String accessoryId) =>
      state.unlockedAccessories.contains(accessoryId);

  Future<void> setSelectedGridSize(int size) async {
    state.lastSelectedGridSize = size;
    await _persist();
  }

  Future<void> setActiveCharacter(String characterId) async {
    state.activeCharacterId = characterId;
    await _persist();
  }

  Future<void> migrateFromOnboarding({
    required String childAge,
    required List<String> goals,
    required int dailyGoalMinutes,
  }) async {
    // Only migrate once — don't overwrite existing user data
    if (state.childAge.isNotEmpty) return;

    state.childAge = childAge;
    state.goals = List<String>.from(goals);
    state.dailyGoalMinutes = dailyGoalMinutes;
    await _persist();
  }

  Future<void> _persist() async {
    await _box.put(AppConstants.progressDataKey, state);
    ref.notifyListeners();
  }
}

final userProgressProvider =
    NotifierProvider<UserProgressNotifier, UserProgress>(
        UserProgressNotifier.new);
