# Информационные экраны в онбординге

> Дата: 2026-03-15

## Проблема

Текущий онбординг (5 экранов) сразу переходит к сбору данных (возраст, цели, частота) после короткого приветствия. Пользователь не получает информации о том, что такое таблицы Шульте, зачем они нужны и почему методика работает. Это особенно критично, потому что онбординг проходят родитель и ребёнок вместе — родителю нужны аргументы, ребёнку — понимание.

## Решение

Добавить 2 информационных экрана после Welcome и до сбора данных.

## Новая структура онбординга

| # | Экран | Тип | Статус |
|---|-------|-----|--------|
| 1 | Welcome | Приветствие | Без изменений |
| 2 | **Что такое Шульте** | Информационный | **Новый** |
| 3 | **Почему это работает** | Информационный | **Новый** |
| 4 | Возраст ребёнка | Сбор данных | Без изменений (был #2) |
| 5 | Главная цель | Сбор данных | Без изменений (был #3) |
| 6 | Частота занятий | Сбор данных | Без изменений (был #4) |
| 7 | Paywall | Монетизация | Без изменений (был #5) |

## Экран 2 — «Таблицы Шульте — тренажёр для мозга»

### Содержание
- **Мини-таблица 3×3** вверху экрана — статичная, фиксированная раскладка: `[3, 7, 1 / 5, 9, 4 / 8, 2, 6]`. Ячейка «1» подсвечена зелёным (`#00B894`, фон `rgba(0,190,148,0.2)`, border 2px), ячейка «2» — фиолетовым (`#6C5CE7`), остальные — белый текст на `#1A1A2E`. Размер таблицы ~160px, ячейки с border-radius 10px, gap 6px. Подпись под таблицей: «Найди числа по порядку: 1, 2, 3...» (11px, `#A0A0C0`)
- **Заголовок:** «Таблицы Шульте — тренажёр для мозга»
- **Подзаголовок:** «Находи числа по порядку как можно быстрее. Чем больше таблица — тем сложнее!»
- **Три преимущества** (emoji в контейнере 36×36 с `rgba(108,92,231,0.15)` border-radius 10px + текст 14px белый):
  - 🎯 Развивает внимание и концентрацию
  - 👁️ Расширяет периферическое зрение
  - 📖 Ускоряет чтение в 1.5–2 раза
- **Кнопка «Далее»** внизу — используется существующий `OnboardingPrimaryButton` с ключом `onboardingNext`

### Навигация
Кнопка вызывает `ref.read(onboardingProvider.notifier).nextPage()` (аналогично WelcomePage). Кнопка «Назад» в системном AppBar работает через `previousPage()` — стандартное поведение для всех экранов онбординга.

### Тон
Нейтральный, понятный и родителю, и ребёнку 10+. Не слишком детский, не слишком научный.

## Экран 3 — «Проверено наукой»

### Содержание
- **Иконка 🧠** в круге с фиолетовым фоном
- **Заголовок:** «Проверено наукой»
- **Подзаголовок:** «Методика создана немецким психиатром Вальтером Шульте в 1960-х для тренировки внимания»
- **Три факта-карточки** (крупная цифра + описание):
  - **60+ лет** — используется в нейропсихологии и педагогике (цвет: фиолетовый)
  - **2 недели** — для заметного улучшения скорости чтения при ежедневных занятиях (цвет: бирюзовый)
  - **5 мин/день** — достаточно для результата — не перегружает ребёнка (цвет: жёлтый)
- **Кнопка «Далее»** внизу — `OnboardingPrimaryButton` с ключом `onboardingNext`, вызывает `nextPage()`

### Навигация
Аналогично экрану 2 — `nextPage()` по кнопке, `previousPage()` по системной кнопке «Назад».

### Тон
Авторитетный, но доступный. Факты без ссылок на конкретные исследования (приложение для массового рынка, не научная статья).

## Технические изменения

### Новые файлы
- `lib/features/onboarding/pages/schulte_info_page.dart` — экран 2
- `lib/features/onboarding/pages/science_page.dart` — экран 3

### Изменения в существующих файлах

**`brainy-app/lib/features/onboarding/screens/onboarding_screen.dart`:**
- Добавить два новых экрана в PageView (индексы 1 и 2, существующие страницы сдвигаются на +2)

**`brainy-app/lib/app/app_constants.dart`:**
- Обновить `onboardingPageCount` с 5 на 7. Это единственное место, где хранится константа — `onboarding_screen.dart` и `onboarding_provider.dart` ссылаются на неё автоматически.

**`brainy-app/l10n/app_ru.arb`:**
- `onboardingSchulteTitle`: «Таблицы Шульте — тренажёр для мозга»
- `onboardingSchulteSubtitle`: «Находи числа по порядку как можно быстрее. Чем больше таблица — тем сложнее!»
- `onboardingSchulteHint`: «Найди числа по порядку: 1, 2, 3...»
- `onboardingSchulteBenefit1`: «Развивает внимание и концентрацию»
- `onboardingSchulteBenefit2`: «Расширяет периферическое зрение»
- `onboardingSchulteBenefit3`: «Ускоряет чтение в 1.5–2 раза»
- `onboardingScienceTitle`: «Проверено наукой»
- `onboardingScienceSubtitle`: «Методика создана немецким психиатром Вальтером Шульте в 1960-х для тренировки внимания»
- `onboardingScienceFact1Value`: «60+ лет»
- `onboardingScienceFact1Label`: «используется в нейропсихологии и педагогике»
- `onboardingScienceFact2Value`: «2 недели»
- `onboardingScienceFact2Label`: «для заметного улучшения скорости чтения при ежедневных занятиях»
- `onboardingScienceFact3Value`: «5 мин/день»
- `onboardingScienceFact3Label`: «достаточно для результата — не перегружает ребёнка»

**`brainy-app/l10n/app_en.arb`:**
- `onboardingSchulteTitle`: «Schulte Tables — Brain Trainer»
- `onboardingSchulteSubtitle`: «Find the numbers in order as fast as you can. Bigger grid — harder challenge!»
- `onboardingSchulteHint`: «Find the numbers in order: 1, 2, 3...»
- `onboardingSchulteBenefit1`: «Builds attention and concentration»
- `onboardingSchulteBenefit2`: «Expands peripheral vision»
- `onboardingSchulteBenefit3`: «Boosts reading speed 1.5–2×»
- `onboardingScienceTitle`: «Backed by Science»
- `onboardingScienceSubtitle`: «Developed by German psychiatrist Walter Schulte in the 1960s for attention training»
- `onboardingScienceFact1Value`: «60+ years»
- `onboardingScienceFact1Label`: «used in neuropsychology and education»
- `onboardingScienceFact2Value`: «2 weeks»
- `onboardingScienceFact2Label`: «to noticeably improve reading speed with daily practice»
- `onboardingScienceFact3Value`: «5 min/day»
- `onboardingScienceFact3Label`: «enough for results — won't overwhelm your child»

## Дизайн

Оба экрана следуют существующей дизайн-системе:
- Фон: `#0D0D1A`
- Карточки: `#1A1A2E`, border-radius 14px
- Иконки: в контейнере с `rgba(108,92,231,0.15)`, border-radius 10px
- Заголовки: Nunito 28px weight 800 (как на остальных экранах онбординга — age, goals, frequency)
- Подзаголовки: Nunito 15px weight 400 цвет `#A0A0C0`
- Факты-карточки: значение — 24px weight 800, описание — 13px цвет `#A0A0C0`
- Цвета фактов: фиолетовый `#6C5CE7`, бирюзовый `#00CEC9`, жёлтый `#FDCB6E`
- Кнопка «Далее»: существующий `OnboardingPrimaryButton`
- Padding: 24px horizontal, 64px top (как на остальных экранах)

## Обратная совместимость

Пользователи, уже прошедшие онбординг (`onboardingCompleted: true` в Hive), не увидят изменений — роутер перенаправляет их на `/home`. Индекс `currentPage` хранится только в runtime-стейте (Riverpod), не персистится в Hive, поэтому сдвиг индексов не вызовет проблем при обновлении.

## Что НЕ входит в скоуп
- Анимация мини-таблицы (статичная достаточна для v1)
- Изменения в существующих экранах (возраст, цели, частота, paywall)
- A/B тестирование
- Аналитика (отдельная задача)
