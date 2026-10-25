import 'package:flutter/painting.dart';
import '../l10n/app_localizations.dart';

enum AccessorySlot { hat, glasses, effect, cape }

class AccessoryInfo {
  final String id;
  final AccessorySlot slot;
  final int price;

  /// What is drawn on the avatar and in the shop: an emoji or text glyph.
  final String? glyph;

  /// Capes without a glyph are painted as a cape of this colour.
  final Color? tint;

  const AccessoryInfo({
    required this.id,
    required this.slot,
    required this.price,
    this.glyph,
    this.tint,
  });

  String name(AppLocalizations l10n) => switch (id) {
        'hat_scientist' => l10n.accessoryHatScientistName,
        'hat_crown' => l10n.accessoryHatCrownName,
        'hat_cap' => l10n.accessoryHatCapName,
        'hat_helmet' => l10n.accessoryHatHelmetName,
        'hat_tophat' => l10n.accessoryHatTophatName,
        'glasses_smart' => l10n.accessoryGlassesSmartName,
        'glasses_sun' => l10n.accessoryGlassesSunName,
        'glasses_pixel' => l10n.accessoryGlassesPixelName,
        'glasses_vr' => l10n.accessoryGlassesVrName,
        'effect_stars' => l10n.accessoryEffectStarsName,
        'effect_fire' => l10n.accessoryEffectFireName,
        'effect_electric' => l10n.accessoryEffectElectricName,
        'cape_mantle' => l10n.accessoryCapeMantleName,
        'cape_ninja' => l10n.accessoryCapeNinjaName,
        'cape_wings' => l10n.accessoryCapeWingsName,
        _ => id,
      };
}
