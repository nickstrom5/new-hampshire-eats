# New Hampshire sources and calibration (checked 2026-11-06)

## Official sources
| Source | What it has | Can a script read it? | Used |
|---|---|---|---|
| NH DHHS Food Protection, "Search for License or Permit Holder" (nh-dhhs.my.site.com/fsre/s/search-license-permit-holder, Salesforce) | licensed food service establishments outside the 15 self-inspecting communities; each visit since 2025-12-15 with its type, date and Priority violations (code section, status, complied-on date) | search only; no bulk file or API (the prompt: don't script the portal's endpoints); dhhs.nh.gov gives scripts an Akamai "Access Denied" | linked only: the inspections page and every place link the search (200). No result is shown, no grade computed. Bulk data needs a Right-to-Know request (RSA 91-A): **Nick's call** |
| The 15 self-inspecting communities (Bedford, Berlin, Claremont, Concord, Derry, Dover, Exeter, Keene, Manchester, Merrimack, Nashua, Plaistow, Portsmouth, Rochester, Salem; DHHS list rev. May 2025) | their own inspections | none publishes results as data (per the prompt: Manchester on request, Nashua, Concord and Portsmouth post none) | no |
| NH Liquor Commission licensee lookup (forms.nh.gov/licenseverification; enforcement.liquor.nh.gov) | on-premises licensees | no: behind a browser check / Akamai for scripts; no download | no: "Serves alcohol" is "—" everywhere. A Right-to-Know request needs Nick's yes |
| NH Parcel Mosaic (nhgeodata.unh.edu) | parcels, no values | yes | no (no building-value board) |

So New Hampshire has **no official restaurant list we may read**: no inspection list, no license list. The app keeps inspections one
link on each place page, as Nick asked on 11-05.

## Towns
The place filter is New Hampshire's 259 towns, cities and unincorporated places: Overture's locality outlines (less Manchester's Wards 1-9,
Meadow Brook Village and Pine Tree Lane Apartments). Each map listing takes the town its point is in (listings.py); 147 listings' points
sat in another town than their postal name. The postal name stays as the place's `area` when it's a village (305 listings: North Conway
95, West Lebanon 46, Glen 17, North Woodstock 16, Woodsville 13, Sanbornville 13 and so on), searchable; an area that is another town's
name is dropped. The 19 border tests (Kittery ME, White River Jct. VT, the Massachusetts line, Québec) pass. Counties (10) split the
app's detail files into 5 regions.

## Calibration
- BLS QCEW: 3,412 private NAICS 722 establishments (2025 annual average, per the prompt; 3,394 in 2026 Q1).
- Overture 2026-10-21.0: 6,693 eating and drinking listings in New Hampshire (388 marked permanently closed by Overture). The family's
  keep rule (Meta 0.95, or 0.90 with a website, or a brand feed), measured on Massachusetts' Cambridge and Somerville lists (Meta 0.95+
  matched an official record about 90% of the time), plus the hand-checked places gives the App Store build **3,318 places, 3,221
  restaurants** (94% of QCEW). No official list exists here to measure it against directly.
- Overture has no address points for New Hampshire (only Massachusetts, Maine and Vermont in its box).
- No Google data at all (no 2021 snapshot; `data/nh/google21.pkl` is empty by design).

## Research sources (each place cites its own; data/research/app/*.json; all read 2026-11-06 through Claude's web fetcher)
- Visit NH's 2026 Ice Cream Trail passport (the state tourism office's own PDF, with addresses): 53 stands and creameries, less candy
  shops, a garden center, a Christmas shop, a golf center and the chains.
- NH Magazine: 10 places to eat lobster (2026-06-05), breakfast spots for pancake season (2025-03-12).
- Tasting Table: Hampton's hidden gems (2026-02-01), the best diner breakfast in every region (2026-09-09; the Red Arrow, 1922), the
  oldest restaurant in every state (2025-09-23; the Hancock Inn, 1789).
- NHPR: summer things to do (2025-08-01).
- jamesbeard.org: 2026 semifinalists, nominees and winners; 2025 semifinalists and nominees; the 2020 America's Classics.
- Not usable: unionleader.com, seacoastonline.com, wmur.com (robots.txt disallows Claude); visitnh.gov's HTML pages (403 to the
  fetcher; its PDFs read). Readers' polls (Best of NH) don't count. Leads in `data/research/app/LEADS.md`.
- No MICHELIN Guide covers New Hampshire.
