## 1. Make the decision

- [x] 1.1 Owner decides whether Android is a supported target
- [ ] 1.2 Record the decision and its date in `CLAUDE.md`

## 2. If Android is NOT supported

- [x] 2.1 Remove the "Android CI пока не настроен" line from `ci-cd.md`
- [x] 2.2 Remove Google Play Games references from `leaderboards.md`; describe Game Center concretely
- [ ] 2.3 State in `CLAUDE.md` that `brainy-app/android/` is unbuilt Flutter scaffolding
- [x] 2.4 Remove `brainy-app/android/**` from the path filter in `deploy-testflight.yml`
- [x] 2.5 Confirm no plan describes Android work as outstanding

## 3. If Android IS supported

- [ ] 3.1 Create a separate change scoping the Android release pipeline
- [ ] 3.2 Scope: upload keystore and signing configuration
- [ ] 3.3 Scope: Play Console app setup
- [ ] 3.4 Scope: an Android build and release workflow
- [ ] 3.5 Scope: Google Play Games leaderboard configuration matching the seven Game Center leaderboards
- [ ] 3.6 Scope: device testing coverage
- [ ] 3.7 Correct the path filter so Android changes trigger an Android build, not an iOS one
- [ ] 3.8 Update `ci-cd.md` and `leaderboards.md` to describe the planned pipeline with a named change

## 4. Verify

- [ ] 4.1 Confirm no "not yet configured" statement remains without a named change
- [x] 4.2 Confirm an Android-only change no longer triggers an iOS TestFlight build
- [ ] 4.3 Coordinate the resulting plan edits with `plans-code-sync`
