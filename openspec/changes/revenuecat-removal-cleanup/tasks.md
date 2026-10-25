## 1. Remove the dead setup snippet

- [x] 1.1 Delete `brainy-app/docs/setup/revenue_cat/` (`initialize.dart`, `credentials.md`, `prompt.md`)
- [x] 1.2 Confirm `flutter analyze` no longer reports the 3 errors and 1 info from `initialize.dart`

## 2. Clean the integration test

- [x] 2.1 Remove the `package:purchases_flutter/purchases_flutter.dart` import from `integration_test/screenshot_test.dart`
- [x] 2.2 Remove the `Purchases.configure(PurchasesConfiguration(AppConstants.revenueCatApiKey))` block from `setUpAll`
- [x] 2.3 Update the stale comment about avoiding a RevenueCat crash
- [x] 2.4 Confirm the analyzer reports no issues for this file

## 3. Clean the constants test

- [x] 3.1 Remove the `RevenueCat` group from `test/constants/app_constants_test.dart`
- [x] 3.2 Note that YooKassa constants remain covered by `subscription_constants_test.dart`
- [ ] 3.3 Run `flutter test test/constants/app_constants_test.dart` and confirm it loads and passes

## 4. Remove the build-time secret plumbing

- [ ] 4.1 Grep `.github/workflows/` and `brainy-app/ios/fastlane/Fastfile` for `REVENUECAT_API_KEY`
- [ ] 4.2 Remove the `--dart-define` for the RevenueCat key from the `deploy_testflight` lane
- [ ] 4.3 Delete the `REVENUECAT_API_KEY` GitHub repository secret
- [ ] 4.4 Confirm a TestFlight build still succeeds without it

## 5. Verify

- [x] 5.1 `flutter analyze` reports no issues
- [ ] 5.2 `flutter analyze --fatal-infos` exits 0 (requires `share-card-record-key-fix` to have landed)
- [ ] 5.3 Grep the package for `purchases_flutter`, `Purchases`, `revenueCatApiKey`, `revenueCatEntitlement`, `productId` and confirm no functional matches
- [ ] 5.4 Confirm no test file fails at the `loading` stage in a full run
