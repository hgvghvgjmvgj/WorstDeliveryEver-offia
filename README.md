# GET IT IN!

A solo-complete social Roblox moving game about forcing absurd oversized objects through spaces that look too small for them.

## Current status

- Core carry mechanic: PASS
- Mobile controls: PASS
- Core loop: PASS
- Puzzle variety proof: PASS
- Basic economy proof: PASS
- Saving: PASS
- Visual direction: PASS
- **M6.5 independent multi-job architecture: CURRENT TEST**

## M6.5 — Multi-job architecture reset

The old server architecture had one global active object, one global contract index, and one global holder. That meant the entire server effectively shared one job.

M6.5 replaces that with **independent job state per player**.

### Current proof

The map now has four functional job sites.

Each assigned player gets their own:
- plot
- furniture object
- challenge geometry
- success zone
- current contract index
- rotate / tilt state
- holder state
- completion state

Player A completing or moving their furniture should not change Player B's job.

### Why only four sites right now?

This milestone is proving the architecture, not the final server capacity.

Once two or more simultaneous jobs pass cleanly, we can scale the same plot system to more sites and add waiting/HQ behavior for larger servers.

## Vehicle direction — locked for later

The longer-term loop is now:

**Moving Company HQ -> choose contract -> get vehicle -> travel to job site -> solve move -> get paid -> return / take next job**

Vehicle progression can become a meaningful money sink:
- starter van
- larger box truck
- faster vehicle
- cosmetic paint/wheels/company branding
- specialized trucks that unlock multi-item or heavy contracts

The vehicle should support the moving fantasy, not become a separate driving simulator.

### Map size strategy

Do **not** build the final giant map before vehicles exist.

Current town footprint is large enough to prove multiple simultaneous jobs.

After the vehicle system works, expand outward with:
- new suburbs
- townhouses
- apartments
- commercial district
- wealthy district
- special-event job sites

That creates update-friendly map expansion without forcing players to walk long empty distances.

## M6.5 PASS test

Use Roblox Studio multiplayer test with at least 2 players.

PASS if:
1. Player 1 is assigned one job site.
2. Player 2 is assigned a different job site.
3. Both players see their own furniture.
4. Player 1 can grab/rotate/tilt their furniture.
5. Player 2 can do the same at the same time.
6. Moving Player 1's object does not move Player 2's.
7. Completing Player 1's contract does not advance Player 2's contract.
8. Each player receives only their own payout.
9. Saving still works.
10. Leaving frees the plot for a future player.

Do not judge contract selection, reputation, vehicles, polished UI, co-op helping, or final map size yet. Those come after coexistence passes.
