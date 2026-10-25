## Outcome

Decided 2026-08-01 by the owner: **iOS only.** Recorded in `CLAUDE.md:22-26`. The "not supported" branch of the migration plan was carried out (plans, path filter, `CLAUDE.md`); the "supported" branch was not needed. `brainy-app/android/` stays as unbuilt Flutter scaffolding.

## Context

Flutter scaffolds both platforms by default, so `brainy-app/android/` exists whether or not anyone intends to ship it. What turns scaffolding into an implied commitment is the surrounding documentation.

Evidence that Android was intended (state before this change): `ci-cd.md` said Android CI was "not yet" configured; `leaderboards.md` described Google Play Games alongside Game Center; the `games_services` package supports both; `deploy-testflight.yml` watched `brainy-app/android/**`.

Evidence that it was not: `android/app/` holds only `build.gradle.kts` and `src`. `build.gradle.kts:11-14,39-56` contains the Flutter-template release `signingConfig` reading a gitignored `key.properties` (`brainy-app/android/.gitignore:12`), falling back to debug signing — scaffolding, not a release setup. There is no keystore in the repository, no Play Console pipeline, no Android workflow, no release history. The App Store metadata, fastlane setup, monitoring workflow and the entire release process are iOS-only. The stated direction is completing the iOS product.

> Correction: an earlier draft said "there is no keystore configuration". The scaffolded signing config above does exist; what is absent is a committed keystore and any pipeline that uses it.

The path filter was the one place this ambiguity did something concrete and wrong: a change touching only Android files triggered a macOS runner to build and upload an iOS build to TestFlight. Fixed: `deploy-testflight.yml:7-13`.

## Goals / Non-Goals

**Goals:**
- Record an explicit decision. — Done.
- Remove the ongoing tax of an undeclared maybe. — Done.
- Fix the path filter either way. — Done.

**Non-Goals:**
- Making the decision. It is a product and business call — market, audience, capacity — not a technical one. This change forced it to be made and recorded; the owner made it.
- Building an Android pipeline.
- Removing `brainy-app/android/`. Flutter regenerates it, and deleting scaffolding to signal intent is a poor mechanism; a stated decision is the right mechanism.

## Decisions

**Force the decision rather than default to one.** The previous state was not neutral — it cost a little on every change and delivered nothing. Result: iOS only.

**Keep the `android/` directory but state its status.** Deleting it fights the framework. Documenting it as unbuilt scaffolding costs one sentence (`CLAUDE.md:24-25`, `ci-cd.md:12-13`) and removes the ambiguity.

**Fix the path filter.** With Android unsupported, `brainy-app/android/**` no longer triggers an iOS deployment.

**Do not preserve Play Games documentation "just in case".** `leaderboards.md` now describes Game Center; if Android arrives later, the documentation arrives with it.

**`games_services` stays as is.** The package supports both platforms; that needs no change. The service still passes `androidLeaderboardID` values to the package API (`brainy-app/lib/shared/services/game_services_service.dart:35,54,69,93`); these are inert on iOS and out of scope for this documentation-only change.

**Sequence alongside `plans-code-sync`.** This change supplied the decision; the resulting `ci-cd.md` and `leaderboards.md` edits landed directly, and `plans-code-sync` has no Android tasks to conflict with.

## Risks / Trade-offs

- **Declaring Android unsupported closes a door** → It does not: the code is cross-platform Flutter and the decision is reversible at any time. What is removed is only the implication that work is owed.
- **Someone later assumes Android works because the directory exists** → Mitigated by `CLAUDE.md` `## Platform` and `ci-cd.md:12-13`.
- **Someone assumes Android is release-ready because a signing config exists** → The config is the Flutter template; without a pipeline it implies nothing. Stated in `CLAUDE.md:24-25` ("no Android builds, signing or store listing are planned").
- **Changing the path filter breaks a build trigger someone relies on** → No one could rely on Android paths triggering an iOS build; that behaviour was a bug.

## Migration Plan

1. Owner decides: supported, or not. — Done: not supported (2026-08-01).
2. Remove the Android line from `ci-cd.md`; remove Play Games from `leaderboards.md`; state the scaffolding's status; drop `brainy-app/android/**` from the deploy path filter. — Done.
3. ~~If yes: create a separate change scoping signing, Play Console, the build workflow, Play Games configuration and device testing.~~ — Not applicable.
4. Record the decision in `CLAUDE.md` so it does not need making again. — Done.

**Rollback:** documentation and one workflow filter line; trivially revertible.

## Open Questions (resolved)

- Is Android a target? — **No.** iOS only, decided 2026-08-01.
- If yes, does the free release change the Play Store calculus? — Moot; Android is not a target.
- Should `leaderboards.md` describe Game Center concretely? — **Yes**, and it now does (`leaderboards.md:10`).
