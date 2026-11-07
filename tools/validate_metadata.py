"""Validate generated public API/defaults and self-contained skill references."""
from pathlib import Path
import json
import re
import sync_skill

root = Path(__file__).resolve().parents[1]
read = lambda p: (root/p).read_text(encoding='utf-8')
api = json.loads(read('docs/API.json'))
defaults = json.loads(read('defaults/PearlUI.defaults.json'))
showcase = json.loads(read('docs/ShowcaseAPI.json'))
assert api['version'] == defaults['libraryVersion'] == sync_skill.VERSION
assert set(api['methods']) == set(sync_skill.public_api()) == set(showcase['locations'])
assert len(api['methods']) == showcase['publicAPIs'] == 76
for key,signature in sync_skill.public_api().items():
    assert api['methods'][key]['signature'] == signature, key
    assert re.fullmatch(r'[\w.:]+\([^()\n]*\)', signature), ('Malformed signature', key)
roles = {'Window','Sidebar','Card','Text','Muted','Border','Track','Field','Hover','Accent'}
assert len(defaults['themes']['order']) == 9
assert set(defaults['themes']['order']) == set(defaults['themes']['palettes'])
for name,palette in defaults['themes']['palettes'].items():
    assert set(palette) == roles, name
    assert all(re.fullmatch(r'#[0-9A-F]{6}',v) for v in palette.values())
assert defaults['themes']['palettes']['Forest']['Accent'] == '#37744A'
assert defaults['themes']['palettes']['Light']['Accent'] == '#0071F6'
source = sync_skill.SOURCE
for field in ('Theme','ConfigScope','Title'):
    assert f'{field} = options.{field} or "{defaults["constructor"][field]}"' in source, field
for field in ('Scale','Columns','AnimationSpeed'):
    assert f'{field} = options.{field} or {defaults["constructor"][field]}' in source, field
for field in ('WindowSize','MinSize','MaxSize'):
    x,y=defaults['initialState'][field]
    assert f'{field} = Vector2.new({x}, {y})' in source
assert f'Opacity = {defaults["initialState"]["Opacity"]}' in source
assert 'ToggleKey = options.ToggleKey or '+defaults['constructor']['ToggleKey'] in source
assert defaults['configs']['defaultCoreScope'] == defaults['constructor']['ConfigScope']
assert defaults['controls']['Toggle']['Default'] is False
assert defaults['controls']['Input']['MaxLength'] == 128
assert defaults['persistence']['Debounce'] == 1.5
refs=root/'skills/pearl-ui/references'
for a,b in [('docs/API.md','api.md'),('docs/Defaults.md','defaults.md'),('docs/Configs.md','configs.md'),('docs/Persistence.md','persistence.md'),('docs/Showcase.md','showcase.md'),('docs/Integration.md','integration.md'),('docs/Architecture.md','architecture.md'),('docs/ValidationGuide.md','validation.md')]:
    # Reference content may differ only in portable Markdown link destinations.
    strip=lambda s: re.sub(r'\[([^\]]+)\]\([^)]+\)',r'\1',s)
    assert strip(read(a)) == strip((refs/b).read_text(encoding='utf-8')), b
assert json.loads((refs/'defaults.json').read_text()) == defaults
assert json.loads((refs/'showcase-api.json').read_text()) == showcase
for file in [root/'skills/pearl-ui/SKILL.md',*refs.glob('*.md'),* (root/'docs').glob('*.md')]:
    for target in re.findall(r'\[[^\]]+\]\(([^)]+)\)',file.read_text(encoding='utf-8')):
        if '://' not in target and not target.startswith('#'):
            assert (file.parent/target.split('#')[0]).exists(), (file,target)
skill=read('skills/pearl-ui/SKILL.md')
assert '[TODO' not in skill and 'name: pearl-ui' in skill
catalog=json.loads(read('assets/lucide/catalog.json'))
aliases=json.loads(read('assets/lucide/aliases.json'))
packed=source.split('local ICONS = {',1)[1].split('local ICON_ALIASES = {',1)[0]
names=re.findall(r'^\t\["([^"]+)"\] = ',packed,re.M)
assert len(names)==len(set(names))==catalog['count']==2029
assert set(names)==set(catalog['icons'])=={f.stem for f in (root/'assets/lucide').glob('*.svg')}
assert len(aliases)==296 and all(n in catalog['icons'] for n in aliases.values())
assert (root/'skills/pearl-ui/references/icons.md').is_file()
print('PASS: 76 API contracts, 9 palettes, 2,029 icons / 296 aliases, defaults, showcase and skill links')
