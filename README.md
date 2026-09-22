# ONE TRIP!

Small Roblox prototype built around one decision:

**How much can you carry before the trip becomes too risky?**

## Milestone 1.1 — Make Greed Dangerous

The gray-box map is still generated at runtime. This revision is specifically testing whether the player hesitates before taking another item.

Current loop:

1. Spawn beside the open grocery car.
2. Grab as many groceries as you want.
3. Each item raises weight and increases the payout multiplier.
4. Press **START TRIP**.
5. Walk to the front door.
6. Heavy loads build balance strain while moving.
7. Sharp turns, jumping, obstacles, and steps add balance spikes.
8. Stop moving to recover.
9. Reach 100% balance and the groceries explode off the character.
10. Reach the door and bank the payout.

## Milestone 1.1 PASS criteria

The prototype passes only if:
- 1–2 light items feel safe.
- A medium load makes the player pay attention.
- A full load is possible but genuinely dangerous.
- Obstacles and sharp turns matter.
- Stopping to recover feels like a deliberate tactic.
- The payout jump makes taking another item tempting.
- At least once, the tester hesitates before taking the final item.

Still intentionally excluded:
- saving
- upgrades
- rarity
- final map art
- final grocery models
- monetization
- final UI
