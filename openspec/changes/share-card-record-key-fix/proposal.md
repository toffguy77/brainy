## Why

`ShareCard.showAndShare` reads `records[5]` from a `Map<String, int>` whose keys look like `"classic_5"`. Indexing a string-keyed map with an integer always yields `null`, so the social share card — the app's only organic growth surface — has never shown a 5x5 best time. It renders an empty slot to every parent who taps Share.

The defect was introduced by the records-key migration (`"5"` → `"classic_5"`) which updated `RecordsNotifier` but missed this consumer. The analyzer flagged it as `collection_methods_unrelated_type`, an info — visible for as long as it has existed, and never read, because no CI job ran the analyzer.

## What Changes

- `ShareCard` looks the record up with the same `recordKey(mode, gridSize)` helper the rest of the app uses, instead of an integer literal.
- A widget test covers the card, so the value it renders is verified rather than assumed.
- The last remaining `flutter analyze` info is cleared, unblocking `--fatal-infos` in the CI gate.

## Capabilities

### New Capabilities
- `progress-sharing`: what the shareable progress card contains and how it derives its values.

### Modified Capabilities
<!-- None: openspec/specs/ has no existing capability for sharing. -->

## Impact

- `brainy-app/lib/features/parent/widgets/share_card.dart` — the record lookup.
- `brainy-app/test/parent/share_card_test.dart` — new.
- `flutter analyze` — final info cleared; `ci-quality-gate` can make `--fatal-infos` required.

This is the one change in the backlog that fixes user-visible behaviour rather than tooling or structure.
