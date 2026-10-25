## Decision and Outcome

**Decision (owner, 2026-08-01):** remove the "Maximum session time" control. There is no play-time limit.

**Outcome:** removed in `f0e1ec8`. Verified absent on 2026-10-25 (see `tasks.md` 1.4). Every remaining parent-settings control was verified to have an observable effect (see `tasks.md` 6.3).

## Context

Before removal, `ParentSettings.maxSessionTimeMinutes` was loaded from Hive (`parentMaxSessionTimeKey`, default 0 meaning unlimited) and written by `setMaxSessionTime`. Both lived only in `parent_provider.dart`, and no game code read the value. The sibling settings did have consumers: grid size mode was read by the home screen, and the notification settings by the reminder scheduler. The session limit was a UI control whose wiring was never built.

## Rationale for removal over enforcement

- **The options did not fit the game.** A table takes about 25 seconds (5x5) to 81 seconds (9x9) at target pace. A 5-15 minute per-session cap would almost never trigger.
- **A daily budget would have been a real feature.** It needs a day-boundary definition, a child-facing "time is up" message, partial-session rules (no record, keep earned coins and XP) and new tests. That is out of proportion for the product.
- **Product position.** The owner chose not to limit play.
- **An honest absence beats a dishonest presence.** Removing the control fixes the defect, which was a parental promise the app did not keep, at the lowest cost.

## Decisions

- **Delete code, constant, strings and plan text together** (`f0e1ec8`), so no layer advertises the setting.
- **Leave the stored orphan value in place.** The user box may still hold `'parentMaxSessionTime' → int` on upgraded devices. Nothing reads the key. It is a primitive in an untyped box, so no adapter depends on it. Nothing iterates the box. A cleanup migration would add code and risk for no effect the user could see.
- **Keep the honesty invariant as a requirement.** Every control on the parent settings screen must change observable behaviour. This is now the substance of `specs/session-time-limit/spec.md`.
- **`dailyGoalMinutes` stays separate and is now used.** The old open question about merging it with the limit is resolved by the removal. The daily goal is a goal, not a cap: it can be edited in parent settings and drives the home "Today: X of N min" bar and the dashboard.

## Risks / Trade-offs

- **Parents who relied on the label lose nothing.** It never did anything.
- **The invariant has no direct test.** It holds by review today, not by a test. There is no widget test for `parent_settings_screen.dart` or for the notification-denial path of `ParentNotifier.setNotificationsEnabled`. Coverage exists only for the downstream consumers (home screen and reminder plan tests). Noted as a gap; not fixed by this change.

## Migration Plan

None required. The stored orphan value is inert. Rollback would mean re-adding the control, which the owner decision forbids.

## Historical analysis (superseded, kept for the record)

Before the decision, this document recommended enforcing the limit as a **daily** budget, based on the mismatch between session length and the option values. It also suggested merging the limit with onboarding's `dailyGoalMinutes`, ending a limited session through the normal completion path with no personal record, excluding the countdown from elapsed time, and never cutting off a session already in progress. All of this is moot after the removal decision, and none of it was implemented.
