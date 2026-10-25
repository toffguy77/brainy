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

## Open Questions

- Should `ci-cd.md` be updated by `ci-quality-gate` when it adds `ci.yml`, rather than here?
- Are there plans for areas with no documentation at all — the game loop, adaptive difficulty — worth adding once the existing ones are true?
- Should the `/review` command's checklist gain an explicit "verify identifiers named in touched plans" step?
