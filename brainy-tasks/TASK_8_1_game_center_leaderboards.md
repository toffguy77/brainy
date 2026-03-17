# Задание 8.1 — Game Center / Google Play Games лидерборды

> **Используй вместе с MASTER_CONTEXT.md**
> Выполняется после задания 7.x (подготовка к релизу).

---

## Цель

Интегрировать Game Center (iOS) и Google Play Games (Android) для реальных лидербордов и идентификации игроков. Имя игрока берётся только из Game Center / Play Games. Таб «Лига» показывает реальных игроков в кастомном UI, с кнопкой для открытия нативного лидерборда.

---

## Обзор

### Идентификация игрока
- Имя берётся **только** из Game Center (iOS) / Google Play Games (Android)
- Если сервис не подключён — показываем «Lv{N}» как сейчас
- Никакого ручного ввода имени

### Лидерборды (7 штук)
| ID | Тип | Описание |
|---|---|---|
| `weekly_xp` | Recurring (еженедельный) | Недельный XP — основной рейтинг лиги |
| `best_time_3x3` | Best time | Лучшее время 3×3 |
| `best_time_4x4` | Best time | Лучшее время 4×4 |
| `best_time_5x5` | Best time | Лучшее время 5×5 |
| `best_time_6x6` | Best time | Лучшее время 6×6 |
| `best_time_7x7` | Best time | Лучшее время 7×7 |
| `best_time_9x9` | Best time | Лучшее время 9×9 |

### Тиры (визуальные, локальный расчёт)
| Тир | Порог недельного XP |
|---|---|
| Бронза | 0 |
| Серебро | 150 |
| Золото | 400 |
| Платина | 800 |

Тир — **персональный бейдж**, рассчитывается локально по недельному XP игрока. Не влияет на группировку в лидерборде.

---

## Зависимости

### Flutter-пакет
```yaml
# pubspec.yaml
dependencies:
  games_services: ^4.0.0  # единый пакет для Game Center + Google Play Games
```

### Настройка платформ

**iOS:**
- Включить Game Center capability в Xcode
- Настроить лидерборды в App Store Connect (7 шт.)

**Android:**
- Включить Google Play Games Services в Google Play Console
- Настроить лидерборды в Play Console (7 шт.)
- Добавить `games_services` metadata в `AndroidManifest.xml`

---

## Сервис Game Services

### `lib/shared/services/game_services_service.dart`

```dart
class GameServicesService {
  /// Авторизация в Game Center / Play Games
  /// Вызывается при запуске приложения
  Future<bool> signIn();

  /// Получить displayName текущего игрока
  /// Возвращает null если не авторизован
  Future<String?> getPlayerName();

  /// Отправить недельный XP
  Future<void> submitWeeklyXp(int xp);

  /// Отправить лучшее время на таблицу (в миллисекундах)
  Future<void> submitBestTime({
    required int gridSize,
    required int timeMs,
  });

  /// Получить топ игроков из лидерборда weekly_xp
  /// Возвращает список (имя, скор, ранг)
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard({
    int count = 25,
  });

  /// Получить окружающих игроков (вокруг текущего)
  Future<List<LeaderboardEntry>> getNearbyPlayers({
    int count = 10,
  });

  /// Открыть нативный UI всех лидербордов
  Future<void> showNativeLeaderboards();

  /// Проверить, авторизован ли игрок
  bool get isSignedIn;
}
```

### `lib/models/leaderboard_entry.dart`

```dart
class LeaderboardEntry {
  final String playerName;
  final int score;
  final int rank;
  final bool isCurrentPlayer;
}
```

---

## Провайдеры

### `lib/features/league/providers/game_services_provider.dart`

```dart
/// Провайдер сервиса Game Services (singleton)
final gameServicesProvider = Provider<GameServicesService>((ref) {
  return GameServicesService();
});

/// Имя игрока из Game Center / Play Games
final playerNameProvider = FutureProvider<String?>((ref) {
  final service = ref.watch(gameServicesProvider);
  return service.getPlayerName();
});

/// Статус авторизации
final isGameServicesSignedInProvider = Provider<bool>((ref) {
  return ref.watch(gameServicesProvider).isSignedIn;
});
```

### Обновить `lib/features/league/providers/league_provider.dart`

Заменить симулированных NPC на реальные данные:

```dart
/// Реальные standings из Game Center / Play Games
final leagueStandingsProvider = FutureProvider<List<LeaderboardEntry>>((ref) {
  final service = ref.watch(gameServicesProvider);
  if (!service.isSignedIn) {
    return []; // пустой список если не авторизован
  }
  return service.getWeeklyLeaderboard(count: 25);
});
```

---

## Экран лиги — изменения

### `lib/features/league/screens/league_screen.dart`

**Структура (обновлённая):**
```
AppBar: «Лига»

Тир-бейдж (как сейчас)
├── Иконка тира (бронза/серебро/золото/платина)
├── «Золотая лига» (название)
└── Прогресс до следующего тира

Недельный XP: «325 XP на этой неделе»

Лидерборд (реальные игроки)
├── #1  Маша      480 XP
├── #2  Артём     350 XP
├── #3  ► Ты      325 XP    ← подсвечен
├── #4  Alex      290 XP
└── ...

[Полный рейтинг] ← кнопка, открывает нативный Game Center / Play Games

Подвал: «Обновляется каждый понедельник»
```

**Поведение:**
- Если Game Services не авторизован → показать карточку «Подключи Game Center для соревнований с реальными игроками» + кнопка [Подключить]
- Если авторизован но нет данных → показать спиннер
- Если есть данные → показать лидерборд
- Текущий игрок подсвечивается жёлтым акцентом
- Кнопка «Полный рейтинг» → `GameServicesService.showNativeLeaderboards()`

---

## Отправка скоров

### При завершении сессии (обновить result_screen.dart / sessions_provider.dart):

```
После сохранения сессии:
1. Пересчитать недельный XP → submitWeeklyXp(totalWeeklyXp)
2. Если это личный рекорд на данном размере → submitBestTime(gridSize, timeMs)
```

---

## Локализация

### `l10n/app_ru.arb` (добавить)
```json
{
  "leagueConnectGameCenter": "Подключи Game Center для соревнований с реальными игроками",
  "leagueConnect": "Подключить",
  "leagueFullRanking": "Полный рейтинг",
  "leagueUpdatesMonday": "Обновляется каждый понедельник",
  "leagueNotConnected": "Game Center не подключён"
}
```

### `l10n/app_en.arb` (добавить)
```json
{
  "leagueConnectGameCenter": "Connect Game Center to compete with real players",
  "leagueConnect": "Connect",
  "leagueFullRanking": "Full Ranking",
  "leagueUpdatesMonday": "Updates every Monday",
  "leagueNotConnected": "Game Center not connected"
}
```

---

## Тесты

### Unit-тесты

**`test/services/game_services_service_test.dart`**
- `signIn()` возвращает true при успешной авторизации
- `getPlayerName()` возвращает имя после авторизации
- `getPlayerName()` возвращает null если не авторизован
- `submitWeeklyXp()` вызывает platform-метод с правильным leaderboard ID
- `submitBestTime()` маппит gridSize на правильный leaderboard ID
- `getWeeklyLeaderboard()` парсит ответ в `List<LeaderboardEntry>`
- `getNearbyPlayers()` парсит ответ корректно

**`test/providers/league_provider_test.dart`**
- `leagueStandingsProvider` возвращает пустой список если не авторизован
- `leagueStandingsProvider` возвращает реальные данные если авторизован
- `playerNameProvider` корректно пробрасывает имя
- Тир рассчитывается правильно: 0→бронза, 150→серебро, 400→золото, 800→платина
- Тир обновляется при изменении недельного XP

**`test/models/leaderboard_entry_test.dart`**
- Создание модели с правильными полями
- `isCurrentPlayer` корректно выставляется

### Widget-тесты

**`test/features/league/screens/league_screen_test.dart`**
- Показывает карточку подключения если Game Services не авторизован
- Показывает лидерборд с реальными именами
- Текущий игрок подсвечен
- Тир-бейдж отображает правильный тир
- Кнопка «Полный рейтинг» вызывает `showNativeLeaderboards()`
- Кнопка «Подключить» вызывает `signIn()`

### Integration-тесты

**`test/integration/score_submission_test.dart`**
- После завершения сессии отправляется недельный XP
- При личном рекорде отправляется лучшее время
- Если Game Services не авторизован — отправка пропускается без ошибок

---

## Затронутые файлы

| Файл | Изменение |
|---|---|
| `pubspec.yaml` | Добавить `games_services` |
| `lib/shared/services/game_services_service.dart` | Создать — сервис Game Center / Play Games |
| `lib/models/leaderboard_entry.dart` | Создать — модель записи лидерборда |
| `lib/features/league/providers/game_services_provider.dart` | Создать — провайдеры Game Services |
| `lib/features/league/providers/league_provider.dart` | Обновить — реальные данные вместо NPC |
| `lib/features/league/screens/league_screen.dart` | Обновить — реальный лидерборд + кнопка нативного UI |
| `lib/features/game/screens/result_screen.dart` | Обновить — отправка скоров после сессии |
| `lib/main.dart` | Добавить — инициализация Game Services при старте |
| `l10n/app_ru.arb` | Добавить строки |
| `l10n/app_en.arb` | Добавить строки |
| `ios/Runner.xcodeproj` | Включить Game Center capability |
| `android/app/src/main/AndroidManifest.xml` | Добавить Play Games metadata |

---

## Критерии готовности

- [ ] `games_services` подключён и настроен для iOS и Android
- [ ] Game Center / Play Games авторизация работает при запуске
- [ ] Имя игрока отображается из Game Center / Play Games
- [ ] 7 лидербордов созданы и настроены на обеих платформах
- [ ] Недельный XP отправляется после каждой сессии
- [ ] Лучшее время отправляется при личном рекорде
- [ ] Таб «Лига» показывает реальных игроков
- [ ] Текущий игрок подсвечен в лидерборде
- [ ] Тир рассчитывается локально и отображается как бейдж
- [ ] Кнопка «Полный рейтинг» открывает нативный UI
- [ ] Если Game Services не подключён — показывается карточка подключения
- [ ] Все unit-тесты проходят
- [ ] Все widget-тесты проходят
- [ ] Все integration-тесты проходят
- [ ] Локализация на RU и EN
