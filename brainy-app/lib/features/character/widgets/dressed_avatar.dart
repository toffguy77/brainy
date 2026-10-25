import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/accessory.dart';
import '../../../models/character.dart';
import '../data/accessories_data.dart';
import '../providers/character_provider.dart';
import '../screens/character_screen.dart';

/// The accessory equipped in each slot of [character], skipping unknown ids.
Map<AccessorySlot, AccessoryInfo> equippedAccessories(CharacterData character) {
  final ids = {
    AccessorySlot.hat: character.equippedHat,
    AccessorySlot.glasses: character.equippedGlasses,
    AccessorySlot.effect: character.equippedEffect,
    AccessorySlot.cape: character.equippedCape,
  };
  return {
    for (final entry in ids.entries)
      if (entry.value != null)
        for (final a in defaultAccessories)
          if (a.id == entry.value) entry.key: a,
  };
}

/// A character avatar wearing its equipped accessories: cape behind, then
/// the body, glasses on the face, hat on top and effects around it.
/// Occupies a [size] x [size] box; layers are placed relative to it.
class DressedAvatar extends ConsumerWidget {
  final String characterId;
  final double size;

  const DressedAvatar({
    super.key,
    required this.characterId,
    required this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characters = ref.watch(characterProvider);
    CharacterData? character;
    for (final c in characters) {
      if (c.id == characterId) character = c;
    }
    final worn = character == null
        ? const <AccessorySlot, AccessoryInfo>{}
        : equippedAccessories(character);
    return DressedAvatarView(
      characterId: characterId,
      size: size,
      worn: worn,
    );
  }
}

/// Stateless rendering of [DressedAvatar], separate so it can be tested
/// without providers.
class DressedAvatarView extends StatelessWidget {
  final String characterId;
  final double size;
  final Map<AccessorySlot, AccessoryInfo> worn;

  const DressedAvatarView({
    super.key,
    required this.characterId,
    required this.size,
    required this.worn,
  });

  @override
  Widget build(BuildContext context) {
    final cape = worn[AccessorySlot.cape];
    final glasses = worn[AccessorySlot.glasses];
    final hat = worn[AccessorySlot.hat];
    final effect = worn[AccessorySlot.effect];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (cape != null) ..._capeLayers(cape),
          characterAvatar(characterId, size: size),
          if (glasses != null)
            Positioned(
              key: const ValueKey('worn-glasses'),
              top: size * 0.30,
              child: _Glyph(glasses.glyph!, size * 0.30),
            ),
          if (hat != null)
            Positioned(
              key: const ValueKey('worn-hat'),
              top: -size * 0.28,
              child: _Glyph(hat.glyph!, size * 0.42),
            ),
          if (effect != null) ..._effectLayers(effect),
        ],
      ),
    );
  }

  List<Widget> _capeLayers(AccessoryInfo cape) {
    if (cape.glyph != null) {
      // Wings: one glyph per side, the left one mirrored.
      return [
        Positioned(
          key: const ValueKey('worn-cape'),
          left: -size * 0.30,
          top: size * 0.15,
          child: Transform.flip(flipX: true, child: _Glyph(cape.glyph!, size * 0.45)),
        ),
        Positioned(
          right: -size * 0.30,
          top: size * 0.15,
          child: _Glyph(cape.glyph!, size * 0.45),
        ),
      ];
    }
    return [
      Positioned(
        key: const ValueKey('worn-cape'),
        top: size * 0.25,
        child: CustomPaint(
          size: Size(size * 1.2, size * 0.85),
          painter: CapePainter(cape.tint ?? Colors.redAccent),
        ),
      ),
    ];
  }

  List<Widget> _effectLayers(AccessoryInfo effect) {
    final g = effect.glyph!;
    final s = size * 0.24;
    return [
      Positioned(
          key: const ValueKey('worn-effect'),
          left: -s * 0.4,
          top: size * 0.05,
          child: _Glyph(g, s)),
      Positioned(right: -s * 0.4, top: size * 0.45, child: _Glyph(g, s * 0.8)),
      Positioned(left: size * 0.1, bottom: -s * 0.3, child: _Glyph(g, s * 0.7)),
    ];
  }
}

/// The accessory as drawn in the shop: its glyph, or a painted cape.
class AccessoryGlyph extends StatelessWidget {
  final AccessoryInfo accessory;
  final double size;
  const AccessoryGlyph({super.key, required this.accessory, required this.size});

  @override
  Widget build(BuildContext context) {
    final glyph = accessory.glyph;
    if (glyph != null) return _Glyph(glyph, size);
    return CustomPaint(
      size: Size(size, size * 0.8),
      painter: CapePainter(accessory.tint ?? Colors.redAccent),
    );
  }
}

class _Glyph extends StatelessWidget {
  final String text;
  final double size;
  const _Glyph(this.text, this.size);

  @override
  Widget build(BuildContext context) {
    // Text glyphs like '⌐■-■' are wider than an emoji; FittedBox keeps every
    // glyph within its box.
    return SizedBox(
      width: size * 1.6,
      height: size,
      child: FittedBox(
        child: Text(
          text,
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            fontSize: size,
            height: 1,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

/// A cape: a collar at the top flaring out to a wavy hem.
class CapePainter extends CustomPainter {
  final Color color;
  CapePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.35, 0)
      ..lineTo(w * 0.65, 0)
      ..quadraticBezierTo(w * 0.95, h * 0.55, w, h)
      ..quadraticBezierTo(w * 0.75, h * 0.9, w * 0.5, h)
      ..quadraticBezierTo(w * 0.25, h * 0.9, 0, h)
      ..quadraticBezierTo(w * 0.05, h * 0.55, w * 0.35, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.02,
    );
  }

  @override
  bool shouldRepaint(CapePainter oldDelegate) => oldDelegate.color != color;
}
