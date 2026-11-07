"""Generate the API contract, palettes and portable PearlUI skill references."""
from pathlib import Path
import json
import re
import posixpath

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "src/PearlUI.luau").read_text(encoding="utf-8")
VERSION = re.search(r'local PearlUI = \{ Version = "([^"]+)"', SOURCE).group(1)
REF = ROOT / "skills/pearl-ui/references"
REF.mkdir(parents=True, exist_ok=True)

# Return value and behavior are reviewed contracts, not guessed from function names.
CONTRACT = {
"PearlUI.new": ("Window", "Client constructor; LocalScript or explicit Parent. Enum KeyCode for constructor ToggleKey. See constructor/default tables."),
"PearlUI.GetThemes": ("string[]", "Ordered defensive copy: Light, Dark, Midnight, Graphite, Lavender, Rose, Matcha, Ocean, Forest."),
"Window.Tab": ("Tab", "String or {Name, Description, Icon}. Adds sidebar and dock entries; first tab is selected."),
"Tab.Section": ("Section", "String or {Title, Id, Column}. Stable unique Id; Column Left/Right, alternating by default."),
"Section.Toggle": ("Control", "Boolean Default=false; Callback(boolean)."),
"Section.Slider": ("Control", "Finite numeric Min/Max/Step; defaults 0/100/1; clamped and quantized value, Callback(number)."),
"Section.Dropdown": ("Control", "Required nonempty unique string Options. Multi=false, Searchable=true. Scalar or ordered array value."),
"Section.ColorPicker": ("Control", "Default current accent, Alpha=1. Accept Color3, HEX or {Hex,Alpha}; callback receives Color3,alpha."),
"Section.Input": ("Control", "Default empty string; MaxLength=128 UTF-8 characters, Placeholder='Enter text'. Commits on focus loss."),
"Section.Keybind": ("Control", "Default RightShift. Callback(string key name) for changes; OnPressed(Enum.KeyCode) for activation."),
"Section.Button": ("Control", "Text='Run', Primary=false. Callback() on activation. No persistence Id/value contract."),
"Section.Label": ("Control", "String shorthand or {Label,Value}; Value defaults empty. Get/Set useful for result labels; no persistence Id."),
"Control.Get": ("value copy", "Defensive copy for table values. ColorPicker overrides this to return Color3,alpha."),
"Control.Serialize": ("JSON-safe value", "ColorPicker returns {Hex,Alpha}; multi-dropdown returns an array. Never serialize GUI instances."),
"Control.Set": ("self", "Validate, store and render. Callback fires unless silent=true; works while disabled. Destroyed controls reject setters."),
"Control.OnChanged": ("self", "Replace callback; nil removes it. This is one callback slot, not an event subscription list."),
"Control.CanInteract": ("boolean", "Own destroyed/disabled/visible/row state. Not a complete ancestor visibility or clipping check."),
"Control.SetDisabled": ("self", "Boolean plus optional reason. Blocks native input and cancels owned popup/capture/drag; setters still work."),
"Control.SetVisible": ("self", "Hide/show while respecting search. Hiding closes owned interactions."),
"Control.SetLabel": ("self", "Change presentation without changing Id; refresh search matching."),
"Control.Close": ("self", "Close an owned dropdown/color editor if open."),
"Control.Destroy": ("nil", "Idempotent removal, listener/tween cleanup and Id release. Rebuild with the same Id after destruction."),
"Dropdown.SetOptions": ("self", "Validate new options before mutation; retain valid selections unless default supplied. Third argument silent suppresses callback."),
"Dropdown.Open": ("self", "Open if enabled and in a visible window/page; multi selection stays open until Done/Close."),
"ColorPicker.Get": ("Color3, number", "Color plus alpha. Use Serialize for a JSON-safe representation."),
"ColorPicker.SetAlpha": ("self", "Alpha in [0,1], optional silent. Preserve current HEX."),
"ColorPicker.SetHSV": ("self", "All channels finite in [0,1], optional silent; validates all channels before applying."),
"ColorPicker.Open": ("self", "Open SV/hue/alpha and HEX/RGB editor if interactive and visible."),
"Section.Detach": ("nil", "Move card to a floating window, resetting card origin/canvas. Already detached reveals it."),
"Section.Reveal": ("self", "Reveal/focus detached panel, restoring hidden/minimized main window; detaches if needed."),
"Section.Dock": ("nil", "Return content synchronously to its own page; fade empty floating shell independently."),
"Window.SetColumns": ("nil", "Only 1 or 2. Effective columns may collapse to one for a narrow viewport."),
"Window.SetTheme": ("nil", "Name from GetThemes. Repaint all bound roles while preserving a custom accent override."),
"Window.SetAccent": ("nil", "Color3 sets Custom accent mode. nil restores the selected theme's accent."),
"Window.ResetAccent": ("self", "Return to Theme mode; later themes follow their own accents. Demo also synchronizes its picker."),
"Window.SetOpacity": ("nil", "Finite number, clamped to [0.75,1], including surfaces with a visibility transition."),
"Window.SetScale": ("nil", "Finite desired scale clamped to [0.65,1.3]; actual fit scale may be smaller."),
"Window.SetSize": ("nil", "Finite width/height; rounded, clamped to 680x420..1440x1000, with viewport fitting."),
"Window.SetToggleKey": ("nil", "Enum.KeyCode or key-name string; updates footer. Constructor itself expects an Enum.KeyCode."),
"Window.SetVisible": ("nil", "Show/hide main and detached panels; hidden main leaves the dock available."),
"Window.SetMinimized": ("nil", "Minimize/restore; separate from Visible and from dock stow side."),
"Window.SetMaximized": ("nil", "Maximize/restore while remembering prior position/size."),
"Window.StowDock": ("nil", "Left or Right; hides dock offscreen with recovery handle, retaining height."),
"Window.RevealDock": ("nil", "Reveal expanded dock from edge; immediate=true skips its travel tween. Does not open main by itself."),
"Window.SelectTab": ("nil", "Tab object belonging to window or known name; closes menu and updates active page/search."),
"Window.RefreshUserProfile": ("nil", "Refresh LocalPlayer display name, username and AvatarBust thumbnail, with fallback/token guards."),
"Window.Notify": ("toast slot or nil", "String shorthand or {Title,Description,Duration,Preview}. Disabled preference suppresses ordinary notifications; Preview=true bypasses it without changing preference."),
"Window.GetLayout": ("table", "Version=1 layout with Window, Dock, Panels and ActiveTab; normalized positions, no GUI objects."),
"Window.ExportLayout": ("JSON string", "Encode GetLayout for transfer/storage."),
"Window.ImportLayout": ("boolean, error?", "Validate table or JSON before applying window, tab, panel and dock geometry."),
"Window.ExportProfile": ("JSON string", "Version=1, Values, Appearance and Layout. Persist=false controls and destroyed controls are excluded."),
"Window.ImportProfile": ("boolean, error?", "Validate known control values/appearance/layout before applying; legacy AccentMode omission retains custom-color behavior."),
"Window.CaptureDefaults": ("self", "Capture current profile after building UI and before loading user state. Named Default profile is separate."),
"Window.Reset": ("boolean, error?", "Apply captured Appearance/Controls/Layout/All immediately; requires CaptureDefaults and keeps named configs."),
"Window.RequestReset": ("confirmation handle", "Same scopes, with an in-product confirmation before application."),
"Window.Confirm": ("handle", "Title/Description/ConfirmText/OnConfirm/OnCancel. Optional Text, ReadOnly and Validate for editor. Handle Confirm/Cancel complete once; Editor/ErrorLabel available for inspection."),
"Window.ConfigurePersistence": ("boolean, loaded-or-error", "Adapter Load/Save, Key required; AutoSave=true, Load=true, Debounce=1.5, optional OnStatus. Configure after CaptureDefaults."),
"Window.GetPersistenceStatus": ("status, error?", "Disabled, Ready, Loading, Unsaved, Saving, Saved or Error."),
"Window.LoadSettings": ("boolean, exists-or-error", "Load/validate current game bank and named configs; selected auto-load overrides last working setup. Failed load blocks writes."),
"Window.SaveSettings": ("boolean, error?", "Save latest current setup and banks only after acknowledged adapter write; skip unchanged snapshot."),
"Window.DisablePersistence": ("nil", "flush=true attempts SaveSettings first; false disconnects without a write. Cancels its watcher."),
"Window.SaveProfile": ("JSON string", "Legacy named save in current scope; uses storage-budget checks. With persistence configured it survives through the settings envelope."),
"Window.LoadProfile": ("boolean, error?", "Legacy raw named-profile apply. Prefer LoadConfig for active-config tracking."),
"Window.CreateConfig": ("boolean, name-or-error", "Capture current profile under a new normalized name; set active; reject duplicates/capacity overflow."),
"Window.SaveConfig": ("boolean, name-or-error", "Update existing named snapshot from current setup and set active. Does not mean adapter has already acknowledged disk save."),
"Window.LoadConfig": ("boolean, name-or-error", "Apply named profile and set active only on success."),
"Window.RenameConfig": ("boolean, name-or-error", "Move snapshot; update active/auto-load references; preserve current values."),
"Window.DeleteConfig": ("boolean, name-or-error", "Remove snapshot, clear matching references; do not reset current values. UI wraps this with confirmation."),
"Window.SetAutoLoadConfig": ("boolean, name-or-error", "Known name selects startup snapshot; nil clears it for this scope."),
"Window.ListConfigs": ("string[]", "Sorted defensive list for current scope."),
"Window.GetConfigStatus": ("table", "Scope, Active, AutoLoad, Dirty, Count. Manager fields and transient tab/visibility changes do not create edited status."),
"Window.ExportConfig": ("JSON-or-nil, error?", "One versioned PearlUIConfig envelope with Name, Scope and Profile, not all configs."),
"Window.ValidateConfig": ("boolean, error?", "Validate package or legacy profile JSON without applying or storing it."),
"Window.ImportConfig": ("boolean, name-or-error", "Save a validated copy into current scope without applying; overwrite=true explicitly replaces an exact name."),
"Window.OnConfigsChanged": ("Disconnect handle", "Observe list/metadata changes. This is not a callback for every control edit."),
"Window.Destroy": ("nil", "Idempotent teardown; attempt final auto-save, cancel jobs/tweens/listeners, dispose both ScreenGuis. Showcase also disposes its sample."),
}

def public_api():
    methods = {}
    for c,sep,name,args in re.findall(r'^function (PearlUI|Window|Tab|Section|Control)([.:])([A-Za-z]\w*)\(([^)\n]*)\)', SOURCE, re.M):
        if not name.startswith('_'):
            methods[c+'.'+name] = c+sep+name+'('+args+')'
    methods.update({'Dropdown.SetOptions':'dropdown:SetOptions(entries, default?, silent?)','Dropdown.Open':'dropdown:Open()','ColorPicker.Get':'picker:Get()','ColorPicker.Open':'picker:Open()','ColorPicker.SetAlpha':'picker:SetAlpha(alpha, silent?)','ColorPicker.SetHSV':'picker:SetHSV(h, s, v, silent?)'})
    assert set(methods) == set(CONTRACT), 'Update the reviewed API contract for changed public methods'
    return methods

def main():
    defaults_path = ROOT/'defaults/PearlUI.defaults.json'
    defaults = json.loads(defaults_path.read_text(encoding='utf-8'))
    assert defaults['libraryVersion'] == VERSION
    palettes = {}
    theme_block=SOURCE[SOURCE.index('local THEMES = {'):SOURCE.index('local THEME_ORDER')]
    for name,body in re.findall(r'\t(\w+) = \{(.*?)\n\t\}',theme_block,re.S):
        palettes[name]={role:'#'+''.join(f'{int(v):02X}' for v in rgb.split(',')) for role,rgb in re.findall(r'(\w+) = Color3.fromRGB\(([^)]+)\)',body)}
    order=re.search(r'local THEME_ORDER = \{([^}]+)\}',SOURCE).group(1)
    defaults['themes']['order']=re.findall(r'"([^"]+)"',order)
    defaults['themes']['palettes']=palettes
    defaults_path.write_text(json.dumps(defaults,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
    methods=public_api()
    lines=['# PearlUI API contract', '', f'Version {VERSION}. All {len(methods)} public methods; underscore methods are private.', '', 'See [Defaults.md](Defaults.md) for constructor/control options and values.', '', '| Method | Returns | Contract |','|---|---|---|']
    for key in sorted(methods):
        returns,description=CONTRACT[key]
        lines.append(f'| `{methods[key]}` | {returns} | {description} |')
    lines += ['', '## Value and callback rules', '', '- Generic `Get` and `Serialize` copy arrays/tables. ColorPicker `Get` returns Color3 plus alpha; serialize HEX/alpha instead.', '- Keybind change callbacks receive a key-name string. OnPressed receives Enum.KeyCode and is ignored while typing in a TextBox.', '- Ordinary setters do not automatically keep an unrelated application control synchronized. Bind it deliberately or update its value silently; the showcase performs parameter synchronization.', '- Label and Button do not reserve persisted Ids. Put state in a value control with a stable Id.', '- SetDisabled prevents interaction but permits Set. Hiding/destroying a control cancels owned interactions.', '- Methods returning boolean/error are suitable for UI feedback. Constructor/control/configuration assertions can throw; use pcall at integration boundaries when inputs are external.', '', '## Construction and runtime fields', '', 'Accepted window constructor options: Title, Name, Theme, Accent (Color3), Parent, DisplayOrder, Columns, Scale, ReduceMotion, AnimationSpeed, ToggleKey (Enum.KeyCode), ConfigScope. Size and opacity are changed through SetSize/SetOpacity, not invented constructor options.', '', 'Applications may deliberately update ReduceMotion, AnimationSpeed and NotificationsEnabled, as the supplied demo does. Read Theme, Palette, Scale, Columns, WindowSize and ToggleKey for current state; prefer methods for geometry/theme changes.', '', 'Control common options: Id, Label, Description, Callback, Visible, Disabled, DisabledReason, Persist and ResetGroup. Use explicit section Id/Column to preserve existing config layout.']
    (ROOT/'docs/API.md').write_text('\n'.join(lines)+'\n',encoding='utf-8',newline='\n')
    (ROOT/'docs/API.json').write_text(json.dumps({'version':VERSION,'methods':{k:{'signature':methods[k],'returns':CONTRACT[k][0],'contract':CONTRACT[k][1]} for k in sorted(methods)}},ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
    copies={'docs/API.md':'api.md','docs/Defaults.md':'defaults.md','defaults/PearlUI.defaults.json':'defaults.json','docs/Configs.md':'configs.md','docs/Persistence.md':'persistence.md','docs/Showcase.md':'showcase.md','docs/ShowcaseAPI.json':'showcase-api.json','docs/Integration.md':'integration.md','docs/Architecture.md':'architecture.md','docs/ValidationGuide.md':'validation.md'}
    for source,target in copies.items():
        content=(ROOT/source).read_text(encoding='utf-8')
        if source.endswith('.md'):
            def link(match):
                label,destination=match.groups()
                if '://' in destination or destination.startswith('#'):return match.group(0)
                path,sep,anchor=destination.partition('#')
                resolved=posixpath.normpath(posixpath.join(posixpath.dirname(source),path))
                destination=copies.get(resolved,'https://github.com/emperhub/PearlUi/blob/main/'+resolved)
                return '['+label+']('+destination+(sep+anchor if sep else '')+')'
            content=re.sub(r'\[([^\]]+)\]\(([^)]+)\)',link,content)
        (REF/target).write_text(content,encoding='utf-8',newline='\n')
    print(json.dumps({'version':VERSION,'publicAPIs':len(methods),'themes':len(palettes),'references':len(copies)}))

if __name__=='__main__':main()
