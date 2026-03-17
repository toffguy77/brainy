import 'package:hive/hive.dart';

class UserProgress extends HiveObject {
  int coins;
  int xp;
  int level;
  int currentStreak;
  int longestStreak;
  DateTime? lastPlayedDate;
  String childAge;
  List<String> goals;
  int dailyGoalMinutes;
  String activeCharacterId;
  int lastSelectedGridSize;
  List<String> unlockedAccessories;
  List<String> unlockedAchievements;

  UserProgress({
    this.coins = 0,
    this.xp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastPlayedDate,
    this.childAge = '',
    this.goals = const [],
    this.dailyGoalMinutes = 10,
    this.activeCharacterId = 'brainy',
    this.lastSelectedGridSize = 5,
    List<String>? unlockedAccessories,
    List<String>? unlockedAchievements,
  })  : unlockedAccessories = unlockedAccessories ?? [],
        unlockedAchievements = unlockedAchievements ?? [];
}

// Field indices 0-11 are permanent. Future fields must start at 12+.
class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 1;

  @override
  UserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return UserProgress(
      coins: fields[0] as int? ?? 0,
      xp: fields[1] as int? ?? 0,
      level: fields[2] as int? ?? 1,
      currentStreak: fields[3] as int? ?? 0,
      longestStreak: fields[4] as int? ?? 0,
      lastPlayedDate: fields[5] as DateTime?,
      childAge: fields[6] as String? ?? '',
      goals: (fields[7] as List?)?.cast<String>() ?? [],
      dailyGoalMinutes: fields[8] as int? ?? 10,
      activeCharacterId: fields[9] as String? ?? 'brainy',
      lastSelectedGridSize: fields[10] as int? ?? 5,
      unlockedAccessories: (fields[11] as List?)?.cast<String>() ?? [],
      unlockedAchievements: (fields[12] as List?)?.cast<String>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer
      ..writeByte(13) // number of fields
      ..writeByte(0)
      ..write(obj.coins)
      ..writeByte(1)
      ..write(obj.xp)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.currentStreak)
      ..writeByte(4)
      ..write(obj.longestStreak)
      ..writeByte(5)
      ..write(obj.lastPlayedDate)
      ..writeByte(6)
      ..write(obj.childAge)
      ..writeByte(7)
      ..write(obj.goals)
      ..writeByte(8)
      ..write(obj.dailyGoalMinutes)
      ..writeByte(9)
      ..write(obj.activeCharacterId)
      ..writeByte(10)
      ..write(obj.lastSelectedGridSize)
      ..writeByte(11)
      ..write(obj.unlockedAccessories)
      ..writeByte(12)
      ..write(obj.unlockedAchievements);
  }
}
