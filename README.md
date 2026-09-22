# ONE TRIP

A 12-player Roblox game about carrying an increasingly ridiculous pile of objects and deciding whether to risk **ONE MORE** before making it back to your van.

## Current milestone

**M0 — Project reset + prototype foundation**

This repository previously contained the old **GET IT IN!** project. The old gameplay architecture has been removed. ONE TRIP starts from a clean, prototype-first foundation.

### M0 goals

- clean Rojo project structure
- one shared source of truth for prototype tuning
- simple 12-player graybox layout
- eight primitive test-item definitions
- networking namespace prepared for the carry prototype
- no economy, persistence, rarity system, monetization, events, or final art

## Locked core loop

**Enter warehouse -> grab objects -> build a ridiculous carried pile -> decide whether to risk ONE MORE -> return to your van -> unload -> earn -> upgrade -> repeat.**

Only the first half of that loop belongs in the current prototype. We are proving the carrying decision before building the surrounding game.

## Prototype question

> Is carrying a ridiculous pile, reading its danger, and deciding whether to risk ONE MORE genuinely fun?

If primitive blocks cannot make that fun, we fix the carrying mechanic before adding progression.

## Project structure

```text
src/
  client/
    Main.client.lua
  server/
    Main.server.lua
    Services/
      RemoteService.lua
      WorldService.lua
  shared/
    Config/
      CarryConfig.lua
      GameConfig.lua
      ItemConfig.lua
    Net/
      RemoteNames.lua

docs/
  ARCHITECTURE.md
  CORE_MECHANIC.md
```

## Tooling

This project uses Rojo.

```bash
aftman install
rojo serve
```

Build a place file with:

```bash
rojo build -o OneTrip.rbxlx
```

## Scope rule

Do not add pets, rebirths, combat, trading, crafting, multiple currencies, giant maps, quests, clans, battle passes, aggressive PvP, or unrelated minigames to solve uncertainty in the carry mechanic.
