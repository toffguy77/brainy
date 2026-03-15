import '../../../models/accessory.dart';

const defaultAccessories = [
  // Hats (5)
  AccessoryInfo(
    id: 'hat_scientist',
    nameRu: 'Колпак учёного',
    nameEn: 'Scientist Cap',
    slot: AccessorySlot.hat,
    price: 50,
    assetPath: 'assets/accessories/hat_scientist.png',
  ),
  AccessoryInfo(
    id: 'hat_crown',
    nameRu: 'Корона',
    nameEn: 'Crown',
    slot: AccessorySlot.hat,
    price: 100,
    assetPath: 'assets/accessories/hat_crown.png',
  ),
  AccessoryInfo(
    id: 'hat_cap',
    nameRu: 'Кепка',
    nameEn: 'Baseball Cap',
    slot: AccessorySlot.hat,
    price: 30,
    assetPath: 'assets/accessories/hat_cap.png',
  ),
  AccessoryInfo(
    id: 'hat_helmet',
    nameRu: 'Шлем',
    nameEn: 'Helmet',
    slot: AccessorySlot.hat,
    price: 80,
    assetPath: 'assets/accessories/hat_helmet.png',
  ),
  AccessoryInfo(
    id: 'hat_tophat',
    nameRu: 'Цилиндр',
    nameEn: 'Top Hat',
    slot: AccessorySlot.hat,
    price: 120,
    assetPath: 'assets/accessories/hat_tophat.png',
  ),

  // Glasses (4)
  AccessoryInfo(
    id: 'glasses_smart',
    nameRu: 'Умные очки',
    nameEn: 'Smart Glasses',
    slot: AccessorySlot.glasses,
    price: 40,
    assetPath: 'assets/accessories/glasses_smart.png',
  ),
  AccessoryInfo(
    id: 'glasses_sun',
    nameRu: 'Солнцезащитные',
    nameEn: 'Sunglasses',
    slot: AccessorySlot.glasses,
    price: 60,
    assetPath: 'assets/accessories/glasses_sun.png',
  ),
  AccessoryInfo(
    id: 'glasses_pixel',
    nameRu: 'Пиксельные',
    nameEn: 'Pixel Glasses',
    slot: AccessorySlot.glasses,
    price: 90,
    assetPath: 'assets/accessories/glasses_pixel.png',
  ),
  AccessoryInfo(
    id: 'glasses_vr',
    nameRu: 'VR-шлем',
    nameEn: 'VR Headset',
    slot: AccessorySlot.glasses,
    price: 150,
    assetPath: 'assets/accessories/glasses_vr.png',
  ),

  // Effects (3)
  AccessoryInfo(
    id: 'effect_stars',
    nameRu: 'Звёзды',
    nameEn: 'Stars',
    slot: AccessorySlot.effect,
    price: 70,
    assetPath: 'assets/accessories/effect_stars.png',
  ),
  AccessoryInfo(
    id: 'effect_fire',
    nameRu: 'Огонь',
    nameEn: 'Fire',
    slot: AccessorySlot.effect,
    price: 100,
    assetPath: 'assets/accessories/effect_fire.png',
    isPremium: true,
  ),
  AccessoryInfo(
    id: 'effect_electric',
    nameRu: 'Электричество',
    nameEn: 'Electricity',
    slot: AccessorySlot.effect,
    price: 100,
    assetPath: 'assets/accessories/effect_electric.png',
    isPremium: true,
  ),

  // Capes (3)
  AccessoryInfo(
    id: 'cape_mantle',
    nameRu: 'Мантия',
    nameEn: 'Mantle',
    slot: AccessorySlot.cape,
    price: 80,
    assetPath: 'assets/accessories/cape_mantle.png',
  ),
  AccessoryInfo(
    id: 'cape_ninja',
    nameRu: 'Плащ ниндзя',
    nameEn: 'Ninja Cloak',
    slot: AccessorySlot.cape,
    price: 120,
    assetPath: 'assets/accessories/cape_ninja.png',
  ),
  AccessoryInfo(
    id: 'cape_wings',
    nameRu: 'Крылья',
    nameEn: 'Wings',
    slot: AccessorySlot.cape,
    price: 200,
    assetPath: 'assets/accessories/cape_wings.png',
  ),
];
