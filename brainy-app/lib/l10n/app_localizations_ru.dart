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
  String get settings => 'Настройки';

  @override
  String get continue_ => 'Продолжить';

  @override
  String get skip => 'Пропустить';

  @override
  String get back => 'Назад';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get result => 'Результат';

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
  String get onboardingPaywallTitle => 'Попробуй Premium бесплатно';

  @override
  String get onboardingPaywallBenefit1 => 'Все размеры таблиц (6×6, 7×7, 9×9)';

  @override
  String get onboardingPaywallBenefit2 => 'Все 5 персонажей';

  @override
  String get onboardingPaywallBenefit3 => 'Полная статистика прогресса';

  @override
  String get onboardingPaywallBenefit4 => 'Без рекламы';

  @override
  String get onboardingTryFree => 'Начать 7 дней бесплатно';

  @override
  String get onboardingSkipPaywall => 'Продолжить без подписки';

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
  String get onboardingAlreadySubscribed => 'Вы уже подписаны!';

  @override
  String get onboardingLetsGo => 'Поехали!';

  @override
  String get playNow => 'Играть';

  @override
  String get selectGridSize => 'Размер таблицы';

  @override
  String get premiumGridLocked => 'Доступно в Premium';

  @override
  String lastResult(int gridSize, int seconds) {
    return 'Последний: $gridSize×$gridSize за $secondsс';
  }

  @override
  String get noSessionsYet => 'Нет игр — начнём!';

  @override
  String streakDays(int count) {
    return 'Серия $count дней';
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
  String get characterUnlockPremium => 'Открыть Premium';

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
  String get accessoriesBuy => 'Купить';

  @override
  String get accessoriesEquip => 'Надеть';

  @override
  String get accessoriesEquipped => 'Надето';

  @override
  String get accessoriesRemove => 'Снять';

  @override
  String get accessoriesPremiumOnly => 'Premium';

  @override
  String get accessoriesNotEnoughCoins => 'Не хватает монет';

  @override
  String accessoriesNotEnoughCoinsMessage(int price, int balance) {
    return 'Нужно $price монет, а у тебя $balance';
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
  String get parentPremiumOnly => 'Premium';

  @override
  String get parentRecentSessions => 'Последние сессии';

  @override
  String get parentNoSessions => 'Нет сессий';

  @override
  String get parentShare => 'Поделиться';

  @override
  String get parentSettings => 'Настройки';

  @override
  String get parentSettingsTitle => 'Настройки родителя';

  @override
  String get parentGridSizeMode => 'Размер таблицы';

  @override
  String get parentGridSizeAuto => 'Авто';

  @override
  String get parentGridSizeFixed => 'Фиксированный';

  @override
  String get parentMaxSessionTime => 'Макс. время сессии';

  @override
  String get parentNoLimit => 'Без ограничений';

  @override
  String parentMinutes(int min) {
    return '$min мин';
  }

  @override
  String get parentNotifications => 'Уведомления';

  @override
  String get parentChangePin => 'Сменить PIN';

  @override
  String get parentManageSubscription => 'Управление подпиской';

  @override
  String parentShareCardTitle(int days) {
    return 'тренируется уже $days дней!';
  }

  @override
  String get parentShareBest5x5 => 'Лучший результат 5×5';

  @override
  String get parentShareDownload => 'Скачай Brainy: brainyapp.io';

  @override
  String get parentStars => 'Звёзды';

  @override
  String get paywallTitle => 'Brainy Premium';

  @override
  String get paywallSubtitle => 'Открой всё и тренируйся без ограничений';

  @override
  String get paywallBenefit1 => 'Все размеры таблиц — до 9×9';

  @override
  String get paywallBenefit2 => '5 уникальных персонажей';

  @override
  String get paywallBenefit3 => 'Панель прогресса для родителей';

  @override
  String get paywallBenefit4 => 'Без рекламы';

  @override
  String get paywallBenefit5 => 'Режим Горбова-Шульте';

  @override
  String get paywallPlanYear => 'Год';

  @override
  String get paywallPlanMonth => 'Месяц';

  @override
  String get paywallPlanFamily => 'Семейная';

  @override
  String get paywallBestPrice => 'Лучшая цена';

  @override
  String paywallPerMonth(String price) {
    return '~$price/мес';
  }

  @override
  String get paywallTryFree => 'Начать 7 дней бесплатно';

  @override
  String get paywallSubscribe => 'Подписаться';

  @override
  String get paywallDisclaimer =>
      'Отмена в любое время. Управление подпиской в App Store.';

  @override
  String get paywallRestore => 'Восстановить покупки';

  @override
  String get paywallTerms => 'Условия';

  @override
  String get paywallPrivacy => 'Конфиденциальность';

  @override
  String get paywallWelcome => 'Добро пожаловать в Premium!';

  @override
  String get paywallErrorTitle => 'Ошибка покупки';

  @override
  String get paywallErrorMessage => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get paywallLoading => 'Загрузка планов...';

  @override
  String get premiumFeatureLocked => 'Это Premium фича';

  @override
  String get premiumUnlock => 'Открыть Premium';

  @override
  String get premiumTryFree => 'Попробовать бесплатно 7 дней';

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
    return 'Стрик $days дней';
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
  String get progressStartPlaying => 'Начни играть, чтобы видеть прогресс!';

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
  String get leagueNotConnected => 'Game Center не подключён';
}
