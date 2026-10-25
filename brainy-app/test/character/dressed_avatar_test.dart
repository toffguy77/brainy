import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainy/features/character/data/accessories_data.dart';
import 'package:brainy/features/character/widgets/dressed_avatar.dart';
import 'package:brainy/models/accessory.dart';
import 'package:brainy/models/character.dart';

AccessoryInfo _a(String id) => defaultAccessories.firstWhere((a) => a.id == id);

Widget _host(Map<AccessorySlot, AccessoryInfo> worn) => MaterialApp(
      home: Center(
        child: DressedAvatarView(characterId: 'brainy', size: 100, worn: worn),
      ),
    );

void main() {
  test('equippedAccessories maps each slot to its catalogue entry', () {
    final c = CharacterData(id: 'brainy', nameRu: '', nameEn: '', isUnlocked: true)
      ..equippedHat = 'hat_crown'
      ..equippedCape = 'cape_wings'
      ..equippedGlasses = 'no_such_item';
    final worn = equippedAccessories(c);
    expect(worn[AccessorySlot.hat]!.id, 'hat_crown');
    expect(worn[AccessorySlot.cape]!.id, 'cape_wings');
    expect(worn.containsKey(AccessorySlot.glasses), isFalse);
    expect(worn.containsKey(AccessorySlot.effect), isFalse);
  });

  testWidgets('a bare avatar draws no accessory layers', (tester) async {
    await tester.pumpWidget(_host(const {}));
    for (final k in ['worn-hat', 'worn-glasses', 'worn-effect', 'worn-cape']) {
      expect(find.byKey(ValueKey(k)), findsNothing);
    }
  });

  testWidgets('every slot renders its layer, painted capes included',
      (tester) async {
    await tester.pumpWidget(_host({
      AccessorySlot.hat: _a('hat_tophat'),
      AccessorySlot.glasses: _a('glasses_pixel'),
      AccessorySlot.effect: _a('effect_fire'),
      AccessorySlot.cape: _a('cape_ninja'),
    }));
    for (final k in ['worn-hat', 'worn-glasses', 'worn-effect', 'worn-cape']) {
      expect(find.byKey(ValueKey(k)), findsOneWidget, reason: k);
    }
    expect(find.text('🎩'), findsOneWidget);
    expect(find.text('⌐■-■'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is CapePainter),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wings are drawn as a mirrored pair', (tester) async {
    await tester.pumpWidget(_host({AccessorySlot.cape: _a('cape_wings')}));
    expect(find.text('🪽'), findsNWidgets(2));
  });
}
