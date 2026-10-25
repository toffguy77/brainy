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
- 3 неудачных попытки -> блокировка на 30 секунд (`parentMaxPinAttempts`, `parentLockoutSeconds`)
- Красивый нумпад с индикатором прогресса (4 точки)

## Дашборд

Маршрут: `/parent/dashboard`.

После верификации PIN открывается полный дашборд. Ограничений по доступу нет.

### Содержимое дашборда

1. **Карточка «Эта неделя»**: стрик (дни), среднее время (сек), количество сессий
2. **График прогресса**: LineChart (fl_chart) — время прохождения 5x5 за последние 14 дней, группировка по daily best
3. **Лучшие результаты**: чипы по всем размерам (3x3..9x9) с рекордами
4. **Последние 10 сессий**: дата, размер, время, звёзды, бейдж рекорда. Сессии Горбова отмечены бейджем «Г» цветом #E17055

AppBar: заголовок «Прогресс ребёнка», кнопки Share и Settings.

## Настройки родителя

Маршрут: `/parent/settings`.

Настройки:
- **Размер таблицы**: авто / фиксированный (любой из 3x3..9x9). Ключи Hive: `parentGridSizeModeKey`, `parentFixedGridSizeKey`
- **Уведомления**: тоггл вкл/выкл + выбор времени через TimePicker. Ключ: `notificationsEnabledKey`
- **Сменить PIN**
- **Звук и вибрация**: тогглы. Ключи: `soundEnabledKey`, `hapticEnabledKey`

## Карточка для соцсетей

Виджет `ShareCard` генерирует PNG-карточку с прогрессом для шаринга:
- Brainy логотип, стрик, лучший результат 5x5, прогресс за месяц
- Сохраняется через `screenshot` пакет
- Вызывается из AppBar дашборда (кнопка Share)

Файл: `brainy-app/lib/features/parent/widgets/share_card.dart`

## Ключевые файлы

- `brainy-app/lib/features/parent/screens/parent_dashboard_screen.dart`
- `brainy-app/lib/features/parent/screens/parent_pin_screen.dart`
- `brainy-app/lib/features/parent/screens/parent_settings_screen.dart`
- `brainy-app/lib/features/parent/providers/parent_provider.dart`
