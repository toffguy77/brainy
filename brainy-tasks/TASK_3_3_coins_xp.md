# Задание 3.3 — Система монет и XP

> **Используй вместе с MASTER_CONTEXT.md**
> Выполняется после задания 3.2.

---

## Цель

Реализовать полную систему начисления монет, XP, уровней и базовую систему ачивок.

---

## Провайдер монет и XP

### `lib/features/progress/providers/rewards_provider.dart`

Метод `processSessionRewards(GameSession session)` вызывается после каждой сессии:

```
1. Начислить базовые монеты: +10
2. Если isPersonalRecord: +25 монет
3. Если стрик == 7: +50 монет (один раз)
4. Если стрик == 30: +200 монет (один раз)
5. Начислить XP = gridSize * gridSize
6. Проверить повышение уровня
7. Проверить новые ачивки
8. Сохранить всё в Hive
```

---

## Ачивки

### `lib/models/achievement.dart`

```dart
class Achievement {
  final String id;
  final String titleRu;
  final String titleEn;
  final String descriptionRu;
  final String descriptionEn;
  final String iconAsset;
  final bool isUnlocked;
  final DateTime? unlockedAt;
}
```

**Список ачивок для MVP:**

| ID | Условие |
|---|---|
| first_game | Первая завершённая сессия |
| personal_record | Личный рекорд |
| triple_record | Личный рекорд 3 раза |
| streak_3 | Стрик 3 дня |
| streak_7 | Стрик 7 дней |
| streak_30 | Стрик 30 дней |
| master_5x5 | Пройти 5×5 за ≤20 сек |
| fast_3x3 | Пройти 3×3 за ≤5 сек |
| collector_10 | Собрать 10 аксессуаров |
| no_mistakes | Пройти таблицу без ошибок |

---

## Экран ачивок

### `lib/features/progress/screens/achievements_screen.dart`

**Структура:**
- Список всех ачивок
- Разблокированные — цветные с датой получения
- Заблокированные — серые с описанием условия
- При получении новой ачивки — попап снизу экрана (SnackBar стиле но красивый)

---

## Критерии готовности

- [ ] Монеты начисляются корректно после каждой сессии
- [ ] XP начисляется и уровень повышается
- [ ] Все 10 ачивок проверяются после каждой сессии
- [ ] При получении ачивки появляется красивый попап
- [ ] Экран ачивок отображает разблокированные и заблокированные
- [ ] Все данные сохраняются в Hive