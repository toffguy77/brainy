# product-analytics Specification

## Purpose
TBD - created by archiving change analytics-events. Update Purpose after archive.

## Requirements

### Requirement: No analytics SDK is bundled

The app SHALL NOT depend on any product-analytics SDK. Firebase dependencies MUST be limited to `firebase_core` and `firebase_crashlytics`.

#### Scenario: Dependencies contain no analytics package

- **WHEN** `brainy-app/pubspec.yaml` and `pubspec.lock` are inspected
- **THEN** neither lists `firebase_analytics` or any other analytics package, and the only Firebase packages are `firebase_core` and `firebase_crashlytics`

#### Scenario: No analytics service exists

- **WHEN** `brainy-app/lib/` is searched
- **THEN** there is no analytics service file and no reference to `FirebaseAnalytics`

### Requirement: No analytics events or screen views are emitted

The app SHALL NOT emit custom analytics events or automatic screen-view events in any build.

#### Scenario: Navigation sends no screen views

- **WHEN** the user navigates between routes
- **THEN** no screen-view event is sent, because the `GoRouter` in `lib/app/router.dart` installs no analytics observer

#### Scenario: Gameplay and progression send no events

- **WHEN** a user finishes onboarding, completes a session, sets a record, reaches a streak, unlocks an achievement, selects a character or buys an accessory
- **THEN** no analytics event is logged, because no `logEvent` call exists in the codebase

#### Scenario: Tests and debug builds emit nothing

- **WHEN** the test suite or a debug build runs
- **THEN** no analytics data is sent, since no analytics SDK is linked

### Requirement: Firebase analytics collection is disabled in configuration

The iOS Firebase configuration MUST mark analytics as disabled.

#### Scenario: Analytics flag is off

- **WHEN** `brainy-app/ios/Runner/GoogleService-Info.plist` is read
- **THEN** `IS_ANALYTICS_ENABLED` is `false`

### Requirement: Crash reporting is the only telemetry

Firebase SHALL be used only to report crashes through Crashlytics.

#### Scenario: Uncaught errors go to Crashlytics

- **WHEN** an uncaught Flutter framework error or uncaught asynchronous error occurs
- **THEN** it is recorded as a fatal error in Crashlytics (`FlutterError.onError` and the `runZonedGuarded` handler in `main.dart`)

#### Scenario: Startup initializes Firebase for Crashlytics only

- **WHEN** the app starts
- **THEN** `main.dart` initializes Firebase and wires Crashlytics handlers, and starts no other Firebase data collection

### Requirement: The privacy declaration lists only crash diagnostics

The App Store privacy plan in `docs/plans/ops/appstore-metadata.md` SHALL declare only the data Crashlytics collects, and MUST NOT declare Analytics.

#### Scenario: Declared categories match Crashlytics

- **WHEN** the privacy labels section of the plan is read
- **THEN** it lists Diagnostics → Crash Data, Diagnostics → Other Diagnostic Data and Identifiers → Device ID (Crashlytics installation ID), all marked not linked to identity and not used for tracking

#### Scenario: Analytics is explicitly not declared

- **WHEN** the privacy labels section of the plan is read
- **THEN** it states that Analytics is not collected and that the Analytics category must be removed from the App Store Connect declaration
