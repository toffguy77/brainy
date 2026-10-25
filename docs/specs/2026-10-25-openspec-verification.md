---
title: Сверка openspec changes с кодом — находки и решения
tags: [audit, openspec, backlog, verification]
date: 2026-10-25
---

# Сверка openspec changes с кодом (2026-10-25)

Каждый из 16 changes в `openspec/changes/` проверен отдельным агентом: proposal, design, specs и
tasks сравнивались с фактическим кодом. Ниже — сводка находок и принятые решения. Статус
выполнения отражается в `tasks.md` каждого change.

## Решения владельца

- Приложение полностью бесплатное; RevenueCat, YooKassa, Cloud Functions не нужны.
- Только iOS; `brainy-app/android/` — неиспользуемая заготовка Flutter.
- Аналитика не собирается; лимит времени сессии удалён.
- Аксессуары рисуются поверх аватара иконками (без отдельного арта).
- `dailyGoalMinutes` из онбординга показывается как прогресс дневной цели.
- Адаптивная сложность реализуется (подсказка следующего размера в пределах режима).
- Статистика (прогресс, родительская панель) получает переключатель режима.

## Баги в приложении

| # | Где | Проблема |
|---|-----|----------|
| 1 | `records_provider.dart` | Рекорды reverse/letters не загружаются после перезапуска → каждый результат «рекорд», +25 монет, худшее время перезаписывает лучшее |
| 2 | `home_screen.dart` | Фиксированный родителем размер не ограничивается режимом → letters 6×6+ падает с `ArgumentError`, gorbov 3×3/4×4 запускается |
| 3 | `game_header.dart` | Бейдж «следующая цель» показывает ординал: reverse — «1» вместо N², letters — «1» вместо буквы |
| 4 | `game_screen.dart` | Рекорды всех режимов отправляются в лидерборды classic |
| 5 | `notification_service.dart` | Локаль не передаётся — все напоминания на английском |
| 6 | `game_screen.dart`, `game_header.dart` | Захардкожены «Найдено», «Найди», «сек» — английская локаль видит русский |
| 7 | `user_progress_provider.dart` | Pixel, Glitch, Zap никогда не разблокируются (`checkUnlockEligibility` не вызывается) |
| 8 | `user_progress_provider.dart` | Достижения streak_7/streak_30 не показываются как новые на экране результата |
| 9 | `parent_pin_screen.dart` | Блокировка PIN сбрасывается при выходе с экрана / перезапуске |
| 10 | `parent_settings_screen.dart` | Включение уведомлений не запрашивает разрешение — тумблер может ничего не делать |
| 11 | `league_provider.dart` | Игрок с кастомным именем дублируется в реальной таблице |
| 12 | `game_provider.dart` | Таймеры не отменяются при dispose; штраф и монеты захардкожены вместо констант |
| 13 | `share_card.dart` | Нет обработки ошибок, неверный якорь на iPad, единица «s» не локализована |
| 14 | `home_screen.dart` | Выбранный режим не сохраняется между экранами |

## Незавершённая функциональность

- Аксессуары не отображаются на персонаже; `assetPath` указывает на несуществующие файлы;
  владение глобальное (поле `CharacterData.unlockedAccessories` мёртвое).
- Подсказки режимов `gameModeReverseHint` / `gameModeLettersHint` не используются.
- Адаптивная сложность описана, но не реализована.
- Статистика показывает только classic.
- `dailyGoalMinutes` нигде не используется.
- Ссылки на политику конфиденциальности и условия есть в константах, но не в UI (`url_launcher` не используется).

## Инфраструктура и гигиена

- `REVENUECAT_API_KEY` всё ещё в `Fastfile` (2 лейна) и в `deploy-testflight.yml`, `release.yml`.
- `ios/Runner/Products.storekit` с подписками Brainy Pro и ссылка на него в схеме.
- `review_information/notes.txt` говорит о «premium Coming soon».
- Деплой и релиз не зависят от CI; нет `permissions`; `cancel-in-progress` отменяет прогоны на main;
  таймаут 20 мин против бюджета 10; Flutter не закреплён; нет gitleaks и проверки паритета ARB.
- Мёртвый код: `firebase_service.dart`, `brainy_button.dart`, `brainy_card.dart`,
  `app_text_styles.dart`, `HapticService.purchase`, неиспользуемые ARB-ключи и константы.
- `assets/animations/` объявлена, но пуста; `firebase.json` / `firestore.*` без потребителя.
- `GoogleService-Info.plist`: `IS_ANALYTICS_ENABLED=true`.

## Тесты

- Тап-логика classic/reverse/letters живёт в приватных методах `GameNotifier` и не покрыта.
- Сохранение сессии и рекордов живёт в виджете `GameScreen` — не тестируемо.
- Решения о расписании уведомлений смешаны с платформенными вызовами.
- Условия достижений и блокировка PIN не покрыты; тест `ShareCard` не проверяет продакшн-путь.

## Требует внешних действий

- Отозвать ключ RevenueCat в дашборде; удалить секрет `REVENUECAT_API_KEY` в GitHub.
- Branch protection: required check «Flutter analyze + test» на `main`.
- Закрыть dependabot PR для удалённой `functions/`.
- App Store Connect: убрать подписки/IAP, категорию Analytics в privacy labels.
- Firebase: отключить Google Analytics в проекте.
- Ручные прогоны на устройстве: режимы, магазин, карточка «Поделиться», уведомления в обеих локалях.
