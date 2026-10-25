## Context

Everything the shop needs already exists:

- `accessories_screen.dart` — the screen, with category tabs and a purchase grid.
- `/accessories` — a registered route.
- `accessories_data.dart` — items across four slots, including three capes.
- `character_provider.dart` — purchase and equip logic.
- `models/character.dart` — `unlockedAccessories`, `equippedHat/Glasses/Effect/Cape`, Hive typeId 2.
- `models/accessory.dart` — `AccessorySlot { hat, glasses, effect, cape }`.

The only missing piece is the entry point: `character_screen.dart` renders a `Material` row reading `'${l10n.accessoriesCustomize} — ${l10n.comingSoon}'`, greyed to 50% opacity, with no gesture handler. It looks like a disabled button because it is one.

Meanwhile the coin economy runs at full speed — 10 per session, 25 per record, 50 at a 7-day streak, 200 at 30 days — into a balance with nowhere to go.

This is a completion task, not a build task. The main risk is assuming the underlying flow works because it exists; it has likely never been exercised by a real user.

## Goals / Non-Goals

**Goals:**
- Make the shop reachable.
- Verify the purchase, equip, render and persistence chain actually works end to end.
- Give the coin economy its sink, so earning coins means something.

**Non-Goals:**
- Redesigning the shop UI or adding items. Fourteen-plus items across four slots is enough for launch.
- Repricing the economy. Worth revisiting once real spending data exists; guessing now is worse than shipping the current numbers.
- Adding a coin purchase path. Coins are earned by playing — that is the stated design, and `remove-monetization-go-free` makes it absolute.

## Decisions

**Enable the existing button rather than rebuild the entry point.** The placeholder sits in the right place with the right label and icon. Restoring full opacity and adding navigation is the whole change on the character screen.

**Verify the chain before declaring it done.** The screen has never been reachable in production, so "it compiles" says very little. Each link — balance check, deduction, ownership write, auto-equip, preview render, restart persistence — gets its own scenario. This is the substance of the change; enabling the button is the trivial part.

**Sequence after `remove-monetization-go-free`.** Two accessories are marked `isPremium: true`. Opening the shop first would expose two permanently unbuyable items and reproduce, in miniature, the problem being fixed.

**Keep auto-equip on purchase.** Documented in `character-system.md` and the obviously right default: a player buying a hat wants to see the hat.

**Do not gate the shop behind a character being unlocked beyond the current rule.** The existing condition — the active character must be unlocked — is correct; every player has Brainy from the start, so the shop is reachable immediately.

## Risks / Trade-offs

- **The purchase flow has latent bugs from never being exercised** → The central risk, and the reason verification dominates the task list rather than implementation. Expect to fix something.
- **Accessory art may be missing or misaligned on the preview** → `assets/characters/` holds character PNGs; per-accessory assets need checking. If art is missing, that is a real blocker to surface early rather than at review time.
- **Achievement definitions may not match the shipped set** → The plan lists a `collector_10` achievement; the code's actual set is `firstGame, personalRecord, speedDemon, master5x5, focusMode, streak3, streak7, streak30, nightOwl, coinHoarder`. Whether any is accessory-dependent must be checked, not assumed. `coinHoarder` may in fact conflict with spending, if it rewards hoarding a balance the shop now encourages spending.
- **Opening a coin sink changes progression pacing** → Acceptable and intended; the economy currently has no sink at all.

## Migration Plan

1. Land `remove-monetization-go-free` so no accessory is premium-gated.
2. Enable the character screen button and remove the placeholder strings.
3. Walk the full flow manually: earn coins, buy, equip, restart, verify.
4. Fix whatever the walkthrough exposes.
5. Add automated coverage for purchase, insufficient funds, equip-replacement and persistence.
6. Update `character-system.md`, including the missing `equippedCape` field.

**Rollback:** re-disable the button. The shop becomes unreachable again but no user data is corrupted — purchases already made remain in Hive and reappear if the button is re-enabled.

## Open Questions

- Does every accessory have preview art, and does it align on the character sprite?
- Does `coinHoarder` reward a balance the shop now encourages spending? If so, its condition may need rewording.
- Should the character screen show the coin balance, so the player knows what they can afford before entering the shop?
