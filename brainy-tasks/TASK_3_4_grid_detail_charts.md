# Задание 3.4 — Графики динамики по размерам таблиц

> **Используй вместе с MASTER_CONTEXT.md**
> Выполняется после задания 3.3.

---

## Цель

Добавить экран детальной статистики по конкретному размеру таблицы. При тапе на чип рекорда на странице прогресса (например, «5×5 22s») открывается экран с графиком динамики, фильтрами периодов и карточками статистики.

Экран доступен **только Premium** пользователям. Free пользователи при тапе на рекорд перенаправляются на paywall.

---

## Навигация

### Обновить `lib/app/router.dart`

Добавить маршрут:

```
/progress/grid-detail?size=5  →  GridDetailScreen(gridSize: 5)
```

Маршрут внутри ShellRoute, рядом с `/progress`.

### Обновить `lib/features/progress/screens/progress_screen.dart`

Сделать `_RecordChip` тапабельным:
- Обернуть в `GestureDetector` / `InkWell`
- При тапе:
  - Если Premium → `context.push('/progress/grid-detail?size=$gridSize')`
  - Если не Premium → `context.push('/paywall')`
- Добавить визуальную индикацию кликабельности (иконка `>` или ripple-эффект)

---

## Экран детальной статистики

### `lib/features/progress/screens/grid_detail_screen.dart`

**Параметр:** `gridSize` (int) — размер таблицы

**Структура:**

```
AppBar: «Таблица N×N» + кнопка назад
│
├── Фильтры периодов (горизонтальная строка чипов):
│   └── Нед | Мес | 3М | Год | Всё
│       По умолчанию: Нед (если есть данные), иначе Всё
│
├── Карточка графика (surface, border-radius 20):
│   ├── Заголовок «ВРЕМЯ ПРОХОЖДЕНИЯ»
│   └── LineChart (fl_chart):
│       ├── Линия daily best (сплошная, primary, stroke 2.5)
│       ├── Градиент-заливка под линией (primary, 15% → 0%)
│       ├── Точки daily best (primary, stroke 2, с обводкой surface)
│       ├── Scatter-точки всех сессий (primary, opacity 0.2, radius 3)
│       ├── Пунктирная горизонтальная линия рекорда (success, opacity 0.6)
│       │   └── Подпись «Ns ★» справа
│       ├── Ось Y: секунды (AppColors.textSecondary, size 10)
│       └── Ось X: даты, формат зависит от периода:
│           - Нед: Пн, Вт, ..., Вс
│           - Мес: 1, 5, 10, 15, 20, 25, 30
│           - 3М: Мес1, Мес2, Мес3 (названия месяцев)
│           - Год: Янв, Фев, ..., Дек
│           - Всё: авто (по месяцам или годам)
│
├── Легенда:
│   ├── ── Daily best
│   ├── ○ Все попытки
│   └── --- Рекорд
│
└── Карточки статистики (строка из 3):
    ├── Лучшее время (success цвет) + звёзды
    ├── Среднее время (accent цвет) + звёзды
    └── Всего игр (primary цвет)
```

---

## Провайдер данных для графика

### `lib/features/progress/providers/grid_stats_provider.dart`

```dart
enum TimePeriod { week, month, threeMonths, year, allTime }

class GridStatsState {
  final int gridSize;
  final TimePeriod period;
  final List<FlSpot> dailyBestSpots;     // точки для линии daily best
  final List<FlSpot> allSessionSpots;     // scatter-точки всех сессий
  final int? bestTime;                     // рекорд за весь период
  final double? averageTime;               // среднее за выбранный период
  final int totalGames;                    // кол-во игр за период
  final int bestTimeAllTime;               // абсолютный рекорд (для пунктирной линии)
}
```

Логика:
1. Фильтровать `sessions` по `gridSize` и `mode == 'classic'`
2. Фильтровать по выбранному периоду (`TimePeriod`)
3. Группировать по дням → для каждого дня выбрать минимальный `durationSeconds` → daily best
4. Все сессии за период → scatter-точки
5. Вычислить: лучшее, среднее, общее кол-во
6. Данные пересчитываются при смене `period`

---

## Обработка пустого состояния

Если нет данных для выбранного размера/периода:

```
Карточка графика:
  └── «Ещё нет данных для N×N»
      «Сыграйте несколько раз, чтобы увидеть прогресс»
```

---

## Локализация

### Добавить в `lib/l10n/app_ru.arb` и `lib/l10n/app_en.arb`:

```
gridDetailTitle: "Таблица {size}×{size}" / "Table {size}×{size}"
periodWeek: "Нед" / "Week"
periodMonth: "Мес" / "Month"
periodThreeMonths: "3М" / "3M"
periodYear: "Год" / "Year"
periodAll: "Всё" / "All"
chartTimeLabel: "ВРЕМЯ ПРОХОЖДЕНИЯ" / "COMPLETION TIME"
statBestTime: "Лучшее" / "Best"
statAverageTime: "Среднее" / "Average"
statTotalGames: "Всего игр" / "Total games"
gridDetailNoData: "Ещё нет данных для {size}×{size}" / "No data yet for {size}×{size}"
gridDetailPlayMore: "Сыграйте несколько раз, чтобы увидеть прогресс" / "Play a few games to see progress"
legendDailyBest: "Daily best" / "Daily best"
legendAllAttempts: "Все попытки" / "All attempts"
legendRecord: "Рекорд" / "Record"
```

---

## Стилевые детали

- Цвета: строго из `AppColors` (primary, secondary, accent, success, surface, background)
- Шрифт: Nunito, веса 600/700/800
- Border-radius: 16–20px
- Анимация графика: `duration: Duration(milliseconds: 300)` при смене периода
- График: `curveSmoothness: 0.3` в fl_chart для плавных кривых
- Тёмная тема: все элементы на `background` (#0D0D1A), карточки на `surface` (#1A1A2E)

---

## Критерии готовности

- [ ] Тап на чип рекорда открывает `GridDetailScreen` для выбранного размера
- [ ] Free пользователи перенаправляются на paywall
- [ ] Фильтры периодов переключаются и данные обновляются
- [ ] График показывает линию daily best с градиентом
- [ ] Scatter-точки всех сессий отображаются полупрозрачными
- [ ] Пунктирная линия рекорда видна на графике
- [ ] Карточки статистики показывают лучшее/среднее/всего
- [ ] Пустое состояние отображается корректно
- [ ] Локализация RU + EN
- [ ] Анимация при смене периода
