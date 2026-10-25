## 1. Prerequisites

- [x] 1.1 Confirm `remove-monetization-go-free` has landed
- [x] 1.2 Re-run the import audit for every dependency: grep `package:<name>/` across `lib/`, `test/`, `integration_test/`
- [x] 1.3 Record the current baseline: `flutter analyze` clean, `flutter test` green, iOS build succeeds

## 2. Remove the clearly unused packages

- [x] 2.1 Remove `cloud_functions` from `pubspec.yaml`
- [x] 2.2 Remove `shared_preferences`
- [x] 2.3 Remove `collection`
- [x] 2.4 Run `flutter pub get`, `flutter analyze`, `flutter test`
- [x] 2.5 Run `flutter build ios --no-codesign` to catch platform-level breakage

## 3. Remove the unused code generation toolchain

- [x] 3.1 Confirm no `@riverpod` annotation and no `.g.dart` file exists
- [x] 3.2 Remove `riverpod_annotation`, `riverpod_generator` and `build_runner`
- [x] 3.3 Remove the `build_runner` command from the Commands section of `CLAUDE.md`
- [x] 3.4 Correct the state-management section of `CLAUDE.md` to describe hand-written providers
- [x] 3.5 Verify analyze, test and build

## 4. Decide on device identity

- [x] 4.1 Determine whether anything still requires a stable device identifier now that payments are gone
- [x] 4.2 If not: delete `device_id_service.dart` and `device_id_service_test.dart`
- [x] 4.3 If not: remove `flutter_secure_storage` and `device_info_plus`
- [ ] 4.4 If retaining: record the reason in `design.md`
- [x] 4.5 Verify analyze, test and build

## 5. Confirm the outcome

- [x] 5.1 Re-run the full import audit and confirm every remaining dependency has at least one import
- [x] 5.2 Confirm `CLAUDE.md` describes only tooling the project actually uses
- [ ] 5.3 Note whether dependabot volume drops as expected
- [ ] 5.4 Decide whether to open a follow-up change for the 105 outdated packages
