## Decision (2026-08-01)

Owner decision: **do not collect analytics.** The app is completely free and has no accounts; product analytics in an app used by children is not worth the privacy cost. This change is therefore a **removal**: task 1.2 applies and the build/instrument/verify groups (2 to 4) are dropped.

## Outcome

- `firebase_analytics` removed from `brainy-app/pubspec.yaml` (`f0e1ec8`); only `firebase_core` and `firebase_crashlytics` remain (`pubspec.yaml:24-26`).
- `FirebaseAnalyticsObserver` removed from the router (`f0e1ec8`); `lib/app/router.dart:21` builds `GoRouter` without observers, so no screen views are sent.
- Placeholder `lib/shared/services/analytics_service.dart` deleted (`f0e1ec8`); the dead `firebase_service.dart` stub deleted (`faf276b`).
- `IS_ANALYTICS_ENABLED` set to `false` in `ios/Runner/GoogleService-Info.plist:19-20` (`faf276b`).
- Firebase remains for Crashlytics only: `main.dart:24-29,48` initializes Firebase and routes Flutter and zone errors to Crashlytics. `CLAUDE.md:26` records the rule.
- App Store privacy plan rewritten (`faf276b`, `docs/plans/ops/appstore-metadata.md:67-78`): only Crashlytics data is declared (Crash Data, Other Diagnostic Data, Device ID; not linked to identity, no tracking) and Analytics is explicitly not collected.
- Remaining work is external: un-declare Analytics in App Store Connect and disable Google Analytics in the Firebase console (tasks 6.1, 6.2).

## Why

At the time this change was opened, `analytics_service.dart` was a one-line placeholder comment, nothing called `logEvent`, yet `firebase_analytics` was a dependency, the router installed a `FirebaseAnalyticsObserver` (automatic screen views) and the App Store privacy labels declared Analytics. The declaration did not match the behaviour, and for a children's app over-declaring something half-wired is the wrong state to be in.

Two resolutions were possible: implement a small, privacy-safe event set, or remove analytics entirely. The owner chose removal.

## What Changes

- Remove the analytics SDK, the router observer and the placeholder service.
- Turn off the analytics flag in the Firebase iOS config.
- Keep Crashlytics as the sole Firebase data flow.
- Align the App Store privacy declaration with what is actually collected (crash diagnostics only).

*Historical:* the original proposal described an `AnalyticsService` with typed methods, event constants and a funnel event set (onboarding, sessions, records, streaks, achievements, character and accessory activity). None of that was built; it was superseded by the decision above.

## Capabilities

### New Capabilities
- `product-analytics`: the app collects no product analytics; crash reporting is the only telemetry, and the privacy declaration reflects that.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for analytics. -->

## Impact

- `brainy-app/pubspec.yaml`, `pubspec.lock` — `firebase_analytics` removed.
- `brainy-app/lib/app/router.dart` — observer removed.
- `brainy-app/lib/shared/services/analytics_service.dart`, `firebase_service.dart` — deleted.
- `brainy-app/ios/Runner/GoogleService-Info.plist` — `IS_ANALYTICS_ENABLED=false`.
- `docs/plans/ops/appstore-metadata.md` — privacy labels section rewritten.
- `CLAUDE.md` — "Firebase is used for Crashlytics only".
- External: App Store Connect privacy labels; Firebase console Google Analytics setting.
