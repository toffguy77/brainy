import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/game_services_service.dart';

/// Singleton GameServicesService instance.
final gameServicesProvider = Provider<GameServicesService>((ref) {
  return GameServicesService();
});

/// Whether the player is signed in to Game Center / Play Games.
/// Updated via ref.read(isGameServicesSignedInProvider.notifier).state = true
/// after successful signIn().
final isGameServicesSignedInProvider = StateProvider<bool>((ref) => false);

/// Player display name from Game Center / Play Games.
/// Updated after sign-in.
final playerNameProvider = StateProvider<String?>((ref) => null);
