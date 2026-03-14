# Задание 4.1 — Экран персонажа

> **Используй вместе с MASTER_CONTEXT.md**
> Выполняется после задания 3.3.

---

## Цель

Реализовать модели персонажей и экран выбора персонажа с превью.

---

## Модель персонажа

### `lib/models/character.dart`

```dart
@HiveType(typeId: 2)
class CharacterData extends HiveObject {
  @HiveField(0)
  final String id;           // 'brainy', 'zap', etc.

  @HiveField(1)
  final String nameRu;

  @HiveField(2)
  final String nameEn;

  @HiveField(3)
  bool isUnlocked;

  @HiveField(4)
  List<String> unlockedAccessories;  // IDs аксессуаров

  @HiveField(5)
  String? equippedHat;
  
  @HiveField(6)
  String? equippedGlasses;
  
  @HiveField(7)
  String? equippedEffect;
}
```

---

## Дефолтные персонажи

### `lib/features/character/data/characters_data.dart`

```dart
final defaultCharacters = [
  CharacterInfo(
    id: 'brainy',
    nameRu: 'Брейни',
    nameEn: 'Brainy',
    descriptionRu: 'Мозг с характером. Стартовый герой!',
    unlockConditionRu: 'Доступен бесплатно',
    unlockType: UnlockType.free,
    assetPath: 'assets/characters/brainy.png', // placeholder
    color: Color(0xFF6C5CE7),
  ),
  CharacterInfo(
    id: 'zap',
    nameRu: 'Зэп',
    nameEn: 'Zap',
    descriptionRu: 'Электрический роботёнок. Быстрый как молния!',
    unlockConditionRu: 'Достигни уровня 10',
    unlockType: UnlockType.level,
    requiredLevel: 10,
    assetPath: 'assets/characters/zap.png',
    color: Color(0xFFFDCB6E),
  ),
  CharacterInfo(
    id: 'vortex',
    nameRu: 'Вортекс',
    nameEn: 'Vortex',
    descriptionRu: 'Загадочный и странный. Любит вихри.',
    unlockConditionRu: 'Стрик 30 дней',
    unlockType: UnlockType.streak,
    requiredStreak: 30,
    assetPath: 'assets/characters/vortex.png',
    color: Color(0xFF00CEC9),
  ),
  CharacterInfo(
    id: 'pixel',
    nameRu: 'Пиксель',
    nameEn: 'Pixel',
    descriptionRu: '8-битный герой из прошлого.',
    unlockConditionRu: 'Premium подписка',
    unlockType: UnlockType.premium,
    assetPath: 'assets/characters/pixel.png',
    color: Color(0xFF00B894),
  ),
  CharacterInfo(
    id: 'glitch',
    nameRu: 'Глитч',
    nameEn: 'Glitch',
    descriptionRu: 'Сломан, но не сломлен.',
    unlockConditionRu: 'Стрик 60 дней',
    unlockType: UnlockType.streak,
    requiredStreak: 60,
    assetPath: 'assets/characters/glitch.png',
    color: Color(0xFFFF7675),
  ),
];
```

---

## Экран персонажа

### `lib/features/character/screens/character_screen.dart`

**Структура:**
```
AppBar: «Мои персонажи»

Большой превью активного персонажа (центр, анимированный)
  └── Имя персонажа под ним

PageView с карточками персонажей (горизонтальный скролл)
  ├── Разблокированный → цветная карточка, кнопка [Выбрать]
  └── Заблокированный → затемнённая карточка, условие разблокировки

Кнопка [Настроить аксессуары] → переход на экран 4.2
```

**Поведение:**
- Активный персонаж подсвечивается рамкой
- Заблокированный персонаж при тапе → показать BottomSheet с условием разблокировки
- Если условие — Premium → показать кнопку [Открыть Premium]

---

## Критерии готовности

- [ ] Все 5 персонажей отображаются в списке
- [ ] Brainy разблокирован по умолчанию
- [ ] Выбор персонажа сохраняется в Hive
- [ ] Заблокированные персонажи затемнены
- [ ] При тапе на заблокированного — BottomSheet с условием
- [ ] Активный персонаж отображается на главном экране