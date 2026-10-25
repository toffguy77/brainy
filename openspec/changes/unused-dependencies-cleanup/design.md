## Context

A grep for `package:<name>/` across `lib/`, `test/` and `integration_test/` found six declared dependencies with zero imports: `cloud_functions`, `shared_preferences`, `collection`, `riverpod_annotation`, `riverpod_generator`, `build_runner`.

Each has a traceable origin. `cloud_functions` was added for the YooKassa client, which was never uncommented. `shared_preferences` predates the move to Hive. The Riverpod codegen trio came with the project template; `CLAUDE.md` notes that Hive adapters are hand-written *because* `hive_generator` and `riverpod_generator` conflict — meaning the project chose the manual path and never removed the tooling for the path not taken.

The Riverpod case is the most actively harmful: `CLAUDE.md` lists `dart run build_runner build --delete-conflicting-outputs` under Commands, describing it as what to run "after adding `@riverpod` annotations". There are no annotations and no `.g.dart` files. Anyone following the documented workflow runs a generator that produces nothing.

Two further packages need judgement rather than a grep. `flutter_secure_storage` and `device_info_plus` are each imported exactly once, by `DeviceIdService` — which exists to give a payment backend a stable device identity. With payments removed, its consumer disappears.

## Goals / Non-Goals

**Goals:**
- Declared dependencies match imported dependencies.
- `CLAUDE.md` stops documenting tooling the project does not use.
- The device-id question is decided rather than defaulted.

**Non-Goals:**
- Upgrading dependencies. `flutter pub outdated` reports 105 packages with newer versions behind constraints; that is a separate, larger piece of work with real regression risk.
- Reducing the dependency count as a goal in itself. `confetti`, `audioplayers` and `screenshot` each have exactly one import and all earn their place.
- Adopting Riverpod code generation. Removing the tooling records the decision already made in practice.

## Decisions

**Remove the Riverpod codegen trio and correct `CLAUDE.md` together.** Removing the packages without fixing the documentation leaves a command that now fails outright rather than silently doing nothing — worse than the status quo. They are one change.

**Verify each removal with analyze, test and a real iOS build.** A grep for Dart imports misses platform channel registration and transitive requirements. The iOS build is the step that catches a package whose absence only manifests at link time.

**Decide the device-id question on its merits.** `DeviceIdService` reads and writes a device identifier through secure storage, with a `device_info_plus` fallback. Its only motivation was identifying an anonymous payer. Once payments are gone, the honest question is whether anything else needs a stable id — leaderboard identity comes from Game Center, and all other state is local. If nothing does, deleting the service and both packages is correct.

*Alternative considered:* keep the service in case a future feature needs it. Rejected — this is exactly the reasoning that produced the current list. Speculative retention is how `shared_preferences` survived the migration to Hive.

**Sequence after `remove-monetization-go-free`.** That change deletes `functions/` and the payment client, making `cloud_functions` unambiguously dead and settling the device-id question. Removing dependencies first would mean guessing at what that change will leave behind.

## Risks / Trade-offs

- **A package is used transitively or via platform channels and the grep misses it** → Mitigated by requiring a full iOS build, not just analysis, after each removal.
- **Removing `device_info_plus` loses a capability a future feature wants** → Re-adding a package is cheap; carrying an unused one indefinitely is not.
- **`pubspec.lock` churn produces a large diff** → Cosmetic; the lock file is meant to move with dependencies.
- **Removing `collection` breaks a transitive expectation** → Unlikely, since it is a Dart team package usually pulled transitively anyway; the build will confirm.

## Migration Plan

1. Land `remove-monetization-go-free`.
2. Remove `cloud_functions`, `shared_preferences` and `collection`. Verify.
3. Remove `riverpod_annotation`, `riverpod_generator` and `build_runner`; correct `CLAUDE.md` in the same commit. Verify.
4. Decide on device identity; if unneeded, delete `DeviceIdService`, its test, `flutter_secure_storage` and `device_info_plus`. Verify.
5. Re-run the import audit across every remaining dependency to confirm none was missed.

**Rollback:** re-add the dependency and run `flutter pub get`. Each step is independently revertible, which is why they are separate commits rather than one sweep.

## Open Questions

- Does anything still need a stable device identifier once payments are gone?
- Should the 105 outdated packages be addressed as a follow-up change?
- Does `integration_test/screenshot_test.dart` survive `remove-monetization-go-free`, and does its fate change any dependency's usage count?
