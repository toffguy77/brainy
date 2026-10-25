## 1. Fix the lookup

- [x] 1.1 Replace `records[5]` with `records[recordKey('classic', 5)]` in `share_card.dart`
- [x] 1.2 Grep the codebase for other integer indexing of the records map and fix any found
- [x] 1.3 Confirm `flutter analyze` no longer reports `collection_methods_unrelated_type`

## 2. Cover it with a test

- [x] 2.1 Create `test/parent/share_card_test.dart`
- [x] 2.2 Test the rendered 5x5 value against a records box seeded with `classic_5`
- [x] 2.3 Test the empty state against an empty records box
- [x] 2.4 Test that a `gorbov_5` record alone still yields the empty state
- [x] 2.5 Confirm the test fails if the lookup is reverted to the integer key

## 3. Verify visually

- [ ] 3.1 Play a 5x5 classic game to set a record, open the parent dashboard, tap Share
- [ ] 3.2 Confirm the real value renders and the layout accommodates it
- [ ] 3.3 Confirm the empty state still renders correctly for a fresh install

## 4. Unblock the gate

- [x] 4.1 Confirm `flutter analyze --fatal-infos` exits 0 once `revenuecat-removal-cleanup` has also landed
