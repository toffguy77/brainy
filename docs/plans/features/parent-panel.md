---
title: Панель родителя
tags: [parent, pin, dashboard, settings, share]
---

# Панель родителя

## Обзор

Отдельный интерфейс для родителей с PIN-защитой. Включает дашборд прогресса ребёнка и настройки — всё доступно всем пользователям. Вход через иконку шестерёнки на главном экране.

## PIN-защита

Маршрут: `/parent/pin`.

- 4-значный PIN (`AppConstants.parentPinLength`)
- Первый вход — установка PIN, последующие — проверка
- PIN хранится в Hive (ключ `parentPinHash`)
- 3 неудачных попытки -> блокировка на 30 секунд (`parentMaxPinAttempts`, `parentLockoutSeconds`).
  Счётчик и момент окончания блокировки хранятся в Hive (`parentPinFailedAttempts`,
  `parentPinLockedUntil`, класс `PinLockout`), поэтому выход с экрана или перезапуск блокировку
  не снимают. Верный PIN сбрасывает счётчик. Несовпадение при подтверждении нового PIN — опечатка,
  а не подбор: показывается ошибка, но попытка не считается.
- Красивый нумпад с индикатором прогресса (4 точки)

## Дашборд

Маршрут: `/parent/dashboard`.

После верификации PIN открывается полный дашборд. Ограничений по доступу нет.

### Содержимое дашборда

1. **Карточка «Эта неделя»**: стрик (дни), среднее время (сек), количество сессий — по всем режимам
   за последние 7 дней;
   строка дневной цели «Сегодня: X из N мин» / «Цель дня выполнена!»
2. **Переключатель режима** (`ModeFilterChips`, общий `statsModeProvider` с экраном прогресса):
   классика / обратный / Горбов / буквы
3. **График прогресса**: LineChart (fl_chart) — лучшее за день время 5x5 выбранного режима за 14 дней
4. **Лучшие результаты**: чипы по размерам выбранного режима (`gridSizesForMode`) с рекордами
5. **Последние 10 сессий** (все режимы): дата, размер, время (`shareSeconds`), звёзды, бейдж рекорда.
   Неклассические режимы помечены бейджем из ARB: «Обр» / «Горб» (#E17055) / «Букв»

AppBar: заголовок «Прогресс ребёнка», кнопки Share и Settings.

## Настройки родителя

Маршрут: `/parent/settings`.

Настройки:
- **Размер таблицы**: авто (ребёнок выбирает сам, главный экран подсказывает следующий размер) /
  фиксированный (любой из 3x3..9x9; на главной зажимается под режим). Ключи Hive:
  `parentGridSizeModeKey`, `parentFixedGridSizeKey`
- **Дневная цель**: 5 / 10 / 15 минут (`AppConstants.frequencyOptions`), значение
  `UserProgress.dailyGoalMinutes` — то же, что выбрано в онбординге
- **Уведомления**: тоггл вкл/выкл + выбор времени через TimePicker. Ключ: `notificationsEnabledKey`.
  Включение запрашивает системное разрешение; при отказе тоггл остаётся выключенным и
  показывается подсказка открыть настройки iOS.
- **Сменить PIN** — `/parent/pin?mode=change`: сначала текущий PIN, затем новый с подтверждением
- **Версия приложения** (`appVersionLabel`, из `package_info_plus`); тап копирует её в буфер
- **Политика конфиденциальности** и **Условия использования** — ссылки из ARB, открываются в браузере
- **Звук и вибрация**: тогглы. Ключи: `soundEnabledKey`, `hapticEnabledKey`

## Карточка для соцсетей

Виджет `ShareCard` рендерит PNG-карточку и открывает системный share sheet:
- Название приложения (`l10n.appName`), заголовок со стриком (ICU-плюрал, для стрика 0 —
  «Начинаем тренировки!»), стрик и лучший результат classic 5x5 (единица — `shareSeconds`)
- Слот рекорда скрыт, если рекорда classic 5x5 нет; рекорды других режимов и размеров его не заменяют
- `ShareCard.fromState(progress, records, l10n)` — единый путь сборки для приложения и тестов
- Рендер — пакет `screenshot` (`captureFromLongWidget`), файл во временной директории, отправка —
  `share_plus` (`SharePlus.instance.share` с `sharePositionOrigin` от контекста кнопки, чтобы на
  iPad поповер был привязан к кнопке)
- Ошибка рендера или шаринга показывает SnackBar `shareFailed`
- Вызывается из AppBar дашборда (кнопка Share)

Файл: `brainy-app/lib/features/parent/widgets/share_card.dart`

## Ключевые файлы

- `brainy-app/lib/features/parent/screens/parent_dashboard_screen.dart`
- `brainy-app/lib/features/parent/screens/parent_pin_screen.dart`
- `brainy-app/lib/features/parent/screens/parent_settings_screen.dart`
- `brainy-app/lib/features/parent/providers/parent_provider.dart`
- `brainy-app/lib/features/parent/providers/pin_lockout.dart`
