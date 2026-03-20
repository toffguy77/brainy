---
title: CI/CD
tags: [ci, cd, github-actions, testflight, fastlane, deploy, certificate]
---

# CI/CD

## Обзор

Автоматизированный деплой iOS-приложения в TestFlight и отправка на App Store Review через GitHub Actions + Fastlane. Android CI пока не настроен.

## Workflows

### deploy-ios.yml — Deploy to TestFlight

Триггер: push тега `v*` (например `v1.0.0`).

Runner: `macos-15`, timeout 30 мин.

Шаги:
1. Checkout кода
2. Select Xcode 26.3
3. Setup Flutter (stable channel, cached)
4. `flutter pub get`
5. Setup Ruby 3.2 + bundler cache
6. Install CocoaPods + `pod install`
7. Decode distribution certificate (P12 из secrets, base64)
8. Decode provisioning profile (mobileprovision из secrets, base64)
9. Fastlane `deploy_testflight`
10. Cleanup secrets (always)

Файл: `.github/workflows/deploy-ios.yml`

### submit-review.yml — Submit to App Store Review

Триггер: `workflow_dispatch` (ручной запуск).

Runner: `macos-15`, timeout 15 мин.

Шаги:
1. Checkout
2. Setup Ruby 3.2
3. Fastlane `submit_review`

Файл: `.github/workflows/submit-review.yml`

## Fastlane

Файл: `brainy-app/ios/fastlane/Fastfile`

### Lane: deploy_testflight

1. `setup_ci` — настройка CI-окружения
2. Установка App Store Connect API key (base64-encoded из env)
3. Import distribution certificate (P12 + password)
4. Install provisioning profile + extract UUID
5. `update_code_signing_settings` — переключение на manual signing:
   - Team ID: `3GWRDGA8B7`
   - Bundle ID: `com.brainyapp.brainy`
   - Identity: `Apple Distribution`
6. `flutter build ios --release --no-codesign` с dart-define для REVENUECAT_API_KEY
7. `build_app` — archive + export IPA (app-store method)
8. `upload_to_testflight` — загрузка, skip_waiting, не distribute_external

### Lane: submit_review

1. App Store Connect API key
2. `deliver` с параметрами:
   - submit_for_review: true
   - automatic_release: true
   - skip_binary_upload: true (использует уже загруженный билд)
   - overwrite_screenshots: true

## Secrets (GitHub)

| Secret | Описание |
|--------|----------|
| APP_STORE_CONNECT_API_KEY | Base64-encoded .p8 key |
| APP_STORE_CONNECT_KEY_ID | Key ID из App Store Connect |
| APP_STORE_CONNECT_ISSUER_ID | Issuer ID |
| DISTRIBUTION_CERTIFICATE_P12 | Base64-encoded .p12 certificate |
| DISTRIBUTION_CERTIFICATE_PASSWORD | Password для P12 |
| PROVISIONING_PROFILE | Base64-encoded .mobileprovision |
| REVENUECAT_API_KEY | RevenueCat API key (передаётся как dart-define) |

## Fastlane Metadata

Структура `brainy-app/ios/fastlane/metadata/`:
- `en-US/` — английские метаданные
- `ru/` — русские метаданные
- `review_information/` — информация для review

Используется lane `submit_review` для автоматической загрузки метаданных и скриншотов.

## Скриншоты

Директория: `brainy-app/ios/fastlane/screenshots/`

Скрипт композиции: `brainy-app/scripts/compose_screenshots.py`

## Ключевые файлы

- `.github/workflows/deploy-ios.yml`
- `.github/workflows/submit-review.yml`
- `brainy-app/ios/fastlane/Fastfile`
- `brainy-app/ios/fastlane/Appfile`
