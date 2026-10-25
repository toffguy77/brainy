// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Brainy';

  @override
  String get play => 'Играть';

  @override
  String get character => 'Персонаж';

  @override
  String get progress => 'Прогресс';

  @override
  String get newRecord => 'Новый рекорд!';

  @override
  String get greatResult => 'Отличный результат!';

  @override
  String get goodResult => 'Хороший результат!';

  @override
  String get keepPracticing => 'Продолжай тренироваться!';

  @override
  String timeSec(int seconds) {
    return '$seconds сек';
  }

  @override
  String timeMinSec(int minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get coinsEarned => 'Монеты';

  @override
  String get mistakes => 'Ошибки';

  @override
  String get personalRecord => 'Рекорд';

  @override
  String get playAgain => 'Сыграть ещё';

  @override
  String get home => 'Домой';

  @override
  String get onboardingWelcomeTitle => 'Тренируем мозг играючи';

  @override
  String get onboardingWelcomeSubtitle => 'Таблицы Шульте для детей 6–14 лет';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingAgeTitle => 'Сколько лет ребёнку?';

  @override
  String get onboardingAgeSubtitle => 'Подберём подходящую сложность';

  @override
  String get onboardingAge69 => '6 – 9 лет';

  @override
  String get onboardingAge1012 => '10 – 12 лет';

  @override
  String get onboardingAge1314 => '13 – 14 лет';

  @override
  String get onboardingGoalsTitle => 'Какая главная цель?';

  @override
  String get onboardingGoalsSubtitle => 'Выбери одно или несколько';

  @override
  String get onboardingGoalConcentration => 'Концентрация';

  @override
  String get onboardingGoalReading => 'Скорость чтения';

  @override
  String get onboardingGoalExams => 'Подготовка к экзаменам';

  @override
  String get onboardingGoalFun => 'Просто тренировка';

  @override
  String get onboardingFrequencyTitle => 'Сколько времени в день?';

  @override
  String get onboardingFrequencySubtitle =>
      'Даже 5 минут в день дают результат';

  @override
  String get onboardingFreq5min => '5 минут';

  @override
  String get onboardingFreq5minDesc => 'Лёгкий старт';

  @override
  String get onboardingFreq10min => '10 минут';

  @override
  String get onboardingFreq10minDesc => 'Рекомендуем';

  @override
  String get onboardingFreq15min => '15+ минут';

  @override
  String get onboardingFreq15minDesc => 'Интенсив';

  @override
  String get onboardingRecommended => 'Рекомендуем';

  @override
  String get onboardingSchulteTitle => 'Таблицы Шульте — тренажёр для мозга';

  @override
  String get onboardingSchulteSubtitle =>
      'Находи числа по порядку как можно быстрее. Чем больше таблица — тем сложнее!';

  @override
  String get onboardingSchulteHint => 'Найди числа по порядку: 1, 2, 3...';

  @override
  String get onboardingSchulteBenefit1 => 'Развивает внимание и концентрацию';

  @override
  String get onboardingSchulteBenefit2 => 'Расширяет периферическое зрение';

  @override
  String get onboardingSchulteBenefit3 => 'Ускоряет чтение в 1.5–2 раза';

  @override
  String get onboardingScienceTitle => 'Проверено наукой';

  @override
  String get onboardingScienceSubtitle =>
      'Методика создана немецким психиатром Вальтером Шульте в 1960-х для тренировки внимания';

  @override
  String get onboardingScienceFact1Value => '60+ лет';

  @override
  String get onboardingScienceFact1Label =>
      'используется в нейропсихологии и педагогике';

  @override
  String get onboardingScienceFact2Value => '2 недели';

  @override
  String get onboardingScienceFact2Label =>
      'для заметного улучшения скорости чтения при ежедневных занятиях';

  @override
  String get onboardingScienceFact3Value => '5 мин/день';

  @override
  String get onboardingScienceFact3Label =>
      'достаточно для результата — не перегружает ребёнка';

  @override
  String get playNow => 'Играть';

  @override
  String get selectGridSize => 'Размер таблицы';

  @override
  String lastResult(int gridSize, int seconds) {
    return 'Последний: $gridSize×$gridSize за $secondsс';
  }

  @override
  String get noSessionsYet => 'Нет игр — начнём!';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Серия $count дней',
      few: 'Серия $count дня',
      one: 'Серия $count день',
    );
    return '$_temp0';
  }

  @override
  String levelLabel(int level) {
    return 'Уровень $level';
  }

  @override
  String get characterScreenTitle => 'Мои персонажи';

  @override
  String get characterSelect => 'Выбрать';

  @override
  String get characterSelected => 'Выбран';

  @override
  String get accessoriesTitle => 'Кастомизация';

  @override
  String get accessoriesTabHats => 'Шляпы';

  @override
  String get accessoriesTabGlasses => 'Очки';

  @override
  String get accessoriesTabEffects => 'Эффекты';

  @override
  String get accessoriesTabCapes => 'Плащи';

  @override
  String get accessoriesEquip => 'Надеть';

  @override
  String get accessoriesRemove => 'Снять';

  @override
  String get accessoriesNotEnoughCoins => 'Не хватает монет';

  @override
  String accessoriesNotEnoughCoinsMessage(int price, int balance) {
    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: '$price монет',
      few: '$price монеты',
      one: '$price монета',
    );
    return 'Нужно $_temp0, а у тебя $balance';
  }

  @override
  String get accessoriesCustomize => 'Кастомизация';

  @override
  String get accessoriesPurchased => 'Куплено!';

  @override
  String get parentTitle => 'Прогресс ребёнка';

  @override
  String get parentSetPin => 'Установить PIN';

  @override
  String get parentEnterPin => 'Введите PIN';

  @override
  String get parentSetPinSubtitle =>
      'Придумайте 4-значный PIN для защиты настроек';

  @override
  String get parentEnterPinSubtitle => 'Введите 4-значный PIN';

  @override
  String get parentWrongPin => 'Неверный PIN';

  @override
  String parentLockedOut(int seconds) {
    return 'Слишком много попыток. Подождите $secondsс';
  }

  @override
  String get parentThisWeek => 'Эта неделя';

  @override
  String get parentStreak => 'Стрик';

  @override
  String get parentAvgTime => 'Среднее время';

  @override
  String get parentSessions => 'Сессий';

  @override
  String get parentDays => 'дней';

  @override
  String get parentSec => 'сек';

  @override
  String get parentProgressChart => 'Прогресс (14 дней)';

  @override
  String get parentNoChartData => 'Пока недостаточно данных';

  @override
  String get parentBestResults => 'Лучшие результаты';

  @override
  String parentBestTime(int seconds) {
    return 'Лучший: $secondsс';
  }

  @override
  String get parentNoRecord => '—';

  @override
  String get parentRecentSessions => 'Последние сессии';

  @override
  String get parentNoSessions => 'Нет сессий';

  @override
  String get parentSettingsTitle => 'Настройки родителя';

  @override
  String get parentGridSizeMode => 'Размер таблицы';

  @override
  String get parentGridSizeAuto => 'Авто';

  @override
  String get parentGridSizeFixed => 'Фиксированный';

  @override
  String get parentNotifications => 'Уведомления';

  @override
  String get parentChangePin => 'Сменить PIN';

  @override
  String get settingsPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get settingsDailyGoal => 'Дневная цель';

  @override
  String settingsMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get settingsTerms => 'Условия использования';

  @override
  String get privacyPolicyUrl =>
      'https://toffguy77.github.io/brainy-legal/privacy-policy-ru.html';

  @override
  String get termsUrl =>
      'https://toffguy77.github.io/brainy-legal/terms-ru.html';

  @override
  String get settingsLinkFailed => 'Не удалось открыть ссылку';

  @override
  String parentShareCardTitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дней тренировок подряд!',
      few: '$days дня тренировок подряд!',
      one: '$days день тренировок подряд!',
      zero: 'Начинаем тренировки!',
    );
    return '$_temp0';
  }

  @override
  String get parentShareBest5x5 => 'Лучший результат 5×5';

  @override
  String shareSeconds(int seconds) {
    return '$seconds с';
  }

  @override
  String get shareFailed => 'Не удалось поделиться. Попробуйте ещё раз.';

  @override
  String get parentShareDownload => 'Скачай Brainy: brainyapp.io';

  @override
  String get settingsSounds => 'Звуки';

  @override
  String get settingsHaptic => 'Вибрация';

  @override
  String get settingsReminderTime => 'Время напоминания';

  @override
  String get settingsDefaultTime => 'по умолчанию';

  @override
  String get settingsResetTime => 'Сбросить на 20:00';

  @override
  String get progressTitle => 'Мой прогресс';

  @override
  String get progressTotalGames => 'Игры';

  @override
  String get progressTotalXp => 'Опыт';

  @override
  String get progressBestStreak => 'Лучший стрик';

  @override
  String progressXpToNextLevel(int xp, int level) {
    return '$xp XP до уровня $level';
  }

  @override
  String get progressMaxLevel => 'Максимальный уровень!';

  @override
  String get progressNextGoals => 'Следующие цели';

  @override
  String progressGoalReachLevel(int level) {
    return 'Достигни уровня $level';
  }

  @override
  String progressGoalStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Стрик $days дней',
      few: 'Стрик $days дня',
      one: 'Стрик $days день',
    );
    return '$_temp0';
  }

  @override
  String progressGoalUnlock(String name) {
    return 'Открой $name';
  }

  @override
  String get progressRecords => 'Лучшее время';

  @override
  String get progressNoRecords => 'Играй, чтобы установить рекорды!';

  @override
  String starHintNext(int seconds, int stars) {
    return 'Пройди за $seconds сек для $stars★';
  }

  @override
  String gridDetailTitle(int size) {
    return 'Таблица $size×$size';
  }

  @override
  String get periodWeek => 'Нед';

  @override
  String get periodMonth => 'Мес';

  @override
  String get periodThreeMonths => '3М';

  @override
  String get periodYear => 'Год';

  @override
  String get periodAll => 'Всё';

  @override
  String get chartTimeLabel => 'ВРЕМЯ ПРОХОЖДЕНИЯ';

  @override
  String get statBestTime => 'Лучшее';

  @override
  String get statAverageTime => 'Среднее';

  @override
  String get statTotalGames => 'Всего игр';

  @override
  String gridDetailNoData(int size) {
    return 'Ещё нет данных для $size×$size';
  }

  @override
  String get gridDetailPlayMore =>
      'Сыграйте несколько раз, чтобы увидеть прогресс';

  @override
  String get legendDailyBest => 'Daily best';

  @override
  String get legendAllAttempts => 'Все попытки';

  @override
  String get legendRecord => 'Рекорд';

  @override
  String get achievementsTitle => 'Достижения';

  @override
  String achievementsCount(int unlocked, int total) {
    return '$unlocked / $total';
  }

  @override
  String get achievementUnlocked => 'Новое достижение!';

  @override
  String get achievementFirstGame => 'Первая игра';

  @override
  String get achievementFirstGameDesc => 'Заверши первую сессию';

  @override
  String get achievementPersonalRecord => 'Рекордсмен';

  @override
  String get achievementPersonalRecordDesc => 'Установи личный рекорд';

  @override
  String get achievementSpeedDemon => 'Молния';

  @override
  String get achievementSpeedDemonDesc => 'Пройди 3×3 за 5 секунд или быстрее';

  @override
  String get achievementMaster5x5 => 'Мастер 5×5';

  @override
  String get achievementMaster5x5Desc => 'Пройди 5×5 за 20 секунд или быстрее';

  @override
  String get achievementFocusMode => 'Фокус';

  @override
  String get achievementFocusModeDesc => 'Пройди таблицу без ошибок';

  @override
  String get achievementStreak3 => 'Стрик 3 дня';

  @override
  String get achievementStreak3Desc => 'Играй 3 дня подряд';

  @override
  String get achievementStreak7 => 'Неделя';

  @override
  String get achievementStreak7Desc => 'Играй 7 дней подряд';

  @override
  String get achievementStreak30 => 'Легенда месяца';

  @override
  String get achievementStreak30Desc => 'Играй 30 дней подряд';

  @override
  String get achievementNightOwl => 'Ночная сова';

  @override
  String get achievementNightOwlDesc => 'Сыграй сессию после 22:00';

  @override
  String get achievementCoinHoarder => 'Копилка';

  @override
  String get achievementCoinHoarderDesc => 'Накопи 500 монет';

  @override
  String get league => 'Лига';

  @override
  String get leagueTitle => 'Недельная лига';

  @override
  String get leagueBronze => 'Бронза';

  @override
  String get leagueSilver => 'Серебро';

  @override
  String get leagueGold => 'Золото';

  @override
  String get leaguePlatinum => 'Платина';

  @override
  String leagueWeeklyXp(int xp) {
    return '$xp XP за неделю';
  }

  @override
  String leagueNextTier(int xp, String tier) {
    return '$xp XP до $tier';
  }

  @override
  String get leagueMaxTier => 'Высшая лига достигнута!';

  @override
  String get leagueResetsMonday => 'Обновляется каждый понедельник';

  @override
  String get leagueYou => 'Ты';

  @override
  String get leagueConnectTitle => 'Соревнуйся с реальными игроками!';

  @override
  String get leagueConnectSubtitle =>
      'Подключи Game Center для настоящих лидербордов';

  @override
  String get leagueConnect => 'Подключить';

  @override
  String get leagueFullRanking => 'Полный рейтинг';

  @override
  String get leagueLoading => 'Загрузка рейтинга...';

  @override
  String get leagueError => 'Не удалось загрузить рейтинг';

  @override
  String get leagueEditName => 'Изменить имя';

  @override
  String get leagueEditNameHint => 'Введи своё имя';

  @override
  String get leagueEditNameSave => 'Сохранить';

  @override
  String get leagueEditNameCancel => 'Отмена';

  @override
  String appVersionLabel(Object version, Object buildNumber) {
    return 'Версия $version ($buildNumber)';
  }

  @override
  String get versionCopied => 'Версия скопирована';

  @override
  String get gameModeClassic => 'Классика';

  @override
  String get gameModeGorbov => 'Горбов';

  @override
  String gorbovHintWhite(int number) {
    return 'Найди: белую $number';
  }

  @override
  String gorbovHintRed(int number) {
    return 'Найди: красную $number';
  }

  @override
  String get gameModeReverse => 'Обратный';

  @override
  String get gameModeLetters => 'Буквенный';

  @override
  String get gameModeReverseHint => 'Нажимай числа по убыванию';

  @override
  String get gameModeLettersHint => 'Нажимай буквы по алфавиту';

  @override
  String get gameFind => 'Найди';

  @override
  String gameFoundProgress(int found, int total) {
    return 'Найдено: $found / $total';
  }

  @override
  String get gameModeClassicHint => 'Нажимай числа по возрастанию';

  @override
  String get gameModeGorbovHint =>
      'Чередуй: белые по возрастанию, красные по убыванию';

  @override
  String get gameModeReverseBadge => 'Обр';

  @override
  String get gameModeGorbovBadge => 'Горб';

  @override
  String get gameModeLettersBadge => 'Букв';

  @override
  String homeDailyGoal(int played, int goal) {
    return 'Сегодня: $played из $goal мин';
  }

  @override
  String get homeDailyGoalDone => 'Цель дня выполнена!';

  @override
  String homeSuggestNextSize(int size) {
    return 'Готов к $size×$size? Попробуй!';
  }

  @override
  String resultNewCharacter(String name) {
    return 'Новый персонаж: $name!';
  }

  @override
  String get gamePaused => 'Пауза';

  @override
  String get gameTapToResume => 'Нажми, чтобы продолжить';

  @override
  String get characterBrainyName => 'Брейни';

  @override
  String get characterBrainyDescription =>
      'Мозг с характером. Стартовый герой!';

  @override
  String get characterBrainyUnlock => 'Доступен бесплатно';

  @override
  String get characterZapName => 'Зэп';

  @override
  String get characterZapDescription =>
      'Электрический роботёнок. Быстрый как молния!';

  @override
  String get characterZapUnlock => 'Достигни уровня 10';

  @override
  String get characterVortexName => 'Вортекс';

  @override
  String get characterVortexDescription =>
      'Загадочный и странный. Любит вихри.';

  @override
  String get characterVortexUnlock => 'Стрик 30 дней';

  @override
  String get characterPixelName => 'Пиксель';

  @override
  String get characterPixelDescription => '8-битный герой из прошлого.';

  @override
  String get characterPixelUnlock => 'Стрик 14 дней';

  @override
  String get characterGlitchName => 'Глитч';

  @override
  String get characterGlitchDescription => 'Сломан, но не сломлен.';

  @override
  String get characterGlitchUnlock => 'Стрик 60 дней';

  @override
  String get accessoryHatScientistName => 'Колпак учёного';

  @override
  String get accessoryHatCrownName => 'Корона';

  @override
  String get accessoryHatCapName => 'Кепка';

  @override
  String get accessoryHatHelmetName => 'Шлем';

  @override
  String get accessoryHatTophatName => 'Цилиндр';

  @override
  String get accessoryGlassesSmartName => 'Умные очки';

  @override
  String get accessoryGlassesSunName => 'Солнцезащитные';

  @override
  String get accessoryGlassesPixelName => 'Пиксельные';

  @override
  String get accessoryGlassesVrName => 'VR-шлем';

  @override
  String get accessoryEffectStarsName => 'Звёзды';

  @override
  String get accessoryEffectFireName => 'Огонь';

  @override
  String get accessoryEffectElectricName => 'Электричество';

  @override
  String get accessoryCapeMantleName => 'Мантия';

  @override
  String get accessoryCapeNinjaName => 'Плащ ниндзя';

  @override
  String get accessoryCapeWingsName => 'Крылья';

  @override
  String get notificationMotivation1 => 'Время потренировать мозг!';

  @override
  String notificationStreak1(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Стрик $count дней сгорит сегодня!',
      few: 'Стрик $count дня сгорит сегодня!',
      one: 'Стрик $count день сгорит сегодня!',
    );
    return '$_temp0';
  }

  @override
  String get notificationMotivation2 => 'Брейни ждёт тебя! Зайди на тренировку';

  @override
  String notificationStreak2(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не потеряй свой стрик $count дней!',
      few: 'Не потеряй свой стрик $count дня!',
      one: 'Не потеряй свой стрик $count день!',
    );
    return '$_temp0';
  }

  @override
  String get notificationMotivation3 =>
      'Несколько минут — и мозг станет быстрее!';

  @override
  String notificationStreak3(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дней подряд — не останавливайся!',
      few: '$count дня подряд — не останавливайся!',
      one: '$count день подряд — не останавливайся!',
    );
    return '$_temp0';
  }

  @override
  String get notificationMotivation4 => 'Зэп зовёт на тренировку!';

  @override
  String notificationStreak4(int count) {
    return 'Стрик в опасности! Сыграй сегодня';
  }

  @override
  String get notificationMotivation5 => 'Сегодня ещё не тренировались. Начнём?';

  @override
  String notificationStreak5(int count) {
    return 'Осталось немного до конца дня. Сохрани стрик!';
  }

  @override
  String get notificationMotivation6 => 'Мозг любит тренировки. Не пропусти!';

  @override
  String notificationStreak6(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Твой стрик $count дней на волоске!',
      few: 'Твой стрик $count дня на волоске!',
      one: 'Твой стрик $count день на волоске!',
    );
    return '$_temp0';
  }

  @override
  String get notificationMotivation7 =>
      'Пора размять мозг! Таблица Шульте ждёт';

  @override
  String notificationStreak7(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Брейни переживает за стрик $count дней!',
      few: 'Брейни переживает за стрик $count дня!',
      one: 'Брейни переживает за стрик $count день!',
    );
    return '$_temp0';
  }

  @override
  String get settingsNotificationsDenied =>
      'Уведомления запрещены. Разрешите их в Настройках iOS.';

  @override
  String progressStreakProgress(int current, int required) {
    String _temp0 = intl.Intl.pluralLogic(
      required,
      locale: localeName,
      other: '$required дней',
      few: '$required дня',
      one: '$required день',
    );
    return '$current / $_temp0';
  }
}
