---
title: Уведомления
tags: [notifications, reminders, schedule, permissions]
---

# Уведомления

## Обзор

Одно контекстное уведомление в день с настраиваемым временем. Текст выбирается умно: мотивационный или предупреждение о стрике. Реализовано через `flutter_local_notifications` + `timezone`.

## Логика пересчёта

Единая точка входа `NotificationService.rescheduleFromStorage()` сама читает настройки, стрик и
сегодняшние сессии из Hive и язык устройства. Вызывается:
1. При старте приложения (`main.dart`)
2. После завершения игры (`SessionCompleter` в `session_completion_provider.dart`)
3. После онбординга, если разрешение получено (`onboarding_provider.dart`)
4. При изменении настроек уведомлений (`parent_provider.dart`)

Решение принимает чистая функция `NotificationService.planReminders(...)` (покрыта тестами) и
возвращает разовые напоминания (`ReminderSlot`) на `AppConstants.reminderDaysAhead` (7) дней вперёд
в одно и то же время:
1. `notificationsEnabled` выключены -> пустой список
2. Сегодняшний слот пропускается, если ребёнок уже играл (`hasPlayedOn(sessions, now)`) или время
   уже прошло — напоминания продолжаются с завтрашнего дня
3. «Стрик горит» — только у первого слота и только при `currentStreak >
   AppConstants.streakWarningThreshold` (2); если его пропустить, стрик всё равно сгорит, поэтому
   дальше идёт пул «мотивация»
4. Вариант текста — по дате слота (`variantIndexFor`), у каждого дня свой

Время: кастомное, если `hasCustomReminderTime`, иначе `AppConstants.defaultReminderHour/Minute` (20:00).

Перед планированием отменяются все id `100..106` (id = 100 + смещение дня). Разовые уведомления,
а не одно повторяющееся: так напоминания приходят, даже если приложение не открывали несколько
дней, сегодняшнее можно пропустить после игры, а число дней стрика не «застывает» в тексте.

## Часовой пояс и язык

- При инициализации `flutter_timezone` задаёт `tz.local` по поясу устройства — иначе `timezone`
  остаётся в UTC и напоминание на 20:00 срабатывало бы в 20:00 UTC.
- Язык текста — язык устройства через `AppConstants.resolveLanguage`: `ru` -> русский, любой
  другой -> английский (то же правило, что `localeResolutionCallback` в `main.dart`).
- Заголовок — `l10n.appName`.

## Текст уведомлений

ID: `100 + день` (0..6), см. «Логика пересчёта».

### Мотивация (стрик <= 2, 7 вариантов)

RU: «Время потренировать мозг!», «Брейни ждёт тебя!», «Зэп зовёт на тренировку!» и др.
EN: «Time to train your brain!», «Brainy is waiting for you!», «Zap is calling you to practice!» и др.

### Стрик горит (стрик > 2, 7 вариантов)

RU: «Стрик {N} дней сгорит сегодня!», «Не потеряй свой стрик {N} дней!» и др.
EN: «Your {N}-day streak expires today!», «Don't lose your {N}-day streak!» и др.

Выбор варианта: число дней с 2024-01-01 по UTC-датам `% 7` (`variantIndexFor`) — детерминированно,
меняется каждый день, не сбивается переходом на летнее время.

## Настройки (Hive)

| Ключ | Тип | По умолчанию |
|------|-----|-------------|
| `notificationsEnabledKey` | bool | false |
| `hasCustomReminderTimeKey` | bool | false |
| `customReminderHourKey` | int | 20 |
| `customReminderMinuteKey` | int | 0 |

## UI настроек

В `parent_settings_screen.dart`:
- Тоггл: Включить уведомления
- Текст: «Время напоминания: HH:MM»
- Кнопка [Изменить время] -> TimePicker
- Кнопка [Сбросить на 20:00] (если задано кастомное время)

## Разрешения

- Онбординг: запрос через `permission_handler` в `completeOnboarding()` (последняя страница). При
  согласии `notificationsEnabled = true` и вызывается `rescheduleFromStorage()`.
- Родительские настройки: включение тоггла сначала запрашивает разрешение. При отказе настройка
  остаётся выключенной и показывается подсказка открыть настройки iOS — тоггл не обещает того,
  чего iOS не доставит.

## Приоритет уведомлений (iOS)

- Стрик-предупреждения: `InterruptionLevel.timeSensitive`
- Мотивационные: `InterruptionLevel.active`

## Ключевые файлы

- `brainy-app/lib/shared/services/notification_service.dart`
- `brainy-app/lib/features/parent/providers/parent_provider.dart`
- `brainy-app/lib/constants/app_constants.dart` — notification keys and defaults
