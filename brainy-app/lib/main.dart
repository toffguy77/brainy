import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'constants/app_constants.dart';
import 'models/character.dart';
import 'models/session.dart';
import 'models/user_progress.dart';
import 'features/league/providers/game_services_provider.dart';
import 'shared/services/notification_service.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Send all uncaught Flutter errors to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    await Hive.initFlutter();
    Hive.registerAdapter(GameSessionAdapter());
    Hive.registerAdapter(UserProgressAdapter());
    Hive.registerAdapter(CharacterDataAdapter());
    await Hive.openBox<GameSession>(AppConstants.sessionsBox);
    await Hive.openBox<int>(AppConstants.recordsBox);
    await Hive.openBox(AppConstants.userBox);
    await Hive.openBox<CharacterData>(AppConstants.characterBox);
    await Hive.openBox<UserProgress>(AppConstants.progressBox);
    await NotificationService.initialize();
    runApp(
      const ProviderScope(
        child: BrainyApp(),
      ),
    );
  }, (error, stack) {
    // Send all uncaught async errors to Crashlytics
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

class BrainyApp extends StatelessWidget {
  const BrainyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return _NotificationRescheduler(
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
        theme: AppTheme.darkTheme,
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          for (final code in AppConstants.supportedLanguages) Locale(code),
        ],
        // Any device language other than ru/en falls back to English, the
        // same rule notifications use outside the widget tree.
        localeResolutionCallback: (locale, _) =>
            Locale(AppConstants.resolveLanguage(locale?.languageCode)),
      ),
    );
  }
}

class _NotificationRescheduler extends ConsumerStatefulWidget {
  final Widget child;
  const _NotificationRescheduler({required this.child});

  @override
  ConsumerState<_NotificationRescheduler> createState() =>
      _NotificationReschedulerState();
}

class _NotificationReschedulerState
    extends ConsumerState<_NotificationRescheduler> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reschedule();
      _signInToGameServices();
    });
  }

  void _reschedule() {
    NotificationService.rescheduleFromStorage();
  }

  void _signInToGameServices() {
    final service = ref.read(gameServicesProvider);
    service.signIn().then((_) {
      if (!mounted) return;
      ref.read(isGameServicesSignedInProvider.notifier).state =
          service.isSignedIn;
      // Use custom name from Hive if set, otherwise Game Center name
      final box = Hive.box(AppConstants.userBox);
      final customName =
          box.get(AppConstants.customPlayerNameKey) as String?;
      ref.read(playerNameProvider.notifier).state =
          customName ?? service.playerName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
