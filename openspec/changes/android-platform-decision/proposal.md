## Decision (2026-08-01)

Owner decision: **Android is not a supported target.** `brainy-app/android/` remains as unused Flutter scaffolding. Section 2 of the task list applies; section 3 is dropped.

## Why

The project is ambiguous about whether Android is a target. `docs/plans/ops/ci-cd.md` states "Android CI пока не настроен" — *not yet*, implying it is planned. `docs/plans/features/leaderboards.md` describes Google Play Games integration alongside Game Center. The `games_services` package supports both. `deploy-testflight.yml` includes `brainy-app/android/**` in its path filter, so an Android change triggers an iOS build.

Against that, `brainy-app/android/app/` contains only `build.gradle.kts` and `src`. There is no signing configuration in the repository, no Play Console pipeline, no Android workflow, and no evidence any Android build has been produced. The user's stated direction is iOS product completion.

"Not yet" is the expensive state. It means every change carries a small Android tax — keeping the plans plausible, keeping the path filter, wondering whether a platform-specific decision needs an Android counterpart — while delivering nothing. Either Android is a target and gets a pipeline, or it is not and the references go.

## What Changes

- An explicit decision is recorded: Android is either a supported target or it is not.
- If not: Android references are removed from the plans, the path filter is corrected, and Google Play Games is dropped from the leaderboards documentation. The `android/` directory may remain as Flutter scaffolding, but it stops being described as a pending deliverable.
- If yes: the work required is scoped honestly — signing, Play Console setup, a build workflow, Play Games leaderboard configuration, device testing — and tracked as its own change rather than as an implied intention.
- Either way, the documentation stops saying "not yet".

## Capabilities

### New Capabilities
- `platform-scope`: which platforms the project supports, and what support means.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for platform scope. -->

## Impact

- `docs/plans/ops/ci-cd.md` — the "Android CI not yet configured" line.
- `docs/plans/features/leaderboards.md` — Google Play Games references.
- `.github/workflows/deploy-testflight.yml` — the `brainy-app/android/**` path filter, which currently triggers an iOS build for Android-only changes.
- `CLAUDE.md` — platform scope, if it needs stating.
- `brainy-app/android/` — retained as scaffolding or removed, per the decision.

No application code changes under either outcome.
