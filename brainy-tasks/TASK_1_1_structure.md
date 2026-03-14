# Задание 1.1 — Структура проекта и навигация

> **Используй вместе с MASTER_CONTEXT.md**

---

## Цель

Создать полностью рабочий Flutter проект с правильной структурой папок, всеми зависимостями и базовой навигацией между заглушками экранов. После выполнения этого задания проект должен запускаться на iOS симуляторе и показывать навигацию между экранами.

---

## Шаг 1 — Создание проекта

```bash
flutter create brainy --org com.brainyapp --platforms ios,android
cd brainy
```

---

## Шаг 2 — pubspec.yaml

Замени содержимое `pubspec.yaml` на:

```yaml
name: brainy
description: Brain training app for kids with Schulte tables
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Navigation
  go_router: ^13.0.0

  # Local storage
  hive_flutter: ^1.1.0

  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.8

  # Subscriptions
  purchases_flutter: ^6.3.0

  # Animations
  lottie: ^2.7.0

  # Ads
  google_mobile_ads: ^4.0.0

  # Utils
  intl: ^0.19.0
  shared_preferences: ^2.2.2
  collection: ^1.18.0
  uuid: ^4.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.9
  hive_generator: ^2.0.1

flutter:
  uses-material-design: true
  generate: true

  assets:
    - assets/characters/
    - assets/animations/
    - assets/sounds/

  fonts:
    - family: Nunito
      fonts:
        - asset: assets/fonts/Nunito-Regular.ttf
        - asset: assets/fonts/Nunito-Bold.ttf
          weight: 700
        - asset: assets/fonts/Nunito-ExtraBold.ttf
          weight: 800
```

---

## Шаг 3 — Структура папок

Создай все папки и пустые файлы точно по этой структуре:

```
lib/
├── main.dart
├── app/
│   ├── router.dart
│   └── theme.dart
├── features/
│   ├── onboarding/
│   │   └── screens/
│   │       └── onboarding_screen.dart
│   ├── game/
│   │   ├── screens/
│   │   │   ├── game_screen.dart
│   │   │   └── result_screen.dart
│   │   ├── widgets/
│   │   │   └── schulte_grid.dart
│   │   └── providers/
│   │       └── game_provider.dart
│   ├── character/
│   │   └── screens/
│   │       └── character_screen.dart
│   ├── progress/
│   │   └── screens/
│   │       └── progress_screen.dart
│   ├── parent/
│   │   └── screens/
│   │       └── parent_screen.dart
│   └── subscription/
│       └── screens/
│           └── paywall_screen.dart
├── shared/
│   ├── widgets/
│   │   ├── brainy_button.dart
│   │   └── brainy_card.dart
│   └── services/
│       ├── firebase_service.dart
│       └── analytics_service.dart
├── models/
│   ├── session.dart
│   ├── character.dart
│   └── user_progress.dart
└── constants/
    ├── app_colors.dart
    ├── app_text_styles.dart
    └── app_constants.dart

assets/
├── characters/    (пустая папка, добавь .gitkeep)
├── animations/    (пустая папка, добавь .gitkeep)
├── sounds/        (пустая папка, добавь .gitkeep)
└── fonts/         (скачай Nunito с Google Fonts)

l10n/
├── app_en.arb
└── app_ru.arb
```

---

## Шаг 4 — Константы цветов

**`lib/constants/app_colors.dart`:**

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C5CE7);
  static const Color secondary = Color(0xFF00CEC9);
  static const Color accent = Color(0xFFFDCB6E);
  static const Color success = Color(0xFF00B894);
  static const Color error = Color(0xFFFF7675);
  static const Color background = Color(0xFF0D0D1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0C0);

  // Градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
```

---

## Шаг 5 — Тема

**`lib/app/theme.dart`:**

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
    ),
    fontFamily: 'Nunito',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: 'Nunito',
        ),
      ),
    ),
  );
}
```

---

## Шаг 6 — Роутер

**`lib/app/router.dart`:**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/game/screens/game_screen.dart';
import '../features/game/screens/result_screen.dart';
import '../features/character/screens/character_screen.dart';
import '../features/progress/screens/progress_screen.dart';
import '../features/parent/screens/parent_screen.dart';
import '../features/subscription/screens/paywall_screen.dart';
import 'main_shell.dart';

final router = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/game',
          builder: (context, state) => const GameScreen(),
        ),
        GoRoute(
          path: '/result',
          builder: (context, state) => const ResultScreen(),
        ),
        GoRoute(
          path: '/character',
          builder: (context, state) => const CharacterScreen(),
        ),
        GoRoute(
          path: '/progress',
          builder: (context, state) => const ProgressScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/parent',
      builder: (context, state) => const ParentScreen(),
    ),
    GoRoute(
      path: '/paywall',
      builder: (context, state) => const PaywallScreen(),
    ),
  ],
);
```

---

## Шаг 7 — Main Shell (нижняя навигация)

Создай файл **`lib/app/main_shell.dart`:**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        selectedIndex: _selectedIndex(context),
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Играть',
          ),
          NavigationDestination(
            icon: Icon(Icons.face_rounded),
            label: 'Персонаж',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Прогресс',
          ),
        ],
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/character')) return 1;
    if (location.startsWith('/progress')) return 2;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/game'); break;
      case 1: context.go('/character'); break;
      case 2: context.go('/progress'); break;
    }
  }
}
```

---

## Шаг 8 — main.dart

**`lib/main.dart`:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'app/router.dart';
import 'app/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: BrainyApp(),
    ),
  );
}

class BrainyApp extends StatelessWidget {
  const BrainyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Brainy',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
      ],
    );
  }
}
```

---

## Шаг 9 — Заглушки экранов

Создай заглушку для каждого экрана. Пример для **`lib/features/game/screens/game_screen.dart`:**

```dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Игра'),
      ),
      body: const Center(
        child: Text(
          'Game Screen',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
```

Создай аналогичные заглушки для всех остальных экранов:
- `result_screen.dart` — «Result Screen»
- `character_screen.dart` — «Character Screen»
- `progress_screen.dart` — «Progress Screen»
- `parent_screen.dart` — «Parent Screen»
- `paywall_screen.dart` — «Paywall Screen»
- `onboarding_screen.dart` — «Onboarding Screen»

---

## Шаг 10 — Локализация (базовая)

**`l10n/app_ru.arb`:**
```json
{
  "@@locale": "ru",
  "appName": "Brainy",
  "play": "Играть",
  "character": "Персонаж",
  "progress": "Прогресс",
  "settings": "Настройки",
  "continue": "Продолжить",
  "skip": "Пропустить",
  "back": "Назад"
}
```

**`l10n/app_en.arb`:**
```json
{
  "@@locale": "en",
  "appName": "Brainy",
  "play": "Play",
  "character": "Character",
  "progress": "Progress",
  "settings": "Settings",
  "continue": "Continue",
  "skip": "Skip",
  "back": "Back"
}
```

Добавь в `pubspec.yaml` в секцию `flutter:`:
```yaml
  generate: true
```

Создай файл **`l10n.yaml`** в корне проекта:
```yaml
arb-dir: l10n
template-arb-file: app_ru.arb
output-localization-file: app_localizations.dart
```

---

## Критерии готовности

После выполнения задания:

- [ ] `flutter pub get` проходит без ошибок
- [ ] `flutter run` запускает приложение на iOS симуляторе
- [ ] Видна нижняя навигация с 3 пунктами
- [ ] Переключение между вкладками работает
- [ ] Все экраны показывают заглушку без крашей
- [ ] Тёмный фон `#0D0D1A` на всех экранах
