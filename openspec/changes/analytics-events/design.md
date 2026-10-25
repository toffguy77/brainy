## Context

`analytics_service.dart` is a placeholder comment. `firebase_analytics` is a dependency, `FirebaseService` initializes Firebase at startup, and the router attaches a `FirebaseAnalyticsObserver` — so automatic screen-view events do flow. Nothing else does: no custom event has ever been defined or sent.

The App Store privacy section declares collection of Analytics and Crash Data. Crashlytics is genuinely wired. Analytics is declared but effectively unused, so the app over-declares — which for an app used by 6-to-14-year-olds is the wrong asymmetry.

With monetization removed, engagement is the only signal. Whether the app is worth continuing to build depends on questions currently unanswerable: do people finish onboarding, do they come back the next day, does adaptive difficulty move anyone up a grid size, does the accessory shop give coins a purpose.

## Goals / Non-Goals

**Goals:**
- Answer a small number of concrete product questions.
- Collect nothing that could identify a child.
- Make the privacy declaration true.

**Non-Goals:**
- A comprehensive event taxonomy. A large event set nobody reads is worse than a small one that gets used, and every extra event is extra privacy surface.
- User-level identity, cohorts or cross-device tracking. No accounts exist, and adding identity to a children's app to improve dashboards is a poor trade.
- A second analytics vendor. Firebase is already present.
- A/B testing infrastructure.

## Decisions

**Typed methods, not a generic `log(String, Map)`.** A generic API invites free-text parameters at call sites, which is exactly how personal data leaks into analytics. `logSessionCompleted(gridSize: …, mode: …, …)` makes the parameter set reviewable in one file and makes a privacy audit a matter of reading the service, not grepping the app.

**Privacy constraint outranks measurement.** Written into the spec as an explicit precedence rule so that a future "it would be useful to know…" cannot quietly win. For a children's app the default answer to a new parameter is no.

**Age only as the existing coarse bucket.** Onboarding already collects `6-9` / `10-12` / `13-14` for difficulty tuning. Reusing the bucket adds no new precision. A precise age or birth date would be a meaningful escalation and is excluded.

**Swallow analytics failures.** Nothing about a metric justifies interrupting a child's game. Fire-and-forget, catch everything, log nothing to the user.

**Disable in debug and test.** Otherwise every local run and every CI execution pollutes production data, and the numbers stop being trustworthy — at which point nobody reads them and the whole exercise was wasted.

**Land after `remove-monetization-go-free`.** The funnel changes shape when the paywall and the seventh onboarding page disappear. Instrumenting screens scheduled for deletion would waste the work and produce a dataset with a discontinuity in it.

**Removal is a legitimate outcome.** If the owner does not want analytics, deleting the dependency, the observer and the privacy declaration is a complete and correct resolution. The unacceptable state is the current one: declaring collection that does not happen.

## Risks / Trade-offs

- **Instrumentation spreads analytics calls across many files** → Keep call sites shallow: one line at a decision point, no logic. Concentrate all shaping in the service.
- **Events are added over time without privacy review** → The spec requires review of parameters before any new event ships; enforcement is by code review.
- **Firebase Analytics has a documented parameter limit** → The event set is small; if a limit is approached, that is a signal the set has grown past its purpose.
- **Automatic screen views may already record more than intended** → Audit what the `FirebaseAnalyticsObserver` currently sends; route names are the risk, and none currently embed user data.
- **Analytics on a children's app carries regulatory weight (COPPA and similar)** → The no-personal-data rule is the mitigation. If the app is ever marketed to children in a jurisdiction with stricter rules, revisit; note that the 2.3.8 rejection already pushed the listing away from kids-directed language.

## Migration Plan

1. Owner decides: implement, or remove analytics entirely.
2. If implementing: write the service with typed methods and constant event names.
3. Add call sites one funnel stage at a time — onboarding, then sessions, then progression.
4. Verify events arrive in the Firebase console from a debug build with the debug flag enabled.
5. Confirm no events are emitted from tests.
6. Review the privacy labels against the shipped event set.

**Rollback:** the service is additive; removing the call sites disables collection without affecting behaviour, because every call is fire-and-forget.

## Open Questions

- Implement or remove? Needs an owner decision before any code.
- Should adaptive-difficulty transitions be measured, given that they are the app's central pedagogical claim?
- Does the existing screen-view observer already need a privacy review of its route names?
- Should analytics be opt-out in the parent settings, given the audience?
