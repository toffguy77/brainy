import 'package:flutter/material.dart';

enum UnlockType { free, level, streak }

class CharacterInfo {
  final String id;
  final String nameRu;
  final String nameEn;
  final String descriptionRu;
  final String descriptionEn;
  final String unlockConditionRu;
  final String unlockConditionEn;
  final UnlockType unlockType;
  final int? requiredLevel;
  final int? requiredStreak;
  final String assetPath;
  final Color color;

  const CharacterInfo({
    required this.id,
    required this.nameRu,
    required this.nameEn,
    required this.descriptionRu,
    required this.descriptionEn,
    required this.unlockConditionRu,
    required this.unlockConditionEn,
    required this.unlockType,
    this.requiredLevel,
    this.requiredStreak,
    required this.assetPath,
    required this.color,
  });

  String name(String locale) => locale == 'ru' ? nameRu : nameEn;
  String description(String locale) => locale == 'ru' ? descriptionRu : descriptionEn;
  String unlockCondition(String locale) => locale == 'ru' ? unlockConditionRu : unlockConditionEn;
}

const defaultCharacters = [
  CharacterInfo(
    id: 'brainy',
    nameRu: 'Брейни',
    nameEn: 'Brainy',
    descriptionRu: 'Мозг с характером. Стартовый герой!',
    descriptionEn: 'A brain with personality. Starter hero!',
    unlockConditionRu: 'Доступен бесплатно',
    unlockConditionEn: 'Available for free',
    unlockType: UnlockType.free,
    assetPath: 'assets/characters/brainy.png',
    color: Color(0xFF6C5CE7),
  ),
  CharacterInfo(
    id: 'zap',
    nameRu: 'Зэп',
    nameEn: 'Zap',
    descriptionRu: 'Электрический роботёнок. Быстрый как молния!',
    descriptionEn: 'Electric little robot. Fast as lightning!',
    unlockConditionRu: 'Достигни уровня 10',
    unlockConditionEn: 'Reach level 10',
    unlockType: UnlockType.level,
    requiredLevel: 10,
    assetPath: 'assets/characters/zap.png',
    color: Color(0xFFFDCB6E),
  ),
  CharacterInfo(
    id: 'vortex',
    nameRu: 'Вортекс',
    nameEn: 'Vortex',
    descriptionRu: 'Загадочный и странный. Любит вихри.',
    descriptionEn: 'Mysterious and strange. Loves whirlwinds.',
    unlockConditionRu: 'Стрик 30 дней',
    unlockConditionEn: '30-day streak',
    unlockType: UnlockType.streak,
    requiredStreak: 30,
    assetPath: 'assets/characters/vortex.png',
    color: Color(0xFF00CEC9),
  ),
  CharacterInfo(
    id: 'pixel',
    nameRu: 'Пиксель',
    nameEn: 'Pixel',
    descriptionRu: '8-битный герой из прошлого.',
    descriptionEn: '8-bit hero from the past.',
    unlockConditionRu: 'Стрик 14 дней',
    unlockConditionEn: '14-day streak',
    unlockType: UnlockType.streak,
    requiredStreak: 14,
    assetPath: 'assets/characters/pixel.png',
    color: Color(0xFF00B894),
  ),
  CharacterInfo(
    id: 'glitch',
    nameRu: 'Глитч',
    nameEn: 'Glitch',
    descriptionRu: 'Сломан, но не сломлен.',
    descriptionEn: 'Broken, but not defeated.',
    unlockConditionRu: 'Стрик 60 дней',
    unlockConditionEn: '60-day streak',
    unlockType: UnlockType.streak,
    requiredStreak: 60,
    assetPath: 'assets/characters/glitch.png',
    color: Color(0xFFFF7675),
  ),
];
