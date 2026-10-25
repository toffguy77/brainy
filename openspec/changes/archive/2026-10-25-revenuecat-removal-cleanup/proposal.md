## Decision / Outcome

**Owner decision:** RevenueCat is not needed at all. Brainy is completely free; it has no payments of any kind (no RevenueCat, no YooKassa, no StoreKit products, no Cloud Functions).

**Outcome (as of `1e1e279`, branch `chore/finish-audit-changes`):** all in-repo work is done across `f0e1ec8`..HEAD.

- `f0e1ec8` — deleted `brainy-app/docs/setup/revenue_cat/`, the `purchases_flutter` import and `Purchases.configure` block in `integration_test/screenshot_test.dart`, the `RevenueCat` group in `test/constants/app_constants_test.dart`, and (as part of going free) the YooKassa constants and `subscription_constants_test.dart`.
- `9180bab` — removed `REVENUECAT_API_KEY` from `.github/workflows/deploy-testflight.yml`, `.github/workflows/release.yml` and the `--dart-define` from both Fastfile lanes (`deploy_testflight`, `release`); deleted `ios/Runner/Products.storekit`.
- `faf276b` — removed the `Products.storekit` reference from `Runner.xcscheme`.
- A repo-wide grep finds no functional RevenueCat reference; `test/app/free_access_test.dart` guards against `purchases_flutter` reappearing in `lib/`.
- Maintainer reports `flutter analyze --fatal-infos` clean and `flutter test` green (267 tests); CI enforces both (`.github/workflows/ci.yml:54,57`).

**Still pending (external, not in git):** delete the `REVENUECAT_API_KEY` GitHub secret; revoke the key in the RevenueCat dashboard; confirm a TestFlight build succeeds without it (CI run on `main`).

## Why

`flutter analyze` reported 11 errors and 3 infos, every one of them a leftover of the RevenueCat integration. The dependency had been dropped from `pubspec.yaml` and the constants commented out, but three files still imported `purchases_flutter` and referenced deleted constants. Two of those files were tests, so they failed at the `loading` stage and contributed no coverage while looking like they did. The CI pipeline also still injected a RevenueCat secret into release builds.

(Historical note: the original write-up described RevenueCat as "replaced by YooKassa" in `3b9684a`. YooKassa has since been removed too; the app has no payments at all.)

A red analyzer trains everyone to ignore analyzer output, and it blocked `ci-quality-gate`, which runs `flutter analyze --fatal-infos`.

## What Changes

- `brainy-app/docs/setup/revenue_cat/` is removed (shared with `secrets-hygiene`, which owns the credential in it).
- `integration_test/screenshot_test.dart` no longer imports `purchases_flutter` or calls `Purchases.configure`.
- `test/constants/app_constants_test.dart` drops its `RevenueCat` group.
- `REVENUECAT_API_KEY` is no longer passed by `deploy-testflight.yml`, `release.yml`, or either Fastfile lane.
- `ios/Runner/Products.storekit` and its scheme reference are removed.
- Externally: the GitHub secret is deleted and the RevenueCat key revoked.

## Capabilities

### New Capabilities
- `static-analysis-health`: the analyzer runs clean, every test file loads, no code or build plumbing references the removed purchase SDK, and this is enforced by CI and a guard test.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for build hygiene. -->

## Impact

- `brainy-app/docs/setup/revenue_cat/` — deleted.
- `brainy-app/integration_test/screenshot_test.dart` — SDK import and `setUpAll` call removed.
- `brainy-app/test/constants/app_constants_test.dart` — RevenueCat group removed.
- `.github/workflows/deploy-testflight.yml`, `.github/workflows/release.yml` — `REVENUECAT_API_KEY` env removed.
- `brainy-app/ios/fastlane/Fastfile` — `--dart-define` removed from `deploy_testflight` and `release`.
- `brainy-app/ios/Runner/Products.storekit`, `Runner.xcscheme` — deleted / reference removed.
- GitHub repository secrets and RevenueCat dashboard — external cleanup pending.
- Unblocked `test-suite-stabilization` (two load failures) and `ci-quality-gate` (analyzer job).
