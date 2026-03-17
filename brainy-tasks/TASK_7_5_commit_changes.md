# Задание 7.5 — Закоммитить все изменения

> **Приоритет:** P0
> **Статус:** Не начато

---

## Проблема

В рабочей директории ~38 изменённых файлов и множество новых, которые не закоммичены:

### Изменённые файлы
- Иконки приложения (Android mipmap, iOS AppIcon)
- Dart-файлы (router, screens, providers, models)
- Локализации (app_en.arb, app_ru.arb, сгенерированные l10n)
- pubspec.yaml
- iOS project.pbxproj

### Новые файлы
- Android drawable ресурсы (adaptive icon)
- Спрайты персонажей (5 PNG)
- Бейджи ачивок (10 PNG)
- Изображения лиг (4 PNG)
- Иконки приложения (assets/icon/)
- Новые экраны (grid_detail_screen, league_screen)
- Новые провайдеры (achievements, grid_stats, league)
- Новые модели (achievement, league)
- Файл colors.xml для Android

---

## Что нужно сделать

Сгруппировать изменения в логические коммиты:

1. **feat(icons): add app icons for iOS and Android** — все иконки и drawable
2. **feat(assets): add character sprites, badges, and league images** — спрайты и изображения
3. **feat(progress): add achievements, grid stats, and league system** — новые модели, провайдеры, экраны
4. **feat(l10n): update localizations for new features** — ARB файлы и сгенерированные l10n
5. **chore: update pubspec and project config** — pubspec.yaml, project.pbxproj

---

## Критерии готовности

- [ ] Все изменения закоммичены
- [ ] `git status` показывает чистое рабочее дерево
- [ ] Коммиты логически сгруппированы
