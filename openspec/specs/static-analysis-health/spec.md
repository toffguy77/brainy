# static-analysis-health Specification

## Purpose
TBD - created by archiving change revenuecat-removal-cleanup. Update Purpose after archive.

## Requirements

### Requirement: The analyzer reports no issues

`flutter analyze --fatal-infos` SHALL report no errors, warnings, or infos across the entire package, including `test/` and `integration_test/`, and CI SHALL fail when it does not.

#### Scenario: Clean analyzer run

- **WHEN** `flutter analyze --fatal-infos` is run from `brainy-app/`
- **THEN** it prints `No issues found!` and exits `0`

#### Scenario: CI enforces the analyzer

- **WHEN** the CI workflow runs on a pull request or a push to `main`
- **THEN** it runs `flutter analyze --fatal-infos` and fails the job on any reported issue

### Requirement: No code references the removed purchase SDK

No file in the package SHALL import `purchases_flutter` or reference RevenueCat identifiers (`Purchases`, `PurchasesConfiguration`, `revenueCatApiKey`, `revenueCatEntitlement`, `productIdMonthly`, `productIdYearly`, `productIdFamily`). The only permitted occurrence is the guard list in `test/app/free_access_test.dart`.

#### Scenario: Repository search finds no functional reference

- **WHEN** the repository (excluding generated and vendored directories) is searched case-insensitively for `revenuecat`, `purchases_flutter`, `Purchases.` and `revenueCatApiKey`
- **THEN** the only match is the `purchases_flutter` needle in `test/app/free_access_test.dart`

#### Scenario: Reintroduction is caught by a test

- **WHEN** a file under `lib/` contains `purchases_flutter`
- **THEN** `test/app/free_access_test.dart` fails and names the offending file

#### Scenario: No StoreKit product configuration

- **WHEN** `brainy-app/ios/` is inspected
- **THEN** no `.storekit` file exists and the `Runner` scheme has no `storeKitConfigurationFileReference`

### Requirement: Every test file contributes coverage

Every test file SHALL compile and execute. A file that fails at the `loading` stage provides no coverage while appearing as though it does.

#### Scenario: Full test run has no load failures

- **WHEN** `flutter test` is run from `brainy-app/`
- **THEN** every test file loads and all tests pass

#### Scenario: The integration test compiles

- **WHEN** `flutter analyze` inspects `integration_test/screenshot_test.dart`
- **THEN** it reports no issues and the file configures no purchase SDK in `setUpAll`

### Requirement: No credential is injected into builds for a removed integration

The build pipeline SHALL NOT pass, store, or depend on credentials for RevenueCat.

#### Scenario: Workflows do not read the RevenueCat secret

- **WHEN** `.github/workflows/deploy-testflight.yml` and `.github/workflows/release.yml` are inspected
- **THEN** neither references `REVENUECAT_API_KEY`

#### Scenario: Fastlane does not inject the RevenueCat key

- **WHEN** the `deploy_testflight` and `release` lanes in `brainy-app/ios/fastlane/Fastfile` are inspected
- **THEN** neither passes a `--dart-define` for `REVENUECAT_API_KEY`

#### Scenario: The repository secret is deleted and the key revoked

- **WHEN** the repository's GitHub secrets are listed and the RevenueCat dashboard is checked
- **THEN** `REVENUECAT_API_KEY` is not among the secrets and the previously committed key is revoked

#### Scenario: Release builds succeed without the secret

- **WHEN** `deploy-testflight.yml` runs on `main`
- **THEN** the TestFlight build and upload succeed without any RevenueCat credential
