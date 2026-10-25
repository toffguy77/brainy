## Context

`ParentSettings.maxSessionTimeMinutes` is loaded from Hive (`parentMaxSessionTimeKey`, default 0 meaning unlimited) and written by `setMaxSessionTime`. Both live in `parent_provider.dart`. A grep for the field and the key across `lib/` returns matches only in that file — no consumer exists.

By contrast, the sibling settings work: `gridSizeMode` and `fixedGridSize` are read by `home_screen.dart`, and the notification settings are read by `game_screen.dart` when rescheduling. The session limit is the odd one out, which suggests it was added to the settings UI and its wiring was never finished.

A single Schulte session lasts seconds to a couple of minutes — a 5x5 target time is 25 seconds, a 9x9 is 81. A 5-minute per-session cap would therefore almost never trigger. That mismatch between the option values and the natural session length is the strongest evidence that the intended meaning was daily play time, not per-session duration.

## Goals / Non-Goals

**Goals:**
- The control does what a parent reasonably believes it does.
- The child experiences the limit as a clear, kind boundary, not a malfunction.
- No progress is lost when the limit ends a session.

**Non-Goals:**
- A full screen-time regime with schedules, weekday rules or bedtime windows. Out of proportion for this app.
- Enforcing the limit against clock tampering. A child who changes the device clock can defeat any local limit; solving that needs a server and is not worth it here.
- Blocking access to the rest of the app. The limit is about play sessions, not about the character or progress screens.

## Decisions

**Resolve the per-session versus per-day question before writing code.** This is the crux of the change and cannot be settled by looking at the code, because the code has no behaviour. The evidence points to per-day: 5/10/15-minute options against 25-to-81-second target times mean a per-session cap would essentially never fire, making the feature pointless. The onboarding also asks "how often to train" with 5/10/15-minute options and stores `dailyGoalMinutes` — the same numbers, explicitly framed as a daily budget. The two settings are probably the same concept, entered twice.

Recommendation: implement as a **daily** budget, accumulating across sessions, and rename the setting accordingly. Requires an owner decision; recorded as an open question rather than assumed.

*Alternative considered:* implement literally per-session, matching the current label. Cheapest and matches the string, but ships a control that almost never activates — a subtler version of the current defect.

**End the session gracefully, do not kill the screen.** Route through the normal session-completion path with a flag, so coins, XP and session recording all reuse tested code. Abruptly popping the route would bypass persistence and lose the child's progress.

**Do not write a personal record for a partial session.** A record is a completion time; a session cut short has none. Writing one would corrupt the records the parent dashboard and Game Center leaderboards display.

**Exclude the countdown from elapsed time.** Three seconds of a five-minute budget is small, but a limit that counts waiting is wrong on its face and trivially avoidable.

**Do not terminate a running session when the setting changes.** A parent adjusting settings should not yank a game out from under a child mid-play. Apply from the next session.

**If the owner decides the limit is unwanted, remove it.** Deleting the control, the Hive key and the plan section is a legitimate resolution and better than leaving a decorative control. What is not acceptable is shipping it as it stands.

## Risks / Trade-offs

- **A daily budget needs day-boundary handling** → Reuse the streak logic's existing notion of "today", so both features agree on when a day starts. Do not invent a second definition.
- **A child mid-table when the budget expires loses their attempt** → Mitigated by preserving earned progress and by wording the message kindly. Consider allowing the current table to finish if it is nearly done, though that complicates the rule; deferred.
- **Two overlapping settings confuse parents** → `dailyGoalMinutes` (a goal, from onboarding) and `maxSessionTimeMinutes` (a limit, from parent settings) may need merging, or clearly distinct labels. Flagged as an open question.
- **Clock tampering defeats the limit** → Accepted; out of scope.

## Migration Plan

1. Owner decides: per-session, per-day, or remove.
2. If keeping: implement enforcement in the game timer, route the end through normal completion, add the localized message.
3. Add tests for limit reached, limit not reached, and unlimited.
4. Manually verify with a short limit that the message appears and progress is kept.
5. Update `parent-panel.md` to describe the real behaviour.

**Rollback:** revert the enforcement; the setting returns to being inert, which is today's state. No user data is affected either way.

## Open Questions

- **Per-session or per-day?** The central decision. Recommendation above is per-day.
- Should `maxSessionTimeMinutes` and `dailyGoalMinutes` be merged into one concept?
- Should a nearly finished table be allowed to complete when the budget expires?
- Should the parent dashboard show how much of the budget was used today?
