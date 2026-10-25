---
title: Локализация
tags: [l10n, i18n, russian, english, arb, intl]
---

# Локализация

## Обзор

Приложение локализовано на два языка с первой версии: русский (основной рынок) и английский (международный). Используется встроенный генератор Flutter `gen_l10n` (`l10n.yaml`, `generate: true`) с ARB-файлами.

## Технический стек

- Формат: ARB (Application Resource Bundle)
- Генератор: `flutter gen-l10n` (конфиг `brainy-app/l10n.yaml`, шаблон — `app_ru.arb`)
- Доступ: `AppLocalizations.of(context)!`
- Автогенерация: `brainy-app/lib/l10n/app_localizations*.dart`

## Файлы

| Файл | Язык | Роль |
|------|------|------|
| `brainy-app/l10n/app_ru.arb` | Русский | Основной |
| `brainy-app/l10n/app_en.arb` | Английский | Перевод |

Генерируемые файлы:
- `brainy-app/lib/l10n/app_localizations.dart` — абстрактный класс
- `brainy-app/lib/l10n/app_localizations_ru.dart`
- `brainy-app/lib/l10n/app_localizations_en.dart`

## Правила

- Все пользовательские строки локализованы — никаких хардкодных текстов
- Параметризованные строки используют ICU syntax: `{count}`, `{size}`, `{number}`
- Ветвление по языку в коде (`Localizations.localeOf(context).languageCode == 'ru'`) запрещено —
  выбор перевода делает система локализации
- Пулы вариантов (например, тексты уведомлений) задаются нумерованными ключами в ARB; индекс
  выбирается в Dart. Количество вариантов должно совпадать во всех локалях — индекс вычисляется
  один раз и применяется к активной локали
- `NotificationService` получает локализации через `AppLocalizations.delegate.load()`, так как
  планирует уведомления вне дерева виджетов; язык — язык устройства через
  `AppConstants.resolveLanguage` (`ru` -> русский, любой другой -> английский)
- Приложение использует то же правило: `localeResolutionCallback` в `main.dart` даёт английский
  для языков, кроме русского и английского
- Числа со словами склоняются через ICU plural (`{days, plural, one{...} few{...} other{...}}`)
- Паритет ключей ru/en проверяется в CI (`ci.yml`, шаг «ARB key parity»)

## Области локализации

- Онбординг (6 экранов): приветствие, Шульте инфо, наука, возраст, цели, частота
- Игра: подсказки «Найди», прогресс «Найдено», таймер (`timeSec`/`timeMinSec`), правила режимов, результаты, звёзды
- Горбов-Шульте: режим тогл, подсказки цвета
- Персонажи и аксессуары: имена, описания, условия разблокировки — ключи `character{Id}Name/Description/Unlock`,
  `accessory{Id}Name`; `CharacterInfo.name(l10n)` / `AccessoryInfo.name(l10n)` выбирают ключ по id
- Прогресс: достижения, статистика, графики
- Родитель: PIN, дашборд, настройки
- Лига: тиры, подключение Game Center
- Уведомления: 7+7 вариантов текста в ARB (`notificationMotivation1..7`, `notificationStreak1..7`)

## Особенности

- Ссылки на политику конфиденциальности и условия использования — ARB-ключи `privacyPolicyUrl`,
  `termsUrl` (у каждого языка своя страница); открываются из родительских настроек через `url_launcher`
- Название приложения — `appName` (имя бренда, одинаковое в обеих локалях)
- Алфавит буквенного режима выбирается по языку (`AppConstants.alphabetFor`) — это данные игры, а
  не текст интерфейса
- Hive-модель `CharacterData` сохраняет устаревшие поля `nameRu/nameEn` ради совместимости
  формата; они не читаются

## Ключевые файлы

- `brainy-app/l10n/app_ru.arb`
- `brainy-app/l10n/app_en.arb`
- `brainy-app/lib/l10n/app_localizations.dart`
