## 1. Prerequisites

- [x] 1.1 Confirm `remove-monetization-go-free` has landed so no accessory is premium-gated — no `isPremium`/`premium` left in `lib/`; `AccessoryInfo` has no premium field (`lib/models/accessory.dart:6-23`)
- [x] 1.2 Audit `assets/` for per-accessory art and list anything missing before starting — no accessory art exists (`assets/` has only badges, characters, fonts, icon, leagues, sounds, splash); resolved by owner decision: items carry a `glyph` or `tint` instead of an asset path (`lib/features/character/data/accessories_data.dart:4-102`, commit 4111600)

## 2. Open the entry point

- [x] 2.1 Replace the disabled placeholder in `character_screen.dart` with a working button navigating to `/accessories` — `lib/features/character/screens/character_screen.dart:166-169` (`Key('accessoriesButton')`, `context.push('/accessories')`)
- [x] 2.2 Restore full opacity and the enabled visual treatment — `character_screen.dart:163-185` (no `Opacity`, primary icon, `textPrimary` label)
- [x] 2.3 Remove the `comingSoon` usage from the character screen — label is `l10n.accessoriesCustomize` only (`character_screen.dart:177`)
- [x] 2.4 Remove now-unused `comingSoon` strings from `l10n/app_ru.arb` and `l10n/app_en.arb` if no other consumer remains, and regenerate localizations — no `comingSoon` in `l10n/*.arb` or `lib/l10n/*.dart` (removed in f0e1ec8)
- [x] 2.5 Verify ru and en ARB key sets remain identical — enforced in CI, `.github/workflows/ci.yml:37-41` (ARB key parity step)

## 3. Walk the flow end to end

- [x] 3.1 Earn coins by playing, open the shop, and confirm the balance displays correctly — shop app bar shows `progress.coins` (`lib/features/character/screens/accessories_screen.dart:74-99`)
- [x] 3.2 Buy an affordable accessory; confirm deduction, ownership and auto-equip — `UserProgressNotifier.purchaseAccessory` (`lib/features/game/providers/user_progress_provider.dart:88-96`), auto-equip after success (`accessories_screen.dart:471-479`); test `accessory_shop_test.dart` "an affordable accessory is bought and coins are deducted"
- [x] 3.3 Attempt an unaffordable purchase; confirm refusal with a clear message and unchanged balance — bottom sheet "need N, you have M" (`accessories_screen.dart:493-555`); test "an unaffordable accessory is refused and coins are untouched"
- [x] 3.4 Equip a second item in the same slot; confirm the first is replaced — test "equipping a second item in a slot replaces the first"
- [x] 3.5 Buy and equip one item in each of the four slots, capes included — test "an accessory can be equipped in each slot, capes included"
- [x] 3.6 Confirm equipped accessories render on both the character and home screen previews — `DressedAvatar` at `home_screen.dart:224`, `character_screen.dart:238`, `accessories_screen.dart:211`; tests in `test/character/dressed_avatar_test.dart`
- [x] 3.7 Restart the app; confirm ownership, equipment and balance all persist — tests "ownership and coins survive a fresh provider container", "equipment survives a fresh provider container"
- [~] 3.8 Switch characters; confirm per-character ownership and equipment — dropped as worded: owner decision makes ownership global (`UserProgress.unlockedAccessories`, read at `accessories_screen.dart:287`); equipment stays per character (`character_provider.dart:58-96`, keyed by `characterId`)
- [x] 3.9 Fix every defect this walkthrough exposes — nonexistent `assetPath`s replaced by glyph/tint and names moved to ARB (commit 4111600); accessories now drawn on the avatar (removed in f0e1ec8)
- [ ] 3.10 Manual (device): on an iPhone, earn coins, buy and equip one item per slot, check glyph/cape alignment on the home, character and shop avatars, kill and relaunch the app, and confirm ownership, equipment and balance

## 4. Cover it with tests

- [x] 4.1 Test a successful purchase: balance deducted, accessory owned, auto-equipped — `test/character/accessory_shop_test.dart` "an affordable accessory is bought…" (deduction and ownership; auto-equip lives in the widget `_onTap` and is not unit-tested)
- [x] 4.2 Test insufficient funds: purchase refused, balance unchanged — "an unaffordable accessory is refused and coins are untouched"
- [x] 4.3 Test that the balance can never go negative — "balance never goes negative"
- [x] 4.4 Test slot replacement when equipping a second item in one slot — "equipping a second item in a slot replaces the first"
- [x] 4.5 Test persistence of ownership and equipment across a provider rebuild — `persistence` group in `accessory_shop_test.dart`
- [x] 4.6 Test cape equipping specifically, since `equippedCape` is the least exercised field — "slots are independent", "unequipping clears only its own slot" (hat + cape)

## 5. Achievements

- [x] 5.1 Check whether any shipped achievement depends on accessory ownership — none: `_isEarned` has no accessory condition (`lib/features/progress/providers/achievements_provider.dart:41-56`)
- [x] 5.2 Verify `coinHoarder` does not reward hoarding in a way that now conflicts with spending — rule is a balance snapshot `progress.coins >= 500` after a session (`achievements_provider.dart:55`); once unlocked it is never re-evaluated or revoked (`achievements_provider.dart:35`, `achievement_rules_test.dart:88-104`); spending only delays it
- [~] 5.3 Confirm any accessory-dependent achievement unlocks and shows its popup — not applicable: no accessory-dependent achievement exists (`collector_10` was never shipped)

## 6. Update the plans

- [x] 6.1 Update `character-system.md`: the shop is reachable, and `CharacterData` includes `equippedCape` — `docs/plans/features/character-system.md:32,67`
- [x] 6.2 Update `progress-tracking.md` if the achievement list or coin sink description changes — `docs/plans/features/progress-tracking.md:25` (coin sink), `:74` (coin_hoarder not revoked by spending), `:100` (global ownership)
- [x] 6.3 Correct the achievement list in `progress-tracking.md` to the shipped set (coordinate with `plans-code-sync`) — `progress-tracking.md:63-77` matches `AchievementId`

## 7. Work done beyond the original list

- [x] 7.1 Draw equipped accessories on the avatar: `DressedAvatar`/`DressedAvatarView` layer cape/wings behind, glasses, hat and effect over the character (`lib/features/character/widgets/dressed_avatar.dart:28-191`); tint-only capes painted by `CapePainter` (`dressed_avatar.dart:194-222`); tests in `dressed_avatar_test.dart`
- [x] 7.2 Catalogue carries a `glyph` or `tint` per item, no asset paths (`lib/models/accessory.dart:11-15`); test "every accessory has a positive coin price and something to draw"
- [x] 7.3 Accessory names come from ARB (`AccessoryInfo.name`, `accessory.dart:25-42`); test "every accessory is named in both locales"
- [x] 7.4 Global ownership: purchases go to `UserProgress.unlockedAccessories` (`user_progress_provider.dart:88-96`); `CharacterData.unlockedAccessories` kept as a legacy Hive field, never read (`character-system.md:68`)
- [x] 7.5 Tapping an equipped item removes it ("Remove" chip) — `accessories_screen.dart:367-391,450-456`; test "unequipping clears only its own slot"
- [x] 7.6 Buying an already-owned item never charges twice — `user_progress_provider.dart:89`; test "buying the same accessory twice does not charge twice"
- [x] 7.7 Purchase haptic via `HapticService.purchase` and a "Purchased!" snackbar — `accessories_screen.dart:476-491`
- [x] 7.8 Catalogue invariants tested: every slot non-empty, unique ids, cheapest item affordable within 20 sessions (`accessory_shop_test.dart:58-75`)
