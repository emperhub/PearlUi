# PearlUI

📖 [คู่มือออนไลน์ — PearlUI Documentation](https://emperhub.github.io/PearlUi/)
มีเมนูแยกหมวด ค้นหา API ตัวอย่างพร้อมคัดลอก และคลังไอคอน

**1.0.2** พร้อมไอคอนทุกคอนโทรล เลย์เอาต์มือถือ การนำทางเกมแพด Dropdown แบบแบ่งหน้า และ Ready สำหรับตั้งค่าเริ่มต้น/การบันทึก

รันซ้ำด้วย Name เดิมจะแทนที่ UI เก่าอัตโนมัติ รวม Dock และพาแนลย่อย; ใช้ ReplaceExisting=false ถ้าต้องการหลายหน้าต่าง

ปุ่มแดงถามยืนยันก่อนปิด UI และ Dock ทั้งหมด; ปุ่มเหลืองพับหน้าต่าง

เริ่มที่ [คู่มือติดตั้งและใช้จริง](docs/GettingStarted.md) หรือ [Starter.client.luau](examples/Starter.client.luau)
รองรับการใช้แบบ session ทันที; การจำค่าข้ามครั้งต้องต่อ adapter ตามคู่มือ

รุ่น 1.0.2 ผ่านการตรวจที่เกี่ยวข้อง 379 รายการ และรันตัวโหลดจริงซ้ำ 3 ครั้งเหลือหน้าต่างกับ Dock อย่างละอัน ดู [ผลตรวจ](tests/RerunValidation.json)
ฐานรุ่น 1.0.0 ผ่าน 587 รายการและไอคอนครบ 2,029 แบบ ดู [ผลเดิมและขอบเขต](tests/ReleaseValidation.json)
มือถือ/เกมแพดผ่านการจำลอง; ยังไม่ได้ทดสอบอุปกรณ์จริงหรือ DataStore ที่เผยแพร่แล้ว

รองรับ [Lucide ครบ 2,029 ไอคอน](docs/Icons.md) ในตัวไลบรารี ใช้ `Icon = "shield-check"`
หรือชื่อไอคอนอื่นได้ทันที ดูรายชื่อใน `PearlUI.Icons` และ alias ใน `PearlUI.IconAliases`

## เริ่มใช้งาน / ค่า Default / สกิล

ตัวอย่างเรียกจาก GitHub สำหรับ client preview ที่รองรับ HttpGet/loadstring:

```lua
local app = loadstring(game:HttpGet("https://raw.githubusercontent.com/emperhub/PearlUi/main/examples/Remote.client.luau"))()
```

เปิดหน้าต่าง Forest สอง section พร้อม callback ใช้งานจริง ดู [ซอร์สตัวอย่าง](examples/Remote.client.luau)
และ [วิธีใช้ใน Studio/สภาพแวดล้อมอื่น](docs/Integration.md) รันซ้ำด้วยชื่อเดิมได้เลย ตัวเก่าจะถูกปิดให้อัตโนมัติ

- เปิด `dist/PearlUI-Demo.rbxlx` ใน Studio เพื่อดูตัวทดสอบทั้งหมด หรือใช้ `examples/Default.client.luau` เป็นตัวเริ่มต้นสอง section
- [ค่า Default ทุกหมวด](docs/Defaults.md) และ [ไฟล์ JSON](defaults/PearlUI.defaults.json): Light, 2 คอลัมน์, scale 1, animation 0.2s, RightShift; เดโมแยกคอนฟิกตาม GameId
- [API ครบ 81 เมธอด](docs/API.md), [เริ่มใช้งาน](docs/GettingStarted.md), [วิธีติดตั้ง](docs/Integration.md), [โครงสร้างและจุดระวัง](docs/Architecture.md), [วิธีตรวจสอบ](docs/ValidationGuide.md)
- สกิลอยู่ที่ [skills/pearl-ui](skills/pearl-ui/SKILL.md) คัดลอกทั้งโฟลเดอร์ไป `~/.codex/skills/pearl-ui` แล้วเรียก `$pearl-ui` พร้อมตำแหน่งโปรเจกต์ มีคู่มือ API, defaults, คอนฟิก, persistence และแนวทางแก้บั๊กอยู่ในตัว
- สร้างไฟล์พร้อมใช้: `python tools/build.py`; ซิงก์คู่มือ: `python tools/sync_skill.py`; ตรวจความสอดคล้อง: `python tools/validate_metadata.py`

UI Library สำหรับ Roblox สไตล์ macOS โทนเงินเทา มุมมน แถบข้างโปร่งแสง และปุ่มหน้าต่างสามสี เขียนด้วย Luau ใช้ได้จาก LocalScript ใน Roblox Studio

เวอร์ชัน **0.8.0** นำฟังก์ชันสาธารณะทั้ง **76 เมธอด** มาแสดงในตัวทดสอบ รวม **7 แท็บ 14 section และคอนโทรลเริ่มต้น 102 ตัว** เพิ่ม Components, Window lab และ API tools ให้กดลองพร้อมดูค่า callback และผลลัพธ์จริง

อ่านวิธีลองแต่ละหมวดใน [คู่มือตัวทดสอบ](docs/Showcase.md) และดูตำแหน่งของทุก API ใน [ShowcaseAPI.json](docs/ShowcaseAPI.json) การทดสอบ lifecycle/config/storage ใช้หน้าต่าง sample และ memory adapter แยกจากคอนฟิกจริง

เวอร์ชัน **0.7.0** เพิ่มตัวจัดการคอนฟิกในแท็บ **Profiles**: เลือกจากรายการ สร้าง บันทึก โหลด เปลี่ยนชื่อ ลบแบบยืนยัน นำเข้า–ส่งออก JSON และตั้ง Auto-load โดยแยกรายชื่อกับค่าล่าสุดตามเกม พร้อมย้ายโปรไฟล์เดิมเข้าระบบใหม่

ดูขั้นตอนและ API ใน [คู่มือคอนฟิก](docs/Configs.md) การเลือกชื่อไม่โหลดค่าทันที ต้องกด Load; การแก้ค่าจะแสดงสถานะ edited จนกด Save changes เพื่ออัปเดตคอนฟิกนั้น

เวอร์ชัน **0.6.0** เพิ่มการจำค่าข้ามเซสชันด้วย auto-save พร้อมสถานะบันทึก ปุ่ม Save now/Reload รีเซ็ตแยก Appearance/Controls/Layout/All พร้อมหน้าต่างยืนยัน และปุ่ม **Use theme color** เพื่อคืนสี Accent ตามธีม

เดโม standalone บันทึกไฟล์ใน workspace ของสภาพแวดล้อมที่รองรับ file adapter ส่วนไฟล์ Studio มีตัวเชื่อม DataStore ฝั่ง server ให้แล้ว ต้องใช้กับเกมที่ตั้งค่า DataStore พร้อมใช้งาน ดู [คู่มือระบบบันทึกและรีเซ็ต](docs/Persistence.md)

เวอร์ชัน **0.5.1** เพิ่ม **Forest** โทนเขียวมืด รวมทั้งหมด 9 ธีม เลือกที่ **General → Interface → Theme → Forest** และบันทึกลงโปรไฟล์ได้

เวอร์ชัน **0.5.0** เพิ่ม 6 ธีม รวมทั้งหมด 8 แบบ เลือกได้ที่ **General → Interface → Theme** สีของหน้าต่าง พาแนลย่อย Dock เมนู และแจ้งเตือนเปลี่ยนตามกัน และบันทึกชื่อธีมลงโปรไฟล์ได้ โดยสี Accent ที่กำหนดเองจะยังอยู่

| ธีม | โทนสี |
|---|---|
| Light | เงินขาว |
| Dark | เทาเข้ม |
| Midnight | น้ำเงินกลางคืน |
| Graphite | เทาถ่าน |
| Lavender | ม่วงพาสเทล |
| Rose | ชมพูนุ่ม |
| Matcha | เขียวครีม |
| Ocean | น้ำเงินอมเขียวเข้ม |
| Forest | เขียวมืด |

เวอร์ชัน **0.4.3** แก้ Dock สีขาวค้างหลังโหลดโปรไฟล์ เปิดให้ปุ่ม Preview แสดงแจ้งเตือนตัวอย่างได้แม้ปิด Show notifications และปรับปุ่ม Open detached panel ให้ข้อความไม่ล้นและเรียกพาแนลขึ้นหน้า

เวอร์ชัน **0.4.2** แก้พาแนลที่แยกจากคอลัมน์ขวาหรือแถวล่างแล้วเนื้อหาถูกตัด โดยเริ่มตำแหน่งเนื้อหาภายในพาแนลใหม่และให้เลื่อนแนวตั้งเท่านั้น

เวอร์ชัน **0.4.1** แก้พาแนลหายหลัง Dock/เปลี่ยนแท็บ/ซ่อนหน้าหลัก แก้ไฮไลต์แท็บค้างระหว่างเฟด จัดลำดับพาแนลซ้อนและ popup ให้ถูกต้อง พร้อมยกเลิกอินพุตที่ค้างและล้างคอนโทรลที่สร้างไม่สำเร็จ

เวอร์ชัน **0.4.0** จัด section เป็นสองคอลัมน์ซ้าย–ขวา โดยเดโมมี 4 แท็บ แท็บละ 2 section พร้อมการ์ดผู้ใช้มุมล่างซ้ายที่ดึงรูปตัวละคร Display Name และ @Username ของ LocalPlayer อัตโนมัติ เมื่อหน้าต่างแคบจะเรียงเป็นคอลัมน์เดียวให้คอนโทรลยังอ่านและกดได้

เวอร์ชัน **0.3.0** เพิ่ม API จัดการคอนโทรลรายตัว, Color Picker แบบ HSV/HEX/RGB พร้อม alpha, Dropdown ที่ค้นหาและเลือกหลายค่าได้ และบันทึก layout รวมในโปรไฟล์ เดโมมีคอนโทรลเริ่มต้น 34 ตัว

## เปิดเดโม

1. เปิด `dist/PearlUI-Demo.rbxlx` ด้วย Roblox Studio
2. กด **Play / F5** เพื่อแสดง UI
3. กด **RightShift** เพื่อซ่อนหรือแสดงหน้าต่าง

ปุ่มแดงซ่อนหน้าต่าง ปุ่มเหลืองย่อเป็น mini dock ปุ่มเขียวขยายหรือคืนขนาดเดิม ใช้ปุ่มใน mini dock เปิดกลับได้ ลากแถบชื่อด้านบนเพื่อย้ายหน้าต่าง และลากจุดจับมุมขวาล่างเพื่อย่อ–ขยาย เนื้อหาภายในเลื่อนได้เมื่อหน้าต่างเล็กลง

mini dock เริ่มต้นกึ่งกลาง **ชิดขอบบนสุด** โดยใช้ UI layer แยกที่ไม่เว้นพื้นที่แถบระบบ Roblox สามารถลากได้จากพื้นแถบ ปุ่ม Open หรือปุ่มไอคอน คลิกสั้นยังเปิดหน้าต่าง/แท็บตามเดิม ส่วนการลากเกิน 6 พิกเซลจะไม่กระตุ้นปุ่มตอนปล่อยเมาส์ ตำแหน่งที่ลากไว้จะคงอยู่ตลอดอายุ window รวมถึงเมื่อเปิดหน้าต่างแล้วย่อกลับ

ลากแถบไปใกล้ขอบซ้ายหรือขวาแล้วปล่อยเพื่อ **พับซ่อนด้านข้าง** จะเหลือหูจับกว้าง 22 logical pixels ให้คลิกเพื่อเรียกแถบกลับ หรือลากหูจับเข้าด้านในจอเพื่อดึงแถบออกมาโดยตรง การซ่อนจะจำข้างและความสูงไว้ใน window เดิม แม้เปลี่ยน viewport หรือเปิดหน้าต่างแล้วย่อกลับ ส่วนอุปกรณ์ที่มี notch ยังเคารพ DeviceSafeInsets

เวอร์ชัน 0.1.1 เอาแถว Interface scale ออกจากเดโมแล้ว และแก้มุม sidebar ให้โค้งตรงกับกรอบหน้าต่าง

เวอร์ชัน **0.2.0** เพิ่มแอนิเมชันเปิด–ปิด/ย่อ–คืนหน้าต่าง เปลี่ยนแท็บ แยก–รวมพาเนล dropdown และแจ้งเตือน พร้อมเอฟเฟกต์ hover/press/focus ของคอนโทรล สีธีมและ accent เปลี่ยนแบบไล่สี slider เปลี่ยนค่าจากโค้ดแบบ tween ส่วนการลากจะตามเมาส์ทันที

ปรับจังหวะได้ที่ General > Controls > Animation speed และปิดการเคลื่อนไหวด้วย Reduce motion หรือกำหนด `ReduceMotion = true` ตอนสร้าง window ค่าเริ่มต้น 0.2 วินาที ใช้ Quint easing และยกเลิกแอนิเมชันเดิมเมื่อมีเป้าหมายใหม่

กดไอคอนลูกศรมุมขวาของแต่ละ section เพื่อแยกเป็น floating panel กด **Dock panel** เพื่อรวมกลับ พาเนลที่แยกอยู่จะซ่อนและแสดงพร้อมหน้าต่างหลัก

## ใช้ในเกมของคุณ

1. นำ `dist/PearlUI.rbxmx` เข้า Studio แล้ววาง ModuleScript ชื่อ `PearlUI` ใน `ReplicatedStorage`
2. เพิ่ม LocalScript ใน `StarterPlayer > StarterPlayerScripts`
3. เรียกใช้ตามตัวอย่างนี้

```lua
local PearlUI = require(game:GetService("ReplicatedStorage"):WaitForChild("PearlUI"))

local window = PearlUI.new({
    Title = "My Library",
    Theme = "Light", -- ดูชื่อทั้งหมดด้วย PearlUI.GetThemes()
    ToggleKey = Enum.KeyCode.RightShift,
    AnimationSpeed = 0.2,
    ReduceMotion = false,
    Columns = 2, -- ตั้ง 1 เพื่อใช้คอลัมน์เดียว
})

local general = window:Tab({
    Name = "General",
    Icon = "settings-2", -- ชื่อ Lucide ที่แนบมา หรือ alias general
    Description = "Your workspace, your way.",
})

local section = general:Section("Interface")
local enabled = section:Toggle({
    Id = "enabled",
    Label = "Enabled",
    Default = true,
    Callback = function(value)
        print("Enabled:", value)
    end,
})

section:Slider({
    Id = "volume", Label = "Volume",
    Min = 0, Max = 100, Step = 1, Default = 50, Suffix = "%",
    Callback = function(value) print(value) end,
})

section:Dropdown({
    Id = "theme", Label = "Theme",
    Options = PearlUI.GetThemes(), Default = "Light",
    Callback = function(theme) window:SetTheme(theme) end,
})

section:Input({ Id = "name", Label = "Name", Default = "Default", MaxLength = 32 })
section:Keybind({
    Id = "shortcut", Label = "Shortcut", Default = "F2",
    OnPressed = function() print("F2 pressed") end,
})
section:Button({
    Label = "Save setup", Text = "Save", Primary = true,
    Callback = function()
        window:SaveProfile("Default")
        window:Notify({ Title = "Saved", Description = "Your setup is ready." })
    end,
})

enabled:Set(false)       -- เรียก callback ด้วย
enabled:Set(true, true)  -- เปลี่ยนค่าโดยไม่เรียก callback
print(enabled:Get())
```

## API ที่ใช้บ่อย

| Method | การทำงาน |
| --- | --- |
| `window:Tab({Name, Icon, Description})` | เพิ่มแท็บ |
| `tab:Section("Title")` | เพิ่มกลุ่มคอนโทรล |
| `tab:Section({Title = "Settings", Column = "Left" / "Right"})` | กำหนดฝั่งของ section |
| `section:Toggle / Slider / Dropdown / ColorPicker / Input / Keybind / Button / Label(options)` | เพิ่มคอนโทรล |
| `control:Get()` / `control:Set(value, silent?)` | อ่านหรือเปลี่ยนค่า |
| `control:OnChanged(callback)` | กำหนด callback ใหม่ |
| `control:SetDisabled(boolean, reason?)` | ปิด/เปิดใช้งาน พร้อมคำอธิบายเมื่อชี้เมาส์ |
| `control:SetVisible(boolean)` | ซ่อน/แสดงคอนโทรล โดยค้นหาแล้วไม่เปิดกลับเอง |
| `control:SetLabel(text)` | เปลี่ยนชื่อโดยรักษา Id เดิม |
| `control:Destroy()` | ลบรายตัว พร้อมถอด handlers และคืน Id |
| `dropdown:SetOptions(options, default?)` | เปลี่ยนรายการ และรักษาค่าที่เลือกซึ่งยังอยู่ในรายการ |
| `dropdown:Open()` / `picker:Open()` / `control:Close()` | เปิด/ปิด editor ของคอนโทรล |
| `picker:SetAlpha(0 … 1, silent?)` | ปรับ alpha ของสี |
| `picker:SetHSV(h, s, v, silent?)` | ปรับ HSV แต่ละค่าช่วง 0 … 1 |
| `section:Detach()` / `section:Dock()` | แยกหรือรวมพาเนล |
| `section:Reveal()` | เปิดหน้าหลักหากซ่อน/ย่อ และนำพาแนลย่อยขึ้นด้านหน้า |
| `window:SetTheme(name)` | เปลี่ยนหนึ่งใน 9 ธีม เช่น Midnight หรือ Matcha |
| `PearlUI.GetThemes()` | คืนรายชื่อธีมเรียงลำดับ แก้ตารางที่คืนมาได้โดยไม่เปลี่ยน catalog |
| `window:SetAccent(Color3)` | เปลี่ยนสี accent |
| `window:SetScale(0.65 … 1.3)` | เปลี่ยนสเกล พร้อมจำกัดให้พอดีจอ |
| `window:SetSize(width, height)` | ปรับขนาดหน้าต่าง หน่วย logical pixel ช่วง 680×420 ถึง 1440×1000 |
| `window:SetColumns(1 / 2)` | ตั้งจำนวนคอลัมน์ที่ต้องการ โดยจอแคบจะปรับเหลือหนึ่ง |
| `window:RefreshUserProfile()` | อ่านชื่อและโหลดรูปตัวละครของผู้ใช้ปัจจุบันใหม่ |
| `window:SetOpacity(0.75 … 1)` | เปลี่ยนความทึบของพาเนล |
| `window:SetToggleKey(Enum.KeyCode.F4)` | เปลี่ยนปุ่มซ่อน/แสดง |
| `window:SetVisible(boolean)` | ซ่อน/แสดง |
| `window:SetMinimized(boolean)` | ย่อ/คืนจาก mini dock |
| `window:StowDock("Left" / "Right")` | พับแถบย่อซ่อนไว้ขอบซ้าย/ขวา |
| `window:RevealDock()` | เรียกแถบย่อกลับจากขอบจอ |
| `window:SetMaximized(boolean)` | ขยาย/คืนขนาด |
| `window:SelectTab(tabOrName)` | เลือกแท็บ |
| `window:Notify({Title, Description, Duration, Preview})` | แจ้งเตือนปกติเคารพ NotificationsEnabled; ใช้ Preview=true เพื่อแสดงตัวอย่างโดยไม่เปลี่ยนค่าที่ตั้งไว้ |
| `window:SaveProfile(name)` / `window:LoadProfile(name)` | เก็บ/โหลดโปรไฟล์ใน session |
| `window:ExportProfile()` / `window:ImportProfile(json)` | ส่งออก/นำเข้า JSON |
| `window:GetLayout()` / `window:ExportLayout()` | อ่าน layout เป็น table / JSON |
| `window:ImportLayout(tableOrJson)` | ตรวจสอบและคืน layout |
| `window:Destroy()` | ลบ UI และ disconnect input listeners |

กำหนด `Id` ที่ไม่ซ้ำและคงที่ให้คอนโทรลที่ต้องเก็บค่าในโปรไฟล์ หากไม่กำหนด ระบบใช้ชื่อแท็บ ชื่อ section และ label รวมกัน

## การจัดสองคอลัมน์และโปรไฟล์ผู้ใช้

```lua
local left = general:Section({ Id = "interface", Title = "Interface", Column = "Left" })
local right = general:Section({ Id = "controls", Title = "Controls", Column = "Right" })
left:Toggle({ Id = "twoColumnEnabled", Label = "Enabled", Default = true })
right:Keybind({ Id = "twoColumnMenu", Label = "Toggle menu", Default = "RightShift" })
```

เมื่อไม่กำหนด Column ระบบจะสลับ Left/Right ตามลำดับ section ภายในแท็บ การ์ดในแต่ละฝั่งเรียงต่อกันแยกกัน และเลื่อนด้วย scrolling page เดียว ถ้าพื้นที่เนื้อหาแคบกว่า 580 logical pixels จะเรียงคอลัมน์เดียว กรณีการ์ดแคบ label จะอยู่เหนือช่องกรอก/ตัวเลือกเพื่อไม่ให้เบียดกัน ผลการค้นหาจะเรียงเริ่มจากฝั่งซ้าย และคืนฝั่งเดิมเมื่อเลิกค้นหา

การ์ดผู้ใช้ด้านล่าง sidebar แสดงรูป AvatarBust ผ่าน `Players:GetUserThumbnailAsync()` พร้อม DisplayName และ Name ของ LocalPlayer มีตัวอักษรสำรองขณะโหลดรูป และถอดตัวสำรองออกเมื่อรูปพร้อม ชื่อยาวถูกตัดด้วย ellipsis ข้อความใต้การ์ดแสดงปุ่มลัดปัจจุบัน ส่วนเลขเวอร์ชันยังดูได้จากแท็บ Controls > Workspace

คอนโทรลรับ `Disabled`, `DisabledReason`, `Visible` ตั้งแต่สร้างได้ การ disable จะบล็อกอินพุตจาก UI แต่ยังใช้ `Set()` จากโค้ดเพื่ออัปเดตค่าได้ `Destroy()` เรียกซ้ำได้ แต่ setter หลังจาก destroy จะรายงานข้อผิดพลาด โปรไฟล์จะไม่บันทึกคอนโทรลที่ถูกลบแล้ว

## Color Picker และการเลือกหลายค่า

```lua
local picker = section:ColorPicker({
    Id = "accent", Label = "Accent", Default = "#0071F6", Alpha = 0.8,
    Callback = function(color, alpha)
        -- color เป็น Color3; alpha ช่วง 0 ถึง 1
        window:SetAccent(color)
    end,
})

local color, alpha = picker:Get()
picker:Set("#F8A") -- รับ HEX แบบ 3 หรือ 6 หลัก หรือ Color3
picker:Set({ Hex = "#CC66FF", Alpha = 0.6 })
picker:SetAlpha(0.5)

local favorites = section:Dropdown({
    Id = "favorites", Label = "Favorites", Multi = true, Searchable = true,
    Options = { "Appearance", "Controls", "Profiles" },
    Default = { "Appearance", "Profiles" },
    Callback = function(values) print(table.concat(values, ", ")) end,
})

favorites:Set({ "Controls", "Profiles" })
local selected = favorites:Get() -- คืนสำเนา array
favorites:SetOptions({ "Controls", "Profiles", "Notifications" })
```

Color Picker มีพื้นที่เลือก saturation/value, แถบ hue/alpha และช่อง HEX/RGB ตรวจค่าก่อนเปลี่ยนจริง ช่องสีจะแสดง checkerboard เมื่อโปร่งใส ส่วน callback สามารถเปลี่ยน accent ได้โดยไม่ปิด editor

Dropdown เปิดค้นหาเป็นค่าเริ่มต้น ตั้ง `Searchable = false` เพื่อซ่อนช่องค้นหา เมื่อใช้ `Multi = true` ค่าและ callback จะเป็น array รายการที่เลือกเรียงตาม Options และไม่ซ้ำกัน การเลือกหลายค่าจะคง popup ไว้ มี Clear และ Done ให้ใช้งาน

## บันทึก layout

```lua
local layoutJson = window:ExportLayout()
-- เก็บ JSON ผ่านระบบ persistence ของโปรเจ็กต์คุณ
local success, message = window:ImportLayout(layoutJson)
if not success then warn(message) end
```

Layout จำขนาดและตำแหน่งหน้าต่าง จำนวนคอลัมน์ที่เลือก สถานะขยาย/ย่อ/ซ่อน แท็บล่าสุด ตำแหน่ง dock และข้างที่พับซ่อน รวมถึง section ที่แยกเป็นพาเนล ใช้พิกัดสัดส่วนและจำกัดให้อยู่ในจอเมื่อขนาด viewport เปลี่ยน กำหนด Id ให้ section เช่น `tab:Section({Id = "appearance", Title = "Appearance"})` เพื่ออ้างอิงข้ามเวอร์ชันได้คงที่

`SaveProfile()` และ `ExportProfile()` รวม layout ไปด้วยอัตโนมัติ `ImportProfile()` ตรวจ layout ก่อนเปลี่ยนค่าคอนโทรล โปรไฟล์รุ่นก่อนที่ไม่มี layout ยังโหลดได้ การคืน layout อาจสลับแท็บ ย่อหน้าต่าง หรือแสดงหูจับด้านข้างตามสถานะที่บันทึก

`Callback` ของคอนโทรลไม่ถูกเรียกตอนสร้างครั้งแรก `Keybind.Callback` ใช้เมื่อเปลี่ยนปุ่ม ส่วน `OnPressed` ใช้เมื่อกดปุ่มนั้นจริง การพิมพ์ใน TextBox จะไม่สั่ง hotkey ส่วน Escape ยกเลิกการเลือก keybind ใหม่

เมื่อเปิด motion ค่าสถานะและ callback จะเปลี่ยนทันที ส่วนภาพจะเคลื่อนไปหาค่าใหม่ การซ่อนหน้าต่าง/dropdown/แจ้งเตือนจะรอเฟดจบก่อนซ่อนหรือลบจริง `section:Dock()` นำเนื้อหากลับเข้าหน้าที่เป็นเจ้าของทันที แล้วเฟดกรอบพาแนลย่อยที่ว่างออก ใช้ `ReduceMotion = true` เมื่อ integration ต้องการให้ภาพเปลี่ยนทันทีเช่นกัน `Destroy()` ยกเลิก tweens และงานที่รอทั้งหมด

## โปรไฟล์

เดโมเก็บโปรไฟล์ในหน่วยความจำ **เฉพาะ session นี้** ออกจากเกมแล้วค่าจะหาย การเก็บข้าม session ให้ส่ง JSON จาก `ExportProfile()` ผ่านระบบ server ของเกม แล้วนำกลับมาด้วย `ImportProfile()` ระบบตรวจชนิดข้อมูลและค่าทั้งเอกสารก่อนนำไปใช้

`ImportProfile` และ `LoadProfile` คืน `success, errorMessage` ให้ตรวจผลลัพธ์ก่อนแสดงข้อความสำเร็จ Callback ของคอนโทรลจะถูกเรียกตอนโหลด เพื่อให้ระบบที่เชื่อมต่ออยู่ปรับตามค่าที่โหลด

## ไอคอน

ใช้ต้นฉบับจาก **[Lucide Icons](https://lucide.dev/icons)** ตามรายการที่เลือกให้ เก็บ SVG และ license ใน `assets/lucide/` และฝัง geometry พร้อม notice ใน ModuleScript แล้ว ไอคอนเปลี่ยนสีตามธีม ไม่ใช้ HTTP, asset ID หรือฟอนต์สัญลักษณ์ตอนรัน

| ตำแหน่ง | Lucide icon |
| --- | --- |
| General | `settings-2` |
| Appearance | `palette` |
| Controls | `sliders-horizontal` |
| Profiles | `layers` |
| ค้นหา | `search` |
| แยกพาเนล | `arrow-up-right` |
| Dropdown | `chevron-down` |
| Section grip | `grip-vertical` |
| แจ้งเตือนสำเร็จ | `check` |
| ปิดแจ้งเตือน | `x` |
| ไอคอนเสริม | `panel-left` |

`Icon` ของแท็บรับชื่อข้างต้น และ alias `general`, `appearance`, `controls`, `profiles` ได้ ลายเส้นส่วนโค้งจาก SVG ถูกแปลงเป็นช่วงเส้นสั้นเพื่อวาดด้วย Roblox UI ส่วนวงกลมใช้ UIStroke โดยตรง

## โครงสร้างโปรเจ็กต์

```text
src/PearlUI.luau             ไลบรารีแบบ ModuleScript ไฟล์เดียว
examples/Demo.client.luau    ตัวอย่างสี่แท็บและคอนโทรลเริ่มต้น 34 ตัว
assets/lucide/              ต้นฉบับไอคอน ไลเซนส์ และ source commit
tests/Runtime.spec.luau      ชุดทดสอบบน Roblox client
tests/Animation.spec.luau    ทดสอบ motion และการสั่งซ้ำระหว่างทรานซิชัน
tests/Dock.spec.luau         ทดสอบซ่อนแถบด้านข้างและเรียกกลับ
tests/Features.spec.luau     ทดสอบ API คอนโทรล สี รายการหลายค่า และ layout
tests/FeatureMotion.spec.luau ทดสอบฟีเจอร์ใหม่ระหว่างแอนิเมชัน
tests/ColumnsProfile.spec.luau ทดสอบคอลัมน์ responsive และการ์ดผู้ใช้
tools/build_icons.py        แปลง SVG เป็นข้อมูล Luau
tools/build.py              สร้างไฟล์สำหรับเปิดใน Studio
dist/                       Module, demo place และ standalone demo source
default.project.json        สำหรับผู้ใช้ Rojo
```

## Build

ต้องการ Python 3 เท่านั้น ไม่ต้องติดตั้ง package เพิ่ม:

```sh
python tools/build_icons.py
python tools/build.py
```

ถ้าใช้ Rojo สามารถใช้ `rojo serve` หรือ `rojo build -o PearlUI.rbxlx` ได้ตาม workflow ของคุณ

## การตรวจสอบและข้อจำกัด

- เวอร์ชัน 0.8.0 ผ่าน Showcase.spec.luau **45 รายการ** และเทียบตำแหน่งทดสอบกับ API สาธารณะครบ 76 เมธอด

- คอมไพล์ source, demo และ runtime suite ด้วย Luau compiler ทางการ
- ชุดตรวจหลักเดิมเวอร์ชัน 0.7.0 ผ่าน **424/424 รายการ**: regression 50, motion 18, edge dock 16, features 52, feature motion 6, columns/profile 32 lifecycle audit 40 detached geometry 23 และ notification/dock 20 และ themes 59, settings 38, file adapter 11 และ server adapter 14 และ configs 45 (เวอร์ชัน 0.4.1 เคยผ่าน stress test สลับสถานะ 100 ครั้ง) ดูรายละเอียดใน `tests/VALIDATION.md`
- ทดสอบลากมุมเพื่อ resize และลาก title bar เพื่อย้ายหน้าต่างด้วยเมาส์จริงแล้ว
- Build script ตรวจ XML roundtrip ให้ source ของ ModuleScript และ LocalScript ตรงกับต้นฉบับ
- รองรับ mouse/touch ในตัวจัดการ input และสเกลพอดี viewport อัตโนมัติ การใช้งานบนอุปกรณ์ touch จริงและ gamepad ยังไม่ได้ทดสอบ
- ผิวกระจกใช้สีโปร่งแสงจำลอง ไม่ได้ทำ background blur เฉพาะหน้าต่างแบบ macOS
- ไลบรารี UI หลักทำงานฝั่ง client เดโมไม่มีระบบ gameplay; มีตัวเชื่อม server persistence แยกต่างหากสำหรับเกมของคุณ

อ้างอิง API: [GuiObject](https://create.roblox.com/docs/reference/engine/classes/GuiObject), [UIScale](https://create.roblox.com/docs/reference/engine/classes/UIScale), [Color3](https://create.roblox.com/docs/reference/engine/datatypes/Color3), [Players thumbnails](https://create.roblox.com/docs/reference/engine/classes/Players#GetUserThumbnailAsync)

โค้ด PearlUI ใช้ MIT License ไอคอน Lucide ใช้ ISC และบางชิ้นสืบทอด MIT จาก Feather ตาม notice ที่แนบมา

## จำค่าและคืนค่าเริ่มต้น

- Appearance → Personalization → **Use theme color** คืนสี Accent และให้สีเปลี่ยนตามธีมครั้งถัดไป
- Appearance → Personalization → **Reset…** รีเซ็ตเฉพาะธีม/สี/ความโปร่งใส
- Controls → Workspace → **Reset…** รีเซ็ตค่าคอนโทรลและคีย์ลัด
- Profiles → Transfer & storage → **Reset layout…** คืนตำแหน่งและรวมพาแนล
- Profiles → Transfer & storage → **Save now**, **Reload** และ **Reset all…**

ทุกปุ่มรีเซ็ตด้านบนต้องยืนยันก่อนนำค่าไปใช้ ยกเลิกได้ด้วย Cancel, Escape หรือคลิกนอกกล่อง และไม่ลบ named profiles

API หลัก: `CaptureDefaults()`, `RequestReset(scope)`, `Reset(scope)`, `Confirm(options)`, `ConfigurePersistence(options)`, `SaveSettings()`, `LoadSettings()`, `GetPersistenceStatus()` และ `DisablePersistence(flush)`

อ่านรายละเอียดอะแดปเตอร์ การสำรองไฟล์ และการตั้งค่า DataStore ใน [docs/Persistence.md](docs/Persistence.md)
