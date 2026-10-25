## Why

`flutter analyze` reports 11 errors and 3 infos, every one of them a leftover of the RevenueCat integration that was replaced by YooKassa in `3b9684a`. The dependency was dropped from `pubspec.yaml` and the constants were commented out, but three files still import `purchases_flutter` and reference deleted constants. Two of those files are tests, so they fail at the `loading` stage — which means they contribute no coverage while looking like they do.

A red analyzer is not just untidy: it trains everyone to ignore analyzer output, so the next real defect hides in the noise. It also blocks the `ci-quality-gate` change, which runs `flutter analyze --fatal-infos`.

## What Changes

- `brainy-app/docs/setup/revenue_cat/initialize.dart` is removed with the rest of that folder, eliminating 3 errors and 1 info. (The folder deletion is driven by `secrets-hygiene`, which removes the credentials file beside it; this change owns the analyzer consequence.)
- `integration_test/screenshot_test.dart` stops importing `purchases_flutter` and stops calling `Purchases.configure(AppConstants.revenueCatApiKey)` — 4 errors and 1 info.
- `test/constants/app_constants_test.dart` drops its `RevenueCat` group, which asserted four constants that no longer exist — 4 errors, and the file starts loading again.
- The unused `REVENUECAT_API_KEY` GitHub secret and its `--dart-define` in the fastlane lane are removed.

## Capabilities

### New Capabilities
- `static-analysis-health`: the analyzer runs clean, and clean is enforced rather than hoped for.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for build hygiene. -->

## Impact

- `brainy-app/docs/setup/revenue_cat/` — deleted (shared with `secrets-hygiene`).
- `brainy-app/integration_test/screenshot_test.dart` — import and `setUpAll` block removed.
- `brainy-app/test/constants/app_constants_test.dart` — RevenueCat group removed; the YooKassa constants it half-duplicated are already covered by `subscription_constants_test.dart`.
- `brainy-app/ios/fastlane/Fastfile` — `--dart-define` for the RevenueCat key removed.
- GitHub repository secrets — `REVENUECAT_API_KEY` deleted.
- Unblocks `test-suite-stabilization` (two load failures) and `ci-quality-gate` (analyzer job).

Note: `test/constants/subscription_constants_test.dart` and the YooKassa constants themselves are deleted by `remove-monetization-go-free`, not here. This change only removes what the analyzer is failing on.
