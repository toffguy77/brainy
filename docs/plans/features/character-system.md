---
title: Система персонажей
tags: [character, accessories, coins, cosmetics, shop, pixel, brainy, zap, vortex, glitch]
---

# Система персонажей

## Обзор

5 коллекционных персонажей в brainrot/блочном стиле. Каждый разблокируется по-своему. Активный персонаж отображается на главном экране с idle-анимацией (покачивание). Персонажи кастомизируются аксессуарами, покупаемыми за игровые монеты.

## Персонажи

| ID | Имя RU | Имя EN | Разблокировка | Цвет |
|----|--------|--------|---------------|------|
| brainy | Брейни | Brainy | Бесплатно | #6C5CE7 |
| zap | Зэп | Zap | Уровень 10 | #FDCB6E |
| vortex | Вортекс | Vortex | Стрик 30 дней | #00CEC9 |
| pixel | Пиксель | Pixel | Стрик 14 дней | #00B894 |
| glitch | Глитч | Glitch | Стрик 60 дней | #FF7675 |

Типы разблокировки определены в enum `UnlockType`: `free`, `level`, `streak`. Платных разблокировок нет.

## Экран персонажа

Путь: `/character` (таб в нижней навигации).

Структура:
- AppBar: «Мои персонажи»
- Большое превью персонажа текущей карточки PageView (центр, покачивание), имя и описание
- PageView с карточками: разблокированные цветные, заблокированные затемнённые. Тап по
  разблокированной карточке выбирает персонажа активным
- Кнопка [Настроить аксессуары] -> `/accessories` (видна, если персонаж текущей карточки разблокирован)
- Кнопка действия под карточками: [Выбрать] / «Выбран» / условие разблокировки (неактивна)

При тапе на заблокированного — BottomSheet с условием разблокировки.

## Аксессуары

15 предметов в 4 категориях (enum `AccessorySlot`), каталог — `accessories_data.dart`:
- **Шляпы (hat):** Колпак учёного, Корона, Кепка, Шлем, Цилиндр
- **Очки (glasses):** Умные очки, Солнцезащитные, Пиксельные, VR-шлем
- **Эффекты (effect):** Звёзды, Огонь, Электричество
- **Плащи (cape):** Мантия, Плащ ниндзя, Крылья

Покупка за игровые монеты. Платных аксессуаров нет. Владение — общее для всех персонажей
(`UserProgress.unlockedAccessories`), а надетое — своё у каждого персонажа (`equipped*` в
`CharacterData`).

Отрисовка без отдельного арта: у каждого предмета `glyph` (эмодзи или текстовый глиф, например
пиксельные очки `⌐■-■`) либо `tint` — мантия и плащ ниндзя рисуются `CapePainter` нужного цвета.
Виджет `DressedAvatar` накладывает слои на аватар: плащ/крылья сзади, очки на лице, шляпа сверху,
эффект вокруг. Используется на главной, на превью экрана персонажа и в магазине.

## Экран аксессуаров

Путь: через кнопку на экране персонажа — `/accessories?character=<id>` того персонажа, чья карточка
сейчас на экране (он может не быть активным). Без параметра — активный персонаж
(`UserProgress.activeCharacterId`).

- Превью персонажа с надетыми аксессуарами (`DressedAvatar`) и чипы с названиями надетого
- Табы по категориям: Шляпы | Очки | Эффекты | Плащи
- GridView (2 колонки), у карточки — глиф предмета и состояние: надет (действие «Снять»),
  куплен («Надеть»), не куплен (цена)

При покупке: проверка баланса -> списание монет -> автонадевание, вибрация `HapticService.purchase`.
Не хватает монет — BottomSheet «нужно N, у тебя M», баланс не меняется. Тап по надетому снимает его.

## Хранение

- Данные персонажа в `CharacterData` (Hive typeId: 2): id, isUnlocked, equippedHat/Glasses/Effect/Cape.
  Поля `nameRu/nameEn` и `unlockedAccessories` — устаревшие, сохраняются ради формата и не читаются;
  имена персонажей берутся из ARB по id
- Активный персонаж сохраняется в `UserProgress.activeCharacterId`
- Hive box: `character`

## Отображение на главном экране

Активный персонаж рендерится в круглом контейнере 160x160 с градиентным фоном цвета персонажа. Idle-анимация: покачивание вверх-вниз (AnimationController, 1800ms, Tween -6..+6).

Персонаж рисуется `DressedAvatar` (PNG из `assets/characters/*.png` через `characterAvatar()` плюс надетые аксессуары).

## Ключевые файлы

- `brainy-app/lib/features/character/data/characters_data.dart` — CharacterInfo, defaultCharacters
- `brainy-app/lib/models/character.dart` — CharacterData (Hive)
- `brainy-app/lib/models/accessory.dart` — AccessoryInfo, AccessorySlot
- `brainy-app/lib/features/character/data/accessories_data.dart` — каталог аксессуаров
- `brainy-app/lib/features/character/widgets/dressed_avatar.dart` — DressedAvatar, CapePainter
- `brainy-app/lib/features/character/screens/character_screen.dart`
- `brainy-app/lib/features/character/screens/accessories_screen.dart`
- `brainy-app/lib/features/character/providers/character_provider.dart` — CharacterNotifier (выбор, надевание, `unlockEligible`)
