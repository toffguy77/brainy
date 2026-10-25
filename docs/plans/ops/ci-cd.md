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

Триггер: `pull_request` (любая ветка) и `push` в `main`.

Runner: `ubuntu-latest`, timeout 20 мин. macOS не нужен — ни анализ, ни юнит-тесты не требуют Xcode.

Шаги: checkout -> setup Flutter (stable, cached) -> `flutter pub get` -> `flutter analyze --fatal-infos`
-> `flutter test`.

`--fatal-infos` намеренно: баг в `ShareCard` (карточка никогда не показывала рекорд 5x5) выдавался
анализатором только как info. Гейт, игнорирующий info, пропустил бы его.

`concurrency` с `cancel-in-progress` отменяет прогон, если в ту же ветку пришёл новый коммит.

### deploy-testflight.yml — деплой в TestFlight

Триггер: `push` в `main` с фильтром путей (`brainy-app/lib/**`, `pubspec.yaml`, `pubspec.lock`,
`ios/**`, `l10n/**`, `assets/**`) — изменения только в документации сборку не запускают.

Runner: `macos-15`, timeout 30 мин. Xcode 26.3.

Шаги: checkout -> Xcode -> Flutter -> `pub get` -> Ruby 3.2 + bundler -> CocoaPods + `pod install`
-> декодирование сертификата и provisioning profile из secrets -> fastlane `deploy_testflight`
-> очистка секретов (`always`).

### release.yml — релиз в App Store

Триггер: `push` тега `v*`.

Runner: `macos-15`, timeout 60 мин.

Сборка и загрузка в TestFlight с ожиданием обработки Apple, затем обновление метаданных и отправка
на review через App Store Connect API.

### monitor.yml — статус review

Триггер: `schedule` (ежедневно в 9:00 UTC) и `workflow_dispatch`.

Runner: `ubuntu-latest`, timeout 5 мин. Проверяет статус review через App Store Connect API
(JWT-авторизация) и заводит GitHub Issue при изменении статуса.

## Fastlane

Файл: `brainy-app/ios/fastlane/Fastfile`.

### Lane: deploy_testflight

`setup_ci` -> установка App Store Connect API key -> импорт distribution certificate -> установка
provisioning profile и извлечение UUID -> `update_code_signing_settings` (manual signing, Team ID
`3GWRDGA8B7`, Bundle ID `com.brainyapp.brainy`, Apple Distribution) -> `flutter build ios --release
--no-codesign` -> `build_app` (app-store) -> `upload_to_testflight`.

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
- `brainy-app/ios/fastlane/Fastfile`
- `brainy-app/ios/fastlane/Appfile`
