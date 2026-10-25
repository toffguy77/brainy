---
title: Онбординг
tags: [onboarding, tutorial, firstlaunch, welcome, age, goals]
---

# Онбординг

## Обзор

6-экранный онбординг (PageView) при первом запуске. Собирает данные о ребёнке. После завершения сохраняется флаг `onboardingCompleted: true` в Hive — повторные запуски открывают сразу `/home`.

## Структура (6 страниц)

Константа: `AppConstants.onboardingPageCount = 6`.

### Страница 1 — Приветствие (`welcome_page.dart`)
- Анимированный логотип Brainy
- «Тренируем мозг играючи»
- Подзаголовок про таблицы Шульте для детей 6-14 лет
- Кнопка [Начать]

### Страница 2 — Что такое Шульте (`schulte_info_page.dart`)
- Мини-таблица 3x3 (статичная, фиксированная раскладка [3,7,1/5,9,4/8,2,6])
- Ячейка «1» подсвечена зелёным, «2» фиолетовым
- 3 преимущества: внимание, периферическое зрение, скорость чтения
- Кнопка [Далее]

### Страница 3 — Проверено наукой (`science_page.dart`)
- Иконка мозга в круге
- 3 факта-карточки: «60+ лет», «2 недели», «5 мин/день»
- Кнопка [Далее]

### Страница 4 — Возраст ребёнка (`age_page.dart`)
- «Сколько лет ребёнку?»
- 3 карточки: 6-9, 10-12, 13-14
- Сохранение в Hive по ключу `childAge`

### Страница 5 — Главная цель (`goals_page.dart`)
- «Какая главная цель?»
- 4 карточки (множественный выбор): concentration, reading, exams, fun
- Сохранение по ключу `goals`

### Страница 6 — Частота тренировок (`frequency_page.dart`) — последняя
- «Как часто заниматься?»
- 3 карточки: 5 мин, 10 мин (рекомендуем), 15+ мин
- Выбор завершает онбординг: сохраняет `onboardingCompleted: true` и запрашивает разрешение на уведомления (внутри `completeOnboarding()`)
- Сохранение по ключу `dailyGoalMinutes` (и в `UserProgress.dailyGoalMinutes`). Используется как дневная цель:
  на главной — полоса «Сегодня: X из N мин» по сумме времени сегодняшних сессий, родитель может
  изменить цель в настройках


## Навигация

- Кнопка [Далее] или свайп между страницами
- Кнопка [Назад] на страницах 2+
- Индикатор прогресса: 6 точек
- После завершения: роутер перенаправляет на `/home`

## Опции

Определены в `AppConstants`:
- `ageOptions`: ['6-9', '10-12', '13-14']
- `goalOptions`: ['concentration', 'reading', 'exams', 'fun']
- `frequencyOptions`: [5, 10, 15]
- `recommendedFrequencyMinutes`: 10

## Хранение

Все данные онбординга в Hive box `user`:
- `userKeyChildAge`, `userKeyGoals`, `userKeyDailyGoalMinutes`
- `userKeyOnboardingCompleted`

## Ключевые файлы

- `brainy-app/lib/features/onboarding/screens/onboarding_screen.dart`
- `brainy-app/lib/features/onboarding/pages/` — 7 файлов страниц
- `brainy-app/lib/features/onboarding/providers/onboarding_provider.dart`
