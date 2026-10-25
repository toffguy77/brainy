import 'game_modes.dart';

class AppConstants {
  AppConstants._();

  // Grid sizes
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

  /// Letters mode is materially slower than digits — recognising a letter is a
  /// different lookup, and children read digits faster. Reusing the digit
  /// thresholds would put three stars out of reach. Deliberately loose; tighten
  /// once real play data exists.
  static const Map<int, List<int>> starThresholdsLetters = {
    3: [12, 22],
    4: [21, 38],
    5: [33, 57],
  };

  /// Star thresholds for [mode] at [gridSize], or null if unrated.
  /// Reverse is the same visual search as classic with a different traversal,
  /// so it reuses the classic thresholds.
  static List<int>? starThresholdsFor(String mode, int gridSize) =>
      mode == GameModes.letters
          ? starThresholdsLetters[gridSize]
          : starThresholds[gridSize];

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

  // Adaptive difficulty: suggest the next size once the average of the last
  // [sessionsForAdaptive] games at the current size and mode meets the target.
  static const int sessionsForAdaptive = 5;

  /// Target time for adaptive difficulty. Letters and Gorbov are slower
  /// searches than digits (recognising a letter; alternating two sequences),
  /// so their targets are deliberately loose multiples of the digit target.
  static int? adaptiveTargetSeconds(String mode, int gridSize) {
    final base = targetTimes[gridSize];
    if (base == null) return null;
    return switch (mode) {
      GameModes.letters => (base * 3) ~/ 2,
      GameModes.gorbov => base * 2,
      _ => base,
    };
  }

  // Parent PIN
  static const int parentPinLength = 4;
  static const int parentMaxPinAttempts = 3;
  static const int parentLockoutSeconds = 30;
  static const String parentPinHashKey = 'parentPinHash';
  static const String parentPinFailedAttemptsKey = 'parentPinFailedAttempts';
  static const String parentPinLockedUntilKey = 'parentPinLockedUntil';
  static const String parentGridSizeModeKey = 'parentGridSizeMode';
  static const String parentFixedGridSizeKey = 'parentFixedGridSize';
  static const String gridSizeModeAuto = 'auto';
  static const String gridSizeModeFixed = 'fixed';
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
  static const int onboardingPageCount = 6;

  // Hive box names
  static const String sessionsBox = 'sessions';
  static const String recordsBox = 'records';
  static const String userBox = 'user';
  static const String characterBox = 'character';
  static const String progressBox = 'progress';
  static const String progressDataKey = 'data';

  // Last mode picked on the home screen
  static const String lastSelectedModeKey = 'lastSelectedMode';

  // Custom player name
  static const String customPlayerNameKey = 'customPlayerName';

  // Sound & haptic settings
  static const String soundEnabledKey = 'soundEnabled';
  static const String hapticEnabledKey = 'hapticEnabled';

  // Notification settings
  static const String hasCustomReminderTimeKey = 'hasCustomReminderTime';
  static const String customReminderHourKey = 'customReminderHour';
  static const String customReminderMinuteKey = 'customReminderMinute';
  static const int defaultReminderHour = 20;
  static const int defaultReminderMinute = 0;

  /// Above this streak a reminder warns the streak is at risk instead of
  /// motivating a fresh start.
  static const int streakWarningThreshold = 2;

  /// Reminders are scheduled as one-off notifications this many days ahead,
  /// so they keep coming when the app is not opened, and today can be skipped
  /// once the child has played.
  static const int reminderDaysAhead = 7;

  // Grid sizes for home screen picker
  static const List<int> pickerGridSizes = [3, 4, 5, 6, 7, 9];

  // Grid sizes available in Gorbov-Schulte mode (5x5 and above)
  static const List<int> gorbovGridSizes = [5, 6, 7, 9];

  // Letters mode: bounded by the SHORTEST supported alphabet, not the active
  // one, so the sizes on offer do not change when the user switches language.
  // Latin has 26 usable letters, so 5x5 (25 cells) is the ceiling.
  static const List<int> lettersGridSizes = [3, 4, 5];

  static const List<int> reverseGridSizes = allGridSizes;

  /// Russian alphabet without «Ё» and «Й»: at grid cell sizes they differ from
  /// «Е» and «И» by a few pixels, which would make a mistap a matter of
  /// eyesight rather than sequencing.
  static const List<String> alphabetRu = [
    'А','Б','В','Г','Д','Е','Ж','З','И','К','Л','М','Н','О','П','Р',
    'С','Т','У','Ф','Х','Ц','Ч','Ш','Щ','Ъ','Ы','Ь','Э','Ю','Я',
  ];

  static const List<String> alphabetEn = [
    'A','B','C','D','E','F','G','H','I','J','K','L','M',
    'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
  ];

  /// Supported UI languages. The first is the fallback for any other device
  /// language — English is the widest-understood choice.
  static const List<String> supportedLanguages = ['en', 'ru'];

  /// Map a device language to a supported one ('ru' or 'en').
  static String resolveLanguage(String? languageCode) =>
      supportedLanguages.contains(languageCode)
          ? languageCode!
          : supportedLanguages.first;

  static List<String> alphabetFor(String locale) =>
      locale == 'ru' ? alphabetRu : alphabetEn;

  /// Grid sizes available in a given mode.
  static List<int> gridSizesForMode(String mode) => switch (mode) {
        GameModes.gorbov => gorbovGridSizes,
        GameModes.letters => lettersGridSizes,
        GameModes.reverse => reverseGridSizes,
        _ => pickerGridSizes,
      };

  /// Clamp [size] into the range [mode] allows, picking the nearest option.
  static int clampGridSizeForMode(String mode, int size) {
    final sizes = gridSizesForMode(mode);
    if (sizes.contains(size)) return size;
    return sizes.reduce((a, b) => (a - size).abs() <= (b - size).abs() ? a : b);
  }
}
