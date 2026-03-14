# Задание 5.2 — RevenueCat и подписка

> **Используй вместе с MASTER_CONTEXT.md**
> Выполняется после задания 5.1.

---

## Цель

Интегрировать RevenueCat, настроить продукты, реализовать логику проверки подписки во всём приложении.

---

## Настройка RevenueCat

### Предварительные шаги (делаешь вручную в консоли)

1. Создать аккаунт на revenuecat.com
2. Создать приложение iOS с bundle ID `com.brainyapp.brainy`
3. Создать продукты в App Store Connect:
   - `brainy_premium_monthly` — подписка месяц
   - `brainy_premium_yearly` — подписка год
   - `brainy_premium_family` — семейная подписка год
   - `brainy_character_pack` — разовая покупка персонажа
   - `brainy_accessory_pack` — разовая покупка аксессуаров
   - `brainy_streak_restore` — разовое восстановление стрика
4. Создать Entitlement `premium` в RevenueCat
5. Привязать продукты к entitlement

---

## Сервис подписки

### `lib/shared/services/subscription_service.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  static const String _apiKey = 'YOUR_REVENUECAT_API_KEY'; // заменить

  static Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(_apiKey));
  }

  Future<bool> isPremium() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey('premium');
    } catch (e) {
      return false;
    }
  }

  Future<List<Package>> getAvailablePackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.active.containsKey('premium');
    } catch (e) {
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.active.containsKey('premium');
    } catch (e) {
      return false;
    }
  }
}

// Провайдер статуса Premium
final isPremiumProvider = FutureProvider<bool>((ref) async {
  final service = SubscriptionService();
  return service.isPremium();
});

final subscriptionServiceProvider = Provider<SubscriptionService>(
  (_) => SubscriptionService(),
);
```

---

## Применение Premium по всему приложению

Во всех местах где нужна проверка Premium — используй `isPremiumProvider`:

```dart
// Пример блокировки сетки 6×6
final isPremium = ref.watch(isPremiumProvider).value ?? false;

if (!isPremium && gridSize > 5) {
  // показать paywall
  context.go('/paywall');
  return;
}
```

Места где применяется проверка:
- Выбор размера таблицы > 5×5
- Режим Горбова-Шульте
- Панель родителя (полная статистика)
- Персонаж Pixel
- Premium аксессуары
- Восстановление стрика

---

## Критерии готовности

- [ ] RevenueCat инициализируется при старте приложения
- [ ] `isPremiumProvider` возвращает корректный статус
- [ ] Заглушки Premium-контента корректно блокируют доступ
- [ ] `restorePurchases()` работает корректно
- [ ] Покупка пакета обновляет статус по всему приложению