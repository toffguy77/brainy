import 'package:hive/hive.dart';

class CharacterData extends HiveObject {
  final String id;
  final String nameRu;
  final String nameEn;
  bool isUnlocked;
  List<String> unlockedAccessories;
  String? equippedHat;
  String? equippedGlasses;
  String? equippedEffect;
  String? equippedCape;

  CharacterData({
    required this.id,
    required this.nameRu,
    required this.nameEn,
    this.isUnlocked = false,
    List<String>? unlockedAccessories,
    this.equippedHat,
    this.equippedGlasses,
    this.equippedEffect,
    this.equippedCape,
  }) : unlockedAccessories = unlockedAccessories ?? [];
}

// Field indices 0-8 are permanent. Future fields must start at 9+.
class CharacterDataAdapter extends TypeAdapter<CharacterData> {
  @override
  final int typeId = 2;

  @override
  CharacterData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return CharacterData(
      id: fields[0] as String,
      nameRu: fields[1] as String? ?? '',
      nameEn: fields[2] as String? ?? '',
      isUnlocked: fields[3] as bool? ?? false,
      unlockedAccessories: (fields[4] as List?)?.cast<String>() ?? [],
      equippedHat: fields[5] as String?,
      equippedGlasses: fields[6] as String?,
      equippedEffect: fields[7] as String?,
      equippedCape: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CharacterData obj) {
    writer
      ..writeByte(9) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nameRu)
      ..writeByte(2)
      ..write(obj.nameEn)
      ..writeByte(3)
      ..write(obj.isUnlocked)
      ..writeByte(4)
      ..write(obj.unlockedAccessories)
      ..writeByte(5)
      ..write(obj.equippedHat)
      ..writeByte(6)
      ..write(obj.equippedGlasses)
      ..writeByte(7)
      ..write(obj.equippedEffect)
      ..writeByte(8)
      ..write(obj.equippedCape);
  }
}
