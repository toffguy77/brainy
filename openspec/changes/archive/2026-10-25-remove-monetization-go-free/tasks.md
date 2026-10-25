Status verified against code on 2026-10-25 (branch `chore/finish-audit-changes`, commits f0e1ec8..1e1e279).
Legend: `[x]` done (evidence given), `[~]` dropped / not applicable, `[ ]` open — External or Manual (device) only.

## 1. Unlock the feature surfaces

- [x] 1.1 Remove `isPremium` branching from `home_screen.dart`: mode toggle, grid picker lock icons, play button guard — no `isPremium` in `lib/` (guarded by `test/app/free_access_test.dart:19-38`); the leftover `isLocked` picker branch was removed in 5cbd984
- [x] 1.2 Remove the premium size guard from `game_screen.dart` — `router.dart:59-65` passes `size`/`mode` straight to `GameScreen`, no redirect
- [x] 1.3 Remove `_PremiumGateScreen` from `parent_dashboard_screen.dart`; render the dashboard unconditionally — widget-rendered in `test/progress/grid_stats_mode_test.dart:77-92`
- [x] 1.4 Remove the `isPremium` flag from `_BestResultsCard` so no chip renders as locked — `isLocked` now only exists in the PIN lockout (`parent_pin_screen.dart:39`, `pin_lockout.dart:22`), unrelated
- [x] 1.5 Remove the premium redirect from `progress_screen.dart` and `grid_detail_screen.dart` — no premium references in `lib/`
- [x] 1.6 Remove `UnlockType.premium` handling — enum is `{ free, level, streak }` (`characters_data.dart:4`); switch at `character_provider.dart:123-131`; `test/character/character_unlock_test.dart:11`
- [x] 1.7 Give Pixel an achievable unlock condition — 14-day streak (`characters_data.dart:73-75`, ARB `characterPixelUnlock` line 450 in both locales); actually unlocks via `session_completion_provider.dart:73` -> `CharacterNotifier.unlockEligible` (`character_provider.dart:111-121`); `character_unlock_test.dart:25-28`
- [x] 1.8 Remove `isPremium` from `models/accessory.dart` and from the two premium entries in `accessories_data.dart` — `AccessoryInfo` has `id/slot/price/glyph/tint` only (`accessory.dart:6-23`)
- [x] 1.9 Remove the premium branches from `accessories_screen.dart` — no premium references in `lib/`; shop covered by `test/character/accessory_shop_test.dart`
- [ ] 1.10 Manual (device): walk through sizes 6/7/9, Gorbov mode, the parent dashboard and grid detail on a device. Automated coverage already in place: `test/app/free_access_test.dart:57-60` (all sizes and Gorbov offered), `test/home/mode_toggle_test.dart:6-30` (Gorbov sizes playable), `test/home/home_screen_test.dart:153-176` (fixed 9x9 renders, clamps to 5x5 in letters), `test/progress/grid_stats_mode_test.dart:77-92` (dashboard renders). Grid detail screen has no widget test

## 2. Delete the purchase surface

- [~] 2.1 Move the notification-permission request from `paywall_page.dart` — N/A: the request never lived on the paywall page; it is in `completeOnboarding()` (`onboarding_provider.dart:86-101`), called from the frequency page (`frequency_page.dart:64-67`)
- [x] 2.2 Delete `lib/features/onboarding/pages/paywall_page.dart` and its entry in `onboarding_screen.dart` — file absent
- [x] 2.3 Change `AppConstants.onboardingPageCount` from 7 to 6 — `app_constants.dart:126`; `free_access_test.dart:53-55`
- [x] 2.4 Delete `lib/features/subscription/` — absent; `free_access_test.dart:45-47`
- [x] 2.5 Remove the `/paywall` route from `router.dart` — `free_access_test.dart:40-43`
- [x] 2.6 Confirm the notification permission is still requested exactly once during onboarding — single call site `onboarding_provider.dart:101`

## 3. Delete the subscription machinery

- [x] 3.1 Delete `lib/shared/services/subscription_service.dart` including `isPremiumProvider` and the RevenueCat block — absent; `SubscriptionService` guarded in `free_access_test.dart:25`
- [x] 3.2 Remove `premiumGridSizes`, YooKassa constants, subscription Hive keys and `premiumWaitlistUrl` from `app_constants.dart` — none present (repo-wide grep, 2026-10-25)
- [x] 3.3 Remove paywall, premium and "coming soon" strings from both ARB files; regenerate localizations — no hits in `l10n/` or `lib/l10n/`; 12 more unused keys dropped in faf276b
- [x] 3.4 Verify ru and en ARB files still have identical key sets — enforced in CI, `.github/workflows/ci.yml:37-41`
- [x] 3.5 Delete `paywall_screen_test.dart`, `paywall_page_test.dart`, `subscription_service_test.dart`, `subscription_constants_test.dart`, `dashboard_premium_gate_test.dart` — none exist under `brainy-app/test/`
- [x] 3.6 Update `app_constants_test.dart` and `mode_toggle_test.dart` for the removed constants — `mode_toggle_test.dart:24-30`
- [x] 3.7 Add a test asserting the app starts when the Hive user box still contains stale subscription keys — `free_access_test.dart:62-76`

## 4. Delete the payment backend

- [x] 4.1 Delete the `functions/` directory — absent; `free_access_test.dart:49-51`
- [x] 4.2 Remove the `functions` block from `firebase.json` — superseded: `firebase.json` deleted entirely in 9180bab (no consumer)
- [x] 4.3 Remove the `subscriptions` index from `firestore.indexes.json` — superseded: `firestore.indexes.json` and `firestore.rules` deleted in 9180bab
- [x] 4.4 Remove the `functions` job from `.github/workflows/ci.yml` — jobs are `flutter` and `secrets-scan` only (`ci.yml:24-68`)
- [x] 4.5 Review the `deploy-testflight.yml` path filter for stale references — `deploy-testflight.yml:7-13` lists only `brainy-app/` paths; no change needed. `REVENUECAT_API_KEY` removed from Fastfile and all workflows in 9180bab
- [x] 4.6 External: close the open dependabot PRs and delete all 13 remote branches `origin/dependabot/npm_and_yarn/functions/*` (axios, fast-xml-builder, fast-xml-parser, follow-redirects, grpc/grpc-js, handlebars, multi-f792d6d6d9, node-forge, path-to-regexp, picomatch, protobufjs, protobufjs/utf8, tootallnate/once) — all target the deleted `functions/`. No `.github/dependabot.yml` exists, so nothing to change in the repo — done: all dependabot PRs for functions/ closed with branches deleted (#3–#20, #22–#27), 2026-10-25
- [x] 4.7 Confirm no npm advisories remain anywhere in the repository — no `package.json` outside the untracked `brainy-app/build/` cache

## 5. Update the published description of the app

- [x] 5.1 Remove the "Brainy Pro" paragraph from both descriptions — gone; both now say "completely free" and list four modes (`metadata/en-US/description.txt:8,21-22`, `metadata/ru/description.txt:8,21`); `review_information/notes.txt:1` says completely free, four modes
- [x] 5.2 Verify the edits reintroduce no kids/children wording that caused the 2.3.8 rejection — no `kid|child|дети|детск|ребён` in either description
- [x] 5.3 Check `promotional_text.txt` and `keywords.txt` for paid-tier references — none
- [x] 5.4 External: confirm the App Store Connect listing declares no in-app purchases and remove the old Brainy Pro subscription products / group. In-repo side done: `Products.storekit` and its scheme reference deleted (9180bab, faf276b); `Fastfile:99,182` set `precheck_include_in_app_purchases: false` — done: App Store Connect API: no in-app purchases and no subscription groups for app 6760589477 (2026-10-25)

## 6. Update the plans

- [x] 6.1 Delete `docs/plans/features/subscription.md` — absent
- [x] 6.2 Remove premium annotations from `game-modes.md`, `character-system.md`, `parent-panel.md`, `progress-tracking.md` — no premium hits in `docs/plans/`; `character-system.md:44` says "Платных аксессуаров нет"
- [x] 6.3 Remove the subscription section from `CLAUDE.md` — `CLAUDE.md:24-26` states the app is completely free

## 7. Verify

- [x] 7.1 `flutter analyze` clean — enforced by the `flutter` job in `ci.yml`, which 9180bab made a required gate for deploy and release
- [x] 7.2 `flutter test` green — same CI gate
- [x] 7.3 `flutter build ios --no-codesign` succeeds — verified during implementation
- [x] 7.4 Grep for `isPremium`, `premium`, `paywall`, `subscription`, `yookassa` and confirm no functional references remain — repo-wide grep (2026-10-25) finds only negations (`CLAUDE.md:26`, `en-US/description.txt:22`, `.gitignore:44`), the guard test `free_access_test.dart`, and Game Center code-signing entitlements (`project.pbxproj:528,713,738`)
