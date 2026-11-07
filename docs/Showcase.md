# Full interactive showcase

The demo now has **7 tabs, 14 sections and 102 initial controls**. The original
General, Appearance, Controls and Profiles tabs remain available. Three new
tabs expose every public method in the library for hands-on inspection.

## Components

**All components** contains Toggle, stepped Slider, searchable single and
multiple Dropdowns, a dropdown without search, ColorPicker with alpha, Input,
Keybind with an OnPressed result, Button and Label.

**Control inspector** selects a target and runs Get, Serialize, Set, silent Set,
OnChanged attach/remove, CanInteract, enable/disable, show/hide, label changes,
Close, Destroy and Recreate. It shows the latest value, callback count and
action result. False and nil are displayed as values, not failures.

Dropdown actions replace options and open the selected editor. Color actions
read color/alpha, open the editor, set alpha and set HSV. Opening an editor
scrolls its target into view. Use Recreate selected to bring back a control
you deliberately destroyed.

## Window lab

Adjust scale, opacity, desired columns and size, including custom corner
resizing. Test a two-second hide, minimize, maximize, left/right dock stowing
and dock recovery. Select any main-demo section to detach, reveal or dock it;
Dock all brings sections home. Jump between tabs, refresh the user card and
change the menu key. Drag the normal title bars, resize grip and dock directly
to inspect pointer behavior.

## API tools

Open an isolated **Pearl sample** window to test construction and destruction.
Drag its title bar aside if it covers the main inspector. The sample has its
own value, captured defaults and reset confirmation. Closing/destroying it
does not destroy the main demo. Destroying the main demo disposes the sample.

Connect sample memory storage, save, toggle its value and reload to inspect a
real adapter roundtrip without touching your own configuration files. The
sample config menu covers create/save/load/rename/delete, startup selection,
listing/status, export/validate/import, legacy profiles and observer
subscription/disconnection. Start by creating the sample config before
running operations that require one. Export to the sample buffer before
validating or importing that buffer.

Data & feedback opens main layout/profile JSON and recent action results,
lists themes, demonstrates sample JSON restoration, notifications,
confirmation/cancellation and a text editor, and previews theme/accent changes.
Parameter controls track changes made elsewhere in the demo silently.

## Coverage

[ShowcaseAPI.json](ShowcaseAPI.json) maps **all 76 public methods** to visible
controls/actions. Factories are represented by the live component examples
and the Open sample action. This map was checked against the public functions
in src/PearlUI.luau, including dropdown/color-specific methods.

The private underscore methods are implementation details and are not listed
as public test actions. Showcase control values are marked Persist=false;
ordinary window/theme settings and real Profiles actions retain their normal
persistence behavior. Sample storage is memory-only and uses a separate
sample window/config scope.

For integration, put examples/Showcase.luau into ReplicatedStorage as a
ModuleScript named PearlUIShowcase and run:

```lua
window._testBench = require(showcaseModule)(PearlUI, window)
```

The generated Studio place, Rojo project and standalone client already include
this integration. The runtime showcase suite validates coverage and core
interactive paths; native touch/gamepad and every manual action sequence have
not been tested.
