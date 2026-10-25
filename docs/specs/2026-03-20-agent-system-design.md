---
title: Система агентов для разработки Brainy
tags: [agents, ci-cd, skills, github-actions, automation, workflow]
date: 2026-03-20
---

# Система агентов для разработки Brainy

## Проблемы

1. **Качество** — нет автоматического code review, проверки на соответствие планам, регрессии ловятся вручную
2. **Автономность** — каждая фича требует микроменеджмента: агент не задаёт уточняющие вопросы сам, не проверяет билд, не обновляет документацию
3. **Операции** — CI/CD, App Store submissions, скриншоты, мониторинг — всё делается вручную через длинные сессии

## Решение

Два слоя агентов: CLI (Claude Code Skills) для локальной разработки и GitHub Actions для удалённой автоматизации.

---

## Архитектура

```
CLI (локально, Claude Code Skills):
├── /feature    — полный цикл фичи с чекпоинтами
├── /deploy     — bump версии + tag → CI подхватывает
├── /appstore   — metadata + screenshots + App Store submit
└── /review     — ручной code review текущего diff

GitHub Actions (удалённо):
├── deploy-testflight.yml   — push main → подпись → TestFlight
├── release.yml             — tag v* → build + TestFlight + App Store submit
└── monitor.yml             — daily cron → Apple review status → Issue
```

### Принцип разделения

- **Локально:** всё что можно проверить без CI-среды — code review, тесты, билд, линтинг
- **GitHub Actions:** только то, что требует подписи, секретов или cron — деплой, релиз, мониторинг

---

## Планы как source of truth

### Структура

```
docs/plans/
├── features/                     # Живая документация поведения приложения
│   ├── game-modes.md
│   ├── character-system.md
│   ├── progress-tracking.md
│   ├── parent-panel.md
│   ├── subscription.md
│   ├── leaderboards.md
│   ├── notifications.md
│   ├── localization.md
│   └── onboarding.md
└── ops/                          # Операционные процессы
    ├── ci-cd.md
    └── appstore-metadata.md
```

### Формат плана

Каждый файл начинается с YAML frontmatter:

```yaml
---
title: Игровые режимы
tags: [game, schulte, gorbov, grid, classic, modes]
---
```

Теги — короткие, на английском. Агент ищет релевантные планы через grep по тегам в frontmatter.

### Поиск релевантных планов

1. **Основной поиск** — grep по тегам в YAML frontmatter
2. **Fallback** — если по тегам ничего не найдено, поиск по содержимому файлов и именам файлов
3. **Если ноль результатов** — агент предупреждает пользователя и спрашивает, продолжать ли без контекста планов

### Правила работы с планами

1. **Перед реализацией** — агент грепает теги → читает релевантные планы → понимает текущее поведение
2. **После реализации** — если поведение изменилось, агент обновляет затронутые планы в том же коммите
3. **Планы = факт** — описывают как приложение работает сейчас, а не как планировалось

### Первичная генерация

Источники для начального наполнения `docs/plans/`:

1. `brainy-tasks/MASTER_CONTEXT.md` + `TASK_*.md` — спецификации фич
2. `~/.claude/plans/*.md` — планы из прошлых Claude Code сессий
3. `brainy-app/lib/` — код как источник истины (что реально работает)

После генерации `brainy-tasks/` становится архивом.

---

## CLI Skills

### `/feature "описание"`

Полный цикл разработки фичи с двумя чекпоинтами:

```
/feature "описание"
    │
    ├── 1. Поиск планов (grep по тегам)
    ├── 2. Уточняющие вопросы (по одной)
    ├── 3. Показать план изменений (код + какие планы обновятся)
    │       ✋ ЧЕКПОИНТ 1: одобрение плана
    │
    ├── 4. Реализация (код + тесты + локализация)
    ├── 5. Обновление затронутых планов в docs/plans/
    ├── 6. flutter test + flutter analyze
    ├── 7. flutter build ios --no-codesign
    │       ✋ ЧЕКПОИНТ 2: результаты + diff → ждёт одобрения
    │
    ├── 8. Коммит + push        ← только после явного "ок" от пользователя
    └── 9. Создать PR
```

**Между чекпоинтами агент работает автономно.** Если тесты/билд падают — агент чинит сам. К пользователю приходит только зелёный результат.

### `/deploy`

1. Проверить что ветка чистая, тесты проходят
2. Bump build number в `pubspec.yaml` (+1 к числу после `+`, например `1.1.0+15` → `1.1.0+16`). Version string (`1.1.0`) не трогается — задаётся разработчиком вручную
3. Коммит + tag `v{version}` + push
4. GitHub Actions подхватывает → TestFlight

### `/appstore`

1. Обновить метаданные в `brainy-app/ios/fastlane/metadata/`
2. Обновить скриншоты если нужно
3. Запустить `fastlane submit_review`
4. Проверить статус Game Center leaderboards через API. Если есть незаапрувленные — напомнить пользователю (Game Center нельзя полностью автоматизировать через API, может потребоваться ручное действие в App Store Connect)

### `/review`

1. Прочитать `git diff` (staged + unstaged)
2. Grep теги из изменённых файлов → прочитать релевантные планы
3. Проверить:
   - Код соответствует планам
   - Планы обновлены если поведение изменилось
   - Тесты покрывают изменения
   - Локализация обновлена
   - Нет magic strings, хардкода
4. Выдать замечания или одобрить

---

## GitHub Actions Workflows

### `deploy-testflight.yml`

- **Триггер:** `push: branches: [main]`
- **Действия:** flutter build iOS → подпись → upload TestFlight
- **Секреты:** DISTRIBUTION_CERTIFICATE_P12, PROVISIONING_PROFILE, APP_STORE_CONNECT_API_KEY, etc.
- **Основа:** текущий `deploy-ios.yml`, триггер меняется с tag на push в main

### `release.yml`

- **Триггер:** `push: tags: [v*]`
- **Действия:**
  1. Build iOS → подпись → TestFlight (используя `upload_to_testflight(wait_for_uploaded_build: true)` для ожидания обработки Apple, таймаут 30 мин)
  2. Обновить metadata через Fastlane deliver
  3. Submit for review через App Store Connect API
- **Секреты:** те же + APP_STORE_CONNECT credentials

### Миграция с `deploy-ios.yml`

Порядок перехода (нельзя нарушать):
1. Создать `release.yml` с триггером `tags: [v*]` и проверить на тестовом теге
2. Создать `deploy-testflight.yml` с триггером `push: main`
3. Удалить старый `deploy-ios.yml`

### `monitor.yml`

- **Триггер:** `schedule: cron '0 9 * * *'` (ежедневно в 9:00 UTC)
- **Действия:**
  1. Проверить статус Apple review через App Store Connect API (JWT auth через service account)
  2. Если статус изменился (approved/rejected) → создать GitHub Issue с деталями
- **Секреты:** APP_STORE_CONNECT_API_KEY, APP_STORE_CONNECT_KEY_ID, APP_STORE_CONNECT_ISSUER_ID

Crashlytics мониторинг не включён — нет публичного API для crash-free rate. Для крашей использовать Firebase Console Alerts → email.

---

## CLAUDE.md обновления

Добавить в корневой CLAUDE.md (или создать если нет):

```markdown
## Планы

- `docs/plans/features/` — живая документация поведения приложения
- Перед реализацией — прочитать релевантные планы (grep по тегам в frontmatter)
- После реализации — обновить затронутые планы в том же коммите
- Формат: YAML frontmatter с title и tags

## Skills

- `/feature` — полный цикл фичи с чекпоинтами
- `/deploy` — bump + tag для деплоя
- `/appstore` — App Store metadata + submission
- `/review` — code review текущих изменений
```

---

## План реализации (порядок)

1. **Создать `docs/plans/`** — первичная генерация feature-планов из существующих источников
2. **Написать CLI skills** — `/feature`, `/deploy`, `/appstore`, `/review`
3. **Обновить GitHub Actions** — deploy-testflight, release, monitor workflows
4. **Обновить CLAUDE.md** — правила работы с планами и skills

---

## Что НЕ входит

- Оркестратор/координатор агентов (overengineering для соло-проекта)
- Автоматическое создание PR без одобрения (чекпоинт 2 обязателен)
- Slack/Telegram нотификации (GitHub Issues достаточно)
- Автоматический merge (только ручной approve + merge)
- Crashlytics мониторинг через API (нет публичного API, используем Firebase Alerts → email)
- Полная автоматизация Game Center submissions (API ограничен, агент проверяет статус и напоминает)
