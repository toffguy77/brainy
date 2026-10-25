---
title: Метаданные App Store
tags: [appstore, metadata, screenshots, keywords, description, review]
---

# Метаданные App Store

## Обзор

Метаданные для публикации в App Store Connect. Управляются через Fastlane deliver (директория `brainy-app/ios/fastlane/metadata/`). Два языка: русский и английский.

## Название и подзаголовок

Источник истины — файлы `metadata/<locale>/name.txt` и `subtitle.txt`. Формулировки «для детей /
for kids» убраны после отказа по guideline 2.3.8 (коммит `1253576`).

| Поле | RU | EN |
|------|----|----|
| Название | Brainy — тренажёр мозга | Brainy: Schulte Table Trainer |
| Подзаголовок | Тренажёр на таблицах Шульте | Schulte Table Brain Trainer |

## Ключевые слова (до 100 символов)

- **RU:** таблицы шульте,тренажер мозга,внимание,скорочтение,концентрация,развитие,память
- **EN:** schulte table,brain training,attention,speed reading,focus,concentration,cognitive,education,memory

## Категория и рейтинг

Категория и рейтинг задаются в App Store Connect, в `metadata/` файлов для них нет.

- Основная категория: Education
- Дополнительная: Games > Educational
- Возрастной рейтинг: 4+
- Bundle ID: `com.brainyapp.brainy`

## Скриншоты

Требуемые размеры:
- iPhone 6.7" (1290x2796) — обязательно
- iPhone 6.5" (1242x2688) — рекомендуется
- iPad 13" (2048x2732) — файлы `ipad-13_*`

Размеры заданы в `DEVICES` скрипта композиции; готовые файлы — `screenshots/<locale>/{6.7,6.5,ipad-13}_NN_<screen>.png`
(по 18 на язык).

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

Полный текст — `metadata/<locale>/description.txt`. Содержание: таблицы от 3×3 до 9×9; четыре
режима (классический, обратный, буквенный, Горбова-Шульте); уровни, достижения, коллекция
персонажей и магазин аксессуаров за монеты; стрики и дневная цель; адаптивная сложность;
статистика по режимам и панель родителя с PIN. Приложение полностью бесплатное: без встроенных
покупок, подписок и рекламы; работает офлайн.

## Privacy Nutrition Labels

Данные, собираемые приложением (только Firebase Crashlytics):
- Diagnostics → Crash Data
- Diagnostics → Other Diagnostic Data (метаданные устройства и ОС в отчётах о сбоях)
- Identifiers → Device ID (installation UUID Crashlytics)

Все — не связаны с личностью пользователя и не используются для трекинга. Сверять с таблицей
«Apple privacy details» в документации Firebase при обновлении SDK.

Analytics не собирается: Firebase Analytics удалён (решение 2026-08-01). В App Store Connect
категория Analytics должна быть снята с декларации.

## App Review Information

- Заметки для ревьюера — `metadata/review_information/notes.txt`: четыре режима, вход не нужен,
  работает офлайн, всё бесплатно (без IAP, подписок и рекламы), PIN родителя создаётся при первом входе.
- IDFA: не используется (add_id_info_uses_idfa: false)

## Что нового (текущий релиз)

Файлы `metadata/<locale>/release_notes.txt`: новые режимы обратный и буквенный; всё бесплатно;
дневная цель и адаптивная сложность; магазин аксессуаров; статистика по режимам.

## Fastlane deliver

Загрузка метаданных и скриншотов — `deliver` в lane `submit_review` (только метаданные) и в lane
`release` (после загрузки билда; версия и номер сборки берутся из `pubspec.yaml`). Общие параметры:
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
