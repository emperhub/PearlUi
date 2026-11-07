"""Compile the bundled Lucide SVG geometry into PearlUI's offline icon data.

SVG arcs are sampled into short line segments. Circles remain native UIStroke
circles. This avoids asset uploads, executor APIs, and runtime HTTP requests.
"""
from pathlib import Path
import math
import re
import xml.etree.ElementTree as ET
import json

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
    previous, cubic, quadratic = None, None, None
    paths, points = [], []
    counts = {"M": 2, "L": 2, "H": 1, "V": 1, "A": 7, "C": 6, "Q": 4, "S": 4, "T": 2}
    while index < len(tokens):
        if tokens[index].isalpha():
            command = tokens[index]
            index += 1
        upper, relative = command.upper(), command.islower()
        if upper == "Z":
            points.append(origin)
            current = origin
            previous, cubic, quadratic = "Z", None, None
            command = None
            continue
        if upper not in counts:
            raise ValueError(f"Unsupported path command: {command}")
        args = []
        for argument in range(counts[upper]):
            assert index < len(tokens), f'Incomplete {command} command'
            token=tokens[index]
            if upper=='A' and argument in (3,4):
                # SVG flags can touch each other and the next coordinate: 017.07.
                assert token[0] in '01', f'Invalid arc flag: {token}'
                args.append(float(token[0]))
                if len(token)>1:tokens[index]=token[1:]
                else:index+=1
            else:
                args.append(float(token));index+=1
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
        elif upper in ("C", "Q", "S", "T"):
            count = 20
            start = current
            if upper in ("C", "S"):
                if upper=="C":
                    control1, control2, end = coordinate(*args[:2]), coordinate(*args[2:4]), coordinate(*args[4:6])
                else:
                    control1=tuple(2*current[a]-cubic[a] for a in range(2)) if previous in ("C","S") else current
                    control2,end=coordinate(*args[:2]),coordinate(*args[2:4])
                for step in range(1, count + 1):
                    t, u = step / count, 1 - step / count
                    points.append(tuple(u**3 * start[a] + 3*u*u*t * control1[a] + 3*u*t*t * control2[a] + t**3 * end[a] for a in range(2)))
                cubic=control2
            else:
                if upper=="Q":control1,end=coordinate(*args[:2]),coordinate(*args[2:4])
                else:
                    control1=tuple(2*current[a]-quadratic[a] for a in range(2)) if previous in ("Q","T") else current
                    end=coordinate(*args[:2])
                for step in range(1, count + 1):
                    t, u = step / count, 1 - step / count
                    points.append(tuple(u*u*start[a] + 2*u*t*control1[a] + t*t*end[a] for a in range(2)))
                quadratic=control1
            current = end
        previous=upper
        if upper not in ("C","S"):cubic=None
        if upper not in ("Q","T"):quadratic=None
    if points:
        paths.append(points)
    return paths


def number(value):
    return f"{value:.3f}".rstrip("0").rstrip(".") or "0"


def compile_svg(asset):
    shapes=[]
    root=ET.parse(asset).getroot()
    assert root.get('viewBox')=='0 0 24 24', asset
    for element in root:
        tag=element.tag.rsplit('}',1)[-1]
        a=element.attrib
        if tag=='path':shapes.extend(parse_path(a['d']))
        elif tag=='circle':
            shapes.append({'Circle':[float(a[k]) for k in ('cx','cy','r')],'Filled':a.get('fill')=='currentColor'})
        elif tag=='rect':
            x,y,w,h=[float(a.get(k,0)) for k in ('x','y','width','height')]
            rx=min(w/2,float(a.get('rx',a.get('ry',0))))
            ry=min(h/2,float(a.get('ry',a.get('rx',0))))
            if rx==ry:shapes.append({'Rect':[x,y,w,h,rx]})
            else:
                points=[(x+rx,y),(x+w-rx,y)]
                for end,straight in [((x+w,y+ry),(x+w,y+h-ry)),((x+w-rx,y+h),(x+rx,y+h)),((x,y+h-ry),(x,y+ry)),((x+rx,y),(x+rx,y))]:
                    points.extend(arc_points(points[-1],end,rx,ry,0,False,True));points.append(straight)
                shapes.append(points)
        elif tag=='ellipse':
            cx,cy,rx,ry=[float(a[k]) for k in ('cx','cy','rx','ry')]
            shapes.append([(cx+rx*math.cos(i*math.tau/40),cy+ry*math.sin(i*math.tau/40)) for i in range(41)])
        elif tag=='line':shapes.append([(float(a['x1']),float(a['y1'])),(float(a['x2']),float(a['y2']))])
        elif tag in ('polyline','polygon'):
            numbers=[float(v) for v in re.findall(r'[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?',a['points'])]
            assert len(numbers)%2==0
            points=list(zip(numbers[::2],numbers[1::2]))
            if tag=='polygon':points.append(points[0])
            shapes.append(points)
        else:raise ValueError(f'Unsupported SVG element: {tag} in {asset.name}')
    assert shapes,asset
    def rounded(value):
        if isinstance(value,(list,tuple)):return [rounded(v) for v in value]
        if isinstance(value,dict):return {k:rounded(v) for k,v in value.items()}
        if isinstance(value,bool):return value
        assert math.isfinite(value),asset
        n=round(value,3)
        return int(n) if n==int(n) else n
    return rounded(shapes)

def main():
    entries=[]
    catalog=json.loads((ASSETS/'catalog.json').read_text(encoding='utf-8'))
    assets=sorted(ASSETS.glob('*.svg'))
    assert set(catalog['icons'])=={a.stem for a in assets}
    for asset in assets:
        data=json.dumps(compile_svg(asset),separators=(',',':'))
        # JSON strings are decoded only for icons actually rendered. This keeps
        # the full catalog below Luau's constant/register limits and avoids
        # eagerly allocating geometry tables or GUI instances for 2,000 icons.
        entries.append('\t['+json.dumps(asset.stem)+'] = '+json.dumps(data)+',')
    aliases=json.loads((ASSETS/'aliases.json').read_text(encoding='utf-8'))
    aliases.update({'general':'settings-2','appearance':'palette','controls':'sliders-horizontal','profiles':'layers','detach':'arrow-up-right'})
    assert all(target in catalog['icons'] for target in aliases.values())
    alias_lines=['\t['+json.dumps(a)+'] = '+json.dumps(n)+',' for a,n in sorted(aliases.items())]
    license_text=(ASSETS/'LICENSE').read_text(encoding='utf-8')
    commit=(ASSETS/'SOURCE-COMMIT.txt').read_text().strip()
    block='-- BEGIN LUCIDE DATA\n--[[\nLucide Icons | https://lucide.dev | commit '+commit+'\n'+license_text+']]\nlocal ICONS = {\n'+'\n'.join(entries)+'\n}\nlocal ICON_ALIASES = {\n'+'\n'.join(alias_lines)+'\n}\n-- END LUCIDE DATA'
    target=ROOT/'src/PearlUI.luau'
    source=target.read_text(encoding='utf-8')
    assert source.count('-- BEGIN LUCIDE DATA')==1 and source.count('-- END LUCIDE DATA')==1
    source=re.sub(r'-- BEGIN LUCIDE DATA.*?-- END LUCIDE DATA',lambda _:block,source,flags=re.S)
    target.write_text(source,encoding='utf-8',newline='\n')
    print(json.dumps({'compiledIcons':len(entries),'upstreamAliases':len(aliases)-5,'packedBytes':len(block.encode()),'commit':commit}))

if __name__=='__main__':main()
