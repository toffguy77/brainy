---
title: CI/CD
tags: [ci, cd, github-actions, testflight, fastlane, deploy, certificate, monitor]
---

# CI/CD

## Обзор

Проверка, деплой в TestFlight и отправка на App Store Review через GitHub Actions + Fastlane.

Проект — только iOS (решение 2026-08-01). Каталог `brainy-app/android/` — неиспользуемый скаффолдинг
Flutter; сборок для него нет и не планируется.

## Workflows

Четыре файла в `.github/workflows/`.

### ci.yml — проверка

Триггер: `pull_request` (любая ветка), `push` в `main` и `workflow_call` — деплой и релиз вызывают
его как обязательный гейт.

Права: `contents: read`. Секретов не требует.

Job `flutter` («Flutter analyze + test» — это имя ставится required check в branch protection):
`ubuntu-latest`, timeout 10 мин. Шаги: checkout -> паритет ключей ARB ru/en (`jq` + `diff`) ->
setup Flutter (закреплён `3.47.6`, cached) -> `flutter pub get` -> `flutter analyze --fatal-infos`
-> `flutter test --timeout 60s --coverage` -> загрузка `lcov.info` артефактом (без порога).

Job `secrets-scan`: полная история (`fetch-depth: 0`), gitleaks 8.30.1 с конфигом `.gitleaks.toml`.
В allowlist — только публичные ключи Firebase (`firebase_options.dart`, `GoogleService-Info.plist`).

`--fatal-infos` намеренно: баг в `ShareCard` (карточка никогда не показывала рекорд 5x5) выдавался
анализатором только как info. Гейт, игнорирующий info, пропустил бы его.

`concurrency` группируется по `github.workflow` + ref: вызов из деплоя не отменяет самостоятельный
прогон CI. `cancel-in-progress` работает только вне `main` — каждый коммит в `main` проверяется до конца.

### deploy-testflight.yml — деплой в TestFlight

Триггер: `push` в `main` с фильтром путей (`brainy-app/lib/**`, `pubspec.yaml`, `pubspec.lock`,
`ios/**`, `l10n/**`, `assets/**`) — изменения только в документации сборку не запускают.

Runner: `macos-15`, timeout 30 мин. Xcode 26.3.

Job `verify` вызывает `ci.yml`; job `deploy` имеет `needs: verify`, поэтому красный коммит в
TestFlight не уходит.

Шаги: checkout -> Xcode -> Flutter (`3.47.6`) -> `pub get` -> Ruby 3.2 + bundler -> CocoaPods +
`pod install` -> декодирование сертификата и provisioning profile из secrets -> fastlane
`deploy_testflight` -> очистка секретов (`always`).

### release.yml — релиз в App Store

Триггер: `push` тега `v*`.

Runner: `macos-15`, timeout 60 мин.

Как и деплой, сначала `verify` (вызов `ci.yml`), затем `release` с `needs: verify`. Fastlane lane
`release`: сборка и загрузка в TestFlight с ожиданием обработки Apple, затем обновление метаданных
и отправка на review через App Store Connect API.

### monitor.yml — статус review

Триггер: `schedule` (ежедневно в 9:00 UTC) и `workflow_dispatch`.

Runner: `ubuntu-latest`, timeout 5 мин. Проверяет статус review через App Store Connect API
(JWT-авторизация) и заводит GitHub Issue, если статус — `REJECTED`, `METADATA_REJECTED`,
`DEVELOPER_REJECTED` или `READY_FOR_SALE` (дубликаты отсекаются поиском по метке `app-store`).
Права: `contents: read`, `issues: write`. Значения из API передаются в shell через `env`, не
интерполяцией.

## Fastlane

Файл: `brainy-app/ios/fastlane/Fastfile`.

### Lane: deploy_testflight

`setup_ci` -> установка App Store Connect API key -> импорт distribution certificate -> установка
provisioning profile и извлечение UUID -> `update_code_signing_settings` (manual signing, Team ID
`3GWRDGA8B7`, Bundle ID `com.brainyapp.brainy`, Apple Distribution) -> `flutter build ios --release
--no-codesign` -> `build_app` (app-store) -> `upload_to_testflight`.

### Lane: release

То же, что `deploy_testflight`, плюс ожидание обработки билда (`wait_for_uploaded_build`) и
`deliver` с `submit_for_review: true`. Вызывается из `release.yml`.

### Lane: submit_review

App Store Connect API key -> `deliver` с `submit_for_review: true`, `automatic_release: true`,
`skip_binary_upload: true`, `overwrite_screenshots: true`.

## Secrets (GitHub)

| Secret | Описание |
|--------|----------|
| APP_STORE_CONNECT_API_KEY | Base64-encoded .p8 key |
| APP_STORE_CONNECT_KEY_ID | Key ID из App Store Connect |
| APP_STORE_CONNECT_ISSUER_ID | Issuer ID |
| DISTRIBUTION_CERTIFICATE_P12 | Base64-encoded .p12 certificate |
| DISTRIBUTION_CERTIFICATE_PASSWORD | Password для P12 |
| PROVISIONING_PROFILE | Base64-encoded .mobileprovision |

`ci.yml` секретов не требует, поэтому PR из форков проверяются полностью.

## Локальные секреты

Каталог `secrets/` (P12, .p8, mobileprovision) — локальное удобство, не источник истины: CI читает
из GitHub Secrets. Каталог и все расширения подписи закрыты в `.gitignore`; правило проверяется
через `git check-ignore` по реальному пути, а не на глаз.

## Метаданные и скриншоты

Структура `brainy-app/ios/fastlane/metadata/`: `en-US/`, `ru/`, `review_information/`.
Скриншоты — `brainy-app/ios/fastlane/screenshots/`, скрипт композиции —
`brainy-app/scripts/compose_screenshots.py`.

## Ключевые файлы

- `.github/workflows/ci.yml`
- `.github/workflows/deploy-testflight.yml`
- `.github/workflows/release.yml`
- `.github/workflows/monitor.yml`
- `.gitleaks.toml`
- `brainy-app/ios/fastlane/Fastfile`
- `brainy-app/ios/fastlane/Appfile`
