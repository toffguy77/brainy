import 'package:hive_flutter/hive_flutter.dart';
import '../../../constants/app_constants.dart';

/// Brute-force guard for the parent PIN. Failed attempts and the lockout
/// deadline live in Hive, so leaving the screen or restarting the app does
/// not reset them. The clock is injectable for tests.
class PinLockout {
  final Box _box;
  final DateTime Function() _now;

  PinLockout(this._box, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  int get failedAttempts =>
      _box.get(AppConstants.parentPinFailedAttemptsKey) as int? ?? 0;

  DateTime? get lockedUntil {
    final ms = _box.get(AppConstants.parentPinLockedUntilKey) as int?;
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  bool get isLocked {
    final until = lockedUntil;
    return until != null && _now().isBefore(until);
  }

  /// Whole seconds left in the lockout, rounded up; 0 when not locked.
  int get remainingSeconds {
    final until = lockedUntil;
    if (until == null) return 0;
    final ms = until.difference(_now()).inMilliseconds;
    return ms <= 0 ? 0 : (ms + 999) ~/ 1000;
  }

  /// Count a wrong PIN. Reaching [AppConstants.parentMaxPinAttempts] starts a
  /// lockout of [AppConstants.parentLockoutSeconds] and resets the count.
  Future<void> recordFailure() async {
    final attempts = failedAttempts + 1;
    if (attempts >= AppConstants.parentMaxPinAttempts) {
      final until = _now()
          .add(const Duration(seconds: AppConstants.parentLockoutSeconds));
      await _box.put(
          AppConstants.parentPinLockedUntilKey, until.millisecondsSinceEpoch);
      await _box.put(AppConstants.parentPinFailedAttemptsKey, 0);
    } else {
      await _box.put(AppConstants.parentPinFailedAttemptsKey, attempts);
    }
  }

  Future<void> recordSuccess() async {
    await _box.delete(AppConstants.parentPinFailedAttemptsKey);
    await _box.delete(AppConstants.parentPinLockedUntilKey);
  }
}
