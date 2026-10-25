---
title: Прогресс и достижения
tags: [progress, xp, streaks, achievements, stats, coins, level, charts]
---

# Прогресс и достижения

## Обзор

Система прогресса включает монеты, XP/уровни, стрики, достижения и графики детальной статистики. Все данные хранятся локально в Hive.

## Монеты

Зарабатываются только игрой, нельзя купить за реальные деньги.

| Событие | Монеты |
|---------|--------|
| Завершение сессии | +10 |
| Личный рекорд | +25 |
| Стрик 7 дней | +50 |
| Стрик 30 дней | +200 |

Константы: `AppConstants.coinsPerSession`, `coinsForRecord`, `coinsForStreak7`, `coinsForStreak30`.

Монеты тратятся на покупку аксессуаров в магазине персонажей (`/accessories`, вход с экрана персонажа).

## XP и уровни

XP за каждую сессию = количество клеток в таблице (`gridSize * gridSize`). Например: 5x5 = 25 XP.

Пороги уровней определены в `AppConstants.xpThresholds` (20 уровней):
- Уровень 1: 0 XP, Уровень 2: 50, Уровень 5: 300, Уровень 10: 1100, Уровень 20: 6000

Уровень отображается на главном экране под персонажем: "Lv.N".

## Стрик

Правила обновления стрика при сохранении сессии:
1. lastPlayedDate == сегодня -> стрик не меняется
2. lastPlayedDate == вчера -> streak += 1
3. lastPlayedDate < вчера -> streak = 1 (сброс)
4. lastPlayedDate == null -> streak = 1 (первая игра)

Бонусы за стрик:
- 7 дней: +50 монет
- 14 дней: разблокировка персонажа Pixel
- 30 дней: +200 монет + разблокировка персонажа Vortex

Стрик отображается на главном экране (иконка огня, оранжевая если > 0).

## Достижения

10 достижений в MVP, определены в `AchievementsProvider`:

| ID | Условие |
|----|---------|
| first_game | Первая завершённая сессия |
| personal_record | Личный рекорд |
| speed_demon | 3x3 за <=5 сек |
| master_5x5 | 5x5 за <=20 сек |
| focus_mode | Таблица без ошибок |
| streak_3 | Стрик 3 дня |
| streak_7 | Стрик 7 дней |
| streak_30 | Стрик 30 дней |
| night_owl | Игра после 22:00 |
| coin_hoarder | Накоплено 500 монет |

Источник истины — enum `AchievementId` в `lib/models/achievement.dart`. Ключ хранения
(`idString`) — snake_case от имени варианта; путь к бейджу — `assets/badges/{idString}.png`.

Проверяются после каждой сессии. При получении — popup-уведомление.

Экран достижений: `/progress` (таб в нижней навигации). Разблокированные цветные с датой, заблокированные серые.

## Детальная статистика по размеру

При тапе на чип рекорда на экране прогресса открывается `GridDetailScreen` с:
- Фильтры периодов: Нед | Мес | 3М | Год | Всё
- График LineChart (fl_chart): линия daily best, scatter-точки всех сессий, пунктир рекорда
- Карточки: лучшее время, среднее время, всего игр

Доступна всем пользователям.

Провайдер: `GridStatsProvider` с `TimePeriod` enum.

## Модель UserProgress

Hive typeId: 1. Поля: coins, xp, level, currentStreak, longestStreak, lastPlayedDate, childAge, goals, dailyGoalMinutes, activeCharacterId.

Файл: `brainy-app/lib/models/user_progress.dart`

## Ключевые файлы

- `brainy-app/lib/features/game/providers/user_progress_provider.dart` — UserProgressNotifier
- `brainy-app/lib/features/progress/providers/achievements_provider.dart`
- `brainy-app/lib/features/progress/providers/grid_stats_provider.dart`
- `brainy-app/lib/features/progress/screens/progress_screen.dart`
- `brainy-app/lib/features/progress/screens/grid_detail_screen.dart`
