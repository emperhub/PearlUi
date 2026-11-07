"""Build the portable documentation site from the library's actual contracts."""
from pathlib import Path
import argparse, json, re, shutil, hashlib

ROOT=Path(__file__).resolve().parents[1]
WEB=ROOT/'website'
API=json.loads((ROOT/'docs/API.json').read_text(encoding='utf-8'))
DEFAULTS=json.loads((ROOT/'defaults/PearlUI.defaults.json').read_text(encoding='utf-8'))
VERSION=API['version']
GROUPS=[{'id':'start','label':'Start here'},{'id':'interface','label':'Interface'},{'id':'components','label':'Components'},{'id':'data','label':'Data & settings'},{'id':'reference','label':'Reference'}]
PAGES=[]

def code(value):return '\n```lua\n'+value.strip()+'\n```\n'
def guide(path):
    text=(ROOT/path).read_text(encoding='utf-8')
    return re.sub(r'^# [^\n]+\n','',text,count=1).strip()
def page(slug,title,group,icon,description,markdown='',source=None,**extra):
    PAGES.append(dict(slug=slug,title=title,group=group,icon=icon,description=description,markdown=markdown,source=source,**extra))
def scalar(value):
    if value is None:return 'nil'
    if isinstance(value,bool):return str(value).lower()
    if isinstance(value,(list,dict)):return json.dumps(value,ensure_ascii=False)
    return str(value)

page('introduction','Introduction','start','sparkles','UI สไตล์ macOS สำหรับ Roblox ที่ให้คุณจัดการคอนโทรล ธีม และคอนฟิกได้อย่างเป็นระเบียบ โดยใส่ใจรายละเอียดเล็ก ๆ ของการใช้งาน',r'''
## เรียบง่ายในทุกครั้งที่เปิด

PearlUI เป็น UI library ฝั่ง client เขียนด้วย Luau มีหน้าต่าง แถบข้าง คอนโทรล และ Dock ที่ทำงานร่วมกัน คุณเป็นคนกำหนด callback และพฤติกรรมของแอป ส่วน PearlUI ดูแลการแสดงผลและการโต้ตอบ

- **8 คอนโทรลหลัก** พร้อม callback และการจัดการค่าผ่าน API
- **9 ธีม** รวม Forest โทนเขียวมืด และการปรับสี Accent
- **2,029 ไอคอน Lucide** เลือกใช้ได้ทุกคอนโทรล แท็บ และ section
- **คอนฟิกแยกตามเกม** เมื่อกำหนด `ConfigScope` ตาม `game.GameId`
- **รันซ้ำได้** ด้วยชื่อเดิม ตัวเก่าจะถูกปิดก่อนสร้างตัวใหม่

## เริ่มจากหน้าต่างเล็ก ๆ

สร้าง ModuleScript ชื่อ `PearlUI` ใน ReplicatedStorage แล้วเรียกจาก LocalScript:
'''+code('''local PearlUI = require(game.ReplicatedStorage.PearlUI)
local window = PearlUI.new({
    Name = "MyApp",
    Title = "My interface",
    Theme = "Forest",
    ConfigScope = "game_" .. tostring(game.GameId),
})

local tab = window:Tab({ Name = "General", Icon = "house" })
local section = tab:Section({ Title = "Settings", Icon = "settings" })

section:Toggle({
    Id = "enabled", Label = "Enabled", Icon = "power", Default = false,
    Callback = function(value)
        print("Enabled:", value)
    end,
})

local ok, status = window:Ready()
print(ok, status) -- true, Session only''')+'''
## ไปต่อทางไหนดี

อ่าน [Getting started](#/getting-started) สำหรับการติดตั้งจริง หรือเปิด [Showcase](#/showcase) เพื่อดูตัวอย่างทั้งหมด ส่วน [API Reference](#/api) มีเมธอดและผลลัพธ์ที่ตรงกับ implementation

> ไม่มี adapter จะใช้งานและสร้างคอนฟิกภายในหน้าต่างนั้นได้ แต่ยังไม่จำค่าข้ามการรัน อ่านวิธีต่อระบบบันทึกใน [Persistence](#/persistence)
''',heading='A little more Pearl.',eyebrow='Meet your next interface',source='README.md')

page('getting-started','Getting started','start','terminal','ติดตั้งใน Roblox Studio สร้าง UI แรก และเลือกวิธีบันทึกค่าที่เหมาะกับโปรเจกต์',guide('docs/GettingStarted.md'),source='docs/GettingStarted.md')
page('loadstring','Load from GitHub','start','download','ตัวอย่างเรียกใช้งานจริงสำหรับ client ที่รองรับ HttpGet และ loadstring พร้อมหน้าต่าง Forest สอง section','''
## เรียกตัวอย่างล่าสุด

โค้ดนี้ดาวน์โหลดตัวอย่างจาก repository ของ PearlUI และโหลด core จาก commit ที่ตรึงไว้ในตัวอย่าง
'''+code('''local app = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/emperhub/PearlUi/main/examples/Remote.client.luau"
))()''')+'''
## รันซ้ำได้เลย

ตัวอย่างใช้ `Name = "PearlRemoteExample"` เหมือนเดิมทุกครั้ง จึงแทนที่หน้าต่างเก่า รวม Dock พาแนลย่อย และตัวรับปุ่ม โดยไม่ต้องลบ GUI เอง

## ใช้ handle ที่ส่งกลับมา
'''+code('''app.Window:SetTheme("Forest")
app.Controls.Message:Set("Hello from PearlUI")
app.Window:Notify({
    Title = "Ready",
    Description = app.Controls.Message:Get(),
    Preview = true,
})

-- เมื่อต้องการปิดจากโค้ดโดยตรง
app.Window:Destroy()''')+'''
## Roblox Studio

Studio ใช้ `require(ModuleScript)` ตาม [Getting started](#/getting-started) ตัวอย่าง HttpGet/loadstring ขึ้นอยู่กับสภาพแวดล้อมที่รองรับ โค้ด core ปกติไม่ต้องใช้ runtime HTTP หรือฟังก์ชันไฟล์ของ executor

ตัวอย่างนี้ไม่มี persistence adapter จึงไม่เปลี่ยนคอนฟิกของตัวทดสอบหลักและไม่จำค่าข้ามการรัน
''',source='examples/Remote.client.luau')

window_example='''local window = PearlUI.new({
    Name = "MyApp", Title = "My interface", Theme = "Forest",
    Columns = 2, Scale = 1, AnimationSpeed = 0.2,
    ToggleKey = Enum.KeyCode.RightShift,
    Responsive = true, GamepadNavigation = true,
    ReplaceExisting = true,
    ConfigScope = "game_" .. tostring(game.GameId),
})'''
page('window','Window','interface','panels-top-left','สร้างหน้าต่าง จัดขนาด เปิด–พับ และแทนที่ UI เดิมเมื่อรันสคริปต์ซ้ำ','''
## สร้างหน้าต่าง
'''+code(window_example)+'''
`Name` เป็นชื่อที่ใช้จับคู่ UI เมื่อรันซ้ำ ส่วน `Title` เป็นข้อความบนแถบหัว ตั้งชื่อแอปให้คงที่เพื่อให้ตัวเก่าถูกแทนที่อัตโนมัติ

## ปรับขนาดและการแสดงผล
'''+code('''window:SetSize(900, 610)
window:SetScale(1)
window:SetOpacity(0.97)
window:SetMinimized(true)
window:SetMinimized(false)
window:SetVisible(false)
window:SetVisible(true)''')+'''
ขนาดและ opacity ใช้ setter ไม่ใช่ constructor options ดูค่าทั้งหมดใน [Defaults](#/defaults)

## ปุ่มหน้าต่างสามสี

- **แดง** เปิดคำถามยืนยัน ถ้าตกลงจะปิด UI, Dock และพาแนลย่อยทั้งหมด
- **เหลือง** พับหน้าต่างและใช้ Dock เปิดกลับได้
- **เขียว** สลับขยายเต็มพื้นที่กับขนาดเดิม

กด Cancel, Escape หรือพื้นที่นอกคำถามเพื่อยกเลิก การเรียก `Destroy()` จากโค้ดเป็นการปิดโดยตรง

## รันซ้ำและหลายหน้าต่าง

ค่าเริ่มต้น `ReplaceExisting = true` จับคู่จาก **Name และ Parent** แล้วเรียก teardown ของเจ้าของเดิม แม้เป็นไลบรารีที่โหลดคนละรอบ UI ชื่อต่างกันจะยังอยู่
'''+code('''-- แทนที่หน้าต่าง MyApp ตัวเดิม
local window = PearlUI.new({ Name = "MyApp" })

-- เฉพาะกรณีตั้งใจให้มีชื่อซ้ำหลายหน้าต่าง
local additional = PearlUI.new({
    Name = "MyApp",
    ReplaceExisting = false,
})''')+'''
การแทนที่สร้างค่าชุดใหม่ ถ้าต้องการโหลดค่าที่เคยบันทึก ใช้ adapter และ key เดิมตอน `Ready()` หากกำลังบันทึกก่อนปิดอยู่ การสร้างซ้ำที่ชนกันจะคืน error เพื่อกัน UI ซ้อน ให้รอรอบแรกเสร็จก่อน
''',source='docs/Architecture.md',apiPrefixes=['PearlUI.new','Window.SetSize','Window.SetScale','Window.SetOpacity','Window.SetVisible','Window.SetMinimized','Window.SetMaximized','Window.Destroy','Window.Focus'],badge='UPDATED')

page('tabs','Tabs','interface','panel-left','แบ่งพื้นที่ใช้งานด้วยแท็บ ไอคอน และคำอธิบาย โดยสลับแท็บจาก UI หรือโค้ดได้',code('''local general = window:Tab({
    Name = "General", Icon = "house",
    Description = "A place for your everyday settings.",
})
local appearance = window:Tab({ Name = "Appearance", Icon = "palette" })

window:SelectTab(general)
window:SelectTab("Appearance")
appearance:SetIcon("paintbrush")''')+'''
## ไอคอนบนแท็บและ Dock

`SetIcon()` เปลี่ยนไอคอนทั้งแถบข้างและ Dock โดยยังเก็บแท็บที่เลือกไว้ ใช้ชื่อจาก [Icons](#/icons)

## ตัวควบคุมเกมแพด

เมื่อหน้าต่างเป็นเจ้าของ selection แล้ว ใช้ shoulder buttons เปลี่ยนแท็บได้ ส่วน `Focus(control)` พาไปยังคอนโทรลที่ต้องการ อ่านรายละเอียดใน [Getting started](#/getting-started)
''',source='docs/API.md',apiPrefixes=['Window.Tab','Window.SelectTab','Tab.SetIcon'])

page('sections','Sections','interface','layout-grid','จัดคอนโทรลเป็นกลุ่ม วางซ้าย–ขวา และแยก section เป็นหน้าต่างลอย','''
## สร้าง section
'''+code('''local settings = general:Section({
    Id = "general.settings", Title = "Settings",
    Icon = "settings", Column = "Left",
})
local feedback = general:Section({
    Id = "general.feedback", Title = "Feedback",
    Icon = "bell", Column = "Right",
})
settings:Toggle({ Id = "enabled", Label = "Enabled", Default = false })''')+'''
## จัดคอลัมน์

`window:SetColumns(2)` ใช้สองคอลัมน์เมื่อพื้นที่เพียงพอ เมื่อพื้นที่แคบจะยุบเป็นหนึ่งคอลัมน์ ใช้ `Column = "Left"` หรือ `"Right"` ระบุด้าน และใช้ Id ที่คงที่เมื่อบันทึก layout

## แยกและคืนพาแนล
'''+code('''settings:Detach()
settings:Reveal()
settings:Dock()
settings:SetIcon("folder-open")''')+'''
`Dock()` คืนเนื้อหากลับ section ต้นทางทันที แล้วค่อยเฟดกรอบลอยที่ว่างออก ดูรายละเอียดใน [Panels & dock](#/panels)
''',source='docs/API.md',apiPrefixes=['Tab.Section','Section.SetIcon','Section.Detach','Section.Reveal','Section.Dock','Window.SetColumns'])

page('panels','Panels & dock','interface','app-window','ย้าย section ออกมาลอย ลาก Dock ซ่อนด้านข้าง และเปิดกลับสู่ตำแหน่งใช้งาน','''
## พาแนลลอย
'''+code('''local section = general:Section({ Id = "tools", Title = "Tools" })
section:Button({ Label = "Example", Text = "Run", Callback = function()
    print("Running")
end })

section:Detach() -- แยกออกจากหน้าหลัก
section:Reveal() -- เปิดและโฟกัสพาแนลที่แยกแล้ว
section:Dock()   -- คืนไปยังหน้าเดิม''')+'''
## Dock และการกู้คืน

Dock เริ่มที่กึ่งกลางด้านบน ลากย้ายและนำไปซ่อนขอบซ้ายหรือขวาได้ ปุ่มเหลืองพับหน้าต่างโดยยังเหลือ Dock ส่วนปุ่มแดงปิดทั้งหมดหลังยืนยัน
'''+code('''window:SetMinimized(true)
window:StowDock("Left")
window:RevealDock()
window:SetMinimized(false)''')+'''
## เก็บ layout
'''+code('''local layoutJSON = window:ExportLayout()
local ok, message = window:ImportLayout(layoutJSON)
if not ok then warn(message) end''')+'''
การเก็บ layout เป็น JSON ยังไม่ใช่การบันทึกลงไฟล์หรือ DataStore ด้วยตัวมันเอง ใช้ [Persistence](#/persistence) เพื่อเก็บข้ามครั้ง
''',source='docs/Architecture.md',apiPrefixes=['Section.Detach','Section.Reveal','Section.Dock','Window.StowDock','Window.RevealDock','Window.GetLayout','Window.ExportLayout','Window.ImportLayout'])

page('notifications','Notifications','interface','bell','แจ้งผลลัพธ์จาก callback หรือทดลองแจ้งเตือนแม้ผู้ใช้ปิดการแจ้งเตือนปกติ',code('''window:Notify({
    Title = "Settings updated",
    Description = "Your changes have been applied.",
    Duration = 4,
})

-- ปุ่ม Preview ต้องแสดงผลได้แม้ notifications ถูกปิดไว้
window:Notify({
    Title = "Notification preview",
    Description = "This is how your notifications look.",
    Preview = true,
})''')+'''
## ค่าการแจ้งเตือน

`window.NotificationsEnabled = false` ระงับการแจ้งเตือนปกติ ส่วน `Preview = true` ข้ามค่านี้เฉพาะครั้งนั้น โดยไม่เปลี่ยน preference ที่เก็บไว้
''',source='docs/API.md',apiPrefixes=['Window.Notify'])

page('dialogs','Confirmation','interface','circle-help','ขอคำยืนยันก่อนทำสิ่งที่มีผลต่อค่า หรือแสดงข้อความให้ผู้ใช้เลือกทำต่อ','''
## สร้างคำถาม
'''+code('''local question = window:Confirm({
    Title = "Apply changes?",
    Description = "Your current settings will be replaced.",
    ConfirmText = "Apply",
    OnConfirm = function() print("Confirmed") end,
    OnCancel = function() print("Cancelled") end,
})''')+'''
## ควบคุมจากโค้ด
'''+code('''question:Cancel()
-- หรือ question:Confirm() เมื่อโค้ดตั้งใจให้ยืนยัน''')+'''
Handle ทำงานได้เพียงครั้งเดียว กดซ้ำหลัง Confirm/Cancel แล้วไม่ทำ callback ซ้ำ การเปิด dialog ใหม่จะยกเลิกตัวเก่า

## รีเซ็ตด้วยคำถามยืนยัน

เรียก `Ready()` หรือ `CaptureDefaults()` หลังสร้างคอนโทรลให้ครบ ก่อนใช้ `RequestReset()`
'''+code('''window:RequestReset("Appearance")
-- scopes: Appearance, Controls, Layout, All''')+'''
ปุ่มแดงใช้ confirmation ก่อนปิดทั้ง UI อยู่แล้ว ไม่ต้องเขียนคำถามปิดหน้าต่างซ้ำ
''',source='docs/API.md',apiPrefixes=['Window.Confirm','Window.RequestReset','Window.Reset'])

page('themes','Themes','interface','palette','เลือกจาก 9 ธีมในตัว หรือกำหนด Accent ของแอปเองโดยยังเปลี่ยนธีมได้','''
## เลือกธีม
'''+code('''local names = PearlUI.GetThemes()
window:SetTheme("Forest")
window:SetTheme("Dark")''')+'''
## กำหนด Accent
'''+code('''window:SetAccent(Color3.fromRGB(110, 180, 140))
window:SetTheme("Midnight") -- สีที่ตั้งเองยังคงอยู่
window:ResetAccent()        -- กลับไปตามสี Accent ของธีม
window:SetTheme("Forest")''')+'''
`SetAccent()` เลือกโหมด Custom ส่วน `ResetAccent()` คืนโหมด Theme และตามสีของธีมถัดไป ปุ่มสลับสว่าง–มืดบนเว็บนี้เปลี่ยนเฉพาะคู่มือ ไม่เปลี่ยน UI ใน Roblox

## ค่าเริ่มต้น

constructor เริ่มจาก **Light** ตัวอย่างบน GitHub และ Starter เลือก **Forest** ไว้โดยเจตนา ดูตารางสีทั้งหมดใน [Defaults](#/defaults)
''',source='docs/Defaults.md',apiPrefixes=['PearlUI.GetThemes','Window.SetTheme','Window.SetAccent','Window.ResetAccent'])

page('icons','Icons','interface','shapes','Lucide 2,029 ไอคอนในตัวไลบรารี ค้นหาชื่อหรือ alias แล้วคัดลอกไปใช้ในโค้ดได้ทันที','''
## ใส่ไอคอนใน UI
'''+code('''local tab = window:Tab({ Name = "General", Icon = "house" })
local section = tab:Section({ Title = "Tools", Icon = "settings" })
local toggle = section:Toggle({
    Id = "enabled", Label = "Enabled", Icon = "shield-check",
})

toggle:SetIcon("power")
tab:SetIcon("layout-dashboard")
section:SetIcon("folder-open")''')+'''
## ชื่อและ alias

ใช้ kebab-case เช่น `shield-check` เป็นรูปแบบที่อ่านง่าย ตัวไลบรารีรองรับชื่อ PascalCase, underscore และ prefix `lucide:` ด้วย รายชื่อจริงอยู่ใน `PearlUI.Icons` และ alias ใน `PearlUI.IconAliases`

ไอคอนถูกแพ็กใน core แล้ว จึงไม่ต้องดาวน์โหลดรูปทีละตัวใน Roblox สิทธิ์และต้นทางดูใน [Icons guide](https://github.com/emperhub/PearlUi/blob/main/docs/Icons.md) และ [Lucide license](../assets/lucide/LICENSE)
''',source='docs/Icons.md')

CONTROL_DATA=[
 ('toggle','Toggle','toggle-right','สวิตช์เปิด–ปิดที่รับค่า boolean พร้อม callback เมื่อค่าเปลี่ยน','''local enabled = section:Toggle({
    Id = "enabled", Label = "Enabled", Description = "Turn this feature on or off.",
    Icon = "power", Default = false,
    Callback = function(value) print("Enabled:", value) end,
})
enabled:Set(true)
enabled:Set(false, true) -- true ตัวที่สอง = ไม่เรียก callback''',[]),
 ('slider','Slider','sliders-horizontal','เลือกค่าตัวเลขด้วยช่วงและ Step ที่กำหนด พร้อมหน่วยท้ายค่า','''local amount = section:Slider({
    Id = "amount", Label = "Amount", Icon = "sliders-horizontal",
    Min = 0, Max = 100, Step = 5, Default = 50, Suffix = "%",
    Callback = function(value) print(value) end,
})
amount:Set(75)''',[]),
 ('dropdown','Dropdown','list-filter','รายการแบบเลือกค่าเดียวหรือหลายค่า ค้นหาทั้งชุดข้อมูลและแบ่งหน้าสำหรับรายการใหญ่','''local choice = section:Dropdown({
    Id = "choice", Label = "Choose a tool", Icon = "list",
    Options = { "Interface", "Appearance", "Controls" },
    Default = "Interface", Searchable = true, PageSize = 50,
    Callback = function(value) print(value) end,
})
choice:Set("Appearance")
choice:SetOptions({ "Appearance", "Controls", "Profiles" })''',['Dropdown.']),
 ('colorpicker','Color picker','pipette','เลือกสีด้วย SV, hue, alpha และ HEX/RGB โดย callback ส่ง Color3 และ alpha แยกกัน','''local color = section:ColorPicker({
    Id = "accent", Label = "Accent color", Icon = "palette",
    Default = Color3.fromRGB(0, 113, 246), Alpha = 0.8,
    Callback = function(value, alpha)
        window:SetAccent(value)
        print("Alpha:", alpha)
    end,
})
color:Set("#77AADD")
color:SetAlpha(0.7)
local currentColor, alpha = color:Get()''',['ColorPicker.']),
 ('input','Input','text-cursor-input','ช่องรับข้อความ ใช้ MaxLength และ callback เพื่อผูกค่ากับพฤติกรรมของแอป','''local message = section:Input({
    Id = "message", Label = "Message", Icon = "text-cursor-input",
    Default = "Hello from PearlUI", Placeholder = "Type something...",
    MaxLength = 80,
    Callback = function(value) print(value) end,
})
message:Set("Ready")''',[]),
 ('keybind','Keybind','keyboard','ตั้งปุ่มลัดด้วย UI และแยก callback ตอนเปลี่ยนปุ่มกับตอนกดใช้งาน','''local key = section:Keybind({
    Id = "menuKey", Label = "Toggle menu", Icon = "keyboard",
    Default = "RightShift",
    Callback = function(name) window:SetToggleKey(name) end,
    OnPressed = function(keyCode) print("Pressed:", keyCode.Name) end,
})''',[]),
 ('button','Button','mouse-pointer-2','ปุ่มเรียก action พร้อมไอคอนและตัวเลือก Primary สำหรับงานหลัก','''section:Button({
    Label = "Try a notification", Text = "Preview", Icon = "bell",
    Primary = true,
    Callback = function()
        window:Notify({ Title = "Pearl UI", Description = "Ready", Preview = true })
    end,
})''',[]),
 ('label','Label','type','แสดงข้อความหรือสถานะที่อัปเดตจากโค้ด ไม่รับ selection แบบคอนโทรลโต้ตอบ','''local status = section:Label({
    Label = "Status", Value = "Ready", Icon = "info",
})
status:Set("Saved")''',[]),
]
for slug,title,icon,description,example,prefixes in CONTROL_DATA:
    extra=''
    if slug=='dropdown':extra='''\n## เลือกหลายค่า\n'''+code('''section:Dropdown({
    Id = "favorites", Label = "Favorites", Multi = true,
    Options = { "One", "Two", "Three" }, Default = { "One", "Three" },
    Callback = function(values) print(table.concat(values, ", ")) end,
})''')+'''\n`PageSize` เริ่มต้น 50 ปรับได้ 10–100 การค้นหาครอบคลุมทุกตัวเลือก แม้จะแสดงทีละหน้า ค่าและตัวเลือกต้องเป็น string ที่ไม่ซ้ำกัน\n'''
    if slug=='colorpicker':extra='\n## บันทึกค่าสี\n\n`Get()` คืน Color3 และ alpha ส่วน `Serialize()` คืน HEX/alpha ที่เก็บใน JSON ได้ ห้าม JSONEncode Color3 โดยตรง\n'
    kind='ColorPicker'if slug=='colorpicker'else title
    properties='\n## ตัวเลือกและค่าเริ่มต้น\n\n| Option | Default |\n|---|---|\n'+''.join(f'| `{key}` | `{scalar(value)}` |\n'for key,value in DEFAULTS['controls'][kind].items())+'\nทุกคอนโทรลใช้ `Label`, `Description`, `Icon`, `Callback`, `Visible`, `Disabled` และตัวเลือกทั่วไปตาม [Defaults](#/defaults)\n'
    page(slug,title,'components',icon,description,'## สร้าง '+title+'\n'+code(example)+extra+properties+'''
## ควบคุมจากโค้ด

คอนโทรลใช้ `Set(value, silent?)`, `Get()`, `SetDisabled()`, `SetVisible()`, `SetIcon()` และ `Destroy()` ตาม API ด้านล่าง ค่าที่รับขึ้นอยู่กับชนิดคอนโทรล ปุ่มและ Label ไม่จอง Id สำหรับการบันทึกค่า

ใช้ `Id` ที่คงที่กับคอนโทรลที่ต้องบันทึก ตั้ง `Persist = false` สำหรับ inspector และค่าชั่วคราว การ disable บล็อกการกดจาก UI แต่ยังเรียก setter จากโค้ดได้
''',source='docs/API.md',apiPrefixes=['Section.'+('ColorPicker' if slug=='colorpicker' else title),'Control.']+prefixes)

page('configs','Configs','data','folder-cog','สร้าง บันทึก โหลด เปลี่ยนชื่อ และนำเข้า–ส่งออกคอนฟิก โดยแยกรายชื่อกับค่าล่าสุดตามเกม','''
## เริ่มต้นคอนฟิก

สร้าง UI และคอนโทรลทั้งหมดก่อนเรียก `Ready()` ใช้ `ConfigScope = "game_" .. tostring(game.GameId)` เพื่อแยก bank ตามเกม
'''+code('''window:Ready()
local ok, name = window:CreateConfig("My setup")
if ok then print("Created:", name) end
window:SaveConfig("My setup")
window:LoadConfig("My setup")''')+'\n'+guide('docs/Configs.md'),source='docs/Configs.md')
page('persistence','Persistence','data','database','เลือกวิธีจำค่าข้ามครั้งผ่าน adapter จริง พร้อมสถานะบันทึก การรีเซ็ต และการกู้คืนเมื่อโหลดไม่สำเร็จ',guide('docs/Persistence.md'),source='docs/Persistence.md')
page('defaults','Defaults','data','settings-2','ค่าเริ่มต้นของ constructor และคอนโทรลทั้งหมด อ้างอิงจาก catalog ที่ตรวจเทียบกับ source',guide('docs/Defaults.md'),source='docs/Defaults.md')
page('api','API Reference','reference','braces','ค้นหาเมธอดทั้ง 81 ตัว พร้อม signature ผลลัพธ์ และข้อกำหนดที่ตรวจเทียบกับ implementation','''
API ชุดนี้สร้างจาก `docs/API.json` และ source ของ PearlUI เมธอดที่ขึ้นต้นด้วย underscore เป็นรายละเอียดภายในและไม่รวมใน public API

`Set(value, true)` เป็นการตั้งค่าแบบ silent ไม่เรียก callback ส่วนเมธอดที่คืน boolean/error ควรตรวจผลก่อนแสดงว่าบันทึกหรือโหลดสำเร็จ
''',source='docs/API.md')
page('showcase','Interactive showcase','reference','component','เปิดตัวทดสอบครบหมวดใน Roblox เพื่อดูค่า callback และลองฟังก์ชันของไลบรารี',guide('docs/Showcase.md'),source='docs/Showcase.md')
page('validation','Validation','reference','shield-check','ผลตรวจที่ทำจริง ขอบเขตการทดสอบ และสิ่งที่ยังต้องตรวจบนอุปกรณ์หรือเกมที่นำไปใช้',guide('docs/ValidationGuide.md'),source='docs/ValidationGuide.md')
page('changelog','Changelog','reference','history','ดูการเปลี่ยนแปลงย้อนหลัง รวมการยืนยันก่อนปิด UI และการแทนที่อัตโนมัติเมื่อรันซ้ำ',guide('CHANGELOG.md'),source='CHANGELOG.md')

UI_ICON_NAMES={p['icon']for p in PAGES}|{'search','github','arrow-up-right','sun-moon','chevron-right','copy','check','pencil','message-circle','code-xml','braces','layers','file-text'}
def svg_inner(name):
    if name=='github':name='git-branch'
    path=ROOT/'assets/lucide'/f'{name}.svg'
    if not path.exists():
        aliases=json.loads((ROOT/'assets/lucide/aliases.json').read_text(encoding='utf-8'))
        path=ROOT/'assets/lucide'/f'{aliases[name]}.svg'
    text=path.read_text(encoding='utf-8')
    return re.sub(r'^.*?<svg[^>]*>|</svg>\s*$','',text,flags=re.S).strip()

def build(output=None,check=False):
    assert API['version']==DEFAULTS['libraryVersion']
    source=(ROOT/'src/PearlUI.luau').read_text(encoding='utf-8')
    alias_block=source.split('local ICON_ALIASES = {',1)[1].split('\n}',1)[0]
    aliases=dict(re.findall(r'\["([^"]+)"\] = "([^"]+)"',alias_block))
    names=sorted(p.stem for p in (ROOT/'assets/lucide').glob('*.svg'))
    content={'version':VERSION,'groups':GROUPS,'pages':PAGES,'api':API['methods'],'themes':DEFAULTS['themes'],'icons':names,'aliases':aliases,'uiIcons':{name:svg_inner(name)for name in sorted(UI_ICON_NAMES)}}
    text=json.dumps(content,ensure_ascii=False,separators=(',',':'))+'\n'
    target=WEB/'content.json'
    if check:assert target.exists() and target.read_text(encoding='utf-8')==text,'Run python tools/build_docs_site.py and commit website/content.json'
    else:target.write_text(text,encoding='utf-8',newline='\n')
    assert len(names)==2029 and len(API['methods'])==81
    assert len({p['slug']for p in PAGES})==len(PAGES)
    for p in PAGES:
        for dest in re.findall(r'\]\(#/([a-z-]+)',p['markdown']):assert dest in {q['slug']for q in PAGES},(p['slug'],dest)
    dest=Path(output)if output else WEB/'dist';dest.mkdir(parents=True,exist_ok=True)
    for name in ['index.html','styles.css','theme.js','app.js','favicon.svg','content.json']:shutil.copyfile(WEB/name,dest/name)
    shutil.copytree(WEB/'vendor',dest/'vendor',dirs_exist_ok=True)
    (dest/'icons').mkdir(exist_ok=True)
    for name in names:shutil.copyfile(ROOT/'assets/lucide'/f'{name}.svg',dest/'icons'/f'{name}.svg')
    for p in (ROOT/'assets/lucide').glob('LICENSE*'):shutil.copyfile(p,dest/'icons'/p.name)
    print(json.dumps({'version':VERSION,'pages':len(PAGES),'publicAPIs':len(API['methods']),'icons':len(names),'runtimeAliases':len(aliases),'contentSha256':hashlib.sha256(text.encode()).hexdigest(),'output':str(dest)}))

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output');parser.add_argument('--check',action='store_true');args=parser.parse_args();build(args.output,args.check)
