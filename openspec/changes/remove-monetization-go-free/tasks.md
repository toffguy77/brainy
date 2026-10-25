## 1. Unlock the feature surfaces

- [x] 1.1 Remove `isPremium` branching from `home_screen.dart`: mode toggle, grid picker lock icons, play button guard (11 call sites)
- [x] 1.2 Remove the premium size guard from `game_screen.dart`
- [x] 1.3 Remove `_PremiumGateScreen` from `parent_dashboard_screen.dart`; render the dashboard unconditionally
- [x] 1.4 Remove the `isPremium` flag from `_BestResultsCard` so no chip renders as locked
- [x] 1.5 Remove the premium redirect from `progress_screen.dart` and `grid_detail_screen.dart`
- [x] 1.6 Remove `UnlockType.premium` handling from `character_provider.dart` and `character_screen.dart`
- [x] 1.7 Give Pixel an achievable unlock condition in `characters_data.dart` (decision required — see design Open Questions)
- [x] 1.8 Remove `isPremium` from `models/accessory.dart` and from the two premium entries in `accessories_data.dart`
- [x] 1.9 Remove the premium branches from `accessories_screen.dart`
- [ ] 1.10 Verify manually that sizes 6/7/9, Gorbov mode, the parent dashboard and grid detail are all reachable

## 2. Delete the purchase surface

- [x] 2.1 ~~Move the notification-permission request from `paywall_page.dart`~~ — the plan was wrong: the request lives in `completeOnboarding()` in the provider, not on the paywall page. Frequency page now calls `completeOnboarding()`, so the request is preserved without moving anything
- [x] 2.2 Delete `lib/features/onboarding/pages/paywall_page.dart` and its entry in `onboarding_screen.dart`
- [x] 2.3 Change `AppConstants.onboardingPageCount` from 7 to 6 and verify the page indicator renders six dots
- [x] 2.4 Delete `lib/features/subscription/` (`paywall_screen.dart`, `premium_bottom_sheet.dart`)
- [x] 2.5 Remove the `/paywall` route from `router.dart`
- [x] 2.6 Confirm the notification permission is still requested exactly once during onboarding

## 3. Delete the subscription machinery

- [x] 3.1 Delete `lib/shared/services/subscription_service.dart` including `isPremiumProvider` and the commented-out RevenueCat block
- [x] 3.2 Remove `premiumGridSizes`, YooKassa constants, subscription Hive keys and `premiumWaitlistUrl` from `app_constants.dart`
- [x] 3.3 Remove paywall, premium and "coming soon" strings from `l10n/app_ru.arb` and `l10n/app_en.arb`; regenerate localizations
- [x] 3.4 Verify ru and en ARB files still have identical key sets
- [x] 3.5 Delete `paywall_screen_test.dart`, `paywall_page_test.dart`, `subscription_service_test.dart`, `subscription_constants_test.dart`, `dashboard_premium_gate_test.dart`
- [x] 3.6 Update `app_constants_test.dart` and `mode_toggle_test.dart` for the removed constants
- [x] 3.7 Add a test asserting the app starts when the Hive user box still contains stale subscription keys

## 4. Delete the payment backend

- [x] 4.1 Delete the `functions/` directory
- [x] 4.2 Remove the `functions` block from `firebase.json`
- [x] 4.3 Remove the `subscriptions` index from `firestore.indexes.json`
- [x] 4.4 Remove the `functions` job from `.github/workflows/ci.yml`
- [x] 4.5 Review the `deploy-testflight.yml` path filter for stale references
- [ ] 4.6 Close the open dependabot PR for `fast-xml-parser`, now moot
- [x] 4.7 Confirm no npm advisories remain anywhere in the repository

## 5. Update the published description of the app

- [x] 5.1 Remove the "Brainy Pro" paragraph from `metadata/ru/description.txt` and `metadata/en-US/description.txt`
- [x] 5.2 Verify the edits reintroduce no kids/children wording that caused the 2.3.8 rejection
- [x] 5.3 Check `promotional_text.txt` and `keywords.txt` for paid-tier references
- [ ] 5.4 Confirm the App Store Connect listing declares no in-app purchases

## 6. Update the plans

- [x] 6.1 Delete `docs/plans/features/subscription.md`
- [x] 6.2 Remove premium annotations from `game-modes.md`, `character-system.md`, `parent-panel.md`, `progress-tracking.md`
- [x] 6.3 Remove the subscription section from `CLAUDE.md`

## 7. Verify

- [x] 7.1 `flutter analyze` clean
- [x] 7.2 `flutter test` green
- [x] 7.3 `flutter build ios --no-codesign` succeeds
- [x] 7.4 Grep `lib/` for `isPremium`, `premium`, `paywall`, `subscription`, `yookassa` and confirm no functional references remain
