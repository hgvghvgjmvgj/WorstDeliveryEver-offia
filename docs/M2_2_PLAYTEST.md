# ONE TRIP - M2.2 Warehouse + Load Pressure Playtest

M2.2 asks whether physical space now creates a real:

> Do I go deeper or go home?

decision without turning ONE TRIP into a walking simulator.

## Setup

1. Sync latest `main` through Rojo.
2. Confirm server Output prints: `[ONE TRIP] M2.2 warehouse and Load Pressure foundation loaded`.
3. Confirm clients print: `[ONE TRIP] M2.2 client loaded`.
4. Test solo first for route/readability.
5. Then test 4 players.
6. Then test 12 players.

## Test A - New player route

Spawn fresh.

Without instructions verify:
- your own bay is visually obvious
- the bay opens directly toward the shared warehouse
- Near goods are immediately discoverable
- floor/sign organization makes deeper areas legible
- you are not lost in the first five seconds

## Test B - Near run

Take only Near / General Goods.

Expected:
- fast collection
- short return
- relatively safe
- Load Pressure usually low/negligible unless you deliberately overload

Measured normal-speed nearest-stock route: about 4.4-7.2 seconds.

## Test C - Deep run

Travel to Deep / High Value Test stock.
Take heavier/higher-value prototype goods.
Return to your bay.

Expected:
- the outward trip is noticeable but not boring
- a loaded return has enough duration for Load Pressure to matter
- the player feels the difference between taking something near and taking a Safe deep

Measured route from bay unload to Deep stock:
- normal speed: about 9.2-10.1 seconds
- current minimum heavily-loaded speed: about 15.6-17.0 seconds

## Test D - Greed decision

Build a moderate pile in Mid Warehouse.
Look toward Deep stock.

Observe whether you genuinely consider:

> return now

versus

> go deeper for better stuff.

FAIL if going Deep is always obviously correct.
FAIL if Deep is never tempting.

## Test E - 12 players

With 12 clients observe:
- central/deep traffic
- bay entrances
- item competition
- congestion
- sightlines
- collapse visibility
- unload visibility
- performance

Expected:
- other piles remain easy to notice
- paths are wide enough for giant stacks
- no player collision griefing
- central convergence feels social rather than jammed
- bays remain visible/personal without becoming isolated plots

## Test F - Large stacks

Use Veteran-sized exaggerated piles.

Verify:
- open floor routes work
- 46-stud clearance reference is comfortably above normal giant piles
- camera is not trapped
- bay entrance accepts ridiculous stacks
- processing/unload area is immediately reachable on return
- stock-display pads do not obstruct delivery

## Test G - Bay visibility and stock foundation

Inspect several bays from shared warehouse space.

Expected:
- owner label is readable when near enough
- bay is visually open
- three initial stock/display positions are visible
- future slots 4-10 occupy reserved physical layout positions without being active
- van sits behind display space instead of consuming it
- other players could eventually flex visible stocked rare items here

Do NOT expect selling or stock timers yet.

## Test H - Load Pressure UI

With F3 OFF test:
- small load
- medium overload
- huge overload
- stationary overloaded hold
- smooth return
- Critical pressure

Verify:
- LOAD PRESSURE bar appears while carrying
- player sees LOW / BUILDING / HIGH / CRITICAL
- exact percentage is never shown
- first actual pressure encounter can teach: LOAD PRESSURE BUILDS WHEN YOU CARRY TOO MUCH FOR TOO LONG.
- bar urgency increases while the pile also visibly struggles
- the player does not conclude that full bar equals deterministic instant collapse

Then enable F3 and confirm the bar corresponds to internal Strain while collapse still depends on the existing carry state.

## Test I - Item distribution

Compare voluntary choices across several runs.

Current prototype weighting:
- Near: 16 stock positions; average value about 39
- Mid: 12 stock positions; average value about 74
- Deep: 8 stock positions; average value about 93

Watch whether:
- new/safe runs use Near
- greedier runs enter Mid/Deep
- current pile state changes the chosen depth
- item availability creates route variation

## Test J - Performance

With 12 clients:
- repeatedly grab/restock all zones
- build large stacks
- cross through central areas
- trigger collapses
- unload simultaneously

Watch for:
- server errors
- stock duplication
- delayed reservations
- bay assignment failures
- major frame drops
- replicated stack lag
- excessive instance churn

## PASS

M2.2 passes when:
- Near/Mid/Deep feel meaningfully different
- Load Pressure is understandable without F3
- deeper reward creates real temptation
- loaded Deep returns feel consequential
- social visibility remains strong
- bays visibly support future resale/stock progression
- large stacks remain readable and navigable

## FAIL

Do not proceed if:
- bigger map merely feels emptier
- Deep is tedious travel padding
- all players always choose Deep
- nobody chooses Deep
- Load Pressure bar is mistaken for exact collapse probability
- bays feel like isolated houses
- future stock space blocks current delivery flow
- 12-player traffic destroys readability

Do not begin economy/progression until Project Lead approval.