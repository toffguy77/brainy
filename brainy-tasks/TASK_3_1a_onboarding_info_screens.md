# Задание 3.1a — Информационные экраны в онбординге

> **Используй вместе с MASTER_CONTEXT.md**
> Выполняется после задания 3.1 (онбординг уже реализован).

---

## Цель

Добавить 2 информационных экрана в онбординг после Welcome и до сбора данных. Пользователь (родитель + ребёнок) должен понять, что такое таблицы Шульте, зачем они нужны и почему методика работает — до того, как начнёт отвечать на вопросы.

---

## Новая структура онбординга (7 экранов)

| # | Экран | Тип | Статус |
|---|-------|-----|--------|
| 1 | Welcome | Приветствие | Без изменений |
| 2 | **Что такое Шульте** | Информационный | **Новый** |
| 3 | **Почему это работает** | Информационный | **Новый** |
| 4 | Возраст ребёнка | Сбор данных | Без изменений (был #2) |
| 5 | Главная цель | Сбор данных | Без изменений (был #3) |
| 6 | Частота занятий | Сбор данных | Без изменений (был #4) |
| 7 | Paywall | Монетизация | Без изменений (был #5) |

---

## Страница 2 — «Таблицы Шульте — тренажёр для мозга»

### `lib/features/onboarding/pages/schulte_info_page.dart`

- **Мини-таблица 3×3** вверху экрана — статичная, фиксированная раскладка: `[3, 7, 1 / 5, 9, 4 / 8, 2, 6]`
  - Ячейка «1» — подсвечена зелёным (`success`, фон с alpha 0.2, border 2px)
  - Ячейка «2» — текст фиолетовый (`primary`)
  - Остальные — белый текст на `surface`
  - Размер таблицы ~160px, ячейки с border-radius 10px, gap 6px
  - Подпись: «Найди числа по порядку: 1, 2, 3...» (11px, `textSecondary`)
- **Заголовок:** «Таблицы Шульте — тренажёр для мозга» (28px, w800)
- **Подзаголовок:** «Находи числа по порядку как можно быстрее. Чем больше таблица — тем сложнее!» (16px, `textSecondary`)
- **Три преимущества** (emoji в контейнере 36×36 с `primary.withAlpha(38)` border-radius 10px + текст 14px белый):
  - 🎯 Развивает внимание и концентрацию
  - 👁️ Расширяет периферическое зрение
  - 📖 Ускоряет чтение в 1.5–2 раза
- **Кнопка «Далее»** — `OnboardingPrimaryButton`, ключ `onboardingNext`, вызывает `nextPage()`

---

## Страница 3 — «Проверено наукой»

### `lib/features/onboarding/pages/science_page.dart`

- **Иконка 🧠** в круге 72×72 с фоном `primary.withAlpha(38)`
- **Заголовок:** «Проверено наукой» (28px, w800)
- **Подзаголовок:** «Методика создана немецким психиатром Вальтером Шульте в 1960-х для тренировки внимания» (15px, `textSecondary`)
- **Три факта-карточки** (фон `surface`, border-radius 14px, padding 16px):
  - **60+ лет** — используется в нейропсихологии и педагогике (цвет значения: `primary`)
  - **2 недели** — для заметного улучшения скорости чтения при ежедневных занятиях (цвет: `secondary`)
  - **5 мин/день** — достаточно для результата — не перегружает ребёнка (цвет: `accent`)
  - Значение: 24px w800, описание: 13px `textSecondary`
- **Кнопка «Далее»** — `OnboardingPrimaryButton`, ключ `onboardingNext`, вызывает `nextPage()`

---

## Изменения в существующих файлах

### `lib/constants/app_constants.dart`
- `onboardingPageCount`: 5 → 7 (единственное место — остальные файлы ссылаются на эту константу)

### `lib/features/onboarding/screens/onboarding_screen.dart`
- Импорт `schulte_info_page.dart` и `science_page.dart`
- Вставить `SchulteInfoPage()` и `SciencePage()` в PageView после `WelcomePage()` (индексы 1 и 2)

### `l10n/app_ru.arb` — новые строки
```json
"onboardingSchulteTitle": "Таблицы Шульте — тренажёр для мозга",
"onboardingSchulteSubtitle": "Находи числа по порядку как можно быстрее. Чем больше таблица — тем сложнее!",
"onboardingSchulteHint": "Найди числа по порядку: 1, 2, 3...",
"onboardingSchulteBenefit1": "Развивает внимание и концентрацию",
"onboardingSchulteBenefit2": "Расширяет периферическое зрение",
"onboardingSchulteBenefit3": "Ускоряет чтение в 1.5–2 раза",
"onboardingScienceTitle": "Проверено наукой",
"onboardingScienceSubtitle": "Методика создана немецким психиатром Вальтером Шульте в 1960-х для тренировки внимания",
"onboardingScienceFact1Value": "60+ лет",
"onboardingScienceFact1Label": "используется в нейропсихологии и педагогике",
"onboardingScienceFact2Value": "2 недели",
"onboardingScienceFact2Label": "для заметного улучшения скорости чтения при ежедневных занятиях",
"onboardingScienceFact3Value": "5 мин/день",
"onboardingScienceFact3Label": "достаточно для результата — не перегружает ребёнка"
```

### `l10n/app_en.arb` — новые строки
```json
"onboardingSchulteTitle": "Schulte Tables — Brain Trainer",
"onboardingSchulteSubtitle": "Find the numbers in order as fast as you can. Bigger grid — harder challenge!",
"onboardingSchulteHint": "Find the numbers in order: 1, 2, 3...",
"onboardingSchulteBenefit1": "Builds attention and concentration",
"onboardingSchulteBenefit2": "Expands peripheral vision",
"onboardingSchulteBenefit3": "Boosts reading speed 1.5–2×",
"onboardingScienceTitle": "Backed by Science",
"onboardingScienceSubtitle": "Developed by German psychiatrist Walter Schulte in the 1960s for attention training",
"onboardingScienceFact1Value": "60+ years",
"onboardingScienceFact1Label": "used in neuropsychology and education",
"onboardingScienceFact2Value": "2 weeks",
"onboardingScienceFact2Label": "to noticeably improve reading speed with daily practice",
"onboardingScienceFact3Value": "5 min/day",
"onboardingScienceFact3Label": "enough for results — won't overwhelm your child"
```

---

## Обратная совместимость

Пользователи, уже прошедшие онбординг (`onboardingCompleted: true` в Hive), не увидят изменений — роутер перенаправляет их на `/home`. Индекс `currentPage` хранится только в runtime-стейте (Riverpod), не персистится, поэтому сдвиг индексов безопасен.

---

## Что НЕ входит в скоуп

- Анимация мини-таблицы (статичная достаточна для v1)
- Изменения в существующих экранах
- A/B тестирование
- Аналитика

---

## Критерии готовности

- [ ] PageView содержит 7 страниц, индикатор показывает 7 точек
- [ ] Экран 2 показывает мини-таблицу 3×3 с подсветкой «1» и «2»
- [ ] Экран 2 показывает 3 преимущества с emoji-иконками
- [ ] Экран 3 показывает иконку 🧠, заголовок «Проверено наукой» и 3 факта-карточки
- [ ] Кнопка «Далее» на обоих экранах переводит на следующую страницу
- [ ] Кнопка «Назад» работает на обоих экранах
- [ ] Все строки локализованы (RU + EN)
- [ ] Существующие экраны (возраст, цели, частота, paywall) работают как раньше
- [ ] `flutter analyze` проходит без ошибок
