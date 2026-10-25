import '../../constants/game_modes.dart';
import '../../l10n/app_localizations.dart';

/// Localized name of a game mode.
String gameModeLabel(AppLocalizations l10n, String mode) => switch (mode) {
      GameModes.reverse => l10n.gameModeReverse,
      GameModes.gorbov => l10n.gameModeGorbov,
      GameModes.letters => l10n.gameModeLetters,
      _ => l10n.gameModeClassic,
    };

/// One-line rule of a game mode, shown under the mode selector.
String gameModeHint(AppLocalizations l10n, String mode) => switch (mode) {
      GameModes.reverse => l10n.gameModeReverseHint,
      GameModes.gorbov => l10n.gameModeGorbovHint,
      GameModes.letters => l10n.gameModeLettersHint,
      _ => l10n.gameModeClassicHint,
    };

/// Short tag for session lists; classic needs none.
String? gameModeBadge(AppLocalizations l10n, String mode) => switch (mode) {
      GameModes.reverse => l10n.gameModeReverseBadge,
      GameModes.gorbov => l10n.gameModeGorbovBadge,
      GameModes.letters => l10n.gameModeLettersBadge,
      _ => null,
    };
