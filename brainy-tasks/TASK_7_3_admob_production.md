# Задание 7.3 — Заменить тестовый AdMob ID

> **Приоритет:** P0 (блокирует публикацию)
> **Статус:** Не начато

---

## Проблема

В `ios/Runner/Info.plist` используется **тестовый** GAD Application Identifier:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
```

Это тестовый ID от Google — он не будет работать в production и может привести к отклонению приложения.

---

## Варианты решения

### Вариант A: Настроить production AdMob

1. Создать аккаунт в [AdMob](https://admob.google.com/)
2. Зарегистрировать приложение Brainy
3. Получить production App ID
4. Заменить в `Info.plist`
5. Настроить ad units (banner / interstitial / rewarded)
6. Добавить код показа рекламы в приложение

### Вариант B: Убрать рекламу полностью (рекомендуется)

Если монетизация через подписку RevenueCat — реклама может быть не нужна. Для детского приложения отсутствие рекламы — **преимущество** при ревью Apple.

1. Удалить `GADApplicationIdentifier` из `Info.plist`
2. Удалить `google_mobile_ads: ^5.3.0` из `pubspec.yaml`
3. Удалить `NSUserTrackingUsageDescription` из `Info.plist` (если ATT нужен только для рекламы)
4. Удалить любой код связанный с рекламой в `lib/`

> **Примечание:** NSUserTrackingUsageDescription может быть нужен для Firebase Analytics. Проверить, нужен ли ATT для аналитики без персонализированной рекламы.

---

## Файлы для изменения

- `ios/Runner/Info.plist` — GADApplicationIdentifier, возможно NSUserTrackingUsageDescription
- `android/app/src/main/AndroidManifest.xml` — проверить наличие AdMob meta-data
- `pubspec.yaml` — возможно удалить `google_mobile_ads`
- `lib/` — удалить код рекламы (если есть)

---

## Критерии готовности

- [ ] Тестовый AdMob ID заменён на production ИЛИ реклама полностью удалена
- [ ] Приложение собирается без ошибок
- [ ] Нет запроса ATT если реклама убрана и ATT не нужен для аналитики
