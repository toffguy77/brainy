# dependency-hygiene Specification

## Purpose
TBD - created by archiving change unused-dependencies-cleanup. Update Purpose after archive.

## Requirements

### Requirement: Every declared dependency is used

`brainy-app/pubspec.yaml` SHALL declare only packages that are imported by code in `lib/`, `test/` or `integration_test/`. The exception is a dev dependency that is a tool configured from a project file (`flutter_lints` via `analysis_options.yaml`, and `flutter_launcher_icons` and `flutter_native_splash` via their `pubspec.yaml` config blocks).

#### Scenario: No unimported dependencies

- **WHEN** each dependency in `pubspec.yaml` is searched for as `package:<name>/` across `lib/`, `test/` and `integration_test/`
- **THEN** every one has at least one import, or is a tool-config dev dependency with its configuration present

#### Scenario: Previously unused packages stay removed

- **WHEN** `pubspec.yaml` is searched for `cloud_functions`, `shared_preferences`, `collection`, `flutter_secure_storage` and `device_info_plus`
- **THEN** none is declared as a direct dependency (a transitive entry in `pubspec.lock` is allowed)

#### Scenario: A newly added dependency has a consumer

- **WHEN** a dependency is added to `pubspec.yaml`
- **THEN** the same change adds code that imports it (for example, `url_launcher` for the legal links in parent settings, `flutter_timezone` for setting `tz.local` before scheduling reminders, and `fake_async` for timer tests)

### Requirement: Code generation tooling is declared only if code is generated

Code generation packages SHALL be declared only when the project actually generates code with them. Providers and Hive adapters are hand-written.

#### Scenario: No Riverpod codegen without annotations

- **WHEN** the codebase is searched for `@riverpod` and for `*.g.dart` files
- **THEN** neither exists, and `riverpod_annotation`, `riverpod_generator` and `build_runner` are absent from `pubspec.yaml`

#### Scenario: Documentation matches the toolchain

- **WHEN** `CLAUDE.md` is read
- **THEN** it does not instruct running `build_runner`, and it describes providers and Hive adapters as hand-written

### Requirement: Removals are verified, not assumed

Each dependency removal SHALL be verified by a clean analyzer run, a green test suite and a successful iOS build. A dependency SHALL NOT be removed on the strength of a grep alone.

#### Scenario: Analyzer and tests gate every change

- **WHEN** a change to `pubspec.yaml` is pushed
- **THEN** CI runs `flutter analyze --fatal-infos` and `flutter test`, and both pass

#### Scenario: iOS build confirms platform-level integrity

- **WHEN** a plugin dependency is removed or upgraded
- **THEN** `flutter build ios --no-codesign` succeeds on macOS, and the regenerated `ios/Podfile.lock` is committed so that it agrees with `pubspec.lock`

#### Scenario: Native build phases match how the plugins are integrated

- **WHEN** native SDKs such as Firebase are integrated through Swift Package Manager rather than CocoaPods
- **THEN** Xcode build phases do not reference CocoaPods-only paths such as `$PODS_ROOT/FirebaseCrashlytics/upload-symbols`

### Requirement: A dependency's purpose is re-examined when its consumer is removed

When the feature that motivated a dependency is deleted, that dependency and its supporting code SHALL be re-evaluated rather than retained by default. Any dependency that is retained SHALL have its reason recorded.

#### Scenario: No device identifier without a consumer

- **WHEN** the codebase is searched for a device-identity service, `flutter_secure_storage` or `device_info_plus`
- **THEN** none exists, because the payment flow that needed a device id is gone and player identity comes from Game Center

### Requirement: Dependency upgrades are handled separately from removals

Bulk upgrades of outdated packages SHALL be done in a dedicated change, not mixed into dependency cleanup.

#### Scenario: Cleanup does not upgrade versions

- **WHEN** this cleanup change is applied
- **THEN** no version constraint is raised for upgrade purposes, and outdated packages are tracked by a follow-up change
