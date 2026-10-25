## 1. Make the decision

- [x] 1.1 Owner decides whether Android is a supported target — decided 2026-08-01: iOS only
- [x] 1.2 Record the decision and its date in `CLAUDE.md` — `CLAUDE.md:22-26` (`## Platform`, "iOS only (decision 2026-08-01)"), added in faf276b

## 2. If Android is NOT supported

- [x] 2.1 Remove the "Android CI пока не настроен" line from `ci-cd.md` — replaced by an iOS-only statement, `docs/plans/ops/ci-cd.md:12-13`
- [x] 2.2 Remove Google Play Games references from `leaderboards.md`; describe Game Center concretely — `docs/plans/features/leaderboards.md:10` describes Game Center and mentions Play Games only to say the package supports it but the project is iOS only
- [x] 2.3 State in `CLAUDE.md` that `brainy-app/android/` is unbuilt Flutter scaffolding — `CLAUDE.md:24-25`
- [x] 2.4 Remove `brainy-app/android/**` from the path filter in `deploy-testflight.yml` — `.github/workflows/deploy-testflight.yml:7-13` lists lib, pubspec.yaml/lock, ios, l10n, assets only (removed in f0e1ec8); `grep -rn android .github/` finds nothing
- [x] 2.5 Confirm no plan describes Android work as outstanding — `grep -rni android docs/plans` hits only `ci-cd.md:12` and `leaderboards.md:10`, both say iOS only

## 3. If Android IS supported

- [~] 3.1 Create a separate change scoping the Android release pipeline — dropped: owner decided iOS only
- [~] 3.2 Scope: upload keystore and signing configuration — dropped: iOS only
- [~] 3.3 Scope: Play Console app setup — dropped: iOS only
- [~] 3.4 Scope: an Android build and release workflow — dropped: iOS only
- [~] 3.5 Scope: Google Play Games leaderboard configuration matching the seven Game Center leaderboards — dropped: iOS only
- [~] 3.6 Scope: device testing coverage — dropped: iOS only
- [~] 3.7 Correct the path filter so Android changes trigger an Android build, not an iOS one — dropped: iOS only; filter instead excludes Android (2.4)
- [~] 3.8 Update `ci-cd.md` and `leaderboards.md` to describe the planned pipeline with a named change — dropped: iOS only; plans state no pipeline is planned (2.1, 2.2)

## 4. Verify

- [x] 4.1 Confirm no "not yet configured" statement remains without a named change — `grep -rniE "not yet|not configured|пока не|ещё не|еще не|не настроен|TODO|TBD" docs/plans CLAUDE.md` finds only `leaderboards.md:53` ("Пока нет реальных данных…"), which describes runtime fallback behaviour, not missing configuration. The old line survives only as a quotation in the historical audit record `docs/specs/2026-08-01-audit-backlog.md:261`
- [x] 4.2 Confirm an Android-only change no longer triggers an iOS TestFlight build — by inspection of the `push.paths` filter (`deploy-testflight.yml:7-13`); `release.yml:3-6` triggers only on `v*` tags
- [x] 4.3 Coordinate the resulting plan edits with `plans-code-sync` — the `ci-cd.md`/`leaderboards.md` edits landed directly in this branch; `grep -rni android openspec/changes/plans-code-sync/` finds nothing, so there is no overlapping or conflicting task
