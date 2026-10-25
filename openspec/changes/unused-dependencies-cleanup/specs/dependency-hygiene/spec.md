## ADDED Requirements

### Requirement: Every declared dependency is used

`pubspec.yaml` SHALL declare only packages that are imported by code in the package.

#### Scenario: No unimported dependencies

- **WHEN** each dependency in `pubspec.yaml` is searched for as `package:<name>/` across `lib/`, `test/` and `integration_test/`
- **THEN** every one has at least one import

#### Scenario: Identified unused packages are removed

- **WHEN** `cloud_functions`, `shared_preferences` and `collection` are searched for
- **THEN** they are absent from `pubspec.yaml`

### Requirement: Code generation tooling is declared only if code is generated

Code generation packages SHALL be declared only when the project actually generates code with them.

#### Scenario: No Riverpod codegen without annotations

- **WHEN** the codebase is searched for `@riverpod` and for `.g.dart` files
- **THEN** if neither exists, `riverpod_annotation`, `riverpod_generator` and `build_runner` are absent from `pubspec.yaml`

#### Scenario: Documentation matches the toolchain

- **WHEN** `CLAUDE.md` is read
- **THEN** it does not instruct running `build_runner` unless the project generates code

### Requirement: Removals are verified, not assumed

Each dependency removal SHALL be verified by a clean analyzer run, a green test suite and a successful build. A dependency SHALL NOT be removed on the strength of a grep alone.

#### Scenario: Verification after removal

- **WHEN** a dependency is removed
- **THEN** `flutter analyze`, `flutter test` and `flutter build ios --no-codesign` all succeed

#### Scenario: Transitive and platform usage is considered

- **WHEN** a package is considered for removal
- **THEN** platform channel registration and transitive requirements are checked, not only Dart imports

### Requirement: A dependency's purpose is re-examined when its consumer is removed

When the feature that motivated a dependency is deleted, that dependency and its supporting code SHALL be re-evaluated rather than retained by default.

#### Scenario: Device identity is re-examined after payments are removed

- **WHEN** the payment flow that motivated `DeviceIdService` is removed
- **THEN** the need for a device identifier is re-assessed, and `flutter_secure_storage` and `device_info_plus` are removed if nothing else requires them

#### Scenario: A retained dependency has a stated reason

- **WHEN** a dependency is kept despite its original consumer being gone
- **THEN** the reason is recorded

### Requirement: Documentation reflects the real architecture

The project's guidance SHALL describe the toolchain and patterns actually in use.

#### Scenario: State management description is accurate

- **WHEN** `CLAUDE.md` describes state management
- **THEN** it reflects that providers are written by hand and that Hive adapters are hand-written because the generators conflict
