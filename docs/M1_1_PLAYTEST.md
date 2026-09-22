# ONE TRIP - M1.1 Core Feel Playtest

M1.1 is not allowed to pass because the scripts run. It passes only if the primitive build creates greed, escalation, tension, agency, relief, and retry desire.

## Setup

1. Sync the latest `main` through Rojo.
2. Press Play.
3. Confirm Output shows:
   - `[ONE TRIP] M1.1 core feel prototype loaded`
   - `[ONE TRIP] M1.1 client loaded`
4. Leave F3 debug OFF for the first several runs.
5. Use F3 only after judging the visual/physical feedback naturally.

## Round A - Conservative

Take roughly 2-4 low-risk objects and unload.

Look for:
- GRAB feels immediate.
- Objects visibly fly/snap into the pile instead of teleporting dead.
- The pile already looks less tidy than M1.
- Normal movement feels easy.
- Delivery gives a small but clear release.

FAIL if even this feels sluggish or annoying.

## Round B - Slight greed

Build around 5 mixed objects.

Look for:
- stack height/silhouette has clearly escalated.
- upper layers lag behind movement.
- you notice wobble without opening F3.
- you begin steering a little more carefully.

FAIL if movement strategy is unchanged from Round A.

## Round C - Ridiculous pile

Push toward 6+ mixed objects.

Look for:
- pile looks stupid from normal camera distance.
- sharp starts/stops/turns visibly affect upper layers.
- smooth movement is noticeably safer.
- stopping visibly settles motion but the pile still looks inherently bad.

FAIL if holding W is still the obvious strategy.

## Round D - Late heavy temptation

Build a meaningful pile, then grab the Safe near the route home.

Look for:
- Safe pickup feels heavier than Box pickup.
- weight slowdown becomes obvious.
- Base Instability jumps.
- you genuinely consider skipping it.

Compare the same Safe early in a run.

FAIL if early Safe and late Safe feel basically identical.

## Round E - Shape comparison

Compare these choices late in runs:

### Lamp
Light but tall. It should make a high stack visually worse.

### Couch
Bulky and wide. It should protrude and make turns more uncomfortable.

### Safe
Heavy and compact. It should hit movement/weight hard, especially when high.

### Box
Should remain the boring/safer baseline.

FAIL if the four objects produce the same instinct.

## Round F - Near collapse and recovery

Create a dangerous pile and make one aggressive turn.

When the warning hits:
1. release movement or move carefully.
2. watch upper layers.
3. try to recover.

Look for:
- obvious visual "OH SHIT" state.
- top layers shift farther than bottom layers.
- stopping settles Current Sway.
- successful recovery gives a small "SAVED IT" relief moment.

FAIL if recovery is only understandable through debug numbers.

## Round G - Collapse

Repeat Round F but keep moving aggressively.

Look for:
- warning occurs before failure.
- upper portion drops rather than entire run disappearing.
- dropped items scatter down through controlled pseudo-physical motion.
- moment is painful but funny/readable.
- you want to recover/try again instead of quitting.

FAIL if objects simply vanish or collapse feels random.

## Round H - Big success

Build the largest pile you can reasonably bring home.

Unload it.

Look for:
- carried objects animate rapidly into the unload point.
- score burst and short camera response create DANGER -> MADE IT release.
- your immediate instinct is to attempt a bigger pile.

## Decision gate

M1.1 passes only if the following are present without relying on F3:

- GREED: "I want another item."
- ESCALATION: "This pile is getting ridiculous."
- TENSION: "I might lose this."
- AGENCY: "How I move matters."
- RELIEF: "I made it."
- RETRY: "I want to try something stupider."

If one or more are clearly missing, report exactly which emotion is missing and what happened in the run. Do not begin M2.
