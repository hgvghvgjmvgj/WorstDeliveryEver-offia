# ONE TRIP — M6B SECTIONS 1–3 VISUAL PROOF

## Scope lock
M6B is intentionally stopped at:
1. Receiving & Returns
2. Home Basics
3. Appliances

Sections 4–15 remain graybox. Do not scale the M6B treatment farther until this proof passes player-height screenshot review.

## Signless comparison
To test whether the departments read without labels, set this BEFORE Play:
```lua
workspace:SetAttribute("M6BHideSectionSigns", true)
```
Set it back to false for normal testing.

## What changed

### Receiving & Returns
Target read: busy / industrial / high-throughput / ordinary.

Implemented:
- chunky pallet racks on outer opportunities;
- lower package/sorting shelves on inner storage opportunities;
- open intake/staging pallets on focal opportunities;
- pallet stacks and parcel bins;
- tall industrial truss rhythm;
- neutral functional overhead light;
- cardboard/blue/yellow/industrial palette.

### Home Basics
Target read: warmer / familiar / friendly / household storage.

Implemented:
- lower warm wood shelves;
- open small-furniture pockets at focal positions;
- domestic storage bins;
- warm side-floor pockets;
- lower overhead beam rhythm;
- warmer department lighting;
- cream/wood/orange/muted-green palette.

### Appliances
Target read: larger / cleaner / heavier / more organized.

Implemented:
- larger spawn platforms;
- tall reinforced appliance frames;
- open focal appliance bays;
- cleaner light side-floor treatment;
- highest overhead structure of Sections 1–3;
- cool department lighting;
- white/silver/slate/cool-blue language.

## Main freight lane
Sections 1–3 now share a continuous fast-route language:
- clean lane-edge stripes around the 38-stud freight route;
- repeated subtle center rhythm marks;
- no decorative obstacles added to the central lane.

The route should read as the fastest/shared social path without giant arrows.

## Rig I gate correction
The first gate no longer uses a giant translucent red slab.

Current treatment:
- neutral dark industrial posts and arch;
- scanner housings;
- thin amber/red scanner strips when locked;
- thin green scanner strips when cleared;
- visible RIG I REQUIRED / CLEARED label;
- full invisible collision remains authoritative;
- future Appliances content remains visible through the structure.

## Representative cargo proof
The following base cargo now has additional recognizable stylized geometry beyond generic ModelKind treatment.

### Receiving
- Shipping Box — tape + parcel label
- Toolbox — lid + chunky handle
- Suitcase — wheels + pull handle
- Office Chair — stem + feet

### Home Basics
- Desk Lamp — base + stem
- Dining Chair — four simplified legs
- Countertop Oven — glass window + knobs
- Home Storage Shelf — visible shelf boards

### Appliances
- Refrigerator — split doors + chunky handles + display
- Washer — round washer door + control panel
- Television — twin feet
- Oven Range — cooktop + control knobs

These are visual-proof assets, not a claim that all cargo in Sections 1–3 is final.

## Restock readability
Only Sections 1–3 currently receive M6B storage slots.

When cargo leaves:
- its platform/bay remains;
- vacancy light remains visible;
- restock pulses the slot light;
- focal opportunities remain normal RNG positions, not guaranteed rare shelves.

## Screenshot gate
Do not continue to Section 4 before reviewing all four:

A. Player-height from Receiving looking deeper.
B. Player-height inside Home Basics.
C. Player-height inside Appliances.
D. Aerial/angled shot showing all three together.

For the strongest test, repeat A–D once with `M6BHideSectionSigns = true`.

## Pass questions
Without reading signs:
- Does Receiving look like warehouse intake?
- Does Home Basics look like household goods storage?
- Does Appliances look like large appliance storage?
- Does the freight lane remain visually obvious?
- Can a large pile still turn through side storage?
- Are Rare+ items visible from useful sightlines?
- Is the Rig I gate a checkpoint rather than a red wall?

## Performance notes to record
Check:
- client FPS at player height in each department;
- mobile emulator camera clipping;
- Speed 88 freight-lane traversal;
- large-pile turning in side storage;
- whether the six strategic department PointLights cause any noticeable cost.

## Current recommendation
Runtime screenshot review required. The implementation deliberately does NOT authorize Sections 4–15 yet.
