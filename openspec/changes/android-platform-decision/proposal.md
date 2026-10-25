## Decision (2026-08-01)

Owner decision: **Android is not a supported target. The project is iOS only.** `brainy-app/android/` remains as unbuilt Flutter scaffolding. Section 2 of the task list applies and is done; section 3 ("If Android IS supported") is dropped.

## Outcome

- `CLAUDE.md:22-26` has a `## Platform` section: iOS only, decision dated 2026-08-01, `brainy-app/android/` is unbuilt scaffolding, no Android builds, signing or store listing planned.
- `docs/plans/ops/ci-cd.md:12-13` states the project is iOS only; the "Android CI пока не настроен" line is gone.
- `docs/plans/features/leaderboards.md:10` describes Game Center; Play Games is mentioned only to say the package supports it and the project does not use it.
- `.github/workflows/deploy-testflight.yml:7-13` no longer watches `brainy-app/android/**`; no workflow references Android paths.
- No plan in `docs/plans/` describes Android work as outstanding.

## Why

Before this change, the project was ambiguous about whether Android was a target. `docs/plans/ops/ci-cd.md` stated "Android CI пока не настроен" — *not yet*, implying it was planned. `docs/plans/features/leaderboards.md` described Google Play Games integration alongside Game Center. The `games_services` package supports both. `deploy-testflight.yml` included `brainy-app/android/**` in its path filter, so an Android change triggered an iOS build.

Against that, `brainy-app/android/` has no release pipeline. `brainy-app/android/app/build.gradle.kts:11-14,39-56` contains the standard Flutter-scaffolded release `signingConfig`, which reads a gitignored `key.properties` (`brainy-app/android/.gitignore:12`) and falls back to debug signing when the file is absent. There was no Play Console pipeline, no Android workflow, and no evidence any Android release build had been shipped. The user's stated direction is iOS product completion.

> Correction: an earlier draft of this proposal said "there is no signing configuration in the repository". That was wrong — the scaffolded signing config above exists. What is absent is a keystore in the repository and any pipeline that uses it.

"Not yet" is the expensive state. It means every change carries a small Android tax — keeping the plans plausible, keeping the path filter, wondering whether a platform-specific decision needs an Android counterpart — while delivering nothing. Either Android is a target and gets a pipeline, or it is not and the references go. The owner chose the latter.

## What Changes

- An explicit decision is recorded: Android is not a supported target.
- Android references are removed from the plans, the path filter is corrected, and Google Play Games is dropped from the leaderboards documentation. The `android/` directory remains as Flutter scaffolding and is described as such, not as a pending deliverable.
- The documentation no longer says "not yet".
- (Historical, not taken: if Android had been supported, the work — signing, Play Console setup, a build workflow, Play Games leaderboard configuration, device testing — would have been tracked as its own change.)

## Capabilities

### New Capabilities
- `platform-scope`: which platforms the project supports, and what support means.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for platform scope. -->

## Impact

- `docs/plans/ops/ci-cd.md` — "Android CI not yet configured" replaced by an iOS-only statement.
- `docs/plans/features/leaderboards.md` — Game Center described concretely; Play Games not described as an integration.
- `.github/workflows/deploy-testflight.yml` — `brainy-app/android/**` removed from the path filter.
- `CLAUDE.md` — `## Platform` section added.
- `brainy-app/android/` — retained as scaffolding, unchanged.

No application code changes.
