## ADDED Requirements

### Requirement: The analyzer reports no issues

`flutter analyze` SHALL report no errors, warnings, or infos across the entire package, including `test/`, `integration_test/` and any Dart file under `docs/`.

#### Scenario: Clean analyzer run

- **WHEN** `flutter analyze` is run from `brainy-app/`
- **THEN** it prints `No issues found!` and exits `0`

#### Scenario: Infos are treated as failures in CI

- **WHEN** `flutter analyze --fatal-infos` is run in CI
- **THEN** it exits `0`

### Requirement: No source file references a removed dependency

No file in the package SHALL import a package absent from `pubspec.yaml`, or reference an identifier that no longer exists.

#### Scenario: No references to the removed purchase SDK

- **WHEN** the package is searched for `purchases_flutter`, `Purchases`, `PurchasesConfiguration`
- **THEN** no matches remain in any Dart file

#### Scenario: No references to deleted constants

- **WHEN** the package is searched for `revenueCatApiKey`, `revenueCatEntitlement`, `productIdMonthly`, `productIdYearly`, `productIdFamily`
- **THEN** no matches remain outside comments

### Requirement: Every test file contributes coverage

A test file SHALL compile and execute. A file that fails to load provides no coverage while appearing in the test directory as though it does.

#### Scenario: Previously broken test files execute

- **WHEN** `flutter test test/constants/app_constants_test.dart` is run
- **THEN** it loads and its tests execute and pass

#### Scenario: The integration test compiles

- **WHEN** `flutter analyze` inspects `integration_test/screenshot_test.dart`
- **THEN** it reports no issues for that file

### Requirement: No credential is injected into builds for a dependency that no longer exists

The build SHALL NOT pass secrets for removed integrations.

#### Scenario: Fastlane no longer injects the RevenueCat key

- **WHEN** `brainy-app/ios/fastlane/Fastfile` is inspected
- **THEN** it contains no `--dart-define` for `REVENUECAT_API_KEY`

#### Scenario: The unused repository secret is deleted

- **WHEN** the repository's GitHub secrets are listed
- **THEN** `REVENUECAT_API_KEY` is not among them
