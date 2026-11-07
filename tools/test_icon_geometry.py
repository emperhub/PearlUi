"""Regression checks for SVG features used by the complete Lucide catalog."""
import math
import json
from build_icons import parse_path, compile_svg, ASSETS

# Compact flags must split independently of the endpoint coordinate.
a=parse_path('M13.465 3.464a5 5 0 017.07 0 5 5 0 010 7.072')
assert a[0][-1] == (20.535,10.536)
# Smooth commands reflect the preceding matching control point, and an
# unrelated command resets that reflection state.
p=parse_path('M0 0 C0 1 1 1 1 0 S2 -1 2 0')[0]
assert p[-1]==(2,0) and p[20]==(1,0)
q=parse_path('M0 0 Q1 2 2 0 T4 0')[0]
assert q[-1]==(4,0) and min(y for x,y in q)<0
r=parse_path('M0 0 Q1 2 2 0 L3 0 T4 0')[0]
assert all(y==0 for x,y in r[21:])
z=parse_path('M1 1l2 0z m3 0l1 0')
assert z[0][-1]==(1,1) and z[1]==[(4,1),(5,1)]
catalog=json.loads((ASSETS/'catalog.json').read_text(encoding='utf-8'))
aliases=json.loads((ASSETS/'aliases.json').read_text(encoding='utf-8'))
assert len(catalog['icons'])==catalog['count']==2029
assert len(aliases)==296 and all(target in catalog['icons'] for target in aliases.values())
largest=('',0)
for name in catalog['icons']:
    shapes=compile_svg(ASSETS/(name+'.svg'))
    assert shapes,name
    points=sum(len(s) for s in shapes if isinstance(s,list))
    if points>largest[1]:largest=(name,points)
print(json.dumps({'allSVGsCompiled':2029,'upstreamAliases':296,'pathRegressions':5,'largestGeometry':largest}))
