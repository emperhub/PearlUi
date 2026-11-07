"""Rebuild/validate PearlUI and compile all Luau sources. Standard library only."""
from pathlib import Path
import argparse
import hashlib
import io
import os
import subprocess
import sys
import tempfile
import urllib.request
import zipfile

ROOT=Path(__file__).resolve().parents[1]
LUAU_URL='https://github.com/luau-lang/luau/releases/download/0.745/luau-ubuntu.zip'
LUAU_SHA256='186e5ddaa2b048ebc7390c11ed1b00c04e7d3beaffed429250329e3575d2ece2'

def snapshot():
    paths=[ROOT/'src/PearlUI.luau',ROOT/'docs/API.md',ROOT/'docs/API.json',ROOT/'defaults/PearlUI.defaults.json',
        * (ROOT/'skills/pearl-ui/references').glob('*'),* (ROOT/'dist').glob('*')]
    return {p.relative_to(ROOT).as_posix():p.read_text(encoding='utf-8') for p in paths if p.is_file()}

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--compiler',type=Path,help='Path to official luau-compile executable')
    parser.add_argument('--download-compiler',action='store_true',help='Download checksum-pinned official Linux compiler')
    parser.add_argument('--verify-generated',action='store_true',help='Fail if the rebuild changes any generated text')
    args=parser.parse_args()
    before=snapshot()
    for name in ['build_icons.py','test_icon_geometry.py','build.py','sync_skill.py','validate_metadata.py']:
        subprocess.run([sys.executable,str(ROOT/'tools'/name)],cwd=ROOT,check=True)
    if args.verify_generated:
        after=snapshot()
        stale=[name for name in set(before)|set(after) if before.get(name)!=after.get(name)]
        assert not stale,'Commit regenerated artifacts: '+', '.join(sorted(stale))
    compiler=args.compiler
    with tempfile.TemporaryDirectory(prefix='pearl-luau-') as temp:
        if args.download_compiler:
            assert sys.platform.startswith('linux'),'Automatic compiler download is Linux-only; use --compiler on this OS'
            payload=urllib.request.urlopen(LUAU_URL,timeout=60).read()
            assert hashlib.sha256(payload).hexdigest()==LUAU_SHA256,'Luau archive checksum mismatch'
            with zipfile.ZipFile(io.BytesIO(payload)) as archive:
                matches=[name for name in archive.namelist() if Path(name).name=='luau-compile']
                assert len(matches)==1,'Compiler missing from archive'
                compiler=Path(temp)/'luau-compile';compiler.write_bytes(archive.read(matches[0]));compiler.chmod(0o755)
        if compiler:
            compiler=compiler.resolve()
            sources=sorted([*ROOT.glob('src/*.luau'),*ROOT.glob('examples/*.luau'),*ROOT.glob('tests/*.luau'),*ROOT.glob('dist/*.luau')])
            for path in sources:
                run=subprocess.run([str(compiler),'--null',str(path)],capture_output=True,text=True)
                assert run.returncode==0,f'{path.relative_to(ROOT)}: {run.stderr}'
            print(f'PASS: compiled {len(sources)} Luau files')
        else:print('Compiler skipped: provide --compiler or --download-compiler for syntax checks')
    print('PASS: source, generated artifacts, icon geometry, public contracts and skill references')

if __name__=='__main__':main()
