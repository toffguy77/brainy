---
title: Уведомления
tags: [notifications, reminders, schedule, permissions]
---

# Уведомления

## Обзор

Одно контекстное уведомление в день с настраиваемым временем. Текст выбирается умно: мотивационный или предупреждение о стрике. Реализовано через `flutter_local_notifications` + `timezone`.

## Логика пересчёта

Единый метод `NotificationService.reschedule()` вызывается:
1. При старте приложения (`main.dart`)
2. После завершения игры (`game_screen.dart`)
3. При изменении настроек уведомлений (`parent_provider.dart`)

Алгоритм:
1. `notificationsEnabled` выключены -> `cancel()`, выход
2. Ребёнок уже играл сегодня (`hasPlayedToday`) -> `cancel()`, выход
3. Не играл сегодня -> планируем уведомление

Параметры:
- Время: `customReminderTime` если задано, иначе 20:00 (`AppConstants.defaultReminderHour/Minute`)
- Текст: если `currentStreak > 2` -> из пула «стрик горит», иначе -> из пула «мотивация»

## Текст уведомлений

Один notification ID: `_notificationId = 100`.

### Мотивация (стрик <= 2, 7 вариантов)

RU: «Время потренировать мозг!», «Брейни ждёт тебя!», «Зэп зовёт на тренировку!» и др.
EN: «Time to train your brain!», «Brainy is waiting for you!», «Zap is calling you to practice!» и др.

### Стрик горит (стрик > 2, 7 вариантов)

RU: «Стрик {N} дней сгорит сегодня!», «Не потеряй свой стрик {N} дней!» и др.
EN: «Your {N}-day streak expires today!», «Don't lose your {N}-day streak!» и др.

Выбор варианта: `dayOfYear % count` (детерминированный, меняется каждый день).

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

Запрос разрешения через `permission_handler` на последней странице онбординга (страница 7, notifications). При получении разрешения `notificationsEnabled = true` и вызывается `reschedule` с дефолтными параметрами.

## Приоритет уведомлений

- Стрик-предупреждения: `Importance.high`, `Priority.high`
- Мотивационные: `Importance.defaultImportance`, `Priority.defaultPriority`

## Ключевые файлы

- `brainy-app/lib/shared/services/notification_service.dart`
- `brainy-app/lib/features/parent/providers/parent_provider.dart`
- `brainy-app/lib/constants/app_constants.dart` — notification keys and defaults
