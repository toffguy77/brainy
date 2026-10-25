## Outcome

- The character screen button is enabled and pushes `/accessories` (`character_screen.dart:157-191`). It is shown when the character on the current page is unlocked; the shop itself always dresses the **active** character (`UserProgress.activeCharacterId`, `accessories_screen.dart:52-56`).
- Purchase lives in `UserProgressNotifier.purchaseAccessory` (`user_progress_provider.dart:88-96`): an already-owned id returns `true` without charging; otherwise it refuses when `coins < price`, else deducts, appends to `UserProgress.unlockedAccessories` and persists. The screen then auto-equips via `CharacterNotifier.equipAccessory` (`accessories_screen.dart:471-479`).
- Ownership is global across characters; equipment is stored per character in `CharacterData.equipped*` (owner decision).
- Accessories are drawn without asset files: `glyph` or `tint` per item, layered by `DressedAvatar` (`widgets/dressed_avatar.dart`) on home, character and shop screens (owner decision).
- An equipped tile shows "Remove" and tapping it unequips that slot only.
- The app is free; coins cannot be bought.

## Context

At the start of this change the shop already existed:

- `accessories_screen.dart` — the screen, with category tabs and a purchase grid.
- `/accessories` — a registered route.
- `accessories_data.dart` — items across four slots (15 items: 5 hats, 4 glasses, 3 effects, 3 capes).
- `user_progress_provider.dart` — `purchaseAccessory`; `character_provider.dart` — equip/unequip.
- `models/character.dart` — `equippedHat/Glasses/Effect/Cape`, Hive typeId 2 (plus the legacy, unread `unlockedAccessories`).
- `models/accessory.dart` — `AccessorySlot { hat, glasses, effect, cape }`.

The missing piece was the entry point: `character_screen.dart` rendered a row reading `'${l10n.accessoriesCustomize} — ${l10n.comingSoon}'`, greyed to 50% opacity, with no gesture handler. Separately, the catalogue pointed at accessory asset paths that did not exist, and nothing drew equipped items on the character.

Coins are earned at 10 per session, 25 per record, 50 at a 7-day streak and 200 at 30 days.

## Goals / Non-Goals

**Goals:**
- Make the shop reachable.
- Verify the purchase, equip, render and persistence chain.
- Give the coin economy its sink.
- Show equipped accessories on the character.

**Non-Goals:**
- Redesigning the shop UI or adding items.
- Repricing the economy.
- Any coin purchase path or premium item — the app is completely free.
- Drawn per-accessory artwork.

## Decisions

**Enable the existing button rather than rebuild the entry point.** The placeholder sat in the right place with the right label and icon; restoring full opacity and adding navigation was the whole change on the character screen.

**Verify each link with a test.** Balance check, deduction, ownership write, slot replacement, independent slots, unequip and persistence across a fresh `ProviderContainer` each have a test in `test/character/accessory_shop_test.dart`. Auto-equip after purchase is in the widget and is not unit-tested.

**Global ownership, per-character equipment.** Buying an item once makes it available to every character; each character remembers what it wears. `CharacterData.unlockedAccessories` stays in the Hive format (field 4) only for compatibility.

**Glyphs and painted capes instead of art.** Each item has a `glyph` (emoji or text) or a `tint`. `DressedAvatar` places: cape/wings behind the body, glasses on the face, hat above, effect glyphs around. Wings are a mirrored glyph pair; tint-only capes are painted by `CapePainter`.

**Keep auto-equip on purchase.** A player buying a hat wants to see the hat.

**Tap the equipped item to remove it.** The equipped tile's chip reads "Remove", describing the action a tap performs.

**Sequence after `remove-monetization-go-free`.** Done; no accessory is premium.

## Risks / Trade-offs

- **Latent bugs in a never-reachable flow** → mitigated by the test suite above; the on-device walkthrough remains manual.
- **Accessory art missing** → resolved by the glyph/tint decision; emoji rendering depends on the iOS system font, and placement is checked only on a device.
- **Achievement definitions** → the shipped set is `firstGame, personalRecord, speedDemon, master5x5, focusMode, streak3, streak7, streak30, nightOwl, coinHoarder`; none depends on accessories.
- **`coinHoarder` vs spending** → no conflict: it is checked after each session as `coins >= 500` and never revoked once unlocked; spending only delays it.
- **Viewed vs active character** → the button appears for the character on the current page, but the shop dresses the active character. If they differ, the shop shows a different character from the one the user was looking at.

## Migration Plan

1. `remove-monetization-go-free` landed.
2. Button enabled, `comingSoon` strings removed.
3. Catalogue moved to glyph/tint and ARB names; `DressedAvatar` added.
4. Automated coverage for purchase, insufficient funds, equip replacement, unequip and persistence.
5. `character-system.md` and `progress-tracking.md` updated.
6. Manual on-device walkthrough (outstanding).

**Rollback:** re-disable the button. Purchases already made remain in Hive and reappear if the button is re-enabled.

## Open Questions (resolved)

- ~~Does every accessory have preview art, and does it align on the character sprite?~~ No art; each item is a glyph or a painted tint drawn by `DressedAvatar` (owner decision). Alignment is checked on a device.
- ~~Does `coinHoarder` reward a balance the shop now encourages spending?~~ No conflict: it is a one-time unlock at a 500-coin balance and is never revoked.
- ~~Should the character screen show the coin balance?~~ Not built; the balance is shown in the shop's app bar only.
