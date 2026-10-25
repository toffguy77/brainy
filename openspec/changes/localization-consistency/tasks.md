## 1. Prerequisites

- [x] 1.1 Confirm `remove-monetization-go-free` has landed and `paywall_screen.dart` is gone
- [x] 1.2 Grep the codebase for `languageCode ==` and confirm no manual locale branching remains
- [x] 1.3 Record the baseline: ru and en ARB key counts match

## 2. Move notification strings into ARB

- [x] 2.1 Decide how `NotificationService` obtains localizations when scheduling outside a widget tree
- [x] 2.2 Add seven motivational variants as numbered keys to `app_ru.arb` and `app_en.arb`
- [x] 2.3 Add seven streak-warning variants as numbered keys to both files, preserving the `{count}` placeholder
- [x] 2.4 Move all strings verbatim so the diff is pure relocation
- [x] 2.5 Regenerate localizations
- [x] 2.6 Update `NotificationService` to resolve strings through localizations, keeping the `dayOfYear % count` selection
- [x] 2.7 Confirm both pools have equal variant counts in every locale
- [ ] 2.8 Update any notification test that asserted on literal strings

## 3. Resolve the character name duplication

- [x] 3.1 Choose the single source: `CharacterInfo` (recommended) or ARB
- [x] 3.2 Remove the duplicate definitions from the other source
- [ ] 3.3 Update all callers
- [ ] 3.4 Confirm character names render correctly in both locales

## 4. Verify

- [x] 4.1 Confirm ru and en ARB key sets are identical
- [x] 4.2 Grep `lib/` for user-facing string literals and confirm none remain
- [ ] 4.3 Trigger a reminder notification in each locale and confirm the text is correct
- [x] 4.4 Run `flutter analyze` and `flutter test`

## 5. Correct the documentation

- [x] 5.1 Rewrite `docs/plans/features/localization.md` to describe one consistent mechanism
- [x] 5.2 Remove the section cataloguing deviations
- [ ] 5.3 Decide whether ARB key parity should be enforced in CI via `ci-quality-gate`
