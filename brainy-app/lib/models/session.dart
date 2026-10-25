import 'package:hive/hive.dart';
import '../constants/app_constants.dart';

class GameSession extends HiveObject {
  final String id;
  final DateTime playedAt;
  final int gridSize; // 3, 4, 5, 6, 7, 9
  final int durationSeconds;
  final int mistakesCount;
  final bool isPersonalRecord;
  final String mode; // one of GameModes.all
  final int coinsEarned;

  GameSession({
    required this.id,
    required this.playedAt,
    required this.gridSize,
    required this.durationSeconds,
    required this.mistakesCount,
    required this.isPersonalRecord,
    required this.mode,
    required this.coinsEarned,
  });

  int get xpEarned => gridSize * gridSize;

  int get stars {
    final thresholds = AppConstants.starThresholdsFor(mode, gridSize);
    if (thresholds == null) return 1;
    if (durationSeconds <= thresholds[0]) return 3;
    if (durationSeconds <= thresholds[1]) return 2;
    return 1;
  }
}

class GameSessionAdapter extends TypeAdapter<GameSession> {
  @override
  final int typeId = 0;

  @override
  GameSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return GameSession(
      id: fields[0] as String,
      playedAt: fields[1] as DateTime,
      gridSize: fields[2] as int,
      durationSeconds: fields[3] as int,
      mistakesCount: fields[4] as int,
      isPersonalRecord: fields[5] as bool,
      mode: fields[6] as String,
      coinsEarned: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GameSession obj) {
    writer
      ..writeByte(8) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.playedAt)
      ..writeByte(2)
      ..write(obj.gridSize)
      ..writeByte(3)
      ..write(obj.durationSeconds)
      ..writeByte(4)
      ..write(obj.mistakesCount)
      ..writeByte(5)
      ..write(obj.isPersonalRecord)
      ..writeByte(6)
      ..write(obj.mode)
      ..writeByte(7)
      ..write(obj.coinsEarned);
  }
}
