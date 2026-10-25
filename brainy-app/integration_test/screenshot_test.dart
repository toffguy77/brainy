// integration_test/screenshot_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/features/game/widgets/schulte_grid.dart';
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
import 'package:brainy/features/character/screens/accessories_screen.dart';
import 'package:brainy/features/progress/screens/grid_detail_screen.dart';
import 'package:brainy/app/main_shell.dart';

/// Locale passed via --dart-define=LOCALE=ru (default: ru)
const _locale = String.fromEnvironment('LOCALE', defaultValue: 'ru');

/// Device folder for output: '6.7', '6.5' or 'ipad-13'. Passed by the
/// screenshots workflow via --dart-define=DEVICE=...; detected otherwise.
const _deviceDefine = String.fromEnvironment('DEVICE');
String _deviceName = _deviceDefine;

/// Save a screenshot to screenshots/raw/{device}/{locale}/{name}.png
/// Pump enough frames for the UI to render without waiting for all
/// animations to finish (many screens have looping animations).
Future<void> _pumpFrames(WidgetTester tester, {int frames = 10}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Take a screenshot. The name encodes the full path so the driver's
/// onScreenshot callback saves it to screenshots/raw/{device}/{locale}/{name}.png
Future<void> _takeScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  // Pump a few frames to let layout settle, but don't use pumpAndSettle
  // because many screens have repeating animations (bobbing character, etc.)
  await _pumpFrames(tester);
  // Encode the output path in the screenshot name.
  // The driver's onScreenshot callback saves to screenshots/{name}.png
  await binding.takeScreenshot('raw/$_deviceName/$_locale/$name');
}

/// Create a test GoRouter mirroring the app routes, without redirects
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
    level: 11, // AppConstants.xpThresholds[11] = 1350
    currentStreak: 15,
    longestStreak: 15,
    lastPlayedDate: DateTime.now(),
    childAge: '10-12',
    goals: ['concentration', 'reading'],
    dailyGoalMinutes: 10,
    activeCharacterId: 'brainy',
    lastSelectedGridSize: 5,
    unlockedAccessories: ['hat_crown', 'glasses_sun', 'cape_mantle'],
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
      mode: const ['classic', 'reverse', 'letters', 'classic'][i % 4],
      coinsEarned: 10 + (i % 3) * 5,
    );
    await sessionsBox.put(session.id, session);
  }

  // Records
  final recordsBox = Hive.box<int>(AppConstants.recordsBox);
  await recordsBox.put('classic_3', 7);
  await recordsBox.put('classic_4', 14);
  await recordsBox.put('classic_5', 18);
  await recordsBox.put('classic_6', 31);
  await recordsBox.put('reverse_5', 21);
  await recordsBox.put('letters_4', 19);

  // Characters — Brainy + Zap unlocked
  final characterBox = Hive.box<CharacterData>(AppConstants.characterBox);
  for (final info in defaultCharacters) {
    final data = CharacterData(
      id: info.id,
      nameRu: info.id,
      nameEn: info.id,
      isUnlocked: info.id == 'brainy' || info.id == 'zap',
      // Show the accessory shop's result on the avatar.
      equippedHat: info.id == 'brainy' ? 'hat_crown' : null,
      equippedGlasses: info.id == 'brainy' ? 'glasses_sun' : null,
      equippedCape: info.id == 'brainy' ? 'cape_mantle' : null,
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
    if (_deviceName.isEmpty) {
      final size = tester.view.physicalSize;
      _deviceName = size.width / size.height > 0.7
          ? 'ipad-13'
          : (size.width >= 1290 ? '6.7' : '6.5');
    }

    await _seedMockData();

    final testRouter = _createTestRouter();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          title: 'Brainy',
          debugShowCheckedModeBanner: false,
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
    await _pumpFrames(tester);

    // --- Screen 1: Home ---
    await _takeScreenshot(binding, tester, 'home');

    // --- Screen 2: Game (mid-game) ---
    testRouter.go('/game?size=5');
    await _pumpFrames(tester);
    // Wait for countdown (3 seconds)
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 500));
    await _pumpFrames(tester);
    // Tap first 8 numbers to show mid-game state
    // Scope finders to SchulteGrid to avoid matching '1' in '10', '11', etc.
    for (int num = 1; num <= 8; num++) {
      final finder = find.descendant(
        of: find.byType(SchulteGrid),
        matching: find.text('$num'),
      );
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await _pumpFrames(tester);
      }
    }
    await _pumpFrames(tester);
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
    await _pumpFrames(tester, frames: 20);
    await _takeScreenshot(binding, tester, 'characters');

    // --- Screen 5: Progress ---
    testRouter.go('/progress');
    await _pumpFrames(tester);
    await _takeScreenshot(binding, tester, 'progress');

    // --- Screen 6: Parent Dashboard ---
    parentPinVerifiedSession = true;
    testRouter.go('/parent/dashboard');
    await _pumpFrames(tester);
    await _takeScreenshot(binding, tester, 'parent');

    debugPrint('✅ All 6 screenshots captured for $_deviceName/$_locale');
  });
}
