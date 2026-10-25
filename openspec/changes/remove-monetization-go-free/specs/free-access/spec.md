## ADDED Requirements

### Requirement: Every game mode and grid size is available to all users

The app SHALL NOT gate any grid size or game mode. Grid sizes 3, 4, 5, 6, 7 and 9 and both Classic and Gorbov-Schulte modes SHALL be playable by every user without any unlock step.

#### Scenario: Large grid sizes are playable

- **WHEN** a user selects grid size 6, 7 or 9 on the home screen
- **THEN** no lock icon is shown, no bottom sheet appears, and tapping Play starts the game

#### Scenario: Gorbov-Schulte mode is playable

- **WHEN** a user taps the Gorbov-Schulte toggle on the home screen
- **THEN** the mode switches and no upsell is shown

#### Scenario: Navigating directly to a formerly-gated size starts the game

- **WHEN** `/game?size=9&mode=gorbov` is opened directly
- **THEN** the game screen starts the countdown and does not redirect

### Requirement: Every character and accessory is obtainable without payment

Characters and accessories SHALL be unlocked by in-game achievement or in-game currency only. No character or accessory SHALL require a purchase.

#### Scenario: Pixel is unlockable by playing

- **WHEN** a user inspects the Pixel character card
- **THEN** it shows an achievable in-game condition, not a payment requirement

#### Scenario: Formerly-premium accessories are purchasable with coins

- **WHEN** a user views the Electricity effect or any other formerly-premium accessory in the shop
- **THEN** it shows only its coin price and is purchasable once the user has enough coins

### Requirement: Parent dashboard and detailed statistics are available to all users

The parent dashboard and the per-grid-size detail screen SHALL render their full content for every user.

#### Scenario: Dashboard renders after PIN entry

- **WHEN** a parent enters the correct PIN and reaches `/parent/dashboard`
- **THEN** the full dashboard renders with the weekly card, progress chart, best results and recent sessions
- **AND** no upsell screen is shown

#### Scenario: Best-result chips are never marked locked

- **WHEN** the dashboard renders its best-results chips for sizes 3 through 9
- **THEN** no chip is styled or labelled as locked

#### Scenario: Per-size statistics open for any size

- **WHEN** a user taps any record chip on the progress screen
- **THEN** the grid detail screen opens with its charts and period filters

### Requirement: The app presents no purchase path

The app SHALL contain no paywall, no purchase call to action, no subscription management entry point, and no waitlist link.

#### Scenario: The paywall route no longer exists

- **WHEN** `/paywall` is opened
- **THEN** the router does not resolve it to a paywall screen

#### Scenario: Onboarding contains no paywall page

- **WHEN** a new user completes onboarding
- **THEN** no page offers a subscription, and the notification-permission request is still presented exactly once

#### Scenario: No premium upsell surface remains

- **WHEN** the codebase is searched for `isPremium`, `showPremiumBottomSheet`, `premiumGridSizes` or `SubscriptionService`
- **THEN** no matches remain in `lib/`

### Requirement: No payment backend is deployed or retained

The project SHALL NOT retain payment backend code, its dependencies, or its data model.

#### Scenario: Payment functions are gone

- **WHEN** the repository is inspected
- **THEN** `functions/` does not exist, and `firebase.json` declares no functions source

#### Scenario: The payment vulnerability surface is gone

- **WHEN** dependency vulnerabilities are counted across the repository
- **THEN** the 23 advisories previously reported by `npm audit` in `functions/` are absent because the package no longer exists

#### Scenario: The subscriptions index is removed

- **WHEN** `firestore.indexes.json` is inspected
- **THEN** it declares no `subscriptions` collection index

### Requirement: Store metadata describes a fully free app

Published metadata SHALL NOT advertise a paid tier or list features as paid.

#### Scenario: Descriptions omit the paid tier

- **WHEN** `brainy-app/ios/fastlane/metadata/ru/description.txt` and `.../en-US/description.txt` are read
- **THEN** neither mentions "Brainy Pro", a subscription, or paid features

#### Scenario: Store listing has no in-app purchase declaration

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
