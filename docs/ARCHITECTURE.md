# ONE TRIP — Architecture Rules

## Authority model

The server owns gameplay truth.

Clients may request actions and render feedback, but they do not authoritatively decide:
- who owns a shared item
- item state
- carried-item membership
- collapse results
- unload results
- player rewards

## Prototype architecture

### Shared

Shared modules contain:
- immutable item definitions
- prototype tuning values
- remote names
- cross-boundary constants

### Server

Server services own:
- world/graybox generation
- item spawning
- shared-item reservation
- carry state
- instability/collapse simulation
- unloading

Services should expose small public APIs and keep mutable state private.

### Client

Client code owns:
- input
- contextual Grab/Drop presentation
- camera protection
- local visual/audio feedback

The client should not calculate authoritative carry success or collapse outcomes.

## Development rules

1. Build the risky interaction before economy or persistence.
2. Prefer deterministic/controlled stacking over true physics.
3. No player body-blocking as a gameplay feature.
4. Carried piles must not become collision weapons.
5. New item properties require a demonstrated decision-making purpose.
6. Avoid hidden RNG that causes unexplained failure.
7. Keep prototype tuning centralized in Config modules.
8. Preserve the visible pile. Do not replace it with an invisible inventory.
9. The target lobby is 12 players and must remain playable on mobile.
10. Commit only after a milestone is testable.
