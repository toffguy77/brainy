# free-access Specification

## Purpose
TBD - created by archiving change remove-monetization-go-free. Update Purpose after archive.

## Requirements

### Requirement: Every game mode and every size it supports is available to all users

The app SHALL NOT gate any grid size or game mode behind a purchase or unlock step. All four modes SHALL be playable by every user on every size the mode supports: classic on 3, 4, 5, 6, 7 and 9; reverse on 3, 4, 5, 6, 7 and 9; Gorbov-Schulte on 5, 6, 7 and 9; letters on 3, 4 and 5 (bounded by the shortest supported alphabet).

#### Scenario: Large grid sizes are playable

- **WHEN** a user selects grid size 6, 7 or 9 in classic, reverse or Gorbov-Schulte mode on the home screen
- **THEN** no lock icon is shown, no bottom sheet appears, and tapping Play starts the game

#### Scenario: Every mode is selectable

- **WHEN** a user selects classic, reverse, letters or Gorbov-Schulte on the home screen
- **THEN** the mode switches and no upsell is shown

#### Scenario: The size picker offers only sizes the mode supports

- **WHEN** a mode is selected
- **THEN** the grid picker offers exactly that mode's sizes (letters 3-5, Gorbov-Schulte 5-9, classic and reverse 3-9)

#### Scenario: A size the mode does not support is clamped, not crashed

- **WHEN** the selected or parent-fixed grid size is outside the current mode's range (for example a parent-fixed 9x9 while letters is selected)
- **THEN** the home screen shows and starts the nearest supported size (5x5 for letters) and the app does not throw

#### Scenario: Navigating directly to a formerly-gated combination starts the game

- **WHEN** `/game?size=9&mode=gorbov` is opened directly
- **THEN** the game screen starts the countdown and does not redirect

### Requirement: Every character and accessory is obtainable without payment

Characters SHALL be unlocked by in-game achievement only and accessories by in-game coins only. No character or accessory SHALL require a purchase, and the unlock type set SHALL contain no purchase-based type.

#### Scenario: Pixel unlocks on a 14-day streak

- **WHEN** a user inspects the Pixel character card
- **THEN** it shows the condition "14-day streak" ("Стрик 14 дней" in Russian), not a payment requirement

#### Scenario: Pixel is granted when the streak is reached

- **WHEN** a session completes and the user's longest streak is at least 14 days
- **THEN** Pixel becomes unlocked without any further action

#### Scenario: Formerly-premium accessories are purchasable with coins

- **WHEN** a user views the Electricity effect or any other formerly-premium accessory in the shop
- **THEN** it shows only its coin price and is purchasable once the user has enough coins

### Requirement: Parent dashboard and detailed statistics are available to all users

The parent dashboard and the per-grid-size detail screen SHALL render their full content for every user, for every game mode.

#### Scenario: Dashboard renders after PIN entry

- **WHEN** a parent enters the correct PIN and reaches `/parent/dashboard`
- **THEN** the full dashboard renders with the weekly card, progress chart, best results and recent sessions
- **AND** no upsell screen is shown

#### Scenario: Best-result chips are never marked locked

- **WHEN** the dashboard renders its best-results chips for any mode
- **THEN** no chip is styled or labelled as locked

#### Scenario: Per-size statistics open for any size

- **WHEN** a user taps any record chip on the progress screen
- **THEN** the grid detail screen opens with its charts and period filters

### Requirement: The app presents no purchase path

The app SHALL contain no paywall, no purchase call to action, no subscription management entry point, no waitlist link and no StoreKit product configuration.

#### Scenario: The paywall route no longer exists

- **WHEN** `/paywall` is opened
- **THEN** the router does not resolve it to a paywall screen

#### Scenario: Onboarding contains no paywall page

- **WHEN** a new user completes onboarding
- **THEN** onboarding has six pages, none offers a subscription, and the notification-permission request is presented exactly once, on completion

#### Scenario: No premium upsell surface remains

- **WHEN** the Dart sources in `lib/` are searched for `isPremium`, `SubscriptionService`, `showPremiumBottomSheet`, `premiumGridSizes`, `PaywallScreen`, `yookassa` or `purchases_flutter`
- **THEN** no matches remain

#### Scenario: No StoreKit products are configured

- **WHEN** the iOS project is inspected
- **THEN** no `.storekit` file exists and the Runner scheme references none

### Requirement: No payment backend or payment credentials are retained

The project SHALL NOT retain payment backend code, its dependencies, its data model or payment-provider credentials.

#### Scenario: Payment functions are gone

- **WHEN** the repository is inspected
- **THEN** `functions/` does not exist and no `firebase.json`, `firestore.indexes.json` or `firestore.rules` is present

#### Scenario: The payment vulnerability surface is gone

- **WHEN** dependency vulnerabilities are counted across the repository
- **THEN** no npm package remains, so the 23 advisories previously reported in `functions/` are absent

#### Scenario: No payment credentials are passed to builds

- **WHEN** `Fastfile` and the GitHub workflows are inspected
- **THEN** none references `REVENUECAT_API_KEY` or any other payment-provider secret

### Requirement: Store metadata describes a fully free app

Published metadata SHALL NOT advertise a paid tier or list features as paid, and SHALL describe all four modes.

#### Scenario: Descriptions state the app is free

- **WHEN** `brainy-app/ios/fastlane/metadata/ru/description.txt` and `.../en-US/description.txt` are read
- **THEN** neither mentions "Brainy Pro" or paid features, both state the app is completely free, and both list the four modes

#### Scenario: Review notes state the app is free

- **WHEN** `brainy-app/ios/fastlane/metadata/review_information/notes.txt` is read
- **THEN** it says the app is completely free with four modes and makes no "premium coming soon" claim

#### Scenario: Store listing has no in-app purchase declaration (verified externally)

- **WHEN** the App Store Connect listing is reviewed before submission
- **THEN** it declares no in-app purchases or subscriptions

### Requirement: Existing players lose no progress in the transition

Removing the paid tier SHALL NOT reset or invalidate any locally stored progress.

#### Scenario: Stored progress survives the upgrade

- **WHEN** a user who played the gated build installs the free build
- **THEN** their coins, XP, level, streak, records, sessions, achievements and unlocked characters are unchanged

#### Scenario: Subscription keys are ignored rather than fatal

- **WHEN** the free build reads a Hive user box that still holds `subscriptionStatus`, `subscriptionExpiresAt` or `subscriptionPlan` keys from an earlier build
- **THEN** the app starts normally and ignores them
