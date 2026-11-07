"""Download the Overture Maps extracts that newhampshire.py reads -> data/nh/

- overture_nh_bbox.parquet     every place in New Hampshire's bounding box (name, category, address, point)
- overture_nh_sources.parquet  which datasets each New Hampshire eating/drinking listing came from (Meta, Foursquare, ...)
- nh_shapes.json               simplified state and county outlines for the map
- nh_state_detail.geojson      the state outline at full detail, for the in-state test
- nh_counties_detail.geojson   the 10 counties
- nh_towns_detail.geojson      the 234 cities and towns and the 25 unincorporated grants, purchases and locations: Overture's localities
                               without Manchester's nine wards and two stray entries

Reads the public Overture bucket over S3 with DuckDB (no account needed). Ported from ma-eats/pipeline/fetch_overture.py (2026-11-06).
The script checks the Isles of Shoals and the towns on the lines with Massachusetts, Vermont, Maine and Quebec (Salem is in, Methuen
is out; Hanover in, White River Junction out; Portsmouth in, Kittery out; Pittsburg in, Chartierville out).
"""
import os, json, time
import duckdb
from shapely import wkb
from shapely.geometry import mapping, Polygon

RELEASE = "2026-10-21.0"
OUT = os.path.join(os.path.dirname(__file__), "..", "data", "nh")
# New Hampshire (42.70°N–45.31°N, 70.56°W–72.56°W) plus a margin for the border towns and the Isles of Shoals
BBOX = "bbox.xmin BETWEEN -72.65 AND -70.50 AND bbox.ymin BETWEEN 42.65 AND 45.35"
EAT = "('restaurant','casual_eatery','bar','fast_food_restaurant','coffee_shop','cafe','smoothie_juice_bar','brewery','food_court')"
os.makedirs(OUT, exist_ok=True)

con = duckdb.connect()
con.execute("INSTALL httpfs; LOAD httpfs; INSTALL spatial; LOAD spatial; SET s3_region='us-west-2';")
places = f"s3://overturemaps-us-west-2/release/{RELEASE}/theme=places/type=place/*.parquet"

t = time.time()
if not os.path.exists(f"{OUT}/overture_nh_bbox.parquet"):
    con.execute(f"""
COPY (
  SELECT id, names.primary AS name, basic_category AS cat, taxonomy.primary AS tax, taxonomy.hierarchy AS hier, confidence,
         operating_status AS status, brand.names.primary AS brand, addresses[1].freeform AS street, addresses[1].locality AS city,
         addresses[1].postcode AS zip, addresses[1].region AS region, ST_Y(geometry) AS lat, ST_X(geometry) AS lon, websites[1] AS web,
         phones[1] AS phone
  FROM read_parquet('{places}', hive_partitioning=1) WHERE {BBOX}
) TO '{OUT}/overture_nh_bbox.parquet' (FORMAT PARQUET)""")
    print("places in bbox", round(time.time() - t), "s", flush=True)
if not os.path.exists(f"{OUT}/overture_nh_sources.parquet"):
    con.execute(f"""
COPY (
  SELECT id, list_transform(sources, lambda x: x.dataset) AS ds, list_transform(sources, lambda x: x.update_time) AS ut,
         list_transform(sources, lambda x: x.record_id) AS rid,
         len(socials) AS n_soc, len(websites) AS n_web, len(phones) AS n_ph
  FROM read_parquet('{places}', hive_partitioning=1)
  WHERE {BBOX} AND basic_category IN {EAT}
) TO '{OUT}/overture_nh_sources.parquet' (FORMAT PARQUET)""")
    print("sources", round(time.time() - t), "s", flush=True)

areas = f"s3://overturemaps-us-west-2/release/{RELEASE}/theme=divisions/type=division_area/*.parquet"
rows = con.execute(f"""
  SELECT subtype, names.primary AS name, ST_AsWKB(geometry) AS g
  FROM read_parquet('{areas}', hive_partitioning=1)
  WHERE country = 'US' AND region = 'US-NH' AND subtype IN ('region', 'county') AND class = 'land'
    AND bbox.xmin > -72.7 AND bbox.xmax < -70.4 AND bbox.ymin > 42.6 AND bbox.ymax < 45.4""").fetchall()
# the cities and towns and the unincorporated places: Overture's localities, less Manchester's wards and two stray entries
NOT_TOWNS = {f"Ward {i}" for i in range(1, 10)} | {"Meadow Brook Village", "Pine Tree Lane Apartments"}
trows = con.execute(f"""
  SELECT names.primary AS name, ST_AsWKB(geometry) AS g
  FROM read_parquet('{areas}', hive_partitioning=1)
  WHERE country = 'US' AND region = 'US-NH' AND subtype = 'locality' AND class = 'land'""").fetchall()
towns = {n: wkb.loads(bytes(g)).buffer(0) for n, g in trows if n not in NOT_TOWNS}
assert len(towns) == 259, len(towns)
json.dump({n: mapping(g.simplify(0.0002, preserve_topology=True)) for n, g in towns.items()}, open(f"{OUT}/nh_towns_detail.geojson", "w"))
print("towns:", len(towns))


def rings(geom, tol, min_area):
    geom = geom.simplify(tol, preserve_topology=True)
    polys = [p for p in getattr(geom, "geoms", [geom]) if p.geom_type == "Polygon" and p.area >= min_area]
    return [[[round(x, 3), round(y, 3)] for x, y in p.exterior.coords] for p in polys]


out = {"state": None, "counties": []}
for sub, name, g in rows:
    geom = wkb.loads(bytes(g)).buffer(0)
    if sub == "region":
        json.dump(mapping(geom.simplify(0.0005, preserve_topology=True)), open(f"{OUT}/nh_state_detail.geojson", "w"))
        out["state"] = [[r] for r in rings(geom, 0.002, 0.000005)]
    else:
        out["counties"].append({"name": name, "c": rings(geom, 0.004, 0.00002)})
# full-detail county polygons for assigning each place to a county (not shipped)
json.dump({name: mapping(wkb.loads(bytes(g)).buffer(0).simplify(0.0003, preserve_topology=True))
           for sub, name, g in rows if sub == "county"}, open(f"{OUT}/nh_counties_detail.geojson", "w"))
json.dump(out, open(f"{OUT}/nh_shapes.json", "w"), separators=(",", ":"))
print("outlines: state", len(out["state"] or []), "rings +", len(out["counties"]), "counties;", round(time.time() - t), "s total")
# islands, shores and border towns: each must fall on the right side of the detailed state outline
from shapely.geometry import shape, Point
st = shape(json.load(open(f"{OUT}/nh_state_detail.geojson")))
for nm, lon, lat, want in [("Salem", -71.2009, 42.7884, True), ("Methuen, MA", -71.1910, 42.7262, False), ("Seabrook", -70.8710, 42.8950, True),
                           ("Salisbury, MA", -70.8600, 42.8420, False), ("Nashua", -71.4676, 42.7654, True), ("Tyngsborough, MA", -71.4240, 42.6770, False),
                           ("Hanover", -72.2896, 43.7022, True), ("White River Jct, VT", -72.3190, 43.6490, False), ("Hinsdale", -72.4862, 42.7865, True),
                           ("Brattleboro, VT", -72.5579, 42.8509, False), ("Portsmouth", -70.7626, 43.0718, True), ("Kittery, ME", -70.7360, 43.0880, False),
                           ("Conway", -71.1287, 43.9790, True), ("Fryeburg, ME", -70.9790, 44.0170, False), ("Pittsburg", -71.3910, 45.0520, True),
                           ("Chartierville, QC", -71.2000, 45.2900, False), ("Star Island (Isles of Shoals)", -70.6140, 42.9770, True),
                           ("Mount Washington summit", -71.3033, 44.2706, True), ("Lebanon", -72.2518, 43.6423, True)]:
    ok = st.contains(Point(lon, lat))
    print(f"  {nm}: {'inside' if ok else 'outside'}{'' if ok == want else '  <-- WRONG'}")
print("counties:", len(out["counties"]), sorted(c["name"] for c in out["counties"]))

# the neighbours' land (Rhode Island, Connecticut, New York, Vermont, New Hampshire): listings.py widens New Hampshire's outline ~300 m
# for shores, but only where no neighbour's land is, so a Pawtucket or Salem, NH listing on the far side of the line stays out
nb = con.execute(f"""
  SELECT region, ST_AsWKB(geometry) FROM read_parquet('{areas}', hive_partitioning=1)
  WHERE ((country = 'US' AND region IN ('US-MA', 'US-VT', 'US-ME')) OR (country = 'CA' AND region = 'CA-QC')) AND subtype = 'region' AND class = 'land'""").fetchall()
from shapely.ops import unary_union
from shapely.geometry import box
near = box(-72.7, 42.6, -70.4, 45.4)
nbg = unary_union([wkb.loads(bytes(g)).buffer(0).intersection(near) for _, g in nb])
json.dump(mapping(nbg.simplify(0.0002, preserve_topology=True)), open(f"{OUT}/nh_neighbors.geojson", "w"))
print("neighbours:", sorted(r for r, _ in nb))
