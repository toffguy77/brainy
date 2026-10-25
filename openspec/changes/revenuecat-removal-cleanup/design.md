## Decision / Outcome

**Decision:** remove RevenueCat completely — code, tests, docs snippet, StoreKit config, CI env and Fastfile plumbing, and the external secret/key. The app is completely free and has no payment provider of any kind; earlier references to YooKassa as a replacement are historical only.

**Outcome:** in-repo removal is complete (`f0e1ec8`, `9180bab`, `faf276b`). Static evidence at HEAD:

| Area | Evidence |
|------|----------|
| Setup snippet | `brainy-app/docs/` no longer exists (deleted in `f0e1ec8`) |
| Integration test | `screenshot_test.dart:229` `setUpAll` only initialises Hive; no SDK import |
| Constants test | `app_constants_test.dart:7-108` has no `RevenueCat` group |
| Workflows | no `REVENUECAT_API_KEY` in `.github/workflows/` (removed in `9180bab`) |
| Fastfile | `build_app` at `Fastfile:59-70` (`deploy_testflight`) and `:152-163` (`release`) has no `--dart-define` |
| StoreKit | `ios/Runner/Products.storekit` deleted (`9180bab`), scheme ref removed (`faf276b`) |
| Guard | `test/app/free_access_test.dart:19-38` fails on `purchases_flutter` in `lib/` |
| CI | `ci.yml:54` runs `flutter analyze --fatal-infos`, `ci.yml:57` runs `flutter test` |

Maintainer reports `flutter analyze --fatal-infos` clean and 267 tests passing locally.

Pending, external: delete the `REVENUECAT_API_KEY` GitHub secret, revoke the key in the RevenueCat dashboard, confirm a TestFlight build on `main` succeeds without it.

## Context

The historical RevenueCat → YooKassa migration (`3b9684a`; YooKassa is gone too) removed `purchases_flutter` from `pubspec.yaml` and commented out the RevenueCat constants, but left three consumers behind:

| File | Issues | Nature |
|------|--------|--------|
| `docs/setup/revenue_cat/initialize.dart` | 3 errors + 1 info | Setup snippet, never part of the app |
| `integration_test/screenshot_test.dart` | 4 errors + 1 info | Configured the SDK in `setUpAll` |
| `test/constants/app_constants_test.dart` | 4 errors | Asserted four deleted constants |

The two test files failed at the `loading` stage, contributing zero coverage. The CI deploy and release workflows and both Fastfile lanes still injected `REVENUECAT_API_KEY` into builds.

The third info — `collection_methods_unrelated_type` in `share_card.dart` — belonged to `share-card-record-key-fix` and has since been fixed.

## Goals / Non-Goals

**Goals:**
- `flutter analyze --fatal-infos` clean, including tests and integration tests.
- Every test file loads and executes.
- No secret injected for an integration that no longer exists; the secret itself deleted and the key revoked.

**Non-Goals:**
- Product-level monetization removal (paywall, subscription feature, YooKassa, Cloud Functions). That is `remove-monetization-go-free`, which has landed.
- Wider rewrite of `screenshot_test.dart`.

## Decisions

**Delete the RevenueCat assertions rather than port them.** There is no payment provider left to port to; YooKassa and `subscription_constants_test.dart` were removed with the move to a free app.

**Delete `docs/setup/revenue_cat/` rather than exclude it from analysis.** A setup snippet for an abandoned integration has no reader and held a leaked credential. Excluding it in `analysis_options.yaml` was rejected: it keeps dead, non-compiling code while hiding it.

**Remove all build plumbing, not only the Fastfile.** Both the workflow `env:` entries and the `--dart-define` in both lanes were removed so that deleting the GitHub secret cannot break a build.

**Guard with a test, not just a grep.** `free_access_test.dart` fails if `purchases_flutter` (or other paid-tier identifiers) reappear in `lib/`, so the decision is enforced by CI.

## Risks / Trade-offs

- **A workflow still reads the deleted secret** → Mitigated: no workflow or Fastfile references `REVENUECAT_API_KEY` at HEAD. Final confirmation needs a TestFlight run on `main`.
- **The leaked key remains usable until revoked** → Revocation in the RevenueCat dashboard is an explicit external task.
- **`screenshot_test.dart` does not run in CI** → It needs a simulator; CI only checks that it compiles via the analyzer.

## Migration Plan

1. Delete `docs/setup/revenue_cat/`. Done.
2. Remove the SDK import and `setUpAll` call from `screenshot_test.dart`. Done.
3. Remove the `RevenueCat` group from `app_constants_test.dart`. Done.
4. Remove `REVENUECAT_API_KEY` from both workflows and both Fastfile lanes; delete `Products.storekit`. Done.
5. Run `flutter analyze --fatal-infos` and `flutter test`. Done (maintainer-reported; enforced in CI).
6. External: delete the GitHub secret, revoke the RevenueCat key, confirm a TestFlight build on `main`. Pending.

**Rollback:** ordinary git reverts. There is no reason to restore the secret: nothing consumes it.
