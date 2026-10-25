## ADDED Requirements

### Requirement: The accessory shop is reachable

The character screen SHALL provide a working entry point to the accessory shop for any unlocked character. The entry point SHALL NOT be a disabled placeholder.

#### Scenario: The button navigates

- **WHEN** a user viewing an unlocked character taps the accessories button
- **THEN** the app navigates to the accessories screen

#### Scenario: No "coming soon" placeholder remains

- **WHEN** the character screen is inspected
- **THEN** it contains no disabled control labelled "coming soon"

### Requirement: Coins can be spent

Every coin earned SHALL be spendable. The shop SHALL be the sink for the coin economy.

#### Scenario: An affordable accessory is purchased

- **WHEN** a user with 200 coins buys an accessory priced at 150
- **THEN** the balance becomes 50 and the accessory is added to their unlocked accessories

#### Scenario: An unaffordable accessory is refused

- **WHEN** a user with 50 coins attempts to buy an accessory priced at 150
- **THEN** the purchase is refused, the balance is unchanged, and the user is told why

#### Scenario: Balance never goes negative

- **WHEN** any purchase is attempted
- **THEN** the resulting balance is greater than or equal to zero

### Requirement: Purchased accessories are equipped and shown

A purchased accessory SHALL be equipped automatically and SHALL render on the character preview.

#### Scenario: Purchase equips automatically

- **WHEN** a purchase succeeds
- **THEN** the accessory becomes the equipped item for its slot

#### Scenario: Equipped accessories render on the character

- **WHEN** a user with equipped accessories views the character screen or the home screen
- **THEN** the character preview shows them

#### Scenario: One item per slot

- **WHEN** a user equips a second hat
- **THEN** the first hat is unequipped and the second becomes the equipped hat

### Requirement: All four accessory slots are supported

The shop SHALL support hats, glasses, effects and capes. Each slot SHALL be independently equippable and persisted.

#### Scenario: Every slot has a tab

- **WHEN** the accessories screen is opened
- **THEN** it presents tabs for hats, glasses, effects and capes

#### Scenario: A cape is equipped and persisted

- **WHEN** a user buys and equips a cape
- **THEN** `CharacterData.equippedCape` holds its id, independently of the other three slots

### Requirement: Purchases and equipment survive restart

Ownership and equipment state SHALL be persisted to local storage and restored on launch.

#### Scenario: State survives a restart

- **WHEN** a user buys and equips accessories, then restarts the app
- **THEN** the accessories remain owned and equipped, and the coin balance reflects the purchases

#### Scenario: Ownership is per character

- **WHEN** a user switches the active character
- **THEN** each character's own unlocked and equipped accessories are shown

### Requirement: Accessory-related achievements are attainable

Achievements that depend on owning accessories SHALL be reachable now that accessories can be bought.

#### Scenario: An ownership achievement unlocks

- **WHEN** a user owns the number of accessories an achievement requires
- **THEN** that achievement unlocks and its popup is shown
