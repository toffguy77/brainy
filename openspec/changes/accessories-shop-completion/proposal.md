## Why

The coin economy has no sink. Coins are earned four ways — every session, personal records, 7-day and 30-day streaks — and the only thing they can buy is accessories. The accessories screen is fully built (`accessories_screen.dart`, the `/accessories` route, `accessories_data.dart` with items across four slots, purchase and equip logic in `character_provider.dart`), but its entry point on the character screen is a **disabled placeholder reading "Accessories — Coming soon"**.

So a player accumulates a balance that can never be spent, on a shop that already exists behind a button that does nothing. `docs/plans/features/character-system.md` describes the shop as working, including the purchase flow and the four category tabs.

This is the largest gap between what is built and what is reachable, after the premium gating removed by `remove-monetization-go-free`.

## What Changes

- The character screen's accessories button becomes live, navigating to `/accessories`.
- The "Coming soon" placeholder and its localization strings are removed.
- The purchase flow is verified end to end: balance check, coin deduction, auto-equip, persistence across restart.
- Equipped accessories are confirmed to render on the character preview on the home and character screens.
- The `collector_10` style achievement — awarded for owning accessories — becomes attainable, since accessories can finally be owned.

## Capabilities

### New Capabilities
- `accessory-shop`: how accessories are browsed, bought with coins, equipped, and persisted.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for the character economy. -->

## Impact

- `lib/features/character/screens/character_screen.dart` — the placeholder becomes a navigation button.
- `lib/features/character/screens/accessories_screen.dart` — verified, and its premium branches removed by `remove-monetization-go-free`.
- `lib/features/character/providers/character_provider.dart` — purchase and equip paths.
- `lib/models/character.dart` — `unlockedAccessories`, `equippedHat/Glasses/Effect` persistence.
- `l10n/app_ru.arb`, `l10n/app_en.arb` — `comingSoon` usage removed from the character screen.
- `test/character/` — new coverage for purchase, insufficient funds, equip and persistence.
- `docs/plans/features/character-system.md`, `progress-tracking.md` — accuracy restored.

Depends on `remove-monetization-go-free` for the two formerly-premium accessories; the shop should open with every item purchasable by coins alone.

Verified during specification: all four slots are fully supported in code — `AccessorySlot` is `{hat, glasses, effect, cape}`, `CharacterData` persists `equippedCape` alongside the other three, and three cape items exist. The gap is in `character-system.md`, which lists only `equippedHat/Glasses/Effect` and so understates the model. That correction belongs to `plans-code-sync`.
