import re

import klayout.db as db

LAYERS = {
    "Metal1": 8,
    "Metal2": 10,
    "Metal3": 30,
    "Metal4": 50,
    "Metal5": 67,
    "TopMetal1": 126,
}

ly = db.Layout()
ly.read(gds)
top = ly.cell(cell)
dbu = ly.dbu

text = open(lef).read()

covered = {name: db.Region() for name in LAYERS}
layer = None
for line in text.splitlines():
    m = re.match(r"\s*LAYER\s+(\S+)", line)
    if m:
        layer = m.group(1)
        continue
    m = re.match(r"\s*RECT\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)", line)
    if m and layer in covered:
        x0, y0, x1, y1 = (round(float(v) / dbu) for v in m.groups())
        covered[layer].insert(db.Box(x0, y0, x1, y1))

extra = []
for name, gds_layer in LAYERS.items():
    li = ly.find_layer(gds_layer, 0)
    if li is None:
        continue
    missing = db.Region(top.begin_shapes_rec(li)) - covered[name]
    missing.merge()
    boxes = [p.bbox().to_dtype(dbu) for p in missing.decompose_trapezoids_to_region().each()]
    if boxes:
        extra.append(f"    LAYER {name} ;")
        for b in boxes:
            extra.append(f"     RECT {b.left:.3f} {b.bottom:.3f} {b.right:.3f} {b.top:.3f} ;")
        print(f"{lef}: {name}: {len(boxes)} uncovered piece(s) added to OBS")

if extra:
    text, n = re.subn(r"^(  OBS\n)", lambda m: m.group(1) + "\n".join(extra) + "\n", text, count=1, flags=re.M)
    if n != 1:
        raise SystemExit(f"{lef}: no OBS section to extend")
    open(lef, "w").write(text)
else:
    print(f"{lef}: abstract covers all GDS metal")
