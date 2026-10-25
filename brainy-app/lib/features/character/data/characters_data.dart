import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

enum UnlockType { free, level, streak }

class CharacterInfo {
  final String id;
  final UnlockType unlockType;
  final int? requiredLevel;
  final int? requiredStreak;
  final String assetPath;
  final Color color;

  const CharacterInfo({
    required this.id,
    required this.unlockType,
    this.requiredLevel,
    this.requiredStreak,
    required this.assetPath,
    required this.color,
  });

  String name(AppLocalizations l10n) => switch (id) {
        'brainy' => l10n.characterBrainyName,
        'zap' => l10n.characterZapName,
        'vortex' => l10n.characterVortexName,
        'pixel' => l10n.characterPixelName,
        'glitch' => l10n.characterGlitchName,
        _ => id,
      };

  String description(AppLocalizations l10n) => switch (id) {
        'brainy' => l10n.characterBrainyDescription,
        'zap' => l10n.characterZapDescription,
        'vortex' => l10n.characterVortexDescription,
        'pixel' => l10n.characterPixelDescription,
        'glitch' => l10n.characterGlitchDescription,
        _ => id,
      };

  String unlockCondition(AppLocalizations l10n) => switch (id) {
        'brainy' => l10n.characterBrainyUnlock,
        'zap' => l10n.characterZapUnlock,
        'vortex' => l10n.characterVortexUnlock,
        'pixel' => l10n.characterPixelUnlock,
        'glitch' => l10n.characterGlitchUnlock,
        _ => id,
      };
}

const defaultCharacters = [
  CharacterInfo(
    id: 'brainy',
    unlockType: UnlockType.free,
    assetPath: 'assets/characters/brainy.png',
    color: Color(0xFF6C5CE7),
  ),
  CharacterInfo(
    id: 'zap',
    unlockType: UnlockType.level,
    requiredLevel: 10,
    assetPath: 'assets/characters/zap.png',
    color: Color(0xFFFDCB6E),
  ),
  CharacterInfo(
    id: 'vortex',
    unlockType: UnlockType.streak,
    requiredStreak: 30,
    assetPath: 'assets/characters/vortex.png',
    color: Color(0xFF00CEC9),
  ),
  CharacterInfo(
    id: 'pixel',
    unlockType: UnlockType.streak,
    requiredStreak: 14,
    assetPath: 'assets/characters/pixel.png',
    color: Color(0xFF00B894),
  ),
  CharacterInfo(
    id: 'glitch',
    unlockType: UnlockType.streak,
    requiredStreak: 60,
    assetPath: 'assets/characters/glitch.png',
    color: Color(0xFFFF7675),
  ),
];
