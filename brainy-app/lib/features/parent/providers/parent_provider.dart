import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../constants/app_constants.dart';
import '../../../models/session.dart';
import '../../../models/user_progress.dart';
import '../../../shared/services/notification_service.dart';
import '../../../shared/services/sound_service.dart';
import '../../../shared/services/haptic_service.dart';

/// Session-only PIN verification — resets on app restart.
bool parentPinVerifiedSession = false;

class ParentSettings {
  final bool hasPin;
  final String gridSizeMode; // 'auto' | 'fixed'
  final int fixedGridSize;
  final bool notificationsEnabled;
  final bool hasCustomReminderTime;
  final int customReminderHour;
  final int customReminderMinute;
  final bool soundEnabled;
  final bool hapticEnabled;

  const ParentSettings({
    this.hasPin = false,
    this.gridSizeMode = 'auto',
    this.fixedGridSize = 5,
    this.notificationsEnabled = false,
    this.hasCustomReminderTime = false,
    this.customReminderHour = 20,
    this.customReminderMinute = 0,
    this.soundEnabled = true,
    this.hapticEnabled = true,
  });

  ParentSettings copyWith({
    bool? hasPin,
    String? gridSizeMode,
    int? fixedGridSize,
    bool? notificationsEnabled,
    bool? hasCustomReminderTime,
    int? customReminderHour,
    int? customReminderMinute,
    bool? soundEnabled,
    bool? hapticEnabled,
  }) {
    return ParentSettings(
      hasPin: hasPin ?? this.hasPin,
      gridSizeMode: gridSizeMode ?? this.gridSizeMode,
      fixedGridSize: fixedGridSize ?? this.fixedGridSize,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      hasCustomReminderTime:
          hasCustomReminderTime ?? this.hasCustomReminderTime,
      customReminderHour: customReminderHour ?? this.customReminderHour,
      customReminderMinute:
          customReminderMinute ?? this.customReminderMinute,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }
}

class ParentNotifier extends Notifier<ParentSettings> {
  Box get _box => Hive.box(AppConstants.userBox);

  @override
  ParentSettings build() {
    final pinHash = _box.get(AppConstants.parentPinHashKey) as String?;
    return ParentSettings(
      hasPin: pinHash != null && pinHash.isNotEmpty,
      gridSizeMode:
          _box.get(AppConstants.parentGridSizeModeKey) as String? ?? 'auto',
      fixedGridSize:
          _box.get(AppConstants.parentFixedGridSizeKey) as int? ?? 5,
      notificationsEnabled:
          _box.get(AppConstants.notificationsEnabledKey) as bool? ?? false,
      hasCustomReminderTime:
          _box.get(AppConstants.hasCustomReminderTimeKey) as bool? ?? false,
      customReminderHour:
          _box.get(AppConstants.customReminderHourKey) as int? ??
              AppConstants.defaultReminderHour,
      customReminderMinute:
          _box.get(AppConstants.customReminderMinuteKey) as int? ??
              AppConstants.defaultReminderMinute,
      soundEnabled:
          _box.get(AppConstants.soundEnabledKey) as bool? ?? true,
      hapticEnabled:
          _box.get(AppConstants.hapticEnabledKey) as bool? ?? true,
    );
  }

  static String _hashPin(String pin) {
    final bytes = utf8.encode('brainy_salt_$pin');
    // Simple hash — adequate for a 4-digit child-safety PIN
    var hash = 0x811c9dc5;
    for (final b in bytes) {
      hash ^= b;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }

  Future<void> setPin(String pin) async {
    await _box.put(AppConstants.parentPinHashKey, _hashPin(pin));
    state = state.copyWith(hasPin: true);
  }

  bool verifyPin(String pin) {
    final stored = _box.get(AppConstants.parentPinHashKey) as String?;
    if (stored == null) return false;
    return stored == _hashPin(pin);
  }

  Future<void> setGridSizeMode(String mode) async {
    await _box.put(AppConstants.parentGridSizeModeKey, mode);
    state = state.copyWith(gridSizeMode: mode);
  }

  Future<void> setFixedGridSize(int size) async {
    await _box.put(AppConstants.parentFixedGridSizeKey, size);
    state = state.copyWith(fixedGridSize: size);
  }


  Future<void> _rescheduleNotification() async {
    final sessions = Hive.box<GameSession>(AppConstants.sessionsBox);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final hasPlayedToday = sessions.values.any((s) {
      final d = s.playedAt;
      return d.year == today.year &&
          d.month == today.month &&
          d.day == today.day;
    });

    final progress = Hive.box<UserProgress>(AppConstants.progressBox)
        .get(AppConstants.progressDataKey);
    final currentStreak = progress?.currentStreak ?? 0;

    await NotificationService.reschedule(
      enabled: state.notificationsEnabled,
      hasCustomTime: state.hasCustomReminderTime,
      hour: state.customReminderHour,
      minute: state.customReminderMinute,
      currentStreak: currentStreak,
      hasPlayedToday: hasPlayedToday,
    );
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _box.put(AppConstants.notificationsEnabledKey, enabled);
    state = state.copyWith(notificationsEnabled: enabled);
    await _rescheduleNotification();
  }

  Future<void> setCustomReminderTime(int hour, int minute) async {
    await _box.put(AppConstants.hasCustomReminderTimeKey, true);
    await _box.put(AppConstants.customReminderHourKey, hour);
    await _box.put(AppConstants.customReminderMinuteKey, minute);
    state = state.copyWith(
      hasCustomReminderTime: true,
      customReminderHour: hour,
      customReminderMinute: minute,
    );
    await _rescheduleNotification();
  }

  Future<void> clearCustomReminderTime() async {
    await _box.put(AppConstants.hasCustomReminderTimeKey, false);
    state = state.copyWith(
      hasCustomReminderTime: false,
      customReminderHour: AppConstants.defaultReminderHour,
      customReminderMinute: AppConstants.defaultReminderMinute,
    );
    await _rescheduleNotification();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await SoundService.setEnabled(enabled);
    state = state.copyWith(soundEnabled: enabled);
  }

  Future<void> setHapticEnabled(bool enabled) async {
    await HapticService.setEnabled(enabled);
    state = state.copyWith(hapticEnabled: enabled);
  }
}

final parentProvider =
    NotifierProvider<ParentNotifier, ParentSettings>(ParentNotifier.new);
