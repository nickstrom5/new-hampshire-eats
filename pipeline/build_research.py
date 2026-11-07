"""Writes data/research/app/*.json (hand-checked New Hampshire guides), data/research/michelin.json, jbf.json and closed.json from the
compact lists below. Ported from ma-eats/pipeline/build_research.py.

Each entry cites the page that names it, read on 2026-11-06 through Claude's web fetcher (every host's robots.txt lets Claude read it;
check_sources.py): Visit NH's 2026 Ice Cream Trail passport (the state tourism office's own publication, with each shop's address), NH
Magazine's dated features, NHPR, Tasting Table and jamesbeard.org. The address comes from the map listing we already hold for that
name in that town (site/newhampshire.json); when the map data doesn't have the place as a kept place to eat, it is added with the
street address its source prints. Towns are the 259 towns and unincorporated places: North Conway is Conway, Weirs Beach is Laconia.
Usage: ../.venv/bin/python build_research.py   (then newhampshire.py)"""
import json, os, re
from brands import brand_of
from common import norm_name
ROOT = os.path.join(os.path.dirname(__file__), "..")
R = os.path.join(ROOT, "data", "research")
d = json.load(open(os.path.join(ROOT, "site", "newhampshire.json")))
C, M = d["cols"], d["meta"]
norm = lambda s: re.sub(r"\s+", " ", re.sub(r"[^a-z0-9 ]", " ", (s or "").lower().replace("'", "").replace("’", ""))).strip()

# each dated on its face, or the state tourism office's own 2026 publication (read 2026-11-06)
ICE = ("https://www.visitnh.gov/getContentAsset/2e77bc54-3f79-4da2-b283-0a8001eef550/73aabf56-e6e5-4330-95a3-5f2a270a1d2b/"
       "Ice-Cream-Trail-Brochure-2026.pdf?language=en")                                            # Visit NH, Ice Cream Trail 2026
LOB = "https://www.nhmagazine.com/10-places-to-eat-lobster-in-nh/"                                   # NH Magazine, 2026-06-05
TT_HAMPTON = "https://www.tastingtable.com/2086627/new-hampshire-hidden-gem-hampton-food/"            # Tasting Table, 2026-02-01
PANCAKE = "https://www.nhmagazine.com/our-favorite-breakfast-spots-for-pancake-season/"              # NH Magazine, 2025-03-12
TT_DINER = "https://www.tastingtable.com/2251841/best-diner-breakfast-every-major-us-region/"         # Tasting Table, 2026-09-09
NHPR = ("https://www.nhpr.org/arts-culture/2025-08-01/things-to-do-new-hampshire-newengland-summer-ideas-travel-weekend-trip-"
        "vacation-daytrip")                                                                       # NHPR, 2025-08-01
TT_OLD = "https://www.tastingtable.com/1975409/oldest-restaurant-every-state-still-open/"             # Tasting Table, 2025-09-23
JBF26 = "https://www.jamesbeard.org/stories/james-beard-award-semifinalists-2026"                   # 2026-01-21
JBF26N = "https://www.jamesbeard.org/stories/james-beard-awards-restaurant-and-chef-nominees-2026"  # 2026-03-31
JBF26W = "https://www.jamesbeard.org/stories/james-beard-award-winners-2026"                        # 2026-06-15
JBF25 = "https://www.jamesbeard.org/stories/the-2025-james-beard-award-semifinalists"               # 2025-01-22
JBF25N = "https://www.jamesbeard.org/stories/2025-james-beard-awards-restaurant-and-chef-nominees"  # 2025-04-02
JBF20C = "https://www.jamesbeard.org/stories/announcing-the-2020-americas-classics-winners"         # 2020 America's Classics
TRAIL = "Visit NH's 2026 Ice Cream Trail"

# (name as the source writes it, town (one of the 259), street address as the source prints it (or None), note, founded,
# founded_note, [sources])
I = lambda name, town, addr, note: (name, town, addr, note, None, None, [ICE])
GUIDES = {
 "ice cream stand": [   # Visit NH's 2026 Ice Cream Trail: the ice cream stands and creameries (not the candy shops or chains)
  I("Cup & Cone", "Berlin", "83 Main St", "A North Woods scoop shop on Berlin's Main Street."),
  I("Moose Alley Cones", "Pittsburg", "2356 N Main St", "Cones at the top of the state, on the road to the Connecticut Lakes."),
  I("Scoops on Main", "Lancaster", "176 Main St", "Ice cream made with New Hampshire milk and cream, on Lancaster's Main Street."),
  I("Hatchland Farm", "Haverhill", "15 Petticoat Ln", "A North Haverhill dairy farm's own ice cream, from its own milk."),
  I("Pine Cones Ice Cream", "Woodstock", "109 Lost River Rd", "Handmade ice cream at Maple Haven campground in North Woodstock."),
  I("Sherman Farm", "Conway", "2679 East Conway Rd", "A Center Conway farm stand with ice cream."),
  I("Super Secret Ice Cream", "Bethlehem", "2213 Main St", "Ice cream made on site in Bethlehem; a James Beard Outstanding Bakery finalist in 2025 and 2026."),
  I("Trails End Ice Cream Shop", "Bartlett", "3631 White Mountain Hwy", "An Intervale ice cream stand on Route 16."),
  I("Bubba's Bar & Grille", "Newbury", "976 Route 103", "A bar and grill by Lake Sunapee with an ice cream window."),
  I("Naughty Nellie's Ice Cream Bar", "Andover", "46 Main St", "Ice cream made on site in Andover."),
  I("Sanctuary Dairy Farm Ice Cream", "Sunapee", "209 Route 103", "A dairy farm's own ice cream, made on site."),
  I("The Big Spoon", "Newport", "29 Main St", "A scoop shop on Newport's Main Street."),
  I("The Quack Shack", "Sunapee", "36 River Rd", "A Sunapee ice cream stand."),
  I("The Velvet Moose Ice Cream Shoppe", "Warner", "25 East Main St", "An ice cream shop on Warner's Main Street."),
  I("Wade's Ice Cream", "Claremont", "488 Main St", "A Claremont ice cream stand."),
  I("Bailey's Bubble", "Wolfeboro", "5 Railroad Ave", "A Wolfeboro ice cream stand by the town docks."),
  I("Barnyard Creamery at the Pizza Barn", "Ossipee", "1860 Route 16", "Ice cream made on site at the Pizza Barn in Center Ossipee."),
  I("Bobby Sue's Homemade Ice Cream", "Freedom", "70 Eaton Rd", "Homemade ice cream in Freedom village."),
  I("Happy Cow Ice Cream Shop", "Laconia", "385 Union Ave", "A Laconia ice cream shop."),
  I("Kellerhaus", "Laconia", "259 Endicott St N", "A Weirs Beach candy and ice cream house with a make-your-own sundae buffet; ice cream made on site."),
  I("Milltuck Farm and Creamery", "Sanbornton", "728 New Hampton Rd", "A farm creamery using New Hampshire milk and cream."),
  I("M 'n M Scoops", "Plymouth", "67 Main St", "A scoop shop on Plymouth's Main Street."),
  I("Papa Beans Ice Cream", "Sandwich", "301 Wing Rd", "Handmade ice cream from New Hampshire milk in North Sandwich."),
  I("Social Club Creamery", "Laconia", "51 Elm St", "Ice cream made on site in Lakeport."),
  I("The Sandwich Creamery", "Sandwich", "2 Maple Ridge Rd", "A dairy farmer's creamery in North Sandwich: made on site from New Hampshire milk."),
  I("Wolfeboro Dockside Grille & Dairy Bar", "Wolfeboro", None, "A dairy bar and grill on the Wolfeboro docks."),
  I("Charlie's Olde Tyme Creamery", "Peterborough", "9 Sharon Rd", "An old-fashioned creamery in Peterborough."),
  I("Frisky Cow Gelato", "Keene", "80 Krif Rd", "Gelato made on site from New Hampshire milk."),
  I("Hayward's Family Ice Cream", "Milford", "383 Elm St", "Ice cream made on site in Milford."),
  I("The Piazza", "Keene", "830 Park Ave", "A Keene ice cream stand using New Hampshire milk."),
  I("Village Creamery", "Chesterfield", "20 Brook St", "A West Chesterfield ice cream stand."),
  I("Village Creami-Cone", "Swanzey", "919 W Swanzey Rd", "A West Swanzey soft-serve stand."),
  I("Walpole Creamery", "Walpole", "532 Main St", "Walpole's creamery."),
  I("Zippers Soft Serve Ice Cream", "Hillsborough", "3 Henniker St", "A Hillsborough soft-serve stand."),
  I("Devriendt Farm Products", "Goffstown", "178 South Mast St", "A Goffstown farm stand with ice cream."),
  I("Dudley's Ice Cream", "Loudon", "846 NH-106", "An ice cream stand on Route 106 in Loudon."),
  I("Gould Hill Farm", "Hopkinton", "656 Gould Hill Rd", "A Contoocook orchard's ice cream, made from New Hampshire milk."),
  I("Hayward's Homemade Ice Cream", "Merrimack", "360 Daniel Webster Hwy", "Homemade ice cream on the Daniel Webster Highway in Merrimack."),
  I("Hayward's Homemade Ice Cream", "Nashua", "7 Daniel Webster Hwy", "Homemade ice cream on the Daniel Webster Highway in Nashua."),
  I("Ilsley's Ice Cream", "Weare", "33 South Sugar Hill Rd", "A dairy farmer's ice cream stand in Weare, made on site."),
  I("Moo's Place Homemade Ice Cream", "Derry", "27 Crystal Ave", "Homemade ice cream in Derry."),
  I("Peach Tree Farm", "Salem", "88 Brady Ave", "A Salem farm stand with ice cream."),
  I("Richardson's Farm", "Boscawen", "170 Water St", "A Boscawen farm's ice cream, made on site from New Hampshire milk."),
  I("Sundae Drive", "Brookline", "346 Route 13", "An ice cream stand on Route 13 using New Hampshire milk."),
  I("Super Scoops", "Henniker", "58 Main St", "Ice cream made on site in Henniker from New Hampshire milk."),
  I("Sweet Dreamz", "Concord", "325 Village St", "An ice cream stand in Penacook."),
  I("The Big 1 Ice Cream Stand", "Nashua", "185 Concord St", "A Nashua ice cream stand."),
  I("Annabelle's Natural Ice Cream", "Portsmouth", "49 Ceres St", "A Portsmouth ice cream shop by the harbor."),
  I("JB's on the Boardwalk", "Hampton", "139 Ocean Blvd", "Ice cream on the Hampton Beach boardwalk."),
  I("Lago's Ice Cream", "Rye", "71 Lafayette Rd", "Ice cream made on site in Rye."),
  I("Lickee's & Chewy's", "Dover", "53 Washington St", "A Dover candy shop and creamery."),
  I("Lone Oak Ice Cream", "Rochester", "175 Milton Rd", "Ice cream made on site in Rochester."),
  I("What's the Scoop", "Kingston", "160 Main St", "A Kingston ice cream stand.")],
 "seacoast seafood": [   # NH Magazine's Seacoast lobster places (June 2026) and Tasting Table's Hampton (February 2026)
  ("Brown's Lobster Pound", "Seabrook", "407 NH-286", "A family-owned lobster pound on the water since 1950: pick a lobster from the tanks.", 1950,
   "NH Magazine (June 2026): family-owned since 1950.", [LOB]),
  ("Markey's Lobster Pool", "Seabrook", "420 NH-286", "A family-owned lobster pool with a raw bar, open since 1971; cash only.", 1971,
   "NH Magazine (June 2026): open since 1971.", [LOB]),
  ("Petey's Summertime Seafood", "Rye", "1323 Ocean Blvd", "A Rye seafood shack open all year that catches its own lobster.", None, None, [LOB]),
  ("BG's Boat House Restaurant", "Portsmouth", "191 Wentworth Rd", "A seasonal restaurant and marina by the water, for nearly four decades.", None, None, [LOB]),
  ("The Beach Plum", "North Hampton", None, "The Route 1A shack known for lobster rolls.", None, None, [LOB]),
  ("Geno's Chowder and Sandwich Shop", "Portsmouth", "177 Mechanic St", "A seasonal chowder and sandwich shop in its 56th year.", None, None, [LOB]),
  ("The Ice House", "Rye", "112 Wentworth Rd", "A seasonal seafood stand, open Wednesday through Sunday.", None, None, [LOB]),
  ("Sea Ketch Restaurant", "Hampton", "127 Ocean Blvd", "A Hampton Beach seafood restaurant on Ocean Boulevard.", None, None, [LOB, TT_HAMPTON]),
  ("Rye Harbor Lobster Pound", "Rye", "1870 Ocean Blvd", "A tiny lobster pound at Rye Harbor.", None, None, [LOB]),
  ("Ray's Seafood Restaurant", "Rye", "1677 Ocean Blvd", "A seafood restaurant on the Rye shore.", None, None, [LOB]),
  ("The Old Salt", "Hampton", None, "Chowder, oysters, fried haddock and clambakes at Lamie's Inn, a Colonial-style lodge built in 1740.", None, None, [TT_HAMPTON]),
  ("Galley Hatch", "Hampton", None, "A Hampton seafood restaurant on Lafayette Road, dating to 1970.", None, None, [TT_HAMPTON])],
 "pancake house": [   # NH Magazine's pancake-season breakfast spots (March 2025), and the Red Arrow and Hungry Diner
  ("Polly's Pancake Parlor", "Sugar Hill", "672 Route 117", "An institution for over 85 years: its own maple syrup and stone-ground pancakes from freshly milled flour.",
   None, None, [PANCAKE, NHPR]),
  ("Intervale Farm Pancake House", "Henniker", "931 Flanders Rd", "Pancakes and waffles, open daily year-round for more than 30 years.", None, None, [PANCAKE]),
  ("Heritage Farm Pancake House", "Sanbornton", "16 Parker Hill Rd", "A farm pancake house, open Fridays and Saturdays, March through October.", None, None, [PANCAKE]),
  ("Stuart & John's Sugar House Restaurant", "Westmoreland", "31 Route 63", "Pancakes, waffles and donut holes with its own syrup, weekends in maple season and spring.",
   None, None, [PANCAKE, ICE]),
  ("Parker's Maple Barn", "Mason", "1316 Brookline Rd", "Seven kinds of pancakes; its sugar house boils sap over a wood fire.", None, None, [PANCAKE]),
  ("Benton's Sugar Shack", "Thornton", "2010 Route 175", "Pancakes and French toast with warm homemade syrup.", None, None, [PANCAKE]),
  ("Red Arrow Diner", "Manchester", "61 Lowell St", "Manchester's diner, founded in 1922, open around the clock.", 1922,
   "Tasting Table (September 2026): founded in 1922.", [TT_DINER]),
  ("The Hungry Diner", "Walpole", None, "A Walpole diner on NHPR's 2025 summer list.", None, None, [NHPR])],
 "historic inn": [   # not a guide of its own: the oldest places list
  ("The Hancock Inn", "Hancock", "33 Main St", "New Hampshire's oldest restaurant, an inn that opened in 1789, with its Fox Tavern.", 1789,
   "Tasting Table (September 2025): the Hancock Inn opened in 1789.", [TT_OLD])],
}
ADDR = {}
CUISINE = {}
POINT = {}
DISPLAY = {}
KINDS = {k: [k] for k in GUIDES}
I_CU = "Bakery & Sweets"
for name, town, *_ in GUIDES["ice cream stand"]:
    if name not in ("Bubba's Bar & Grille",):
        CUISINE[(name, town)] = I_CU
for name, town, *_ in GUIDES["pancake house"]:
    CUISINE[(name, town)] = "Breakfast & Diner"
CUISINE[("The Hancock Inn", "Hancock")] = "American & Other"

# no MICHELIN Guide covers New Hampshire (its Northeast coverage stops at Greater Boston)
MICHELIN = []
MI_MATCH = {}
MI_UT = None
NE = "Best Chef: Northeast"
# James Beard (facts with sources): the 2026 Best Chef: Northeast winner, the 2025-26 Outstanding Bakery finalist and the 2025
# semifinalists; Puritan Backroom's 2020 America's Classic; jamesbeard.org pages read 2026-11-06
JBF = [{"name": "Stages", "city": "Dover", "honors": [f"{NE} winner 2026 (Evan Hennessey)"], "sources": [JBF26W, JBF26N, JBF26],
        "match_names": ["STAGES AT ONE WASHINGTON", "STAGES AT ONE WASHINGTON STREET"]},
       {"name": "Super Secret Ice Cream", "city": "Bethlehem", "honors": ["Outstanding Bakery finalist 2026", "Outstanding Bakery finalist 2025"],
        "sources": [JBF26N, JBF25N, JBF25]},
       {"name": "Puritan Backroom", "city": "Manchester", "honors": ["America's Classics 2020"], "sources": [JBF20C]},
       {"name": "Otis Restaurant", "city": "Exeter", "honors": [f"{NE} semifinalist 2025 (Lee Frank)"], "sources": [JBF25], "match_names": ["OTIS"]},
       {"name": "Stalk", "city": "Dover", "honors": [f"{NE} semifinalist 2025 (Nicole Nocella)"], "sources": [JBF25]}]
CLOSED = []


def key(s):
    """The name key without a leading "the": "Varsity" is our "The Varsity"."""
    return re.sub(r"^the ", "", norm(s))


def find(name, town, num):
    hits = find_in(name, town, num)
    if not hits and num:   # the source's town is a village ("Intervale"): the same name at the same street number anywhere
        hits = find_in(name, None, num)
    return hits


def find_in(name, town, num):
    k = key(name)
    hits = [i for i, n in enumerate(C["name"]) if C["city"][i] is not None and (town is None or M["cities"][C["city"][i]] == town)
            and (key(n) == k or key(n).startswith(k + " ") or k.startswith(key(n) + " ") or key(n).replace(" ", "") == k.replace(" ", "")
                 or (key(n).split()[:2] == k.split()[:2] and len(k.split()) >= 2))]
    if num:
        hits = [i for i in hits if (C["addr"][i] or "").split(" ")[0].upper() == num.upper()]
    exact = [i for i in hits if key(C["name"][i]) == k]   # "Limoncello" and "Limoncello Ristorante", one place listed twice
    return exact if len(hits) > 1 and len(exact) == 1 else hits


leads, n_out = [], {}
for kind, rows in GUIDES.items():
    out = []
    for name, town, addr, note, founded, fnote, srcs in rows:
        num = (re.match(r"\s*(\d+)", addr or "") or [None, None])[1]
        hits = find(name, town, num)
        if len(hits) != 1 and addr:
            # not a kept place to eat in the map data (or listed twice there): added with the street address its source gives
            out.append({"name": name, "address": addr, "city": town, "zip": None, "kinds": KINDS[kind], "dishes": [], "note": note,
                        "founded": founded, "founded_note": fnote, "website": None, "open": True, "evidence_date": "2026-11",
                        "sources": srcs, "match_names": []} | ({"cuisine": CUISINE[(name, town)]} if (name, town) in CUISINE else {}))
            if len(hits) > 1:
                leads.append(f"- {kind}: {name} ({town}, {addr}) — {len(hits)} matches in our data; added by its address")
            continue
        if len(hits) != 1:
            leads.append(f"- {kind}: {name} ({town}) — {len(hits)} matches in our data and no address; not added"); continue
        i = hits[0]
        out.append({"name": C["name"][i], "address": C["addr"][i], "city": M["cities"][C["city"][i]], "zip": str(C["zip"][i]) if C["zip"][i] else None,
                    "kinds": KINDS[kind], "dishes": [], "note": note, "founded": founded, "founded_note": fnote, "website": None, "open": True,
                    "evidence_date": "2026-11", "sources": srcs, "match_names": [name.upper()] if norm(name) != norm(C["name"][i]) else []})
        if brand_of(norm_name(name)):
            out[-1]["display"] = name
        if (name, town) in DISPLAY:
            out[-1]["display"] = DISPLAY[(name, town)]
        if (name, town) in CUISINE:
            out[-1]["cuisine"] = CUISINE[(name, town)]
    fn = re.sub(r"[^a-z]+", "_", kind).strip("_")
    json.dump(out, open(f"{R}/app/{fn}.json", "w"), indent=1, ensure_ascii=False)
    n_out[kind] = len(out)

MI_ADDR = {"311 Omakase": "605 Tremont St", "Jahunger": "272 Brookline St", "Wa Shin": "222 Stuart St", "Zhi Wei Cafe": "104 South St"}
json.dump({"restaurants": [{"name": n, "address": MI_ADDR.get(n), "city": t, "zip": None, "distinction": dist, "cuisine": cu, "green_star": False,
                             "michelin_url": MI_UT, "sources": [MI_UT], "match_names": [x.upper() for x in MI_MATCH.get(n, [])], "open": True}
                            for n, t, dist, cu in MICHELIN]}, open(f"{R}/michelin.json", "w"), indent=1, ensure_ascii=False)
json.dump([dict({"address": None}, **j, zip=None, open=True) for j in JBF], open(f"{R}/jbf.json", "w"), indent=1, ensure_ascii=False)
json.dump(CLOSED, open(f"{R}/closed.json", "w"), indent=1, ensure_ascii=False)
open(f"{R}/app/LEADS.md", "w").write("# New Hampshire research leads (not yet verified)\n\nWritten by pipeline/build_research.py.\n\n" + "\n".join(leads) + """

## Waiting for a source we may use
- Classic diners beyond the Red Arrow and the Hungry Diner (Four Aces, Littleton Diner, Tilt'n Diner, Peterboro Diner, Gilly's): the
  2025-26 mentions found are readers' polls (Best of NH), which don't count; NH Magazine's diner features are from 2014-2015.
- Chicken tenders (Puritan Backroom's own claim), Franco-American poutine and pork pie, cider-donut orchards and colonial inns beyond
  the Hancock Inn: no 2025-26 source on a host that lets Claude read it yet. unionleader.com, seacoastonline.com and wmur.com disallow
  Claude; visitnh.gov's pages answer the fetcher 403 (its PDFs read).
- Polly's Pancake Parlor's America's Classics year (the prompt says 2006): no jamesbeard.org page found for it yet.
- Excluded from the ice cream trail list: candy and chocolate shops (Red Kite Candy, Life is Sweet, the Granite State Candy Shoppes,
  Ava Marie, Kilwins), a garden center and a Christmas shop, a golf center, and the chains (Bruster's, Salt & Straw, Sub Zero).
""")
print(n_out, "| leads:", len(leads))
for l in leads: print(l)
