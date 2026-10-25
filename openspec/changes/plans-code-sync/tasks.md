## 1. Prerequisites

- [x] 1.1 Confirm `remove-monetization-go-free` has landed
- [x] 1.2 Confirm `parent-session-time-limit` has been decided and implemented or removed
- [x] 1.3 Confirm `accessories-shop-completion` has landed
- [x] 1.4 Confirm `unused-dependencies-cleanup` has settled the code generation question

## 2. Correct CLAUDE.md

- [x] 2.1 Remove the claim that YooKassa lives on branch `feat/yookassa-payment`
- [x] 2.2 Correct the persistence section: leaderboards use Game Center, not Firestore; `lib/` contains no Firestore usage
- [x] 2.3 Remove the `build_runner` command and the `@riverpod` annotation claim
- [x] 2.4 Correct the state-management description to reflect hand-written providers
- [x] 2.5 Remove the subscription section

## 3. Rewrite ci-cd.md

- [x] 3.1 Replace `deploy-ios.yml` and `submit-review.yml` with the actual workflows
- [x] 3.2 Document `deploy-testflight.yml` (push to `main`, path-filtered)
- [x] 3.3 Document `release.yml` (tag `v*`)
- [x] 3.4 Document `monitor.yml` (daily cron, App Store review status)
- [x] 3.5 Document `ci.yml` from `ci-quality-gate`
- [x] 3.6 Correct the secrets table, removing `REVENUECAT_API_KEY`
- [x] 3.7 Remove the obsolete migration sequence section

## 4. Correct identifiers in the feature plans

- [x] 4.1 `progress-tracking.md`: replace the achievement list with the actual `AchievementId` values
- [x] 4.2 `leaderboards.md`: correct leaderboard IDs to `brainy_weekly_xp` and `brainy_best_time_{N}x{N}`
- [x] 4.3 `character-system.md`: correct SVG to PNG assets
- [x] 4.4 `character-system.md`: add `equippedCape` to the `CharacterData` field list
- [x] 4.5 `character-system.md`: describe the accessory shop as reachable
- [x] 4.6 `parent-panel.md`: describe the session time limit as implemented or remove it, per the decision made
- [x] 4.7 Remove premium annotations left in `game-modes.md`, `character-system.md`, `parent-panel.md`, `progress-tracking.md`

## 5. Remove dead references

- [x] 5.1 Confirm `docs/plans/features/subscription.md` is deleted
- [x] 5.2 Confirm the `brainy-tasks/TASK_10_1_yookassa.md` reference is gone from `subscription_service.dart`
- [x] 5.3 Grep all plans for `brainy-tasks` and remove any remaining reference

## 6. Verify

- [x] 6.1 Check that every file path referenced in the plans exists
- [x] 6.2 Check that every identifier named in the plans exists in the code
- [x] 6.3 Check that every git branch named in the plans exists
- [x] 6.4 Check that every workflow named in `ci-cd.md` exists with the trigger described
- [ ] 6.5 Consider adding an identifier-verification step to the `/review` command checklist
