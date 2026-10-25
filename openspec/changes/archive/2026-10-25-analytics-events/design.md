## Outcome

Analytics was removed rather than implemented (owner decision 2026-08-01). The app links no analytics SDK, emits no events or screen views, has the Firebase analytics flag off, and uses Firebase solely for Crashlytics. The App Store privacy plan declares only crash diagnostics. See `proposal.md` `## Outcome` for file references.

## Context

When this change was opened, `analytics_service.dart` was a placeholder comment, `firebase_analytics` was a dependency, and the router attached a `FirebaseAnalyticsObserver`, so automatic screen-view events flowed while no custom event had ever been defined. The App Store privacy section declared Analytics and Crash Data. Crashlytics was genuinely wired; Analytics was declared but effectively unused, so the app over-declared — the wrong asymmetry for an app used by 6-to-14-year-olds.

## Goals / Non-Goals

**Goals:**
- Make the privacy declaration true.
- Collect nothing that could identify a child.

**Non-Goals:**
- Product analytics of any kind (decided).
- Removing Crashlytics. Crash reports stay; they are declared as diagnostics.
- Any analytics opt-out UI — there is nothing to opt out of.

## Decisions

**Remove instead of implement.** The original design treated removal as "a legitimate outcome" alongside a small typed event set. The owner chose removal: the app is free, has no accounts and serves children, so the measurement value does not justify the privacy surface or the declaration it would require.

**Remove the SDK, not just the calls.** Dropping `firebase_analytics` from `pubspec.yaml` (rather than leaving it linked and unused) means no code path can emit analytics and the binary does not contain the collector. The router observer went with it, which also ended automatic screen views.

**Turn off `IS_ANALYTICS_ENABLED` in `GoogleService-Info.plist`.** With the SDK gone the flag has no runtime effect, but leaving it `true` misdescribes the configuration and would silently re-enable collection if the SDK were ever re-added.

**Keep Crashlytics; declare it precisely.** Crash Data, Other Diagnostic Data and the Crashlytics installation ID (Device ID), all not linked to identity and not used for tracking. The plan instructs re-checking Firebase's Apple privacy table on SDK upgrades.

**Console and App Store Connect are out of the repo.** Un-declaring Analytics in App Store Connect and disabling Google Analytics in the Firebase project cannot be done from code; they are tracked as External tasks.

*Historical (not built):* typed `AnalyticsService` methods, event-name constants, fire-and-forget logging, debug/test suppression, age only as the onboarding bucket, and landing after `remove-monetization-go-free`. If analytics is ever reconsidered, it should be a new change that re-adopts these constraints and updates the privacy declaration in the same step.

## Risks / Trade-offs

- **No engagement data.** Questions such as onboarding completion or adaptive-difficulty progression cannot be answered from telemetry. Accepted by the owner.
- **Published labels lag the repo** until the App Store Connect edit is made (task 6.1). Until then the store still over-declares — the safe direction.
- **Re-adding a Firebase SDK could pull in analytics transitively.** Mitigated by `CLAUDE.md:26` and the flag being `false`; a future dependency bump should be checked against the "no analytics SDK" requirement.

## Migration Plan

1. Remove `firebase_analytics`, router observer, placeholder service (done, `f0e1ec8`).
2. Set `IS_ANALYTICS_ENABLED=false`, delete `firebase_service.dart`, rewrite privacy plan (done, `faf276b`).
3. External: update App Store Connect privacy labels; disable Google Analytics in the Firebase console.

**Rollback:** not needed; removal has no user-visible behaviour.

## Open Questions (resolved)

- *Implement or remove?* — Remove (2026-08-01).
- *Should adaptive-difficulty transitions be measured?* — No; no analytics is collected.
- *Does the screen-view observer need a privacy review of its route names?* — Moot; the observer was removed.
- *Should analytics be opt-out in the parent settings?* — No; there is nothing to opt out of.
