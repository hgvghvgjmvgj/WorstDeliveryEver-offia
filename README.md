# GET IT IN!

A solo-first Roblox spatial puzzle about forcing absurd oversized objects through spaces that look too small for them.

## Current status

- Prototype Zero controls: PASS
- Mobile controls: PASS
- M2 core loop: PASS
- M3 variety: PASS
- M4 economy + progression: PASS
- M5 saving + reliability: CURRENT TEST

## M5 — Saving + Reliability

M5 persists the progression already proven in M4 without changing the puzzle controls or economy.

Saved:
- cash
- contract unlocks indirectly through saved cash

Not saved yet:
- current furniture position
- active contract position/state
- cosmetics
- settings
- map state

### Reliability rules

- Data loads before the player can grab furniture.
- Cash is sanitized before use.
- DataStore reads/writes retry up to 3 times.
- Progress saves after successful deliveries.
- Dirty progress also autosaves every 60 seconds.
- Dirty progress saves again when leaving and when the server closes.
- If loading fails, the player can still play that session, but saving is disabled so a temporary failure cannot overwrite an existing save with $0.
- Current cash only increases, so saves keep the larger stored value to protect against an older server overwriting newer progress.

## Studio testing

Roblox DataStores only persist when the experience is published and Studio/API access is available for the test environment.

For the real M5 test:
1. Publish the experience privately.
2. Enable Studio access to API services for the test place if testing persistence from Studio.
3. Join and earn cash.
4. Leave completely.
5. Rejoin.
6. Confirm the same cash returns and the same contracts remain unlocked.

## M5 PASS criteria

- Earned cash survives a full leave/rejoin.
- Sectional/Piano unlocks rebuild correctly from loaded cash.
- Rejoining never resets valid progress to $0.
- A failed DataStore request does not crash the game.
- Normal carrying, rotate, tilt, drop, delivery, and payouts still behave exactly as before.
- Repeated deliveries do not duplicate or lose payouts unexpectedly.

## Do not worry about yet

- polished map/art
- final furniture models
- rarity / special contracts
- social/co-op systems
- monetization implementation
- final UI/VFX/audio

The hint/monetization concept remains planned for the monetization milestone: one useful free hint per contract, with optional paid convenience later, without making base puzzles unfair.
