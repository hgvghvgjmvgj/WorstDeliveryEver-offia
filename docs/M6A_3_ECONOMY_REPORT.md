# ONE TRIP — M6A.3 ECONOMY CORRECTION REPORT

## Status

Static/config implementation is complete. Runtime balance validation is still required before M6B final art.

The correction is designed around successful multi-item hauls, not single-item prices. Receiving remains in satisfying low-thousands; pacing is corrected primarily through stronger upgrade costs and a smoother 15-section value curve.

---

# 1. RIG COST CURVE

| Rig | Strength next cost | Carry Space next cost | Control next cost | Marginal Rig cost | Cumulative Rig cost |
| --- | ---: | ---: | ---: | ---: | ---: |
| RIG I | $1,200 | $1,100 | $2,200 | $4,500 | $4,500 |
| RIG II | $8,000 | $7,000 | $15,000 | $30,000 | $34,500 |
| RIG III | $40,000 | $35,000 | $75,000 | $150,000 | $184,500 |
| RIG IV | $180,000 | $160,000 | $310,000 | $650,000 | $834,500 |
| RIG V | $700,000 | $650,000 | $1,150,000 | $2,500,000 | $3,334,500 |

Post-Rig-V handling upgrades are also no longer cheaper than the milestone that came before them:

- Strength: $1.6M, then $3.5M.
- Carry Space: $1.5M, then $3.2M.
- Control: $2.4M, then $5.0M.

---

# 2. SPEED COST CURVE

| Speed | Upgrade cost |
| ---: | ---: |
| 20 | FREE |
| 28 | $2,500 |
| 38 | $12,000 |
| 49 | $60,000 |
| 61 | $250,000 |
| 74 | $1,000,000 |
| 88 | $4,000,000 |

This makes Speed a competing Cash decision rather than an automatic early max.

---

# 3. STOCK SLOT COST CURVE

| Capacity | Upgrade cost |
| ---: | ---: |
| 3 | FREE |
| 4 | $12,000 |
| 5 | $45,000 |
| 6 | $160,000 |
| 8 | $650,000 |
| 10 | $2,400,000 |

The Stock curve intentionally competes with the same broad progression bands as Rig and Speed.

Offline income remains capped at five minutes. The existing Stock break-even formula is unchanged for this pass because the corrected static model keeps full Common Stock income at roughly 12–18% of modeled active hauling at appropriate progression.

---

# 4. SECTION ECONOMY AUDIT

`EconomicScale` is now a compensating catalog multiplier rather than a progression score. It is intentionally non-monotonic in a few places because authored BaseSell values differ heavily by section. Actual resulting Common values are what must rise smoothly.

The table excludes hero-only objects from the Common averages. Rare = 1.6× Common economics and Legendary = 3.1× Common economics.

| # | Section | Scale | Common min | Common avg | Common max | Rare avg | Legendary avg | Ordinary haul model |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | Receiving & Returns | 1.00 | $900 | $1,517 | $2,300 | $2,427 | $4,702 | ~$4,550 / 3 items |
| 2 | Home Basics | 1.60 | $1,520 | $2,230 | $2,960 | $3,568 | $6,913 | ~$6,690 / 3 items |
| 3 | Appliances | 1.90 | $2,090 | $3,966 | $6,080 | $6,346 | $12,295 | ~$15,865 / 4 items |
| 4 | Furniture | 2.90 | $2,465 | $5,969 | $11,310 | $9,551 | $18,504 | ~$23,877 / 4 items |
| 5 | Electronics | 3.20 | $6,240 | $8,580 | $11,200 | $13,728 | $26,598 | ~$34,320 / 4 items |
| 6 | Recreation | 4.60 | $9,200 | $11,069 | $12,880 | $17,710 | $34,313 | ~$44,275 / 4 items |
| 7 | Garage & Auto | 5.25 | $11,025 | $15,028 | $18,375 | $24,045 | $46,587 | ~$75,141 / 5 items |
| 8 | Construction | 6.85 | $16,440 | $19,993 | $24,660 | $31,990 | $61,980 | ~$99,967 / 5 items |
| 9 | Heavy Equipment | 14.50 | $18,125 | $26,946 | $37,700 | $43,113 | $83,532 | ~$107,783 / 4 items |
| 10 | Industrial Machinery | 18.50 | $21,275 | $38,079 | $62,900 | $60,927 | $118,045 | ~$152,317 / 4 items |
| 11 | Premium Interiors | 16.00 | $44,000 | $51,600 | $62,400 | $82,560 | $159,960 | ~$258,000 / 5 items |
| 12 | Luxury Goods | 17.80 | $56,960 | $69,865 | $83,660 | $111,784 | $216,582 | ~$349,325 / 5 items |
| 13 | Art & Collectibles | 20.70 | $80,730 | $94,961 | $115,920 | $151,938 | $294,380 | ~$474,806 / 5 items |
| 14 | Secure Vault | 50.00 | $80,000 | $132,917 | $210,000 | $212,667 | $412,042 | ~$664,583 / 5 items |
| 15 | Restricted / Prototype | 28.50 | $136,800 | $172,781 | $216,600 | $276,450 | $535,622 | ~$863,906 / 5 items |

The important result is that average Common value now increases section-to-section. The old accidental cliffs/non-monotonic averages at Furniture, Heavy Equipment, Industrial and Secure are removed.

---

# 5. MODELED ACTIVE HAUL / MINUTE

This is a pre-runtime model only, not telemetry.

Assumptions:

- use the ordinary haul counts in the section table;
- use the minimum Speed tier appropriate to the section's Rig band: 20 / 28 / 38 / 49 / 61 / 74;
- modeled loaded return speed = 72% of unloaded Speed;
- pickup/decision time = 10 seconds + 6 seconds per modeled item;
- route distance uses the current 15-section runway center distance.

| Section | Modeled active SELL-equivalent / min |
| --- | ---: |
| Receiving | ~$8.4K/min |
| Home Basics | ~$10.1K/min |
| Appliances | ~$19.9K/min |
| Furniture | ~$29.6K/min |
| Electronics | ~$39.0K/min |
| Recreation | ~$46.2K/min |
| Garage & Auto | ~$72.7K/min |
| Construction | ~$90.9K/min |
| Heavy Equipment | ~$100.6K/min |
| Industrial Machinery | ~$147.5K/min |
| Premium Interiors | ~$215.7K/min |
| Luxury Goods | ~$276.6K/min |
| Art & Collectibles | ~$390.5K/min |
| Secure Vault | ~$520.1K/min |
| Restricted / Prototype | ~$642.2K/min |

Real gameplay should be slower because this model does not price in failed runs, detours, contested loot, hesitation, partial collapse, KEEP decisions or imperfect pile building.

---

# 6. PASSIVE VS ACTIVE STATIC CHECK

Using section-average Common Stock, the Stock capacity expected around each progression band, and the unchanged break-even formula, a full Common Stock board models at roughly:

- Starter: ~16–18% of active hauling.
- Rig I: ~15%.
- Rig II: ~13–15%.
- Rig III: ~12%.
- Rig IV: ~12–15%.
- Rig V: ~14%.

This is a healthy first-pass relationship: Stock matters, but ordinary passive income is not the fastest path through the Rig ladder. Higher-rarity Stock can be significantly stronger, as intended, but consumes the same limited slots and sacrifices immediate progression Cash.

---

# 7. STATIC TARGET TRIP COUNTS

Using the deepest ordinary section in each currently accessible progression band as a deliberately optimistic reference:

| Next Rig | Marginal cost | Reference haul | Static ordinary trips |
| --- | ---: | ---: | ---: |
| RIG I | $4,500 | Receiving ~$4,550 | ~1.0 |
| RIG II | $30,000 | Appliances ~$15,865 | ~1.9 |
| RIG III | $150,000 | Recreation ~$44,275 | ~3.4 |
| RIG IV | $650,000 | Heavy Equipment ~$107,783 | ~6.0 |
| RIG V | $2,500,000 | Luxury Goods ~$349,325 | ~7.2 |

These align with the requested first-pass pacing before runtime penalties/choices:

- Rig I: 1–2 normal trips.
- Rig II: roughly 2–4 additional productive trips.
- Rig III: roughly 3–6.
- Rig IV: roughly 5–8.
- Rig V: roughly 6–10+.

A lucky rarity should reduce these counts. One ordinary non-exceptional haul after Rig I should not normally purchase all three upgrades for the following Rig.

---

# 8. SUPPLY INTEGRATION CORRECTION

The old central supply controller treated:

- <= $4,999 as Ordinary;
- <= $11,999 as Strong;
- everything above as High.

That was calibrated for the small M4 economy. Under the corrected 15-section values it would make ordinary late cargo use premium vacancy timing.

M6A.3 test bands are now:

- Ordinary: <= $149,999;
- Strong: <= $399,999;
- High: > $399,999.

Legendary+ rarity caps/cooldowns remain owned by `LootRarityService`; this change only prevents the old absolute-value supply system from starving normal deep cargo.

---

# 9. PLAYER-FACING NEXT-RIG PROGRESS

The handling HUD now shows the exact next Rig costs instead of only stat deltas.

Example:

```text
CURRENT RIG II   →   NEXT RIG III
STRENGTH $40K   |   SPACE ✓   |   CONTROL $75K
```

A specialized player therefore always knows which of the three handling requirements is still blocking clearance.

---

# 10. FRESH TEST PROFILE

Data namespace for this balance pass:

```text
OneTripPlayerData_M6A_3EconomyTest_v1
```

The previous M6A.2 runway-test namespace remains untouched.

---

# 11. TELEMETRY TO RECORD

The test build now exposes/prints:

- `DevSuccessfulHauls`
- `DevLastDeliveryItems`
- `DevLastDeliverySellPotential`
- `DevFirstSellSeconds`
- `DevRig1UnlockSeconds` ... `DevRig5UnlockSeconds`
- `DevRig1UnlockHauls` ... `DevRig5UnlockHauls`
- `DevLastTripSeconds`
- `DevLastTripItems`
- `DevLastTripSellPotential`
- `DevLastTripPotentialCashPerMinute`
- `DevLastTripAdjustedCashPerMinute`
- `DevCurrentPassiveRate`
- `DevLastTripPassiveToActiveRatio`

For the cleanest active-income sample, resolve a Delivery Review with SELL ALL. KEEP runs are real gameplay but should be evaluated separately because they deliberately exchange immediate Cash for Stock.

---

# 12. REQUIRED RUNTIME GATE

Do not lock these test values or begin M6B until a fresh profile verifies:

1. Rig I remains quick and satisfying.
2. Rig II requires real early-game hauling.
3. Rig III cannot normally chain immediately after Rig II.
4. Rig IV feels like a substantial milestone.
5. Rig V feels like true late-game access.
6. A normal haul after Rig I does not normally purchase the complete next Rig.
7. Lucky rarities accelerate progression without routinely skipping multiple Rig bands.
8. Within-band deeper sections are not effortlessly farmable immediately after unlock.
9. Speed purchases create real tradeoffs with Rig progress.
10. Stock purchases create real tradeoffs with Rig/Speed.
11. KEEP has visible opportunity cost.
12. Passive income helps but does not dominate active hauling.
13. Supply remains healthy across all 15 sections.
14. Progression gets harder without becoming repetitive or miserable.
15. Runtime telemetry replaces these static assumptions before final balance lock.
