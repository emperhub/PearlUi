"""Inspect an explicit PearlUI checkout without changing it."""
from pathlib import Path
import argparse, json, re

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("checkout", type=Path)
args = parser.parse_args()
root = args.checkout.resolve()
source = (root / "src/PearlUI.luau").read_text(encoding="utf-8")
version = re.search(r'local PearlUI = \{ Version = "([^"]+)"', source).group(1)
api = json.loads((root / "docs/API.json").read_text(encoding="utf-8"))
defaults = json.loads((root / "defaults/PearlUI.defaults.json").read_text(encoding="utf-8"))
assert version == api["version"] == defaults["libraryVersion"], "Version mismatch"
print(json.dumps({"checkout": str(root), "version": version,
    "publicAPIs": len(api["methods"]), "defaultTheme": defaults["constructor"]["Theme"],
    "defaultScope": defaults["constructor"]["ConfigScope"], "themes": defaults["themes"]["order"],
    "generatedArtifacts": {name: (root/"dist"/name).is_file() for name in
        ["PearlUI.rbxmx", "PearlUI-Demo.rbxlx", "PearlUI-Demo.client.luau"]}}, indent=2))
