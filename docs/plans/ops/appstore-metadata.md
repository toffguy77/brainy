---
title: Метаданные App Store
tags: [appstore, metadata, screenshots, keywords, description, review]
---

# Метаданные App Store

## Обзор

Метаданные для публикации в App Store Connect. Управляются через Fastlane deliver (директория `brainy-app/ios/fastlane/metadata/`). Два языка: русский и английский.

## Название и подзаголовок

| Поле | RU | EN |
|------|----|----|
| Название | Brainy -- Таблицы Шульте | Brainy -- Brain Training |
| Подзаголовок | Тренажёр внимания для детей | Focus Trainer for Kids |

## Ключевые слова (до 100 символов)

- **RU:** таблица шульте,тренировка внимания,скорочтение,развитие ребёнка,концентрация,память
- **EN:** schulte table,brain training,focus kids,speed reading,attention,cognitive

## Категория и рейтинг

- Основная категория: Education
- Дополнительная: Games > Educational
- Возрастной рейтинг: 4+
- Bundle ID: `com.brainyapp.brainy`

## Скриншоты

Требуемые размеры:
- iPhone 6.7" (1290x2796) — обязательно
- iPhone 6.5" (1284x2778) — рекомендуется

Экраны для скриншотов (6 штук):
1. Главный экран с персонажем
2. Игровой экран (таблица 5x5 в процессе)
3. Экран результата (3 звезды, рекорд)
4. Экран персонажей
5. Экран прогресса/достижений
6. Панель родителя с графиком

Подписи к скриншотам (RU/EN):
1. «Тренируй внимание каждый день» / «Train your focus daily»
2. «Таблицы Шульте от 3x3 до 9x9» / «Schulte tables from 3x3 to 9x9»
3. «Ставь рекорды и получай звёзды» / «Set records and earn stars»
4. «Собирай персонажей» / «Collect characters»
5. «Следи за прогрессом» / «Track your progress»
6. «Контроль для родителей» / «Parent controls»

Скрипт композиции: `brainy-app/scripts/compose_screenshots.py`

## Описание приложения

### RU (краткое содержание)

Brainy -- игровой тренажёр внимания для детей 6-14 лет. Таблицы от 3x3 до 9x9 с адаптивной сложностью. Звёзды, монеты, достижения, персонажи, стрики. Панель родителя с PIN и статистикой. Brainy Pro: расширенные таблицы, режим Горбова-Шульте, эксклюзивный персонаж, без рекламы.

### EN (краткое содержание)

Brainy is a gamified attention trainer for kids 6-14, based on Schulte tables. Tables 3x3 to 9x9, adaptive difficulty, stars, coins, achievements, characters, streaks. Parent panel with PIN and analytics. Brainy Pro: extended tables, Gorbov-Schulte mode, exclusive character, ad-free.

## Privacy Nutrition Labels

Данные, собираемые приложением:
- Crash Data (Firebase Crashlytics)

Analytics не собирается: Firebase Analytics удалён (решение 2026-08-01). В App Store Connect
категория Analytics должна быть снята с декларации.

## App Review Information

- Демо-инструкции: «Приложение не требует входа. Пройдите онбординг. Для панели родителя создайте PIN.»
- IDFA: не используется (add_id_info_uses_idfa: false)

## Что нового (текущий релиз)

- RU: Первый релиз Brainy! Тренируйте внимание с помощью таблиц Шульте.
- EN: First release of Brainy! Train your focus with Schulte tables.

## Fastlane deliver

Автоматическая загрузка метаданных и скриншотов выполняется через lane `submit_review` в Fastfile. Параметры:
- `overwrite_screenshots: true`
- `skip_binary_upload: true`
- `submit_for_review: true`
- `automatic_release: true`

## Ключевые файлы

- `brainy-app/ios/fastlane/metadata/en-US/` — EN metadata
- `brainy-app/ios/fastlane/metadata/ru/` — RU metadata
- `brainy-app/ios/fastlane/metadata/review_information/`
- `brainy-app/ios/fastlane/screenshots/`
- `brainy-app/scripts/compose_screenshots.py`
