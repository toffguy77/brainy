## 1. Decide

- [x] 1.1 Owner decides: implement analytics, or remove the dependency and the privacy declaration
- [x] 1.2 If removing: delete `firebase_analytics`, the router's `FirebaseAnalyticsObserver`, `analytics_service.dart`, and the Analytics entry in the privacy labels — then close this change
- [ ] 1.3 Confirm `remove-monetization-go-free` has landed, so the funnel being instrumented is the final one

## 2. Build the service

- [ ] 2.1 Define event and parameter name constants in one file
- [ ] 2.2 Implement `AnalyticsService` over `FirebaseAnalytics` with a typed method per event
- [ ] 2.3 Make every call fire-and-forget and swallow exceptions
- [ ] 2.4 Disable emission in debug builds and under test
- [ ] 2.5 Review every parameter against the no-personal-data rule

## 3. Instrument the funnel

- [ ] 3.1 Onboarding completed — goals, frequency, age bucket
- [ ] 3.2 Session completed — grid size, mode, duration, mistakes, stars
- [ ] 3.3 Personal record set — grid size, mode
- [ ] 3.4 Streak milestone reached — streak length
- [ ] 3.5 Achievement unlocked — achievement id
- [ ] 3.6 Character selected — character id
- [ ] 3.7 Accessory purchased — accessory id, coin price
- [ ] 3.8 Keep each call site to a single line with no logic

## 4. Verify

- [ ] 4.1 Enable Firebase debug mode and confirm events arrive in the console
- [ ] 4.2 Confirm no events are emitted during `flutter test`
- [ ] 4.3 Confirm no event carries a custom player name, precise age, free text or device identifier
- [ ] 4.4 Audit the automatic screen-view events from the router observer for route names that embed user data
- [ ] 4.5 Add `test/services/analytics_service_test.dart` asserting events are suppressed under test

## 5. Align the privacy declaration

- [ ] 5.1 Compare the App Store privacy labels against the implemented event set
- [ ] 5.2 Confirm every declared category is actually collected and nothing collected is undeclared
- [ ] 5.3 Update `docs/plans/ops/appstore-metadata.md`
- [ ] 5.4 Decide whether an analytics opt-out belongs in the parent settings, given the audience
