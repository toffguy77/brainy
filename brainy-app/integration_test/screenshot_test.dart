// integration_test/screenshot_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/app/theme.dart';
import 'package:brainy/l10n/app_localizations.dart';
import 'package:brainy/models/session.dart';
import 'package:brainy/models/user_progress.dart';
import 'package:brainy/models/character.dart';
import 'package:brainy/models/achievement.dart';
import 'package:brainy/features/character/data/characters_data.dart';
import 'package:brainy/features/parent/providers/parent_provider.dart';
import 'package:brainy/features/home/screens/home_screen.dart';
import 'package:brainy/features/game/screens/game_screen.dart';
import 'package:brainy/features/game/screens/result_screen.dart';
import 'package:brainy/features/character/screens/character_screen.dart';
import 'package:brainy/features/progress/screens/progress_screen.dart';
import 'package:brainy/features/parent/screens/parent_dashboard_screen.dart';
import 'package:brainy/features/parent/screens/parent_pin_screen.dart';
import 'package:brainy/features/parent/screens/parent_settings_screen.dart';
import 'package:brainy/features/onboarding/screens/onboarding_screen.dart';
import 'package:brainy/features/league/screens/league_screen.dart';
import 'package:brainy/features/subscription/screens/paywall_screen.dart';
import 'package:brainy/features/character/screens/accessories_screen.dart';
import 'package:brainy/features/progress/screens/grid_detail_screen.dart';
import 'package:brainy/app/main_shell.dart';

/// Locale passed via --dart-define=LOCALE=ru (default: ru)
const _locale = String.fromEnvironment('LOCALE', defaultValue: 'ru');

/// Device name for output path (detected from screen size at runtime)
String _deviceName = 'unknown';

/// Save a screenshot to screenshots/raw/{device}/{locale}/{name}.png
Future<void> _takeScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  await tester.pumpAndSettle();
  final dir = Directory('screenshots/raw/$_deviceName/$_locale');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  // Use binding.takeScreenshot which works on iOS simulators
  final bytes = await binding.takeScreenshot(name);
  File('${dir.path}/$name.png').writeAsBytesSync(bytes);
}

/// Create a test GoRouter without FirebaseAnalyticsObserver
GoRouter _createTestRouter() {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final box = Hive.box(AppConstants.userBox);
      final completed =
          box.get(AppConstants.userKeyOnboardingCompleted) as bool? ?? false;
      if (completed && state.matchedLocation == '/onboarding') {
        return '/home';
      }
      if (!state.matchedLocation.startsWith('/parent')) {
        parentPinVerifiedSession = false;
      }
      if (state.matchedLocation == '/parent/dashboard' ||
          state.matchedLocation == '/parent/settings') {
        if (!parentPinVerifiedSession) {
          return '/parent/pin';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/game',
            builder: (context, state) {
              final gridSize =
                  int.tryParse(state.uri.queryParameters['size'] ?? '') ?? 5;
              final mode = state.uri.queryParameters['mode'] ?? 'classic';
              return GameScreen(gridSize: gridSize, mode: mode);
            },
          ),
          GoRoute(
            path: '/result',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ResultScreen(extra: extra);
            },
          ),
          GoRoute(
            path: '/character',
            builder: (context, state) => const CharacterScreen(),
          ),
          GoRoute(
            path: '/accessories',
            builder: (context, state) => const AccessoriesScreen(),
          ),
          GoRoute(
            path: '/progress',
            builder: (context, state) => const ProgressScreen(),
          ),
          GoRoute(
            path: '/league',
            builder: (context, state) => const LeagueScreen(),
          ),
          GoRoute(
            path: '/progress/grid-detail',
            builder: (context, state) {
              final size =
                  int.tryParse(state.uri.queryParameters['size'] ?? '') ?? 5;
              return GridDetailScreen(gridSize: size);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/parent/pin',
        builder: (context, state) => const ParentPinScreen(),
      ),
      GoRoute(
        path: '/parent/dashboard',
        builder: (context, state) => const ParentDashboardScreen(),
      ),
      GoRoute(
        path: '/parent/settings',
        builder: (context, state) => const ParentSettingsScreen(),
      ),
      GoRoute(
        path: '/paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
    ],
  );
}

/// Seed Hive boxes with mock data for beautiful screenshots
Future<void> _seedMockData() async {
  // UserProgress
  final progressBox = Hive.box<UserProgress>(AppConstants.progressBox);
  final progress = UserProgress(
    coins: 350,
    xp: 1500,
    level: 10,
    currentStreak: 15,
    longestStreak: 15,
    lastPlayedDate: DateTime.now(),
    childAge: '10-12',
    goals: ['concentration', 'reading'],
    dailyGoalMinutes: 10,
    activeCharacterId: 'brainy',
    lastSelectedGridSize: 5,
    unlockedAchievements: [
      'first_game',
      'personal_record',
      'streak_3',
      'streak_7',
      'speed_demon',
    ],
  );
  await progressBox.put(AppConstants.progressDataKey, progress);

  // Sessions — seed 20 over past 15 days
  final sessionsBox = Hive.box<GameSession>(AppConstants.sessionsBox);
  final now = DateTime.now();
  for (int i = 0; i < 20; i++) {
    final session = GameSession(
      id: 'screenshot_session_$i',
      playedAt: now.subtract(Duration(days: i % 15, hours: i)),
      gridSize: [3, 4, 5][i % 3],
      durationSeconds: 15 + (i * 2) % 20,
      mistakesCount: i % 3,
      isPersonalRecord: i == 0,
      mode: 'classic',
      coinsEarned: 10 + (i % 3) * 5,
    );
    await sessionsBox.put(session.id, session);
  }

  // Records
  final recordsBox = Hive.box<int>(AppConstants.recordsBox);
  await recordsBox.put('3', 7);
  await recordsBox.put('4', 14);
  await recordsBox.put('5', 18);

  // Characters — Brainy + Zap unlocked
  final characterBox = Hive.box<CharacterData>(AppConstants.characterBox);
  for (final info in defaultCharacters) {
    final data = CharacterData(
      id: info.id,
      nameRu: info.nameRu,
      nameEn: info.nameEn,
      isUnlocked: info.id == 'brainy' || info.id == 'zap',
    );
    await characterBox.put(info.id, data);
  }

  // Onboarding completed
  final userBox = Hive.box(AppConstants.userBox);
  await userBox.put(AppConstants.userKeyOnboardingCompleted, true);

  // Sound/haptic off for screenshots (no audio issues in test)
  await userBox.put(AppConstants.soundEnabledKey, false);
  await userBox.put(AppConstants.hapticEnabledKey, false);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Init Hive for testing
    await Hive.initFlutter();
    Hive.registerAdapter(GameSessionAdapter());
    Hive.registerAdapter(UserProgressAdapter());
    Hive.registerAdapter(CharacterDataAdapter());
    await Hive.openBox<GameSession>(AppConstants.sessionsBox);
    await Hive.openBox<int>(AppConstants.recordsBox);
    await Hive.openBox(AppConstants.userBox);
    await Hive.openBox<CharacterData>(AppConstants.characterBox);
    await Hive.openBox<UserProgress>(AppConstants.progressBox);
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('Capture App Store screenshots ($_locale)', (tester) async {
    // Detect device name from screen size
    final size = tester.view.physicalSize;
    if (size.width >= 1290) {
      _deviceName = '6.7';
    } else {
      _deviceName = '6.5';
    }

    await _seedMockData();

    final testRouter = _createTestRouter();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          title: 'Brainy',
          theme: AppTheme.darkTheme,
          routerConfig: testRouter,
          locale: Locale(_locale),
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
        ),
      ),
    );
    await tester.pumpAndSettle();

    // --- Screen 1: Home ---
    await _takeScreenshot(binding, tester, 'home');

    // --- Screen 2: Game (mid-game) ---
    testRouter.go('/game?size=5');
    await tester.pumpAndSettle();
    // Wait for countdown (3 seconds)
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    // Tap first 8 numbers to show mid-game state
    for (int num = 1; num <= 8; num++) {
      final finder = find.text('$num');
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await tester.pump(const Duration(milliseconds: 300));
      }
    }
    await tester.pumpAndSettle();
    await _takeScreenshot(binding, tester, 'game');

    // --- Screen 3: Result (3 stars, record) ---
    final mockSession = GameSession(
      id: 'screenshot_result',
      playedAt: DateTime.now(),
      gridSize: 5,
      durationSeconds: 18,
      mistakesCount: 0,
      isPersonalRecord: true,
      mode: 'classic',
      coinsEarned: 25,
    );
    testRouter.go('/result', extra: {
      'session': mockSession,
      'isRecord': true,
      'xpEarned': 25,
      'totalXp': 1500,
      'level': 10,
      'newAchievements': <AchievementDef>[
        allAchievements.firstWhere((a) => a.id == AchievementId.firstGame),
      ],
    });
    // Wait for animations (confetti runs 3s, stars pop in, coins counter)
    // NOTE: Do NOT use pumpAndSettle() here — ConfettiWidget's particle
    // system may never "settle", causing a timeout. Use explicit pumps.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 500));
    await _takeScreenshot(binding, tester, 'result');

    // --- Screen 4: Characters ---
    testRouter.go('/character');
    await tester.pumpAndSettle();
    await _takeScreenshot(binding, tester, 'characters');

    // --- Screen 5: Progress ---
    testRouter.go('/progress');
    await tester.pumpAndSettle();
    await _takeScreenshot(binding, tester, 'progress');

    // --- Screen 6: Parent Dashboard ---
    parentPinVerifiedSession = true;
    testRouter.go('/parent/dashboard');
    await tester.pumpAndSettle();
    await _takeScreenshot(binding, tester, 'parent');
  });
}
