## ADDED Requirements

### Requirement: Supported platforms are stated explicitly

The project SHALL state in `CLAUDE.md` that iOS is the only supported platform, together with the date of the decision. Documentation SHALL NOT describe any platform as planned without a corresponding tracked change.

#### Scenario: Platform scope is discoverable

- **WHEN** `CLAUDE.md` is read
- **THEN** a `## Platform` section states the project is iOS only and gives the decision date (2026-08-01)

#### Scenario: No indefinite "not yet"

- **WHEN** `docs/plans/` and `CLAUDE.md` are searched for statements that something is not yet configured
- **THEN** none is found that lacks a named change, and no such statement concerns Android

### Requirement: Documentation describes only integrations that exist

Plans SHALL describe only platform integrations that are implemented. Leaderboard documentation MUST describe Game Center and MUST NOT describe Google Play Games as an integration of the app.

#### Scenario: Leaderboards describe Game Center

- **WHEN** `docs/plans/features/leaderboards.md` is read
- **THEN** it describes the Game Center integration, and Play Games appears at most as a note that the `games_services` package supports it while the project is iOS only

#### Scenario: CI documentation matches supported platforms

- **WHEN** `docs/plans/ops/ci-cd.md` is read
- **THEN** it documents only the iOS pipelines and states that no Android builds exist or are planned

### Requirement: Build triggers match supported platforms

Workflow path filters SHALL trigger builds only for platforms the workflow builds. The TestFlight deployment workflow MUST NOT include `brainy-app/android/**` in its path filter.

#### Scenario: iOS deployment is not triggered by Android-only changes

- **WHEN** a push to `main` touches only files under `brainy-app/android/`
- **THEN** `deploy-testflight.yml` does not run, because its `paths` filter lists only `brainy-app/lib/**`, `pubspec.yaml`, `pubspec.lock`, `ios/**`, `l10n/**` and `assets/**`

#### Scenario: No workflow references Android paths

- **WHEN** `.github/workflows/` is searched for `android`
- **THEN** there are no matches

### Requirement: The unsupported Android platform imposes no ongoing obligation

The project SHALL NOT retain documentation, configuration or process that implies Android work is owed. `brainy-app/android/` MAY remain as Flutter scaffolding, including the template release `signingConfig` that reads a gitignored `key.properties`, provided its status is stated.

#### Scenario: No pending Android deliverables remain

- **WHEN** `docs/plans/` is searched for Android
- **THEN** every mention states that the project is iOS only, and none describes Android work as outstanding

#### Scenario: Scaffolding is distinguished from intent

- **WHEN** `brainy-app/android/` is present in the repository
- **THEN** `CLAUDE.md` and `ci-cd.md` state it is unbuilt Flutter scaffolding with no builds, signing or store listing planned, so neither the directory nor its scaffolded signing config is read as a commitment

#### Scenario: Reversing the decision requires a named change

- **WHEN** the owner later decides to support Android
- **THEN** signing, Play Console setup, a build workflow, Play Games leaderboards and device testing are scoped in a separate named change before any plan describes Android as planned
