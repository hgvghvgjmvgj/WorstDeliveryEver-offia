# ONE TRIP - M1 Manual Playtest

M1 does not prove the game design. It creates the build needed to test the core carry question.

## Studio setup

1. Sync or build the Rojo project into Roblox Studio.
2. Press Play.
3. Confirm Output prints ONE TRIP M1 server and client loaded messages.
4. Walk to a primitive item.
5. Press E or use the mobile GRAB button.
6. Press F3 if exact developer telemetry is useful.

## Required scenarios

### Heavy Early

Grab two Boxes and a Safe early.

Expected: the Safe is meaningfully heavy, but the low pile is more controllable than a late Safe.

### Heavy Late

Build a larger stack, then take Safe.

Expected: Base Instability rises more because the heavy Safe occupies a higher layer.

### Tall Late

Build a tall pile, then add Lamp.

Expected: Lamp is light but still worsens a tall load.

### Weight vs Bulk

Compare Couch and Safe.

Expected: Safe pressures Weight more. Couch pressures Bulk and contributes Wide behavior.

### Smooth Return

Take a dangerous pile home with gentle steering.

Expected: Current Sway stays more manageable and delivery remains possible.

### Aggressive Turn

With a dangerous pile, make a sharp turn.

Expected: Current Sway increases visibly. Wide items amplify turning pressure.

### Recovery

Reach Near Collapse, then stop.

Expected: Current Sway drains and the stack can recover if it falls far enough before the warning window expires. Base Instability remains.

### Continued Greed

Reach Near Collapse and continue abrupt movement.

Expected: after the warning window, Partial Collapse removes the upper portion of the pile and spawns protected dropped objects.

### Stop Exploit

Try repeated walk, stop, walk, stop movement.

Expected: stopping reduces Current Sway but does not erase Base Instability. Restarting movement creates acceleration pressure again.

## Playtest observations

Watch behavior rather than only asking for ratings.

- Does the player bank before a theoretical maximum?
- Do they approach an item, hesitate, and leave?
- Do they sometimes hesitate and grab it anyway?
- Do different players make different choices?
- Do they naturally stop moving to save a bad wobble?
- After Partial Collapse, do they quickly attempt another run?
- Does the visible pile remain funny and readable as it grows?
- Does any failure feel unexplained?

## Technical failure signs

- duplicate scoring from one carried item
- one world item can be taken by two players
- apparently stable piles collapse
- stopping zeroes Base Instability
- exact item count becomes the meaningful limit
- carried parts collide with players
- large piles make the local camera unusable
- unload can reward the same carried pile twice
