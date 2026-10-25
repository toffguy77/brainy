import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:brainy/constants/app_constants.dart';
import 'package:brainy/constants/game_modes.dart';
import 'package:brainy/features/character/providers/character_provider.dart';
import 'package:brainy/features/game/providers/records_provider.dart';
import 'package:brainy/features/game/providers/session_completion_provider.dart';
import 'package:brainy/features/game/providers/sessions_provider.dart';
import 'package:brainy/features/game/providers/user_progress_provider.dart';
import 'package:brainy/features/league/providers/game_services_provider.dart';
import 'package:brainy/models/character.dart';
import 'package:brainy/models/game_state.dart';
import 'package:brainy/models/session.dart';
import 'package:brainy/models/user_progress.dart';
import 'package:brainy/shared/services/game_services_service.dart';

/// Records what would be posted to Game Center.
class _FakeGameServices extends GameServicesService {
  final bestTimes = <({int gridSize, int timeMs})>[];
  int weeklyXpSubmissions = 0;

  @override
  bool get isSignedIn => true;

  @override
  Future<void> submitWeeklyXp(int xp) async => weeklyXpSubmissions++;

  @override
  Future<void> submitBestTime({required int gridSize, required int timeMs}) async =>
      bestTimes.add((gridSize: gridSize, timeMs: timeMs));
}

GameState _finished(String mode, int size, int seconds, {int mistakes = 0}) =>
    GameState(
      status: GameStatus.finished,
      gridSize: size,
      mode: mode,
      elapsedSeconds: seconds,
      mistakesCount: mistakes,
    );

void main() {
  late ProviderContainer container;
  late _FakeGameServices gameServices;
  var reschedules = 0;

  ProviderContainer newContainer() => ProviderContainer(overrides: [
        gameServicesProvider.overrideWithValue(gameServices),
        sessionCompleterProvider.overrideWith((ref) => SessionCompleter(ref,
            rescheduleReminder: () async => reschedules++,
            onSideEffectError: (_, __) {})),
      ]);

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hive_complete_');
    Hive.init(dir.path);
    Hive.registerAdapter(GameSessionAdapter());
    Hive.registerAdapter(UserProgressAdapter());
    Hive.registerAdapter(CharacterDataAdapter());
    await Hive.openBox<GameSession>(AppConstants.sessionsBox);
    await Hive.openBox<int>(AppConstants.recordsBox);
    await Hive.openBox(AppConstants.userBox);
    await Hive.openBox<UserProgress>(AppConstants.progressBox);
    await Hive.openBox<CharacterData>(AppConstants.characterBox);
  });

  setUp(() async {
    await Hive.box<GameSession>(AppConstants.sessionsBox).clear();
    await Hive.box<int>(AppConstants.recordsBox).clear();
    await Hive.box<UserProgress>(AppConstants.progressBox).clear();
    await Hive.box<CharacterData>(AppConstants.characterBox).clear();
    gameServices = _FakeGameServices();
    reschedules = 0;
    container = newContainer();
  });

  tearDown(() => container.dispose());
  tearDownAll(() => Hive.close());

  Future<SessionOutcome> complete(GameState g) =>
      container.read(sessionCompleterProvider).complete(g);

  test('a failing or hanging reminder never holds up the outcome', () async {
    final errors = <Object>[];
    final failing = ProviderContainer(overrides: [
      gameServicesProvider.overrideWithValue(gameServices),
      sessionCompleterProvider.overrideWith((ref) => SessionCompleter(ref,
          rescheduleReminder: () async => throw StateError('plugin'),
          onSideEffectError: (e, _) => errors.add(e))),
    ]);
    addTearDown(failing.dispose);
    final outcome = await failing
        .read(sessionCompleterProvider)
        .complete(_finished(GameModes.classic, 3, 10));
    expect(outcome.session.gridSize, 3);
    await Future<void>.delayed(Duration.zero);
    expect(errors, hasLength(1));

    final hanging = ProviderContainer(overrides: [
      gameServicesProvider.overrideWithValue(gameServices),
      sessionCompleterProvider.overrideWith((ref) => SessionCompleter(ref,
          rescheduleReminder: () => Completer<void>().future,
          onSideEffectError: (_, __) {})),
    ]);
    addTearDown(hanging.dispose);
    final second = await hanging
        .read(sessionCompleterProvider)
        .complete(_finished(GameModes.classic, 4, 12))
        .timeout(const Duration(seconds: 2));
    expect(second.session.gridSize, 4);
  });

  test('a finished game is saved with its mode, size, time and coins', () async {
    final outcome = await complete(_finished(GameModes.reverse, 4, 24, mistakes: 2));

    final saved = Hive.box<GameSession>(AppConstants.sessionsBox)
        .get(outcome.session.id)!;
    expect(saved.mode, GameModes.reverse);
    expect(saved.gridSize, 4);
    expect(saved.durationSeconds, 24);
    expect(saved.mistakesCount, 2);
    expect(saved.coinsEarned,
        AppConstants.coinsPerSession + AppConstants.coinsForRecord);
    expect(container.read(sessionsProvider).first.id, outcome.session.id);
    expect(container.read(userProgressProvider).coins, saved.coinsEarned);
    expect(reschedules, 1);
  });

  test('a first result is a record under the {mode}_{size} key', () async {
    final outcome = await complete(_finished(GameModes.letters, 4, 30));
    expect(outcome.isRecord, isTrue);
    expect(Hive.box<int>(AppConstants.recordsBox).get('letters_4'), 30);
    expect(Hive.box<int>(AppConstants.recordsBox).get('classic_4'), isNull);
  });

  test('a slower or equal game does not overwrite the record', () async {
    await complete(_finished(GameModes.classic, 4, 20));
    final slower = await complete(_finished(GameModes.classic, 4, 24));
    final equal = await complete(_finished(GameModes.classic, 4, 20));
    expect(slower.isRecord, isFalse);
    expect(equal.isRecord, isFalse);
    expect(slower.session.coinsEarned, AppConstants.coinsPerSession);
    expect(Hive.box<int>(AppConstants.recordsBox).get('classic_4'), 20);
  });

  test('a faster game replaces an existing record', () async {
    await complete(_finished(GameModes.classic, 4, 30));
    final faster = await complete(_finished(GameModes.classic, 4, 25));
    expect(faster.isRecord, isTrue);
    expect(Hive.box<int>(AppConstants.recordsBox).get('classic_4'), 25);
  });

  test('reverse and letters records survive an app restart', () async {
    await complete(_finished(GameModes.reverse, 5, 40));
    await complete(_finished(GameModes.letters, 3, 15));

    container.dispose();
    container = newContainer(); // a restart re-reads Hive

    final records = container.read(recordsProvider.notifier);
    expect(records.getRecord(5, mode: GameModes.reverse), 40);
    expect(records.getRecord(3, mode: GameModes.letters), 15);
    final slower = await complete(_finished(GameModes.reverse, 5, 55));
    expect(slower.isRecord, isFalse);
    expect(Hive.box<int>(AppConstants.recordsBox).get('reverse_5'), 40);
  });

  test('only classic records are posted to the Game Center time boards',
      () async {
    await complete(_finished(GameModes.reverse, 5, 40));
    await complete(_finished(GameModes.letters, 5, 50));
    await complete(_finished(GameModes.gorbov, 5, 60));
    expect(gameServices.bestTimes, isEmpty);

    await complete(_finished(GameModes.classic, 5, 30));
    expect(gameServices.bestTimes, [(gridSize: 5, timeMs: 30000)]);
    expect(gameServices.weeklyXpSubmissions, 4);
  });

  test('first game unlocks first_game and personal_record achievements',
      () async {
    final outcome = await complete(_finished(GameModes.classic, 5, 30, mistakes: 1));
    final ids = outcome.newAchievements.map((a) => a.idString).toSet();
    expect(ids, containsAll(['first_game', 'personal_record']));
    expect(ids, isNot(contains('focus_mode')));

    final again = await complete(_finished(GameModes.classic, 5, 40, mistakes: 1));
    expect(again.newAchievements.map((a) => a.idString),
        isNot(contains('first_game')));
  });

  test('reaching level 10 unlocks Zap', () async {
    container.read(characterProvider); // seed default characters
    final progress = container.read(userProgressProvider.notifier);
    await progress.addXp(AppConstants.xpThresholds[10]!);

    final outcome = await complete(_finished(GameModes.classic, 3, 10));
    expect(outcome.unlockedCharacters, contains('zap'));
    expect(container.read(characterProvider.notifier).getById('zap')!.isUnlocked,
        isTrue);
  });
}
