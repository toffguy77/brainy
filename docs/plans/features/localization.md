---
title: Локализация
tags: [l10n, i18n, russian, english, arb, intl]
---

# Локализация

## Обзор

Приложение локализовано на два языка с первой версии: русский (основной рынок) и английский (международный). Используется `flutter_intl` с ARB-файлами.

## Технический стек

- Формат: ARB (Application Resource Bundle)
- Генератор: `flutter_intl` (intl package)
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
- Некоторые строки в paywall используют locale-based выбор напрямую (`Localizations.localeOf(context).languageCode == 'ru'`) — это отступление от стандартного подхода через ARB

## Области локализации

- Онбординг (7 экранов): приветствие, Шульте инфо, наука, возраст, цели, частота, paywall
- Игра: подсказки, таймер, результаты, звёзды
- Горбов-Шульте: режим тогл, подсказки цвета
- Персонажи: имена, описания, условия разблокировки (дублированы в CharacterInfo)
- Прогресс: достижения, статистика, графики
- Родитель: PIN, дашборд, настройки
- Лига: тиры, подключение Game Center
- Подписка: paywall, premium gate, bottom sheet
- Уведомления: 7+7 вариантов текста в NotificationService (хардкод, не через ARB)

## Особенности

- Имена персонажей хранятся и в ARB, и в `CharacterInfo.nameRu/nameEn` — дублирование
- Тексты уведомлений хардкодированы прямо в `NotificationService` (не через ARB), с выбором по locale-параметру
- Legal URLs различаются по языку: `privacyPolicyUrlRu` / `privacyPolicyUrlEn`

## Ключевые файлы

- `brainy-app/l10n/app_ru.arb`
- `brainy-app/l10n/app_en.arb`
- `brainy-app/lib/l10n/app_localizations.dart`
