# Задание 3.2 — Профиль ребёнка и стрик

> **Используй вместе с MASTER_CONTEXT.md**
> Выполняется после задания 3.1.

---

## Цель

Реализовать модель пользователя, систему стрика и главный экран ребёнка.

---

## Модель пользователя

### `lib/models/user_progress.dart`

```dart
@HiveType(typeId: 1)
class UserProgress extends HiveObject {
  @HiveField(0)
  int coins;

  @HiveField(1)
  int xp;

  @HiveField(2)
  int level;

  @HiveField(3)
  int currentStreak;      // дней подряд

  @HiveField(4)
  int longestStreak;

  @HiveField(5)
  DateTime? lastPlayedDate;

  @HiveField(6)
  String childAge;        // '6-9' | '10-12' | '13-14'

  @HiveField(7)
  List<String> goals;

  @HiveField(8)
  int dailyGoalMinutes;

  @HiveField(9)
  String activeCharacterId;  // 'brainy' по умолчанию
}
```

---

## Логика стрика

### `lib/features/progress/providers/streak_provider.dart`

Стрик обновляется при сохранении каждой новой сессии:

```
Правила:
1. Если lastPlayedDate == сегодня → стрик не меняется (уже сыграли сегодня)
2. Если lastPlayedDate == вчера → streak += 1
3. Если lastPlayedDate < вчера → streak = 1 (сброс)
4. Если lastPlayedDate == null → streak = 1 (первая игра)

После обновления проверить:
- streak == 7  → выдать бонус 50 монет + ачивку 'week_streak'
- streak == 30 → выдать бонус 200 монет + разблокировать персонажа Vortex
```

---

## Главный экран ребёнка

### Обновить `lib/features/game/screens/game_screen.dart` (главный экран, не экран игры)

Создать `lib/features/home/screens/home_screen.dart`:

**Структура:**
```
SafeArea
├── Верхняя панель
│   ├── 🪙 [количество монет]
│   └── 🔥 [стрик] дней
│
├── Персонаж по центру (большой, 200×200)
│   └── Анимация idle (покачивание)
│
├── Кнопка [Играть] (большая, градиентная)
│
├── Строка выбора размера сетки
│   └── 3×3 | 4×4 | 5×5 | 🔒6×6 | 🔒7×7
│
└── Последний результат (если есть)
    "Последний раз: 28 сек"
```

---

## Критерии готовности

- [ ] `UserProgress` сохраняется и читается из Hive
- [ ] Стрик корректно увеличивается при ежедневной игре
- [ ] Стрик сбрасывается если пропущен день
- [ ] При стрике 7 дней — выдаются монеты и ачивка
- [ ] Главный экран показывает монеты и стрик
- [ ] Выбор размера таблицы сохраняется
- [ ] Заблокированные (Premium) размеры отображаются с иконкой 🔒