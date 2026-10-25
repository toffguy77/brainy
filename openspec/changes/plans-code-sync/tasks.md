## 1. Prerequisites

- [x] 1.1 Confirm `remove-monetization-go-free` has landed — `subscription.md`, `subscription_service.dart`, `functions/` and `Products.storekit` are gone (`faf276b`, `9180bab`); no `premium`/`RevenueCat` text left in plans
- [x] 1.2 Confirm `parent-session-time-limit` has been decided and implemented or removed — removed by owner decision; no session-limit key in `AppConstants` and no mention in `parent-panel.md`
- [x] 1.3 Confirm `accessories-shop-completion` has landed — `/accessories` route, `DressedAvatar` glyph/`CapePainter` rendering (`64479a7`)
- [x] 1.4 Confirm `unused-dependencies-cleanup` has settled the code generation question — `pubspec.yaml` has no `build_runner`/generators; comment "Hive adapters are written manually"

## 2. Correct CLAUDE.md

- [x] 2.1 Remove the claim that YooKassa lives on branch `feat/yookassa-payment` — no `yookassa`/`feat/` in `CLAUDE.md` or plans; only `main` and `chore/finish-audit-changes` branches exist
- [x] 2.2 Correct the persistence section: leaderboards use Game Center, not Firestore; `lib/` contains no Firestore usage — `CLAUDE.md` "Firestore (cloud): not used by the app"
- [x] 2.3 Remove the `build_runner` command and the `@riverpod` annotation claim — absent from `CLAUDE.md`
- [x] 2.4 Correct the state-management description to reflect hand-written providers — "Providers are hand-written (no code generation)"
- [x] 2.5 Remove the subscription section — replaced by the "Platform" section (free, iOS only, Crashlytics only)

## 3. Rewrite ci-cd.md

- [x] 3.1 Replace `deploy-ios.yml` and `submit-review.yml` with the actual workflows — `ci-cd.md` documents exactly the four files in `.github/workflows/`
- [x] 3.2 Document `deploy-testflight.yml` (push to `main`, path-filtered) — paths match the workflow; `verify` → `deploy` with `needs`
- [x] 3.3 Document `release.yml` (tag `v*`) — including `verify` gate and the `release` lane reading version/build from `pubspec.yaml`
- [x] 3.4 Document `monitor.yml` (daily cron, App Store review status) — `0 9 * * *`, alert states, `issues: write`
- [x] 3.5 Document `ci.yml` from `ci-quality-gate` — ARB parity, Flutter 3.47.6, `--fatal-infos`, `--timeout 60s --coverage`, gitleaks 8.30.1, concurrency rule
- [x] 3.6 Correct the secrets table, removing `REVENUECAT_API_KEY` — six secrets, all referenced by the workflows; none other
- [x] 3.7 Remove the obsolete migration sequence section — absent

## 4. Correct identifiers in the feature plans

- [x] 4.1 `progress-tracking.md`: replace the achievement list with the actual `AchievementId` values — 10 rows equal `AchievementDef.idString` values and `assets/badges/*.png`
- [x] 4.2 `leaderboards.md`: correct leaderboard IDs to `brainy_weekly_xp` and `brainy_best_time_{N}x{N}` — matches `GameServicesService` helpers
- [x] 4.3 `character-system.md`: correct SVG to PNG assets — `assets/characters/*.png` via `characterAvatar()`
- [x] 4.4 `character-system.md`: add `equippedCape` to the `CharacterData` field list — fields 0–8 incl. `equippedCape`, typeId 2
- [x] 4.5 `character-system.md`: describe the accessory shop as reachable — button → `/accessories`; shop dresses the active character
- [x] 4.6 `parent-panel.md`: describe the session time limit as implemented or remove it, per the decision made — removed (decision: no limit)
- [x] 4.7 Remove premium annotations left in `game-modes.md`, `character-system.md`, `parent-panel.md`, `progress-tracking.md` — grep for `premium`/`Pro` finds nothing

## 5. Remove dead references

- [x] 5.1 Confirm `docs/plans/features/subscription.md` is deleted
- [x] 5.2 Confirm the `brainy-tasks/TASK_10_1_yookassa.md` reference is gone from `subscription_service.dart` — the whole file was deleted
- [x] 5.3 Grep all plans for `brainy-tasks` and remove any remaining reference — no matches in `docs/plans/` or `CLAUDE.md`

## 6. Verify

- [x] 6.1 Check that every file path referenced in the plans exists — scripted check over all backticked paths in `docs/plans/**` and `CLAUDE.md`: all resolve
- [x] 6.2 Check that every identifier named in the plans exists in the code — scripted grep of every backticked identifier in feature plans and `CLAUDE.md`: all found (only `gen_l10n`, the Flutter tool name, is not a code symbol)
- [x] 6.3 Check that every git branch named in the plans exists — plans name no branches
- [x] 6.4 Check that every workflow named in `ci-cd.md` exists with the trigger described — compared against all four workflow files
- [x] 6.5 Consider adding an identifier-verification step to the `/review` command checklist — added in `.claude/commands/review.md`: "Every identifier, path, constant and key a touched plan names exists in code (grep each one)" (`faf276b`)

## 7. Re-audit after f0e1ec8..1e1e279 (2026-10-25)

- [x] 7.1 Re-check every plan in `docs/plans/features/` and `docs/plans/ops/` plus `CLAUDE.md` claim by claim against the code
- [x] 7.2 Fix remaining drift in the plans (picker sizes per mode, character-screen preview, achievement dates, level label, onboarding navigation and page count, plural coverage, screenshot sizes, deliver lanes, player-name source, ARB location in `CLAUDE.md`)
- [x] 7.3 Record behaviour that can only be fixed in code as findings for follow-up (see `design.md`, "Outcome")
