## 1. Remove the dead setup snippet

- [x] 1.1 Delete `brainy-app/docs/setup/revenue_cat/` (`initialize.dart`, `credentials.md`, `prompt.md`) — deleted in `f0e1ec8`; `brainy-app/docs/` no longer exists
- [x] 1.2 Confirm `flutter analyze` no longer reports the 3 errors and 1 info from `initialize.dart` — the file is gone; maintainer reports `flutter analyze --fatal-infos` clean

## 2. Clean the integration test

- [x] 2.1 Remove the `package:purchases_flutter/purchases_flutter.dart` import from `integration_test/screenshot_test.dart` — removed in `f0e1ec8`; imports at `screenshot_test.dart:2-31` contain no purchase SDK
- [x] 2.2 Remove the `Purchases.configure(PurchasesConfiguration(AppConstants.revenueCatApiKey))` block from `setUpAll` — removed in `f0e1ec8`; `setUpAll` (`screenshot_test.dart:229`) only initialises Hive
- [x] 2.3 Update the stale comment about avoiding a RevenueCat crash — both RevenueCat comments removed in `f0e1ec8`; router comment refreshed in `faf276b`
- [x] 2.4 Confirm the analyzer reports no issues for this file — maintainer reports `flutter analyze --fatal-infos` clean (covers `integration_test/`)

## 3. Clean the constants test

- [x] 3.1 Remove the `RevenueCat` group from `test/constants/app_constants_test.dart` — removed in `f0e1ec8`; remaining groups (`app_constants_test.dart:7-108`) are grid sizes, star thresholds, target times, XP, coins, legal URLs
- [~] 3.2 Note that YooKassa constants remain covered by `subscription_constants_test.dart` — dropped: the app has no payments at all; YooKassa constants and `subscription_constants_test.dart` were deleted in `f0e1ec8`, so there is nothing left to cover
- [x] 3.3 Run `flutter test test/constants/app_constants_test.dart` and confirm it loads and passes — maintainer reports the full `flutter test` run (267 tests) passes, which includes this file

## 4. Remove the build-time secret plumbing

- [x] 4.1 Grep `.github/workflows/` and `brainy-app/ios/fastlane/Fastfile` for `REVENUECAT_API_KEY` — zero matches at HEAD
- [x] 4.2 Remove the `--dart-define=REVENUECAT_API_KEY` from both Fastfile lanes, `deploy_testflight` and `release` — removed in `9180bab`; `build_app` calls at `Fastfile:59-70` and `Fastfile:152-163` carry no `--dart-define`
- [x] 4.3 Remove the `REVENUECAT_API_KEY: ${{ secrets.REVENUECAT_API_KEY }}` env entry from `.github/workflows/deploy-testflight.yml` and `.github/workflows/release.yml` — removed in `9180bab`; remaining `secrets.*` are signing and App Store Connect only (`deploy-testflight.yml:66-79`, `release.yml:59-72`)
- [ ] 4.4 External: delete the `REVENUECAT_API_KEY` GitHub repository secret
- [ ] 4.5 External: revoke the API key in the RevenueCat dashboard (it was committed to history and must be treated as leaked)
- [x] 4.6 External: confirm a TestFlight build succeeds without the secret (needs a `deploy-testflight.yml` run on `main`) — done: deploy-testflight run 40216725096 on main uploaded 1.2.0 (16) without the secret; build VALID in App Store Connect

## 5. Verify

- [x] 5.1 `flutter analyze` reports no issues — maintainer-reported
- [x] 5.2 `flutter analyze --fatal-infos` exits 0 — maintainer-reported; enforced in CI at `.github/workflows/ci.yml:54`; the `share_card.dart` info it depended on is fixed (`share_card.dart:37` uses `recordKey(...)`)
- [x] 5.3 Grep the repo for `revenuecat`, `purchases_flutter`, `Purchases.`, `revenueCatApiKey`, `revenueCatEntitlement`, `productId`, `entitlement` and confirm no functional matches — only hits: the guard needle at `test/app/free_access_test.dart:31` and Apple `CODE_SIGN_ENTITLEMENTS` in `project.pbxproj:528,713,738` (unrelated)
- [x] 5.4 Confirm no test file fails at the `loading` stage in a full run — maintainer reports all 267 tests pass
- [x] 5.5 Guard against reintroduction — `test/app/free_access_test.dart:19-38` fails if any `lib/` file contains `purchases_flutter` or other paid-tier identifiers
