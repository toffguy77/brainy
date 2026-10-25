import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../features/parent/providers/parent_provider.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/game/screens/game_screen.dart';
import '../features/game/screens/result_screen.dart';
import '../features/character/screens/accessories_screen.dart';
import '../features/character/screens/character_screen.dart';
import '../features/progress/screens/progress_screen.dart';
import '../features/progress/screens/grid_detail_screen.dart';
import '../features/parent/screens/parent_pin_screen.dart';
import '../features/parent/screens/parent_dashboard_screen.dart';
import '../features/parent/screens/parent_settings_screen.dart';
import '../features/league/screens/league_screen.dart';
import 'main_shell.dart';
import '../constants/game_modes.dart';


final router = GoRouter(
  initialLocation: '/onboarding',
  redirect: (context, state) {
    final box = Hive.box(AppConstants.userBox);
    final completed =
        box.get(AppConstants.userKeyOnboardingCompleted) as bool? ?? false;
    if (completed && state.matchedLocation == '/onboarding') {
      return '/home';
    }

    // Clear PIN verification when leaving parent area
    if (!state.matchedLocation.startsWith('/parent')) {
      parentPinVerifiedSession = false;
    }

    // Guard parent dashboard/settings behind PIN verification
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
            // An unknown mode would be saved into sessions and record keys.
            final mode = state.uri.queryParameters['mode'];
            return GameScreen(
              gridSize: gridSize,
              mode: GameModes.all.contains(mode) ? mode! : GameModes.classic,
            );
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
          builder: (context, state) => AccessoriesScreen(
            characterId: state.uri.queryParameters['character'],
          ),
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
            final mode = state.uri.queryParameters['mode'];
            return GridDetailScreen(
              gridSize: size,
              mode: GameModes.all.contains(mode) ? mode! : GameModes.classic,
            );
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
