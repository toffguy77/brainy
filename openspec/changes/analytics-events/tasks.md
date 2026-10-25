## 1. Decide

- [x] 1.1 Owner decides: implement analytics, or remove the dependency and the privacy declaration — decided 2026-08-01: remove, collect no analytics (see proposal `## Decision`)
- [x] 1.2 If removing: delete `firebase_analytics`, the router's `FirebaseAnalyticsObserver`, `analytics_service.dart`, and the Analytics entry in the privacy labels — then close this change — code removed in `f0e1ec8` (pubspec.yaml, router.dart, analytics_service.dart); `pubspec.yaml:24-26` lists only `firebase_core` + `firebase_crashlytics`; `router.dart:21` `GoRouter(` has no `observers`; `lib/shared/services/` has no analytics file; privacy plan updated in `faf276b` (`docs/plans/ops/appstore-metadata.md:67-78`). App Store Connect side is task 6.1
- [~] 1.3 Confirm `remove-monetization-go-free` has landed, so the funnel being instrumented is the final one — not applicable: nothing is instrumented

## 2. Build the service

- [~] 2.1 Define event and parameter name constants in one file — dropped: owner decision "no analytics"
- [~] 2.2 Implement `AnalyticsService` over `FirebaseAnalytics` with a typed method per event — dropped: owner decision "no analytics"
- [~] 2.3 Make every call fire-and-forget and swallow exceptions — dropped: no analytics calls exist
- [~] 2.4 Disable emission in debug builds and under test — dropped: nothing emits in any build
- [~] 2.5 Review every parameter against the no-personal-data rule — dropped: no events, no parameters

## 3. Instrument the funnel

- [~] 3.1 Onboarding completed — goals, frequency, age bucket — dropped: owner decision "no analytics"
- [~] 3.2 Session completed — grid size, mode, duration, mistakes, stars — dropped: owner decision "no analytics"
- [~] 3.3 Personal record set — grid size, mode — dropped: owner decision "no analytics"
- [~] 3.4 Streak milestone reached — streak length — dropped: owner decision "no analytics"
- [~] 3.5 Achievement unlocked — achievement id — dropped: owner decision "no analytics"
- [~] 3.6 Character selected — character id — dropped: owner decision "no analytics"
- [~] 3.7 Accessory purchased — accessory id, coin price — dropped: owner decision "no analytics"
- [~] 3.8 Keep each call site to a single line with no logic — dropped: no call sites

## 4. Verify

- [~] 4.1 Enable Firebase debug mode and confirm events arrive in the console — dropped: no events to verify
- [~] 4.2 Confirm no events are emitted during `flutter test` — superseded by 5.6: no analytics SDK is linked, so nothing can be emitted in any run
- [~] 4.3 Confirm no event carries a custom player name, precise age, free text or device identifier — superseded by 5.6: no events exist
- [~] 4.4 Audit the automatic screen-view events from the router observer for route names that embed user data — superseded: the observer was removed (`router.dart:21`, no `observers`), so no screen views are sent
- [~] 4.5 Add `test/services/analytics_service_test.dart` asserting events are suppressed under test — dropped: there is no service to test

## 5. Align the privacy declaration

- [~] 5.1 Compare the App Store privacy labels against the implemented event set — replaced by 5.2: compared against the actual data flow (Crashlytics only)
- [x] 5.2 Confirm every declared category is actually collected and nothing collected is undeclared — plan declares only Crashlytics data (Crash Data, Other Diagnostic Data, Device ID; not linked, no tracking) and states Analytics is not collected (`docs/plans/ops/appstore-metadata.md:69-78`), matching `main.dart:24-29,48` (Firebase init + Crashlytics handlers only)
- [x] 5.3 Update `docs/plans/ops/appstore-metadata.md` — done in `faf276b`
- [~] 5.4 Decide whether an analytics opt-out belongs in the parent settings, given the audience — not applicable: nothing to opt out of
- [x] 5.5 Set `IS_ANALYTICS_ENABLED` to false in `GoogleService-Info.plist` (added; audit finding) — `faf276b`, `brainy-app/ios/Runner/GoogleService-Info.plist:19-20`
- [x] 5.6 Confirm no analytics code remains (added) — no `firebase_analytics` in `pubspec.yaml` or `pubspec.lock`; no `FirebaseAnalytics`/`logEvent` in `lib/`, `test/`, `integration_test/`, `ios/Runner/`
- [x] 5.7 Delete the dead `firebase_service.dart` stub (added; audit finding) — `faf276b`; Firebase is initialized directly in `main.dart:24-26`
- [x] 5.8 Record "Firebase is used for Crashlytics only, no analytics" in project rules (added) — `CLAUDE.md:26`

## 6. External

- [ ] 6.1 External: in App Store Connect, remove the Analytics category from the App Privacy section so the published labels match `docs/plans/ops/appstore-metadata.md:69-78`
- [ ] 6.2 External: disable Google Analytics for the Firebase project `brainy-app-1e48c` in the Firebase console
