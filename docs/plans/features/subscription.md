---
title: Подписка и монетизация
tags: [premium, paywall, yookassa, payment, subscription, free, locked]
---

# Подписка и монетизация

## Текущее состояние

Подписка НЕ активна в production. `SubscriptionService.isPremium()` всегда возвращает `false`. Приложение работает как бесплатное с заблокированными Premium-функциями.

Paywall-экран показывает бейдж «Coming Soon» и кнопку «Подписаться на обновления», которая открывает Telegram-канал (`AppConstants.premiumWaitlistUrl`).

## Архитектура подписки

### RevenueCat (закомментирован)

Оригинальная реализация через RevenueCat полностью закомментирована в `subscription_service.dart`. Константы закомментированы в `app_constants.dart`. Причина: Apple заблокировала Paid Applications Agreement для аккаунтов из РФ.

### YooKassa (бэкенд готов, не задеплоен)

Реализация для российского рынка через YooKassa + Firebase Cloud Functions:
- `functions/src/createPayment.ts` — создание платежа
- `functions/src/yookassaWebhook.ts` — webhook обработка
- `functions/src/checkSubscription.ts` — проверка статуса
- `functions/src/renewSubscriptions.ts` — авто-продление (cron)

Код на ветке `feat/yookassa-payment`. Cloud Functions не задеплоены, YooKassa credentials не настроены.

### Текущий stub

```dart
class SubscriptionService {
  static Future<void> initialize() async {}
  static Future<bool> isPremium() async => false;
}
```

Provider: `isPremiumProvider` — FutureProvider<bool>, всегда false.

## Планы подписки (запланированные)

| План | Цена RUB | Длительность |
|------|----------|-------------|
| monthly | 299 руб | 30 дней |
| yearly | 1990 руб | 365 дней |

Семейный план убран (был в RevenueCat).

## Что включает Premium

- Размеры таблиц 6x6, 7x7, 9x9
- Режим Горбова-Шульте
- Персонаж Pixel (сразу)
- Дашборд родителя (статистика)
- Детальные графики по размерам
- (Запланировано: восстановление стрика, без рекламы)

## Что бесплатно

- Таблицы 3x3, 4x4, 5x5
- Персонаж Brainy + разблокируемые через стрик/уровень
- Настройки родителя
- Стрик, достижения, базовая статистика
- Классический режим

## Paywall-экран

Маршрут: `/paywall`.

Показывает:
- Иконка Premium с градиентом
- Заголовок + подзаголовок
- 5 анимированных преимуществ (fade+slide, staggered)
- Бейдж «Coming Soon»
- Кнопка «Подписаться на обновления» -> Telegram
- Ссылки: Terms of Use, Privacy Policy

Также существует inline paywall на онбординге (страница 7) — перенаправляет на PaywallScreen.

## Premium Bottom Sheet

`showPremiumBottomSheet()` — показывается при попытке доступа к Premium-функциям (тап на locked размер, Горбов, locked персонаж). Содержит описание функции и кнопку перехода на paywall.

## Ключевые файлы

- `brainy-app/lib/shared/services/subscription_service.dart`
- `brainy-app/lib/features/subscription/screens/paywall_screen.dart`
- `brainy-app/lib/features/subscription/widgets/premium_bottom_sheet.dart`
- `brainy-app/lib/features/onboarding/pages/paywall_page.dart`
- `brainy-app/lib/constants/app_constants.dart` — YooKassa + subscription constants
