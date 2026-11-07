"""Build drag-and-drop Roblox XML artifacts using only Python's standard library."""
from pathlib import Path
import xml.etree.ElementTree as ET
import json
import re

ROOT = Path(__file__).resolve().parents[1]
DIST = ROOT / "dist"
DIST.mkdir(exist_ok=True)
next_referent = 0


def item(parent, kind, name):
    global next_referent
    next_referent += 1
    element = ET.SubElement(parent, "Item", {"class": kind, "referent": f"RBX{next_referent}"})
    props = ET.SubElement(element, "Properties")
    ET.SubElement(props, "string", {"name": "Name"}).text = name
    return element, props


def document():
    root = ET.Element("roblox", {"version": "4"})
    ET.SubElement(root, "External").text = "null"
    ET.SubElement(root, "External").text = "nil"
    return root


def script(parent, kind, name, source):
    element, props = item(parent, kind, name)
    ET.SubElement(props, "ProtectedString", {"name": "Source"}).text = source
    return element


def write(root, path):
    ET.indent(root, space="  ")
    ET.ElementTree(root).write(path, encoding="utf-8", xml_declaration=True)


library = (ROOT / "src/PearlUI.luau").read_text(encoding="utf-8")
demo = (ROOT / "examples/Demo.client.luau").read_text(encoding="utf-8")
persistence_client = (ROOT / "src/PersistenceClient.luau").read_text(encoding="utf-8")
persistence_server = (ROOT / "examples/Persistence.server.luau").read_text(encoding="utf-8")
file_adapter = (ROOT / "examples/FileStorage.luau").read_text(encoding="utf-8")
showcase = (ROOT / "examples/Showcase.luau").read_text(encoding="utf-8")
model = document()
script(model, "ModuleScript", "PearlUI", library)
write(model, DIST / "PearlUI.rbxmx")

place = document()
replicated, _ = item(place, "ReplicatedStorage", "ReplicatedStorage")
script(replicated, "ModuleScript", "PearlUI", library)
script(replicated, "ModuleScript", "PearlUIPersistence", persistence_client)
script(replicated, "ModuleScript", "PearlUIShowcase", showcase)
server_scripts, _ = item(place, "ServerScriptService", "ServerScriptService")
script(server_scripts, "Script", "PearlUIPersistenceServer", persistence_server)
starter, _ = item(place, "StarterPlayer", "StarterPlayer")
scripts, _ = item(starter, "StarterPlayerScripts", "StarterPlayerScripts")
script(scripts, "LocalScript", "PearlUIDemo", demo)
workspace, _ = item(place, "Workspace", "Workspace")
part, props = item(workspace, "Part", "Baseplate")
ET.SubElement(props, "bool", {"name": "Anchored"}).text = "true"
ET.SubElement(props, "bool", {"name": "Locked"}).text = "true"
ET.SubElement(props, "token", {"name": "TopSurface"}).text = "3"
size = ET.SubElement(props, "Vector3", {"name": "size"})
for axis, value in zip("XYZ", (256, 1, 256)):
    ET.SubElement(size, axis).text = str(value)
color = ET.SubElement(props, "Color3", {"name": "Color"})
for channel, value in zip("RGB", (0.78, 0.8, 0.85)):
    ET.SubElement(color, channel).text = str(value)
frame = ET.SubElement(props, "CoordinateFrame", {"name": "CFrame"})
for key, value in {"X": 0, "Y": -1, "Z": 0, "R00": 1, "R01": 0, "R02": 0, "R10": 0, "R11": 1, "R12": 0, "R20": 0, "R21": 0, "R22": 1}.items():
    ET.SubElement(frame, key).text = str(value)
spawn, spawn_props = item(workspace, "SpawnLocation", "Spawn")
ET.SubElement(spawn_props, "bool", {"name": "Anchored"}).text = "true"
ET.SubElement(spawn_props, "bool", {"name": "Neutral"}).text = "true"
spawn_size = ET.SubElement(spawn_props, "Vector3", {"name": "size"})
for axis, value in zip("XYZ", (6, 1, 6)):
    ET.SubElement(spawn_size, axis).text = str(value)
lighting, lighting_props = item(place, "Lighting", "Lighting")
ET.SubElement(lighting_props, "float", {"name": "ClockTime"}).text = "14"
ET.SubElement(lighting_props, "float", {"name": "Brightness"}).text = "2"
write(place, DIST / "PearlUI-Demo.rbxlx")

# Standalone source for local preview integrations. Studio users use the module.
standalone = "local PearlUI = (function()\n" + library + "\nend)()\n"
demo_without_require = demo.replace('local PearlUI = require(ReplicatedStorage:WaitForChild("PearlUI"))', "")
adapter_block = '''local persistenceAdapter
local fileEnvironment = getfenv()
if type(fileEnvironment.readfile) == "function" and type(fileEnvironment.writefile) == "function" then
    local factory = (function()
''' + file_adapter + '''
    end)()
    local ok, adapter = pcall(factory, { FileSystem = fileEnvironment, Folder = "PearlUI", Prefix = "u" .. tostring(game:GetService("Players").LocalPlayer.UserId) .. "_" })
    if ok then persistenceAdapter = adapter end
end
'''
demo_without_require = re.sub(r"-- BEGIN STORAGE ADAPTER.*?-- END STORAGE ADAPTER", lambda _: adapter_block, demo_without_require, flags=re.S)
showcase_block = "local showcaseFactory = (function()\n" + showcase + "\nend)()\nwindow._testBench = showcaseFactory(PearlUI, window)\n"
demo_without_require = re.sub(r"-- BEGIN SHOWCASE.*?-- END SHOWCASE", lambda _: showcase_block, demo_without_require, flags=re.S)
standalone += demo_without_require
(DIST / "PearlUI-Demo.client.luau").write_text(standalone, encoding="utf-8")

# Check XML roundtrips preserve both scripts exactly, including UTF-8.
roundtrip = ET.parse(DIST / "PearlUI-Demo.rbxlx")
sources = [node.text for node in roundtrip.findall(".//ProtectedString[@name='Source']")]
assert sources == [library, persistence_client, showcase, persistence_server, demo], "XML changed script source"
assert ET.parse(DIST / "PearlUI.rbxmx").find(".//ProtectedString").text == library
json.loads((ROOT / "default.project.json").read_text(encoding="utf-8"))
print("Built and verified:")
for artifact in sorted(DIST.iterdir()):
    if artifact.is_file():
        print(f"  {artifact.name} ({artifact.stat().st_size:,} bytes)")
