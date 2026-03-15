import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../constants/app_constants.dart';

class HapticService {
  HapticService._();

  static bool get isEnabled {
    final box = Hive.box(AppConstants.userBox);
    return box.get(AppConstants.hapticEnabledKey) as bool? ?? true;
  }

  static Future<void> setEnabled(bool enabled) async {
    final box = Hive.box(AppConstants.userBox);
    await box.put(AppConstants.hapticEnabledKey, enabled);
  }

  static void correctTap() {
    if (!isEnabled) return;
    HapticFeedback.lightImpact();
  }

  static void wrongTap() {
    if (!isEnabled) return;
    HapticFeedback.heavyImpact();
  }

  static Future<void> gameComplete() async {
    if (!isEnabled) return;
    for (int i = 0; i < 3; i++) {
      HapticFeedback.mediumImpact();
      if (i < 2) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  static void recordBroken() {
    if (!isEnabled) return;
    HapticFeedback.vibrate();
  }

  static void purchase() {
    if (!isEnabled) return;
    HapticFeedback.mediumImpact();
  }
}
