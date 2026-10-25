## 1. Prerequisites

- [x] 1.1 Confirm `remove-monetization-go-free` has landed. Evidence: `f0e1ec8` and `faf276b` ("remove monetization leftovers"). No payment, `cloud_functions` or YooKassa import remains in `lib/`.
- [x] 1.2 Re-run the import audit for every dependency (grep `package:<name>/` across `lib/`, `test/`, `integration_test/`). Evidence: re-run 2026-10-25; all 22 runtime packages (excluding the `flutter` SDK) and 3 test-only packages have imports, and the remaining 3 dev dependencies are tool configs (see 5.1).
- [~] 1.3 Record the pre-removal baseline. Dropped: the removals had already landed in the `f0e1ec8` snapshot, so a pre-removal baseline can't be recorded after the fact. Ongoing analyze and test gating is done by CI (`.github/workflows/ci.yml:54`, `:57`). The iOS build is 6.1.

## 2. Remove the clearly unused packages

- [x] 2.1 Remove `cloud_functions` from `pubspec.yaml`. Evidence: removed in `f0e1ec8`; absent from `pubspec.yaml` and `pubspec.lock`.
- [x] 2.2 Remove `shared_preferences`. Evidence: removed in `f0e1ec8`; absent from `pubspec.lock`.
- [x] 2.3 Remove `collection`. Evidence: removed in `f0e1ec8`; it remains only as `dependency: transitive` (`pubspec.lock:148-149`).
- [x] 2.4 Run `flutter pub get`, `flutter analyze`, `flutter test`. Evidence: `pubspec.lock` no longer lists the removed packages as direct dependencies. Analyze and test are gated by CI (`ci.yml:54` `--fatal-infos`, `ci.yml:57`).
- [~] 2.5 Run `flutter build ios --no-codesign`. Merged into 6.1: one Manual iOS build covers every removal step.

## 3. Remove the unused code generation toolchain

- [x] 3.1 Confirm no `@riverpod` annotation and no `.g.dart` file exists. Evidence: 0 `@riverpod` hits in `lib/` and `test/`; `find -name '*.g.dart'` (excluding `.dart_tool`) is empty.
- [x] 3.2 Remove `riverpod_annotation`, `riverpod_generator` and `build_runner`. Evidence: removed in `f0e1ec8`; absent from `pubspec.yaml`.
- [x] 3.3 Remove the `build_runner` command from the Commands section of `CLAUDE.md`. Evidence: no `build_runner` mention remains in `CLAUDE.md`.
- [x] 3.4 Correct the state-management section of `CLAUDE.md` to describe hand-written providers. Evidence: `CLAUDE.md:75`; Hive adapters hand-written at `CLAUDE.md:66`, `:79`; `pubspec.yaml:68` comment.
- [x] 3.5 Verify analyze and test. Evidence: CI gate (`ci.yml:54`, `:57`). The build part is in 6.1.

## 4. Decide on device identity

- [x] 4.1 Determine whether anything still requires a stable device identifier. Evidence: no. No device-id, secure-storage or device-info reference exists in `lib/`, `test/` or `integration_test/`. Identity comes from Game Center (`game_services_service.dart:19`).
- [x] 4.2 Delete `device_id_service.dart` and `device_id_service_test.dart`. Evidence: deleted in `f0e1ec8` (`git show --stat f0e1ec8`).
- [x] 4.3 Remove `flutter_secure_storage` and `device_info_plus`. Evidence: removed in `f0e1ec8`; absent from `pubspec.yaml`.
- [~] 4.4 If retaining, record the reason in `design.md`. N/A: the device id service was removed, so there is nothing to justify keeping.
- [x] 4.5 Verify analyze and test. Evidence: CI gate (`ci.yml:54`, `:57`). The build part is in 6.1.

## 5. Confirm the outcome

- [x] 5.1 Re-run the full import audit and confirm every remaining dependency has at least one import. Evidence (2026-10-25): every `pubspec.yaml` package is imported, e.g. `games_services` at `game_services_service.dart:2`, `uuid` at `game_provider.dart:4`, `url_launcher` at `parent_settings_screen.dart:6`, `flutter_timezone` at `notification_service.dart:3`, `fake_async` at `game_notifier_test.dart:2`, `integration_test` at `screenshot_test.dart:4`. Tool configs: `flutter_lints` (`analysis_options.yaml`), `flutter_launcher_icons` and `flutter_native_splash` (`pubspec.yaml:74`, `:81`). Nothing is unused.
- [x] 5.2 Confirm `CLAUDE.md` describes only tooling the project actually uses. Evidence: no codegen or build_runner commands; the Commands list is `flutter run`, `build ipa`, `test` and `analyze`.
- [ ] 5.3 External: note whether dependabot volume drops. This can't be measured from the repo: there is no `.github/dependabot.yml`, and alerts and PRs live in GitHub settings.
- [x] 5.4 Decide whether to open a follow-up change for the outdated packages. Decision: yes, as a separate follow-up change covering the 105 (now about 82) outdated packages. Nothing is upgraded in this change.
- [x] 5.5 Confirm the dependencies added since the first audit have real consumers. Evidence: `url_launcher` (`parent_settings_screen.dart:460`), `flutter_timezone` (`notification_service.dart:40-41`, fixes reminders firing in UTC), `fake_async` (`game_notifier_test.dart:35`).

## 6. Manual verification (macOS)

- [x] 6.1 Manual: run `flutter build ios --no-codesign` (or `flutter build ipa`) on macOS after `pod install`, and commit the regenerated `ios/Podfile.lock`. It currently pins `games_services (4.1.0)` (`Podfile.lock:3`) while `pubspec.lock:392` resolves `5.0.0`. — done: macOS build succeeds in deploy-testflight run 40216725096 (Podfile.lock is gitignored, regenerated on CI by pod install)
- [x] 6.2 Manual: confirm the Crashlytics build phase works. `project.pbxproj:395` runs `"$PODS_ROOT/FirebaseCrashlytics/upload-symbols"`, but `Podfile.lock` has no Firebase pods and plugins come through SPM (`FlutterGeneratedPluginSwiftPackage`, `project.pbxproj:20`). Fix the script path, or confirm the phase is a no-op or failing. — done: fixed in #28: the phase looks in Pods and SPM checkouts and skips with a warning; release build passes
