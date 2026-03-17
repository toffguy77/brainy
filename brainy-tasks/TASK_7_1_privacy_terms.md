# Задание 7.1 — Privacy Policy и Terms of Use

> **Приоритет:** P0 (блокирует публикацию)
> **Статус:** Не начато

---

## Проблема

Apple **обязательно** требует ссылку на Privacy Policy для любого приложения в App Store. Для приложений с подпиской также требуются Terms of Use (EULA). Сейчас:

1. В `paywall_screen.dart:337` — `// TODO: open terms URL` (заглушка)
2. В `paywall_screen.dart:344` — `// TODO: open privacy URL` (заглушка)
3. Пакет `url_launcher` не подключён в `pubspec.yaml`
4. Сами документы не созданы и не захостированы

---

## Что нужно сделать

### 1. Создать документы

**Privacy Policy** должна включать:
- Какие данные собираются (Firebase Analytics, Crashlytics, RevenueCat, AdMob)
- Как хранятся данные (Hive локально, Firestore в облаке)
- Что приложение для детей — соответствие COPPA / российскому закону о персональных данных
- Использование рекламного идентификатора (NSUserTrackingUsageDescription)
- Контактные данные разработчика

**Terms of Use** должны включать:
- Условия подписки Brainy Pro (цены, период, автопродление)
- Политика возврата (через Apple)
- Возрастные ограничения
- Ограничение ответственности

### 2. Захостить документы

Варианты:
- GitHub Pages (бесплатно)
- Notion (публичная страница)
- Простой лендинг на любом хостинге

Нужны 4 URL:
- Privacy Policy (RU)
- Privacy Policy (EN)
- Terms of Use (RU)
- Terms of Use (EN)

### 3. Подключить `url_launcher`

```yaml
# pubspec.yaml
dependencies:
  url_launcher: ^6.2.5
```

### 4. Реализовать открытие ссылок

В `paywall_screen.dart` заменить TODO на:

```dart
import 'package:url_launcher/url_launcher.dart';

// Константы (вынести в app_constants.dart)
static const privacyPolicyUrl = 'https://...';
static const termsOfUseUrl = 'https://...';

// В onPressed:
onPressed: () => launchUrl(Uri.parse(termsOfUseUrl));
onPressed: () => launchUrl(Uri.parse(privacyPolicyUrl));
```

### 5. Добавить ссылку в App Store Connect

В разделе «App Information» → «Privacy Policy URL» указать ссылку.

---

## Файлы для изменения

- `pubspec.yaml` — добавить `url_launcher`
- `lib/constants/app_constants.dart` — добавить URL констант
- `lib/features/subscription/screens/paywall_screen.dart` — подключить ссылки
- `lib/features/parent/screens/parent_settings_screen.dart` — добавить ссылку на Privacy Policy (желательно)

---

## Критерии готовности

- [ ] Privacy Policy создана на RU и EN
- [ ] Terms of Use созданы на RU и EN
- [ ] Документы доступны по URL
- [ ] `url_launcher` добавлен в зависимости
- [ ] Кнопки «Условия» и «Конфиденциальность» на paywall открывают правильные URL
- [ ] URL указан в App Store Connect
