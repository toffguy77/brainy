# RevenueCat Production Setup Guide

Пошаговая инструкция по настройке подписок для Brainy.

---

## Шаг 1. App Store Connect — создать подписки

### 1.1 Создать Subscription Group

1. Открой [App Store Connect](https://appstoreconnect.apple.com) → твоё приложение
2. Перейди в **Monetization → Subscriptions**
3. Нажми **+** → Create Subscription Group
4. Название группы: **Brainy Pro**

### 1.2 Создать подписки внутри группы

Создай 3 подписки в группе "Brainy Pro":

| Product ID | Тип | Длительность | Цена RU | Цена EN |
|---|---|---|---|---|
| `brainy_pro_monthly` | Auto-Renewable | 1 Month | 299₽ | $3.99 |
| `brainy_pro_yearly` | Auto-Renewable | 1 Year | 1 990₽ | $24.99 |
| `brainy_pro_family` | Auto-Renewable | 1 Year (Family) | 2 990₽ | $39.99 |

Для **каждой** подписки:

1. **Reference Name**: `Brainy Pro Monthly` / `Brainy Pro Yearly` / `Brainy Pro Family`
2. **Subscription Duration**: выбери соответствующую
3. **Subscription Prices**: нажми **+** и добавь цены:
   - Начни с базовой страны (Russia или United States)
   - Apple автоматически предложит цены для остальных стран
   - Проверь цены для RU и US вручную
4. **Localizations** — добавь RU и EN:
   - **RU**: Название = "Brainy Pro (месяц/год/семья)", Описание = "Полный доступ ко всем функциям"
   - **EN**: Название = "Brainy Pro (monthly/yearly/family)", Описание = "Full access to all features"

### 1.3 Настроить Free Trial (только для monthly)

1. Открой `brainy_pro_monthly` → **Subscription Prices**
2. **Introductory Offers** → **+**
3. Тип: **Free Trial**
4. Длительность: **7 Days**
5. Доступность: все страны

### 1.4 Review Information (для каждой подписки)

Apple требует скриншот для ревью:
1. Сделай скриншот Paywall экрана
2. Загрузи в **Review Information → Screenshot**
3. В **Review Notes** напиши: "This subscription unlocks larger Schulte table sizes (6x6, 7x7, 9x9), Gorbov-Schulte mode, all characters, full statistics, and removes ads."

---

## Шаг 2. App Store Connect — Shared Secret

1. Перейди в **App Information → App-Specific Shared Secret**
2. Если секрет ещё не создан — нажми **Generate**
3. Скопируй секрет — он понадобится для RevenueCat

---

## Шаг 3. RevenueCat Dashboard

### 3.1 Создать проект

1. Открой [RevenueCat Dashboard](https://app.revenuecat.com)
2. **+ New Project** → Название: **Brainy**
3. Выбери платформу **Apple App Store**

### 3.2 Подключить App Store Connect

1. В проекте → **App Store Configuration**
2. **App Bundle ID**: `com.yourcompany.brainy` (проверь в Xcode)
3. **App-Specific Shared Secret**: вставь из шага 2
4. **In-App Purchase Key Configuration**:
   - Скачай ключ в App Store Connect → Users & Access → Integrations → In-App Purchase
   - Загрузи `.p8` файл в RevenueCat
   - Укажи Key ID и Issuer ID

### 3.3 Создать Products

1. Перейди в **Products** → **+ New**
2. Создай 3 продукта с **точными** идентификаторами:

| App Store Product ID | Название в RevenueCat |
|---|---|
| `brainy_pro_monthly` | Brainy Pro Monthly |
| `brainy_pro_yearly` | Brainy Pro Yearly |
| `brainy_pro_family` | Brainy Pro Family |

### 3.4 Создать Entitlement

1. Перейди в **Entitlements** → **+ New**
2. **Identifier**: `brainy_pro` ← ВАЖНО: именно это значение, совпадает с кодом
3. **Lookup Key**: оставь пустым
4. Привяжи все 3 Products к этому Entitlement

### 3.5 Создать Offering

1. Перейди в **Offerings** → **+ New**
2. **Identifier**: `default` ← ВАЖНО: совпадает с `AppConstants.revenueCatOfferingId`
3. Добавь пакеты:
   - **Monthly** → `brainy_pro_monthly`
   - **Annual** → `brainy_pro_yearly`
   - **Custom (Family)** → `brainy_pro_family`
4. Сделай это Offering **текущим** (Current)

### 3.6 Получить Production API Key

1. В проекте → **API Keys**
2. Скопируй **Public App-Specific API Key** (начинается с `appl_`)
3. Этот ключ нужно передать при сборке:

```bash
# Для iOS
flutter build ios --dart-define=REVENUECAT_API_KEY=appl_XXXXXXXXXX

# Для Android (когда добавите Google Play)
flutter build appbundle --dart-define=REVENUECAT_API_KEY=goog_XXXXXXXXXX
```

> **Тестовый ключ** (`test_...`) работает только в sandbox. Для production используй `appl_...` ключ.

### 3.7 Настроить Server Notifications

1. В RevenueCat → проект → **App Store Configuration**
2. Скопируй **Apple Server Notification URL** (формат: `https://api.revenuecat.com/v1/incoming-webhooks/apple/...`)
3. В App Store Connect → App Information → **App Store Server Notifications**
4. Вставь URL из RevenueCat
5. Выбери **Version 2** notifications

---

## Шаг 4. Sandbox тестирование

### 4.1 Создать Sandbox Tester

1. App Store Connect → **Users and Access → Sandbox → Testers**
2. **+** → заполни:
   - Email: используй реальный email (например, `brainy.test@gmail.com`)
   - Password: запомни его
   - Страна: Russia (для тестирования рублёвых цен) или United States
3. На iPhone → **Settings → App Store → Sandbox Account** → войди под тестером

### 4.2 Тестирование покупки

1. Собери приложение на реальное устройство:
```bash
flutter run --dart-define=REVENUECAT_API_KEY=appl_XXXXXXXXXX
```
2. Открой Paywall (из настроек или онбординга)
3. Выбери план и нажми "Попробовать бесплатно"
4. Подтверди покупку через Sandbox аккаунт
5. Проверь что:
   - [ ] Paywall показывает реальные цены из App Store Connect
   - [ ] Покупка проходит успешно
   - [ ] Появляется success dialog
   - [ ] Premium фичи разблокируются (6x6, 7x7, 9x9 таблицы)
   - [ ] Персонаж Pixel доступен

### 4.3 Тестирование восстановления покупок

1. Удали приложение
2. Переустанови и запусти
3. Открой Paywall → нажми "Восстановить покупки"
4. Проверь что premium статус восстановился

### 4.4 Тестирование отмены

В Sandbox подписки автоматически обновляются ускоренно:
- 1 месяц = 5 минут
- 1 год = 1 час

1. Подожди пока подписка обновится несколько раз
2. На iPhone → Settings → Sandbox → Manage Subscriptions → отмени
3. Подожди окончания текущего периода
4. Проверь что premium фичи заблокировались

---

## Шаг 5. Чеклист перед релизом

- [ ] Все 3 подписки созданы в App Store Connect со статусом "Ready to Submit"
- [ ] RevenueCat Dashboard настроен: Products, Entitlement (`brainy_pro`), Offering (`default`)
- [ ] Production API key получен и работает
- [ ] Server Notifications V2 настроены
- [ ] Sandbox тестирование пройдено
- [ ] В сборке передаётся production ключ: `--dart-define=REVENUECAT_API_KEY=appl_XXX`
- [ ] Покупка работает
- [ ] Восстановление работает
- [ ] Premium фичи разблокируются (таблицы 6x6/7x7/9x9, Gorbov-Schulte, Pixel)
