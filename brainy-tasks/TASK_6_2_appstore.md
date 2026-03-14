# Задание 6.2 — Подготовка к App Store

> **Используй вместе с MASTER_CONTEXT.md**
> Выполняется после задания 6.1.

---

## Цель

Подготовить приложение к публикации в App Store: иконка, сплэш-экран, метаданные, финальное тестирование.

---

## Иконка приложения

Создай иконку 1024×1024px:
- Фиолетовый градиентный фон (#6C5CE7 → #00CEC9)
- Белый логотип Brainy (мозг с глазами) по центру
- Скруглённые углы (добавит App Store автоматически)

Используй пакет `flutter_launcher_icons: ^0.13.1`:

```yaml
# pubspec.yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#6C5CE7"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

---

## Сплэш-экран

Используй пакет `flutter_native_splash: ^2.3.10`:

```yaml
# pubspec.yaml
flutter_native_splash:
  color: "#0D0D1A"
  image: assets/splash/splash_logo.png
  android: true
  ios: true
```

---

## Info.plist — разрешения iOS

Добавь в `ios/Runner/Info.plist`:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>Для показа релевантной рекламы и аналитики</string>

<key>NSCameraUsageDescription</key>
<string>Для создания аватара ребёнка</string>
```

---

## Финальный чеклист перед сабмитом

### Функциональность
- [ ] Онбординг проходится без ошибок
- [ ] Игра запускается на 3×3, 4×4, 5×5 без крашей
- [ ] Результаты корректно сохраняются
- [ ] Стрик корректно считается
- [ ] Панель родителя открывается по PIN
- [ ] Подписка через RevenueCat работает (Sandbox тест)
- [ ] Восстановление покупок работает
- [ ] Оба языка (RU и EN) отображаются корректно

### Техническое
- [ ] Нет force unwraps (!) в продакшн коде
- [ ] Нет print() в продакшн коде (используй Logger)
- [ ] Firebase Crashlytics инициализирован
- [ ] Все изображения оптимизированы (WebP где возможно)
- [ ] Приложение работает на iPhone SE (маленький экран)
- [ ] Приложение работает на iPad (если поддерживается)
- [ ] Dark mode — единственная тема, Light mode не ломает UI

### App Store метаданные (готовишь вручную в App Store Connect)

**Название:** Brainy — Таблицы Шульте (RU) / Brainy — Brain Training (EN)

**Подзаголовок:** Тренажёр внимания для детей (RU) / Focus Trainer for Kids (EN)

**Ключевые слова RU:** таблица шульте, тренировка внимания, скорочтение, развитие ребёнка, концентрация, память

**Ключевые слова EN:** schulte table, brain training, focus kids, speed reading, attention, cognitive

**Описание RU (краткое):**
«Brainy — игровой тренажёр внимания для детей 6–14 лет на основе таблиц Шульте. Тренируйтесь каждый день, прокачивайте персонажа и следите за прогрессом!»

**Возрастной рейтинг:** 4+

**Категория:** Education / Games > Educational

### Скриншоты (нужны для App Store)
Сделай скриншоты на симуляторе для:
- iPhone 15 Pro Max (6.7")
- iPhone SE (4.7")
- iPad Pro 12.9" (если поддерживается)

Обязательные экраны для скриншотов:
1. Главный экран с персонажем
2. Игровой экран (таблица 5×5)
3. Экран результата с рекордом
4. Экран персонажа
5. Панель родителя

---

## Команды для финальной сборки

```bash
# Обновить версию в pubspec.yaml перед каждым релизом
# version: 1.0.0+1

# Очистить и пересобрать
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create

# Собрать для TestFlight
flutter build ipa --release

# Архив находится в: build/ios/ipa/brainy.ipa
# Загрузить через Xcode → Product → Archive или Transporter
```

---

## Критерии готовности

- [ ] Иконка приложения отображается корректно на всех размерах
- [ ] Сплэш-экран показывает логотип на тёмном фоне
- [ ] Приложение проходит все проверки из финального чеклиста
- [ ] TestFlight сборка успешно загружена
- [ ] Внутреннее тестирование (хотя бы на 2–3 устройствах) пройдено
- [ ] Все метаданные App Store заполнены на двух языках