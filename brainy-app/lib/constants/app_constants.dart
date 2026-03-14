class AppConstants {
  AppConstants._();

  static const String appName = 'Brainy';

  // Grid sizes
  static const List<int> gridSizes = [3, 4, 5, 6, 7, 9];
  static const List<int> freeGridSizes = [3, 4, 5];
  static const List<int> premiumGridSizes = [6, 7, 9];

  // Target times (seconds) for adaptive difficulty
  static const Map<int, int> targetTimes = {
    3: 9,
    4: 16,
    5: 25,
    6: 36,
    7: 49,
  };

  // Coins
  static const int coinsPerSession = 10;
  static const int coinsPersonalRecord = 25;
  static const int coinsStreak7Days = 50;
  static const int coinsStreak30Days = 200;

  // Penalty
  static const int wrongTapPenaltySeconds = 2;

  // Streak
  static const int sessionsForAdaptive = 5;

  // PIN
  static const int parentPinLength = 4;
}
