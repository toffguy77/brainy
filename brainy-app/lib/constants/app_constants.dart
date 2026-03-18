class AppConstants {
  AppConstants._();

  static const String appName = 'Brainy';

  // Grid sizes
  static const List<int> freeGridSizes = [3, 4, 5];
  static const List<int> premiumGridSizes = [6, 7, 9];
  static const List<int> allGridSizes = [3, 4, 5, 6, 7, 9];

  // Target times (seconds) for adaptive difficulty
  static const Map<int, int> targetTimes = {
    3: 9,
    4: 16,
    5: 25,
    6: 36,
    7: 49,
    9: 81,
  };

  // Star thresholds per grid size: {gridSize: [3-star max seconds, 2-star max seconds]}
  static const Map<int, List<int>> starThresholds = {
    3: [8, 15],
    4: [14, 25],
    5: [22, 38],
    6: [32, 55],
    7: [45, 75],
    9: [80, 130],
  };

  // Penalty
  static const int mistakePenaltySeconds = 2;

  // Coins
  static const int coinsPerSession = 10;
  static const int coinsForRecord = 25;
  static const int coinsForStreak7 = 50;
  static const int coinsForStreak30 = 200;

  // XP thresholds per level
  static const Map<int, int> xpThresholds = {
    1: 0,
    2: 50,
    3: 120,
    4: 200,
    5: 300,
    6: 420,
    7: 560,
    8: 720,
    9: 900,
    10: 1100,
    11: 1350,
    12: 1650,
    13: 2000,
    14: 2400,
    15: 2850,
    16: 3350,
    17: 3900,
    18: 4500,
    19: 5200,
    20: 6000,
  };

  // Streak
  static const int sessionsForAdaptive = 5;

  // Parent PIN
  static const int parentPinLength = 4;
  static const int parentMaxPinAttempts = 3;
  static const int parentLockoutSeconds = 30;
  static const String parentPinHashKey = 'parentPinHash';
  static const String parentGridSizeModeKey = 'parentGridSizeMode';
  static const String parentFixedGridSizeKey = 'parentFixedGridSize';
  static const String parentMaxSessionTimeKey = 'parentMaxSessionTime';
  static const String notificationsEnabledKey = 'notificationsEnabled';

  // Onboarding Hive keys
  static const String userKeyChildAge = 'childAge';
  static const String userKeyGoals = 'goals';
  static const String userKeyDailyGoalMinutes = 'dailyGoalMinutes';
  static const String userKeyOnboardingCompleted = 'onboardingCompleted';

  // Onboarding options
  static const List<String> ageOptions = ['6-9', '10-12', '13-14'];
  static const List<String> goalOptions = [
    'concentration',
    'reading',
    'exams',
    'fun',
  ];
  static const List<int> frequencyOptions = [5, 10, 15];
  static const int recommendedFrequencyMinutes = 10;
  static const int onboardingPageCount = 7;

  // RevenueCat
  static const String revenueCatApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: 'appl_UoxUlnvJRWlCsjkQJkJIeoYxxJZ',
  );
  static const String revenueCatEntitlement = 'brainy_pro';
  static const String revenueCatOfferingId = 'default';

  // RevenueCat Product IDs
  static const String productIdMonthly = 'brainy_pro_monthly';
  static const String productIdYearly = 'brainy_pro_yearly';
  static const String productIdFamily = 'brainy_pro_family';

  // Hive box names
  static const String sessionsBox = 'sessions';
  static const String recordsBox = 'records';
  static const String userBox = 'user';
  static const String characterBox = 'character';
  static const String progressBox = 'progress';
  static const String progressDataKey = 'data';

  // Sound & haptic settings
  static const String soundEnabledKey = 'soundEnabled';
  static const String hapticEnabledKey = 'hapticEnabled';

  // Notification settings
  static const String hasCustomReminderTimeKey = 'hasCustomReminderTime';
  static const String customReminderHourKey = 'customReminderHour';
  static const String customReminderMinuteKey = 'customReminderMinute';
  static const int defaultReminderHour = 20;
  static const int defaultReminderMinute = 0;

  // Grid sizes for home screen picker
  static const List<int> pickerGridSizes = [3, 4, 5, 6, 7, 9];

  // Grid sizes available in Gorbov-Schulte mode (5x5 and above)
  static const List<int> gorbovGridSizes = [5, 6, 7, 9];

  // Legal URLs
  static const String legalBaseUrl = 'https://toffguy77.github.io/brainy-legal';
  static const String privacyPolicyUrlRu =
      '$legalBaseUrl/privacy-policy-ru.html';
  static const String privacyPolicyUrlEn =
      '$legalBaseUrl/privacy-policy-en.html';
  static const String termsUrlRu = '$legalBaseUrl/terms-ru.html';
  static const String termsUrlEn = '$legalBaseUrl/terms-en.html';
}
