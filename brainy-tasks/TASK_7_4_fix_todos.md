# Задание 7.4 — Закрыть TODO в коде

> **Приоритет:** P0 (незавершённая функциональность)
> **Статус:** Не начато

---

## Проблема

В коде есть 2 незакрытых TODO, которые означают, что часть игровой логики не работает:

### TODO 1: Ачивка за недельный стрик

**Файл:** `lib/features/game/providers/user_progress_provider.dart:68`

```dart
// TODO: trigger 'week_streak' achievement
```

Ачивка `streak_7` (7-дневный стрик) определена в данных ачивок, но **никогда не разблокируется** — нет вызова `unlockAchievement('streak_7')` при достижении 7-дневного стрика.

**Решение:** Добавить проверку `currentStreak >= 7` и вызвать разблокировку ачивки.

### TODO 2: Разблокировка персонажа Vortex

**Файл:** `lib/features/game/providers/user_progress_provider.dart:71`

```dart
// TODO: unlock Vortex character
```

Персонаж Vortex должен разблокироваться при 30-дневном стрике, но **логика не реализована**.

**Решение:** Добавить проверку `currentStreak >= 30` и разблокировать персонажа Vortex.

---

## Что нужно сделать

В `user_progress_provider.dart`, в методе обновления стрика:

```dart
// После обновления стрика:
if (progress.currentStreak >= 7) {
  // Разблокировать ачивку streak_7
  _unlockAchievement('streak_7');
}
if (progress.currentStreak >= 30) {
  // Разблокировать персонажа Vortex
  _unlockCharacter('vortex');
  // Разблокировать ачивку streak_30
  _unlockAchievement('streak_30');
}
```

---

## Файлы для изменения

- `lib/features/game/providers/user_progress_provider.dart` — реализовать оба TODO

---

## Критерии готовности

- [ ] Ачивка `streak_7` разблокируется при стрике ≥ 7
- [ ] Ачивка `streak_30` разблокируется при стрике ≥ 30
- [ ] Персонаж Vortex разблокируется при стрике ≥ 30
- [ ] Все TODO удалены из кода
- [ ] Звук ачивки проигрывается при разблокировке
