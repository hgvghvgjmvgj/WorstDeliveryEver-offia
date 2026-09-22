# ONE TRIP — Core Mechanic Lock

## Prototype objective

Prove:

> Carrying an increasingly ridiculous pile, judging its danger, and deciding whether to risk ONE MORE is fun.

## V1 item properties

Only these properties exist in the carry prototype:

- Value — prototype desirability/score
- Weight — load pressure and movement burden
- Bulk — how much the item expands the load
- Shape — Compact, Tall, or Wide

There is no per-item Stability stat. Stability is derived from the current pile.

## Instability inputs

The future CarryService should derive danger from:

- weight pressure
- bulk pressure
- pile height
- shape pressure
- heavy objects placed high in the stack
- current movement/sway
- sharp direction changes

Do not expose an exact percentage danger meter.

## Readable danger states

1. Stable
2. Slight wobble
3. Unstable
4. Dangerous
5. Near collapse

Standing still should allow recovery. Sudden turns should increase sway. Collapse must be preceded by readable danger.

## Failure

Prototype failure variants to test later:

- item slip
- partial collapse
- full collapse

Start from item-slip -> partial-collapse behavior rather than deleting an entire haul immediately.

## Multiplayer rules

- target server size: 12
- player-to-player collision: off during carry gameplay
- carried piles cannot knock other players down
- first valid server-confirmed shared-item grab wins
- no aggressive PvP
- normal stock should recover quickly enough that the Item Floor remains playable

## Hard failure signals

Do not proceed if:
- players simply fill to a known hard maximum every trip
- exact thresholds solve the game
- failures feel random
- item choices feel interchangeable
- veteran carrying becomes effortless
- collapse makes players stop taking risks
- the warehouse is frustrating with 12 players
- the visible pile is not ridiculous
- walking dominates decision-making
