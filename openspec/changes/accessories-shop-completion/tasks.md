## 1. Prerequisites

- [x] 1.1 Confirm `remove-monetization-go-free` has landed so no accessory is premium-gated
- [ ] 1.2 Audit `assets/` for per-accessory art and list anything missing before starting

## 2. Open the entry point

- [x] 2.1 Replace the disabled placeholder in `character_screen.dart` with a working button navigating to `/accessories`
- [x] 2.2 Restore full opacity and the enabled visual treatment
- [x] 2.3 Remove the `comingSoon` usage from the character screen
- [x] 2.4 Remove now-unused `comingSoon` strings from `l10n/app_ru.arb` and `l10n/app_en.arb` if no other consumer remains, and regenerate localizations
- [x] 2.5 Verify ru and en ARB key sets remain identical

## 3. Walk the flow end to end

- [ ] 3.1 Earn coins by playing, open the shop, and confirm the balance displays correctly
- [ ] 3.2 Buy an affordable accessory; confirm deduction, ownership and auto-equip
- [ ] 3.3 Attempt an unaffordable purchase; confirm refusal with a clear message and unchanged balance
- [ ] 3.4 Equip a second item in the same slot; confirm the first is replaced
- [ ] 3.5 Buy and equip one item in each of the four slots, capes included
- [ ] 3.6 Confirm equipped accessories render on both the character and home screen previews
- [ ] 3.7 Restart the app; confirm ownership, equipment and balance all persist
- [ ] 3.8 Switch characters; confirm per-character ownership and equipment
- [ ] 3.9 Fix every defect this walkthrough exposes

## 4. Cover it with tests

- [x] 4.1 Test a successful purchase: balance deducted, accessory owned, auto-equipped
- [x] 4.2 Test insufficient funds: purchase refused, balance unchanged
- [x] 4.3 Test that the balance can never go negative
- [x] 4.4 Test slot replacement when equipping a second item in one slot
- [x] 4.5 Test persistence of ownership and equipment across a provider rebuild
- [x] 4.6 Test cape equipping specifically, since `equippedCape` is the least exercised field

## 5. Achievements

- [x] 5.1 Check whether any shipped achievement depends on accessory ownership
- [ ] 5.2 Verify `coinHoarder` does not reward hoarding in a way that now conflicts with spending
- [ ] 5.3 Confirm any accessory-dependent achievement unlocks and shows its popup

## 6. Update the plans

- [x] 6.1 Update `character-system.md`: the shop is reachable, and `CharacterData` includes `equippedCape`
- [ ] 6.2 Update `progress-tracking.md` if the achievement list or coin sink description changes
- [x] 6.3 Correct the achievement list in `progress-tracking.md` to the shipped set (coordinate with `plans-code-sync`)
