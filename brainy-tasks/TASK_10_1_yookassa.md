# Задание 10.1 — Замена RevenueCat на YooKassa (РФ рынок)

> **Используй вместе с MASTER_CONTEXT.md**
> Заменяет задание 5.2 (RevenueCat) для российского рынка.

---

## Контекст

Apple заблокировала Paid Applications Agreement для аккаунтов из РФ. Пока ждём одобрения смены региона на Кыргызстан, реализуем оплату через YooKassa/СБП для проверки гипотезы о востребованности приложения на российском рынке.

RevenueCat **закомментирован** (не удалён), чтобы можно было вернуть позже.

---

## Архитектура

| Компонент | Технология |
|-----------|------------|
| Платёжный SDK | YooKassa (Flutter: `cloud_functions`, бэкенд: YooKassa REST API) |
| Бэкенд | Firebase Cloud Functions (TypeScript, Node 20) |
| БД подписок | Firestore (collections: `subscriptions`, `payments`) |
| User ID | Device ID (`identifierForVendor` iOS) + Keychain (`flutter_secure_storage`) |
| Кэш подписки | Hive (offline-first) |

### Платёжный поток

```
1. Пользователь → PaywallScreen → выбирает план (299₽/мес или 1990₽/год)
2. App → Cloud Function `createPayment` (deviceId + plan)
3. Cloud Function → YooKassa API POST /v3/payments (save_payment_method: true)
4. Если 3DS → App открывает confirmation_url
5. YooKassa → webhook → Cloud Function `yookassaWebhook`
6. Cloud Function → обновляет Firestore (subscriptions/{deviceId})
7. App → поллинг `checkSubscription` → кэширует в Hive
```

### Авто-продление

Cloud Function `renewSubscriptions` запускается ежедневно в 00:00 UTC, находит истекающие подписки и списывает через сохранённый `paymentMethodId`.

---

## Что сделано (Phase 1-5) ✅

### Ветка: `feat/yookassa-payment`

### Firebase Backend (новые файлы в корне репо)

| Файл | Описание |
|------|----------|
| `firebase.json` | Конфигурация Firebase проекта |
| `firestore.rules` | Deny all client access |
| `firestore.indexes.json` | Композитный индекс subscriptions (status + expiresAt) |
| `functions/package.json` | Node 20, firebase-admin, firebase-functions, axios |
| `functions/tsconfig.json` | TypeScript config |
| `functions/src/index.ts` | Ре-экспорт всех функций |
| `functions/src/createPayment.ts` | `onCall`: создаёт платёж через YooKassa API |
| `functions/src/yookassaWebhook.ts` | `onRequest`: обрабатывает webhook payment.succeeded/canceled |
| `functions/src/checkSubscription.ts` | `onCall`: возвращает {isPremium, plan, expiresAt} |
| `functions/src/renewSubscriptions.ts` | `onSchedule`: авто-продление подписок |

### Flutter (изменённые файлы в brainy-app/)

| Файл | Действие |
|------|----------|
| `pubspec.yaml` | Закомментированы `purchases_flutter`/`purchases_ui_flutter`, добавлены `cloud_functions: ^6.0.7`, `flutter_secure_storage`, `device_info_plus` |
| `lib/constants/app_constants.dart` | Закомментированы RevenueCat константы, добавлены YooKassa + RUB цены |
| `lib/shared/services/device_id_service.dart` | **НОВЫЙ** — Keychain → identifierForVendor → UUID v4 |
| `lib/shared/services/subscription_service.dart` | Полная перепись: Cloud Functions + Hive кэш. Старый код закомментирован |
| `lib/features/subscription/screens/paywall_screen.dart` | Хардкод RUB планы (299₽/мес, 1990₽/год), убран семейный план |
| `lib/features/onboarding/pages/paywall_page.dart` | Заменён `RevenueCatUI.presentPaywallIfNeeded` на навигацию к кастомному PaywallScreen |
| `.gitignore` | Добавлены `functions/node_modules/`, `functions/lib/` |

### Тесты ✅

| Набор | Кол-во | Фреймворк |
|-------|--------|-----------|
| createPayment | 10 | Jest |
| yookassaWebhook | 8 | Jest |
| checkSubscription | 5 | Jest |
| renewSubscriptions | 7 | Jest |
| DeviceIdService | 5 | flutter_test |
| SubscriptionService | 10 | flutter_test |
| PaywallScreen (widget) | 10 | flutter_test |
| PaywallPage (widget) | 6 | flutter_test |
| Subscription constants | 10 | flutter_test |
| **Итого** | **76** | **Все проходят** |

### Файлы БЕЗ изменений

home_screen, game_screen, character_screen, accessories_screen, progress_screen, parent_dashboard_screen, premium_bottom_sheet, main.dart, router.dart — все используют `isPremiumProvider`, который остался без изменений.

---

## Что НЕ сделано — дальнейшие шаги

### Phase 6: Деплой бэкенда 🔴 (критический путь)

1. **Установить Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

2. **Задать секреты YooKassa** (получить в [dashboard.yookassa.ru](https://yookassa.ru/my)):
   ```bash
   cd /Users/thatguy/src/brainy
   firebase functions:secrets:set YOOKASSA_SHOP_ID
   firebase functions:secrets:set YOOKASSA_SECRET_KEY
   ```

3. **Деплой Cloud Functions**:
   ```bash
   cd functions && npm run deploy
   ```

4. **Настроить webhook в YooKassa dashboard**:
   - URL: `https://us-central1-brainy-app-1e48c.cloudfunctions.net/yookassaWebhook`
   - События: `payment.succeeded`, `payment.canceled`

5. **Проверить деплой**:
   ```bash
   # Тест checkSubscription
   firebase functions:shell
   > checkSubscription({deviceId: "test-device"})
   ```

### Phase 7: Тестовая оплата 🟡

1. Включить тестовый режим в YooKassa dashboard
2. Запустить приложение на iOS-устройстве
3. Открыть paywall → выбрать план → оплатить тестовой картой `4111 1111 1111 1111`
4. Проверить:
   - [ ] Платёж создан в Firestore (`payments` collection)
   - [ ] Подписка создана в Firestore (`subscriptions` collection)
   - [ ] `isPremium()` возвращает `true`
   - [ ] Premium-фичи разблокированы (сетки 6×6+, дашборд родителя)
   - [ ] После перезапуска приложения статус сохраняется (Hive кэш)
   - [ ] Без интернета premium работает по кэшу

### Phase 8: YooKassa SDK (опционально) 🟡

Сейчас `purchase()` вызывает Cloud Function напрямую без `paymentToken`. Для полноценного flow нужно:

1. Добавить `yookassa_payments_flutter` SDK в pubspec.yaml
2. В `purchase()` вызывать `YookassaPaymentsFlutter.tokenize()` для показа нативной платёжной формы
3. Передавать полученный `paymentToken` в `createPayment` Cloud Function
4. Обрабатывать 3DS confirmation через SDK

Это даст нативный UI для оплаты (карта/СБП/SberPay/T-Pay).

### Phase 9: Production 🟡

1. Переключить YooKassa из тестового в боевой режим
2. Заменить тестовые ключи на production
3. Настроить production webhook URL
4. Проверить авто-продление (`renewSubscriptions`)
5. Добавить мониторинг/алерты на ошибки платежей

### Phase 10: Возврат RevenueCat (когда одобрят Кыргызстан) 🔵

1. Раскомментировать `purchases_flutter`/`purchases_ui_flutter` в pubspec.yaml
2. Раскомментировать RevenueCat код в `subscription_service.dart`
3. Раскомментировать RevenueCat константы в `app_constants.dart`
4. Вернуть `RevenueCatUI.presentPaywallIfNeeded` в `paywall_page.dart`
5. Вернуть `Package`-based plan cards в `paywall_screen.dart`
6. Cloud Functions можно оставить для РФ-пользователей (двойная система)

---

## Конфигурация

### Секреты (НЕ коммитить!)

| Секрет | Где хранится | Где получить |
|--------|-------------|-------------|
| YOOKASSA_SHOP_ID | Firebase Functions secrets | dashboard.yookassa.ru → Настройки |
| YOOKASSA_SECRET_KEY | Firebase Functions secrets | dashboard.yookassa.ru → Настройки → API ключи |
| YOOKASSA_CLIENT_KEY | Flutter `--dart-define` | dashboard.yookassa.ru (для SDK, Phase 8) |

### Firebase проект

- Project ID: `brainy-app-1e48c`
- Functions region: `us-central1` (по умолчанию)
- Firestore collections: `subscriptions`, `payments`

### Планы подписки

| План | Цена | Duration |
|------|------|----------|
| monthly | 299₽ | 30 дней |
| yearly | 1990₽ | 365 дней |

Семейный план убран (был в RevenueCat).

---

## Команды для разработки

```bash
# Запуск тестов бэкенда
cd /Users/thatguy/src/brainy/functions && npm test

# Запуск тестов Flutter
cd /Users/thatguy/src/brainy/brainy-app && flutter test test/services/device_id_service_test.dart test/services/subscription_service_test.dart test/constants/subscription_constants_test.dart test/features/subscription/paywall_screen_test.dart test/features/onboarding/paywall_page_test.dart

# Локальный запуск Cloud Functions (эмулятор)
cd /Users/thatguy/src/brainy/functions && npm run serve

# Деплой Cloud Functions
cd /Users/thatguy/src/brainy/functions && npm run deploy

# Логи Cloud Functions
cd /Users/thatguy/src/brainy && firebase functions:log
```
