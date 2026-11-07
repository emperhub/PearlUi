"""Compile the bundled Lucide SVG geometry into PearlUI's offline icon data.

SVG arcs are sampled into short line segments. Circles remain native UIStroke
circles. This avoids asset uploads, executor APIs, and runtime HTTP requests.
"""
from pathlib import Path
import math
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets/lucide"


def arc_points(start, end, rx, ry, rotation, large, sweep):
    rx, ry = abs(rx), abs(ry)
    if not rx or not ry or start == end:
        return [end]
    phi = math.radians(rotation)
    cs, sn = math.cos(phi), math.sin(phi)
    dx, dy = (start[0] - end[0]) / 2, (start[1] - end[1]) / 2
    xp, yp = cs * dx + sn * dy, -sn * dx + cs * dy
    radii = xp * xp / (rx * rx) + yp * yp / (ry * ry)
    if radii > 1:
        rx *= math.sqrt(radii)
        ry *= math.sqrt(radii)
    numerator = max(0, rx * rx * ry * ry - rx * rx * yp * yp - ry * ry * xp * xp)
    denominator = rx * rx * yp * yp + ry * ry * xp * xp
    factor = (-1 if bool(large) == bool(sweep) else 1) * math.sqrt(numerator / denominator) if denominator else 0
    cxp, cyp = factor * rx * yp / ry, -factor * ry * xp / rx
    cx = cs * cxp - sn * cyp + (start[0] + end[0]) / 2
    cy = sn * cxp + cs * cyp + (start[1] + end[1]) / 2
    ux, uy = (xp - cxp) / rx, (yp - cyp) / ry
    vx, vy = (-xp - cxp) / rx, (-yp - cyp) / ry
    initial = math.atan2(uy, ux)
    delta = math.atan2(ux * vy - uy * vx, ux * vx + uy * vy)
    if not sweep and delta > 0:
        delta -= math.tau
    if sweep and delta < 0:
        delta += math.tau
    count = max(2, math.ceil(abs(delta) * max(rx, ry) / 1.15))
    points = []
    for index in range(1, count + 1):
        angle = initial + delta * index / count
        points.append((cx + cs * rx * math.cos(angle) - sn * ry * math.sin(angle), cy + sn * rx * math.cos(angle) + cs * ry * math.sin(angle)))
    points[-1] = end
    return points


def parse_path(data):
    tokens = re.findall(r"[a-zA-Z]|[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?", data)
    index, command, current, origin = 0, None, (0, 0), (0, 0)
    paths, points = [], []
    counts = {"M": 2, "L": 2, "H": 1, "V": 1, "A": 7, "C": 6, "Q": 4}
    while index < len(tokens):
        if tokens[index].isalpha():
            command = tokens[index]
            index += 1
        upper, relative = command.upper(), command.islower()
        if upper == "Z":
            points.append(origin)
            current = origin
            command = None
            continue
        if upper not in counts:
            raise ValueError(f"Unsupported path command: {command}")
        args = [float(token) for token in tokens[index:index + counts[upper]]]
        index += counts[upper]
        def coordinate(x, y):
            return (x + current[0], y + current[1]) if relative else (x, y)
        if upper == "M":
            if points:
                paths.append(points)
            current = coordinate(*args)
            origin, points = current, [current]
            command = "l" if relative else "L"
        elif upper == "L":
            current = coordinate(*args)
            points.append(current)
        elif upper == "H":
            current = (args[0] + current[0] if relative else args[0], current[1])
            points.append(current)
        elif upper == "V":
            current = (current[0], args[0] + current[1] if relative else args[0])
            points.append(current)
        elif upper == "A":
            end = coordinate(args[5], args[6])
            points.extend(arc_points(current, end, *args[:5]))
            current = end
        elif upper in ("C", "Q"):
            count = 20
            start = current
            if upper == "C":
                control1, control2, end = coordinate(*args[:2]), coordinate(*args[2:4]), coordinate(*args[4:6])
                for step in range(1, count + 1):
                    t, u = step / count, 1 - step / count
                    points.append(tuple(u**3 * start[a] + 3*u*u*t * control1[a] + 3*u*t*t * control2[a] + t**3 * end[a] for a in range(2)))
            else:
                control1, end = coordinate(*args[:2]), coordinate(*args[2:4])
                for step in range(1, count + 1):
                    t, u = step / count, 1 - step / count
                    points.append(tuple(u*u*start[a] + 2*u*t*control1[a] + t*t*end[a] for a in range(2)))
            current = end
    if points:
        paths.append(points)
    return paths


def number(value):
    return f"{value:.3f}".rstrip("0").rstrip(".") or "0"


entries = []
for asset in sorted(ASSETS.glob("*.svg")):
    shapes = []
    for element in ET.parse(asset).getroot():
        tag = element.tag.rsplit("}", 1)[-1]
        a = element.attrib
        if tag == "path":
            for points in parse_path(a["d"]):
                assert len(points) >= 2
                shapes.append("{ " + ", ".join("{" + number(x) + "," + number(y) + "}" for x, y in points) + " }")
        elif tag == "circle":
            shapes.append("{ Circle = {" + ",".join(number(float(a[key])) for key in ("cx", "cy", "r")) + "}, Filled = " + ("true" if a.get("fill") == "currentColor" else "false") + " }")
        elif tag == "rect":
            values = [float(a.get(key, 0)) for key in ("x", "y", "width", "height", "rx")]
            shapes.append("{ Rect = {" + ",".join(number(v) for v in values) + "} }")
        else:
            raise ValueError(f"Unsupported SVG element: {tag}")
    entries.append('\t["' + asset.stem + '"] = {\n\t\t' + ",\n\t\t".join(shapes) + "\n\t},")

license_text = (ASSETS / "LICENSE").read_text(encoding="utf-8")
commit = (ASSETS / "SOURCE-COMMIT.txt").read_text(encoding="utf-8").strip()
block = "-- BEGIN LUCIDE DATA\n--[[\nLucide Icons | https://lucide.dev | commit " + commit + "\n" + license_text + "]]\nlocal ICONS = {\n" + "\n".join(entries) + "\n}\n-- END LUCIDE DATA"
target = ROOT / "src/PearlUI.luau"
source = target.read_text(encoding="utf-8")
assert source.count("-- BEGIN LUCIDE DATA") == 1 and source.count("-- END LUCIDE DATA") == 1
source = re.sub(r"-- BEGIN LUCIDE DATA.*?-- END LUCIDE DATA", lambda _: block, source, flags=re.S)
target.write_text(source, encoding="utf-8")
print(f"Compiled {len(entries)} Lucide icons from {commit}")
