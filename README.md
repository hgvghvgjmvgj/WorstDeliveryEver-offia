# ONE TRIP!

Prototype for a small Roblox game built around one decision:

**How much can you carry before the trip becomes too risky?**

## Milestone 1 — Core Carry Prototype

The current build intentionally generates a gray-box test map at runtime.

Player flow:

1. Spawn beside the grocery car.
2. Take as many groceries as you want from the trunk.
3. Each item increases weight and the possible payout.
4. Press **GO — ONE TRIP**.
5. Walk to the front door.
6. Moving and turning while overloaded increases the balance meter.
7. Reach the door to get paid, or hit 100% balance and drop everything.
8. Reset and immediately try again.

This milestone does **not** include saving, upgrades, rarity, monetization, final models, or final map art. The only question is whether choosing "one more item" and surviving the walk is fun.

## Test

Run Rojo, connect Studio, and press Play in a one-player test.

Pass criteria:
- Picking items up is immediately understandable.
- Taking more items visibly changes the character.
- A heavy load is meaningfully harder than a light load.
- The player can deliberately play safer to recover balance.
- Success/failure resets quickly enough to encourage another attempt.
