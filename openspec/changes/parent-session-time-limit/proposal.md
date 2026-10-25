## Decision (2026-08-01)

Owner decision: **remove the control entirely.** There is no play-time limit; children play as long as they like. The per-session versus per-day question is moot. This change is therefore a removal, not an implementation — tasks in group 1.4 apply and groups 2 through 5 are dropped.

## Why

The parent settings screen offers a "Maximum session time" control with options of 5, 10, 15 minutes or unlimited. A parent can select a value; it is written to Hive under `parentMaxSessionTimeKey` and read back into `ParentSettings.maxSessionTimeMinutes`. Nothing else reads it. Grepping the codebase finds references only inside `parent_provider.dart` — `game_screen.dart` and `game_provider.dart` never consult it.

The setting is decorative. A parent who limits their child to 5 minutes gets no limit at all, and has no way to discover this. `docs/plans/features/parent-panel.md` documents it as a working control, so the documentation actively confirms the false impression.

For a product aimed at children with a parent-control surface, a screen-time limit that silently does nothing is the worst kind of defect: it is a promise to a parent that the app does not keep.

## What Changes

- The session time limit is enforced during gameplay: when a session reaches the configured limit, it ends.
- The child is told why the session ended, in age-appropriate language, rather than being dropped without explanation.
- Progress earned up to that point is preserved — the session is completed, not discarded.
- "Unlimited" (0) continues to mean no limit.
- The behaviour is covered by tests, so a future refactor cannot silently disconnect it again.

Alternatively, if the product decision is that the limit is not wanted, the control and its Hive key are removed and the plan is corrected. Shipping the current state — a control that lies — is not an option.

## Capabilities

### New Capabilities
- `session-time-limit`: how a parent-configured play-time limit constrains a game session.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for parental controls. -->

## Impact

- `lib/features/game/providers/game_provider.dart` — the timer gains a limit check.
- `lib/features/game/screens/game_screen.dart` — reads `parentProvider` and handles the limit-reached transition.
- `lib/features/game/screens/result_screen.dart` — a variant explaining the session ended on the limit.
- `l10n/app_ru.arb`, `l10n/app_en.arb` — new strings for the limit message.
- `test/game/` — new coverage for limit reached, limit not reached, and unlimited.
- `docs/plans/features/parent-panel.md` — describes real behaviour.

Open question for the owner: does the limit cap a single session, or total play time per day? The setting is named "maximum session time" and the options are 5/10/15 minutes, which reads as per-session — but a child can immediately start another session, which makes a per-session cap weak as a screen-time control. This must be decided before implementation; see `design.md`.
