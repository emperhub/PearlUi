--!nocheck
-- Full renderer smoke: construct each icon individually, release its instances,
-- and yield between batches. Never put the entire catalog on screen at once.
return function(PearlUI)
    local w = PearlUI.new({Name = "PearlIconTest", ReduceMotion = true})
    w.Gui.Enabled, w.DockGui.Enabled = false, false
    local host = Instance.new("Frame")
    host.Visible, host.Parent = false, w.Root
    local count, aliases = 0, 0
    local ok, result = pcall(function()
        assert(table.isfrozen(PearlUI.Icons), "Catalog must be read-only")
        assert(table.isfrozen(PearlUI.IconAliases), "Aliases must be read-only")
        local previous
        for _,name in ipairs(PearlUI.Icons) do
            assert(not previous or previous < name, "Catalog is sorted and unique")
            previous = name
            local icon = w:_icon(host, name, "Text")
            assert(icon:GetAttribute("LucideIcon") == name, "Fallback used for " .. name)
            assert(#icon:GetChildren() > 0, "Empty icon " .. name)
            icon:Destroy()
            count += 1
            if count % 25 == 0 then w:_prune(); task.wait() end
        end
        for alias,canonical in pairs(PearlUI.IconAliases) do
            local icon = w:_icon(host, alias, "Text")
            assert(icon:GetAttribute("LucideIcon") == canonical, "Wrong alias " .. alias)
            icon:Destroy(); aliases += 1
            if aliases % 25 == 0 then w:_prune(); task.wait() end
        end
        for input,expected in pairs({ShieldCheck="shield-check",["lucide:ship"]="ship",["lucide-camera"]="camera",
            ["shield_check"]="shield-check",["not-a-real-icon"]="settings-2"}) do
            local icon = w:_icon(host, input, "Text")
            assert(icon:GetAttribute("LucideIcon") == expected, "Wrong normalized icon " .. input)
            icon:Destroy()
        end
        local tab = w:Tab({Name = "Documents", Icon = "folder-open"})
        assert(tab.Icon:GetAttribute("LucideIcon") == "folder-open", "Sidebar must use new catalog")
        assert(tab.DockButton.Icon:GetAttribute("LucideIcon") == "folder-open", "Dock must use new catalog")
        w:SetTheme("Forest")
        local sample = w:_icon(host, "shield-check", "Text")
        w:SetTheme("Light")
        local painted = 0
        for _,skin in ipairs(w._skins) do
            if skin[1]:IsDescendantOf(sample) then
                assert(skin[1][skin[2]] == w.Palette.Text, "Icon color must follow theme")
                painted += 1
            end
        end
        assert(painted > 0, "Theme test must inspect actual strokes")
        return {canonicalIcons = count, aliases = aliases, normalizedCases = 5, sidebarAndDock = true, themeRepaint = true}
    end)
    w:Destroy()
    assert(w.Gui.Parent == nil and w.DockGui.Parent == nil, "Test cleanup")
    if not ok then error(result) end
    return result
end
