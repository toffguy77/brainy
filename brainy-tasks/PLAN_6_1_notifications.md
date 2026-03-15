# Notifications Rework Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the two-notification system (daily reminder + streak warning) with a single contextual daily notification, configurable in parent settings.

**Architecture:** Single `reschedule()` entry point called on app start, after game completion, and on settings changes. Message content chosen based on streak state. Time defaults to 20:00, optionally set by parent.

**Tech Stack:** Flutter, Riverpod, Hive, flutter_local_notifications, timezone

**Spec:** `brainy-tasks/TASK_6_1_notifications.md`

---

## Chunk 1: Constants and NotificationService

### Task 1: Update AppConstants with new Hive keys

**Files:**
- Modify: `brainy-app/lib/constants/app_constants.dart:104-108`

- [ ] **Step 1: Replace notification constants**

Replace lines 104-108 in `app_constants.dart`:

```dart
  // Notification settings
  static const String notificationsEnabledKey = 'notificationsEnabled';
  static const String hasCustomReminderTimeKey = 'hasCustomReminderTime';
  static const String customReminderHourKey = 'customReminderHour';
  static const String customReminderMinuteKey = 'customReminderMinute';
  static const int defaultReminderHour = 20;
  static const int defaultReminderMinute = 0;
```

Old keys being replaced: `reminderHourKey`, `reminderMinuteKey`, `defaultReminderHour` (was 17), `defaultReminderMinute`. Also `parentRemindersEnabledKey` (line 65) is no longer needed — remove it.

- [ ] **Step 2: Verify no other references to removed keys**

Search for `parentRemindersEnabledKey`, `reminderHourKey`, `reminderMinuteKey` — they are used in `parent_provider.dart` (will be updated in Task 3).

- [ ] **Step 3: Commit**

```bash
git add brainy-app/lib/constants/app_constants.dart
git commit -m "refactor: update notification Hive keys and default time to 20:00"
```

---

### Task 2: Rewrite NotificationService

**Files:**
- Modify: `brainy-app/lib/shared/services/notification_service.dart` (full rewrite)

- [ ] **Step 1: Rewrite notification_service.dart**

Replace the entire file with:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'brainy_reminders';
  static const _channelName = 'Training Reminders';
  static const _notificationId = 100;

  // Motivational messages (streak <= 2 or no streak)
  static const _motivationMessagesRu = [
    'Время потренировать мозг!',
    'Брейни ждёт тебя! Зайди на тренировку',
    'Несколько минут — и мозг станет быстрее!',
    'Зэп зовёт на тренировку!',
    'Сегодня ещё не тренировались. Начнём?',
    'Мозг любит тренировки. Не пропусти!',
    'Пора размять мозг! Таблица Шульте ждёт',
  ];

  static const _motivationMessagesEn = [
    'Time to train your brain!',
    'Brainy is waiting for you! Start training',
    'A few minutes and your brain gets faster!',
    'Zap is calling you to practice!',
    "Haven't trained today yet. Shall we start?",
    "Your brain loves training. Don't skip it!",
    'Time to exercise your brain! Schulte table awaits',
  ];

  // Streak warning messages (streak > 2, hasn't played today)
  // {N} is replaced with streak count at schedule time
  static const _streakMessagesRu = [
    'Стрик {N} дней сгорит сегодня!',
    'Не потеряй свой стрик {N} дней!',
    '{N} дней подряд — не останавливайся!',
    'Стрик в опасности! Сыграй сегодня',
    'Осталось немного до конца дня. Сохрани стрик!',
    'Твой стрик {N} дней на волоске!',
    'Брейни переживает за стрик {N} дней!',
  ];

  static const _streakMessagesEn = [
    'Your {N}-day streak expires today!',
    "Don't lose your {N}-day streak!",
    "{N} days in a row — don't stop now!",
    'Streak in danger! Play today',
    'Day is almost over. Save your streak!',
    'Your {N}-day streak is hanging by a thread!',
    'Brainy is worried about your {N}-day streak!',
  ];

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  static Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Single entry point for all notification scheduling.
  /// Called on app start, after game completion, and on settings change.
  static Future<void> reschedule({
    required bool enabled,
    required bool hasCustomTime,
    required int hour,
    required int minute,
    required int currentStreak,
    required bool hasPlayedToday,
    String locale = 'en',
  }) async {
    await _plugin.cancel(_notificationId);

    if (!enabled || hasPlayedToday) return;

    final effectiveHour = hasCustomTime ? hour : 20;
    final effectiveMinute = hasCustomTime ? minute : 0;

    final isStreakWarning = currentStreak > 2;
    final message = isStreakWarning
        ? _pickStreakMessage(currentStreak, locale)
        : _pickMotivationMessage(locale);

    await _plugin.zonedSchedule(
      _notificationId,
      'Brainy',
      message,
      _nextInstanceOfTime(effectiveHour, effectiveMinute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance:
              isStreakWarning ? Importance.high : Importance.defaultImportance,
          priority:
              isStreakWarning ? Priority.high : Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static String _pickMotivationMessage(String locale) {
    final messages =
        locale == 'ru' ? _motivationMessagesRu : _motivationMessagesEn;
    final index = DateTime.now().difference(DateTime(2024)).inDays %
        messages.length;
    return messages[index];
  }

  static String _pickStreakMessage(int streakDays, String locale) {
    final messages =
        locale == 'ru' ? _streakMessagesRu : _streakMessagesEn;
    final index = DateTime.now().difference(DateTime(2024)).inDays %
        messages.length;
    return messages[index].replaceAll('{N}', '$streakDays');
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add brainy-app/lib/shared/services/notification_service.dart
git commit -m "refactor: rewrite NotificationService with single reschedule() entry point"
```

---

## Chunk 2: Provider, UI, and Integration Points

### Task 3: Update ParentSettings state and provider

**Files:**
- Modify: `brainy-app/lib/features/parent/providers/parent_provider.dart`

- [ ] **Step 1: Update ParentSettings class**

Replace `remindersEnabled`, `reminderHour`, `reminderMinute` fields with:

```dart
class ParentSettings {
  final bool hasPin;
  final String gridSizeMode;
  final int fixedGridSize;
  final int maxSessionTimeMinutes;
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
    this.maxSessionTimeMinutes = 0,
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
    int? maxSessionTimeMinutes,
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
      maxSessionTimeMinutes: maxSessionTimeMinutes ?? this.maxSessionTimeMinutes,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hasCustomReminderTime: hasCustomReminderTime ?? this.hasCustomReminderTime,
      customReminderHour: customReminderHour ?? this.customReminderHour,
      customReminderMinute: customReminderMinute ?? this.customReminderMinute,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }
}
```

- [ ] **Step 2: Update ParentNotifier.build() to read new keys**

```dart
  @override
  ParentSettings build() {
    final pinHash = _box.get(AppConstants.parentPinHashKey) as String?;
    return ParentSettings(
      hasPin: pinHash != null && pinHash.isNotEmpty,
      gridSizeMode:
          _box.get(AppConstants.parentGridSizeModeKey) as String? ?? 'auto',
      fixedGridSize:
          _box.get(AppConstants.parentFixedGridSizeKey) as int? ?? 5,
      maxSessionTimeMinutes:
          _box.get(AppConstants.parentMaxSessionTimeKey) as int? ?? 0,
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
```

- [ ] **Step 3: Replace setRemindersEnabled/setReminderTime with new methods**

Remove `setRemindersEnabled` and `setReminderTime`. Add:

```dart
  Future<void> _rescheduleNotification() async {
    final sessions = Hive.box<GameSession>(AppConstants.sessionsBox);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final hasPlayedToday = sessions.values.any((s) {
      final d = s.playedAt;
      return d.year == today.year && d.month == today.month && d.day == today.day;
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
```

Add required imports at top of file:

```dart
import '../../../models/session.dart';
import '../../../models/user_progress.dart';
```

- [ ] **Step 4: Commit**

```bash
git add brainy-app/lib/features/parent/providers/parent_provider.dart
git commit -m "refactor: update ParentSettings for unified notification model"
```

---

### Task 4: Update Parent Settings UI

**Files:**
- Modify: `brainy-app/lib/features/parent/screens/parent_settings_screen.dart:158-228`

- [ ] **Step 1: Replace the reminders _SettingsCard (lines 158-228)**

Replace the entire reminders `_SettingsCard` block with:

```dart
          _SettingsCard(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SettingsLabel(l10n.parentNotifications),
                  Switch(
                    value: settings.notificationsEnabled,
                    onChanged: (value) {
                      ref
                          .read(parentProvider.notifier)
                          .setNotificationsEnabled(value);
                    },
                    activeTrackColor: AppColors.primary,
                    activeThumbColor: AppColors.textPrimary,
                  ),
                ],
              ),
              if (settings.notificationsEnabled) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: settings.customReminderHour,
                        minute: settings.customReminderMinute,
                      ),
                    );
                    if (picked != null) {
                      ref
                          .read(parentProvider.notifier)
                          .setCustomReminderTime(picked.hour, picked.minute);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.settingsReminderTime,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${settings.customReminderHour.toString().padLeft(2, '0')}:${settings.customReminderMinute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (!settings.hasCustomReminderTime) ...[
                              const SizedBox(width: 6),
                              Text(
                                '(${l10n.settingsDefaultTime})',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (settings.hasCustomReminderTime) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ref
                            .read(parentProvider.notifier)
                            .clearCustomReminderTime();
                      },
                      child: Text(
                        l10n.settingsResetTime,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
```

- [ ] **Step 2: Commit**

```bash
git add brainy-app/lib/features/parent/screens/parent_settings_screen.dart
git commit -m "feat: update notification settings UI with default/custom time toggle"
```

---

### Task 5: Update localization files

**Files:**
- Modify: `brainy-app/l10n/app_en.arb`
- Modify: `brainy-app/l10n/app_ru.arb`
- Modify: `brainy-app/lib/l10n/app_localizations.dart`
- Modify: `brainy-app/lib/l10n/app_localizations_en.dart`
- Modify: `brainy-app/lib/l10n/app_localizations_ru.dart`

- [ ] **Step 1: Add new keys to app_en.arb**

Replace `"parentReminders": "Reminders"` with `"parentNotifications": "Notifications"`.

Add after `"settingsReminderTime"`:

```json
  "settingsDefaultTime": "default",
  "settingsResetTime": "Reset to 20:00",
```

- [ ] **Step 2: Add new keys to app_ru.arb**

Replace `"parentReminders": "Напоминания"` with `"parentNotifications": "Уведомления"`.

Add after `"settingsReminderTime"`:

```json
  "settingsDefaultTime": "по умолчанию",
  "settingsResetTime": "Сбросить на 20:00",
```

- [ ] **Step 3: Update app_localizations.dart base class**

Replace `String get parentReminders;` with `String get parentNotifications;`.

Add after `String get settingsReminderTime;`:

```dart
  String get settingsDefaultTime;
  String get settingsResetTime;
```

- [ ] **Step 4: Update app_localizations_en.dart**

Replace `String get parentReminders => 'Reminders';` with `String get parentNotifications => 'Notifications';`.

Add after `String get settingsReminderTime`:

```dart
  @override
  String get settingsDefaultTime => 'default';

  @override
  String get settingsResetTime => 'Reset to 20:00';
```

- [ ] **Step 5: Update app_localizations_ru.dart**

Replace `String get parentReminders => 'Напоминания';` with `String get parentNotifications => 'Уведомления';`.

Add after `String get settingsReminderTime`:

```dart
  @override
  String get settingsDefaultTime => 'по умолчанию';

  @override
  String get settingsResetTime => 'Сбросить на 20:00';
```

- [ ] **Step 6: Commit**

```bash
git add brainy-app/l10n/ brainy-app/lib/l10n/
git commit -m "feat: add notification settings localization keys (RU/EN)"
```

---

### Task 6: Update onboarding to use new notification API

**Files:**
- Modify: `brainy-app/lib/features/onboarding/providers/onboarding_provider.dart:100-104`

- [ ] **Step 1: Replace notification logic in completeOnboarding()**

Replace lines 100-104:

```dart
    // Request notification permission and schedule daily reminder
    final granted = await NotificationService.requestPermission();
    if (granted) {
      await NotificationService.scheduleDailyReminder();
    }
```

With:

```dart
    // Request notification permission and enable notifications
    final granted = await NotificationService.requestPermission();
    if (granted) {
      final box = Hive.box(AppConstants.userBox);
      await box.put(AppConstants.notificationsEnabledKey, true);
      await NotificationService.reschedule(
        enabled: true,
        hasCustomTime: false,
        hour: AppConstants.defaultReminderHour,
        minute: AppConstants.defaultReminderMinute,
        currentStreak: 0,
        hasPlayedToday: false,
      );
    }
```

- [ ] **Step 2: Commit**

```bash
git add brainy-app/lib/features/onboarding/providers/onboarding_provider.dart
git commit -m "refactor: onboarding uses NotificationService.reschedule()"
```

---

### Task 7: Update game_screen.dart and main.dart integration

**Files:**
- Modify: `brainy-app/lib/features/game/screens/game_screen.dart:178`
- Modify: `brainy-app/lib/main.dart:29`

- [ ] **Step 1: Update game_screen.dart — replace cancelStreakWarning with reschedule**

Replace line 178 (`NotificationService.cancelStreakWarning();`) with:

```dart
    // Reschedule notification — hasPlayedToday=true will cancel it
    final parentSettings = ref.read(parentProvider);
    final progressData = ref.read(userProgressProvider);
    NotificationService.reschedule(
      enabled: parentSettings.notificationsEnabled,
      hasCustomTime: parentSettings.hasCustomReminderTime,
      hour: parentSettings.customReminderHour,
      minute: parentSettings.customReminderMinute,
      currentStreak: progressData.currentStreak,
      hasPlayedToday: true,
    );
```

Add import at top:

```dart
import '../../parent/providers/parent_provider.dart';
```

- [ ] **Step 2: Update main.dart — add reschedule on app start**

After `await NotificationService.initialize();` (line 29), add a helper that runs after ProviderScope is available. The cleanest approach: create a `_RescheduleNotifications` widget that runs once.

Replace lines 29-34:

```dart
  await NotificationService.initialize();
  runApp(
    const ProviderScope(
      child: BrainyApp(),
    ),
  );
}

class _NotificationRescheduler extends ConsumerWidget {
  final Widget child;
  const _NotificationRescheduler({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trigger reschedule once on first build
    ref.listen(parentProvider, (_, __) {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reschedule(ref);
    });

    return child;
  }

  void _reschedule(WidgetRef ref) {
    final box = Hive.box(AppConstants.userBox);
    final enabled =
        box.get(AppConstants.notificationsEnabledKey) as bool? ?? false;
    if (!enabled) return;

    final hasCustomTime =
        box.get(AppConstants.hasCustomReminderTimeKey) as bool? ?? false;
    final hour = box.get(AppConstants.customReminderHourKey) as int? ??
        AppConstants.defaultReminderHour;
    final minute = box.get(AppConstants.customReminderMinuteKey) as int? ??
        AppConstants.defaultReminderMinute;

    final progressBox = Hive.box<UserProgress>(AppConstants.progressBox);
    final progress = progressBox.get(AppConstants.progressDataKey);
    final currentStreak = progress?.currentStreak ?? 0;

    final sessionsBox = Hive.box<GameSession>(AppConstants.sessionsBox);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final hasPlayedToday = sessionsBox.values.any((s) {
      final d = s.playedAt;
      return d.year == today.year &&
          d.month == today.month &&
          d.day == today.day;
    });

    NotificationService.reschedule(
      enabled: true,
      hasCustomTime: hasCustomTime,
      hour: hour,
      minute: minute,
      currentStreak: currentStreak,
      hasPlayedToday: hasPlayedToday,
    );
  }
}
```

Update `BrainyApp.build()` to wrap content with `_NotificationRescheduler`:

```dart
  @override
  Widget build(BuildContext context) {
    return _NotificationRescheduler(
      child: MaterialApp.router(
        title: 'Brainy',
        theme: AppTheme.darkTheme,
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ru'),
          Locale('en'),
        ],
      ),
    );
  }
```

Add imports at top of main.dart:

```dart
import 'features/parent/providers/parent_provider.dart';
import 'models/session.dart';
```

- [ ] **Step 3: Commit**

```bash
git add brainy-app/lib/features/game/screens/game_screen.dart brainy-app/lib/main.dart
git commit -m "feat: integrate NotificationService.reschedule() into app start and game completion"
```

---

### Task 8: Build and verify

- [ ] **Step 1: Run flutter build to check for compilation errors**

```bash
cd brainy-app && flutter build ios --no-codesign 2>&1 | tail -20
```

- [ ] **Step 2: Fix any compilation errors found**

- [ ] **Step 3: Final commit if fixes were needed**

```bash
git add -A && git commit -m "fix: resolve compilation issues from notification refactor"
```
