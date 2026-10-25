import 'package:flutter/painting.dart';
import '../../../models/accessory.dart';

const defaultAccessories = [
  // Hats (5)
  AccessoryInfo(
    id: 'hat_scientist',
    slot: AccessorySlot.hat,
    price: 50,
    glyph: '🎓',
  ),
  AccessoryInfo(
    id: 'hat_crown',
    slot: AccessorySlot.hat,
    price: 100,
    glyph: '👑',
  ),
  AccessoryInfo(
    id: 'hat_cap',
    slot: AccessorySlot.hat,
    price: 30,
    glyph: '🧢',
  ),
  AccessoryInfo(
    id: 'hat_helmet',
    slot: AccessorySlot.hat,
    price: 80,
    glyph: '⛑️',
  ),
  AccessoryInfo(
    id: 'hat_tophat',
    slot: AccessorySlot.hat,
    price: 120,
    glyph: '🎩',
  ),

  // Glasses (4)
  AccessoryInfo(
    id: 'glasses_smart',
    slot: AccessorySlot.glasses,
    price: 40,
    glyph: '👓',
  ),
  AccessoryInfo(
    id: 'glasses_sun',
    slot: AccessorySlot.glasses,
    price: 60,
    glyph: '🕶️',
  ),
  AccessoryInfo(
    id: 'glasses_pixel',
    slot: AccessorySlot.glasses,
    price: 90,
    glyph: '⌐■-■',
  ),
  AccessoryInfo(
    id: 'glasses_vr',
    slot: AccessorySlot.glasses,
    price: 150,
    glyph: '🥽',
  ),

  // Effects (3)
  AccessoryInfo(
    id: 'effect_stars',
    slot: AccessorySlot.effect,
    price: 70,
    glyph: '✨',
  ),
  AccessoryInfo(
    id: 'effect_fire',
    slot: AccessorySlot.effect,
    price: 100,
    glyph: '🔥',
  ),
  AccessoryInfo(
    id: 'effect_electric',
    slot: AccessorySlot.effect,
    price: 100,
    glyph: '⚡',
  ),

  // Capes (3)
  AccessoryInfo(
    id: 'cape_mantle',
    slot: AccessorySlot.cape,
    price: 80,
    tint: Color(0xFFD63031),
  ),
  AccessoryInfo(
    id: 'cape_ninja',
    slot: AccessorySlot.cape,
    price: 120,
    tint: Color(0xFF2D3436),
  ),
  AccessoryInfo(
    id: 'cape_wings',
    slot: AccessorySlot.cape,
    price: 200,
    glyph: '🪽',
  ),
];
