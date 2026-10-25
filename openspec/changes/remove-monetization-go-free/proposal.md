## Decision / Outcome (2026-10-25)

**Decision (owner):** Brainy is completely free and iOS-only. No RevenueCat, no YooKassa, no Cloud Functions, no ads, no analytics.

**Outcome:** implemented on `chore/finish-audit-changes` (f0e1ec8..1e1e279). Every mode (classic, reverse, letters, Gorbov-Schulte) and every grid size its mode supports is open to all users; the paywall, subscription service, payment backend and store-side Brainy Pro artefacts are gone from the repo. Follow-up fixes after the first audit: `Products.storekit`, `firebase.json`, `firestore.indexes.json`, `firestore.rules` and `REVENUECAT_API_KEY` plumbing deleted (9180bab); scheme reference, review notes and descriptions updated (faf276b); fixed-size/mode crash fixed by clamping (5cbd984). Pixel unlocks on a 14-day streak and the unlock now actually fires. Remaining work is outside the repo: closing 13 dependabot branches for `functions/`, App Store Connect IAP cleanup, and a device walkthrough (see `tasks.md`).

The sections below are the original proposal, kept as written.

## Why

Brainy ships free. Monetization is being abandoned, not deferred — so every artefact built to support it becomes dead weight that costs maintenance, blocks features behind locks nobody can ever unlock, and misrepresents the app in the App Store.

Today the app is in the worst possible state: paid features exist and are locked, but no purchase path exists. `SubscriptionService.isPremium()` is a hardcoded `false`, so grid sizes 6/7/9, the entire Gorbov-Schulte mode, the Pixel character, two accessories, the parent dashboard, and per-size statistics are unreachable by *every* user. The paywall shows a "Coming Soon" badge and a Telegram link. Roughly half the product is built, shipped, and permanently switched off.

Going free turns all of that into working product for free, and deletes a payment backend that is the sole source of 23 npm vulnerabilities (2 critical) in `functions/`.

## What Changes

- Premium gating is removed everywhere. Grid sizes 6, 7 and 9, Gorbov-Schulte mode, the Pixel character, premium accessories, the parent dashboard and per-size statistics become available to all users.
- The paywall screen, the onboarding paywall page, the premium bottom sheet and the `/paywall` route are deleted.
- `SubscriptionService`, `isPremiumProvider`, the commented-out RevenueCat block and all YooKassa constants are deleted.
- The `functions/` package is deleted in full — all four of its exports (`createPayment`, `yookassaWebhook`, `checkSubscription`, `renewSubscriptions`) are payment-only. This also removes the 23 npm vulnerabilities and the `subscriptions` Firestore index.
- The Pixel character's unlock condition changes from Premium to an achievable rule, so it is collectable rather than merely granted.
- App Store metadata drops "Brainy Pro" and the paid-feature list from both locales.
- **BREAKING** for anyone reading the plans: `docs/plans/features/subscription.md` is deleted rather than updated.

## Capabilities

### New Capabilities
- `free-access`: every feature is reachable by every user; the app defines no paid tier and no purchase path.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability describing access tiers. -->

## Impact

- `lib/features/subscription/` — deleted in full (`paywall_screen.dart`, `premium_bottom_sheet.dart`).
- `lib/features/onboarding/pages/paywall_page.dart` — deleted; onboarding drops from 7 pages to 6, so `AppConstants.onboardingPageCount` and the page indicator change. The notification-permission request currently living on the paywall page must move to the preceding page rather than be lost.
- `lib/shared/services/subscription_service.dart` — deleted, along with `isPremiumProvider`.
- `lib/features/home/screens/home_screen.dart` — mode toggle, grid picker and play button stop branching on `isPremium` (11 call sites).
- `lib/features/character/` — `characters_data.dart` (Pixel unlock), `accessories_data.dart` (two `isPremium: true` items), `character_provider.dart` (`UnlockType.premium` case), `character_screen.dart`, `accessories_screen.dart`.
- `lib/features/parent/screens/parent_dashboard_screen.dart` — `_PremiumGateScreen` deleted; dashboard always renders.
- `lib/features/progress/screens/progress_screen.dart`, `grid_detail_screen.dart` — per-size stats open to all.
- `lib/features/game/screens/game_screen.dart` — premium size check removed.
- `lib/models/accessory.dart` — `isPremium` field removed.
- `lib/constants/app_constants.dart` — `premiumGridSizes`, YooKassa constants, `premiumWaitlistUrl` removed.
- `lib/app/router.dart` — `/paywall` route removed.
- `l10n/app_ru.arb`, `l10n/app_en.arb` — paywall, premium and "coming soon" strings removed.
- `functions/`, `firebase.json`, `firestore.indexes.json`, `firestore.rules` — payment backend removed; the Firebase config files had no other consumer and were deleted outright (9180bab).
- `brainy-app/ios/Runner/Products.storekit` and its reference in `Runner.xcscheme` — Brainy Pro StoreKit test config deleted (9180bab, faf276b).
- `brainy-app/ios/fastlane/Fastfile`, `.github/workflows/deploy-testflight.yml`, `release.yml` — `REVENUECAT_API_KEY` removed (9180bab).
- `brainy-app/ios/fastlane/metadata/review_information/notes.txt` — states the app is completely free with four modes (faf276b).
- `test/` — `paywall_screen_test.dart`, `paywall_page_test.dart`, `subscription_service_test.dart`, `subscription_constants_test.dart`, `dashboard_premium_gate_test.dart` deleted; `app_constants_test.dart` and `mode_toggle_test.dart` updated.
- `brainy-app/ios/fastlane/metadata/{ru,en-US}/description.txt` — "Brainy Pro" paragraph removed.
- `docs/plans/features/subscription.md` — deleted; `game-modes.md`, `character-system.md`, `parent-panel.md`, `progress-tracking.md` lose their premium annotations.
