# Задание 6.3 — Firebase Crashlytics & Analytics

> **Используй вместе с MASTER_CONTEXT.md**

---

## Цель

Подключить Firebase Crashlytics и Analytics для мониторинга крашей и базовой аналитики поведения пользователей в продакшене.

---

## Что реализовано

### 1. Firebase инициализация

- Создан `lib/firebase_options.dart` с конфигурацией iOS из `GoogleService-Info.plist`
- `Firebase.initializeApp()` вызывается в `main()` до всех остальных инициализаций

### 2. Crashlytics — перехват ошибок

- `FlutterError.onError` → `FirebaseCrashlytics.instance.recordFlutterFatalError` — ловит все синхронные Flutter-ошибки
- `runZonedGuarded` оборачивает весь `main()` — ловит все асинхронные ошибки и отправляет как fatal через `recordError()`
- Все краши и non-fatal ошибки автоматически отправляются в Firebase Console → Crashlytics

### 3. Analytics — отслеживание экранов

- `FirebaseAnalyticsObserver` добавлен в `GoRouter.observers` — автоматически логирует переходы между экранами
- `IS_ANALYTICS_ENABLED` включён в `GoogleService-Info.plist`

---

## Затронутые файлы

| Файл | Изменение |
|---|---|
| `lib/firebase_options.dart` | Создан — конфигурация Firebase для iOS |
| `lib/main.dart` | Firebase.initializeApp, runZonedGuarded, FlutterError.onError |
| `lib/app/router.dart` | FirebaseAnalyticsObserver в GoRouter |
| `ios/Runner/GoogleService-Info.plist` | IS_ANALYTICS_ENABLED → true |

---

## Возможные следующие шаги

- Добавить Android-конфигурацию (`google-services.json`, секция в `firebase_options.dart`)
- Кастомные аналитические события (начало/завершение игры, покупка подписки, выбор персонажа)
- Non-fatal логирование ошибок сети и парсинга данных
- Sentry как альтернатива/дополнение для более детального анализа
