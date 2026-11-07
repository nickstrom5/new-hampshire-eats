# Granite State Eats: name, icon and palette (final: Nick's decisions, 2026-11-07)

Final (Nick, 2026-11-07, "Yes, as proposed" on the 17-state review): the name and App Store subtitle as in
`playbook/app-store/listing.json`, icon concept A, the pancake stack, and the palette as built (below).

## Name
- **Granite State Eats** (App Store name "Granite State Eats: NH", 22 characters, since "…: New Hampshire" is 33 and Apple allows 30;
  "new hampshire" is in the keywords instead. Home Screen "Granite State Eats", 18, which may truncate under the icon on smaller
  iPhones). "The Granite State" is New Hampshire's nickname. A web search (2026-11-06) found no app,
  guide, show or blog called "Granite State Eats"; the prompt found granitestateeats.com unregistered (RDAP). "Granite State" is a
  crowded nickname in business names (a candy shop, a credit union, a college, an Exeter hot dog cart), so Nick approved the name on
  2026-11-07; no USPTO search was run.
- Alternatives from the prompt: **New Hampshire Eats** (newhampshireeats.com unregistered; 18 characters, the same truncation) and
  **603 Eats** (short, but 603eats.com was registered in November 2025).
- Avoided: the state motto "Live Free or Die", Visit NH's taglines, the Old Man of the Mountain, the state seal and flag, team names and
  marks.
- Bundle id `com.newhampshireeats.ios`; site nickstrom5.github.io/new-hampshire-eats/ until a `newhampshire.eatsranked.com` record exists.

## Icon (state-prompts/ICON-STYLE.md)
- **A, Nick's choice (2026-11-07): a short stack of three pancakes with a maple-syrup drip and a pat of butter**, side view, on granite. Passes
  check.swift; reads as pancakes at 60 px, and ties to the pancake-house guide and the sugar houses.
- B: an apple cider donut with one leaf. Passes; at 60 px it reads as any donut.
- C: a basket of chicken tenders (the invention claim is Manchester's Puritan Backroom's own). Passes; at 60 px the tenders read as
  fries.
Drawn by `scripts/icon-concepts.swift` (PNGs in `playbook/brand/`); `scripts/make-brand.swift` makes the app icon, site icons and
docs/og.png from A.

## Palette (the prompt's landscape option; no team colors or marks)
Granite #3E4A52 (9.2:1 on white; the prompt's #5E6A71 deepened so titles read at small sizes) for titles and tint; foliage orange
#B5471B (white on it 5.4:1) for the hand-checked guide cards and focus rings; lilac #6A4C93 (the state flower) for honors chips; autumn
gold #E3A93B only as a fill under granite text; birch white #F6F4EF pages. Header band: the Presidential Range in two layers of granite
over a foliage-orange baseline.
