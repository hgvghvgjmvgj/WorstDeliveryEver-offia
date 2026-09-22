# GET IT IN!

A solo-first Roblox physics/puzzle game about forcing absurd oversized objects through spaces that look too small for them.

## Locked fantasy

**"There is no way that fits in there... unless I can figure it out."**

The fun must come from manipulating the object and solving the physical space. Progression is not allowed to rescue a boring core mechanic.

## Five-pass design review

1. **Fantasy:** the oversized-object/too-small-space problem is visually obvious and creates curiosity before rewards exist.
2. **Mobile:** no hold-to-drag control. Use tap/proximity grab plus assisted movement and large rotate/tilt buttons.
3. **Solo-first:** every job must be fully completable alone. Co-op can later make jobs funnier/faster, never required.
4. **Progression:** future cash unlocks new objects, contracts, spaces, and optional tools—not permanent strength stats that erase the puzzle.
5. **Scope:** Prototype Zero contains one couch and one doorway. No economy, saving, rarity, final art, destruction, soft-body furniture, or required multiplayer.

## Prototype Zero

The server generates a tiny test room at runtime.

Goal:

**Get the red couch through the doorway.**

Controls:
- Approach the couch and use the GRAB prompt.
- Move normally; the couch follows with limited physical force so walls can stop it.
- Rotate left/right in 15-degree steps.
- Tilt the couch 90 degrees when useful.
- Drop/re-grab whenever you need to reposition.

Desktop:
- Q = rotate left
- E = rotate right
- R = tilt
- F = drop

Mobile:
- Large on-screen Rotate Left / Tilt / Rotate Right / Drop buttons.

## PASS criteria

Do not build progression until all of these are true:

- A new player understands the objective in seconds.
- Grabbing/releasing is comfortable on mobile and desktop.
- The couch can genuinely get stuck instead of clipping through the doorway.
- The player can intentionally rotate/reposition to solve the doorway.
- Failure feels caused by geometry/approach, not an invisible meter.
- Getting the couch through feels satisfying enough that a differently-shaped second object sounds fun.

If moving one placeholder couch through one placeholder doorway is not entertaining, stop development.
