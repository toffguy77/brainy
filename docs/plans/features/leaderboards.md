---
title: Лидерборды и лиги
tags: [gamecenter, leaderboard, league, ranking, weekly, besttime]
---

# Лидерборды и лиги

## Обзор

Интеграция с Game Center (iOS) и Google Play Games (Android) через пакет `games_services`. Таб «Лига» в нижней навигации показывает реальных игроков в кастомном UI с возможностью открыть нативный лидерборд.

## Лидерборды (7 штук)

| ID | Тип | Описание |
|----|-----|----------|
| weekly_xp | Recurring (еженедельный) | Недельный XP — основной рейтинг |
| best_time_3x3 | Best time | Лучшее время 3x3 |
| best_time_4x4 | Best time | Лучшее время 4x4 |
| best_time_5x5 | Best time | Лучшее время 5x5 |
| best_time_6x6 | Best time | Лучшее время 6x6 |
| best_time_7x7 | Best time | Лучшее время 7x7 |
| best_time_9x9 | Best time | Лучшее время 9x9 |

## Тиры (визуальные, локальный расчёт)

| Тир | Порог недельного XP |
|-----|---------------------|
| Бронза | 0 |
| Серебро | 150 |
| Золото | 400 |
| Платина | 800 |

Тир — персональный бейдж, рассчитывается локально по недельному XP. Не влияет на группировку в лидерборде.

## Идентификация игрока

Имя берётся из Game Center / Play Games через `GameServicesService.getPlayerName()`. Пользователь может задать кастомное имя через тап на свою строку в лидерборде — оно сохраняется в Hive (`userBox['customPlayerName']`) и используется вместо имени из Game Center. Кастомное имя — только локальное, другие игроки в Game Center видят оригинальное имя. Если ни кастомного, ни Game Center имени нет — отображается «Lv{N}».

## Экран лиги

Маршрут: `/league` (таб в нижней навигации).

Структура:
- Тир-бейдж с иконкой и названием + прогресс до следующего тира
- Недельный XP: «N XP на этой неделе»
- Лидерборд (реальные игроки): ранг, имя, XP. Текущий игрок подсвечен
- Кнопка «Полный рейтинг» -> нативный Game Center / Play Games
- Подвал: «Обновляется каждый понедельник»

Если Game Services не авторизован — карточка «Подключи Game Center для соревнований» + кнопка [Подключить].

## Отправка скоров

Выполняется после завершения каждой сессии:
1. Пересчёт недельного XP -> `submitWeeklyXp(totalWeeklyXp)`
2. Если личный рекорд -> `submitBestTime(gridSize, timeMs)`
3. Если Game Services не авторизован — отправка пропускается без ошибок

## Модели

`LeaderboardEntry`: playerName, score, rank, isCurrentPlayer.

`LeagueTier` enum: bronze, silver, gold, platinum (определён в `league.dart`).

## Ключевые файлы

- `brainy-app/lib/shared/services/game_services_service.dart`
- `brainy-app/lib/features/league/providers/game_services_provider.dart`
- `brainy-app/lib/features/league/providers/league_provider.dart`
- `brainy-app/lib/features/league/screens/league_screen.dart`
- `brainy-app/lib/models/leaderboard_entry.dart`
- `brainy-app/lib/models/league.dart`
