import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'Brainy'**
  String get appName;

  /// No description provided for @play.
  ///
  /// In ru, this message translates to:
  /// **'Играть'**
  String get play;

  /// No description provided for @character.
  ///
  /// In ru, this message translates to:
  /// **'Персонаж'**
  String get character;

  /// No description provided for @progress.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс'**
  String get progress;

  /// No description provided for @settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// No description provided for @continue_.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get continue_;

  /// No description provided for @skip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get back;

  /// No description provided for @comingSoon.
  ///
  /// In ru, this message translates to:
  /// **'Скоро'**
  String get comingSoon;

  /// No description provided for @result.
  ///
  /// In ru, this message translates to:
  /// **'Результат'**
  String get result;

  /// No description provided for @newRecord.
  ///
  /// In ru, this message translates to:
  /// **'Новый рекорд!'**
  String get newRecord;

  /// No description provided for @greatResult.
  ///
  /// In ru, this message translates to:
  /// **'Отличный результат!'**
  String get greatResult;

  /// No description provided for @goodResult.
  ///
  /// In ru, this message translates to:
  /// **'Хороший результат!'**
  String get goodResult;

  /// No description provided for @keepPracticing.
  ///
  /// In ru, this message translates to:
  /// **'Продолжай тренироваться!'**
  String get keepPracticing;

  /// No description provided for @timeSec.
  ///
  /// In ru, this message translates to:
  /// **'{seconds} сек'**
  String timeSec(int seconds);

  /// No description provided for @timeMinSec.
  ///
  /// In ru, this message translates to:
  /// **'{minutes}:{seconds}'**
  String timeMinSec(int minutes, String seconds);

  /// No description provided for @coinsEarned.
  ///
  /// In ru, this message translates to:
  /// **'Монеты'**
  String get coinsEarned;

  /// No description provided for @mistakes.
  ///
  /// In ru, this message translates to:
  /// **'Ошибки'**
  String get mistakes;

  /// No description provided for @personalRecord.
  ///
  /// In ru, this message translates to:
  /// **'Рекорд'**
  String get personalRecord;

  /// No description provided for @playAgain.
  ///
  /// In ru, this message translates to:
  /// **'Сыграть ещё'**
  String get playAgain;

  /// No description provided for @home.
  ///
  /// In ru, this message translates to:
  /// **'Домой'**
  String get home;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тренируем мозг играючи'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Таблицы Шульте для детей 6–14 лет'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingStart.
  ///
  /// In ru, this message translates to:
  /// **'Начать'**
  String get onboardingStart;

  /// No description provided for @onboardingNext.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get onboardingNext;

  /// No description provided for @onboardingAgeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сколько лет ребёнку?'**
  String get onboardingAgeTitle;

  /// No description provided for @onboardingAgeSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Подберём подходящую сложность'**
  String get onboardingAgeSubtitle;

  /// No description provided for @onboardingAge69.
  ///
  /// In ru, this message translates to:
  /// **'6 – 9 лет'**
  String get onboardingAge69;

  /// No description provided for @onboardingAge1012.
  ///
  /// In ru, this message translates to:
  /// **'10 – 12 лет'**
  String get onboardingAge1012;

  /// No description provided for @onboardingAge1314.
  ///
  /// In ru, this message translates to:
  /// **'13 – 14 лет'**
  String get onboardingAge1314;

  /// No description provided for @onboardingGoalsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Какая главная цель?'**
  String get onboardingGoalsTitle;

  /// No description provided for @onboardingGoalsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Выбери одно или несколько'**
  String get onboardingGoalsSubtitle;

  /// No description provided for @onboardingGoalConcentration.
  ///
  /// In ru, this message translates to:
  /// **'Концентрация'**
  String get onboardingGoalConcentration;

  /// No description provided for @onboardingGoalReading.
  ///
  /// In ru, this message translates to:
  /// **'Скорость чтения'**
  String get onboardingGoalReading;

  /// No description provided for @onboardingGoalExams.
  ///
  /// In ru, this message translates to:
  /// **'Подготовка к экзаменам'**
  String get onboardingGoalExams;

  /// No description provided for @onboardingGoalFun.
  ///
  /// In ru, this message translates to:
  /// **'Просто тренировка'**
  String get onboardingGoalFun;

  /// No description provided for @onboardingFrequencyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сколько времени в день?'**
  String get onboardingFrequencyTitle;

  /// No description provided for @onboardingFrequencySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Даже 5 минут в день дают результат'**
  String get onboardingFrequencySubtitle;

  /// No description provided for @onboardingFreq5min.
  ///
  /// In ru, this message translates to:
  /// **'5 минут'**
  String get onboardingFreq5min;

  /// No description provided for @onboardingFreq5minDesc.
  ///
  /// In ru, this message translates to:
  /// **'Лёгкий старт'**
  String get onboardingFreq5minDesc;

  /// No description provided for @onboardingFreq10min.
  ///
  /// In ru, this message translates to:
  /// **'10 минут'**
  String get onboardingFreq10min;

  /// No description provided for @onboardingFreq10minDesc.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендуем'**
  String get onboardingFreq10minDesc;

  /// No description provided for @onboardingFreq15min.
  ///
  /// In ru, this message translates to:
  /// **'15+ минут'**
  String get onboardingFreq15min;

  /// No description provided for @onboardingFreq15minDesc.
  ///
  /// In ru, this message translates to:
  /// **'Интенсив'**
  String get onboardingFreq15minDesc;

  /// No description provided for @onboardingRecommended.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендуем'**
  String get onboardingRecommended;

  /// No description provided for @onboardingPaywallTitle.
  ///
  /// In ru, this message translates to:
  /// **'Попробуй Premium бесплатно'**
  String get onboardingPaywallTitle;

  /// No description provided for @onboardingPaywallBenefit1.
  ///
  /// In ru, this message translates to:
  /// **'Все размеры таблиц (6×6, 7×7, 9×9)'**
  String get onboardingPaywallBenefit1;

  /// No description provided for @onboardingPaywallBenefit2.
  ///
  /// In ru, this message translates to:
  /// **'Все 5 персонажей'**
  String get onboardingPaywallBenefit2;

  /// No description provided for @onboardingPaywallBenefit3.
  ///
  /// In ru, this message translates to:
  /// **'Полная статистика прогресса'**
  String get onboardingPaywallBenefit3;

  /// No description provided for @onboardingPaywallBenefit4.
  ///
  /// In ru, this message translates to:
  /// **'Без рекламы'**
  String get onboardingPaywallBenefit4;

  /// No description provided for @onboardingTryFree.
  ///
  /// In ru, this message translates to:
  /// **'Начать 7 дней бесплатно'**
  String get onboardingTryFree;

  /// No description provided for @onboardingSkipPaywall.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить без подписки'**
  String get onboardingSkipPaywall;

  /// No description provided for @onboardingSchulteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Таблицы Шульте — тренажёр для мозга'**
  String get onboardingSchulteTitle;

  /// No description provided for @onboardingSchulteSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Находи числа по порядку как можно быстрее. Чем больше таблица — тем сложнее!'**
  String get onboardingSchulteSubtitle;

  /// No description provided for @onboardingSchulteHint.
  ///
  /// In ru, this message translates to:
  /// **'Найди числа по порядку: 1, 2, 3...'**
  String get onboardingSchulteHint;

  /// No description provided for @onboardingSchulteBenefit1.
  ///
  /// In ru, this message translates to:
  /// **'Развивает внимание и концентрацию'**
  String get onboardingSchulteBenefit1;

  /// No description provided for @onboardingSchulteBenefit2.
  ///
  /// In ru, this message translates to:
  /// **'Расширяет периферическое зрение'**
  String get onboardingSchulteBenefit2;

  /// No description provided for @onboardingSchulteBenefit3.
  ///
  /// In ru, this message translates to:
  /// **'Ускоряет чтение в 1.5–2 раза'**
  String get onboardingSchulteBenefit3;

  /// No description provided for @onboardingScienceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверено наукой'**
  String get onboardingScienceTitle;

  /// No description provided for @onboardingScienceSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Методика создана немецким психиатром Вальтером Шульте в 1960-х для тренировки внимания'**
  String get onboardingScienceSubtitle;

  /// No description provided for @onboardingScienceFact1Value.
  ///
  /// In ru, this message translates to:
  /// **'60+ лет'**
  String get onboardingScienceFact1Value;

  /// No description provided for @onboardingScienceFact1Label.
  ///
  /// In ru, this message translates to:
  /// **'используется в нейропсихологии и педагогике'**
  String get onboardingScienceFact1Label;

  /// No description provided for @onboardingScienceFact2Value.
  ///
  /// In ru, this message translates to:
  /// **'2 недели'**
  String get onboardingScienceFact2Value;

  /// No description provided for @onboardingScienceFact2Label.
  ///
  /// In ru, this message translates to:
  /// **'для заметного улучшения скорости чтения при ежедневных занятиях'**
  String get onboardingScienceFact2Label;

  /// No description provided for @onboardingScienceFact3Value.
  ///
  /// In ru, this message translates to:
  /// **'5 мин/день'**
  String get onboardingScienceFact3Value;

  /// No description provided for @onboardingScienceFact3Label.
  ///
  /// In ru, this message translates to:
  /// **'достаточно для результата — не перегружает ребёнка'**
  String get onboardingScienceFact3Label;

  /// No description provided for @onboardingAlreadySubscribed.
  ///
  /// In ru, this message translates to:
  /// **'Вы уже подписаны!'**
  String get onboardingAlreadySubscribed;

  /// No description provided for @onboardingLetsGo.
  ///
  /// In ru, this message translates to:
  /// **'Поехали!'**
  String get onboardingLetsGo;

  /// No description provided for @playNow.
  ///
  /// In ru, this message translates to:
  /// **'Играть'**
  String get playNow;

  /// No description provided for @selectGridSize.
  ///
  /// In ru, this message translates to:
  /// **'Размер таблицы'**
  String get selectGridSize;

  /// No description provided for @premiumGridLocked.
  ///
  /// In ru, this message translates to:
  /// **'Доступно в Premium'**
  String get premiumGridLocked;

  /// No description provided for @lastResult.
  ///
  /// In ru, this message translates to:
  /// **'Последний: {gridSize}×{gridSize} за {seconds}с'**
  String lastResult(int gridSize, int seconds);

  /// No description provided for @noSessionsYet.
  ///
  /// In ru, this message translates to:
  /// **'Нет игр — начнём!'**
  String get noSessionsYet;

  /// No description provided for @streakDays.
  ///
  /// In ru, this message translates to:
  /// **'Серия {count} дней'**
  String streakDays(int count);

  /// No description provided for @levelLabel.
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level}'**
  String levelLabel(int level);

  /// No description provided for @characterScreenTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мои персонажи'**
  String get characterScreenTitle;

  /// No description provided for @characterSelect.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать'**
  String get characterSelect;

  /// No description provided for @characterSelected.
  ///
  /// In ru, this message translates to:
  /// **'Выбран'**
  String get characterSelected;

  /// No description provided for @characterUnlockPremium.
  ///
  /// In ru, this message translates to:
  /// **'Открыть Premium'**
  String get characterUnlockPremium;

  /// No description provided for @accessoriesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Кастомизация'**
  String get accessoriesTitle;

  /// No description provided for @accessoriesTabHats.
  ///
  /// In ru, this message translates to:
  /// **'Шляпы'**
  String get accessoriesTabHats;

  /// No description provided for @accessoriesTabGlasses.
  ///
  /// In ru, this message translates to:
  /// **'Очки'**
  String get accessoriesTabGlasses;

  /// No description provided for @accessoriesTabEffects.
  ///
  /// In ru, this message translates to:
  /// **'Эффекты'**
  String get accessoriesTabEffects;

  /// No description provided for @accessoriesTabCapes.
  ///
  /// In ru, this message translates to:
  /// **'Плащи'**
  String get accessoriesTabCapes;

  /// No description provided for @accessoriesBuy.
  ///
  /// In ru, this message translates to:
  /// **'Купить'**
  String get accessoriesBuy;

  /// No description provided for @accessoriesEquip.
  ///
  /// In ru, this message translates to:
  /// **'Надеть'**
  String get accessoriesEquip;

  /// No description provided for @accessoriesEquipped.
  ///
  /// In ru, this message translates to:
  /// **'Надето'**
  String get accessoriesEquipped;

  /// No description provided for @accessoriesRemove.
  ///
  /// In ru, this message translates to:
  /// **'Снять'**
  String get accessoriesRemove;

  /// No description provided for @accessoriesPremiumOnly.
  ///
  /// In ru, this message translates to:
  /// **'Premium'**
  String get accessoriesPremiumOnly;

  /// No description provided for @accessoriesNotEnoughCoins.
  ///
  /// In ru, this message translates to:
  /// **'Не хватает монет'**
  String get accessoriesNotEnoughCoins;

  /// No description provided for @accessoriesNotEnoughCoinsMessage.
  ///
  /// In ru, this message translates to:
  /// **'Нужно {price} монет, а у тебя {balance}'**
  String accessoriesNotEnoughCoinsMessage(int price, int balance);

  /// No description provided for @accessoriesCustomize.
  ///
  /// In ru, this message translates to:
  /// **'Кастомизация'**
  String get accessoriesCustomize;

  /// No description provided for @accessoriesPurchased.
  ///
  /// In ru, this message translates to:
  /// **'Куплено!'**
  String get accessoriesPurchased;

  /// No description provided for @parentTitle.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс ребёнка'**
  String get parentTitle;

  /// No description provided for @parentSetPin.
  ///
  /// In ru, this message translates to:
  /// **'Установить PIN'**
  String get parentSetPin;

  /// No description provided for @parentEnterPin.
  ///
  /// In ru, this message translates to:
  /// **'Введите PIN'**
  String get parentEnterPin;

  /// No description provided for @parentSetPinSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Придумайте 4-значный PIN для защиты настроек'**
  String get parentSetPinSubtitle;

  /// No description provided for @parentEnterPinSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите 4-значный PIN'**
  String get parentEnterPinSubtitle;

  /// No description provided for @parentWrongPin.
  ///
  /// In ru, this message translates to:
  /// **'Неверный PIN'**
  String get parentWrongPin;

  /// No description provided for @parentLockedOut.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много попыток. Подождите {seconds}с'**
  String parentLockedOut(int seconds);

  /// No description provided for @parentThisWeek.
  ///
  /// In ru, this message translates to:
  /// **'Эта неделя'**
  String get parentThisWeek;

  /// No description provided for @parentStreak.
  ///
  /// In ru, this message translates to:
  /// **'Стрик'**
  String get parentStreak;

  /// No description provided for @parentAvgTime.
  ///
  /// In ru, this message translates to:
  /// **'Среднее время'**
  String get parentAvgTime;

  /// No description provided for @parentSessions.
  ///
  /// In ru, this message translates to:
  /// **'Сессий'**
  String get parentSessions;

  /// No description provided for @parentDays.
  ///
  /// In ru, this message translates to:
  /// **'дней'**
  String get parentDays;

  /// No description provided for @parentSec.
  ///
  /// In ru, this message translates to:
  /// **'сек'**
  String get parentSec;

  /// No description provided for @parentProgressChart.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс (14 дней)'**
  String get parentProgressChart;

  /// No description provided for @parentNoChartData.
  ///
  /// In ru, this message translates to:
  /// **'Пока недостаточно данных'**
  String get parentNoChartData;

  /// No description provided for @parentBestResults.
  ///
  /// In ru, this message translates to:
  /// **'Лучшие результаты'**
  String get parentBestResults;

  /// No description provided for @parentBestTime.
  ///
  /// In ru, this message translates to:
  /// **'Лучший: {seconds}с'**
  String parentBestTime(int seconds);

  /// No description provided for @parentNoRecord.
  ///
  /// In ru, this message translates to:
  /// **'—'**
  String get parentNoRecord;

  /// No description provided for @parentPremiumOnly.
  ///
  /// In ru, this message translates to:
  /// **'Premium'**
  String get parentPremiumOnly;

  /// No description provided for @parentRecentSessions.
  ///
  /// In ru, this message translates to:
  /// **'Последние сессии'**
  String get parentRecentSessions;

  /// No description provided for @parentNoSessions.
  ///
  /// In ru, this message translates to:
  /// **'Нет сессий'**
  String get parentNoSessions;

  /// No description provided for @parentShare.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get parentShare;

  /// No description provided for @parentSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get parentSettings;

  /// No description provided for @parentSettingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки родителя'**
  String get parentSettingsTitle;

  /// No description provided for @parentGridSizeMode.
  ///
  /// In ru, this message translates to:
  /// **'Размер таблицы'**
  String get parentGridSizeMode;

  /// No description provided for @parentGridSizeAuto.
  ///
  /// In ru, this message translates to:
  /// **'Авто'**
  String get parentGridSizeAuto;

  /// No description provided for @parentGridSizeFixed.
  ///
  /// In ru, this message translates to:
  /// **'Фиксированный'**
  String get parentGridSizeFixed;

  /// No description provided for @parentMaxSessionTime.
  ///
  /// In ru, this message translates to:
  /// **'Макс. время сессии'**
  String get parentMaxSessionTime;

  /// No description provided for @parentNoLimit.
  ///
  /// In ru, this message translates to:
  /// **'Без ограничений'**
  String get parentNoLimit;

  /// No description provided for @parentMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{min} мин'**
  String parentMinutes(int min);

  /// No description provided for @parentNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get parentNotifications;

  /// No description provided for @parentChangePin.
  ///
  /// In ru, this message translates to:
  /// **'Сменить PIN'**
  String get parentChangePin;

  /// No description provided for @parentManageSubscription.
  ///
  /// In ru, this message translates to:
  /// **'Управление подпиской'**
  String get parentManageSubscription;

  /// No description provided for @parentShareCardTitle.
  ///
  /// In ru, this message translates to:
  /// **'тренируется уже {days} дней!'**
  String parentShareCardTitle(int days);

  /// No description provided for @parentShareBest5x5.
  ///
  /// In ru, this message translates to:
  /// **'Лучший результат 5×5'**
  String get parentShareBest5x5;

  /// No description provided for @parentShareDownload.
  ///
  /// In ru, this message translates to:
  /// **'Скачай Brainy: brainyapp.io'**
  String get parentShareDownload;

  /// No description provided for @parentStars.
  ///
  /// In ru, this message translates to:
  /// **'Звёзды'**
  String get parentStars;

  /// No description provided for @paywallTitle.
  ///
  /// In ru, this message translates to:
  /// **'Brainy Premium'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Открой всё и тренируйся без ограничений'**
  String get paywallSubtitle;

  /// No description provided for @paywallBenefit1.
  ///
  /// In ru, this message translates to:
  /// **'Все размеры таблиц — до 9×9'**
  String get paywallBenefit1;

  /// No description provided for @paywallBenefit2.
  ///
  /// In ru, this message translates to:
  /// **'5 уникальных персонажей'**
  String get paywallBenefit2;

  /// No description provided for @paywallBenefit3.
  ///
  /// In ru, this message translates to:
  /// **'Панель прогресса для родителей'**
  String get paywallBenefit3;

  /// No description provided for @paywallBenefit4.
  ///
  /// In ru, this message translates to:
  /// **'Без рекламы'**
  String get paywallBenefit4;

  /// No description provided for @paywallBenefit5.
  ///
  /// In ru, this message translates to:
  /// **'Режим Горбова-Шульте'**
  String get paywallBenefit5;

  /// No description provided for @paywallPlanYear.
  ///
  /// In ru, this message translates to:
  /// **'Год'**
  String get paywallPlanYear;

  /// No description provided for @paywallPlanMonth.
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get paywallPlanMonth;

  /// No description provided for @paywallPlanFamily.
  ///
  /// In ru, this message translates to:
  /// **'Семейная'**
  String get paywallPlanFamily;

  /// No description provided for @paywallBestPrice.
  ///
  /// In ru, this message translates to:
  /// **'Лучшая цена'**
  String get paywallBestPrice;

  /// No description provided for @paywallPerMonth.
  ///
  /// In ru, this message translates to:
  /// **'~{price}/мес'**
  String paywallPerMonth(String price);

  /// No description provided for @paywallTryFree.
  ///
  /// In ru, this message translates to:
  /// **'Начать 7 дней бесплатно'**
  String get paywallTryFree;

  /// No description provided for @paywallSubscribe.
  ///
  /// In ru, this message translates to:
  /// **'Подписаться'**
  String get paywallSubscribe;

  /// No description provided for @paywallDisclaimer.
  ///
  /// In ru, this message translates to:
  /// **'Отмена в любое время. Управление подпиской в App Store.'**
  String get paywallDisclaimer;

  /// No description provided for @paywallRestore.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить покупки'**
  String get paywallRestore;

  /// No description provided for @paywallTerms.
  ///
  /// In ru, this message translates to:
  /// **'Условия'**
  String get paywallTerms;

  /// No description provided for @paywallPrivacy.
  ///
  /// In ru, this message translates to:
  /// **'Конфиденциальность'**
  String get paywallPrivacy;

  /// No description provided for @paywallWelcome.
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать в Premium!'**
  String get paywallWelcome;

  /// No description provided for @paywallErrorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка покупки'**
  String get paywallErrorTitle;

  /// No description provided for @paywallErrorMessage.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так. Попробуйте ещё раз.'**
  String get paywallErrorMessage;

  /// No description provided for @paywallLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка планов...'**
  String get paywallLoading;

  /// No description provided for @premiumFeatureLocked.
  ///
  /// In ru, this message translates to:
  /// **'Это Premium фича'**
  String get premiumFeatureLocked;

  /// No description provided for @premiumUnlock.
  ///
  /// In ru, this message translates to:
  /// **'Открыть Premium'**
  String get premiumUnlock;

  /// No description provided for @premiumTryFree.
  ///
  /// In ru, this message translates to:
  /// **'Попробовать бесплатно 7 дней'**
  String get premiumTryFree;

  /// No description provided for @settingsSounds.
  ///
  /// In ru, this message translates to:
  /// **'Звуки'**
  String get settingsSounds;

  /// No description provided for @settingsHaptic.
  ///
  /// In ru, this message translates to:
  /// **'Вибрация'**
  String get settingsHaptic;

  /// No description provided for @settingsReminderTime.
  ///
  /// In ru, this message translates to:
  /// **'Время напоминания'**
  String get settingsReminderTime;

  /// No description provided for @settingsDefaultTime.
  ///
  /// In ru, this message translates to:
  /// **'по умолчанию'**
  String get settingsDefaultTime;

  /// No description provided for @settingsResetTime.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить на 20:00'**
  String get settingsResetTime;

  /// No description provided for @progressTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мой прогресс'**
  String get progressTitle;

  /// No description provided for @progressTotalGames.
  ///
  /// In ru, this message translates to:
  /// **'Игры'**
  String get progressTotalGames;

  /// No description provided for @progressTotalXp.
  ///
  /// In ru, this message translates to:
  /// **'Опыт'**
  String get progressTotalXp;

  /// No description provided for @progressBestStreak.
  ///
  /// In ru, this message translates to:
  /// **'Лучший стрик'**
  String get progressBestStreak;

  /// No description provided for @progressXpToNextLevel.
  ///
  /// In ru, this message translates to:
  /// **'{xp} XP до уровня {level}'**
  String progressXpToNextLevel(int xp, int level);

  /// No description provided for @progressMaxLevel.
  ///
  /// In ru, this message translates to:
  /// **'Максимальный уровень!'**
  String get progressMaxLevel;

  /// No description provided for @progressNextGoals.
  ///
  /// In ru, this message translates to:
  /// **'Следующие цели'**
  String get progressNextGoals;

  /// No description provided for @progressGoalReachLevel.
  ///
  /// In ru, this message translates to:
  /// **'Достигни уровня {level}'**
  String progressGoalReachLevel(int level);

  /// No description provided for @progressGoalStreak.
  ///
  /// In ru, this message translates to:
  /// **'Стрик {days} дней'**
  String progressGoalStreak(int days);

  /// No description provided for @progressGoalUnlock.
  ///
  /// In ru, this message translates to:
  /// **'Открой {name}'**
  String progressGoalUnlock(String name);

  /// No description provided for @progressRecords.
  ///
  /// In ru, this message translates to:
  /// **'Лучшее время'**
  String get progressRecords;

  /// No description provided for @progressNoRecords.
  ///
  /// In ru, this message translates to:
  /// **'Играй, чтобы установить рекорды!'**
  String get progressNoRecords;

  /// No description provided for @progressStartPlaying.
  ///
  /// In ru, this message translates to:
  /// **'Начни играть, чтобы видеть прогресс!'**
  String get progressStartPlaying;

  /// No description provided for @starHintNext.
  ///
  /// In ru, this message translates to:
  /// **'Пройди за {seconds} сек для {stars}★'**
  String starHintNext(int seconds, int stars);

  /// No description provided for @gridDetailTitle.
  ///
  /// In ru, this message translates to:
  /// **'Таблица {size}×{size}'**
  String gridDetailTitle(int size);

  /// No description provided for @periodWeek.
  ///
  /// In ru, this message translates to:
  /// **'Нед'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In ru, this message translates to:
  /// **'Мес'**
  String get periodMonth;

  /// No description provided for @periodThreeMonths.
  ///
  /// In ru, this message translates to:
  /// **'3М'**
  String get periodThreeMonths;

  /// No description provided for @periodYear.
  ///
  /// In ru, this message translates to:
  /// **'Год'**
  String get periodYear;

  /// No description provided for @periodAll.
  ///
  /// In ru, this message translates to:
  /// **'Всё'**
  String get periodAll;

  /// No description provided for @chartTimeLabel.
  ///
  /// In ru, this message translates to:
  /// **'ВРЕМЯ ПРОХОЖДЕНИЯ'**
  String get chartTimeLabel;

  /// No description provided for @statBestTime.
  ///
  /// In ru, this message translates to:
  /// **'Лучшее'**
  String get statBestTime;

  /// No description provided for @statAverageTime.
  ///
  /// In ru, this message translates to:
  /// **'Среднее'**
  String get statAverageTime;

  /// No description provided for @statTotalGames.
  ///
  /// In ru, this message translates to:
  /// **'Всего игр'**
  String get statTotalGames;

  /// No description provided for @gridDetailNoData.
  ///
  /// In ru, this message translates to:
  /// **'Ещё нет данных для {size}×{size}'**
  String gridDetailNoData(int size);

  /// No description provided for @gridDetailPlayMore.
  ///
  /// In ru, this message translates to:
  /// **'Сыграйте несколько раз, чтобы увидеть прогресс'**
  String get gridDetailPlayMore;

  /// No description provided for @legendDailyBest.
  ///
  /// In ru, this message translates to:
  /// **'Daily best'**
  String get legendDailyBest;

  /// No description provided for @legendAllAttempts.
  ///
  /// In ru, this message translates to:
  /// **'Все попытки'**
  String get legendAllAttempts;

  /// No description provided for @legendRecord.
  ///
  /// In ru, this message translates to:
  /// **'Рекорд'**
  String get legendRecord;

  /// No description provided for @achievementsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Достижения'**
  String get achievementsTitle;

  /// No description provided for @achievementsCount.
  ///
  /// In ru, this message translates to:
  /// **'{unlocked} / {total}'**
  String achievementsCount(int unlocked, int total);

  /// No description provided for @achievementUnlocked.
  ///
  /// In ru, this message translates to:
  /// **'Новое достижение!'**
  String get achievementUnlocked;

  /// No description provided for @achievementFirstGame.
  ///
  /// In ru, this message translates to:
  /// **'Первая игра'**
  String get achievementFirstGame;

  /// No description provided for @achievementFirstGameDesc.
  ///
  /// In ru, this message translates to:
  /// **'Заверши первую сессию'**
  String get achievementFirstGameDesc;

  /// No description provided for @achievementPersonalRecord.
  ///
  /// In ru, this message translates to:
  /// **'Рекордсмен'**
  String get achievementPersonalRecord;

  /// No description provided for @achievementPersonalRecordDesc.
  ///
  /// In ru, this message translates to:
  /// **'Установи личный рекорд'**
  String get achievementPersonalRecordDesc;

  /// No description provided for @achievementSpeedDemon.
  ///
  /// In ru, this message translates to:
  /// **'Молния'**
  String get achievementSpeedDemon;

  /// No description provided for @achievementSpeedDemonDesc.
  ///
  /// In ru, this message translates to:
  /// **'Пройди 3×3 за 5 секунд или быстрее'**
  String get achievementSpeedDemonDesc;

  /// No description provided for @achievementMaster5x5.
  ///
  /// In ru, this message translates to:
  /// **'Мастер 5×5'**
  String get achievementMaster5x5;

  /// No description provided for @achievementMaster5x5Desc.
  ///
  /// In ru, this message translates to:
  /// **'Пройди 5×5 за 20 секунд или быстрее'**
  String get achievementMaster5x5Desc;

  /// No description provided for @achievementFocusMode.
  ///
  /// In ru, this message translates to:
  /// **'Фокус'**
  String get achievementFocusMode;

  /// No description provided for @achievementFocusModeDesc.
  ///
  /// In ru, this message translates to:
  /// **'Пройди таблицу без ошибок'**
  String get achievementFocusModeDesc;

  /// No description provided for @achievementStreak3.
  ///
  /// In ru, this message translates to:
  /// **'Стрик 3 дня'**
  String get achievementStreak3;

  /// No description provided for @achievementStreak3Desc.
  ///
  /// In ru, this message translates to:
  /// **'Играй 3 дня подряд'**
  String get achievementStreak3Desc;

  /// No description provided for @achievementStreak7.
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get achievementStreak7;

  /// No description provided for @achievementStreak7Desc.
  ///
  /// In ru, this message translates to:
  /// **'Играй 7 дней подряд'**
  String get achievementStreak7Desc;

  /// No description provided for @achievementStreak30.
  ///
  /// In ru, this message translates to:
  /// **'Легенда месяца'**
  String get achievementStreak30;

  /// No description provided for @achievementStreak30Desc.
  ///
  /// In ru, this message translates to:
  /// **'Играй 30 дней подряд'**
  String get achievementStreak30Desc;

  /// No description provided for @achievementNightOwl.
  ///
  /// In ru, this message translates to:
  /// **'Ночная сова'**
  String get achievementNightOwl;

  /// No description provided for @achievementNightOwlDesc.
  ///
  /// In ru, this message translates to:
  /// **'Сыграй сессию после 22:00'**
  String get achievementNightOwlDesc;

  /// No description provided for @achievementCoinHoarder.
  ///
  /// In ru, this message translates to:
  /// **'Копилка'**
  String get achievementCoinHoarder;

  /// No description provided for @achievementCoinHoarderDesc.
  ///
  /// In ru, this message translates to:
  /// **'Накопи 500 монет'**
  String get achievementCoinHoarderDesc;

  /// No description provided for @league.
  ///
  /// In ru, this message translates to:
  /// **'Лига'**
  String get league;

  /// No description provided for @leagueTitle.
  ///
  /// In ru, this message translates to:
  /// **'Недельная лига'**
  String get leagueTitle;

  /// No description provided for @leagueBronze.
  ///
  /// In ru, this message translates to:
  /// **'Бронза'**
  String get leagueBronze;

  /// No description provided for @leagueSilver.
  ///
  /// In ru, this message translates to:
  /// **'Серебро'**
  String get leagueSilver;

  /// No description provided for @leagueGold.
  ///
  /// In ru, this message translates to:
  /// **'Золото'**
  String get leagueGold;

  /// No description provided for @leaguePlatinum.
  ///
  /// In ru, this message translates to:
  /// **'Платина'**
  String get leaguePlatinum;

  /// No description provided for @leagueWeeklyXp.
  ///
  /// In ru, this message translates to:
  /// **'{xp} XP за неделю'**
  String leagueWeeklyXp(int xp);

  /// No description provided for @leagueNextTier.
  ///
  /// In ru, this message translates to:
  /// **'{xp} XP до {tier}'**
  String leagueNextTier(int xp, String tier);

  /// No description provided for @leagueMaxTier.
  ///
  /// In ru, this message translates to:
  /// **'Высшая лига достигнута!'**
  String get leagueMaxTier;

  /// No description provided for @leagueResetsMonday.
  ///
  /// In ru, this message translates to:
  /// **'Обновляется каждый понедельник'**
  String get leagueResetsMonday;

  /// No description provided for @leagueYou.
  ///
  /// In ru, this message translates to:
  /// **'Ты'**
  String get leagueYou;

  /// No description provided for @leagueConnectTitle.
  ///
  /// In ru, this message translates to:
  /// **'Соревнуйся с реальными игроками!'**
  String get leagueConnectTitle;

  /// No description provided for @leagueConnectSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Подключи Game Center для настоящих лидербордов'**
  String get leagueConnectSubtitle;

  /// No description provided for @leagueConnect.
  ///
  /// In ru, this message translates to:
  /// **'Подключить'**
  String get leagueConnect;

  /// No description provided for @leagueFullRanking.
  ///
  /// In ru, this message translates to:
  /// **'Полный рейтинг'**
  String get leagueFullRanking;

  /// No description provided for @leagueLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка рейтинга...'**
  String get leagueLoading;

  /// No description provided for @leagueError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить рейтинг'**
  String get leagueError;

  /// No description provided for @leagueNotConnected.
  ///
  /// In ru, this message translates to:
  /// **'Game Center не подключён'**
  String get leagueNotConnected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
