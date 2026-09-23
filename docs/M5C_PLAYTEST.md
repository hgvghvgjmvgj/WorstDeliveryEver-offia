# ONE TRIP — M5C PLAYTEST

## Phase gate

M5C is implemented but is **not runtime-passed** until this checklist is exercised in Roblox Studio. Do not begin M6 from this document alone.

M5C intentionally does not redesign carrying, handling, SELL/KEEP, Stock, rarity supply, or the M5A map.

## Current persistence behavior

- DataStore namespace remains `OneTripPlayerData_M5B_1HandlingTest_v1`.
- Collection is an additive optional profile field; missing/partial data sanitizes safely.
- Existing Stock is valid evidence of prior successful delivery and backfills Collection on load.
- Stock backfill does not re-pay mastery Cash: thresholds satisfied solely by migrated Stock are reconciled as already claimed.

## Debug tools already available

Under `Workspace.OneTripPrototype` in Studio:

- `DevForceSection`
- `DevForceRarity`
- `DevForceBaseItemId`
- toggle `DevSpawnNow = true`

Use these to produce deterministic test cargo instead of waiting for RNG.

---

## 1. New discovery

1. Start from an item that is `???` in COLLECTION.
2. Pick it up and successfully unload it in your own bay.
3. Do not choose SELL/KEEP yet.
4. Open COLLECTION.

Expected:
- discovery notification appears once
- base item becomes discovered immediately at delivery review
- section count increments by one
- Best Rarity matches delivered rarity
- SELL/KEEP decision is not required for discovery credit

Stop/rejoin and confirm it remains discovered.

## 2. Duplicate delivery

Deliver the same Common base item again.

Expected:
- section discovered count does not increase
- no NEW DISCOVERY toast
- mastery is not duplicated
- internal TimesDelivered may increase

## 3. Best Rarity ordering

For the same base item, deliver in this order:

1. Common
2. Rare
3. Uncommon
4. Mythic

Expected Best Rarity:

`Common -> Rare -> remains Rare -> Mythic`

Never compare rarity strings alphabetically.

## 4. SELL vs KEEP

Deliver two previously undiscovered core items.

- SELL one
- KEEP one

Expected:
- both are already discovered before the review actions
- both remain discovered afterward
- liquidating the kept Stock later does not remove discovery

## 5. Collapse does not discover

1. Find an undiscovered item.
2. Pick it up.
3. Lose it through collapse before reaching the bay.

Expected:
- remains `???`
- no discovery/mastery credit

## 6. Manual ditch does not discover

1. Pick up an undiscovered item.
2. Press Q / DITCH before delivery.

Expected:
- remains undiscovered
- no discovery/mastery credit

## 7. Mastery milestones

Each current section has 12 core items, so the current threshold crossings occur at:

- 3 / 12 -> 25%
- 6 / 12 -> 50%
- 9 / 12 -> 75%
- 12 / 12 -> 100%

Use forced base items to avoid waiting for random spawns.

Expected:
- each milestone reward fires once
- 50% marks SECTION PLAQUE placeholder unlocked
- 75% marks SECTION BANNER placeholder unlocked
- 100% creates that section's physical bay trophy
- reconnect does not pay any milestone again
- trophy returns after reconnect
- trophy does not consume a Stock slot

## 8. Dynamic content count

Do not leave test content committed.

Temporarily simulate a different core-item count in one section (or alter a local Studio copy), then verify the denominator and percentage use actual catalog contents rather than hardcoded 12.

## 9. Hero / Rare Find

Force and deliver a current hero item, for example:

- `RoyalGrandPiano` at Legendary+
- `TitanVaultSafe` at Mythic+
- `CosmicReactorCore` at Cosmic+
- `BlackProjectContainmentUnit` at Cosmic+

Expected:
- appears in RARE FINDS
- records Best Rarity
- does not increase normal Core Collection denominator/completion
- hero RNG is not required for standard 100% mastery

## 10. Cosmic/Eternal normal cargo prestige

Deliver a Cosmic or Eternal version of an ordinary core item.

Expected:
- normal base item discovery/best rarity still works
- it can additionally appear as a prestige Rare Find
- standard section denominator remains unchanged

## 11. Existing Stock backfill

Use a profile from M5B.1 that already owns Stock.

Expected on load:
- owned Stock base item is marked discovered
- Best Rarity reflects the Stock item's rarity
- hero/Cosmic+ Stock can backfill Rare Finds
- no migration mastery Cash exploit
- repeated reconnect does not increment TimesDelivered or pay rewards

## 12. Server announcement

Deliver:

- ordinary Rare -> no server announcement
- ordinary Epic -> no server announcement
- Cosmic -> shared announcement after successful delivery
- Eternal -> shared announcement after successful delivery
- Mythic+ hero -> currently eligible for shared announcement

Expected:
- no announcement on spawn, sight, preview, or pickup
- one extraordinary announcement maximum per haul
- correct DisplayName, item, and rarity

## 13. Multiplayer

Use multiple clients when practical.

Expected:
- Player A's discovery does not unlock Player B's Collection
- mastery rewards stay with correct player
- trophy appears only in owner's bay showcase
- trophies are visible to other players
- Cosmic/Eternal delivery announcement is shared
- reconnect does not swap profiles/collections

## 14. Mobile/UI

Emulate a phone/tablet viewport.

Expected:
- COLLECTION opens/closes comfortably
- horizontal section strip can scroll
- entry list can scroll vertically
- `???` and Best Rarity remain readable
- Rare Finds tab is usable
- notification toasts are compact and do not block GRAB/DITCH controls
- full Collection panel only opens manually

## 15. Persistence/data safety

Exercise:

- fresh profile
- old M5B.1 profile with no Collection field
- old profile with Stock
- save/rejoin after discovery
- save/rejoin after mastery
- partially missing Collection tables if practical

Expected:
- missing data defaults safely
- valid discoveries persist
- invalid/unknown catalog entries do not become collection entries
- reward milestone flags prevent duplicate Cash

## 16. Pre-existing issues not solved by M5C

### Pending Delivery Review

Unresolved Delivery Review still exists only in server memory. M5C does not attempt a large transactional-review persistence rewrite.

### Delivery capture authority cleanup

CollectionService never parses carried visual names itself. It receives the same successful-delivery item IDs used by Economy. However, the current EconomyService `CaptureCarriedItems` implementation still reconstructs that server list from server-created carry presentation parts. This is an older pre-release architecture issue and should eventually be replaced by a direct authoritative CarryService item-record API.

## M5C runtime pass condition

Do not call M5C runtime-passed until the important paths above have been exercised successfully, especially:

- new discovery + reconnect
- duplicate
- Best Rarity ordering
- SELL and KEEP
- collapse/ditch negative cases
- all mastery thresholds + duplicate reward prevention
- trophy persistence
- hero Rare Find
- Stock migration/backfill
- Cosmic/Eternal announcement
- at least a basic multi-client check
- mobile UI check

Then stop and review before M6.
