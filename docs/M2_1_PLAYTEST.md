# ONE TRIP - M2.1 Carry Strain Playtest

M2.1 fixes the turtle strategy without adding a universal timer.

Target feeling:

> Don't rush, but don't waste time either.

## Setup

1. Sync latest main through Rojo.
2. Press Play.
3. Confirm server Output contains: [ONE TRIP] M2.1 carry strain prototype loaded
4. Leave F3 OFF for the first pass.
5. Use F3 afterward to inspect Strain and Load Severity.

## Test A - Safe load

Carry 2-5 ordinary low-risk items.

Expected:
- no artificial urgency
- no persistent strain tremble
- stopping/moving feels like existing M1.1 behavior
- F3 should show zero or negligible Strain accumulation for truly comfortable loads

FAIL if normal trips feel rushed.

## Test B - Large load

Build a clearly dangerous pile, such as a mixed load ending with a late Safe.

Expected:
- Strain begins accumulating
- the effect is initially subtle
- over time the pile becomes harder to keep perfectly settled
- there is pressure to complete the delivery without panic rushing

## Test C - Stop spam

Build an absurd pile.

Repeat:
- walk briefly
- stop until movement Sway settles
- walk briefly
- stop again

Expected:
- Current Sway repeatedly reduces
- Strain does not reset
- persistent tremble increases over time
- recovery becomes slower at high Strain
- eventually standing still is no longer a permanent solution

FAIL if this still allows effectively unlimited safe transportation.

## Test D - Reckless movement

Use the same dangerous pile and move with sharp turns, reversals, and unnecessary acceleration.

Expected:
- existing movement Sway remains the fastest way to get in trouble
- Strain amplifies later mistakes
- reckless movement should fail earlier than smooth movement

FAIL if rushing becomes the safest solution.

## Test E - Smooth continuous movement

Take the same dangerous load and use a direct route with gentle continuous steering.

Expected:
- this should usually be the strongest strategy
- movement Sway stays lower than reckless play
- trip finishes before Strain becomes critical when the route is efficient

## Test F - Long stationary hold

Build an absurd 8-10 item pile and simply stand still.

Expected sequence:
- initial movement Sway settles
- Strain continues accumulating
- persistent pile trembling appears
- High/Critical Strain becomes visually obvious
- the pile can no longer become perfectly calm
- an already absurd load eventually enters the existing recoverable collapse warning and can partially collapse

Failure must remain telegraphed through the pile. No safe-looking random explosion.

## Test G - Recovery still matters

Get a dangerous pile swinging badly, then stop.

Expected:
- movement-generated Sway falls
- you can still save a near-collapse caused by movement
- accumulated Strain remains
- continuing the trip still carries holding pressure

## F3 developer checks

Developer telemetry now shows:
- Base Instability
- Current Sway
- Strain
- Strain Stage
- Load Severity

These values are intentionally not part of the normal player HUD.

## Tuning expectation

With current Beginner values, code-level load examples are approximately:

- 3-item Box/Box/Safe load: no meaningful Strain
- 5-item ordinary mixed load: no meaningful Strain
- risky 6-item mixed load with late Safe: about 29 seconds from zero Strain to Critical if kept overloaded
- dangerous 7-item mixed load: about 18 seconds
- absurd 8-item mixed load: about 14-15 seconds
- extreme 10-item load: about 12-13 seconds

These are load-holding estimates, not player-facing timers.

## PASS

M2.1 passes if the strongest behavior becomes:

> move smoothly, deliberately, and efficiently; stop briefly only when needed.

It fails if either strategy dominates:

- infinite step-stop-step-stop turtling
- reckless rushing because speed is the only thing that matters

Do not begin progression until this is approved.