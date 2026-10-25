// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Brainy';

  @override
  String get play => 'Play';

  @override
  String get character => 'Character';

  @override
  String get progress => 'Progress';

  @override
  String get newRecord => 'New Record!';

  @override
  String get greatResult => 'Great Result!';

  @override
  String get goodResult => 'Good Result!';

  @override
  String get keepPracticing => 'Keep Practicing!';

  @override
  String timeSec(int seconds) {
    return '$seconds sec';
  }

  @override
  String timeMinSec(int minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get coinsEarned => 'Coins';

  @override
  String get mistakes => 'Mistakes';

  @override
  String get personalRecord => 'Record';

  @override
  String get playAgain => 'Play Again';

  @override
  String get home => 'Home';

  @override
  String get onboardingWelcomeTitle => 'Train your brain playfully';

  @override
  String get onboardingWelcomeSubtitle => 'Schulte tables for kids 6–14';

  @override
  String get onboardingStart => 'Start';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingAgeTitle => 'How old is your child?';

  @override
  String get onboardingAgeSubtitle => 'We\'ll adapt the difficulty';

  @override
  String get onboardingAge69 => '6 – 9 years';

  @override
  String get onboardingAge1012 => '10 – 12 years';

  @override
  String get onboardingAge1314 => '13 – 14 years';

  @override
  String get onboardingGoalsTitle => 'What\'s the main goal?';

  @override
  String get onboardingGoalsSubtitle => 'Select one or more';

  @override
  String get onboardingGoalConcentration => 'Concentration';

  @override
  String get onboardingGoalReading => 'Speed reading';

  @override
  String get onboardingGoalExams => 'Exam prep';

  @override
  String get onboardingGoalFun => 'Just for fun';

  @override
  String get onboardingFrequencyTitle => 'Daily practice time';

  @override
  String get onboardingFrequencySubtitle => 'Even 5 minutes a day helps';

  @override
  String get onboardingFreq5min => '5 minutes';

  @override
  String get onboardingFreq5minDesc => 'Easy start';

  @override
  String get onboardingFreq10min => '10 minutes';

  @override
  String get onboardingFreq10minDesc => 'Recommended';

  @override
  String get onboardingFreq15min => '15+ minutes';

  @override
  String get onboardingFreq15minDesc => 'Intensive';

  @override
  String get onboardingRecommended => 'Recommended';

  @override
  String get onboardingSchulteTitle => 'Schulte Tables — Brain Trainer';

  @override
  String get onboardingSchulteSubtitle =>
      'Find the numbers in order as fast as you can. Bigger grid — harder challenge!';

  @override
  String get onboardingSchulteHint => 'Find the numbers in order: 1, 2, 3...';

  @override
  String get onboardingSchulteBenefit1 => 'Builds attention and concentration';

  @override
  String get onboardingSchulteBenefit2 => 'Expands peripheral vision';

  @override
  String get onboardingSchulteBenefit3 => 'Boosts reading speed 1.5–2×';

  @override
  String get onboardingScienceTitle => 'Backed by Science';

  @override
  String get onboardingScienceSubtitle =>
      'Developed by German psychiatrist Walter Schulte in the 1960s for attention training';

  @override
  String get onboardingScienceFact1Value => '60+ years';

  @override
  String get onboardingScienceFact1Label =>
      'used in neuropsychology and education';

  @override
  String get onboardingScienceFact2Value => '2 weeks';

  @override
  String get onboardingScienceFact2Label =>
      'to noticeably improve reading speed with daily practice';

  @override
  String get onboardingScienceFact3Value => '5 min/day';

  @override
  String get onboardingScienceFact3Label =>
      'enough for results — won\'t overwhelm your child';

  @override
  String get playNow => 'Play Now';

  @override
  String get selectGridSize => 'Select table size';

  @override
  String lastResult(int gridSize, int seconds) {
    return 'Last: $gridSize×$gridSize in ${seconds}s';
  }

  @override
  String get noSessionsYet => 'No games yet — let\'s start!';

  @override
  String streakDays(int count) {
    return '$count day streak';
  }

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String get characterScreenTitle => 'My Characters';

  @override
  String get characterSelect => 'Select';

  @override
  String get characterSelected => 'Selected';

  @override
  String get accessoriesTitle => 'Customization';

  @override
  String get accessoriesTabHats => 'Hats';

  @override
  String get accessoriesTabGlasses => 'Glasses';

  @override
  String get accessoriesTabEffects => 'Effects';

  @override
  String get accessoriesTabCapes => 'Capes';

  @override
  String get accessoriesEquip => 'Equip';

  @override
  String get accessoriesRemove => 'Remove';

  @override
  String get accessoriesNotEnoughCoins => 'Not enough coins';

  @override
  String accessoriesNotEnoughCoinsMessage(int price, int balance) {
    return 'You need $price coins, but you have $balance';
  }

  @override
  String get accessoriesCustomize => 'Customize';

  @override
  String get accessoriesPurchased => 'Purchased!';

  @override
  String get parentTitle => 'Child\'s Progress';

  @override
  String get parentSetPin => 'Set PIN';

  @override
  String get parentEnterPin => 'Enter PIN';

  @override
  String get parentSetPinSubtitle =>
      'Create a 4-digit PIN to protect parent settings';

  @override
  String get parentEnterPinSubtitle => 'Enter your 4-digit PIN';

  @override
  String get parentWrongPin => 'Wrong PIN';

  @override
  String parentLockedOut(int seconds) {
    return 'Too many attempts. Try again in ${seconds}s';
  }

  @override
  String get parentThisWeek => 'This Week';

  @override
  String get parentStreak => 'Streak';

  @override
  String get parentAvgTime => 'Avg Time';

  @override
  String get parentSessions => 'Sessions';

  @override
  String get parentDays => 'days';

  @override
  String get parentSec => 'sec';

  @override
  String get parentProgressChart => 'Progress (last 14 days)';

  @override
  String get parentNoChartData => 'Not enough data yet';

  @override
  String get parentBestResults => 'Best Results';

  @override
  String parentBestTime(int seconds) {
    return 'Best: ${seconds}s';
  }

  @override
  String get parentNoRecord => '—';

  @override
  String get parentRecentSessions => 'Recent Sessions';

  @override
  String get parentNoSessions => 'No sessions yet';

  @override
  String get parentSettingsTitle => 'Parent Settings';

  @override
  String get parentGridSizeMode => 'Grid Size';

  @override
  String get parentGridSizeAuto => 'Auto';

  @override
  String get parentGridSizeFixed => 'Fixed';

  @override
  String get parentNotifications => 'Notifications';

  @override
  String get parentChangePin => 'Change PIN';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsDailyGoal => 'Daily goal';

  @override
  String settingsMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get settingsTerms => 'Terms of Use';

  @override
  String get privacyPolicyUrl =>
      'https://toffguy77.github.io/brainy-legal/privacy-policy-en.html';

  @override
  String get termsUrl =>
      'https://toffguy77.github.io/brainy-legal/terms-en.html';

  @override
  String get settingsLinkFailed => 'Couldn\'t open the link';

  @override
  String parentShareCardTitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days of training in a row!',
      one: '1 day of training in a row!',
      zero: 'Just getting started!',
    );
    return '$_temp0';
  }

  @override
  String get parentShareBest5x5 => 'Best 5×5 result';

  @override
  String shareSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get shareFailed => 'Couldn\'t share. Please try again.';

  @override
  String get parentShareDownload => 'Download Brainy: brainyapp.io';

  @override
  String get settingsSounds => 'Sounds';

  @override
  String get settingsHaptic => 'Vibration';

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String get settingsDefaultTime => 'default';

  @override
  String get settingsResetTime => 'Reset to 20:00';

  @override
  String get progressTitle => 'My Progress';

  @override
  String get progressTotalGames => 'Games';

  @override
  String get progressTotalXp => 'XP';

  @override
  String get progressBestStreak => 'Best Streak';

  @override
  String progressXpToNextLevel(int xp, int level) {
    return '$xp XP to level $level';
  }

  @override
  String get progressMaxLevel => 'Max level reached!';

  @override
  String get progressNextGoals => 'Next Goals';

  @override
  String progressGoalReachLevel(int level) {
    return 'Reach level $level';
  }

  @override
  String progressGoalStreak(int days) {
    return '$days-day streak';
  }

  @override
  String progressGoalUnlock(String name) {
    return 'Unlock $name';
  }

  @override
  String get progressRecords => 'Best Times';

  @override
  String get progressNoRecords => 'Play to set records!';

  @override
  String starHintNext(int seconds, int stars) {
    return 'Finish in ${seconds}s for $stars★';
  }

  @override
  String gridDetailTitle(int size) {
    return 'Table $size×$size';
  }

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodThreeMonths => '3M';

  @override
  String get periodYear => 'Year';

  @override
  String get periodAll => 'All';

  @override
  String get chartTimeLabel => 'COMPLETION TIME';

  @override
  String get statBestTime => 'Best';

  @override
  String get statAverageTime => 'Average';

  @override
  String get statTotalGames => 'Total games';

  @override
  String gridDetailNoData(int size) {
    return 'No data yet for $size×$size';
  }

  @override
  String get gridDetailPlayMore => 'Play a few games to see progress';

  @override
  String get legendDailyBest => 'Daily best';

  @override
  String get legendAllAttempts => 'All attempts';

  @override
  String get legendRecord => 'Record';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String achievementsCount(int unlocked, int total) {
    return '$unlocked / $total';
  }

  @override
  String get achievementUnlocked => 'Achievement Unlocked!';

  @override
  String get achievementFirstGame => 'First Game';

  @override
  String get achievementFirstGameDesc => 'Complete your first session';

  @override
  String get achievementPersonalRecord => 'Record Breaker';

  @override
  String get achievementPersonalRecordDesc => 'Set a personal record';

  @override
  String get achievementSpeedDemon => 'Speed Demon';

  @override
  String get achievementSpeedDemonDesc => 'Complete 3×3 in 5 seconds or less';

  @override
  String get achievementMaster5x5 => '5×5 Master';

  @override
  String get achievementMaster5x5Desc => 'Complete 5×5 in 20 seconds or less';

  @override
  String get achievementFocusMode => 'Focus Mode';

  @override
  String get achievementFocusModeDesc => 'Complete a session without mistakes';

  @override
  String get achievementStreak3 => '3-Day Streak';

  @override
  String get achievementStreak3Desc => 'Play 3 days in a row';

  @override
  String get achievementStreak7 => 'Week Warrior';

  @override
  String get achievementStreak7Desc => 'Play 7 days in a row';

  @override
  String get achievementStreak30 => 'Monthly Legend';

  @override
  String get achievementStreak30Desc => 'Play 30 days in a row';

  @override
  String get achievementNightOwl => 'Night Owl';

  @override
  String get achievementNightOwlDesc => 'Play a session after 10 PM';

  @override
  String get achievementCoinHoarder => 'Coin Hoarder';

  @override
  String get achievementCoinHoarderDesc => 'Accumulate 500 coins';

  @override
  String get league => 'League';

  @override
  String get leagueTitle => 'Weekly League';

  @override
  String get leagueBronze => 'Bronze';

  @override
  String get leagueSilver => 'Silver';

  @override
  String get leagueGold => 'Gold';

  @override
  String get leaguePlatinum => 'Platinum';

  @override
  String leagueWeeklyXp(int xp) {
    return '$xp XP this week';
  }

  @override
  String leagueNextTier(int xp, String tier) {
    return '$xp XP to $tier';
  }

  @override
  String get leagueMaxTier => 'Highest league reached!';

  @override
  String get leagueResetsMonday => 'Resets every Monday';

  @override
  String get leagueYou => 'You';

  @override
  String get leagueConnectTitle => 'Compete with real players!';

  @override
  String get leagueConnectSubtitle =>
      'Connect Game Center to see real leaderboards';

  @override
  String get leagueConnect => 'Connect';

  @override
  String get leagueFullRanking => 'Full Ranking';

  @override
  String get leagueLoading => 'Loading leaderboard...';

  @override
  String get leagueError => 'Could not load leaderboard';

  @override
  String get leagueEditName => 'Edit name';

  @override
  String get leagueEditNameHint => 'Enter your name';

  @override
  String get leagueEditNameSave => 'Save';

  @override
  String get leagueEditNameCancel => 'Cancel';

  @override
  String appVersionLabel(Object version, Object buildNumber) {
    return 'Version $version ($buildNumber)';
  }

  @override
  String get versionCopied => 'Version copied';

  @override
  String get gameModeClassic => 'Classic';

  @override
  String get gameModeGorbov => 'Gorbov';

  @override
  String gorbovHintWhite(int number) {
    return 'Find: white $number';
  }

  @override
  String gorbovHintRed(int number) {
    return 'Find: red $number';
  }

  @override
  String get gameModeReverse => 'Reverse';

  @override
  String get gameModeLetters => 'Letters';

  @override
  String get gameModeReverseHint => 'Tap numbers in descending order';

  @override
  String get gameModeLettersHint => 'Tap letters in alphabetical order';

  @override
  String get gameFind => 'Find';

  @override
  String gameFoundProgress(int found, int total) {
    return 'Found: $found / $total';
  }

  @override
  String get gameModeClassicHint => 'Tap numbers in ascending order';

  @override
  String get gameModeGorbovHint => 'Alternate: white ascending, red descending';

  @override
  String get gameModeReverseBadge => 'Rev';

  @override
  String get gameModeGorbovBadge => 'Gorb';

  @override
  String get gameModeLettersBadge => 'ABC';

  @override
  String homeDailyGoal(int played, int goal) {
    return 'Today: $played of $goal min';
  }

  @override
  String get homeDailyGoalDone => 'Daily goal reached!';

  @override
  String homeSuggestNextSize(int size) {
    return 'Ready for $size×$size? Give it a go!';
  }

  @override
  String resultNewCharacter(String name) {
    return 'New character: $name!';
  }

  @override
  String get gamePaused => 'Paused';

  @override
  String get gameTapToResume => 'Tap to continue';

  @override
  String get characterBrainyName => 'Brainy';

  @override
  String get characterBrainyDescription =>
      'A brain with personality. Starter hero!';

  @override
  String get characterBrainyUnlock => 'Available for free';

  @override
  String get characterZapName => 'Zap';

  @override
  String get characterZapDescription =>
      'Electric little robot. Fast as lightning!';

  @override
  String get characterZapUnlock => 'Reach level 10';

  @override
  String get characterVortexName => 'Vortex';

  @override
  String get characterVortexDescription =>
      'Mysterious and strange. Loves whirlwinds.';

  @override
  String get characterVortexUnlock => '30-day streak';

  @override
  String get characterPixelName => 'Pixel';

  @override
  String get characterPixelDescription => '8-bit hero from the past.';

  @override
  String get characterPixelUnlock => '14-day streak';

  @override
  String get characterGlitchName => 'Glitch';

  @override
  String get characterGlitchDescription => 'Broken, but not defeated.';

  @override
  String get characterGlitchUnlock => '60-day streak';

  @override
  String get accessoryHatScientistName => 'Scientist Cap';

  @override
  String get accessoryHatCrownName => 'Crown';

  @override
  String get accessoryHatCapName => 'Baseball Cap';

  @override
  String get accessoryHatHelmetName => 'Helmet';

  @override
  String get accessoryHatTophatName => 'Top Hat';

  @override
  String get accessoryGlassesSmartName => 'Smart Glasses';

  @override
  String get accessoryGlassesSunName => 'Sunglasses';

  @override
  String get accessoryGlassesPixelName => 'Pixel Glasses';

  @override
  String get accessoryGlassesVrName => 'VR Headset';

  @override
  String get accessoryEffectStarsName => 'Stars';

  @override
  String get accessoryEffectFireName => 'Fire';

  @override
  String get accessoryEffectElectricName => 'Electricity';

  @override
  String get accessoryCapeMantleName => 'Mantle';

  @override
  String get accessoryCapeNinjaName => 'Ninja Cloak';

  @override
  String get accessoryCapeWingsName => 'Wings';

  @override
  String get notificationMotivation1 => 'Time to train your brain!';

  @override
  String notificationStreak1(int count) {
    return 'Your $count-day streak expires today!';
  }

  @override
  String get notificationMotivation2 =>
      'Brainy is waiting for you! Start training';

  @override
  String notificationStreak2(int count) {
    return 'Don\'t lose your $count-day streak!';
  }

  @override
  String get notificationMotivation3 =>
      'A few minutes and your brain gets faster!';

  @override
  String notificationStreak3(int count) {
    return '$count days in a row — don\'t stop now!';
  }

  @override
  String get notificationMotivation4 => 'Zap is calling you to practice!';

  @override
  String notificationStreak4(int count) {
    return 'Streak in danger! Play today';
  }

  @override
  String get notificationMotivation5 =>
      'Haven\'t trained today yet. Shall we start?';

  @override
  String notificationStreak5(int count) {
    return 'Day is almost over. Save your streak!';
  }

  @override
  String get notificationMotivation6 =>
      'Your brain loves training. Don\'t skip it!';

  @override
  String notificationStreak6(int count) {
    return 'Your $count-day streak is hanging by a thread!';
  }

  @override
  String get notificationMotivation7 =>
      'Time to exercise your brain! Schulte table awaits';

  @override
  String notificationStreak7(int count) {
    return 'Brainy is worried about your $count-day streak!';
  }

  @override
  String get settingsNotificationsDenied =>
      'Notifications are blocked. Allow them in iOS Settings.';
}
