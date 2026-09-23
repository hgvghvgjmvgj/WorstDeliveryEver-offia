# ONE TRIP — M5B.1 PLAYTEST

## Scope

This gate validates **natural capability progression** only.

Do not start M5C until this passes.

M5A geometry remains locked. Normal sections remain physically open. Rarity remains primarily economic/visual.

---

## A. Handling architecture

Each M5 item exposes:

- Weight
- Bulk
- ShapeTag
- Handling.Strength
- Handling.CarrySpace
- Handling.Control

The server evaluates the worst requirement ratio across Strength / Carry Space / Control after also considering the full current pile's Weight, Bulk, shape mix, and raw Base Instability.

Bands:

- READY: ratio >= 0.97
- RISKY: ratio >= 0.82
- DANGEROUS: ratio >= 0.65
- UNMANAGEABLE: ratio < 0.65

RISKY and DANGEROUS stay skill-permissive.

UNMANAGEABLE applies a persistent instability/pressure deficit and a readable grip-failure timer. Standing still can reduce Current Sway, but it cannot erase the underlying handling deficit. If the load remains UNMANAGEABLE for roughly 2.35–3.8 seconds, the most recently added/top cargo is permanently lost through the existing collapse-loss presentation path.

---

## B. Rig summary

Rig is derived from the real handling stats. It is not used as the gameplay gate.

| Rig | Strength | Carry Space | Control |
|---|---:|---:|---:|
| Starter | 15 | 13 | 1.00 |
| Rig I | 17 | 15 | 1.10 |
| Rig II | 19.5 | 17.5 | 1.22 |
| Rig III | 22.5 | 20.5 | 1.35 |
| Rig IV | 26 | 24 | 1.50 |
| Rig V | 30 | 28 | 1.67 |

Mobility is intentionally excluded.

Section guidance:

| Section | Recommended summary |
|---|---|
| Receiving | Starter |
| Appliances | Rig I |
| Furniture | Rig II |
| Heavy Goods | Rig III |
| Industrial | Rig IV |
| Secure | Rig V |

These are guidance milestones, not doors.

---

## C. Current handling target ranges

| Section | Strength | Carry Space | Control |
|---|---:|---:|---:|
| Receiving | 9–16 | 8–14 | ~0.90–1.17 |
| Appliances | 13–20 | 11–17 | ~0.98–1.25 |
| Furniture | 14–25 | 12–18.5 | ~1.02–1.41 |
| Heavy Goods | 18–30 | 13–20 | ~1.08–1.41 |
| Industrial | 24–35 | 17–25 | ~1.20–1.61 |
| Secure | 27–38 | 19–29 | ~1.34–1.80 |

The upper Control values include shape/hero adjustments. Rarity variants of the same base object keep the same physical handling profile.

---

## D. Representative objects

Static expected Starter state; runtime still must be verified in Studio.

| Section | Item | Weight | Bulk | Shape | Req Strength | Req Space | Req Control | Starter expected |
|---|---|---:|---:|---|---:|---:|---:|---|
| Receiving | Shipping Box | 1 | 1 | Compact | 10.5 | 9.5 | 0.94 | READY |
| Receiving | Office Chair | 2 | 2 | Wide | 12 | 10.5 | 1.03 | READY |
| Receiving | Golden Pallet Jack | 4.5 | 4.5 | Wide | 16 | 14 | 1.17 | RISKY |
| Appliances | Microwave | 2 | 2 | Compact | 15 | 13 | 1.05 | RISKY |
| Appliances | Refrigerator | 5.5 | 4 | Tall | 18.5 | 15.5 | 1.18 | DANGEROUS |
| Appliances | Prototype Smart Fridge | 7 | 4.5 | Tall | 20 | 16 | 1.25 | DANGEROUS |
| Furniture | Armchair | 3 | 4 | Wide | 17 | 14.5 | 1.19 | RISKY |
| Furniture | Couch | 4 | 6.5 | Wide | 18 | 16 | 1.26 | DANGEROUS |
| Furniture | Upright Piano | 8.5 | 7.5 | Wide | 22 | 16.5 | 1.30 | DANGEROUS |
| Furniture | Royal Grand Piano | 11.5 | 11 | Wide | 25 | 18.5 | 1.41 | UNMANAGEABLE |
| Heavy | Commercial Safe | 7.5 | 2 | Compact | 23.5 | 15 | 1.21 | UNMANAGEABLE |
| Heavy | Generator | 9 | 3.5 | Compact | 24.5 | 16.5 | 1.24 | UNMANAGEABLE |
| Heavy | Titan Vault Safe | 16.5 | 6 | Compact | 29.5 | 19 | 1.41 | UNMANAGEABLE |
| Industrial | Engine Block | 12.5 | 3.5 | Compact | 29.5 | 20 | 1.39 | UNMANAGEABLE |
| Industrial | Production Machine | 22.5 | 8.5 | Wide | 34 | 24.5 | 1.61 | UNMANAGEABLE |
| Industrial | Experimental Reactor Core | 21.5 | 8 | Tall | 33.5 | 24 | 1.61 | UNMANAGEABLE |
| Secure | Luxury Display Case | 9 | 5 | Tall | 30.5 | 23.5 | 1.57 | UNMANAGEABLE |
| Secure | High-Security Case | 10.5 | 4 | Compact | 31 | 22.5 | 1.49 | UNMANAGEABLE |
| Secure | Executive Vault Unit | 21 | 6.5 | Compact | 35.5 | 25 | 1.65 | UNMANAGEABLE |
| Secure | Black-Project Containment Unit | 26.5 | 10 | Tall | 37.5 | 28 | 1.80 | UNMANAGEABLE |

---

## E. Upgrade impact examples

Static expected single-item progression:

### Microwave
Starter RISKY -> Rig I READY.

### Refrigerator
Starter DANGEROUS -> Rig I RISKY -> Rig II READY.

### Couch
Starter DANGEROUS -> Rig I/Rig II RISKY -> Rig III READY.

### Commercial Safe
Starter UNMANAGEABLE -> Rig I DANGEROUS -> Rig II/Rig III RISKY -> Rig IV READY.

### Engine Block
Starter/Rig I UNMANAGEABLE -> Rig II/Rig III DANGEROUS -> Rig IV RISKY -> Rig V READY.

### Luxury Display Case
Starter/Rig I/Rig II UNMANAGEABLE -> Rig III DANGEROUS -> Rig IV RISKY -> Rig V READY.

The largest Industrial/Secure hero objects intentionally remain challenging even at their section's recommended summary tier.

---

## F. Player-facing guidance

Existing M5A section signs are changed locally per player to show:

- section name
- recommended rig
- current rig
- READY / CAUTION / HEAVY CARGO AHEAD

Nearby loot shows a temporary contextual card:

- rarity + item name
- SELL value
- READY / RISKY / DANGEROUS / UNMANAGEABLE
- main weakness: Strength / Carry Space / Control

No collapse probability is shown.

The top handling card shows current Rig and the approximate stats needed for the next Rig milestone.

---

# REQUIRED STUDIO TESTS

## 1. Fresh starter check

M5B.1 uses the temporary DataStore:

`OneTripPlayerData_M5B_1HandlingTest_v1`

Expected fresh profile:

- Strength 15
- Carry Space 13
- Control 1.00
- HandlingRigTier 0 / STARTER

If the profile is not fresh, stop the test.

## 2. Starter section sequence-break

Walk into every section. Do not buy upgrades.

Test at least 3 items per section.

Expected broad result:

- Receiving: mostly READY
- Appliances: possible, mostly RISKY/DANGEROUS for larger cargo
- Furniture: RISKY/DANGEROUS; biggest cargo can be UNMANAGEABLE
- Heavy: mostly DANGEROUS/UNMANAGEABLE
- Industrial: mostly UNMANAGEABLE
- Secure: economically important cargo should generally be UNMANAGEABLE

Record exceptions.

## 3. UNMANAGEABLE single-item test

Force or find:

`BlackProjectContainmentUnit__Eternal`

Starter expected:

- UNMANAGEABLE
- weakness visible
- movement strongly reduced
- persistent wobble / pressure
- GRIP FAILING notice
- item lost after short readable struggle if handling remains insufficient

Standing still must not save it indefinitely.

## 4. Stop/start cheese test

With one UNMANAGEABLE item:

move -> stop -> wait -> move -> stop -> wait

Repeat.

PASS only if the handling deficit persists and the cargo still grip-fails.

## 5. Slight sequence-break test

Use an object showing RISKY or DANGEROUS rather than UNMANAGEABLE.

Try to bring it home carefully.

PASS if skilled movement can sometimes succeed.

## 6. Current-pile test

Find one object that is READY/RISKY by itself.

Build a meaningful pile first, then preview/grab the same archetype.

PASS if the additional pile can worsen the handling band.

## 7. One-section-ahead test

Approximate Section N's recommended Rig, then enter N+1.

PASS if lighter N+1 items are possible while harder ones remain RISKY/DANGEROUS/UNMANAGEABLE.

## 8. Two-sections-ahead test

Attempt N+2 with the same build.

PASS if most meaningful cargo is DANGEROUS/UNMANAGEABLE and deep farming is not the rational route.

## 9. Specialization test

Use equivalent investment with three builds:

- Strength-heavy
- Carry Space-heavy
- Control-heavy

PASS if:

- Strength build favors safes/generators/machinery
- Space build favors couches/wardrobes/oversized piles
- Control build favors Tall/Wide/mixed awkward loads

## 10. Upgrade impact

Record an object's band.

Buy relevant upgrades.

Retest the same object.

PASS if statuses visibly improve over meaningful upgrade steps.

## 11. Rarity sanity

Test the same base archetype at Common and Eternal.

PASS if Weight/Bulk/Handling requirements remain the same while economy/visual prestige changes.

## 12. Deep value-per-difficulty exploit

As a Starter, deliberately hunt for the best Secure/Industrial value relative to handling difficulty.

FAIL if a repeatable light/high-value object lets Starter reliably outperform intended early play.

## 13. Huge-pile test

With a properly progressed player, build a huge pile in the appropriate section.

PASS if greed still creates danger. Progression must move the frontier; it must not remove the frontier.

---

## Debug attributes

On the Player while carrying:

- HandlingBand
- HandlingWeakness
- HandlingRatio
- HandlingRequiredStrength
- HandlingRequiredCarrySpace
- HandlingRequiredControl
- HandlingBaseInstabilityBonus
- HandlingInstabilityFloor
- HandlingSwayMultiplier
- HandlingRecoveryMultiplier
- HandlingMovementMultiplier
- HandlingStrainFloor
- HandlingGripRemaining
- CarryRawBaseInstability
- HandlingRigTier
- HandlingRigName

These are developer telemetry only.

---

## Map decision

No M5A macro geometry was changed for M5B.1.

Only patch map geometry later if playtesting proves a shortcut/placement/transition materially breaks natural handling progression.

---

## Phase gate

Do not start M5C until the project lead reviews:

1. Starter section distribution
2. stop/start exploit
3. single-item deep exploit
4. one/two-section-ahead overlap
5. specialization
6. upgrade impact
7. deep value-per-difficulty farming

Runtime results are required; static expectations alone do not pass M5B.1.
