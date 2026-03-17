import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/features/league/providers/game_services_provider.dart';
import 'package:brainy/shared/services/game_services_service.dart';

void main() {
  group('gameServicesProvider', () {
    test('provides a GameServicesService instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(gameServicesProvider);
      expect(service, isA<GameServicesService>());
    });

    test('provides same instance on multiple reads', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service1 = container.read(gameServicesProvider);
      final service2 = container.read(gameServicesProvider);
      expect(identical(service1, service2), true);
    });
  });

  group('isGameServicesSignedInProvider', () {
    test('returns false initially', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final isSignedIn = container.read(isGameServicesSignedInProvider);
      expect(isSignedIn, false);
    });

    test('can be set to true after sign-in', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(isGameServicesSignedInProvider.notifier).state = true;
      expect(container.read(isGameServicesSignedInProvider), true);
    });
  });

  group('playerNameProvider', () {
    test('returns null initially', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(playerNameProvider), isNull);
    });

    test('can be set after sign-in', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(playerNameProvider.notifier).state = 'TestPlayer';
      expect(container.read(playerNameProvider), 'TestPlayer');
    });
  });
}
