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

Решение принимает чистая функция `NotificationService.planReminder(...)` (покрыта тестами):
1. `notificationsEnabled` выключены -> `null` (ничего не планируется, прежнее отменено)
2. Уже играл сегодня (`hasPlayedOn(sessions, now)`) -> `null`
3. Иначе -> `ReminderPlan` (час, минута, пул, индекс варианта)

Параметры:
- Время: кастомное, если `hasCustomReminderTime`, иначе `AppConstants.defaultReminderHour/Minute` (20:00)
- Пул: `currentStreak > AppConstants.streakWarningThreshold` (2) -> «стрик горит», иначе «мотивация»

## Часовой пояс и язык

- При инициализации `flutter_timezone` задаёт `tz.local` по поясу устройства — иначе `timezone`
  остаётся в UTC и напоминание на 20:00 срабатывало бы в 20:00 UTC.
- Язык текста — язык устройства через `AppConstants.resolveLanguage`: `ru` -> русский, любой
  другой -> английский (то же правило, что `localeResolutionCallback` в `main.dart`).
- Заголовок — `l10n.appName`.

## Текст уведомлений

Один notification ID: `_notificationId = 100`.

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
