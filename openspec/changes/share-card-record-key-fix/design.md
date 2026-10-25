## Context

Records were originally keyed by grid size alone (`"5"`). When Gorbov-Schulte mode arrived, the key format became `"{mode}_{gridSize}"` and `RecordsNotifier` gained a `recordKey(mode, gridSize)` helper plus a one-time migration for legacy keys. Every consumer was updated except `ShareCard`, which still does:

```dart
best5x5: records[5],   // records is Map<String, int>
```

Dart's `Map.operator []` accepts `Object?`, so this compiles. It returns `null` for every user, always. The card has therefore never shown a 5x5 result since Gorbov mode shipped.

The analyzer does flag it — `collection_methods_unrelated_type` at `share_card.dart:39` — but at info severity, and nothing has ever run the analyzer in CI.

This is a small fix with an outsized lesson: the type system permitted a lookup that could not succeed, the analyzer noticed, and the finding sat unread. It is the concrete justification for `--fatal-infos` in `ci-quality-gate`.

## Goals / Non-Goals

**Goals:**
- The card shows the real record.
- The lookup uses the canonical helper, so the next key-format change updates it too.
- A test covers the card so the failure mode cannot silently return.

**Non-Goals:**
- Redesigning the card. Its layout and content are fine; only the lookup is wrong.
- Making the card show Gorbov records or other grid sizes. Plausible improvements, but scope creep on a bug fix; the plan describes a classic-5x5 card and that is what it should be.
- Auditing every other map lookup in the codebase. `flutter analyze --fatal-infos` will surface any equivalent case once the gate exists.

## Decisions

**Use `recordKey('classic', 5)` rather than the literal `'classic_5'`.** The helper is the single definition of the format. A literal would work today and break at the next migration in exactly the same way this bug arose.

**Test the widget, not just the lookup.** A pure-function test of `recordKey` would pass today and would have passed while this bug was live — the defect was in the caller. The test must exercise the card with a seeded box and assert the rendered value.

**Treat the empty state as a first-class case.** `best5x5` is nullable and, because of this bug, the null path is the only one ever exercised in production. It must keep working after the fix, so it gets its own scenario.

**Land this before making `--fatal-infos` required.** It is the last analyzer finding after `revenuecat-removal-cleanup`. Sequencing recorded in `ci-quality-gate`.

## Risks / Trade-offs

- **The card now renders a value where it always rendered blank** → That is the fix. Worth a visual check that the layout accommodates a real number, since it has only ever been exercised empty.
- **Widget-testing a `ScreenshotController`-based card is awkward** → Test the `ShareCard` widget's rendering directly with a seeded provider scope rather than driving `showAndShare`, which touches `path_provider` and `share_plus`.
- **Other stale record lookups may exist** → Grep as part of this change; the CI gate catches future ones.

## Migration Plan

1. Change the lookup to `records[recordKey('classic', 5)]`.
2. Grep for other integer indexing of the records map.
3. Add `test/parent/share_card_test.dart` covering a seeded record and the empty state.
4. Confirm `flutter analyze` is clean.
5. Visually verify the card with a real record present.

**Rollback:** trivial revert. No data or user state involved.

## Open Questions

- Should the card show the best across both modes, or gain a Gorbov line? A product question, deliberately deferred.
- Is the card still the right growth surface at all, given it is reached only through the PIN-protected parent dashboard?
