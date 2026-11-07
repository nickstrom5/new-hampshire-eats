"""New Hampshire has no open official restaurant records a script may read (official.py, playbook/12-sources.md): nothing to fetch.

Checked 2026-11-06: dhhs.nh.gov answers scripts with an Akamai "Access Denied"; DHHS's inspection results are on a search-only
Salesforce portal (nh-dhhs.my.site.com/fsre/s/search-license-permit-holder), linked from each place, never scraped; the Liquor
Commission's licensee lookup sits behind a browser check and offers no download. This script only writes an empty meta.json.
"""
import json, os

OUT = os.path.join(os.path.dirname(__file__), "..", "data", "raw", "official")
os.makedirs(OUT, exist_ok=True)
json.dump({}, open(os.path.join(OUT, "meta.json"), "w"))
print("New Hampshire: no official lists to fetch")
