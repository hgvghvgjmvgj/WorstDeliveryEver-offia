# ONE TRIP

A Roblox game about carrying an increasingly ridiculous pile of objects and deciding whether to risk **ONE MORE** before making it back to your unload point.

## Current milestone

**M1.1 - Core Feel Pass / awaiting playtest validation**

M1 proved that the basic architecture worked, but the first playtest verdict was that the core felt ugly and, more importantly, not fun enough.

M1.1 keeps the same architecture and core mechanic. It does not add progression or content systems. It strengthens:

- pickup responsiveness
- stack spectacle
- item differentiation
- movement-driven danger
- readable recovery
- partial-collapse presentation
- unload payoff
- temptation-focused test layout

## Current primitive loop

Find item -> GRAB -> object flies into pile -> pile gets more ridiculous -> movement creates visible sway -> decide whether to risk another object -> recover or collapse -> reach unload -> animated test-score release -> repeat

## Controls

- **E / mobile GRAB button** - grab nearest highlighted item
- **Q** - drop the top carried item
- **F3** - toggle developer carry telemetry

## Important prototype behavior

- The first few items should feel easy and empowering.
- Around the middle of a run, object choice should start mattering.
- Dangerous loads should punish sharp acceleration and turning more than careful movement.
- Stopping drains Current Sway but never removes Base Instability.
- Upper stack layers lag and move more dramatically than lower layers.
- Partial Collapse remains the active failure mode.
- This is still primitive graybox content, not production art.

## Still excluded

- DataStores
- progression / upgrade shop
- final Cash economy
- rarity
- collections
- events
- monetization
- final warehouse
- final UI
- cosmetics
- Blender assets
- pets / rebirths / trading / combat / quests

## Tooling

Use `aftman install`, then `rojo serve`.

Build with:

`rojo build -o OneTrip.rbxlx`

See:

- `docs/CORE_MECHANIC.md`
- `docs/M1_PLAYTEST.md`
- `docs/M1_1_PLAYTEST.md`
