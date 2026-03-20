---
title: Панель родителя
tags: [parent, pin, dashboard, settings, share, premium]
---

# Панель родителя

## Обзор

Отдельный интерфейс для родителей с PIN-защитой. Включает дашборд прогресса ребёнка (Premium) и настройки (доступны всем). Вход через иконку шестерёнки на главном экране.

## PIN-защита

Маршрут: `/parent/pin`.

- 4-значный PIN (`AppConstants.parentPinLength`)
- Первый вход — установка PIN, последующие — проверка
- PIN хранится в Hive (ключ `parentPinHash`)
- 3 неудачных попытки -> блокировка на 30 секунд (`parentMaxPinAttempts`, `parentLockoutSeconds`)
- Красивый нумпад с индикатором прогресса (4 точки)

## Дашборд (Premium only)

Маршрут: `/parent/dashboard`.

После верификации PIN проверяется подписка:
- **Premium**: полный дашборд
- **Free**: экран-заглушка `_PremiumGateScreen` с замком, описанием и кнопкой «Открыть с Premium» -> `/paywall`. Кнопка «Настройки» остаётся доступной.

### Содержимое дашборда

1. **Карточка «Эта неделя»**: стрик (дни), среднее время (сек), количество сессий
2. **График прогресса**: LineChart (fl_chart) — время прохождения 5x5 за последние 14 дней, группировка по daily best
3. **Лучшие результаты**: чипы по всем размерам (3x3..9x9) с рекордами. Premium-размеры помечены для free пользователей
4. **Последние 10 сессий**: дата, размер, время, звёзды, бейдж рекорда. Сессии Горбова отмечены бейджем «Г» цветом #E17055

AppBar: заголовок «Прогресс ребёнка», кнопки Share и Settings.

## Настройки родителя

Маршрут: `/parent/settings`. Доступны всем пользователям (и free, и premium).

Настройки:
- **Размер таблицы**: авто / фиксированный (3x3..5x5). Ключи Hive: `parentGridSizeModeKey`, `parentFixedGridSizeKey`
- **Максимальное время сессии**: 5 / 10 / 15 / без ограничений. Ключ: `parentMaxSessionTimeKey`
- **Уведомления**: тоггл вкл/выкл + выбор времени через TimePicker. Ключ: `notificationsEnabledKey`
- **Сменить PIN**
- **Звук и вибрация**: тогглы. Ключи: `soundEnabledKey`, `hapticEnabledKey`
- **Управление подпиской**

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
