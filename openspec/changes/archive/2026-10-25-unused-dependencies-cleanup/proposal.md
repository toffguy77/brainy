## Decision / Outcome (2026-10-25)

**Implemented in code, apart from the manual verification on macOS.** Re-audit on branch `chore/finish-audit-changes` (commits `f0e1ec8..1e1e279`): every package in `brainy-app/pubspec.yaml` now has at least one import in `lib/`, `test/` or `integration_test/`. The exceptions are tool-config dev dependencies (`flutter_lints` via `analysis_options.yaml`, `flutter_launcher_icons` and `flutter_native_splash` via their `pubspec.yaml` config blocks at lines 74 and 81).

- **Removed (8 unused packages):** the 6 originally identified (`cloud_functions`, `shared_preferences`, `collection`, `riverpod_annotation`, `riverpod_generator`, `build_runner`), plus `flutter_secure_storage` and `device_info_plus` together with `DeviceIdService` and its test (`git show f0e1ec8 -- brainy-app/pubspec.yaml`). `firebase_analytics` was removed in the same commit together with its only consumer (`lib/app/router.dart` at `f0e1ec8~1`), so it is not counted as an unused package.
- **Count correction:** the first audit listed 6 unused packages, but there were 7. `url_launcher` was declared (`pubspec.yaml:51` at `f0e1ec8`) yet imported nowhere; the privacy and terms links lived only in constants. It is now used (see below), so it stays.
- **Dependencies added or put to use since the first audit, each with a real consumer:**
  - `url_launcher` (`pubspec.yaml:51`) is now imported by `lib/features/parent/screens/parent_settings_screen.dart:6`, which opens the privacy and terms links (`:274`, `:279`, `launchUrl` at `:460`).
  - `flutter_timezone` (`pubspec.yaml:59`) is imported by `lib/shared/services/notification_service.dart:3` and sets `tz.local` (`:40-41`). Before this, `tz.local` stayed UTC, so a 20:00 reminder fired at 20:00 UTC.
  - `fake_async` (dev, `pubspec.yaml:67`) is imported by `test/game/game_notifier_test.dart:2` for deterministic timer tests (`fakeAsync` at `:35`, `:53`).
- `CLAUDE.md` no longer documents `build_runner`. It describes hand-written providers (`CLAUDE.md:75`) and hand-written Hive adapters (`CLAUDE.md:66`, `:79`).
- `assets/animations/` was removed together with its `pubspec.yaml` asset entry (`faf276b`).
- **Outdated packages (105, about 82 at the 2026-10-25 audit): left out of scope here, with a separate follow-up change recommended.** Upgrades carry regression risk unrelated to removing unused packages.
- **Dependabot volume:** this can't be measured from the repo, because there is no `.github/dependabot.yml` and alerts live on the GitHub side. It is left as an External task.
- **Open risk (Manual, needs macOS):** `ios/Podfile.lock` looks stale. It pins `games_services (4.1.0)` (`Podfile.lock:3`) while `pubspec.lock:392` resolves `5.0.0`, and it lists no Firebase pods, which suggests Firebase arrives through SPM (`FlutterGeneratedPluginSwiftPackage`, `project.pbxproj:20`, `:228`). Yet `project.pbxproj:395` still runs `"$PODS_ROOT/FirebaseCrashlytics/upload-symbols"`, a path that would not exist under SPM. Both points need a real iOS build to confirm.

## Why

Several declared dependencies had zero imports anywhere in `lib/`, `test/` or `integration_test/`:

| Package | Imports | Why it was there |
|---------|---------|------------------|
| `cloud_functions` | 0 | Added for YooKassa; `SubscriptionService` was a stub |
| `shared_preferences` | 0 | Superseded by Hive |
| `collection` | 0 | Unclear (still present transitively) |
| `riverpod_annotation` | 0 | No `@riverpod` annotation exists |
| `riverpod_generator` | 0 | No `.g.dart` file is generated |
| `build_runner` | 0 | Nothing to generate |
| `url_launcher` | 0 (at first audit) | Missed by the first audit; now used for legal links |

The Riverpod codegen trio was the most misleading. `CLAUDE.md` documented a `build_runner` command although the project had no annotation and no generated file.

Unused dependencies enlarge the build, slow resolution, generate dependabot noise and misrepresent the architecture.

## What Changes

- Dependencies with no imports are removed from `pubspec.yaml`.
- The Riverpod codegen packages are removed, and `CLAUDE.md` stops documenting a build_runner workflow.
- `DeviceIdService`, `flutter_secure_storage` and `device_info_plus` are removed. Payments are gone, and nothing else needs a stable device id: leaderboards use Game Center (`lib/shared/services/game_services_service.dart`).
- Each new dependency must have a consumer. `url_launcher`, `flutter_timezone` and `fake_async` do.
- Removals are checked by CI's analyze and test runs (`.github/workflows/ci.yml:54`, `:57`) and by a manual iOS build.

## Capabilities

### New Capabilities
- `dependency-hygiene`: the standard for what may be declared as a dependency.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for dependencies. -->

## Impact

- `brainy-app/pubspec.yaml` and `pubspec.lock`: removals done.
- `CLAUDE.md`: build_runner command and codegen claim removed.
- `lib/shared/services/device_id_service.dart` and `test/services/device_id_service_test.dart`: deleted.
- Follow-ups outside this change: upgrading the outdated packages (a separate change), and on macOS, regenerating `Podfile.lock` and checking the Crashlytics `upload-symbols` build phase.
