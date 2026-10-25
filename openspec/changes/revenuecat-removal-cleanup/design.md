## Context

The RevenueCat → YooKassa migration (`3b9684a`) removed the `purchases_flutter` dependency from `pubspec.yaml` and commented out the RevenueCat constants in `app_constants.dart`, but left three consumers behind:

| File | Issues | Nature |
|------|--------|--------|
| `docs/setup/revenue_cat/initialize.dart` | 3 errors + 1 info | Setup snippet, never part of the app |
| `integration_test/screenshot_test.dart` | 4 errors + 1 info | Configures the SDK in `setUpAll` |
| `test/constants/app_constants_test.dart` | 4 errors | Asserts four deleted constants |

The two test files fail at the `loading` stage, so they have been contributing zero coverage since the migration while still appearing in `test/`. Nobody noticed because no CI job ran the analyzer or the tests.

The third info — `collection_methods_unrelated_type` in `share_card.dart` — is a real bug and belongs to `share-card-record-key-fix`, not here. Both must land before `--fatal-infos` can pass.

## Goals / Non-Goals

**Goals:**
- `flutter analyze` clean, including tests and integration tests.
- The two broken test files execute again.
- No secret injected for an integration that no longer exists.

**Non-Goals:**
- Removing YooKassa constants or `subscription_constants_test.dart`. That is `remove-monetization-go-free`; doing it here would couple an analyzer fix to a product decision.
- Fixing the `share_card.dart` info. That is `share-card-record-key-fix`.
- Rewriting `screenshot_test.dart` beyond removing the SDK call. Its wider fate depends on `remove-monetization-go-free`, which changes the screens it captures.

## Decisions

**Delete the RevenueCat assertions rather than port them to YooKassa.** `subscription_constants_test.dart` already covers the YooKassa constants — prices, Hive keys, uniqueness — more thoroughly than the deleted group did. Porting would duplicate coverage that `remove-monetization-go-free` is about to delete anyway.

**Delete `docs/setup/revenue_cat/` rather than move it outside the analyzed tree.** A setup snippet for an abandoned integration has no reader. It also holds the leaked credential, so `secrets-hygiene` deletes it regardless; this change simply owns the analyzer half of that outcome.

*Alternative considered:* add the folder to `analysis_options.yaml` excludes. Rejected — it keeps dead, non-compiling code while hiding it, which is how this situation arose.

**Remove the fastlane `--dart-define` in this change, not in `secrets-hygiene`.** The two are related but distinct: `secrets-hygiene` revokes the key, this change removes the plumbing that passes it. Keeping them separate means revoking the key does not depend on an app-side edit landing first.

**Fix the analyzer before touching the test deadlock.** `test-suite-stabilization` needs a clean full-suite signal to tell an order-dependent deadlock from a compile failure. Landing this first removes two confounds.

## Risks / Trade-offs

- **`--fatal-infos` fails on an info this change does not own** → Expected. `share-card-record-key-fix` must land before the CI analyzer job becomes required. Sequenced in `ci-quality-gate`.
- **`screenshot_test.dart` still does not run in CI** → It needs a device or simulator and is out of scope for the unit CI job. It will at least compile, which is what `flutter analyze` checks.
- **Removing the GitHub secret breaks a workflow that still reads it** → Grep the workflows before deleting; only the fastlane lane references it.

## Migration Plan

1. Delete `docs/setup/revenue_cat/`.
2. Remove the import and `setUpAll` SDK call from `screenshot_test.dart`.
3. Remove the `RevenueCat` group from `app_constants_test.dart`.
4. Run `flutter analyze` — expect only the `share_card.dart` info to remain.
5. Remove the fastlane `--dart-define` and delete the GitHub secret.
6. Run the two previously broken test files to confirm they execute.

**Rollback:** ordinary reverts; deleting a secret is the only non-git action, and it can be re-added from the RevenueCat dashboard if ever needed.

## Open Questions

- Should `analysis_options.yaml` gain stricter lints once the baseline is clean? Better as a follow-up than bundled here.
- Does `screenshot_test.dart` still serve a purpose once `remove-monetization-go-free` deletes the paywall screens it captures? Revisit there.
