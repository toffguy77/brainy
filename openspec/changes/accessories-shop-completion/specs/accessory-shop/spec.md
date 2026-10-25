## ADDED Requirements

### Requirement: The accessory shop is reachable

The character screen SHALL show an enabled "Customize accessories" button whenever the character on the current page is unlocked, and tapping it SHALL navigate to `/accessories`. The character screen MUST NOT show a disabled "coming soon" placeholder for accessories.

#### Scenario: The button navigates

- **WHEN** a user viewing an unlocked character on the character screen taps the accessories button
- **THEN** the app pushes the `/accessories` route and the accessories screen is shown

#### Scenario: Locked characters have no button

- **WHEN** the character on the current page is locked
- **THEN** no accessories button is shown

#### Scenario: No "coming soon" placeholder remains

- **WHEN** the character screen is rendered
- **THEN** it contains no disabled accessories control and no "coming soon" text, and the ARB files contain no `comingSoon` key

### Requirement: The shop dresses the active character

The accessories screen SHALL show and modify the character stored in `UserProgress.activeCharacterId`, falling back to the first character if that id is unknown.

#### Scenario: Shop preview shows the active character

- **WHEN** the accessories screen opens
- **THEN** its preview shows the active character wearing its equipped accessories, with a chip naming each equipped item

### Requirement: Coins are the only currency

Every accessory SHALL have a positive coin price and SHALL be purchasable with coins alone. The shop MUST NOT offer premium items or any way to buy coins. The shop SHALL display the current coin balance.

#### Scenario: Balance is visible

- **WHEN** the accessories screen is open
- **THEN** its app bar shows the current `UserProgress.coins`

#### Scenario: The cheapest item is reachable early

- **WHEN** the catalogue is inspected
- **THEN** the cheapest accessory costs no more than 20 sessions' worth of coins

### Requirement: Purchases deduct coins and grant global ownership

A purchase SHALL succeed only if the balance covers the price; on success the price MUST be deducted and the accessory id added to `UserProgress.unlockedAccessories`, which is shared by all characters. The balance MUST NOT go negative. Buying an already-owned accessory MUST NOT charge again.

#### Scenario: An affordable accessory is purchased

- **WHEN** a user with 500 coins buys an accessory priced at P
- **THEN** the balance becomes 500 − P and the accessory is owned

#### Scenario: An unaffordable accessory is refused

- **WHEN** a user with P − 1 coins taps an accessory priced at P
- **THEN** the purchase is refused, ownership and balance are unchanged, and a bottom sheet says coins are insufficient, showing the price and the current balance

#### Scenario: Balance never goes negative

- **WHEN** a user with 10 coins attempts to buy every accessory
- **THEN** the resulting balance is greater than or equal to zero

#### Scenario: No double charge

- **WHEN** a user buys an accessory they already own
- **THEN** the call succeeds and the balance is unchanged

#### Scenario: Ownership is shared across characters

- **WHEN** a user buys an accessory and then makes a different character active
- **THEN** the accessory is shown as owned for that character too

### Requirement: Equipment is per character, one item per slot

Each character SHALL store its own equipped item for each of the four slots (hat, glasses, effect, cape) in `CharacterData.equippedHat/Glasses/Effect/Cape`. Slots MUST be independent, and equipping an item SHALL replace whatever that character wore in the same slot.

#### Scenario: Purchase equips automatically

- **WHEN** a purchase in the shop succeeds
- **THEN** the item becomes the active character's equipped item for its slot, a purchase haptic fires, and a "Purchased!" snackbar is shown

#### Scenario: Tapping an owned item equips it

- **WHEN** a user taps an owned, unequipped accessory
- **THEN** it becomes the equipped item for its slot, replacing the previous one

#### Scenario: One item per slot

- **WHEN** a user equips a second hat
- **THEN** the second hat is the equipped hat and the first is no longer worn

#### Scenario: Tapping the equipped item removes it

- **WHEN** a user taps the equipped accessory, whose chip reads "Remove"
- **THEN** that slot is cleared and the other slots keep their items

#### Scenario: A cape is equipped independently

- **WHEN** a user equips a hat and a cape
- **THEN** `equippedHat` and `equippedCape` both hold their ids

### Requirement: All four slots are offered

The accessories screen SHALL present four tabs — hats, glasses, effects, capes — each listing every catalogue item of that slot, and every slot SHALL have at least one item. Accessory ids MUST be unique and every accessory MUST have a localized name in both Russian and English.

#### Scenario: Every slot has a tab

- **WHEN** the accessories screen is opened
- **THEN** it shows tabs for hats, glasses, effects and capes, each with a two-column grid of that slot's items showing the item glyph and its state (price, "Equip" or "Remove")

### Requirement: Equipped accessories are drawn on the avatar without asset files

Every accessory SHALL carry a `glyph` (emoji or text) or a `tint`; no accessory MUST depend on an image asset. The avatar on the home screen, the character screen and the shop SHALL draw the character's equipped items: cape behind the body, glasses on the face, hat above, effect glyphs around. A cape with a glyph (wings) SHALL be drawn as a mirrored pair; a cape with only a tint SHALL be painted in that colour. Unknown equipped ids SHALL be ignored.

#### Scenario: Equipped accessories render on the character

- **WHEN** a character wears a hat, glasses, an effect and a cape
- **THEN** its avatar draws all four layers

#### Scenario: Bare avatar

- **WHEN** a character wears nothing
- **THEN** no accessory layer is drawn

#### Scenario: Wings and painted capes

- **WHEN** a character wears the wings
- **THEN** the wing glyph is drawn twice, one mirrored
- **WHEN** a character wears a tint-only cape
- **THEN** a painted cape of that tint is drawn behind the character

### Requirement: Purchases and equipment survive restart

Coins, ownership and equipment SHALL be persisted to Hive on every change and restored on launch.

#### Scenario: State survives a restart

- **WHEN** a user buys and equips accessories and the providers are rebuilt from storage
- **THEN** the balance, the owned accessories and each character's equipped items are unchanged

### Requirement: Spending does not revoke achievements

No achievement SHALL depend on owning accessories. `coin_hoarder` SHALL unlock when the balance is at least 500 coins after a session and, once unlocked, MUST NOT be revoked or re-awarded when coins are spent.

#### Scenario: Spending after coin_hoarder

- **WHEN** a user who has unlocked `coin_hoarder` spends coins below 500
- **THEN** the achievement remains unlocked and is not announced again
