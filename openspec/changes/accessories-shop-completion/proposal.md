## Outcome

Implemented in f0e1ec8 (entry point, shop tests in `test/character/accessory_shop_test.dart`) and on branch `chore/finish-audit-changes` in 4111600 (glyph/tint catalogue, ARB names) and 64479a7 (`DressedAvatar`). What was decided and built:

- **The shop is reachable.** The character screen's "Customize accessories" button (`character_screen.dart:166-169`) navigates to `/accessories` whenever the character shown on the page is unlocked. The "Coming soon" placeholder and the `comingSoon` strings are gone.
- **Coins are the only currency.** The app is completely free (owner decision); every accessory is bought with coins earned by playing. No item is premium.
- **Ownership is global, equipment is per character** (owner decision). Purchases go to `UserProgress.unlockedAccessories`; each `CharacterData` stores its own `equippedHat/Glasses/Effect/Cape`. `CharacterData.unlockedAccessories` is a legacy Hive field that is written but never read.
- **No separate art** (owner decision). Each catalogue item carries a `glyph` (emoji or text such as `⌐■-■`) or a `tint`; `DressedAvatar` draws the equipped items over the character on the home screen, the character screen and in the shop, and `CapePainter` paints tint-only capes.
- **Purchase flow:** balance check → coin deduction → ownership write → auto-equip on the active character, with a purchase haptic and a "Purchased!" snackbar. Insufficient funds shows a bottom sheet with price and balance and changes nothing. Tapping an owned item equips it; tapping the equipped item removes it.
- **Achievements:** no shipped achievement depends on accessory ownership; `collector_10` never existed in code. `coin_hoarder` (balance ≥ 500 after a session) stays unlocked once earned, so spending does not conflict with it.
- Not built: a coin balance on the character screen (the balance is shown in the shop's app bar).

Remaining: one manual on-device walkthrough (see `tasks.md` 3.10).

## Why

The coin economy has no sink. Coins are earned four ways — every session, personal records, 7-day and 30-day streaks — and the only thing they can buy is accessories. The accessories screen was built (`accessories_screen.dart`, the `/accessories` route, `accessories_data.dart` with items across four slots, purchase logic in `user_progress_provider.dart`, equip logic in `character_provider.dart`), but its entry point on the character screen was a **disabled placeholder reading "Accessories — Coming soon"**.

So a player accumulated a balance that could never be spent, on a shop that already existed behind a button that did nothing.

## What Changes

- The character screen's accessories button becomes live, navigating to `/accessories`.
- The "Coming soon" placeholder and its localization strings are removed.
- The purchase flow is verified and covered by tests: balance check, coin deduction, auto-equip, persistence across a provider rebuild.
- Equipped accessories are drawn on the character avatar (`DressedAvatar`) on the home, character and shop screens, from glyphs and painted capes rather than asset files.
- Accessory names move to ARB; the catalogue carries `glyph`/`tint` instead of nonexistent asset paths.
- Equipped items can be removed from the shop.

_Historical:_ the original proposal expected a `collector_10` ownership achievement to become attainable. No such achievement exists in the shipped set, so nothing was changed there.

## Capabilities

### New Capabilities
- `accessory-shop`: how accessories are browsed, bought with coins, equipped, drawn on the avatar, and persisted.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for the character economy. -->

## Impact

- `lib/features/character/screens/character_screen.dart` — the placeholder became a navigation button; the preview uses `DressedAvatar`.
- `lib/features/character/screens/accessories_screen.dart` — glyph tiles, Remove action, purchase haptic, no premium branches.
- `lib/features/character/widgets/dressed_avatar.dart` — new: `DressedAvatar`, `DressedAvatarView`, `CapePainter`, `equippedAccessories`.
- `lib/features/character/data/accessories_data.dart`, `lib/models/accessory.dart` — glyph/tint catalogue, ARB names.
- `lib/features/game/providers/user_progress_provider.dart` — `purchaseAccessory` (global ownership).
- `lib/features/character/providers/character_provider.dart` — equip/unequip per character.
- `lib/features/home/screens/home_screen.dart` — avatar uses `DressedAvatar`.
- `l10n/app_ru.arb`, `l10n/app_en.arb` — `comingSoon` and `accessoriesEquipped` removed, accessory names added.
- `test/character/accessory_shop_test.dart`, `test/character/dressed_avatar_test.dart` — new coverage.
- `docs/plans/features/character-system.md`, `progress-tracking.md` — updated.

Depended on `remove-monetization-go-free`; that has landed and no accessory is premium-gated.
