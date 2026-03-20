---
title: Игровые режимы
tags: [game, schulte, gorbov, grid, classic, modes, session, records, timer]
---

# Игровые режимы

## Обзор

Brainy предлагает два игровых режима на основе таблиц Шульте: классический и Горбова-Шульте. Игрок тапает числа в заданном порядке на сетке N x N. Таймер запускается после 3-секундного обратного отсчёта.

## Классический режим

Сетка N x N заполнена числами от 1 до N² в случайном порядке. Игрок тапает по возрастанию: 1, 2, 3... до N².

- Правильный тап: ячейка подсвечивается зелёным и помечается найденной
- Неправильный тап: красное мигание (500ms), штраф +2 секунды (`AppConstants.mistakePenaltySeconds`)
- Завершение: когда `nextNumber > totalNumbers`

## Режим Горбова-Шульте (Premium)

Двухцветная модификация. Сетка содержит белые и красные числа. Игрок чередует:
- Белые числа по возрастанию: 1, 2, 3...
- Красные числа по убыванию: max, max-1, max-2...

Последовательность: белая 1 -> красная max -> белая 2 -> красная (max-1) -> ...

Распределение для таблицы N x N:
- Белых: `ceil(N²/2)`, значения 1..ceil(N²/2)
- Красных: `floor(N²/2)`, значения 1..floor(N²/2)

Доступные размеры для Горбова: 5x5, 6x6, 7x7, 9x9 (`AppConstants.gorbovGridSizes`).

Красные ячейки отображаются цветом `#E17055` (не `AppColors.error`), чтобы не путать с подсветкой ошибок.

Завершение: `nextWhiteNumber > whiteCount && nextRedNumber < 1`.

## Размеры таблиц

| Размер | Доступ | Целевое время (сек) | 3 звезды (<=) | 2 звезды (<=) |
|--------|--------|---------------------|---------------|---------------|
| 3x3 | Free | 9 | 8s | 15s |
| 4x4 | Free | 16 | 14s | 25s |
| 5x5 | Free | 25 | 22s | 38s |
| 6x6 | Premium | 36 | 32s | 55s |
| 7x7 | Premium | 49 | 45s | 75s |
| 9x9 | Premium | 81 | 80s | 130s |

Все размеры отображаются в пикере на home screen (`AppConstants.pickerGridSizes = [3, 4, 5, 6, 7, 9]`). Premium-размеры показывают замок для бесплатных пользователей.

## Адаптивная сложность

Приложение предлагает следующий размер, когда среднее время за последние 5 сессий (`AppConstants.sessionsForAdaptive`) <= целевого времени для текущего размера. Родитель может переключить режим на фиксированный размер через настройки.

## Рекорды

Рекорды хранятся в Hive box `records` с ключами вида `"classic_5"`, `"gorbov_7"` (формат `{mode}_{gridSize}`). При первом запуске после обновления выполняется миграция старых ключей (`"5"` -> `"classic_5"`).

Файл: `brainy-app/lib/features/game/providers/records_provider.dart`

## Сессии

Каждая завершённая игра сохраняется как `GameSession` в Hive box `sessions`:
- id (UUID v4), playedAt, gridSize, durationSeconds, mistakesCount
- isPersonalRecord, mode ('classic' | 'gorbov'), coinsEarned
- Вычисляемые: `xpEarned = gridSize * gridSize`, `stars` (1-3)

Файл: `brainy-app/lib/models/session.dart`

## Звёзды

Оценка по звёздам определяется из `AppConstants.starThresholds`:
- 3 звезды: время <= порог[0]
- 2 звезды: время <= порог[1]
- 1 звезда: остальное

## Ключевые файлы

- `brainy-app/lib/models/game_state.dart` — GameState, GridCell, GameStatus enum
- `brainy-app/lib/features/game/providers/game_provider.dart` — GameNotifier (логика игры)
- `brainy-app/lib/features/game/providers/records_provider.dart` — RecordsNotifier
- `brainy-app/lib/features/game/providers/sessions_provider.dart` — SessionsNotifier
- `brainy-app/lib/constants/app_constants.dart` — все числовые константы
