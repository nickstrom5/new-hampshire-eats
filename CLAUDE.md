# Granite State Eats (nh-eats) — notes for Claude Code sessions

Built 2026-11-06 by a side session for Nick's "build the 17 remaining states" (group: Massachusetts, New Hampshire, New Mexico, Montana),
ported from `../ma-eats/` (itself from `../va-eats/`, with every fix to 2026-11-05: delivery-only brands hidden, the shared website
blocklist and `link_blocklist.py`, the Share link to `Links.site + explore/#p=<id>`, OTA data, the widened adult rule, the Denny's
delivery-brand guard, Utah's street-word merge fix, the exact-outline county lookup). Local only: git-ignored data, no repo, no remote,
nothing published. Sources and calibration: `playbook/12-sources.md`. Brand: `playbook/05-naming.md` — **final** (Nick's decisions, 2026-11-07: "Granite State Eats: NH" on the App Store, Home Screen "Granite State Eats"; a pancake-stack icon, concept A, on granite;
granite #3E4A52, foliage orange #B5471B, lilac #6A4C93 honors, autumn gold #E3A93B fill only, birch #F6F4EF; a band of the
Presidential Range).

## New Hampshire is different
- **No Google data at all**, in either build (Nick's rule for these four states): `listings.py` reads no UCSD snapshot.
- **No official list we may read.** DHHS's inspection results are search-only (nh-dhhs.my.site.com, since 2025-12-15), the 15
  self-inspecting communities publish none as data, and the Liquor Commission's lookup is behind a browser check. So: no inspection
  result is shown and none is computed; every place links DHHS's search; "Serves alcohol" is "—". A Right-to-Know request (RSA 91-A)
  for bulk inspections or licensees is **Nick's call**. `fetch_official.py` writes an empty meta.json; `official.py` loads nothing.
- **Towns:** the 259 towns and unincorporated places from Overture's locality outlines (`fetch_overture.py` writes
  `nh_towns_detail.geojson`). Each listing's town is the outline its point is in; its village postal name stays as `area` (`ar` in
  the app data: "North Conway, Conway", "West Lebanon, Lebanon"), searchable. `canon_city` maps villages for research
  (`VILLAGE_TOWN`, and `data/nh/locality_town.json`, which `listings.py` derives). Counties (10) only split the detail files into 5
  regions (Seacoast; Merrimack Valley; Lakes Region & Mount Washington Valley; White Mountains & North Country; Monadnock & Sunapee).
- **Honors:** no MICHELIN Guide covers New Hampshire. James Beard: Stages (Dover; Evan Hennessey, Best Chef: Northeast 2026), Super
  Secret Ice Cream (Bethlehem; Outstanding Bakery finalist 2025 and 2026), Puritan Backroom (Manchester; America's Classics 2020), 2025
  semifinalists Otis (Exeter) and Stalk (Dover). Polly's Pancake Parlor's America's Classics year (the prompt says 2006) is a lead:
  no jamesbeard.org page found yet. The facts for all four states are in the shared notes, `jbf-ma-nh-nm-mt-2025-26.md`.
- **Guides** (tags in `newhampshire.py` TAGS, bits 1, 2, 4, 8): ice cream stands (Visit NH's 2026 Ice Cream Trail), Seacoast seafood
  (NH Magazine 2026, Tasting Table 2026), pancake houses & diners (NH Magazine 2025, Tasting Table 2026, NHPR 2025), oldest (3 dated
  places: no oldest page on the site until there are 4). Sources in `pipeline/build_research.py`; leads (diners beyond the Red Arrow,
  chicken tenders, poutine, cider donuts, colonial inns, The Old Salt) in `data/research/app/LEADS.md`.
- **Venues:** Manchester-Boston Regional Airport's terminal (by box), the arenas, stadiums and speedway, the prisons.
- **Inspections:** only a link on place pages (no inspection list among the guides), per Nick's 11-05 call.
- **Ranking:** "Featured first" (honors, then founding year), as everywhere; no health-grade wording.

## Rebuild
```bash
cd pipeline
../.venv/bin/python check_sources.py URL...   # a new host first
../.venv/bin/python fetch_overture.py && ../.venv/bin/python fetch_extras.py && ../.venv/bin/python fetch_official.py
../.venv/bin/python listings.py && ../.venv/bin/python calibrate.py
../.venv/bin/python newhampshire.py && ../.venv/bin/python build_research.py && ../.venv/bin/python newhampshire.py
../.venv/bin/python geocode_census.py   # research addresses the map lacks (data/research/geocode_todo.json), then newhampshire.py again
NH_APP=1 ../.venv/bin/python newhampshire.py && cd .. && cp data/app/places.json data/app/detail-*.json NewHampshireEats/Resources/
cd pipeline && ../.venv/bin/python check_websites.py && ../.venv/bin/python check_websites.py --retry-transient && cd ..   # then re-export
.venv/bin/python scripts/make-site.py && .venv/bin/python scripts/publish_app_data.py && .venv/bin/python scripts/publish_app_data.py --check
.venv/bin/python scripts/qa-site.py --static
```
(`listings.py` before `calibrate.py`; `newhampshire.py` once before `build_research.py`, which matches names against
`site/newhampshire.json`.) The `.venv` is a copy of wy-eats' (python.org framework Python 3.12, md-eats' package versions).

## App, site, screenshots
- App: `NewHampshireEats/` (XcodeGen `project.yml`, bundle `com.newhampshireeats.ios`, display "Granite State Eats"), tests in
  `NewHampshireEatsTests/` (data guards: adult venues, blocklisted and multi-URL websites, bad and legal names, non-restaurants, listed
  twice, no Google data; the outline with Kittery ME, White River Jct. VT, the Massachusetts line and Québec outside, the Isles of
  Shoals' Star Island inside) and `NewHampshireEatsUITests/`. Run with `DEVELOPER_DIR="/Applications/Xcode 1.app/Contents/Developer"`;
  unit tests may use `CODE_SIGNING_ALLOWED=NO`, UI tests need the signed runner (no flag). Archive only with Xcode 1.app (27.2, 27B52).
  Run `xcodegen generate` whenever the set of `Resources/*.json` files changes.
- Site: `scripts/make-site.py` writes `docs/` and `playbook/site-numbers.json`; `scripts/explore.js` is the web app (it searches the
  `ar` area too); `scripts/qa-site.py` the QA. Site URL for now: nickstrom5.github.io/new-hampshire-eats (no CNAME). Rebuild the site
  before the unit tests (`ShareLinkTests` reads `docs/`).
- OTA data: `docs/data/app/` via `scripts/publish_app_data.py` (`../OTA-DATA.md`).
- Screenshots: `scripts/capture-screenshots.sh <sim>` (ScreenshotMode pins Concord's Main Street; Hampton for Seacoast seafood), then
  `scripts/site-images.sh`, then make-site + qa-site. App Store frames: `scripts/appstore-screenshots.py`. Icons:
  `scripts/icon-concepts.swift` and `scripts/make-brand.swift` (concept A).

## Status (2026-11-07): ready to publish
- Data: 3,318 places, 3,221 restaurants in 187 towns (QCEW 3,412); 71 hand-checked on a guide (51 ice cream stands, 11 Seacoast seafood,
  8 pancake houses and diners), 3 dated oldest, 5 James Beard honorees. Links checked 2026-11-06 (1,956 of 2,900 ok).
- Tests: unit (49) pass on iPhone 17 Pro Max; UI tests pass on iPad Pro 13" and iPhone (iOS 27.0, Xcode 1.app), the tour after a fix.
  Launch-time check: passed on iPhone on a quiet Mac, 4.61 s (the QA session, 2026-11-07); the iPad pass was running then.
  Screenshots in docs/screenshots and playbook/app-store/{iphone,ipad}. Site: 12 pages; `qa-site.py` (full) passes. OTA 2026-11-06.1
  (`--check` OK). Listing: playbook/app-store/listing.json (App Store name "Granite State Eats: NH", since the long form is 33 characters).
- Records: the QA session is drafting the Right-to-Know request (DHHS inspections), for Nick.

## Rules
No commits, pushes, public repos, App Store Connect or DNS changes without Nick's yes each time; never submit for review or accept
agreements; never publish Google-derived data. Support email nick@eatsranked.com. Commit author "Nick Soderstrom"
<329204362+nickstrom5@users.noreply.github.com> via `-c user.name -c user.email`.
