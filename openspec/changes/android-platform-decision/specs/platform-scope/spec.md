## ADDED Requirements

### Requirement: Supported platforms are stated explicitly

The project SHALL state which platforms it supports. Documentation SHALL NOT describe a platform as planned without a corresponding tracked change.

#### Scenario: Platform scope is discoverable

- **WHEN** `CLAUDE.md` or the plans are read
- **THEN** the supported platforms are stated unambiguously

#### Scenario: No indefinite "not yet"

- **WHEN** the plans are searched for statements that something is not yet configured
- **THEN** each either names the change that will configure it, or is removed

### Requirement: Documentation describes only integrations that exist or are scheduled

Plans SHALL NOT describe platform integrations that are neither implemented nor scheduled.

#### Scenario: Play Games references match reality

- **WHEN** `leaderboards.md` is read
- **THEN** it describes Google Play Games only if Android is a supported target with that integration configured

#### Scenario: CI documentation matches supported platforms

- **WHEN** `ci-cd.md` is read
- **THEN** it documents pipelines for supported platforms and does not imply a pipeline that will not be built

### Requirement: Build triggers match supported platforms

Workflow path filters SHALL trigger builds only for platforms the workflow actually builds.

#### Scenario: iOS deployment is not triggered by Android-only changes

- **WHEN** a change touches only files under `brainy-app/android/`
- **THEN** the iOS TestFlight workflow does not run, unless Android is a supported target built by that workflow

### Requirement: An unsupported platform imposes no ongoing obligation

If a platform is not supported, the project SHALL NOT retain documentation, configuration or process that implies work is owed for it.

#### Scenario: No pending Android deliverables remain

- **WHEN** Android is declared unsupported
- **THEN** no plan describes Android work as outstanding, and no workflow references Android paths

#### Scenario: Scaffolding is distinguished from intent

- **WHEN** `brainy-app/android/` is retained as Flutter scaffolding
- **THEN** that is stated, so its presence is not read as a commitment

### Requirement: A supported platform has a real pipeline

If a platform is declared supported, it SHALL have a build and release path, not only a source directory.

#### Scenario: Support implies a pipeline

- **WHEN** Android is declared supported
- **THEN** signing configuration, a build workflow and a store release path exist or are tracked in a named change
