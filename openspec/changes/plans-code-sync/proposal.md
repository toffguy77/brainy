## Why

`CLAUDE.md` declares that `docs/plans/features/` is the source of truth, that it is living documentation of how the app behaves, and that agents must read the relevant plan before implementing and update it after. The audit found ten places where the plans describe something the code does not do.

That is worse than having no documentation. An agent or developer who follows the stated process reads a plan, believes it, and builds on a false premise. Two of the errors would send someone hunting for a git branch that does not exist.

| # | Document | Claims | Reality |
|---|----------|--------|---------|
| 1 | `CLAUDE.md`, `subscription.md` | YooKassa lives on branch `feat/yookassa-payment` | No such branch; the code is on `main` in `functions/` |
| 2 | `CLAUDE.md` | Firestore stores leaderboard scores via the league feature | No Firestore usage in `lib/` at all; leaderboards are Game Center |
| 3 | `CLAUDE.md` | Run `build_runner` after adding `@riverpod` annotations | No annotations, no `.g.dart` files, no code generation |
| 4 | `ci-cd.md` | Workflows are `deploy-ios.yml` and `submit-review.yml`, triggered by tag | Actual: `deploy-testflight.yml` (push to main), `release.yml` (tag), `monitor.yml` (cron) |
| 5 | `progress-tracking.md` | Achievements include `triple_record`, `fast_3x3`, `collector_10`, `no_mistakes` | Actual: `speedDemon`, `focusMode`, `nightOwl`, `coinHoarder` |
| 6 | `leaderboards.md` | Leaderboard IDs are `weekly_xp`, `best_time_3x3` | Actual: `brainy_weekly_xp`, `brainy_best_time_{N}x{N}` |
| 7 | `character-system.md` | Characters render as SVG avatars | PNG assets |
| 8 | `character-system.md` | `CharacterData` has `equippedHat/Glasses/Effect` | Also has `equippedCape` |
| 9 | `subscription.md` | See `brainy-tasks/TASK_10_1_yookassa.md` | `brainy-tasks/` was deleted |
| 10 | `parent-panel.md` | Maximum session time limits play | Never read by game code |

## What Changes

- Every claim above is corrected against the code, or the code is corrected if the plan describes the intended behaviour.
- Plans that describe deleted features are deleted rather than updated.
- `ci-cd.md` is rewritten, since it documents a superseded workflow generation rather than containing isolated errors.
- A verification step is defined so that plans are checked against the code rather than assumed correct.

## Capabilities

### New Capabilities
- `living-documentation`: what it means for the plans to be a source of truth, and how that is kept true.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for documentation. -->

## Impact

- `CLAUDE.md` — three corrections (items 1, 2, 3).
- `docs/plans/ops/ci-cd.md` — rewritten.
- `docs/plans/features/progress-tracking.md`, `leaderboards.md`, `character-system.md`, `parent-panel.md` — corrected.
- `docs/plans/features/subscription.md` — deleted by `remove-monetization-go-free`.
- `lib/shared/services/subscription_service.dart` — the dead `brainy-tasks` reference, also removed by that change.

Sequencing: this change must run **after** `remove-monetization-go-free`, `parent-session-time-limit`, `accessories-shop-completion` and `unused-dependencies-cleanup`, each of which changes behaviour the plans describe. Correcting the plans first would document a state about to change again.
