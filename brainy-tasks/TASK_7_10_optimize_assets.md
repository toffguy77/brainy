# Задание 7.10 — Оптимизация ассетов

> **Приоритет:** P2
> **Статус:** Не начато

---

## Проблема

### Звуковые файлы в WAV
9 файлов в `assets/sounds/` в формате WAV. WAV — несжатый формат, занимает в 5-10 раз больше места, чем сжатые альтернативы.

### Пустая директория Lottie-анимаций
`assets/animations/` содержит только `.gitkeep`. Пакет `lottie: ^3.3.1` подключён, но не используется.

---

## Что нужно сделать

### 1. Конвертировать WAV → M4A или OGG

```bash
# Установить ffmpeg если нет
brew install ffmpeg

# Конвертировать все WAV в M4A (AAC)
cd brainy-app/assets/sounds/
for f in *.wav; do
  ffmpeg -i "$f" -c:a aac -b:a 128k "${f%.wav}.m4a"
done
```

Или использовать OGG для кроссплатформенности:
```bash
for f in *.wav; do
  ffmpeg -i "$f" -c:a libvorbis -q:a 5 "${f%.wav}.ogg"
done
```

После конвертации:
- Обновить расширения в коде (`sound_service.dart`)
- Удалить оригинальные WAV файлы
- Проверить что звуки играют на iOS и Android

> **Примечание:** `audioplayers` поддерживает m4a, mp3 и ogg на обеих платформах.

### 2. Убрать Lottie или добавить анимации

**Вариант A** (убрать): Удалить `lottie: ^3.3.1` из `pubspec.yaml` и убрать `assets/animations/` из секции assets.

**Вариант B** (добавить): Скачать/создать Lottie-анимации для:
- Конфетти при рекорде
- Idle-анимация персонажа
- Переход между экранами

### 3. Проверить размер PNG ассетов

Убедиться что character sprites, badges и league images оптимизированы:
```bash
# Проверить размеры
du -sh brainy-app/assets/characters/*
du -sh brainy-app/assets/badges/*
du -sh brainy-app/assets/leagues/*
```

Оптимизировать если нужно:
```bash
# pngquant для PNG оптимизации
brew install pngquant
pngquant --quality=65-80 brainy-app/assets/**/*.png
```

---

## Файлы для изменения

- `assets/sounds/*.wav` → конвертировать в m4a/ogg
- `lib/shared/services/sound_service.dart` — обновить расширения файлов
- `pubspec.yaml` — возможно удалить lottie

---

## Критерии готовности

- [ ] Звуковые файлы конвертированы из WAV в m4a/ogg
- [ ] Размер приложения уменьшился
- [ ] Звуки работают на iOS и Android
- [ ] Lottie — либо используется, либо удалён
- [ ] PNG ассеты оптимизированы
