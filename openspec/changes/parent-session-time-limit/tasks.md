## 1. Decide the semantics

- [x] 1.1 Owner decides: enforce per-session, enforce per-day, or remove the control
- [ ] 1.2 If merging with `dailyGoalMinutes`, decide whether one setting replaces the other
- [x] 1.3 Record the decision in `design.md` and update the setting's label and ARB strings to match
- [x] 1.4 If the decision is to remove: delete the control, `parentMaxSessionTimeKey`, the provider field, and the plan section — then close this change

## 2. Enforce the limit

- [ ] 2.1 Read `parentProvider.maxSessionTimeMinutes` when a session starts in `game_screen.dart`
- [ ] 2.2 Measure elapsed play time from the end of the countdown, not from screen entry
- [ ] 2.3 If per-day, accumulate across sessions using the same day-boundary definition as the streak logic
- [ ] 2.4 End the session through the normal completion path with a limit-reached flag, so persistence is reused
- [ ] 2.5 Treat 0 as unlimited and skip all limit logic
- [ ] 2.6 Do not terminate a session already in progress when the setting changes

## 3. Explain it to the child

- [ ] 3.1 Add localized strings for the limit-reached message to `l10n/app_ru.arb` and `l10n/app_en.arb`
- [ ] 3.2 Word it as a boundary, not a failure — no loss framing
- [ ] 3.3 Show the message on the result screen when the session ended on the limit
- [ ] 3.4 Verify ru and en ARB key sets remain identical and regenerate localizations

## 4. Preserve progress

- [ ] 4.1 Confirm coins and XP earned before the limit are retained
- [ ] 4.2 Confirm no personal record is written for an incomplete session
- [ ] 4.3 Confirm the partial session is recorded consistently with other incomplete sessions

## 5. Test

- [ ] 5.1 Test that a session ends when the limit is reached
- [ ] 5.2 Test that a session completing before the limit is unaffected
- [ ] 5.3 Test that unlimited (0) never ends a session
- [ ] 5.4 Test that the countdown is excluded from elapsed time
- [ ] 5.5 Test that progress is preserved and no record is written
- [ ] 5.6 If per-day, test accumulation across sessions and reset at the day boundary

## 6. Verify and document

- [ ] 6.1 Manually verify with a 1-minute limit that the message appears and progress is kept
- [ ] 6.2 Update `docs/plans/features/parent-panel.md` to describe the real behaviour
- [ ] 6.3 Review the parent settings screen and confirm every remaining control changes observable behaviour
