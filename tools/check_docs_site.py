"""Check website content parity, links/assets and compile its Luau examples."""
from pathlib import Path
import argparse,json,re,subprocess,tempfile
from html.parser import HTMLParser
import build_docs_site

ROOT=Path(__file__).resolve().parents[1]

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--compiler',type=Path);args=parser.parse_args()
    build_docs_site.build(check=True)
    content=json.loads((ROOT/'website/content.json').read_text(encoding='utf-8'))
    api=json.loads((ROOT/'docs/API.json').read_text(encoding='utf-8'))
    assert content['api']==api['methods'] and content['version']==api['version']
    assert len(content['pages'])==26 and len(content['api'])==81 and len(content['icons'])==2029 and len(content['aliases'])==301
    for page in content['pages']:
        assert page['title'] and page['description'] and page['markdown']
        assert page['icon']in content['uiIcons']
        assert page['group']in {g['id']for g in content['groups']}
        if page.get('apiPrefixes'):
            for prefix in page['apiPrefixes']:assert any(name.startswith(prefix)for name in content['api']),(page['slug'],prefix)
        if page.get('source'):assert (ROOT/page['source']).is_file()
    class Assets(HTMLParser):
        def handle_starttag(self,tag,attrs):
            attrs=dict(attrs)
            if tag=='script'and 'src'in attrs:assert (ROOT/'website/dist'/attrs['src']).is_file(),attrs['src']
            if tag=='link'and attrs.get('rel')in ['stylesheet','icon']:assert (ROOT/'website/dist'/attrs['href']).is_file(),attrs['href']
    Assets().feed((ROOT/'website/index.html').read_text(encoding='utf-8'))
    snippets=[]
    for page in content['pages']:
        snippets.extend((page['slug'],block)for block in re.findall(r'```(?:lua|luau)\s*\n(.*?)\n```',page['markdown'],re.S))
    unique={block:slug for slug,block in snippets}
    if args.compiler:
        with tempfile.TemporaryDirectory(prefix='pearl-doc-examples-')as directory:
            for index,(block,slug)in enumerate(unique.items()):
                path=Path(directory)/f'{index}-{slug}.luau';path.write_text(block,encoding='utf-8')
                result=subprocess.run([str(args.compiler),'--null',str(path)],capture_output=True,text=True)
                assert result.returncode==0,(slug,result.stderr)
    print(json.dumps({'pages':26,'apiParity':81,'iconAssets':2029,'aliases':301,'luaCodeBlocks':len(snippets),'uniqueLuaExamples':len(unique),'examplesCompiled':bool(args.compiler),'assets':'Passed'}))

if __name__=='__main__':main()
