# ONE TRIP — M6A.3 PLAYTEST GATE

## Scope
M6A.3 tests onboarding, derived Rig clearance, long-map Speed, high-speed carrying, and stronger graybox section identity. Do not start final M6B art until this gate passes.

## Implemented test Speed curve
- Level 1: 20
- Level 2: 28
- Level 3: 38
- Level 4: 49
- Level 5: 61
- Level 6: 74
- Level 7: 88

Existing Speed upgrade costs are intentionally unchanged for this test.

## Static travel estimate — home to Section 15 center (~1,261 studs)
- Starter 20: ~63.1s
- Mid 49: ~25.7s
- Max 88: ~14.3s

These are geometric estimates, not Studio results.

## Static loaded-speed examples
Representative Weight ratios only; actual result also depends on handling band, cargo, Control, and movement events.

| Speed stat | READY/light | RISKY example | DANGEROUS example |
| --- | ---: | ---: | ---: |
| 20 | ~20.0 | ~18.5 | ~12.5 |
| 49 | ~49.0 | ~43.8 | ~28.1 |
| 88 | ~88.0 | ~77.9 | ~49.2 |

The goal is not to lock these numbers. Verify that Speed upgrades remain valuable under load without trivializing dangerous extraction.

# Clearance bands

| Derived Rig | Accessible sections |
| --- | --- |
| STARTER | 1 Receiving & Returns; 2 Home Basics |
| RIG I | +3 Appliances |
| RIG II | +4 Furniture; +5 Electronics; +6 Recreation |
| RIG III | +7 Garage & Auto; +8 Construction; +9 Heavy Equipment |
| RIG IV | +10 Industrial Machinery; +11 Premium Interiors; +12 Luxury Goods |
| RIG V | +13 Art & Collectibles; +14 Secure Vault; +15 Restricted / Prototype |

Physical checkpoints exist before Sections 3, 4, 7, 10 and 13.

## Clearance architecture
- Character groups: PlayerRig0 ... PlayerRig5.
- Gate groups: GateRig1 ... GateRig5.
- Every player Rig group remains non-collidable with every other player Rig group.
- A player's group collides only with gates above their tier.
- Gate visuals are local RED locked / GREEN cleared presentation.
- Server validates `ItemService.TryTake` against the item's section.
- A player found meaningfully beyond their first locked checkpoint is returned to the home side without clearing Sway or Load Pressure.
- Clearance is not persisted separately. `HandlingRigTier` remains derived from Strength + Carry Space + Control.

# Tutorial flow

Expected sequence:
1. YOUR BAY.
2. GO TO RECEIVING — temporary objective marker/beam.
3. GRAB SOMETHING — actual desktop/controller/touch Grab interaction.
4. CAN YOU CARRY ONE MORE? — requires a two-item pile.
5. SHARP MOVES MAKE YOUR PILE SWAY / MOVE SMOOTHLY.
6. Tutorial-only instability message can show STOP OR IT MAY FALL!
7. BRING IT BACK — objective targets the player's own UnloadZone.
8. FIRST TRIP COMPLETE — SELL vs KEEP explanation.
9. UPGRADES automatically opens so Strength / Carry Space / Control / Speed are visible.
10. APPLIANCES — RIG I REQUIRED / BUILD RIG I TO GO DEEPER.
11. Tutorial completes and is persisted.

Tutorial completion uses the temporary M6A.3 boolean store `OneTripTutorial_M6A3_v1`. No clearance or Rig unlock state is duplicated there.

To replay onboarding within the current Studio session:
```lua
local p = game.Players:GetPlayers()[1]
p:SetAttribute("TutorialCompleted", false)
```

# Test 1 — zero-explanation new player
Use a fresh/test profile and do not deliberately inspect Explorer first.

Pass if, within seconds:
- YOUR BAY is obvious;
- Receiving direction is obvious;
- the first Grab action is understandable;
- the game teaches stacking instead of one-item delivery;
- return target is the player's own bay;
- SELL/KEEP is understood at a basic level;
- the next goal becomes RIG I / Appliances.

Record total tutorial completion time. Target 60–120 seconds depending on behavior.

# Test 2 — Starter clearance
As STARTER:
- enter Receiving;
- enter Home Basics;
- attempt the RIG I checkpoint before Appliances;
- jump at it;
- run into it at full Starter Speed;
- approach both edges;
- reset/respawn and repeat.

Pass if Appliances is physically inaccessible and no player-player body blocking appears.

# Test 3 — two-client per-player gate
Start two clients.

Client A: STARTER.
Client B: RIG I or higher.

Pass if:
- B crosses GateRig1;
- A remains blocked by the exact same gate;
- B crossing does not globally open it;
- A and B remain non-collidable with each other.

For a temporary collision-only test in Server Command Bar:
```lua
local players = game.Players:GetPlayers()
players[1]:SetAttribute("HandlingRigTier", 0)
players[2]:SetAttribute("HandlingRigTier", 3)
```
Use real upgrades for the final progression validation.

# Test 4 — upgrade while touching gate
Stand against the first locked gate, then legitimately reach RIG I.

Pass if:
- Rig I unlock celebration appears once;
- checkpoint turns locally GREEN / CLEARED;
- character collision updates without respawn;
- player can walk through immediately.

# Test 5 — server backup
As STARTER, teleport or otherwise place the character beyond the RIG I checkpoint.

Pass if:
- no kick occurs;
- inaccessible cargo cannot be grabbed server-side;
- the player is safely recovered to the home side of the first locked gate;
- carried Sway/Pressure is not reset as a reward for exploiting.

# Test 6 — high-speed unloaded traversal
Test Speed 20, 49 and 88 on desktop.

Record real home → Section 15 travel time.

Judge:
- steering;
- camera readability;
- section-sign readability;
- whether 88 feels exciting vs absurd;
- whether section transitions can still be perceived.

Repeat max Speed in mobile emulator before approving 88.

# Test 7 — high-speed loaded handling
Use the same manageable pile where possible.

At high Speed test:
- straight smooth cruise;
- gradual acceleration;
- hard acceleration;
- gradual stop;
- panic stop;
- 30-degree turn;
- 60-degree turn;
- 90-degree turn;
- 180-degree reversal;
- repeated zig-zag.

Watch player attributes:
- MotionSpeed
- MotionAcceleration
- MotionTurnDegrees
- MotionEventSeverity
- MotionCruiseStable
- HandlingSwayMultiplier
- HandlingRecoveryMultiplier
- CarryStrain

Pass if smooth cruising settles while high-speed mistakes create substantially more temporary Dynamic Sway.

# Test 8 — Control comparison
Repeat a high-Speed loaded turn/brake test at low Control and high Control.

Pass if higher Control noticeably damps movement-event severity/recovery penalties but does not make a 90-degree turn or panic stop free.

# Test 9 — Load Pressure regression
Take an overloaded pile and cruise smoothly for a long time.

Pass if Dynamic Sway can settle but Load Pressure / Strain continues according to the load. Sprinting straight must not make an overloaded pile safe.

# Test 10 — section identity graybox
Walk the whole accessible range and later test unlocked bands.

Ignore final aesthetics. Judge whether boundaries differ through:
- overhead height;
- frame frequency;
- aisle-edge spacing;
- floor treatment/material;
- storage layout;
- major Rig checkpoint architecture;
- signs/openness.

Fail if it still reads only as one long corridor with different floor colors.

# Test 11 — multiplayer concentration
With several players at similar Rig tiers, observe whether they repeatedly share the same accessible regions and contest visible loot.

Pass if clearance improves density without instancing the warehouse or creating player blocking.

# Runtime status
Static implementation only. Roblox Studio must validate:
- tutorial timing/usability;
- collision-group behavior in live character physics;
- gate edge/jump/high-speed cases;
- server recovery feel;
- 20 starter movement feel;
- 88 desktop/mobile camera and steering;
- loaded Speed retention;
- Control at high Speed;
- multiplayer density;
- section readability;
- tutorial persistence/rejoin.

Do not begin M6B until these are reviewed.
