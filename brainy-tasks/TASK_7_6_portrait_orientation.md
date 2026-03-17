# Задание 7.6 — Зафиксировать portrait-only ориентацию

> **Приоритет:** P1
> **Статус:** Не начато

---

## Проблема

В `ios/Runner/Info.plist` разрешены все ориентации экрана:

```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>
```

Для приложения с Schulte-таблицами landscape-ориентация:
- Может ломать UI игрового экрана (таблица не влезает)
- Может ломать layout онбординга и других экранов
- Не тестировалась (судя по отсутствию landscape-адаптации в коде)

---

## Что нужно сделать

### iOS (`Info.plist`)

Оставить только portrait для iPhone:

```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
</array>
```

Для iPad можно оставить все ориентации (App Store требует поддержку нескольких ориентаций на iPad):

```xml
<key>UISupportedInterfaceOrientations~ipad</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationPortraitUpsideDown</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>
```

### Android (`AndroidManifest.xml`)

Добавить в `<activity>`:

```xml
android:screenOrientation="portrait"
```

---

## Файлы для изменения

- `ios/Runner/Info.plist` — убрать landscape для iPhone
- `android/app/src/main/AndroidManifest.xml` — добавить screenOrientation="portrait"

---

## Критерии готовности

- [ ] iPhone — только portrait
- [ ] iPad — все ориентации (требование Apple)
- [ ] Android — только portrait
- [ ] UI не ломается при повороте устройства
