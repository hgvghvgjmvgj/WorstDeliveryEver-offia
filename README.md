# GET IT IN!

A solo-first Roblox spatial puzzle about forcing absurd oversized objects through spaces that look too small for them.

## Current status

- Prototype Zero controls: PASS
- Mobile controls: PASS
- M2 core loop: PASS
- M3 variety: PASS
- M4 economy + progression: CURRENT TEST

## M4 — Economy + Progression

M4 adds one currency and contract unlocks without making the carrying mechanic easier.

Session progression (not saved yet):

- **Oversized Couch** — unlocked immediately — pays $45
- **Tall Wardrobe** — unlocked immediately — pays $60
- **L-Shaped Sectional** — unlocks at $100 — pays $90
- **Grand Piano-ish Thing** — unlocks at $180 — pays $125

The expected first-session path is:

Couch -> Wardrobe -> unlock Sectional -> complete Sectional -> unlock Piano.

Progression changes the situations available to the player. There are deliberately no Strength, Grip, Carry Speed, or similar upgrades.

## M3 cleanup included

- Challenge walls now span the playable area so walking around the puzzle is no longer the intended shortcut.
- Wardrobe now has a low doorway followed by an offset second doorway, so one tilt is not the whole solution.
- Piano hallway has a low ceiling around the corner, so standing the long piano vertically should not erase the corner puzzle.
- Delivery now requires the full multi-piece object to be inside the success zone, not just its center pivot.

## M4 PASS criteria

- Cash makes finishing a delivery feel more meaningful.
- The next unlock is understandable without opening a menu.
- Unlocking the Sectional/Piano creates real curiosity.
- New contracts feel like new problems, not stat-gated copies.
- The player is not thinking "I need +10 Strength to make this less annoying."
- The first two unlock thresholds feel quick enough for a first session.

## Do not worry about yet

- DataStore saving (M5)
- final models and map art
- large contract library
- rarity / special orders
- co-op
- monetization
- polished effects and sound
- final UI styling

Cash resets when the server/session restarts on purpose. Persistence comes next if M4 passes.
