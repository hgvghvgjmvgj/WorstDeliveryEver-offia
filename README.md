# GET IT IN!

A solo-first Roblox spatial/physics puzzle game about forcing absurd oversized objects through spaces that look too small for them.

## Locked fantasy

**"There is no way that fits in there... unless I can figure it out."**

The core interaction has passed the first desktop and mobile control tests. The player moves normally while holding furniture; the object mirrors movement, can jam against geometry, and can be rotated/tilted without forcing the avatar around.

## M2 — Complete Core Loop

Current prototype loop:

1. A moving object appears outside the house.
2. Grab it.
3. Walk normally while the object follows your movement.
4. Rotate, tilt, drop, re-grab, and reposition as needed.
5. Get the whole object far enough inside.
6. **DELIVERED!**
7. The next geometry problem appears automatically.

Current test set:

- **Oversized Couch** — width problem.
- **Tall Fridge** — height/orientation problem.
- **Huge Dining Table** — width + depth problem.

After all three, the prototype loops back to the first object for repeat testing.

## Controls

Desktop:
- Normal movement = move the held object with your character.
- Q / E = rotate.
- R = tilt/reorient.
- F = drop.

Mobile:
- Normal Roblox joystick = move while holding.
- Large LEFT / TILT / RIGHT / DROP buttons.

## What M2 must prove

Expected:
- The successful couch controls remain comfortable.
- The 3 objects require noticeably different solutions.
- Finishing one object makes the next one immediately understandable.
- The transition between deliveries is fast.
- The player wants to see what the next object is.

Do not worry about yet:
- cash
- saving
- upgrades
- rarity
- final furniture models
- final house/map art
- destruction
- co-op
- monetization
- polished effects

If all three objects feel like the exact same puzzle with different rectangles, M2 fails and we revise variety before adding progression.
