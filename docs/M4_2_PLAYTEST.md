# ONE TRIP — M4.2 FINAL PASSIVE ECONOMY PLAYTEST

M5 is NOT started. This gate validates only passive Stock, SELL/KEEP decisions, and offline-income sanity.

## Reference active economy

Use approximately **$17.5K/min** as the current early active reference from M4.1. Do not force runtime results to match this exact number; use it as a comparison baseline.

## Current M4.2 item economy

| Item | SELL | Passive/min | Break-even | Weight | Bulk | Economic tier |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Box | $900 | $400 | 2.25m | 1 | 1 | Weak |
| Lamp | $1,680 | $500 | 3.36m | 1 | 1 | Weak |
| Microwave | $2,240 | $650 | 3.45m | 2 | 2 | Early |
| Tire | $3,600 | $850 | 4.24m | 2 | 1 | Early |
| Chair | $4,800 | $1,000 | 4.80m | 2 | 2 | Early |
| TV | $9,000 | $1,300 | 6.92m | 3 | 2 | Strong |
| Couch | $16,800 | $1,700 | 9.88m | 3 | 4 | Strong |
| Safe | $24,000 | $2,000 | 12.00m | 6 | 2 | Exceptional |

### Known design tension

The requested 3-slot passive bands and the requested 10–20 minute ordinary-item break-even cannot both coexist while preserving the already-measured active SELL economy. For example, a weak $1.5K/min three-item Stock setup would need roughly $15K–$30K of combined SELL sacrifice to break even in 10–20 minutes. That would substantially increase active SELL income if those same early items remain common warehouse loot.

M4.2 therefore preserves the M4.1 SELL values and tests whether M4.1 scarcity + limited Stock slots + immediate-Cash progression keep short low-tier break-even from making KEEP automatic. If low-tier KEEP becomes obviously dominant in runtime, report it rather than hiding the conflict.

## Old vs new passive

| Item | M4.1 passive/min | M4.2 passive/min |
| --- | ---: | ---: |
| Box | $150 | $400 |
| Lamp | $240 | $500 |
| Microwave | $320 | $650 |
| Tire | $450 | $850 |
| Chair | $600 | $1,000 |
| TV | $900 | $1,300 |
| Couch | $1,400 | $1,700 |
| Safe | $2,000 | $2,000 |

## Required 3-slot setups

### Weak

Box + Lamp + Microwave

- Passive: **$1,550/min**
- % of $17.5K active reference: **8.9%**
- Immediate SELL sacrifice: **$4,820**
- Effective combined break-even: **3.11 min**
- 30-minute capped offline payout: **$46,500**

### Average

Microwave + Tire + Chair

- Passive: **$2,500/min**
- % of $17.5K active reference: **14.3%**
- Immediate SELL sacrifice: **$10,640**
- Effective combined break-even: **4.26 min**
- 30-minute capped offline payout: **$75,000**

### Strong

Chair + TV + Couch

- Passive: **$4,000/min**
- % of $17.5K active reference: **22.9%**
- Immediate SELL sacrifice: **$30,600**
- Effective combined break-even: **7.65 min**
- 30-minute capped offline payout: **$120,000**

### Exceptional

Safe + Safe + Safe

- Passive: **$6,000/min**
- % of $17.5K active reference: **34.3%**
- Immediate SELL sacrifice: **$72,000**
- Effective combined break-even: **12.00 min**
- 30-minute capped offline payout: **$180,000**

## Fresh-profile requirement

M4.2 uses the temporary DataStore namespace:

`OneTripPlayerData_M4_2PassiveTest_v1`

Expected fresh join:

- $0 Cash
- all normal progression at Level 1
- 3 Stock Slots
- no persisted Stock

Do not reuse M4.1 Stock for this test because persisted Stock stores the passive rate that existed when it was KEPT.

## Test A — fresh-player SELL vs KEEP

Play naturally from $0.

For the first several delivery reviews, note:

1. Weak item: is SELL still an acceptable/obvious choice when immediate Cash matters?
2. Decent item: does KEEP now create hesitation?
3. Strong item: does KEEP feel genuinely attractive?

FAIL if every item becomes an automatic KEEP.
FAIL if decent/strong items still feel pointless to KEEP.

## Test B — Cash-needed decision

Get close to an upgrade you actually want. Deliver an item whose SELL payout would immediately help buy it.

Ask whether you genuinely consider:

- SELL = progression now
- KEEP = permanent income later

SELL must remain useful.

## Test C — full Stock replacement

Fill all 3 slots.

Then deliver:

- an item slightly better than weakest Stock
- an item much better than weakest Stock
- an item worse than existing Stock

Expected:

- slightly better = debatable
- much better = replacement compelling
- worse = SELL usually obvious

Remember liquidation remains reduced salvage, not original full SELL.

## Test D — active + passive

With Average Stock, run warehouse trips for several minutes.

Record:

- `[ONE TRIP][M4 ECON TEST]` active $/min lines
- Stock passive/min
- approximate combined $/min

Repeat with Strong Stock if practical.

Passive should be noticeable, but active gameplay should remain the majority of normal income.

## Test E — offline income

Current temporary offline cap: **30 minutes**.

Test at least one meaningful absence with Average or Strong Stock.

Expected maximum base payouts at the cap:

- Weak: $46.5K
- Average: $75K
- Strong: $120K
- Exceptional: $180K

Verify:

- payout happens once
- immediate reconnect does not award it again
- returning feels rewarding
- payout does not make active progression irrelevant

## Test F — M4.1 regression sanity

M4.2 must not alter warehouse supply behavior.

Confirm briefly:

- consumed loot still leaves vacancies
- exact high-value spawn does not instantly reproduce
- warehouse still feels stocked
- carry/Load Pressure/collapse feel unchanged

## Pass questions

Before M5 review, answer:

1. Does average Stock now feel useful?
2. Does strong Stock feel like a meaningful accelerator?
3. Is SELL still attractive when Cash is needed now?
4. Does weak Stock pay back so quickly that you automatically KEEP it?
5. Does full-Stock replacement create real decisions?
6. Is active + Stock clearly better than idle Stock only?
7. Is the 30-minute offline cap too weak, good, or too generous?
8. Did M4.1 supply or carry behavior regress?

STOP after this playtest. Do not begin M5.
