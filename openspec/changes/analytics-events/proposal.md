## Decision (2026-08-01)

Owner decision: **do not collect analytics.** `firebase_analytics`, the router observer and the placeholder service are removed, and the Analytics category is dropped from the App Store privacy declaration. This change is therefore a removal — task 1.2 applies and groups 2 through 5 are dropped.

## Why

`lib/shared/services/analytics_service.dart` contains exactly one line — a comment reading "Analytics service — will be implemented when Firebase is configured". Nothing imports it. There is not a single `logEvent` call in the codebase.

Meanwhile `firebase_analytics` is a declared dependency, Firebase is initialized at startup, the router installs a `FirebaseAnalyticsObserver`, and the App Store privacy labels declare that the app collects Analytics data. The app therefore tells Apple and its users that it collects analytics, while collecting nothing beyond automatic screen views.

Two problems follow. The privacy declaration overstates what the app does, which is the wrong direction to be wrong in a children's app. And with the product going fully free, engagement and retention are the only signals left worth measuring — there is no revenue to read instead.

## What Changes

- A real `AnalyticsService` wrapping `FirebaseAnalytics`, with a typed method per event rather than free-form string calls.
- A small, deliberate event set covering the funnel that matters: onboarding completion, session completion, records, streaks, achievements, character and accessory activity.
- No personal data, no free-text, no child-identifying values in any event or parameter.
- Event names and parameters defined as constants, so they cannot drift by typo.
- App Store privacy labels reviewed against what is actually collected.

Alternatively, if the owner prefers not to collect analytics at all, the dependency, the observer and the privacy declaration are removed. Declaring collection while collecting nothing is the one option that should not survive.

## Capabilities

### New Capabilities
- `product-analytics`: what the app measures, what it must never record, and how events are defined.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for analytics. -->

## Impact

- `lib/shared/services/analytics_service.dart` — implemented.
- `lib/constants/app_constants.dart` or a new `analytics_events.dart` — event and parameter name constants.
- Call sites: `game_screen.dart` and `result_screen.dart` (session, record), `onboarding_screen.dart` (completion), `achievements_provider.dart` (unlock), `character_screen.dart` and `accessories_screen.dart` (selection, purchase), `user_progress_provider.dart` (streak milestones).
- `docs/plans/ops/appstore-metadata.md` — privacy labels reviewed.
- `test/services/analytics_service_test.dart` — new.

Sequencing: worth landing after `remove-monetization-go-free`, since the funnel to measure changes substantially once the paywall is gone. Instrumenting the paywall first would produce events for screens about to be deleted.
