import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../constants/app_constants.dart';

class SoundService {
  SoundService._();

  static final AudioPlayer _player = AudioPlayer();
  static final Set<String> _validAssets = {};
  static bool _validated = false;

  static bool get isEnabled {
    final box = Hive.box(AppConstants.userBox);
    return box.get(AppConstants.soundEnabledKey) as bool? ?? true;
  }

  static Future<void> setEnabled(bool enabled) async {
    final box = Hive.box(AppConstants.userBox);
    await box.put(AppConstants.soundEnabledKey, enabled);
  }

  static Future<void> _validateAssets() async {
    if (_validated) return;
    _validated = true;
    for (final effect in SoundEffect.values) {
      try {
        final data = await rootBundle.load('assets/sounds/${effect.filename}');
        if (data.lengthInBytes > 0) {
          _validAssets.add(effect.filename);
        }
      } catch (_) {}
    }
  }

  static Future<void> play(SoundEffect effect) async {
    if (!isEnabled) return;
    await _validateAssets();
    if (!_validAssets.contains(effect.filename)) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/${effect.filename}'));
    } catch (_) {
      _validAssets.remove(effect.filename);
    }
  }
}

enum SoundEffect {
  tapCorrect('tap_correct.wav'),
  tapWrong('tap_wrong.wav'),
  gameStart('game_start.wav'),
  gameComplete('game_complete.wav'),
  recordBroken('record_broken.wav'),
  achievement('achievement.wav'),
  coins('coins.wav'),
  levelUp('level_up.wav'),
  streak('streak.wav');

  final String filename;
  const SoundEffect(this.filename);
}
