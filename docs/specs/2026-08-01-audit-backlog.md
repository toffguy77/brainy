---
title: Ревизия кода, документации и спецификаций — план доделок
tags: [audit, backlog, tech-debt, ci, security, docs-drift]
date: 2026-08-01
---

# Ревизия Brainy — план доделок и улучшений

Дата: 2026-08-01. Ветка: `main` @ `1253576`.

Проверено: `flutter analyze`, `flutter test` (полный прогон), `npm test` + `npm audit` в `functions/`,
сверка всех 11 планов в `docs/plans/` и `CLAUDE.md` с фактическим кодом, конфиги CI/CD, Firebase, git-состояние.

## Сводка состояния

| Проверка | Было | Стало |
|----------|------|-------|
| `flutter analyze` | ❌ 11 errors + 3 info | ✅ No issues found |
| `flutter test` (кроме league) | ❌ не компилировалось | ✅ 118 passed |
| `flutter test` — `league_screen_test.dart` | ❌ 2 теста висят по 10 мин | ⚠️ по отдельности все зелёные, вместе — дедлок (см. п.4) |
| `functions` — `npm test` | ✅ 33/33 passed | ✅ без изменений |
| `functions` — `npm audit` | ⚠️ 23 уязвимости (2 critical, 6 high) | ⚠️ не трогал |
| ARB ru/en синхронизация | ✅ 244/244 ключа | ✅ без изменений |
| CI прогоняет тесты/линт | ❌ нет вообще | ✅ добавлен `.github/workflows/ci.yml` |
| Секреты в репозитории | ❌ 2 проблемы | 🟡 файлы убраны и закрыты в `.gitignore`; ключ RevenueCat остаётся в истории git — нужен ручной отзыв |
| Планы соответствуют коду | ❌ 8 расхождений | ❌ не трогал (п.10–17) |

---

## P0 — Блокеры (чинить первыми)

### 1. Продакшн-ключ RevenueCat закоммичен в git

`brainy-app/docs/setup/revenue_cat/credentials.md` содержит `API_KEY=<...>` и лежит в истории git.

**Доделать:**
- Отозвать/перевыпустить ключ в дашборде RevenueCat (ключ скомпрометирован фактом попадания в историю).
- Удалить файл из рабочего дерева и вычистить из истории (`git filter-repo` / BFG), либо, если история переписываться не будет — считать ключ мёртвым и просто удалить файл.
- Вся папка `brainy-app/docs/setup/revenue_cat/` бесполезна: RevenueCat выпилен, а `initialize.dart` оттуда ещё и ломает `flutter analyze` (см. п.3). Удалить целиком.

### 2. Папка `secrets/` не в `.gitignore`

В `secrets/` лежат `Certificates.p12`, `AuthKey_Q2Q32CN7T9.p8`, `SubscriptionKey_WH6Q4W9JG2.p8`,
`Github_Actions.mobileprovision`, `distribution.cer`. Сейчас они **untracked, но не игнорируются** —
любой `git add .` их закоммитит.

В `.gitignore` (незакоммиченное изменение) добавлено `.secrets/` — с точкой, а папка называется `secrets/`. Правило не срабатывает.

**Доделать:** заменить `.secrets/` на паттерны, покрывающие реальные файлы:
```
secrets/
*.p12
*.p8
*.mobileprovision
*.cer
```

### 3. `flutter analyze` красный — 11 ошибок компиляции

| Файл | Проблема |
|------|----------|
| `brainy-app/docs/setup/revenue_cat/initialize.dart` | 3 ошибки: импорт удалённого `purchases_flutter` |
| `integration_test/screenshot_test.dart` | 4 ошибки: `purchases_flutter`, `AppConstants.revenueCatApiKey` |
| `test/constants/app_constants_test.dart` | 4 ошибки: `productIdMonthly/Yearly/Family`, `revenueCatEntitlement` — константы закомментированы в `app_constants.dart` |

Всё — хвосты миграции RevenueCat → YooKassa (`3b9684a`), которую не довели до конца.

**Доделать:** удалить `docs/setup/revenue_cat/`, вычистить RevenueCat из `integration_test/screenshot_test.dart`,
удалить/переписать RevenueCat-блок в `test/constants/app_constants_test.dart`.

### 4. `flutter test` красный, прогон 20 минут

```
Failing tests:
  test/constants/app_constants_test.dart          — не компилируется (см. п.3)
  test/home/mode_toggle_test.dart                 — не компилируется в общем прогоне
                                                     (изолированно проходит: 4/4)
  test/features/league/league_screen_test.dart:
    "edit name dialog cancel does not save"       — TimeoutException 10:00
    "shows loading state"                         — TimeoutException 10:00
```

Оба теста добавлены в `681dd86` («feat: allow player to edit display name in league screen») — фича уехала в main с красными тестами, потому что CI их не гоняет (см. п.5).

**Статус: частично.** `app_constants_test.dart` и `mode_toggle_test.dart` починены (см. п.3),
весь набор кроме league-файла зелёный — 118 passed. Дедлок в `league_screen_test.dart` остался.

Что установлено экспериментально:
- **Каждый** тест файла проходит в изоляции (`--plain-name`) за доли секунды.
- Начиная с 7-го теста подряд изолят намертво встаёт: `--timeout 45s` не срабатывает,
  а сам runner падает с `Bad state: Cannot close sink while adding stream`
  (`flutter_tools/src/test/flutter_platform.dart:766`) — то есть виснет уровень харнесса, не тело теста.
- Триггер — повторное открытие диалога с `autofocus: true` в одном файле: автофокус открывает
  platform text-input соединение, которое утекает между тестами.

Что уже сделано и **не** помогло снять дедлок (но исправлено как самостоятельные дефекты — см. п.6a–6c):
диспоуз `TextEditingController`, `await` на записи в Hive, снятие фокуса и замена `pumpAndSettle`
на ограниченные `pump` в тестах.

**Доделать:** вынести три диалоговых теста в отдельный файл (обходит утечку между тестами,
но это workaround) либо избавиться от `autofocus: true` в диалоге и проверить, снимется ли дедлок.
До этого момента `flutter test` целиком остаётся красным, и CI из п.5 будет падать.

### 5. CI не гоняет ни тесты, ни линт

`deploy-testflight.yml` триггерится на `push: main` и сразу собирает и заливает в TestFlight.
Ни `flutter test`, ни `flutter analyze`, ни `npm test` в `functions/` нигде в `.github/workflows/` нет.

Это корневая причина того, что п.3 и п.4 вообще доехали до main.

**Доделать:** добавить workflow `ci.yml` (`pull_request` + `push: main`): `flutter analyze` →
`flutter test` → `cd functions && npm ci && npm test`. Сделать его required-гейтом для деплоя.
Прогон тестов не должен занимать 20 минут — сначала п.4.

---

## P1 — Реальные баги в приложении

### 6. `ShareCard` всегда шарит пустой результат 5x5

`brainy-app/lib/features/parent/widgets/share_card.dart:39`:
```dart
best5x5: records[5],   // records — Map<String, int>, ключи вида "classic_5"
```
Индексация `Map<String,int>` по `int` всегда даёт `null`. `flutter analyze` ловит это как info
(`collection_methods_unrelated_type`), но это функциональный баг: карточка для соцсетей
(документирована в `parent-panel.md`) никогда не показывает лучший результат.

**Статус: исправлено** — `records[recordKey('classic', 5)]`. Тест на `ShareCard` ещё не написан (п.25).

### 6a. `TextEditingController` в диалоге переименования не диспозился

`_showEditNameDialog` создавал контроллер в замыкании и никогда его не освобождал.
**Статус: исправлено** — диалог вынесен в `_EditNameDialog` (StatefulWidget), контроллер освобождается в `dispose()`.

### 6b. Запись имени игрока в Hive не дожидалась завершения

`box.put(customPlayerNameKey, newName)` вызывался без `await` — гонка со следующим чтением.
**Статус: исправлено** — `await box.put(...)`, `Navigator` захватывается до `await`.

### 7. Настройка «Максимальное время сессии» ничего не делает

`parentMaxSessionTimeKey` / `maxSessionTimeMinutes` читается и пишется только внутри
`parent_provider.dart`. В `game_screen.dart` и `game_provider.dart` — ни одной ссылки.
Родитель выставляет лимит 5/10/15 минут, игра его игнорирует.

При этом `parent-panel.md` описывает настройку как работающую.

**Доделать:** либо реализовать лимит в `GameNotifier` (авто-завершение сессии по достижении лимита),
либо убрать настройку из UI и из плана. Решить, что нужно продукту.

### 8. Analytics не реализован

`brainy-app/lib/shared/services/analytics_service.dart` — файл из одной строки-комментария
«will be implemented when Firebase is configured». Ни одного `logEvent` во всём `lib/`.

При этом Firebase Analytics подключён в `pubspec.yaml`, а в App Store Privacy Nutrition Labels
(`docs/plans/ops/appstore-metadata.md`) заявлен сбор Analytics.

**Доделать:** либо реализовать базовый набор событий (`session_completed`, `record_set`,
`paywall_shown`, `paywall_cta_tapped`, `onboarding_completed`, `achievement_unlocked`),
либо удалить сервис и зависимость и привести Privacy Labels в соответствие. Без событий
нет данных для решений по монетизации.

### 9. Мёртвый код: `ParentScreen`

`brainy-app/lib/features/parent/screens/parent_screen.dart` нигде не импортируется, нет в роутере.
Плюс содержит единственный в проекте захардкоженный русский текст `Text('Родитель')` —
нарушение правила «все строки локализованы».

**Доделать:** удалить файл.

---

## P2 — Расхождения документации и кода

Планы объявлены source of truth, но по 8 пунктам описывают не то, что в коде.

| # | Документ | Написано | На самом деле |
|---|----------|----------|---------------|
| 10 | `CLAUDE.md`, `subscription.md` | YooKassa «на ветке `feat/yookassa-payment`, не задеплоен» | Ветки не существует. Код в `functions/src/` на `main`, тесты 33/33 зелёные |
| 11 | `CLAUDE.md` | «Firestore (cloud): leaderboard scores via `league` feature» | В `lib/` нет ни `cloud_firestore`, ни `FirebaseFirestore`. Лидерборды — Game Center. Firestore используется только Cloud Functions для подписок |
| 12 | `CLAUDE.md` | `dart run build_runner build` для Riverpod-провайдеров | Ни одного `@riverpod`, ни одного `.g.dart`. Кодогенерация не используется |
| 13 | `docs/plans/ops/ci-cd.md` | workflows `deploy-ios.yml`, `submit-review.yml`; триггер по тегу `v*` | Реально: `deploy-testflight.yml` (push в main), `release.yml` (tag `v*`), `monitor.yml` (cron). Весь раздел описывает предыдущую итерацию |
| 14 | `progress-tracking.md` | Достижения: `triple_record`, `fast_3x3`, `collector_10`, `no_mistakes` | В `models/achievement.dart`: `speedDemon`, `focusMode`, `nightOwl`, `coinHoarder`. 4 из 10 названы неверно |
| 15 | `leaderboards.md` | ID лидербордов `weekly_xp`, `best_time_3x3` | В `game_services_service.dart`: `brainy_weekly_xp`, `brainy_best_time_{N}x{N}` |
| 16 | `character-system.md` | «персонажи отображаются как SVG-аватары» | PNG: `assets/characters/*.png` |
| 17 | `subscription.md` | Ссылка на `brainy-tasks/TASK_10_1_yookassa.md` (в комментарии `subscription_service.dart`) | `brainy-tasks/` удалён в `86b860f`. Ссылка мёртвая |

**Доделать:** пройтись по всем 8, привести планы и `CLAUDE.md` к фактическому коду.
`ci-cd.md` фактически переписать заново.

Отдельно: `docs/specs/2026-03-20-agent-system-design.md` untracked — спека, по которой построена
вся система агентов, не в git. Закоммитить.

---

## P3 — Гигиена и зависимости

### 18. Уязвимости в `functions/`

`npm audit --omit=dev`: 23 уязвимости, 2 critical (`websocket-driver`), 6 high.
Плюс висит незамёрженный dependabot PR: `fast-xml-parser 5.5.6 → 5.5.7`.

**Доделать:** `npm audit fix`, прогнать тесты, замёржить dependabot PR. Актуально до деплоя
Cloud Functions, не после.

### 19. Неиспользуемые зависимости во Flutter

Ноль импортов в `lib/`, `test/`, `integration_test/`:
- `cloud_functions` — подключён под YooKassa, но `SubscriptionService` — заглушка
- `shared_preferences` — вытеснен Hive
- `collection`
- `riverpod_annotation`, `riverpod_generator`, `build_runner` — кодогенерация не используется (п.12)

**Доделать:** удалить неиспользуемые (`cloud_functions` оставить, если YooKassa включают в ближайшем релизе — тогда см. п.20).

### 20. `assets/animations/` объявлена в pubspec, но пуста

`pubspec.yaml:107` объявляет `assets/animations/`, директория пустая.
**Доделать:** удалить строку или наполнить.

### 21. Мусор в рабочем дереве

- `firebase-debug.log` — 1.3 МБ в корне (не tracked, покрыт `*.log` — ок, но удалить)
- `.DS_Store` в корне
- `brainy-app/ios/fastlane/report.xml`, `README.md` — untracked артефакты fastlane, добавить в `.gitignore`
- `brainy-app/screenshots/review_*.png` — 4 untracked скриншота, решить: коммитить или игнорировать

---

## P4 — Улучшения, которые планировались

### 22. ~~Довести YooKassa до продакшна~~ → Убрать монетизацию, выпустить всё бесплатно

**Решение изменено 2026-08-01:** приложение выпускается полностью бесплатным. Вместо доведения
платежей — удаление платного тира целиком. См. `openspec/changes/remove-monetization-go-free/`.
Это же снимает п.18 (23 уязвимости в `functions/` исчезают вместе с пакетом).

Ниже — исходный, более не актуальный план:



Backend готов и покрыт тестами. Не сделано:
- Задеплоить Cloud Functions (`firebase deploy --only functions`)
- Настроить YooKassa credentials (`yookassaClientKey`, `yookassaShopId` — сейчас пустые `String.fromEnvironment`)
- Раскомментировать клиентскую часть `subscription_service.dart` (сейчас там только комментарий-заглушка со ссылкой на несуществующую ветку — п.17)
- Убрать режим «Coming Soon» с paywall
- `firestore.rules` сейчас `allow read, write: if false` для всего. Cloud Functions ходят через Admin SDK
  и правила обходят, так что для подписок это работает — но правила нужно осознанно проверить перед запуском платежей.

### 23. Локализация: два отступления от ARB

Оба зафиксированы в `localization.md` как известные, но не исправлены:
- `paywall_screen.dart:142,195,204` — выбор языка через `Localizations.localeOf(context).languageCode == 'ru'` вместо ARB
- Тексты уведомлений (7+7 вариантов) захардкожены в `NotificationService`, не в ARB
- Имена персонажей дублируются в ARB и в `CharacterInfo.nameRu/nameEn`

### 24. Android не настроен

`docs/plans/ops/ci-cd.md`: «Android CI пока не настроен». `android/app/` содержит только
`build.gradle.kts` и `src`. Google Play Games в `leaderboards.md` описан, но пайплайна нет.
**Решить:** нужен ли Android в принципе — если нет, убрать упоминания из планов.

### 25. Покрытие тестами

Не покрыто вообще: `GameNotifier` (основной игровой цикл — есть только чистые функции Горбова),
`NotificationService.reschedule()` (нетривиальная логика с 3 ветками), `AchievementsProvider`
(условия 10 достижений), `ShareCard` (см. п.6), `parent_pin_screen` (лимит попыток, лок-аут 30 сек).

---

## Предлагаемый порядок

1. **Безопасность и красный билд** — п.1, 2, 3, 4, 5. Пока CI не гоняет тесты, любая следующая фича уедет в TestFlight сломанной.
2. **Баги** — п.6, 7, 8, 9.
3. **Синхронизация документации** — п.10–17. Быстро, но ценно: планы объявлены source of truth, а агенты читают их перед каждой фичей.
4. **Гигиена** — п.18–21.
5. **Продуктовое** — п.22 (YooKassa), 23, 24, 25.
