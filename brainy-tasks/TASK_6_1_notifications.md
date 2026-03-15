# Задание 6.1.1 — Уведомления

> **Используй вместе с MASTER_CONTEXT.md**

---

## Цель

Переработать систему уведомлений: одно контекстное уведомление в день с настраиваемым временем и умным выбором текста.

---

## Модель

Одно уведомление в день (единый ID). Логика пересчёта при каждом открытии приложения и после завершения игры:

1. `notificationsEnabled` выключены → `cancelAll()`, выход
2. Ребёнок уже играл сегодня → отменяем уведомление
3. Не играл сегодня:
   - Время: `customReminderTime` если задано, иначе **20:00**
   - Текст: если `currentStreak > 2` → из пула «стрик горит», иначе → из пула «мотивация»
   - Планируем уведомление

---

## NotificationService

### Рефакторинг

Убрать разделение на `scheduleDailyReminder` / `scheduleStreakWarning` (два ID).

Один публичный метод:

```dart
static Future<void> reschedule({
  required bool enabled,
  required bool hasCustomTime,
  required int hour,
  required int minute,
  required int currentStreak,
  required bool hasPlayedToday,
}) async
```

- Один ID уведомления (`_notificationId = 100`)
- Если `!enabled` или `hasPlayedToday` → `cancelAll()`
- Иначе → планируем на `hour:minute` с контекстным текстом

### Тексты уведомлений

**Мотивация (стрик ≤ 2 или нет стрика)** — минимум 7 вариантов:

RU:
1. «Время потренировать мозг!»
2. «Брейни ждёт тебя! Зайди на тренировку»
3. «Несколько минут — и мозг станет быстрее!»
4. «Зэп зовёт на тренировку!»
5. «Сегодня ещё не тренировались. Начнём?»
6. «Мозг любит тренировки. Не пропусти!»
7. «Пора размять мозг! Таблица Шульте ждёт»

EN:
1. "Time to train your brain!"
2. "Brainy is waiting for you! Start training"
3. "A few minutes and your brain gets faster!"
4. "Zap is calling you to practice!"
5. "Haven't trained today yet. Shall we start?"
6. "Your brain loves training. Don't skip it!"
7. "Time to exercise your brain! Schulte table awaits"

**Стрик горит (стрик > 2, не играл сегодня)** — минимум 7 вариантов:

RU:
1. «Стрик {N} дней сгорит сегодня!»
2. «Не потеряй свой стрик {N} дней!»
3. «{N} дней подряд — не останавливайся!»
4. «Стрик в опасности! Сыграй сегодня»
5. «Осталось немного до конца дня. Сохрани стрик!»
6. «Твой стрик {N} дней на волоске!»
7. «Брейни переживает за стрик {N} дней!»

EN:
1. "Your {N}-day streak expires today!"
2. "Don't lose your {N}-day streak!"
3. "{N} days in a row — don't stop now!"
4. "Streak in danger! Play today"
5. "Day is almost over. Save your streak!"
6. "Your {N}-day streak is hanging by a thread!"
7. "Brainy is worried about your {N}-day streak!"

`{N}` заменяется на `currentStreak`. Выбор варианта — по `dayOfYear % count`.

---

## Hive-ключи (AppConstants)

Заменить существующие ключи:

| Старый ключ | Новый ключ | Тип | По умолчанию |
|---|---|---|---|
| `parentRemindersEnabledKey` | `notificationsEnabledKey` | `bool` | `false` |
| `reminderHourKey` | `customReminderHourKey` | `int` | `20` |
| `reminderMinuteKey` | `customReminderMinuteKey` | `int` | `0` |
| — | `hasCustomReminderTimeKey` | `bool` | `false` |

---

## Parent Provider

### Состояние

```dart
bool notificationsEnabled       // false по умолчанию
bool hasCustomReminderTime      // false — время не задано вручную
int customReminderHour          // 20 по умолчанию
int customReminderMinute        // 0 по умолчанию
```

### Методы

```dart
Future<void> setNotificationsEnabled(bool value)
  // → сохраняет в Hive
  // → вызывает NotificationService.reschedule(...)

Future<void> setCustomReminderTime(int hour, int minute)
  // → hasCustomReminderTime = true
  // → сохраняет в Hive
  // → вызывает NotificationService.reschedule(...)

Future<void> clearCustomReminderTime()
  // → hasCustomReminderTime = false
  // → возвращает к 20:00 по умолчанию
  // → вызывает NotificationService.reschedule(...)
```

---

## Parent Settings UI

В `parent_settings_screen.dart`:

```
[Уведомления]
  Тоггл: Включить уведомления (вкл/выкл)

  (если включены):
    Текст: "Время напоминания: 20:00" или "Время напоминания: HH:MM"
    Кнопка: [Изменить время] → TimePicker
    (если время задано вручную):
      Кнопка: [Сбросить на 20:00]
```

---

## Точки вызова reschedule

1. **`main.dart`** — при старте приложения, после инициализации Hive и NotificationService
2. **`game_screen.dart`** — после завершения игры (hasPlayedToday = true → отменяет уведомление)
3. **`parent_provider.dart`** — при изменении настроек уведомлений

---

## Онбординг

Запрос разрешения на уведомления остаётся на последней странице онбординга (страница 5). При получении разрешения:

- `notificationsEnabled = true` сохраняется в Hive
- Вызывается `reschedule` с дефолтными параметрами (20:00, без кастомного времени)

---

## Локализация (ARB)

Добавить ключи для UI настроек:

```json
"settingsNotifications": "Уведомления",
"settingsNotificationsEnabled": "Включить уведомления",
"settingsReminderTime": "Время напоминания: {time}",
"settingsChangeTime": "Изменить время",
"settingsResetTime": "Сбросить на 20:00",
"settingsDefaultTime": "по умолчанию"
```

---

## Критерии готовности

- [ ] Одно уведомление в день с контекстным текстом
- [ ] 7+ вариантов текста для каждой ситуации (мотивация / стрик)
- [ ] Время по умолчанию 20:00, настраиваемое в родительских настройках
- [ ] Уведомление отменяется когда ребёнок сыграл сегодня
- [ ] Пересчёт при каждом запуске приложения
- [ ] Тоггл и TimePicker в настройках родителя
- [ ] Разрешение запрашивается в онбординге
- [ ] Все строки локализованы (RU + EN)
