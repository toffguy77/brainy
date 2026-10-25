## Outcome (2026-10-25)

**Decision:** implemented as designed — this change ran last, after the behaviour-changing
changes landed in `f0e1ec8..1e1e279`. Corrections were made by reading the code (enums, constants,
workflow files, metadata files), not from memory.

**Re-audit.** After those commits every plan file and `CLAUDE.md` was checked claim by claim. The
remaining drift that was fixed in the docs:

| File | Was | Now (per code) |
|------|-----|----------------|
| `game-modes.md` | home picker shows all `pickerGridSizes` | picker shows `gridSizesForMode(mode)`; Gorbov colour/completion moved under Gorbov, named `AppColors.gorbovRed` |
| `character-system.md` | preview of the *active* character; [Select] on cards | preview follows the paged card; tap selects; action button below; shop always dresses the active character |
| `progress-tracking.md` | "Lv.N"; achievements shown "with date"; popup; stars in `gridStatsProvider` | «Уровень N» (`levelLabel`); no date stored; SnackBar on result screen; stars computed in `GridDetailScreen` |
| `onboarding.md` | swipe between pages; 7 page files; answers saved per page | swipe disabled; 6 page files; age card auto-advances; Hive written in `completeOnboarding()` |
| `leaderboards.md` | `GameServicesService.getPlayerName()` | `GameServicesService.playerName`, filled in `signIn()` |
| `parent-panel.md` | — | "this week" = last 7 days; change-PIN flow; version label |
| `notifications.md` | — | daily repeat with fixed text; no reminder after a played day until the next reschedule |
| `localization.md` | all counted words use ICU plural | only `parentShareCardTitle` does; others listed as known debt |
| `appstore-metadata.md` | 6.5" 1284x2778 | 1242x2688; iPad 2048x2732; category/rating live in App Store Connect; `deliver` in `submit_review` and `release` |
| `ci-cd.md` | `release` lane summary | adds `automatic_release` and version/build from `pubspec.yaml` |
| `CLAUDE.md` | ARB files under `lib/l10n/` | ARB in `brainy-app/l10n/`, generated code in `lib/l10n/`; `GameModes` in constants |

**Code findings** (cannot be fixed by editing prose; left for a follow-up change):

- `lib/features/game/screens/result_screen.dart:53` — when `extra` is missing it calls
  `context.go('/game')`, which starts a default classic 5x5 game; `/home` is the likely intent.
- `lib/features/progress/screens/progress_screen.dart:21,56,314` — `locale` is computed and passed
  as a required field but never read.
- `l10n/app_ru.arb` `streakDays`, `progressGoalStreak`, `notificationStreak1..7`,
  `accessoriesNotEnoughCoinsMessage` — no ICU plural, so Russian reads «Стрик 3 дней».
- `lib/features/character/screens/character_screen.dart:88,156` — the accessories button is gated
  on the *paged* character being unlocked, but `/accessories` edits the *active* character.
- `lib/shared/services/notification_service.dart` (`rescheduleFromStorage`) — playing today cancels
  the reminder and nothing is scheduled for tomorrow until the app runs again; the repeating
  notification also keeps the streak count it was scheduled with.
- `brainy-app/pubspec.yaml` `flutter_launcher_icons`/`flutter_native_splash` still set
  `android: true` although the project is iOS only.

## Context

`docs/plans/` was generated in `2f56a89` from three sources: the archived `brainy-tasks/` specifications, planning notes from earlier sessions, and the code itself. The design document for the agent system (`docs/specs/2026-03-20-agent-system-design.md`) states the governing rule plainly: "Планы = факт — описывают как приложение работает сейчас, а не как планировалось."

Ten claims violate that rule. Their distribution is informative. Some were true at generation time and drifted as the code moved on — the CI workflows were renamed and re-triggered in `ac8eb7d` and `0903083`, and `ci-cd.md` still documents the previous generation. Others were never true: the plans were generated partly from *task specifications*, which describe intent, and intent leaked in as fact. The achievement list is the clearest case — `triple_record`, `fast_3x3`, `collector_10` and `no_mistakes` read like a plan for ten achievements, while the code shipped a different four.

The `feat/yookassa-payment` branch reference is the most actively harmful: it appears in both `CLAUDE.md` and `subscription.md` and in a code comment, and sends anyone looking for the payment implementation to a branch that does not exist, when the code is on `main`.

## Goals / Non-Goals

**Goals:**
- Every claim in the plans is true.
- Plans that describe removed features are gone.
- The rule against drift is stated in a way that can actually be applied.

**Non-Goals:**
- Rewriting the plans' structure or format. YAML frontmatter with `title` and `tags` works, and the tag-based grep lookup is used by the `/feature` and `/review` commands.
- Expanding coverage to undocumented areas. Fixing what is wrong comes before adding more.
- Automating drift detection. Prose claims about behaviour cannot be checked mechanically; pretending otherwise would add a check that passes while the plans are wrong.

## Decisions

**Run this change last.** Four other changes rewrite behaviour the plans describe: `remove-monetization-go-free` (deletes `subscription.md` and premium annotations across four plans), `parent-session-time-limit` (decides whether the limit exists), `accessories-shop-completion` (makes the shop real), `unused-dependencies-cleanup` (settles the codegen claim). Correcting the plans before those land would document a state about to change, and would need doing twice.

**Rewrite `ci-cd.md` rather than patch it.** It documents workflow names, triggers and a migration sequence, all superseded. Every section is wrong in the same direction. A rewrite against the three current workflows is less work and less error-prone than reconciling a document to a generation of infrastructure that no longer exists.

**Delete `subscription.md`, do not rewrite it.** Handled by `remove-monetization-go-free`; recorded here so the deletion is a decision rather than an omission.

**Correct the achievement list from the enum, not from memory.** `AchievementId` is the authority. The same applies to leaderboard IDs (`game_services_service.dart`), model fields (`models/character.dart`) and workflow names (`.github/workflows/`). Each correction is made by reading the code, which is also what the verification scenarios require.

**State the anti-drift rule as a review obligation, not an automated check.** The genuinely useful check — do the identifiers named in this plan exist in the code — is a spot-check a reviewer performs. Claiming automation that cannot exist would be a new false statement in a change about removing false statements.

**Note the session-time-limit dependency explicitly.** Item 10 cannot be fixed here in isolation: whether `parent-panel.md` should describe a working limit depends on the decision made in `parent-session-time-limit`. This change records the outcome of that decision rather than pre-empting it.

## Risks / Trade-offs

- **Corrections drift again within months** → The real mitigation is the process already in `CLAUDE.md` — update plans in the same commit as the behaviour change. This change makes the baseline true so the process has something correct to preserve.
- **A rewritten `ci-cd.md` is wrong the next time the workflows change** → Accepted; `ci-quality-gate` adds a fourth workflow, so `ci-cd.md` should be written after it lands or updated as part of it.
- **Ten corrections is a large documentation diff with little review appetite** → Group by document so each is reviewable independently.
- **Correcting a plan may reveal the code is wrong, not the plan** → That is a valid outcome. Item 10 is exactly this case, which is why it is routed to a separate change rather than resolved by editing prose.

## Migration Plan

1. Wait for `remove-monetization-go-free`, `parent-session-time-limit`, `accessories-shop-completion` and `unused-dependencies-cleanup`.
2. Correct `CLAUDE.md`: branch reference, Firestore claim, build_runner claim.
3. Rewrite `ci-cd.md` against the current workflows, including the new `ci.yml`.
4. Correct identifiers in `progress-tracking.md`, `leaderboards.md`, `character-system.md`.
5. Update `parent-panel.md` to reflect whatever was decided about the session limit.
6. Verify every referenced file path and identifier exists.

**Rollback:** documentation-only; ordinary reverts with no runtime impact.

## Open Questions (answered)

- *Should `ci-cd.md` be updated by `ci-quality-gate` when it adds `ci.yml`, rather than here?* —
  Both: `ci-quality-gate` updated it in `9180bab`; this change re-verified it against the four
  workflow files and the Fastfile.
- *Are there plans for undocumented areas — the game loop, adaptive difficulty?* — Covered without
  new files: the tap logic, pause, session completion and adaptive difficulty are in
  `game-modes.md`; the daily goal is in `onboarding.md`, `parent-panel.md` and `progress-tracking.md`.
- *Should `/review` gain an explicit "verify identifiers named in touched plans" step?* — Yes; added to
  `.claude/commands/review.md` in `faf276b`, together with unreferenced-file and
  decorative-control checks.
