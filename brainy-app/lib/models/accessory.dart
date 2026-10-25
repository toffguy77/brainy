enum AccessorySlot { hat, glasses, effect, cape }

class AccessoryInfo {
  final String id;
  final String nameRu;
  final String nameEn;
  final AccessorySlot slot;
  final int price;
  final String assetPath;

  const AccessoryInfo({
    required this.id,
    required this.nameRu,
    required this.nameEn,
    required this.slot,
    required this.price,
    required this.assetPath,
  });

  String name(String locale) => locale == 'ru' ? nameRu : nameEn;
}
