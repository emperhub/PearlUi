"""Vendor every official Lucide SVG at SOURCE-COMMIT.txt, plus alias/search data."""
from pathlib import Path
import argparse
import io
import json
import re
import tarfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets/lucide'

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--archive',type=Path,help='Use an already downloaded upstream tar.gz')
    args=parser.parse_args()
    commit=(ASSETS/'SOURCE-COMMIT.txt').read_text().strip()
    assert re.fullmatch(r'[0-9a-f]{40}',commit)
    payload=args.archive.read_bytes() if args.archive else urllib.request.urlopen(
        f'https://codeload.github.com/lucide-icons/lucide/tar.gz/{commit}',timeout=60).read()
    names=[];metadata={};aliases={}
    with tarfile.open(fileobj=io.BytesIO(payload),mode='r:gz') as archive:
        prefix=f'lucide-{commit}/'
        for member in archive.getmembers():
            if not member.isfile() or not member.name.startswith(prefix):continue
            path=member.name[len(prefix):]
            match=re.fullmatch(r'icons/([a-z0-9-]+)\.(svg|json)',path)
            if not match:continue
            name,extension=match.groups()
            raw=archive.extractfile(member).read().decode('utf-8')
            if extension=='svg':
                (ASSETS/(name+'.svg')).write_text(raw,encoding='utf-8',newline='\n')
                names.append(name)
            else:metadata[name]=json.loads(raw)
        license_member=archive.getmember(prefix+'LICENSE')
        (ASSETS/'LICENSE').write_bytes(archive.extractfile(license_member).read())
    assert names and len(names)==len(set(names))
    names.sort()
    for name in names:
        for entry in metadata.get(name,{}).get('aliases',[]):
            alias=entry if isinstance(entry,str) else entry['name']
            assert alias not in names, ('Alias shadows canonical icon',alias)
            assert alias not in aliases or aliases[alias]==name,alias
            aliases[alias]=name
    # Do not silently leave stale SVGs from another upstream revision.
    assert {p.stem for p in ASSETS.glob('*.svg')}==set(names), 'Remove stale SVGs deliberately before switching revisions'
    (ASSETS/'aliases.json').write_text(json.dumps(dict(sorted(aliases.items())),indent=2)+'\n',encoding='utf-8')
    catalog={'source':'https://github.com/lucide-icons/lucide','commit':commit,'count':len(names),
        'icons':{n:{'tags':metadata.get(n,{}).get('tags',[]),'categories':metadata.get(n,{}).get('categories',[])} for n in names}}
    (ASSETS/'catalog.json').write_text(json.dumps(catalog,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'icons':len(names),'aliases':len(aliases),'commit':commit}))

if __name__=='__main__':main()
