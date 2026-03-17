# Задание 7.8 — Настройка RevenueCat для production

> **Приоритет:** P1
> **Статус:** Не начато

---

## Проблема

RevenueCat SDK подключён (`purchases_flutter`, `purchases_ui_flutter`), но для production нужна полная настройка в App Store Connect и RevenueCat Dashboard.

---

## Что нужно сделать

### 1. App Store Connect — создать подписки

Создать In-App Purchases (Auto-Renewable Subscriptions):

| Product ID | Тип | Цена RU | Цена EN |
|---|---|---|---|
| `brainy_pro_monthly` | Monthly | 299₽ | $3.99 |
| `brainy_pro_yearly` | Yearly | 1 990₽ | $24.99 |
| `brainy_pro_family` | Yearly (Family) | 2 990₽ | $39.99 |

Для каждой подписки:
- [ ] Создать Subscription Group: "Brainy Pro"
- [ ] Указать цены для всех стран
- [ ] Добавить локализованные описания (RU + EN)
- [ ] Настроить Free Trial (7 дней для monthly)

### 2. RevenueCat Dashboard

- [ ] Создать проект в RevenueCat
- [ ] Подключить App Store Connect (Shared Secret)
- [ ] Создать Products, соответствующие Product ID из App Store Connect
- [ ] Создать Entitlement: `brainy_pro`
- [ ] Привязать все Products к Entitlement
- [ ] Создать Offering: `default` с пакетами Monthly, Annual, Family
- [ ] Получить **production** API Key
- [ ] Настроить Server Notifications (App Store Server-to-Server URL)

### 3. Обновить код приложения

Проверить что в `lib/shared/services/subscription_service.dart` или `revenue_cat_service.dart`:
- API ключ — production (не sandbox)
- Entitlement ID = `brainy_pro`
- Offering ID = `default`

### 4. Тестирование в Sandbox

- [ ] Создать Sandbox тестер в App Store Connect
- [ ] Проверить покупку подписки
- [ ] Проверить восстановление покупок
- [ ] Проверить что premium фичи разблокируются
- [ ] Проверить отмену подписки

---

## Файлы для проверки

- `lib/shared/services/subscription_service.dart`
- `lib/shared/services/revenue_cat_service.dart`
- `lib/features/subscription/screens/paywall_screen.dart`

---

## Критерии готовности

- [ ] Подписки созданы в App Store Connect
- [ ] RevenueCat Dashboard настроен с production ключом
- [ ] Покупка работает в Sandbox
- [ ] Восстановление покупок работает
- [ ] Premium фичи (большие таблицы, Gorbov-Schulte, Pixel) разблокируются при подписке
