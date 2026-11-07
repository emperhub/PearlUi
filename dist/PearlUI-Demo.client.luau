local PearlUI = (function()
--!nocheck
-- PearlUI v0.8.0 | MIT License | Client-side, dependency-free UI library.
local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

local PearlUI = { Version = "0.8.0" }
local Window, Tab, Section, Control = {}, {}, {}, {}
Window.__index, Tab.__index, Section.__index = Window, Tab, Section
Control.__index = Control
local FONT, MEDIUM = Enum.Font.Gotham, Enum.Font.GothamMedium
local WINDOW_RADIUS, CARD_RADIUS, FIELD_RADIUS = 14, 12, 7
local THEMES = {
	Light = {
		Window = Color3.fromRGB(244, 245, 249), Sidebar = Color3.fromRGB(231, 234, 242),
		Card = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(29, 31, 38),
		Muted = Color3.fromRGB(110, 115, 130), Border = Color3.fromRGB(213, 216, 226),
		Track = Color3.fromRGB(213, 217, 228), Field = Color3.fromRGB(247, 248, 252),
		Hover = Color3.fromRGB(226, 232, 244), Accent = Color3.fromRGB(0, 113, 246),
	},
	Dark = {
		Window = Color3.fromRGB(32, 34, 41), Sidebar = Color3.fromRGB(27, 29, 36),
		Card = Color3.fromRGB(43, 46, 55), Text = Color3.fromRGB(241, 242, 247),
		Muted = Color3.fromRGB(156, 161, 177), Border = Color3.fromRGB(65, 69, 82),
		Track = Color3.fromRGB(76, 81, 96), Field = Color3.fromRGB(36, 39, 48),
		Hover = Color3.fromRGB(55, 61, 76), Accent = Color3.fromRGB(61, 145, 255),
	},
	Midnight = {
		Window = Color3.fromRGB(17, 22, 36), Sidebar = Color3.fromRGB(13, 18, 30),
		Card = Color3.fromRGB(25, 32, 49), Text = Color3.fromRGB(232, 237, 248),
		Muted = Color3.fromRGB(155, 169, 192), Border = Color3.fromRGB(51, 66, 90),
		Track = Color3.fromRGB(55, 73, 99), Field = Color3.fromRGB(20, 27, 43),
		Hover = Color3.fromRGB(36, 47, 70), Accent = Color3.fromRGB(91, 101, 219),
	},
	Graphite = {
		Window = Color3.fromRGB(27, 28, 30), Sidebar = Color3.fromRGB(22, 23, 25),
		Card = Color3.fromRGB(37, 39, 42), Text = Color3.fromRGB(244, 244, 245),
		Muted = Color3.fromRGB(166, 170, 178), Border = Color3.fromRGB(62, 65, 71),
		Track = Color3.fromRGB(74, 78, 86), Field = Color3.fromRGB(31, 33, 36),
		Hover = Color3.fromRGB(48, 51, 56), Accent = Color3.fromRGB(90, 103, 184),
	},
	Lavender = {
		Window = Color3.fromRGB(243, 240, 250), Sidebar = Color3.fromRGB(232, 225, 245),
		Card = Color3.fromRGB(253, 251, 255), Text = Color3.fromRGB(45, 35, 63),
		Muted = Color3.fromRGB(112, 96, 134), Border = Color3.fromRGB(216, 204, 233),
		Track = Color3.fromRGB(218, 207, 235), Field = Color3.fromRGB(247, 242, 253),
		Hover = Color3.fromRGB(235, 225, 248), Accent = Color3.fromRGB(124, 78, 185),
	},
	Rose = {
		Window = Color3.fromRGB(250, 241, 242), Sidebar = Color3.fromRGB(244, 227, 231),
		Card = Color3.fromRGB(255, 251, 251), Text = Color3.fromRGB(64, 35, 43),
		Muted = Color3.fromRGB(132, 96, 105), Border = Color3.fromRGB(234, 210, 216),
		Track = Color3.fromRGB(232, 204, 212), Field = Color3.fromRGB(253, 245, 247),
		Hover = Color3.fromRGB(247, 226, 233), Accent = Color3.fromRGB(177, 65, 105),
	},
	Matcha = {
		Window = Color3.fromRGB(241, 245, 235), Sidebar = Color3.fromRGB(226, 234, 215),
		Card = Color3.fromRGB(252, 254, 247), Text = Color3.fromRGB(40, 52, 34),
		Muted = Color3.fromRGB(99, 116, 86), Border = Color3.fromRGB(207, 219, 194),
		Track = Color3.fromRGB(202, 217, 187), Field = Color3.fromRGB(244, 249, 237),
		Hover = Color3.fromRGB(227, 238, 213), Accent = Color3.fromRGB(77, 119, 52),
	},
	Forest = {
		Window = Color3.fromRGB(17, 29, 23), Sidebar = Color3.fromRGB(13, 23, 18),
		Card = Color3.fromRGB(25, 42, 32), Text = Color3.fromRGB(232, 244, 234),
		Muted = Color3.fromRGB(151, 179, 159), Border = Color3.fromRGB(47, 76, 57),
		Track = Color3.fromRGB(53, 88, 65), Field = Color3.fromRGB(20, 35, 26),
		Hover = Color3.fromRGB(33, 56, 41), Accent = Color3.fromRGB(55, 116, 74),
	},
	Ocean = {
		Window = Color3.fromRGB(15, 31, 39), Sidebar = Color3.fromRGB(11, 25, 32),
		Card = Color3.fromRGB(23, 43, 52), Text = Color3.fromRGB(230, 245, 247),
		Muted = Color3.fromRGB(145, 178, 186), Border = Color3.fromRGB(46, 76, 87),
		Track = Color3.fromRGB(53, 89, 101), Field = Color3.fromRGB(18, 36, 45),
		Hover = Color3.fromRGB(31, 59, 70), Accent = Color3.fromRGB(22, 119, 130),
	},
}
local THEME_ORDER = { "Light", "Dark", "Midnight", "Graphite", "Lavender", "Rose", "Matcha", "Ocean", "Forest" }

function PearlUI.GetThemes()
	return table.clone(THEME_ORDER)
end

local function make(class, properties, parent)
	local object = Instance.new(class)
	for key, value in pairs(properties or {}) do object[key] = value end
	object.Parent = parent
	return object
end

local function corner(object, radius)
	make("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, object)
end

local function label(parent, value, size, bold)
	return make("TextLabel", {
		BackgroundTransparency = 1, Text = value, Font = bold and MEDIUM or FONT,
		TextSize = size or 13, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.fromScale(1, 1),
	}, parent)
end

local function button(parent, value)
	return make("TextButton", {
		Text = value or "", Font = MEDIUM, TextSize = 12, AutoButtonColor = false,
		BorderSizePixel = 0, BackgroundTransparency = 1,
	}, parent)
end

local function padding(parent, horizontal, vertical)
	make("UIPadding", {
		PaddingLeft = UDim.new(0, horizontal), PaddingRight = UDim.new(0, horizontal),
		PaddingTop = UDim.new(0, vertical), PaddingBottom = UDim.new(0, vertical),
	}, parent)
end

local function list(parent, gap)
	return make("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, gap or 0),
	}, parent)
end

local function copy(value)
	local result = {}
	for key, item in pairs(value) do result[key] = item end
	return result
end

local function deepCopy(value)
	if type(value) ~= "table" then return value end
	local result = {}
	for key, item in pairs(value) do result[key] = deepCopy(item) end
	return result
end

local function finite(value)
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end

function Control:Get()
	assert(not self.Destroyed, "Control has been destroyed")
	return deepCopy(self.Value)
end

function Control:Serialize() return deepCopy(self.Value) end

function Control:Set(value, silent)
	assert(not self.Destroyed, "Control has been destroyed")
	if self.Validate then value = self.Validate(value) end
	self.Value = deepCopy(value)
	self:_render()
	if not silent then self.Window:_callback(self.Callback, self:Get()) end
	return self
end

function Control:OnChanged(callback)
	assert(not self.Destroyed and (callback == nil or type(callback) == "function"), "Invalid callback")
	self.Callback = callback
	return self
end

function Control:CanInteract()
	return not self.Destroyed and not self.Disabled and self.Visible and self.Row.Visible
end

function Control:_canOpenPopup()
	if not self:CanInteract() or not self.Window.Visible or self.Window.Minimized then return false end
	local object = self.Row
	while object and object ~= self.Window.Root do
		if object:IsA("GuiObject") and not object.Visible then return false end
		object = object.Parent
	end
	return object == self.Window.Root
end

function Control:_cancelInteraction()
	local window = self.Window
	if window._popupOwner == self or (window._popupAnchor and window._popupAnchor:IsDescendantOf(self.Row)) then window:_closeMenu() end
	if window._slider and window._slider.control == self then
		if window._slider.finish then window._slider.finish() end
		window._slider = nil
	end
	if window._colorDrag and window._colorDrag.control == self then window._colorDrag = nil end
	if window._capturing == self then window._capturing = nil; self:_render() end
	local focused = Input:GetFocusedTextBox()
	if focused and focused:IsDescendantOf(self.Row) then focused:ReleaseFocus() end
	if window._tooltipOwner == self then window:_hideTooltip() end
end

function Control:SetDisabled(disabled, reason)
	assert(not self.Destroyed, "Control has been destroyed")
	assert(reason == nil or type(reason) == "string", "Disabled reason must be a string")
	self.Disabled, self.DisabledReason = disabled == true, reason
	self.Row:SetAttribute("DisabledReason", reason)
	self.DisabledOverlay.Visible = self.Disabled
	if self.Disabled then self:_cancelInteraction() end
	if not self.Disabled and self.Window._tooltipOwner == self then self.Window:_hideTooltip() end
	for _, object in ipairs(self.Row:GetDescendants()) do
		if object:IsA("GuiButton") and object ~= self.DisabledOverlay then object.Interactable = not self.Disabled end
		if object:IsA("TextBox") then object.TextEditable = not self.Disabled end
	end
	return self
end

function Control:SetVisible(visible)
	assert(not self.Destroyed, "Control has been destroyed")
	self.Visible = visible == true
	if not self.Visible then self:_cancelInteraction() end
	self.Window:_filter(self.Window.Search.Text)
	return self
end

function Control:SetLabel(value)
	assert(not self.Destroyed and type(value) == "string", "Label must be a string")
	self.Label, self.LabelText.Text = value, value
	self.Window:_filter(self.Window.Search.Text)
	return self
end

function Control:Close()
	if self.Window._popupOwner == self then self.Window:_closeMenu() end
	return self
end

function Control:_layoutRow(compact)
	if self._compactLayout == compact then return end
	local field = self.Field or self.Row:FindFirstChild(self.Type)
	if not self._wideLayout then
		self._wideLayout = { Row = self.Row.Size, TitlePosition = self.LabelText.Position, TitleSize = self.LabelText.Size,
			FieldPosition = field and field.Position, FieldSize = field and field.Size,
			DescriptionPosition = self.DescriptionText and self.DescriptionText.Position, DescriptionSize = self.DescriptionText and self.DescriptionText.Size,
			ValuePosition = self.ValueText and self.ValueText.Position, ValueSize = self.ValueText and self.ValueText.Size }
	end
	self._compactLayout = compact
	local wide = self._wideLayout
	if not compact then
		self.Row.Size, self.LabelText.Position, self.LabelText.Size = wide.Row, wide.TitlePosition, wide.TitleSize
		if field then field.Position, field.Size = wide.FieldPosition, wide.FieldSize end
		if self.DescriptionText then self.DescriptionText.Position, self.DescriptionText.Size = wide.DescriptionPosition, wide.DescriptionSize end
		if self.ValueText then self.ValueText.Position, self.ValueText.Size = wide.ValuePosition, wide.ValueSize end
		return
	end
	local hasDescription = self.DescriptionText ~= nil
	if self.Type == "Toggle" then
		self.Row.Size = UDim2.new(1, 0, 0, hasDescription and 64 or 46)
		self.LabelText.Position = UDim2.fromOffset(0, hasDescription and 7 or 0)
		self.LabelText.Size = UDim2.new(1, -60, 0, hasDescription and 22 or 46)
		if hasDescription then self.DescriptionText.Position, self.DescriptionText.Size = UDim2.fromOffset(0, 30), UDim2.new(1, -60, 0, 18) end
	elseif self.Type == "Label" then
		self.LabelText.Size = UDim2.new(0.43, 0, wide.TitleSize.Y.Scale, wide.TitleSize.Y.Offset)
		if hasDescription then self.DescriptionText.Size = UDim2.new(0.43, 0, 0, 20) end
	else
		self.Row.Size = UDim2.new(1, 0, 0, (self.Type == "Slider" and 64 or 68) + (hasDescription and 20 or 0))
		self.LabelText.Position, self.LabelText.Size = UDim2.fromOffset(0, 4), UDim2.new(1, self.Type == "Slider" and -64 or 0, 0, 22)
		if hasDescription then self.DescriptionText.Position, self.DescriptionText.Size = UDim2.fromOffset(0, 26), UDim2.new(1, 0, 0, 18) end
		if field then field.Position, field.Size = UDim2.new(0, 0, 1, -34), UDim2.new(1, 0, 0, self.Type == "Slider" and 30 or 29) end
		if self.Type == "Slider" and self.ValueText then self.ValueText.Position, self.ValueText.Size = UDim2.new(1, -60, 0, 4), UDim2.fromOffset(60, 22) end
	end
end

function Control:_complete()
	self.Default = deepCopy(self.Value)
	for index = self._connectionStart + 1, #self.Window._connections do table.insert(self._ownedConnections, self.Window._connections[index]) end
	self._connectionStart = nil
	if self.Section.Detached then
		local objects = self.Row:GetDescendants(); table.insert(objects, self.Row)
		for _, object in ipairs(objects) do if object:IsA("GuiObject") then object:SetAttribute("PearlDockZ", object.ZIndex); object.ZIndex += 42 + (self.Section._panelLayer or 0) end end
	end
	if self.Section._availableWidth then self:_layoutRow(self.Section._availableWidth < 460) end
	self:SetDisabled(self.Disabled, self.DisabledReason)
	self.Window:_filter(self.Window.Search.Text)
	return self
end

function Control:Destroy()
	if self.Destroyed then return end
	self:_cancelInteraction()
	self.Destroyed = true
	for _, connection in ipairs(self._ownedConnections) do connection:Disconnect() end
	local objects = self.Row:GetDescendants(); table.insert(objects, self.Row)
	for _, object in ipairs(objects) do self.Window:_stop(object) end
	self.Window._refresh[self] = nil
	if self.Id then self.Window._ids[self.Id] = nil end
	local index = table.find(self.Window.Controls, self); if index then table.remove(self.Window.Controls, index) end
	index = table.find(self.Section.Controls, self); if index then table.remove(self.Section.Controls, index) end
	self.Row:Destroy()
	self._ownedConnections = {}
	self.Window:_prune()
	self.Window:_filter(self.Window.Search.Text)
end

function Window:_connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(self._connections, connection)
	return connection
end

function Window:_skin(object, property, role)
	object[property] = self.Palette[role]
	table.insert(self._skins, { object, property, role })
	return object
end

function Window:_border(object, radius)
	corner(object, radius)
	local line = make("UIStroke", { Thickness = 1, Transparency = 0.12, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, object)
	self:_skin(line, "Color", "Border")
	return object
end

function Window:_surface(object, role)
	self:_skin(object, "BackgroundColor3", role)
	object.BackgroundTransparency = 1 - self.Opacity
	table.insert(self._surfaces, object)
	return object
end

function Window:_text(parent, value, size, bold, role)
	return self:_skin(label(parent, value, size, bold), "TextColor3", role or "Text")
end

function Window:_duration(multiplier)
	return self.ReduceMotion and 0 or math.clamp(self.AnimationSpeed, 0.05, 0.6) * (multiplier or 1)
end

function Window:_stop(object, property)
	local slots = self._tweens[object]
	if not slots then return end
	local entries = {}
	if property then
		if slots[property] then entries[slots[property]] = true end
	else
		for _, entry in pairs(slots) do entries[entry] = true end
	end
	local surviving = {}
	for entry in pairs(entries) do
		entry.Cancelled = true
		if entry.Connection then entry.Connection:Disconnect() end
		for key, value in pairs(entry.Properties) do
			if slots[key] == entry then
				slots[key] = nil
				if property and key ~= property then surviving[key] = value end
			end
		end
		entry.Tween:Cancel()
	end
	if next(slots) == nil and self._tweens[object] == slots then self._tweens[object] = nil end
	if property and next(surviving) and not self.Destroyed and object.Parent then
		local writing = self._visibilityWriting; self._visibilityWriting = true
		self:_tween(object, surviving)
		self._visibilityWriting = writing
	end
end

function Window:_target(object, property)
	local slots = self._tweens[object]
	return slots and slots[property] and slots[property].Properties[property] or object[property]
end

function Window:_baseTarget(object, property)
	for _, state in pairs(self._visibility) do
		for _, entry in ipairs(state.Entries) do if entry.Object == object and entry.Properties[property] ~= nil then return entry.Properties[property] end end
	end
	return self:_target(object, property)
end

-- Retarget from the current rendered value; cancel stale completion callbacks.
function Window:_tween(object, properties, multiplier, finished)
	if self.Destroyed or not object.Parent then return end
	if not self._visibilityWriting then
		properties = copy(properties)
		for root, state in pairs(self._visibility) do
			if object == root or object:IsDescendantOf(root) then
				for property, value in pairs(properties) do
					if string.find(property, "Transparency", 1, true) then
						local record
						for _, entry in ipairs(state.Entries) do if entry.Object == object then record = entry; break end end
						if not record then record = { Object = object, Properties = {} }; table.insert(state.Entries, record) end
						record.Properties[property] = value
						if not state.Shown then properties[property] = 1 end
					end
				end
			end
		end
	end
	for property in pairs(properties) do self:_stop(object, property) end
	local duration = self:_duration(multiplier)
	if duration == 0 then
		for property, value in pairs(properties) do object[property] = value end
		if finished then finished() end
		return
	end
	local entry = { Properties = properties }
	entry.Tween = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties)
	local slots = self._tweens[object] or {}
	self._tweens[object] = slots
	for property in pairs(properties) do slots[property] = entry end
	entry.Connection = entry.Tween.Completed:Connect(function(state)
		if entry.Cancelled then return end
		for property in pairs(properties) do if slots[property] == entry then slots[property] = nil end end
		if next(slots) == nil and self._tweens[object] == slots then self._tweens[object] = nil end
		entry.Connection:Disconnect()
		if state == Enum.PlaybackState.Completed and not self.Destroyed and object.Parent and finished then finished() end
	end)
	entry.Tween:Play()
	return entry.Tween
end

function Window:_later(seconds, callback)
	local thread
	thread = task.delay(seconds, function()
		self._jobs[thread] = nil
		if not self.Destroyed then callback() end
	end)
	self._jobs[thread] = true
	return thread
end

function Window:_opacitySnapshot(root)
	local entries = {}
	local objects = root:GetDescendants()
	table.insert(objects, root)
	for _, object in ipairs(objects) do
		local properties = {}
		local function capture(property)
			local value = self:_target(object, property)
			if value < 1 then properties[property] = value end
		end
		if object:IsA("GuiObject") then capture("BackgroundTransparency") end
		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then capture("TextTransparency"); capture("TextStrokeTransparency") end
		if object:IsA("ImageLabel") or object:IsA("ImageButton") then capture("ImageTransparency") end
		if object:IsA("UIStroke") then capture("Transparency") end
		if object:IsA("ScrollingFrame") then capture("ScrollBarImageTransparency") end
		if next(properties) then table.insert(entries, { Object = object, Properties = properties }) end
	end
	return entries
end

function Window:_settleVisibility(root)
	local state = self._visibility[root]
	if not state then return end
	state.Token += 1
	for _, entry in ipairs(state.Entries) do
		if entry.Object.Parent and (entry.Object == root or entry.Object:IsDescendantOf(root)) then
			for property, value in pairs(entry.Properties) do self:_stop(entry.Object, property); entry.Object[property] = value end
		end
	end
	self:_stop(root, "Position")
	root.Position, root.Visible = state.Position, state.Shown
	self._visibility[root] = nil
end

-- Fade native properties rather than allocate a CanvasGroup texture while resizing.
function Window:_show(root, shown, force, finished, offset)
	if self.Destroyed then return end
	if root == self._popup and not root:GetAttribute("PearlPopupLayer") then
		root:SetAttribute("PearlPopupLayer", true)
		local objects = root:GetDescendants(); table.insert(objects, root)
		for _, object in ipairs(objects) do if object:IsA("GuiObject") then object.ZIndex += 9900 end end
	end
	local overlapping = {}
	for other in pairs(self._visibility) do
		if other ~= root and (root:IsDescendantOf(other) or other:IsDescendantOf(root)) then table.insert(overlapping, other) end
	end
	for _, other in ipairs(overlapping) do self:_settleVisibility(other) end
	local state = self._visibility[root]
	if self.ReduceMotion then
		self:_settleVisibility(root)
		root.Visible = shown
		if finished then finished() end
		return
	end
	if not state and root.Visible == shown and not force then if finished then finished() end; return end
	if not state then
		state = { Entries = self:_opacitySnapshot(root), Position = self:_target(root, "Position"), Token = 0 }
		self._visibility[root] = state
	else
		local captured = {}
		for _, entry in ipairs(state.Entries) do captured[entry.Object] = true end
		for _, entry in ipairs(self:_opacitySnapshot(root)) do if not captured[entry.Object] then table.insert(state.Entries, entry) end end
	end
	state.Token += 1
	state.Shown = shown
	local token = state.Token
	local shift = offset or Vector2.new(0, 10)
	local away = state.Position + UDim2.fromOffset(shift.X, shift.Y)
	if shown and (not root.Visible or force) then
		for _, entry in ipairs(state.Entries) do
			if entry.Object.Parent and (entry.Object == root or entry.Object:IsDescendantOf(root)) then
				for property in pairs(entry.Properties) do self:_stop(entry.Object, property); entry.Object[property] = 1 end
			end
		end
		root.Position = away
	end
	root.Visible = true
	for _, entry in ipairs(state.Entries) do
		if entry.Object.Parent and (entry.Object == root or entry.Object:IsDescendantOf(root)) then
			local goal = {}
			for property, value in pairs(entry.Properties) do goal[property] = shown and value or 1 end
			local writing = self._visibilityWriting; self._visibilityWriting = true
			self:_tween(entry.Object, goal)
			self._visibilityWriting = writing
		end
	end
	self:_tween(root, { Position = shown and state.Position or away }, 1, function()
		if self._visibility[root] ~= state or state.Token ~= token then return end
		root.Visible = shown
		root.Position = state.Position
		self:_settleVisibility(root)
		if finished then finished() end
	end)
end

function Window:_feedback(object, options)
	options = options or {}
	local overlay = make("Frame", { Name = "HoverTint", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = object.ZIndex + 1 }, object)
	corner(overlay, options.Radius or FIELD_RADIUS)
	self:_skin(overlay, "BackgroundColor3", "Accent")
	local scale
	if not options.NoScale then scale = make("UIScale", { Name = "PressScale", Scale = 1 }, object) end
	local hovered, pressed = false, false
	local function render()
		self:_tween(overlay, { BackgroundTransparency = pressed and 0.84 or hovered and 0.94 or 1 }, 0.6)
		if scale then self:_tween(scale, { Scale = pressed and 0.97 or 1 }, 0.55) end
	end
	self:_connect(object.MouseEnter, function() hovered = true; render() end)
	self:_connect(object.MouseLeave, function() hovered, pressed = false, false; render() end)
	self:_connect(object.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then pressed = true; render() end
	end)
	self:_connect(object.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then pressed = false; render() end
	end)
	return overlay
end

function Window:_focusFeedback(field)
	local line = field:FindFirstChildOfClass("UIStroke")
	self:_connect(field.Focused, function() self:_tween(line, { Color = self.Palette.Accent, Thickness = 1.5, Transparency = 0 }, 0.65) end)
	self:_connect(field.FocusLost, function() self:_tween(line, { Color = self.Palette.Border, Thickness = 1, Transparency = 0.12 }, 0.65) end)
end

function Window:_callback(callback, ...)
	if not callback then return end
	local ok, message = pcall(callback, ...)
	if not ok then warn("[PearlUI callback] " .. tostring(message)) end
end

function Window:_shadow(parent)
	local shadow = make("Frame", {
		Name = "SoftShadow", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.93,
		BorderSizePixel = 0, Position = UDim2.fromOffset(-7, -2), Size = UDim2.new(1, 14, 1, 18), ZIndex = 1,
	}, parent)
	corner(shadow, WINDOW_RADIUS + 6)
	local inner = make("Frame", {
		BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.94,
		BorderSizePixel = 0, Position = UDim2.fromOffset(4, 3), Size = UDim2.new(1, -8, 1, -8), ZIndex = 1,
	}, shadow)
	corner(inner, WINDOW_RADIUS + 3)
end

-- BEGIN LUCIDE DATA
--[[
Lucide Icons | https://lucide.dev | commit 53fab88ff9d1b48f4704b5b5b560d6b4d560bf4c
ISC License

Copyright (c) 2026 Lucide Icons and Contributors

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

---

The following Lucide icons are derived from the Feather project:

airplay, alert-circle, alert-octagon, alert-triangle, aperture, arrow-down-circle, arrow-down-left, arrow-down-right, arrow-down, arrow-left-circle, arrow-left, arrow-right-circle, arrow-right, arrow-up-circle, arrow-up-left, arrow-up-right, arrow-up, at-sign, calendar, cast, check, chevron-down, chevron-left, chevron-right, chevron-up, chevrons-down, chevrons-left, chevrons-right, chevrons-up, circle, clipboard, clock, code, columns, command, compass, corner-down-left, corner-down-right, corner-left-down, corner-left-up, corner-right-down, corner-right-up, corner-up-left, corner-up-right, crosshair, database, divide-circle, divide-square, dollar-sign, download, external-link, feather, frown, hash, headphones, help-circle, info, italic, key, layout, life-buoy, link-2, link, loader, lock, log-in, log-out, maximize, meh, minimize, minimize-2, minus-circle, minus-square, minus, monitor, moon, more-horizontal, more-vertical, move, music, navigation-2, navigation, octagon, pause-circle, percent, plus-circle, plus-square, plus, power, radio, rss, search, server, share, shopping-bag, sidebar, smartphone, smile, square, table-2, tablet, target, terminal, trash-2, trash, triangle, tv, type, upload, x-circle, x-octagon, x-square, x, zoom-in, zoom-out

The MIT License (MIT) (for the icons listed above)

Copyright (c) 2013-present Cole Bemis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
local ICONS = {
	["arrow-up-right"] = {
		{ {7,7}, {17,7}, {17,17} },
		{ {7,17}, {17,7} }
	},
	["check"] = {
		{ {20,6}, {9,17}, {4,12} }
	},
	["chevron-down"] = {
		{ {6,9}, {12,15}, {18,9} }
	},
	["grip-vertical"] = {
		{ Circle = {9,12,1}, Filled = false },
		{ Circle = {9,5,1}, Filled = false },
		{ Circle = {9,19,1}, Filled = false },
		{ Circle = {15,12,1}, Filled = false },
		{ Circle = {15,5,1}, Filled = false },
		{ Circle = {15,19,1}, Filled = false }
	},
	["layers"] = {
		{ {12.83,2.18}, {12,2}, {11.17,2.18}, {2.6,6.08}, {2.077,6.619}, {2.077,7.371}, {2.6,7.91}, {11.18,11.82}, {12.01,12}, {12.84,11.82}, {21.42,7.92}, {21.943,7.381}, {21.943,6.629}, {21.42,6.09}, {12.83,2.18} },
		{ {2,12}, {2.157,12.54}, {2.58,12.91}, {11.18,16.82}, {12.005,16.998}, {12.83,16.82}, {21.41,12.92}, {21.842,12.548}, {22,12} },
		{ {2,17}, {2.157,17.54}, {2.58,17.91}, {11.18,21.82}, {12.005,21.998}, {12.83,21.82}, {21.41,17.92}, {21.842,17.548}, {22,17} }
	},
	["palette"] = {
		{ {12,22}, {10.88,21.937}, {9.775,21.749}, {8.697,21.439}, {7.661,21.01}, {6.68,20.467}, {5.765,19.818}, {4.929,19.071}, {4.182,18.235}, {3.533,17.32}, {2.99,16.339}, {2.561,15.303}, {2.251,14.225}, {2.063,13.12}, {2,12}, {2.063,10.88}, {2.251,9.775}, {2.561,8.697}, {2.99,7.661}, {3.533,6.68}, {4.182,5.765}, {4.929,4.929}, {5.765,4.182}, {6.68,3.533}, {7.661,2.99}, {8.697,2.561}, {9.775,2.251}, {10.88,2.063}, {12,2}, {13.12,2.057}, {14.225,2.226}, {15.303,2.505}, {16.339,2.891}, {17.32,3.379}, {18.235,3.964}, {19.071,4.636}, {19.818,5.389}, {20.467,6.212}, {21.01,7.095}, {21.439,8.027}, {21.749,8.997}, {21.937,9.992}, {22,11}, {21.875,12.113}, {21.505,13.169}, {20.909,14.117}, {20.117,14.909}, {19.169,15.505}, {18.113,15.875}, {17,16}, {14.75,16}, {13.83,16.261}, {13.185,16.967}, {13.007,17.907}, {13.35,18.8}, {13.65,19.2}, {13.993,20.093}, {13.815,21.033}, {13.17,21.739}, {12.25,22}, {12,22} },
		{ Circle = {13.5,6.5,0.5}, Filled = true },
		{ Circle = {17.5,10.5,0.5}, Filled = true },
		{ Circle = {6.5,12.5,0.5}, Filled = true },
		{ Circle = {8.5,7.5,0.5}, Filled = true }
	},
	["panel-left"] = {
		{ Rect = {3,3,18,18,2} },
		{ {9,3}, {9,21} }
	},
	["search"] = {
		{ {21,21}, {16.66,16.66} },
		{ Circle = {11,11,8}, Filled = false }
	},
	["settings-2"] = {
		{ {14,17}, {5,17} },
		{ {19,7}, {10,7} },
		{ Circle = {17,17,3}, Filled = false },
		{ Circle = {7,7,3}, Filled = false }
	},
	["sliders-horizontal"] = {
		{ {10,5}, {3,5} },
		{ {12,19}, {3,19} },
		{ {14,3}, {14,7} },
		{ {16,17}, {16,21} },
		{ {21,12}, {12,12} },
		{ {21,19}, {16,19} },
		{ {21,5}, {14,5} },
		{ {8,10}, {8,14} },
		{ {8,12}, {3,12} }
	},
	["x"] = {
		{ {18,6}, {6,18} },
		{ {6,6}, {18,18} }
	},
}
-- END LUCIDE DATA

-- Lucide's original geometry is compiled offline into native Roblox strokes.
function Window:_icon(parent, kind, colorRole)
	local aliases = { general = "settings-2", appearance = "palette", controls = "sliders-horizontal", profiles = "layers", detach = "arrow-up-right" }
	local name = aliases[kind] or kind
	local data = ICONS[name] or ICONS["settings-2"]
	local canvas = make("Frame", { Name = "Icon", BackgroundTransparency = 1, Size = UDim2.fromOffset(20, 20) }, parent)
	canvas:SetAttribute("LucideIcon", name)
	for _, shape in ipairs(data) do
		if shape.Circle then
			local x, y, radius = table.unpack(shape.Circle)
			if shape.Filled then radius += 1 end
			local circle = make("Frame", { BackgroundTransparency = shape.Filled and 0 or 1, BorderSizePixel = 0, Position = UDim2.fromScale((x - radius) / 24, (y - radius) / 24), Size = UDim2.fromScale(radius / 12, radius / 12) }, canvas)
			corner(circle, 24)
			if shape.Filled then self:_skin(circle, "BackgroundColor3", colorRole or "Muted")
			else self:_skin(make("UIStroke", { Thickness = 1.5 }, circle), "Color", colorRole or "Muted") end
		elseif shape.Rect then
			local x, y, width, height, radius = table.unpack(shape.Rect)
			local rectangle = make("Frame", { BackgroundTransparency = 1, Position = UDim2.fromScale(x / 24, y / 24), Size = UDim2.fromScale(width / 24, height / 24) }, canvas)
			corner(rectangle, radius * 20 / 24)
			self:_skin(make("UIStroke", { Thickness = 1.5 }, rectangle), "Color", colorRole or "Muted")
		else
			for index = 2, #shape do
				local start, finish = shape[index - 1], shape[index]
				local dx, dy = finish[1] - start[1], finish[2] - start[2]
				local length = math.sqrt(dx * dx + dy * dy)
				if length > 0.001 then
					local segment = make("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0,
						Position = UDim2.fromScale((start[1] + finish[1]) / 48, (start[2] + finish[2]) / 48),
						Size = UDim2.fromScale((length + 0.6) / 24, 1.8 / 24), Rotation = math.deg(math.atan2(dy, dx)),
					}, canvas)
					corner(segment, 4); self:_skin(segment, "BackgroundColor3", colorRole or "Muted")
				end
			end
		end
	end
	return canvas
end

function Window:_prune()
	for index = #self._skins, 1, -1 do if not self._skins[index][1].Parent then table.remove(self._skins, index) end end
	for index = #self._surfaces, 1, -1 do if not self._surfaces[index].Parent then table.remove(self._surfaces, index) end end
	for index = #self._connections, 1, -1 do if not self._connections[index].Connected then table.remove(self._connections, index) end end
	for root, state in pairs(self._visibility) do
		if not root.Parent then self._visibility[root] = nil
		else for index = #state.Entries, 1, -1 do if not state.Entries[index].Object.Parent then table.remove(state.Entries, index) end end end
	end
end

function Window:_settleAncestors(object)
	local roots = {}
	for root in pairs(self._visibility) do if object == root or object:IsDescendantOf(root) or root:IsDescendantOf(object) then table.insert(roots, root) end end
	for _, root in ipairs(roots) do self:_settleVisibility(root) end
end

function Window:_raisePanel(section)
	self._panelStack = self._panelStack or {}
	local old = table.find(self._panelStack, section); if old then table.remove(self._panelStack, old) end
	table.insert(self._panelStack, section)
	local rank = 0
	for _, panel in ipairs(self._panelStack) do
		if panel.Detached and panel.Float then
			local layer = rank * 64; rank += 1; panel._panelLayer = layer
			local objects = panel.Float:GetDescendants(); table.insert(objects, panel.Float)
			for _, object in ipairs(objects) do
				if object:IsA("GuiObject") then
					if object == panel.Frame then object.ZIndex = 48 + layer
					elseif object:IsDescendantOf(panel.Frame) then object.ZIndex = (object:GetAttribute("PearlDockZ") or object.ZIndex) + 42 + layer
					else
						local base = object:GetAttribute("PearlFloatZ") or math.max(40, object.ZIndex)
						object:SetAttribute("PearlFloatZ", base); object.ZIndex = base + layer
					end
				end
			end
		end
	end
end

function Window:_cancelInteractions()
	if self._slider and self._slider.finish then self._slider.finish() end
	self._slider, self._dragging, self._resizing, self._colorDrag = nil, nil, nil, nil
	if self._capturing then local control = self._capturing; self._capturing = nil; if not control.Destroyed then control:_render() end end
	self:_closeMenu()
	local focused = Input:GetFocusedTextBox()
	if focused and (focused:IsDescendantOf(self.Root) or focused:IsDescendantOf(self.DockRoot)) then focused:ReleaseFocus() end
end

function Window:_hideTooltip()
	if self._tooltip then self._tooltip:Destroy(); self._tooltip = nil; self:_prune() end
	self._tooltipOwner = nil
end

function Window:_disabledTooltip(control)
	self:_hideTooltip()
	if not control.Disabled or not control.DisabledReason or control.Destroyed then return end
	local position = (control.Row.AbsolutePosition - self.Root.AbsolutePosition) / self._actualScale
	local tooltip = make("TextLabel", {
		Name = "DisabledReason", Text = control.DisabledReason, TextWrapped = true, Font = FONT, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.fromOffset(276, 48), BorderSizePixel = 0, ZIndex = 11000,
		Position = UDim2.fromOffset(math.clamp(position.X, 8, math.max(8, self._rootWidth - 284)), math.clamp(position.Y + control.Row.AbsoluteSize.Y / self._actualScale + 4, 8, math.max(8, self._rootHeight - 56))),
	}, self.Root)
	self:_surface(tooltip, "Card"); self:_skin(tooltip, "TextColor3", "Muted"); self:_border(tooltip, 8); padding(tooltip, 10, 6)
	self._tooltip, self._tooltipOwner = tooltip, control
end

function Window:_closeMenu()
	local menu = self._popup
	if self._popupOwner then self._popupOwner._menu = nil end
	if self._popupScrollConnection then self._popupScrollConnection:Disconnect(); self._popupScrollConnection = nil end
	local focused = Input:GetFocusedTextBox()
	if menu and focused and focused:IsDescendantOf(menu) then focused:ReleaseFocus() end
	self._popupOwner, self._colorDrag = nil, nil
	self._popup, self._popupAnchor = nil, nil
	if self._popupArrow then self:_tween(self._popupArrow, { Rotation = 0 }, 0.7); self._popupArrow = nil end
	if menu then self:_show(menu, false, false, function() self._visibility[menu] = nil; menu:Destroy(); self:_prune() end, Vector2.new(0, -6)) end
	self.MenuDismiss.Visible = false
end

function Window:_popupMenu(anchor, entries, chosen, onSelect, arrow)
	self:_closeMenu()
	local position = (anchor.AbsolutePosition - self.Root.AbsolutePosition) / self._actualScale
	local width = math.max(164, anchor.AbsoluteSize.X / self._actualScale)
	local height = math.min(#entries * 34 + 8, 212)
	local below = position.Y + anchor.AbsoluteSize.Y / self._actualScale + 5
	local y = below + height > self._rootHeight - 8 and position.Y - height - 5 or below
	local menu = make("ScrollingFrame", {
		Name = "DropdownMenu", Position = UDim2.fromOffset(math.clamp(position.X, 8, math.max(8, self._rootWidth - width - 8)), math.max(8, y)),
		Size = UDim2.fromOffset(width, height), BorderSizePixel = 0, ZIndex = 101,
		AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ScrollBarThickness = 3,
	}, self.Root)
	self:_surface(menu, "Card"); self:_border(menu, 9)
	padding(menu, 4, 4); list(menu, 0)
	self._popup = menu
	self._popupAnchor, self._popupArrow = anchor, arrow
	if arrow then self:_tween(arrow, { Rotation = 180 }, 0.7) end
	self.MenuDismiss.Visible = true
	for index, value in ipairs(entries) do
		local item = button(menu, tostring(value) .. (value == chosen and "   ✓" or ""))
		item.Name = "Option_" .. tostring(value)
		item.LayoutOrder, item.Size, item.ZIndex = index, UDim2.new(1, 0, 0, 34), 102
		item.TextXAlignment = Enum.TextXAlignment.Left; padding(item, 9, 0); corner(item, 6)
		self:_skin(item, "TextColor3", value == chosen and "Accent" or "Text")
		self:_skin(item, "BackgroundColor3", "Hover")
		item.BackgroundTransparency = value == chosen and 0 or 1
		self:_connect(item.MouseEnter, function() if self._popup == menu then self:_tween(item, { BackgroundTransparency = 0 }, 0.55) end end)
		self:_connect(item.MouseLeave, function() if self._popup == menu then self:_tween(item, { BackgroundTransparency = value == chosen and 0 or 1 }, 0.55) end end)
		self:_connect(item.Activated, function() if self._popup == menu then self:_closeMenu(); onSelect(value) end end)
	end
	self:_show(menu, true, true, nil, Vector2.new(0, -6))
end

function Window:_beginDrag(input, target, threshold)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	if target == self.Main and self.Maximized then return end
	self:_settleVisibility(target)
	self:_stop(target, "Position")
	if target == self.Main then self:_stop(target, "Size"); target.Size = UDim2.fromOffset(self.WindowSize.X, self.WindowSize.Y) end
	self:_closeMenu()
	local width, height = self._rootWidth, self._rootHeight
	if target == self.Dock then width, height = self._dockWidth, self._dockHeight end
	local position = UDim2.fromOffset(target.Position.X.Scale * width + target.Position.X.Offset, target.Position.Y.Scale * height + target.Position.Y.Offset)
	local fromEdge = target == self.Dock and self._dockSide or nil
	if fromEdge then position = self:_dockExpandedPosition(fromEdge) end
	self._dragging = { input = input, target = target, start = input.Position, position = position, threshold = threshold or 0, moved = false, fromEdge = fromEdge }
end

function Window:_drag(handle, target, threshold)
	self:_connect(handle.InputBegan, function(input) self:_beginDrag(input, target, threshold) end)
end

function Window:_dockClickAllowed()
	if self._confirmation then return false end
	local drag = self._dragging
	return not (drag and drag.target == self.Dock and drag.moved) and os.clock() >= (self._dockClickUntil or 0)
end

function Window:_clamp(frame)
	if frame == self.Dock then
		local half = self.Dock.Size.X.Offset / 2
		local dragging = self._dragging and self._dragging.target == self.Dock and self._dragging.moved
		local minimum = dragging and -half + 22 or half + 8
		local maximum = dragging and self._dockWidth + half - 22 or self._dockWidth - half - 8
		self.Dock.Position = UDim2.fromOffset(
			math.clamp(self.Dock.Position.X.Scale * self._dockWidth + self.Dock.Position.X.Offset, minimum, math.max(minimum, maximum)),
			math.clamp(self.Dock.Position.Y.Scale * self._dockHeight + self.Dock.Position.Y.Offset, 0, math.max(0, self._dockHeight - self.Dock.Size.Y.Offset))
		)
		return
	end
	local width, height = frame.Size.X.Offset, frame.Size.Y.Offset
	local anchor = frame.AnchorPoint
	local left = frame.Position.X.Scale * self._rootWidth + frame.Position.X.Offset - width * anchor.X
	local top = frame.Position.Y.Scale * self._rootHeight + frame.Position.Y.Offset - height * anchor.Y
	frame.Position = UDim2.fromOffset(
		math.clamp(left, 8, math.max(8, self._rootWidth - width - 8)) + width * anchor.X,
		math.clamp(top, 8, math.max(8, self._rootHeight - height - 8)) + height * anchor.Y
	)
end

function Window:_dockExpandedPosition(side)
	local half = self.Dock.Size.X.Offset / 2
	return UDim2.fromOffset(side == "Left" and half + 8 or self._dockWidth - half - 8, self.Dock.Position.Y.Offset)
end

function Window:_placeDockHandle()
	local y = math.clamp(self.Dock.Position.Y.Offset, 0, math.max(0, self._dockHeight - 54))
	self.DockHandle.Position = UDim2.fromOffset(self._dockSide == "Left" and 0 or self._dockWidth - 22, y)
	self.DockHandle.Icon.Rotation = self._dockSide == "Left" and -90 or 90
end

function Window:_dockOffscreenPosition(side)
	local half = self.Dock.Size.X.Offset / 2
	return UDim2.fromOffset(side == "Left" and -half - 8 or self._dockWidth + half + 8, math.clamp(self.Dock.Position.Y.Offset, 0, math.max(0, self._dockHeight - 54)))
end

function Window:_syncDock()
	local shown = not self.Visible or self.Minimized
	if self._dockSide then
		self:_settleVisibility(self.Dock)
		self:_stop(self.Dock, "Position")
		self.Dock.Position, self.Dock.Visible = self:_dockOffscreenPosition(self._dockSide), false
		self:_placeDockHandle()
		self:_show(self.DockHandle, shown)
	else
		self:_show(self.DockHandle, false)
		self:_show(self.Dock, shown)
	end
end

function Window:StowDock(side)
	assert(side == "Left" or side == "Right", "Dock side must be Left or Right")
	self:_settleVisibility(self.Dock)
	self:_settleVisibility(self.DockHandle)
	self:_stop(self.Dock, "Position")
	self._dockMoved, self._dockSide = true, side
	self:_placeDockHandle()
	local shown = not self.Visible or self.Minimized
	self:_show(self.DockHandle, shown, shown, nil, Vector2.new(0, 0))
	self:_tween(self.Dock, { Position = self:_dockOffscreenPosition(side) }, 1, function()
		if self._dockSide == side then self.Dock.Visible = false end
	end)
end

function Window:RevealDock(immediate)
	local side = self._dockSide
	if not side then return end
	self:_settleVisibility(self.Dock)
	self:_settleVisibility(self.DockHandle)
	self:_stop(self.Dock, "Position")
	local position = self:_dockExpandedPosition(side)
	self._dockSide = nil
	self.Dock.Visible = not self.Visible or self.Minimized
	self:_show(self.DockHandle, false, false, nil, Vector2.new(0, 0))
	if immediate then self.Dock.Position = position else self:_tween(self.Dock, { Position = position }) end
end

function Window:_beginResize(input)
	if self.Maximized or not self.Visible or self.Minimized then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	self:_settleVisibility(self.Main)
	self:_stop(self.Main)
	self.Main.Size = UDim2.fromOffset(self.WindowSize.X, self.WindowSize.Y)
	self:_closeMenu()
	self._dragging = nil
	self._resizing = { input = input, start = input.Position, size = self.WindowSize, scale = self._actualScale }
end

function Window:_updatePointer(input)
	local function follows(session)
		return session and (input == session.input or (input.UserInputType == Enum.UserInputType.MouseMovement and session.input.UserInputType == Enum.UserInputType.MouseButton1))
	end
	if follows(self._colorDrag) then self._colorDrag.update(input.Position.X, input.Position.Y) end
	if follows(self._resizing) then
		local resize = self._resizing
		local delta = (input.Position - resize.start) / resize.scale
		local maximumWidth = math.max(self.MinSize.X, math.min(self.MaxSize.X, self._rootWidth - self.Main.Position.X.Offset - 8))
		local maximumHeight = math.max(self.MinSize.Y, math.min(self.MaxSize.Y, self._rootHeight - self.Main.Position.Y.Offset - 8))
		self.WindowSize = Vector2.new(
			math.round(math.clamp(resize.size.X + delta.X, self.MinSize.X, maximumWidth)),
			math.round(math.clamp(resize.size.Y + delta.Y, self.MinSize.Y, maximumHeight))
		)
		self.Main.Size = UDim2.fromOffset(self.WindowSize.X, self.WindowSize.Y)
		return
	end
	if follows(self._slider) then self._slider.update(input.Position.X) end
	local drag = self._dragging
	if follows(drag) then
		local pixels = input.Position - drag.start
		if not drag.moved and pixels.Magnitude < drag.threshold then return end
		if not drag.moved and drag.fromEdge then self:RevealDock(true) end
		drag.moved = true
		if drag.target == self.Dock then self._dockMoved = true end
		local delta = pixels / self._actualScale
		drag.target.Position = UDim2.fromOffset(drag.position.X.Offset + delta.X, drag.position.Y.Offset + delta.Y)
		self:_clamp(drag.target)
	end
end

function Window:_endPointer(input)
	local function owns(session)
		return session and (input == session.input or (input.UserInputType == Enum.UserInputType.MouseButton1 and session.input.UserInputType == Enum.UserInputType.MouseButton1))
	end
	if owns(self._dragging) then
		local drag = self._dragging; self._dragging = nil
		if drag.target == self.Dock and drag.moved then
			self._dockClickUntil = os.clock() + 0.15
			local center, half = self.Dock.Position.X.Offset, self.Dock.Size.X.Offset / 2
			local threshold = 28 / self._actualScale
			if center - half <= threshold then self:StowDock("Left")
			elseif center + half >= self._dockWidth - threshold then self:StowDock("Right")
			else self:_clamp(self.Dock) end
		end
	end
	if owns(self._slider) then if self._slider.finish then self._slider.finish() end; self._slider = nil end
	if owns(self._resizing) then self._resizing = nil end
	if owns(self._colorDrag) then self._colorDrag = nil end
end

function Window:_layout(animate)
	if self.Destroyed then return end
	self:_settleVisibility(self.Main)
	self:_stop(self.Main)
	local previousPosition, previousSize = self.Main.Position, self.Main.Size
	local viewport = self.Gui.AbsoluteSize
	if viewport.X < 1 or viewport.Y < 1 then return end
	local fit = math.min((viewport.X - 24) / self.WindowSize.X, (viewport.Y - 24) / self.WindowSize.Y)
	self._actualScale = math.max(0.2, math.min(self.Scale, fit))
	self.UIScale.Scale = self._actualScale
	self._rootWidth, self._rootHeight = viewport.X / self._actualScale, viewport.Y / self._actualScale
	self.Root.Size = UDim2.fromOffset(self._rootWidth, self._rootHeight)
	self.DockUIScale.Scale = self._actualScale
	self._dockWidth, self._dockHeight = self.DockGui.AbsoluteSize.X / self._actualScale, self.DockGui.AbsoluteSize.Y / self._actualScale
	self.DockRoot.Size = UDim2.fromOffset(self._dockWidth, self._dockHeight)
	if self.Maximized then
		self.Main.Position, self.Main.Size = UDim2.fromOffset(12, 12), UDim2.fromOffset(self._rootWidth - 24, self._rootHeight - 24)
	else
		self.Main.Size = UDim2.fromOffset(self.WindowSize.X, self.WindowSize.Y)
		if not self._positioned then
			self.Main.Position = UDim2.fromOffset((self._rootWidth - self.WindowSize.X) / 2, (self._rootHeight - self.WindowSize.Y) / 2)
			self._positioned = true
		end
	end
	self.ResizeHandle.Visible = not self.Maximized
	self:_clamp(self.Main)
	if animate and self.Main.Visible then
		local position, size = self.Main.Position, self.Main.Size
		self.Main.Position, self.Main.Size = previousPosition, previousSize
		self:_tween(self.Main, { Position = position, Size = size }, 1.2)
	end
	for _, section in ipairs(self.Sections) do
		if section.Detached then self:_clamp(section.Float) end
	end
	self:_settleVisibility(self.Dock)
	self:_settleVisibility(self.DockHandle)
	self:_stop(self.Dock, "Position")
	if not self._dockMoved then self.Dock.Position = UDim2.fromOffset(self._dockWidth / 2, 0) end
	if self._dockSide then
		self.Dock.Position = self:_dockOffscreenPosition(self._dockSide)
		self:_placeDockHandle()
	else self:_clamp(self.Dock) end
	for _, tab in ipairs(self.Tabs) do tab:_queueLayout() end
	self:_closeMenu()
end

function PearlUI.new(options)
	options = options or {}
	local player = Players.LocalPlayer
	assert(options.Parent or player, "PearlUI must be created from a LocalScript")
	local self = setmetatable({
		Title = options.Title or "Pearl UI", Tabs = {}, Sections = {}, Controls = {}, _ids = {}, _sectionIds = {},
		_connections = {}, _skins = {}, _surfaces = {}, _refresh = {}, _profiles = {}, _configBanks = {}, _configListeners = {}, ConfigScope = options.ConfigScope or "global", _tweens = {}, _visibility = {}, _jobs = {},
		Theme = options.Theme or "Light", Scale = options.Scale or 1,
		Columns = options.Columns or 2,
		WindowSize = Vector2.new(900, 610), MinSize = Vector2.new(680, 420), MaxSize = Vector2.new(1440, 1000),
		Opacity = 0.97, ReduceMotion = options.ReduceMotion == true, AnimationSpeed = options.AnimationSpeed or 0.2, NotificationsEnabled = true,
		ToggleKey = options.ToggleKey or Enum.KeyCode.RightShift,
		Visible = true, Minimized = false, Destroyed = false,
	}, Window)
	assert(type(self.ConfigScope) == "string" and #self.ConfigScope > 0 and #self.ConfigScope <= 64, "Invalid config scope")
	assert(THEMES[self.Theme], "Unknown theme: " .. tostring(self.Theme))
	assert(self.Columns == 1 or self.Columns == 2, "Columns must be 1 or 2")
	self.Palette = copy(THEMES[self.Theme])
	self._accentOverride = options.Accent
	if options.Accent then self.Palette.Accent = options.Accent end
	self.Gui = make("ScreenGui", {
		Name = options.Name or "PearlUI", ResetOnSpawn = false, IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global, DisplayOrder = options.DisplayOrder or 50,
	}, options.Parent or player:WaitForChild("PlayerGui"))
	self.Root = make("Frame", { Name = "Root", BackgroundTransparency = 1 }, self.Gui)
	self.UIScale = make("UIScale", {}, self.Root)
	self.DockGui = make("ScreenGui", {
		Name = (options.Name or "PearlUI") .. "_Dock", ResetOnSpawn = false, IgnoreGuiInset = true,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets, ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder = self.Gui.DisplayOrder + 1,
	}, self.Gui.Parent)
	self.DockRoot = make("Frame", { Name = "DockRoot", BackgroundTransparency = 1 }, self.DockGui)
	self.DockUIScale = make("UIScale", {}, self.DockRoot)
	self.Main = make("Frame", {
		Name = "Window", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromOffset(900, 610),
	}, self.Root)
	self:_shadow(self.Main)
	local shell = make("Frame", { Name = "Shell", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, ZIndex = 2, ClipsDescendants = true }, self.Main)
	self:_surface(shell, "Window"); corner(shell, WINDOW_RADIUS)
	local outline = make("Frame", { Name = "WindowOutline", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 30 }, self.Main)
	self:_border(outline, WINDOW_RADIUS)
	self.ResizeHandle = button(self.Main, "")
	self.ResizeHandle.Name, self.ResizeHandle.Size = "ResizeHandle", UDim2.fromOffset(25, 25)
	self.ResizeHandle.Position, self.ResizeHandle.ZIndex = UDim2.new(1, -28, 1, -28), 32
	for index = 1, 3 do
		local grip = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(18 - index * 2, 18 - index * 2),
			Size = UDim2.fromOffset(index * 4, 1), Rotation = -45, BorderSizePixel = 0, ZIndex = 33,
		}, self.ResizeHandle)
		self:_skin(grip, "BackgroundColor3", "Muted")
	end
	self:_connect(self.ResizeHandle.InputBegan, function(input) self:_beginResize(input) end)
	self:_feedback(self.ResizeHandle, { NoScale = true })
	local titlebar = make("Frame", { Name = "Titlebar", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48), ZIndex = 3, Active = true }, shell)
	local dragArea = make("Frame", { Name = "DragArea", BackgroundTransparency = 1, Position = UDim2.fromOffset(90, 0), Size = UDim2.new(1, -300, 1, 0), ZIndex = 4, Active = true }, titlebar)
	self:_drag(dragArea, self.Main)
	local title = self:_text(titlebar, self.Title, 14, true)
	title.Size, title.TextXAlignment, title.ZIndex = UDim2.new(1, -380, 1, 0), Enum.TextXAlignment.Center, 4
	title.Position = UDim2.fromOffset(190, 0)
	self:_drag(title, self.Main)
	local colors = { Color3.fromRGB(255, 95, 87), Color3.fromRGB(255, 189, 46), Color3.fromRGB(40, 201, 64) }
	for index, color in ipairs(colors) do
		local dot = button(titlebar, "")
		dot.Name = ({ "Close", "Minimize", "Maximize" })[index]
		dot.Size, dot.Position = UDim2.fromOffset(12, 12), UDim2.fromOffset(19 + (index - 1) * 21, 18)
		dot.BackgroundTransparency, dot.BackgroundColor3, dot.ZIndex = 0, color, 7; corner(dot, 12)
		self:_feedback(dot, { Radius = 12 })
		self:_connect(dot.Activated, function()
			if index == 1 then self:SetVisible(false)
			elseif index == 2 then self:SetMinimized(true)
			else self:SetMaximized(not self.Maximized) end
		end)
	end
	local divider = make("Frame", { BorderSizePixel = 0, Position = UDim2.fromOffset(0, 47), Size = UDim2.new(1, 0, 0, 1), ZIndex = 4 }, titlebar)
	self:_skin(divider, "BackgroundColor3", "Border")
	local search = make("TextBox", {
		Name = "Search", Text = "", PlaceholderText = "Search settings…", ClearTextOnFocus = false,
		Font = FONT, TextSize = 12, BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(1, -207, 0, 10), Size = UDim2.fromOffset(192, 28), ZIndex = 7,
	}, titlebar)
	self:_skin(search, "BackgroundColor3", "Field"); self:_skin(search, "TextColor3", "Text")
	self:_skin(search, "PlaceholderColor3", "Muted"); self:_border(search, 7); padding(search, 11, 0)
	self:_focusFeedback(search)
	search:FindFirstChildOfClass("UIPadding").PaddingLeft = UDim.new(0, 31)
	local searchIcon = self:_icon(titlebar, "search")
	searchIcon.Position, searchIcon.Size, searchIcon.ZIndex = UDim2.new(1, -198, 0, 17), UDim2.fromOffset(14, 14), 8
	for _, child in ipairs(searchIcon:GetDescendants()) do if child:IsA("GuiObject") then child.ZIndex = 8 end end
	self.Search = search
	self.Sidebar = make("Frame", { Name = "Sidebar", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 48), Size = UDim2.new(0, 180, 1, -48), ClipsDescendants = true, ZIndex = 3 }, shell)
	-- Clip the extended top/right edges, leaving only the bottom-left corner rounded.
	local sidebarBackground = make("Frame", { Name = "SidebarBackground", BorderSizePixel = 0, Position = UDim2.fromOffset(0, -WINDOW_RADIUS), Size = UDim2.new(1, WINDOW_RADIUS, 1, WINDOW_RADIUS), ZIndex = 3 }, self.Sidebar)
	self:_surface(sidebarBackground, "Sidebar"); corner(sidebarBackground, WINDOW_RADIUS)
	local sideLabel = self:_text(self.Sidebar, "LIBRARY", 10, true, "Muted")
	sideLabel.Position, sideLabel.Size, sideLabel.ZIndex = UDim2.fromOffset(22, 24), UDim2.fromOffset(130, 16), 5
	local nav = make("ScrollingFrame", { Name = "Navigation", BorderSizePixel = 0, ClipsDescendants = true, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ScrollBarThickness = 2, ScrollingDirection = Enum.ScrollingDirection.Y, BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 54), Size = UDim2.new(1, -20, 1, -164), ZIndex = 4 }, self.Sidebar)
	list(nav, 6); self.Navigation = nav; self:_skin(nav, "ScrollBarImageColor3", "Border")
	self.UserCard = make("Frame", { Name = "UserCard", Position = UDim2.new(0, 10, 1, -88), Size = UDim2.new(1, -20, 0, 64), BorderSizePixel = 0, ZIndex = 5 }, self.Sidebar)
	self:_surface(self.UserCard, "Field"); self:_border(self.UserCard, 11); self:_feedback(self.UserCard, { NoScale = true, Radius = 11 })
	local avatarHolder = make("Frame", { Name = "Avatar", Position = UDim2.fromOffset(9, 11), Size = UDim2.fromOffset(42, 42), BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 7 }, self.UserCard)
	self:_skin(avatarHolder, "BackgroundColor3", "Hover"); corner(avatarHolder, 12)
	self.UserAvatar = make("ImageLabel", { Name = "Character", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = "", ScaleType = Enum.ScaleType.Fit, ZIndex = 8 }, avatarHolder)
	corner(self.UserAvatar, 12)
	self.AvatarFallback = self:_text(avatarHolder, "?", 19, true, "Accent")
	self.AvatarFallback.TextXAlignment, self.AvatarFallback.ZIndex = Enum.TextXAlignment.Center, 9
	self.AvatarFallback.BackgroundTransparency = 0; self:_skin(self.AvatarFallback, "BackgroundColor3", "Hover"); corner(self.AvatarFallback, 12)
	self.UserDisplayName = self:_text(self.UserCard, "Local player", 12, true)
	self.UserDisplayName.Position, self.UserDisplayName.Size, self.UserDisplayName.ZIndex = UDim2.fromOffset(60, 14), UDim2.new(1, -68, 0, 20), 7
	self.UserName = self:_text(self.UserCard, "@local", 9, false, "Muted")
	self.UserName.Position, self.UserName.Size, self.UserName.ZIndex = UDim2.fromOffset(60, 36), UDim2.new(1, -68, 0, 16), 7
	self:_connect(self.UserAvatar:GetPropertyChangedSignal("IsLoaded"), function() self.AvatarFallback.Visible = not self.UserAvatar.IsLoaded end)
	local footer = self:_text(self.Sidebar, self.ToggleKey.Name .. " / toggle", 9, false, "Muted")
	footer.Position, footer.Size, footer.ZIndex = UDim2.new(0, 22, 1, -17), UDim2.fromOffset(140, 12), 5
	footer.TextYAlignment = Enum.TextYAlignment.Top
	self.Footer = footer
	self.Content = make("Frame", { Name = "Content", BackgroundTransparency = 1, Position = UDim2.fromOffset(180, 48), Size = UDim2.new(1, -180, 1, -48), ZIndex = 4 }, shell)
	self.Heading = self:_text(self.Content, "", 28, true)
	self.Heading.Position, self.Heading.Size, self.Heading.ZIndex = UDim2.fromOffset(28, 25), UDim2.new(1, -56, 0, 36), 5
	self.Description = self:_text(self.Content, "", 12, false, "Muted")
	self.Description.Position, self.Description.Size, self.Description.ZIndex = UDim2.fromOffset(29, 65), UDim2.new(1, -58, 0, 22), 5
	self.Pages = make("Frame", { Name = "Pages", BackgroundTransparency = 1, Position = UDim2.fromOffset(28, 106), Size = UDim2.new(1, -50, 1, -136), ZIndex = 5 }, self.Content)
	self.MenuDismiss = button(self.Root, "")
	self.MenuDismiss.Name, self.MenuDismiss.Size, self.MenuDismiss.ZIndex, self.MenuDismiss.Visible = "DismissMenu", UDim2.fromScale(1, 1), 10000, false
	self:_connect(self.MenuDismiss.Activated, function() self:_closeMenu() end)
	self.Notifications = make("Frame", { Name = "Notifications", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -24, 1, -24), Size = UDim2.fromOffset(310, 300), ZIndex = 12000 }, self.Root)
	local notificationsList = list(self.Notifications, 8)
	notificationsList.VerticalAlignment = Enum.VerticalAlignment.Bottom
	self.Dock = make("Frame", { Name = "MiniDock", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.fromOffset(330, 54), BorderSizePixel = 0, Visible = false, ZIndex = 70, Active = true }, self.DockRoot)
	self:_surface(self.Dock, "Card"); self:_border(self.Dock, 14)
	self:_drag(self.Dock, self.Dock, 6)
	self.DockHandle = button(self.DockRoot, "")
	self.DockHandle.Name, self.DockHandle.Size, self.DockHandle.ZIndex, self.DockHandle.Visible = "DockHandle", UDim2.fromOffset(22, 54), 75, false
	self:_surface(self.DockHandle, "Card"); self:_border(self.DockHandle, 8)
	self:_feedback(self.DockHandle, { NoScale = true, Radius = 8 })
	local edgeIcon = self:_icon(self.DockHandle, "chevron-down", "Accent")
	edgeIcon.Position, edgeIcon.Size = UDim2.fromOffset(3, 19), UDim2.fromOffset(16, 16)
	for _, child in ipairs(edgeIcon:GetDescendants()) do if child:IsA("GuiObject") then child.ZIndex = 77 end end
	self:_drag(self.DockHandle, self.Dock, 6)
	self:_connect(self.DockHandle.Activated, function() if self:_dockClickAllowed() then self:RevealDock() end end)
	local expand = button(self.Dock, "Open " .. self.Title)
	expand.Name, expand.Position, expand.Size, expand.ZIndex = "Restore", UDim2.fromOffset(8, 8), UDim2.fromOffset(142, 38), 72
	self:_skin(expand, "TextColor3", "Accent"); self:_skin(expand, "BackgroundColor3", "Hover")
	expand.BackgroundTransparency = 0; corner(expand, 9)
	self:_feedback(expand, { Radius = 9 })
	self:_drag(expand, self.Dock, 6)
	self:_connect(expand.Activated, function() if self:_dockClickAllowed() then self:SetVisible(true); self:SetMinimized(false) end end)
	self.DockNavigation = make("ScrollingFrame", {
		Name = "DockNavigation", BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(158, 8), Size = UDim2.new(1, -166, 0, 38),
		AutomaticCanvasSize = Enum.AutomaticSize.X, CanvasSize = UDim2.new(), ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.X, ZIndex = 72,
	}, self.Dock)
	local dockLayout = list(self.DockNavigation, 5)
	dockLayout.FillDirection = Enum.FillDirection.Horizontal
	self:_connect(search:GetPropertyChangedSignal("Text"), function() self:_filter(search.Text) end)
	self:_connect(Input.InputBegan, function(input, processed)
		if self._confirmation then
			if input.KeyCode == Enum.KeyCode.Escape then self._confirmation:Cancel() end
			return
		end
		if input.KeyCode == Enum.KeyCode.Escape and self._popup then self:_closeMenu(); return end
		if self._capturing and Input:GetFocusedTextBox() then self:_cancelInteractions(); return end
		if self._capturing then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				local control = self._capturing; self._capturing = nil
				if input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then control:Set(input.KeyCode.Name) else control:_render() end
			end
			return
		end
		if processed or Input:GetFocusedTextBox() then return end
		if input.KeyCode == self.ToggleKey then self:SetVisible(not self.Visible) end
		for _, control in ipairs(self.Controls) do
			if control.Type == "Keybind" and control:CanInteract() and control.Value == input.KeyCode.Name then self:_callback(control.OnPressed, input.KeyCode) end
		end
	end)
	self:_connect(Input.InputChanged, function(input) self:_updatePointer(input) end)
	self:_connect(Input.InputEnded, function(input) self:_endPointer(input) end)
	self:_connect(self.Gui:GetPropertyChangedSignal("AbsoluteSize"), function() self:_layout() end)
	self:_connect(self.DockGui:GetPropertyChangedSignal("AbsoluteSize"), function() self:_layout() end)
	self:_connect(self.Gui.Destroying, function() self:Destroy() end)
	self:_connect(self.DockGui.Destroying, function() self:Destroy() end)
	if player then
		self:_connect(player:GetPropertyChangedSignal("DisplayName"), function() self:RefreshUserProfile() end)
		self:_connect(player.CharacterAdded, function() self:RefreshUserProfile() end)
	end
	self:_layout()
	self:RefreshUserProfile()
	self:_later(0, function() if self.Visible and not self.Minimized then self:_show(self.Main, true, true) end end)
	return self
end

function Window:RefreshUserProfile()
	if self.Destroyed then return end
	local player = Players.LocalPlayer
	local displayName, username = player and player.DisplayName or "Local player", player and player.Name or "local"
	self.UserDisplayName.Text, self.UserName.Text = displayName, "@" .. username
	local second = utf8.offset(displayName, 2)
	self.AvatarFallback.Text = string.sub(displayName, 1, second and second - 1 or #displayName)
	self._profileToken = (self._profileToken or 0) + 1
	local token = self._profileToken
	if not player or player.UserId <= 0 then return end
	local function waitForImage(remaining)
		if self.Destroyed or self._profileToken ~= token then return end
		if self.UserAvatar.IsLoaded then self.AvatarFallback.Visible = false
		else self:_later(remaining > 0 and 0.1 or 2, function() waitForImage(math.max(0, remaining - 1)) end) end
	end
	local function attempt(number)
		if self.Destroyed or self._profileToken ~= token then return end
		local ok, content, ready = pcall(Players.GetUserThumbnailAsync, Players, player.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size150x150)
		if self.Destroyed or self._profileToken ~= token then return end
		if ok and ready then self.UserAvatar.Image = content; self.AvatarFallback.Visible = not self.UserAvatar.IsLoaded; waitForImage(100)
		elseif number < 3 then self:_later(0.8, function() attempt(number + 1) end) end
	end
	self:_later(0, function() attempt(1) end)
end

function Window:SetColumns(columns)
	assert(columns == 1 or columns == 2, "Columns must be 1 or 2")
	self.Columns = columns
	for _, tab in ipairs(self.Tabs) do tab:_queueLayout() end
end

function Window:SetTheme(theme)
	assert(THEMES[theme], "Unknown theme: " .. tostring(theme))
	self.Theme, self.Palette = theme, copy(THEMES[theme])
	if self._accentOverride then self.Palette.Accent = self._accentOverride
	elseif self._accentControl and not self._accentControl.Destroyed then self._accentControl:Set(self.Palette.Accent, true) end
	for _, entry in ipairs(self._skins) do if entry[1].Parent then self:_tween(entry[1], { [entry[2]] = self.Palette[entry[3]] }) end end
	for _, refresh in pairs(self._refresh) do refresh() end
	self:_paintTabs()
end

function Window:SetAccent(color)
	assert(color == nil or typeof(color) == "Color3", "Accent must be Color3 or nil")
	self._accentOverride = color
	color = color or THEMES[self.Theme].Accent
	self.Palette.Accent = color
	local multiplier = self._colorDrag and 0 or 1
	for _, entry in ipairs(self._skins) do if entry[1].Parent and entry[3] == "Accent" then self:_tween(entry[1], { [entry[2]] = color }, multiplier) end end
	for _, refresh in pairs(self._refresh) do refresh() end
	self:_paintTabs(multiplier)
end

function Window:ResetAccent()
	self:SetAccent(nil)
	if self._accentControl and not self._accentControl.Destroyed then self._accentControl:Set(self.Palette.Accent, true) end
	return self
end

function Window:SetOpacity(value)
	assert(type(value) == "number" and value == value and math.abs(value) < math.huge, "Opacity must be a finite number")
	self.Opacity = math.clamp(value, 0.75, 1)
	for _, surface in ipairs(self._surfaces) do
		if surface.Parent then
			local hiding = false
			for _, state in pairs(self._visibility) do
				for _, entry in ipairs(state.Entries) do
					if entry.Object == surface then entry.Properties.BackgroundTransparency = 1 - self.Opacity; hiding = hiding or not state.Shown end
				end
			end
			if not hiding then self:_tween(surface, { BackgroundTransparency = 1 - self.Opacity }) end
		end
	end
end

function Window:SetScale(value)
	assert(type(value) == "number" and value == value and math.abs(value) < math.huge, "Scale must be a finite number")
	self.Scale = math.clamp(value, 0.65, 1.3)
	self:_layout()
end

function Window:SetSize(width, height)
	assert(type(width) == "number" and width == width and math.abs(width) < math.huge, "Width must be finite")
	assert(type(height) == "number" and height == height and math.abs(height) < math.huge, "Height must be finite")
	if self.Maximized then self:SetMaximized(false) end
	self.WindowSize = Vector2.new(math.round(math.clamp(width, self.MinSize.X, self.MaxSize.X)), math.round(math.clamp(height, self.MinSize.Y, self.MaxSize.Y)))
	self:_layout(true)
end

function Window:SetToggleKey(key)
	if type(key) == "string" then key = Enum.KeyCode[key] end
	assert(typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode, "Invalid toggle key")
	self.ToggleKey = key
	self.Footer.Text = key.Name .. " / toggle"
end

function Window:SetVisible(visible)
	self.Visible = visible == true
	if not self.Visible and self._confirmation then self._confirmation:Cancel() end
	self.AvatarFallback.Visible = self.UserAvatar.Image == "" or not self.UserAvatar.IsLoaded
	local geometry = self._tweens[self.Main]
	if geometry and geometry.Size then
		local position, size = self:_target(self.Main, "Position"), self:_target(self.Main, "Size")
		self:_stop(self.Main)
		self.Main.Position, self.Main.Size = position, size
	end
	self:_cancelInteractions()
	self:_hideTooltip()
	self:_show(self.Main, self.Visible and not self.Minimized)
	self:_syncDock()
	for _, section in ipairs(self.Sections) do if section.Float then self:_show(section.Float, self.Visible and not self.Minimized and section.Detached) end end
end

function Window:SetMinimized(minimized)
	self.Minimized = minimized == true
	if self.Minimized and self._confirmation then self._confirmation:Cancel() end
	self:SetVisible(self.Visible)
end

function Window:SetMaximized(maximized)
	self:_closeMenu()
	self:_settleVisibility(self.Main)
	if maximized and not self.Maximized then self._restorePosition, self._restoreSize = self:_target(self.Main, "Position"), self.Main.Size end
	self.Maximized = maximized == true
	local currentPosition = self.Main.Position
	if not self.Maximized and self._restorePosition then self.Main.Position = self._restorePosition end
	local restoredPosition = self.Main.Position
	self:_layout(true)
	if not self.Maximized then
		local targetSize = UDim2.fromOffset(self.WindowSize.X, self.WindowSize.Y)
		self.Main.Position = currentPosition
		self:_tween(self.Main, { Position = restoredPosition, Size = targetSize }, 1.2)
	end
end

function Window:Notify(options)
	if self.Destroyed then return end
	if type(options) == "string" then options = { Title = options } end
	options = options or {}
	if not self.NotificationsEnabled and options.Preview ~= true then return end
	local slot = make("Frame", { Name = "Toast", Size = UDim2.new(1, 0, 0, 72), BackgroundTransparency = 1, ZIndex = 12001 }, self.Notifications)
	local toast = make("Frame", { Name = "Card", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, ZIndex = 12001 }, slot)
	self:_surface(toast, "Card"); self:_border(toast, 12)
	local badge = self:_icon(toast, "check", "Accent")
	badge.Position, badge.Size, badge.ZIndex = UDim2.fromOffset(17, 25), UDim2.fromOffset(22, 22), 12002
	for _, child in ipairs(badge:GetDescendants()) do if child:IsA("GuiObject") then child.ZIndex = 12002 end end
	local title = self:_text(toast, options.Title or "Done", 12, true)
	title.Position, title.Size, title.ZIndex = UDim2.fromOffset(50, 16), UDim2.new(1, -82, 0, 18), 12002
	title.TextTruncate = Enum.TextTruncate.AtEnd
	local body = self:_text(toast, options.Description or "", 11, false, "Muted")
	body.Position, body.Size, body.ZIndex = UDim2.fromOffset(50, 39), UDim2.new(1, -66, 0, 17), 12002
	body.TextTruncate = Enum.TextTruncate.AtEnd
	local close = button(toast, "")
	close.Position, close.Size, close.ZIndex, close.TextSize = UDim2.new(1, -30, 0, 8), UDim2.fromOffset(23, 23), 12003, 18
	self:_skin(close, "TextColor3", "Muted")
	self:_feedback(close, { Radius = 6 })
	local closeIcon = self:_icon(close, "x")
	closeIcon.Position, closeIcon.Size = UDim2.fromOffset(5, 5), UDim2.fromOffset(13, 13)
	for _, child in ipairs(closeIcon:GetDescendants()) do if child:IsA("GuiObject") then child.ZIndex = 12003 end end
	local closing = false
	local function dismiss()
		if closing or not slot.Parent then return end
		closing = true
		self:_show(toast, false, false, function()
			self._visibility[toast] = nil; slot:Destroy(); self:_prune()
		end, Vector2.new(16, 0))
		if slot.Parent then self:_tween(slot, { Size = UDim2.new(1, 0, 0, 0) }) end
	end
	self:_connect(close.Activated, dismiss)
	if #self.Notifications:GetChildren() > 5 then
		for _, child in ipairs(self.Notifications:GetChildren()) do if child:IsA("Frame") and child ~= toast then child:Destroy(); break end end
	end
	self:_show(toast, true, true, nil, Vector2.new(16, 0))
	self:_later(options.Duration or 4, dismiss)
	return slot
end

function Tab:_queueLayout()
	if self._layoutQueued or self.Window.Destroyed then return end
	self._layoutQueued = true
	self.Window:_later(0, function() self._layoutQueued = false; self:_arrange() end)
end

function Tab:_arrange()
	if self.Window.Destroyed then return end
	local window = self.Window
	local width = math.max(1, self.Page.AbsoluteSize.X / window._actualScale - 12)
	local columns = window.Columns == 2 and width >= 580 and 2 or 1
	local columnWidth = columns == 2 and (width - 14) / 2 or width
	local heights = { 0, 0 }
	local visibleIndex = 0
	self.EffectiveColumns = columns
	for _, section in ipairs(window.Sections) do
		local item
		if section.Frame.Parent == self.Page and section.Frame.Visible then item = section.Frame
		elseif section.Placeholder.Parent == self.Page and section.Placeholder.Visible then item = section.Placeholder end
		if item then
			visibleIndex += 1
			local column = columns == 2 and (window.Search.Text ~= "" and ((visibleIndex - 1) % 2 + 1) or (section.Column == "Right" and 2 or 1)) or 1
			item.Size = UDim2.fromOffset(math.floor(columnWidth), item == section.Frame and 0 or 42)
			if item == section.Frame then section:_layoutControls(columnWidth) end
			window:_stop(item, "Position")
			item.Position = UDim2.fromOffset(column == 2 and columnWidth + 14 or 0, heights[column])
			heights[column] += (item == section.Frame and section:_measureHeight() or 42) + 16
		end
	end
	self.Page.CanvasSize = UDim2.fromOffset(0, math.max(0, math.max(heights[1], heights[2]) - 16) + 4)
end

function Section:_layoutControls(width)
	self._availableWidth = width
	for _, control in ipairs(self.Controls) do if not control.Destroyed then control:_layoutRow(width < 460) end end
end

function Section:_measureHeight()
	local height = 54
	for _, control in ipairs(self.Controls) do if not control.Destroyed and control.Row.Visible then height += control.Row.Size.Y.Offset end end
	return height
end

function Window:Tab(options)
	if type(options) == "string" then options = { Name = options } end
	options = options or {}
	local tab = setmetatable({ Window = self, Name = options.Name or "Tab", Description = options.Description or "", Sections = {} }, Tab)
	tab.Button = button(self.Navigation, "")
	tab.Button.Name, tab.Button.Size, tab.Button.LayoutOrder, tab.Button.ZIndex = "Tab_" .. tab.Name, UDim2.new(1, 0, 0, 39), #self.Tabs + 1, 5
	corner(tab.Button, 8)
	self:_feedback(tab.Button, { NoScale = true, Radius = 8 })
	tab.Icon = self:_icon(tab.Button, options.Icon or string.lower(tab.Name))
	tab.Icon.Position, tab.Icon.ZIndex = UDim2.fromOffset(12, 9), 6
	for _, item in ipairs(tab.Icon:GetDescendants()) do if item:IsA("GuiObject") then item.ZIndex = 6 end end
	tab.Label = self:_text(tab.Button, tab.Name, 12, true)
	tab.Label.Position, tab.Label.Size, tab.Label.ZIndex = UDim2.fromOffset(43, 0), UDim2.new(1, -50, 1, 0), 6
	tab.Page = make("ScrollingFrame", {
		Name = tab.Name, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.None, ScrollBarThickness = 3,
		ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false, ZIndex = 5,
	}, self.Pages)
	self:_skin(tab.Page, "ScrollBarImageColor3", "Border")
	padding(tab.Page, 2, 2)
	self:_connect(tab.Page:GetPropertyChangedSignal("AbsoluteSize"), function() tab:_queueLayout() end)
	self:_connect(tab.Button.Activated, function() self.Search.Text = ""; self:SelectTab(tab) end)
	table.insert(self.Tabs, tab)
	tab.DockButton = button(self.DockNavigation, "")
	tab.DockButton.Name, tab.DockButton.Size, tab.DockButton.LayoutOrder, tab.DockButton.ZIndex = "Dock_" .. tab.Name, UDim2.fromOffset(36, 36), #self.Tabs, 73
	self:_skin(tab.DockButton, "BackgroundColor3", "Hover"); corner(tab.DockButton, 8)
	self:_feedback(tab.DockButton, { Radius = 8 })
	self:_drag(tab.DockButton, self.Dock, 6)
	local dockIcon = self:_icon(tab.DockButton, options.Icon or string.lower(tab.Name), "Accent")
	dockIcon.Position = UDim2.fromOffset(8, 8)
	for _, item in ipairs(dockIcon:GetDescendants()) do if item:IsA("GuiObject") then item.ZIndex = 74 end end
	self:_connect(tab.DockButton.Activated, function()
		if not self:_dockClickAllowed() then return end
		self.Search.Text = ""; self:SetVisible(true); self:SetMinimized(false); self:SelectTab(tab)
	end)
	if not self.ActiveTab then self:SelectTab(tab) end
	return tab
end

function Window:_paintTabs(multiplier)
	for _, item in ipairs(self.Tabs) do
		local active = item == self.ActiveTab
		self:_tween(item.Button, { BackgroundTransparency = active and 0 or 1, BackgroundColor3 = self.Palette.Accent }, multiplier)
		self:_tween(item.DockButton, { BackgroundTransparency = active and 0 or 1 }, multiplier)
		self:_tween(item.Label, { TextColor3 = active and Color3.new(1, 1, 1) or self.Palette.Text }, multiplier)
		for _, child in ipairs(item.Icon:GetDescendants()) do
			if child:IsA("Frame") and self:_baseTarget(child, "BackgroundTransparency") < 1 then self:_tween(child, { BackgroundColor3 = active and Color3.new(1, 1, 1) or self.Palette.Muted }, multiplier) end
			if child:IsA("UIStroke") then self:_tween(child, { Color = active and Color3.new(1, 1, 1) or self.Palette.Muted }, multiplier) end
		end
	end
end

function Window:SelectTab(tab)
	if type(tab) == "string" then
		local found
		for _, item in ipairs(self.Tabs) do if item.Name == tab then found = item; break end end
		assert(found, "Unknown tab: " .. tab); tab = found
	end
	assert(table.find(self.Tabs, tab), "Tab must belong to this window")
	self:_cancelInteractions()
	local changed = self.ActiveTab ~= tab
	self.ActiveTab = tab
	self.Heading.Text, self.Description.Text = tab.Name, tab.Description
	for _, item in ipairs(self.Tabs) do
		local active = item == tab
		if not active then self:_settleVisibility(item.Page) end
		item.Page.Visible = active
	end
	self:_paintTabs()
	self:_filter(self.Search.Text)
	if changed then self:_show(tab.Page, true, true, nil, Vector2.new(0, 8)) end
end

function Window:_filter(query)
	query = string.lower(query or "")
	local count = 0
	for _, section in ipairs(self.Sections) do
		local sectionMatches = query == "" or string.find(string.lower(section.Title), query, 1, true) ~= nil
		local any = false
		local lastVisible
		for _, control in ipairs(section.Controls) do
			local matches = control.Visible and not control.Destroyed and (sectionMatches or string.find(string.lower(control.Label), query, 1, true) ~= nil)
			control.Row.Visible = matches
			control.Separator.Visible = matches
			any = any or matches
			if matches then count += 1; lastVisible = control end
		end
		if lastVisible then lastVisible.Separator.Visible = false end
		section.Frame.Visible = any or (#section.Controls == 0 and sectionMatches)
		section.Placeholder.Visible = section.Detached and section.Frame.Visible
		if query ~= "" then section.Tab.Page.Visible = true end
	end
	if query ~= "" then
		-- Search spans all tabs by temporarily showing their sections in the active page.
		for _, section in ipairs(self.Sections) do if not section.Detached then if section.Frame.Parent ~= self.ActiveTab.Page then self:_settleAncestors(section.Frame); section.Frame.Parent = self.ActiveTab.Page end end end
		for _, tab in ipairs(self.Tabs) do tab.Page.Visible = tab == self.ActiveTab end
		self.Heading.Text, self.Description.Text = "Search", tostring(count) .. " matching settings"
	else
		for _, section in ipairs(self.Sections) do if not section.Detached then if section.Frame.Parent ~= section.Tab.Page then self:_settleAncestors(section.Frame); section.Frame.Parent = section.Tab.Page end end end
		if self.ActiveTab then self.Heading.Text, self.Description.Text = self.ActiveTab.Name, self.ActiveTab.Description end
	end
	for _, tab in ipairs(self.Tabs) do tab:_queueLayout() end
end

function Tab:Section(options)
	if type(options) == "string" then options = { Title = options } end
	options = options or {}
	local window = self.Window
	local section = setmetatable({ Window = window, Tab = self, Title = options.Title or "Section", Controls = {}, Detached = false, _nextControlOrder = 0 }, Section)
	section.Column = options.Column or (#self.Sections % 2 == 0 and "Left" or "Right")
	assert(section.Column == "Left" or section.Column == "Right", "Section Column must be Left or Right")
	section.Id = options.Id or (self.Name .. "." .. section.Title)
	assert(type(section.Id) == "string" and section.Id ~= "", "Section Id must be a nonempty string")
	assert(not window._sectionIds[section.Id], "Duplicate section Id: " .. section.Id)
	window._sectionIds[section.Id] = section
	section.Frame = make("Frame", { Name = "Section_" .. section.Title, Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, LayoutOrder = #window.Sections + 1, ZIndex = 6 }, self.Page)
	window:_surface(section.Frame, "Card"); window:_border(section.Frame, CARD_RADIUS); list(section.Frame, 0)
	section.Header = make("Frame", { Name = "Header", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), LayoutOrder = 0, ZIndex = 7 }, section.Frame)
	local grip = window:_icon(section.Header, "grip-vertical")
	grip.Position, grip.Size, grip.ZIndex = UDim2.fromOffset(13, 11), UDim2.fromOffset(17, 21), 8
	for _, child in ipairs(grip:GetDescendants()) do if child:IsA("GuiObject") then child.ZIndex = 8 end end
	local title = window:_text(section.Header, section.Title, 13, true)
	title.Position, title.Size, title.ZIndex = UDim2.fromOffset(39, 0), UDim2.new(1, -83, 1, 0), 8
	local detach = button(section.Header, "")
	detach.Name, detach.Position, detach.Size, detach.ZIndex = "Detach", UDim2.new(1, -38, 0, 7), UDim2.fromOffset(28, 28), 10
	window:_feedback(detach, { Radius = 6 })
	local detachIcon = window:_icon(detach, "detach")
	detachIcon.Position = UDim2.fromOffset(4, 4)
	for _, item in ipairs(detachIcon:GetDescendants()) do if item:IsA("GuiObject") then item.ZIndex = 10 end end
	window:_connect(detach.Activated, function() if section.Detached then section:Dock() else section:Detach() end end)
	section.Body = make("Frame", { Name = "Rows", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, ZIndex = 7 }, section.Frame)
	padding(section.Body, 16, 6); list(section.Body, 0)
	section.Placeholder = make("TextButton", {
		Name = "Detached_" .. section.Title, Text = "", Font = FONT, TextSize = 12,
		Size = UDim2.new(1, -8, 0, 42), BorderSizePixel = 0, Visible = false, LayoutOrder = section.Frame.LayoutOrder, ZIndex = 6,
	}, self.Page)
	window:_skin(section.Placeholder, "BackgroundColor3", "Field"); window:_skin(section.Placeholder, "TextColor3", "Accent"); window:_border(section.Placeholder, 9)
	local placeholderTitle = window:_text(section.Placeholder, section.Title, 12, true)
	placeholderTitle.Position, placeholderTitle.Size, placeholderTitle.ZIndex = UDim2.fromOffset(12, 3), UDim2.new(1, -24, 0, 18), 7
	placeholderTitle.TextTruncate = Enum.TextTruncate.AtEnd
	local placeholderAction = window:_text(section.Placeholder, "Open detached panel", 10, false, "Accent")
	placeholderAction.Position, placeholderAction.Size, placeholderAction.ZIndex = UDim2.fromOffset(12, 22), UDim2.new(1, -24, 0, 15), 7
	placeholderAction.TextTruncate = Enum.TextTruncate.AtEnd
	window:_feedback(section.Placeholder, { NoScale = true, Radius = 9 })
	window:_connect(section.Placeholder.Activated, function() section:Reveal() end)
	table.insert(self.Sections, section); table.insert(window.Sections, section)
	self:_queueLayout()
	return section
end

function Section:Detach()
	if self.Window.Destroyed then return end
	if self.Detached then self:Reveal(); return end
	local window = self.Window
	window:_cancelInteractions()
	window:_settleAncestors(self.Frame)
	self.Detached = true
	self._motionToken = (self._motionToken or 0) + 1
	if not self.Float then
		self.Float = make("Frame", { Name = "Detached_" .. self.Title, BackgroundTransparency = 1, Size = UDim2.fromOffset(410, 300), ZIndex = 40, Visible = false, Active = true }, window.Root)
		window:_shadow(self.Float)
		window:_connect(self.Float.InputBegan, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then window:_raisePanel(self) end end)
		local surface = make("Frame", { Name = "Surface", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, ZIndex = 41 }, self.Float)
		window:_surface(surface, "Window"); window:_border(surface, WINDOW_RADIUS)
		local bar = make("Frame", { Name = "Titlebar", BackgroundTransparency = 1, Size = UDim2.new(1, -85, 0, 42), Position = UDim2.fromOffset(70, 0), ZIndex = 42, Active = true }, surface)
		window:_drag(bar, self.Float)
		local title = window:_text(bar, self.Title, 12, true)
		title.Size, title.TextXAlignment, title.ZIndex = UDim2.new(1, -15, 1, 0), Enum.TextXAlignment.Center, 43
		local close = button(surface, "")
		close.Name, close.Position, close.Size, close.BackgroundTransparency = "Dock", UDim2.fromOffset(16, 15), UDim2.fromOffset(12, 12), 0
		close.BackgroundColor3, close.ZIndex = Color3.fromRGB(255, 95, 87), 44; corner(close, 12)
		window:_feedback(close, { Radius = 12 })
		local yellow = make("Frame", { Position = UDim2.fromOffset(37, 15), Size = UDim2.fromOffset(12, 12), BackgroundColor3 = Color3.fromRGB(255, 189, 46), BorderSizePixel = 0, ZIndex = 43 }, surface); corner(yellow, 12)
		window:_connect(close.Activated, function() self:Dock() end)
		self.FloatScroll = make("ScrollingFrame", {
			Name = "DetachedContent", BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.fromOffset(12, 48), Size = UDim2.new(1, -24, 1, -100),
			AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ScrollBarThickness = 3,
			ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 42,
		}, surface)
		padding(self.FloatScroll, 2, 2)
		local dock = button(surface, "Dock panel")
		dock.Position, dock.Size, dock.ZIndex, dock.BackgroundTransparency = UDim2.new(0, 14, 1, -43), UDim2.new(1, -28, 0, 30), 44, 0
		window:_skin(dock, "BackgroundColor3", "Field"); window:_skin(dock, "TextColor3", "Accent"); window:_border(dock, 7)
		window:_feedback(dock)
		window:_connect(dock.Activated, function() self:Dock() end)
	end
	window:_settleVisibility(self.Float)
	self:_layoutControls(376)
	self.Float.Size = UDim2.fromOffset(410, math.min(window._rootHeight - 30, math.max(260, self:_measureHeight() + 100)))
	local count = 0
	for _, section in ipairs(window.Sections) do if section ~= self and section.Detached then count += 1 end end
	self.Float.Position = self._lastFloatPosition or UDim2.fromOffset(window.Main.Position.X.Offset + 54 + (count % 6) * 32, window.Main.Position.Y.Offset + 60 + (count % 6) * 28)
	window:_clamp(self.Float)
	window:_stop(self.Frame, "Position")
	self.Frame.Parent = self.FloatScroll
	self.Frame.Position = UDim2.new()
	self.Frame.Size = UDim2.new(1, -6, 0, 0)
	self.FloatScroll.CanvasPosition = Vector2.zero
	self.Placeholder.Visible = true
	for _, child in ipairs(self.Frame:GetDescendants()) do
		if child:IsA("GuiObject") and not child:GetAttribute("PearlDockZ") then child:SetAttribute("PearlDockZ", child.ZIndex); child.ZIndex += 42 end
	end
	self.Frame.ZIndex = 48
	window:_raisePanel(self)
	window:_show(self.Float, window.Visible and not window.Minimized, true)
	self.Tab:_queueLayout()
end

function Section:Reveal()
	local window = self.Window
	if window.Destroyed then return self end
	if not self.Detached then self:Detach(); return self end
	if not window.Visible then window:SetVisible(true) end
	if window.Minimized then window:SetMinimized(false) end
	window:_raisePanel(self)
	window:_clamp(self.Float)
	window:_show(self.Float, true)
	return self
end

function Section:Dock()
	if self.Window.Destroyed or not self.Detached then return end
	local window = self.Window
	window:_cancelInteractions()
	window:_settleVisibility(self.Float)
	window:_settleAncestors(self.Frame)
	self._lastFloatPosition = self.Float.Position
	self.Detached = false
	self._motionToken = (self._motionToken or 0) + 1
	self.Frame.Parent, self.Frame.Size = self.Tab.Page, UDim2.new(1, -8, 0, 0)
	self.Frame.ZIndex = 6
	for _, child in ipairs(self.Frame:GetDescendants()) do
		if child:IsA("GuiObject") and child:GetAttribute("PearlDockZ") then child.ZIndex = child:GetAttribute("PearlDockZ"); child:SetAttribute("PearlDockZ", nil) end
	end
	self.Placeholder.Visible = false
	window:_filter(window.Search.Text)
	window:_show(self.Float, false)
end

function Section:_row(options, kind)
	options = options or {}
	local window = self.Window
	assert(not window.Destroyed, "Window has been destroyed")
	assert(type(options) == "table", "Control options must be a table")
	assert(options.Callback == nil or type(options.Callback) == "function", "Callback must be a function")
	assert(options.Persist == nil or type(options.Persist) == "boolean", "Persist must be a boolean")
	assert(options.ResetGroup == nil or options.ResetGroup == "Controls" or options.ResetGroup == "Appearance", "ResetGroup must be Controls or Appearance")
	assert(options.Label == nil or type(options.Label) == "string", "Label must be a string")
	assert(options.Description == nil or type(options.Description) == "string", "Description must be a string")
	assert(options.DisabledReason == nil or type(options.DisabledReason) == "string", "Disabled reason must be a string")
	local control = setmetatable({ Window = window, Section = self, Label = options.Label or kind, Type = kind, Callback = options.Callback,
		Visible = options.Visible ~= false, Disabled = options.Disabled == true, DisabledReason = options.DisabledReason, ResetGroup = options.ResetGroup or "Controls", Persist = options.Persist ~= false,
		_ownedConnections = {}, _connectionStart = #window._connections, Destroyed = false,
	}, Control)
	if kind ~= "Button" and kind ~= "Label" then
		control.Id = options.Id or (self.Tab.Name .. "." .. self.Title .. "." .. control.Label)
		assert(type(control.Id) == "string" and control.Id ~= "", "Control Id must be a nonempty string")
		assert(not window._ids[control.Id], "Duplicate control Id: " .. control.Id)
		window._ids[control.Id] = control
	end
	self._nextControlOrder += 1
	control.Row = make("Frame", { Name = kind .. "_" .. control.Label, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, options.Description and 62 or 46), LayoutOrder = self._nextControlOrder, ZIndex = 8 }, self.Body)
	local title = window:_text(control.Row, control.Label, 12, false)
	title.Position, title.Size, title.ZIndex = UDim2.fromOffset(0, options.Description and 9 or 0), UDim2.new(1, -214, 0, options.Description and 21 or 46), 9
	control.LabelText = title
	if options.Description then
		local description = window:_text(control.Row, options.Description, 10, false, "Muted")
		description.Position, description.Size, description.ZIndex = UDim2.fromOffset(0, 32), UDim2.new(1, -210, 0, 20), 9
		control.DescriptionText = description
	end
	local separator = make("Frame", { Name = "Separator", BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), ZIndex = 8, BackgroundTransparency = 0.35, Visible = false }, control.Row)
	window:_skin(separator, "BackgroundColor3", "Border")
	control.Separator = separator
	if #self.Controls > 0 then self.Controls[#self.Controls].Separator.Visible = true end
	control.DisabledOverlay = button(control.Row, "")
	control.DisabledOverlay.Name, control.DisabledOverlay.Size, control.DisabledOverlay.ZIndex = "DisabledOverlay", UDim2.fromScale(1, 1), 20
	control.DisabledOverlay.BackgroundTransparency, control.DisabledOverlay.Visible = 0.48, false
	window:_skin(control.DisabledOverlay, "BackgroundColor3", "Card"); corner(control.DisabledOverlay, 5)
	window:_connect(control.DisabledOverlay.MouseEnter, function() window:_disabledTooltip(control) end)
	window:_connect(control.DisabledOverlay.MouseLeave, function() if window._tooltipOwner == control then window:_hideTooltip() end end)
	table.insert(self.Controls, control); table.insert(window.Controls, control)
	return control, window
end

function Section:Toggle(options)
	options = options or {}
	local control, window = self:_row(options, "Toggle")
	control.Value = options.Default == true
	control.Validate = function(value) assert(type(value) == "boolean", "Toggle expects boolean"); return value end
	local switch = button(control.Row, "")
	switch.Name, switch.Position, switch.Size, switch.ZIndex, switch.BackgroundTransparency = "Switch", UDim2.new(1, -43, 0.5, -12), UDim2.fromOffset(43, 24), 11, 0
	corner(switch, 24)
	window:_feedback(switch, { Radius = 24 })
	local thumb = make("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Size = UDim2.fromOffset(20, 20), ZIndex = 12 }, switch); corner(thumb, 20)
	function control:_render()
		window:_tween(switch, { BackgroundColor3 = self.Value and window.Palette.Accent or window.Palette.Track })
		window:_tween(thumb, { Position = UDim2.fromOffset(self.Value and 21 or 2, 2) })
	end
	control:_render(); window._refresh[control] = function() control:_render() end
	window:_connect(switch.Activated, function() if control:CanInteract() then control:Set(not control.Value) end end)
	return control:_complete()
end

function Section:Slider(options)
	options = options or {}
	local control, window = self:_row(options, "Slider")
	local minimum, maximum, step = options.Min or 0, options.Max or 100, options.Step or 1
	assert(finite(minimum) and finite(maximum) and finite(step), "Slider limits and step must be finite numbers")
	assert(maximum > minimum and step > 0, "Slider requires Max > Min and Step > 0")
	control.Validate = function(value)
		assert(type(value) == "number" and value == value and math.abs(value) ~= math.huge, "Slider expects a finite number")
		local result = minimum + math.round((math.clamp(value, minimum, maximum) - minimum) / step) * step
		return math.clamp(math.round(result * 1e6) / 1e6, minimum, maximum)
	end
	control.Value = control.Validate(options.Default or minimum)
	local track = button(control.Row, "")
	track.Name, track.Size, track.Position, track.ZIndex = "Slider", UDim2.fromOffset(134, 30), UDim2.new(1, -198, 0.5, -15), 11
	window:_feedback(track, { NoScale = true, Radius = 8 })
	local rail = make("Frame", { Name = "Rail", Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 0.5, -2), BorderSizePixel = 0, ZIndex = 12 }, track)
	window:_skin(rail, "BackgroundColor3", "Track"); corner(rail, 4)
	local fill = make("Frame", { Name = "Fill", Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, ZIndex = 13 }, rail)
	window:_skin(fill, "BackgroundColor3", "Accent"); corner(fill, 4)
	local thumb = make("Frame", { Name = "Thumb", Size = UDim2.fromOffset(15, 15), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 14 }, rail)
	window:_border(thumb, 15)
	local thumbScale = make("UIScale", { Scale = 1 }, thumb)
	window:_connect(track.MouseEnter, function() window:_tween(thumbScale, { Scale = 1.14 }, 0.55) end)
	window:_connect(track.MouseLeave, function() if not window._slider or window._slider.control ~= control then window:_tween(thumbScale, { Scale = 1 }, 0.55) end end)
	local valueText = window:_text(control.Row, "", 11, false, "Muted")
	control.ValueText = valueText
	valueText.Position, valueText.Size, valueText.TextXAlignment, valueText.ZIndex = UDim2.new(1, -56, 0, 0), UDim2.new(0, 56, 1, 0), Enum.TextXAlignment.Right, 11
	function control:_render()
		local ratio = (self.Value - minimum) / (maximum - minimum)
		if window._slider and window._slider.control == self then
			window:_stop(fill, "Size"); window:_stop(thumb, "Position")
			fill.Size, thumb.Position = UDim2.fromScale(ratio, 1), UDim2.fromScale(ratio, 0.5)
		else
			window:_tween(fill, { Size = UDim2.fromScale(ratio, 1) })
			window:_tween(thumb, { Position = UDim2.fromScale(ratio, 0.5) })
		end
		valueText.Text = tostring(self.Value) .. (options.Suffix or "")
	end
	local function update(x)
		local ratio = math.clamp((x - rail.AbsolutePosition.X) / math.max(1, rail.AbsoluteSize.X), 0, 1)
		local nextValue = control.Validate(minimum + (maximum - minimum) * ratio)
		if nextValue ~= control.Value then control:Set(nextValue) end
	end
	window:_connect(track.InputBegan, function(input)
		if not control:CanInteract() then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			window._slider = { input = input, control = control, update = update, finish = function() window:_tween(thumbScale, { Scale = 1 }, 0.55) end }
			window:_tween(thumbScale, { Scale = 1.2 }, 0.55)
			update(input.Position.X)
		end
	end)
	control:_render()
	return control:_complete()
end

function Window:_openControlPopup(control, name, width, height, arrow)
	self:_cancelInteractions()
	local anchor = control.Field
	local position = (anchor.AbsolutePosition - self.Root.AbsolutePosition) / self._actualScale
	local below = position.Y + anchor.AbsoluteSize.Y / self._actualScale + 5
	local y = below + height > self._rootHeight - 8 and position.Y - height - 5 or below
	local popup = make("Frame", {
		Name = name, Position = UDim2.fromOffset(math.clamp(position.X, 8, math.max(8, self._rootWidth - width - 8)), math.max(8, y)),
		Size = UDim2.fromOffset(width, height), BorderSizePixel = 0, ZIndex = 101,
	}, self.Root)
	self:_surface(popup, "Card"); self:_border(popup, 11)
	self._popup, self._popupAnchor, self._popupArrow, self._popupOwner = popup, anchor, arrow, control
	if arrow then self:_tween(arrow, { Rotation = 180 }, 0.7) end
	self.MenuDismiss.Visible = true
	local parent = anchor.Parent
	while parent and parent ~= self.Root do
		if parent:IsA("ScrollingFrame") then
			self._popupScrollConnection = self:_connect(parent:GetPropertyChangedSignal("CanvasPosition"), function() if self._popup == popup then self:_closeMenu() end end)
			break
		end
		parent = parent.Parent
	end
	return popup
end

function Window:_dropdownPopup(control)
	local searchable = control.Searchable
	local listHeight = math.min(#control.Options * 32 + 4, 196)
	local top = searchable and 46 or 8
	local height = top + listHeight + (control.Multi and 42 or 8)
	local menu = self:_openControlPopup(control, "SearchDropdown", 258, height, control.Arrow)
	local state = { Frame = menu, Rows = {} }
	control._menu = state
	if searchable then
		state.Search = make("TextBox", {
			Name = "SearchOptions", Text = "", PlaceholderText = "Search options…", ClearTextOnFocus = false,
			Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0,
			Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 0, 30), ZIndex = 103,
		}, menu)
		self:_skin(state.Search, "BackgroundColor3", "Field"); self:_skin(state.Search, "TextColor3", "Text"); self:_skin(state.Search, "PlaceholderColor3", "Muted")
		self:_border(state.Search, FIELD_RADIUS); padding(state.Search, 10, 0); self:_focusFeedback(state.Search)
	end
	state.List = make("ScrollingFrame", {
		Name = "Options", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(8, top),
		Size = UDim2.new(1, -16, 0, listHeight), AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
		ScrollBarThickness = 3, ZIndex = 102,
	}, menu)
	list(state.List, 2)
	state.Empty = self:_text(state.List, "No matching options", 11, false, "Muted")
	state.Empty.Name, state.Empty.Size, state.Empty.Visible, state.Empty.ZIndex = "Empty", UDim2.new(1, 0, 0, 32), false, 104
	for index, value in ipairs(control.Options) do
		local row = button(state.List, value)
		row.Name, row.Size, row.LayoutOrder, row.ZIndex = "Option_" .. value, UDim2.new(1, -4, 0, 30), index, 103
		row.TextXAlignment, row.TextTruncate = Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd
		padding(row, 10, 0); corner(row, 6)
		self:_skin(row, "TextColor3", "Text"); self:_skin(row, "BackgroundColor3", "Hover")
		local check = self:_icon(row, "check", "Accent")
		check.Position, check.Size = UDim2.new(1, -22, 0, 7), UDim2.fromOffset(16, 16)
		for _, object in ipairs(check:GetDescendants()) do if object:IsA("GuiObject") then object.ZIndex = 104 end end
		state.Rows[value] = { Button = row, Check = check }
		self:_connect(row.Activated, function()
			if self._popup ~= menu or not control:CanInteract() then return end
			if control.Multi then
				local values = control:Get()
				local found = table.find(values, value)
				if found then table.remove(values, found) else table.insert(values, value) end
				control:Set(values)
			else control:Set(value); self:_closeMenu() end
		end)
		self:_connect(row.MouseEnter, function() if self._popup == menu then self:_tween(row, { BackgroundTransparency = 0 }, 0.5) end end)
		self:_connect(row.MouseLeave, function() if self._popup == menu then control:_render() end end)
	end
	if control.Multi then
		state.Count = self:_text(menu, "", 10, false, "Muted")
		state.Count.Position, state.Count.Size, state.Count.ZIndex = UDim2.new(0, 12, 1, -34), UDim2.fromOffset(104, 26), 103
		local clear, done = button(menu, "Clear"), button(menu, "Done")
		clear.Name, done.Name = "ClearSelection", "Done"
		for _, entry in ipairs({ { clear, -132, 54 }, { done, -72, 64 } }) do
			local item = entry[1]
			item.Position, item.Size, item.ZIndex, item.BackgroundTransparency = UDim2.new(1, entry[2], 1, -34), UDim2.fromOffset(entry[3], 26), 103, 0
			self:_skin(item, "BackgroundColor3", "Field"); self:_skin(item, "TextColor3", "Accent"); self:_border(item, 6); self:_feedback(item)
		end
		self:_connect(clear.Activated, function() if self._popup == menu and control:CanInteract() then control:Set({}) end end)
		self:_connect(done.Activated, function() if self._popup == menu then self:_closeMenu() end end)
	end
	local function filter()
		local query = state.Search and string.lower(state.Search.Text) or ""
		local count = 0
		for value, row in pairs(state.Rows) do
			row.Button.Visible = query == "" or string.find(string.lower(value), query, 1, true) ~= nil
			if row.Button.Visible then count += 1 end
		end
		state.Empty.Visible = count == 0
		state.List.CanvasPosition = Vector2.zero
	end
	if state.Search then self:_connect(state.Search:GetPropertyChangedSignal("Text"), filter) end
	control:_render(); filter()
	self:_show(menu, true, true, nil, Vector2.new(0, -6))
end

function Section:Dropdown(options)
	options = options or {}
	local control, window = self:_row(options, "Dropdown")
	control.Options = deepCopy(options.Options or {})
	control.Multi, control.Searchable = options.Multi == true, options.Searchable ~= false
	assert(#control.Options > 0, "Dropdown requires at least one option")
	local function validateOptions(entries)
		assert(type(entries) == "table" and #entries > 0, "Options cannot be empty")
		local seen = {}
		for key in pairs(entries) do assert(type(key) == "number" and key % 1 == 0 and key >= 1 and key <= #entries, "Options must be an array") end
		for _, value in ipairs(entries) do assert(type(value) == "string" and not seen[value], "Options must be unique strings"); seen[value] = true end
	end
	validateOptions(control.Options)
	local function validateValue(value, entries)
		if not control.Multi then assert(type(value) == "string" and table.find(entries, value), "Invalid dropdown option"); return value end
		assert(type(value) == "table", "Multi dropdown expects an array")
		for key, item in pairs(value) do assert(type(key) == "number" and key % 1 == 0 and key >= 1 and key <= #value and type(item) == "string" and table.find(entries, item), "Invalid multi selection") end
		local canonical = {}
		for _, entry in ipairs(entries) do if table.find(value, entry) then table.insert(canonical, entry) end end
		return canonical
	end
	control.Validate = function(value) return validateValue(value, control.Options) end
	control.Value = control.Validate(options.Default or (control.Multi and {} or control.Options[1]))
	local field = button(control.Row, "")
	field.Name, field.Size, field.Position, field.ZIndex, field.BackgroundTransparency = "Dropdown", UDim2.fromOffset(174, 29), UDim2.new(1, -174, 0.5, -14), 11, 0
	window:_skin(field, "BackgroundColor3", "Field"); window:_skin(field, "TextColor3", "Text"); window:_border(field, FIELD_RADIUS)
	window:_feedback(field)
	control.Field = field
	field.TextTruncate = Enum.TextTruncate.AtEnd
	field.TextXAlignment = Enum.TextXAlignment.Left; padding(field, 10, 0)
	local arrow = window:_icon(field, "chevron-down")
	arrow.Position, arrow.Size, arrow.ZIndex = UDim2.new(1, -18, 0, 7), UDim2.fromOffset(14, 14), 12
	for _, child in ipairs(arrow:GetDescendants()) do if child:IsA("GuiObject") then child.ZIndex = 12 end end
	control.Arrow = arrow
	function control:_render()
		field.Text = self.Multi and (#self.Value == 0 and "Select options" or (#self.Value == 1 and self.Value[1] or tostring(#self.Value) .. " selected")) or self.Value
		local menu = self._menu
		if menu and menu.Frame.Parent then
			for value, row in pairs(menu.Rows) do
				local selected = self.Multi and table.find(self.Value, value) ~= nil or (not self.Multi and self.Value == value)
				row.Check.Visible = selected
				window:_tween(row.Button, { BackgroundTransparency = selected and 0 or 1 }, 0.6)
			end
			if menu.Count then menu.Count.Text = tostring(#self.Value) .. " selected" end
		end
	end
	function control:SetOptions(entries, default, silent)
		assert(not self.Destroyed, "Control has been destroyed")
		validateOptions(entries)
		local value = default
		if value == nil then
			if self.Multi then value = {}; for _, item in ipairs(self.Value) do if table.find(entries, item) then table.insert(value, item) end end
			else value = table.find(entries, self.Value) and self.Value or entries[1] end
		end
		value = validateValue(value, entries)
		self:Close(); self.Options = deepCopy(entries); self:Set(value, silent)
		return self
	end
	function control:Open()
		if not self:_canOpenPopup() then return self end
		window:_dropdownPopup(self)
		return self
	end
	window:_connect(field.Activated, function()
		if window._popupAnchor == field then window:_closeMenu(); return end
		control:Open()
	end)
	control:_render()
	window._refresh[control] = function() control:_render() end
	return control:_complete()
end

function Window:_checkerboard(parent, size, z)
	for y = 0, math.ceil(size.Y / 7) - 1 do
		for x = 0, math.ceil(size.X / 7) - 1 do
			local cell = make("Frame", { BorderSizePixel = 0, Position = UDim2.fromOffset(x * 7, y * 7), Size = UDim2.fromOffset(math.min(7, size.X - x * 7), math.min(7, size.Y - y * 7)), ZIndex = z }, parent)
			self:_skin(cell, "BackgroundColor3", (x + y) % 2 == 0 and "Track" or "Field")
		end
	end
end

function Window:_colorPopup(control)
	local menu = self:_openControlPopup(control, "ColorPicker", 286, 358)
	local state = { Frame = menu }
	control._menu = state
	local title = self:_text(menu, control.Label, 12, true)
	title.Position, title.Size, title.ZIndex = UDim2.fromOffset(12, 10), UDim2.fromOffset(262, 20), 103
	state.SV = button(menu, "")
	state.SV.Name, state.SV.Position, state.SV.Size, state.SV.BackgroundTransparency, state.SV.ZIndex = "SaturationValue", UDim2.fromOffset(12, 38), UDim2.fromOffset(262, 132), 0, 103
	corner(state.SV, 6)
	local white = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 104 }, state.SV)
	corner(white, 6)
	make("UIGradient", { Transparency = NumberSequence.new(0, 1) }, white)
	local black = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 105 }, state.SV)
	corner(black, 6)
	make("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }, black)
	state.Marker = make("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(9, 9), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.7, BorderSizePixel = 0, ZIndex = 107 }, state.SV)
	corner(state.Marker, 9); make("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2 }, state.Marker)
	state.Hue = button(menu, "")
	state.Hue.Name, state.Hue.Position, state.Hue.Size, state.Hue.BackgroundTransparency, state.Hue.BackgroundColor3, state.Hue.ZIndex = "Hue", UDim2.fromOffset(12, 182), UDim2.fromOffset(262, 12), 0, Color3.new(1, 1, 1), 103
	corner(state.Hue, 6)
	local rainbow = {}
	for index = 0, 6 do table.insert(rainbow, ColorSequenceKeypoint.new(index / 6, Color3.fromHSV(index / 6, 1, 1))) end
	make("UIGradient", { Color = ColorSequence.new(rainbow) }, state.Hue)
	state.HueMarker = make("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(3, 18), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 105 }, state.Hue)
	corner(state.HueMarker, 3)
	local alphaLabel = self:_text(menu, "Opacity", 10, false, "Muted")
	alphaLabel.Position, alphaLabel.Size, alphaLabel.ZIndex = UDim2.fromOffset(12, 202), UDim2.fromOffset(110, 16), 103
	state.AlphaValue = self:_text(menu, "", 10, false, "Muted")
	state.AlphaValue.Position, state.AlphaValue.Size, state.AlphaValue.TextXAlignment, state.AlphaValue.ZIndex = UDim2.fromOffset(218, 202), UDim2.fromOffset(56, 16), Enum.TextXAlignment.Right, 103
	state.Alpha = button(menu, "")
	state.Alpha.Name, state.Alpha.Position, state.Alpha.Size, state.Alpha.ZIndex, state.Alpha.ClipsDescendants = "Alpha", UDim2.fromOffset(12, 224), UDim2.fromOffset(262, 12), 103, true
	corner(state.Alpha, 6); self:_checkerboard(state.Alpha, Vector2.new(262, 12), 103)
	state.AlphaColor = make("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, ZIndex = 104 }, state.Alpha)
	make("UIGradient", { Transparency = NumberSequence.new(1, 0) }, state.AlphaColor)
	state.AlphaMarker = make("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(3, 12), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 105 }, state.Alpha)
	local function field(name, x, width)
		local caption = self:_text(menu, name, 9, true, "Muted")
		caption.Position, caption.Size, caption.ZIndex = UDim2.fromOffset(x, 246), UDim2.fromOffset(width, 14), 103
		local item = make("TextBox", {
			Name = name, Text = "", Font = FONT, TextSize = 11, ClearTextOnFocus = false, BorderSizePixel = 0,
			Position = UDim2.fromOffset(x, 264), Size = UDim2.fromOffset(width, 28), ZIndex = 103,
		}, menu)
		self:_skin(item, "BackgroundColor3", "Field"); self:_skin(item, "TextColor3", "Text"); self:_border(item, FIELD_RADIUS); self:_focusFeedback(item)
		return item
	end
	state.Hex = field("HEX", 12, 92)
	state.R, state.G, state.B = field("R", 112, 48), field("G", 166, 48), field("B", 220, 54)
	state.Error = self:_text(menu, "", 10, false, "Muted")
	state.Error.Name, state.Error.Position, state.Error.Size, state.Error.ZIndex = "Validation", UDim2.fromOffset(12, 298), UDim2.fromOffset(262, 18), 103
	local done = button(menu, "Done")
	done.Name, done.Position, done.Size, done.BackgroundTransparency, done.ZIndex = "Done", UDim2.fromOffset(12, 322), UDim2.fromOffset(262, 26), 0, 103
	self:_skin(done, "BackgroundColor3", "Field"); self:_skin(done, "TextColor3", "Accent"); self:_border(done, FIELD_RADIUS); self:_feedback(done)
	self:_connect(done.Activated, function() if self._popup == menu then self:_closeMenu() end end)
	local function ratio(object, x, y)
		local inset = GuiService:GetGuiInset()
		return math.clamp((x - object.AbsolutePosition.X - inset.X) / math.max(1, object.AbsoluteSize.X), 0, 1), math.clamp((y - object.AbsolutePosition.Y - inset.Y) / math.max(1, object.AbsoluteSize.Y), 0, 1)
	end
	local function updateSV(x, y)
		if self._popup ~= menu or not control:CanInteract() then return end
		local saturation, value = ratio(state.SV, x, y)
		control:SetHSV(control._hue, saturation, 1 - value)
	end
	local function updateHue(x, y)
		if self._popup ~= menu or not control:CanInteract() then return end
		local hue = ratio(state.Hue, x, y)
		local color = control:Get(); local _, saturation, value = color:ToHSV()
		control:SetHSV(hue, saturation, value)
	end
	local function updateAlpha(x, y)
		if self._popup ~= menu or not control:CanInteract() then return end
		local alpha = ratio(state.Alpha, x, y)
		control:SetAlpha(alpha)
	end
	state.UpdateSV, state.UpdateHue, state.UpdateAlpha = updateSV, updateHue, updateAlpha
	for _, entry in ipairs({ { state.SV, updateSV, "SV" }, { state.Hue, updateHue, "Hue" }, { state.Alpha, updateAlpha, "Alpha" } }) do
		self:_connect(entry[1].InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if self._popup ~= menu or not control:CanInteract() then return end
				self._colorDrag = { input = input, control = control, update = entry[2], kind = entry[3] }
				entry[2](input.Position.X, input.Position.Y)
			end
		end)
	end
	self:_connect(state.Hex.FocusLost, function()
		if self._popup ~= menu or not control:CanInteract() then return end
		local ok = pcall(function() control:Set(state.Hex.Text) end)
		if not ok then control:_render(); state.Error.Text = "Use a 3- or 6-digit HEX color." end
	end)
	local function rgb()
		if self._popup ~= menu or not control:CanInteract() then return end
		local red, green, blue = tonumber(state.R.Text), tonumber(state.G.Text), tonumber(state.B.Text)
		for _, channel in ipairs({ red or -1, green or -1, blue or -1 }) do
			if not finite(channel) or channel < 0 or channel > 255 then control:_render(); state.Error.Text = "RGB values must be from 0 to 255."; return end
		end
		control:Set(Color3.fromRGB(math.round(red), math.round(green), math.round(blue)))
	end
	for _, item in ipairs({ state.R, state.G, state.B }) do self:_connect(item.FocusLost, rgb) end
	control:_render()
	self:_show(menu, true, true, nil, Vector2.new(0, -6))
end

function Section:ColorPicker(options)
	options = options or {}
	local control, window = self:_row(options, "ColorPicker")
	control._hue = 0
	control.Validate = function(value)
		local alpha = control.Value and control.Value.Alpha or options.Alpha or 1
		local color = value
		if type(value) == "table" then color = value.Hex; if value.Alpha ~= nil then alpha = value.Alpha end end
		assert(finite(alpha) and alpha >= 0 and alpha <= 1, "Color alpha must be from 0 to 1")
		if typeof(color) ~= "Color3" then
			assert(type(color) == "string", "Color expects Color3, HEX, or {Hex, Alpha}")
			local hex = color:gsub("^#", "")
			assert((#hex == 3 or #hex == 6) and hex:match("^[%da-fA-F]+$"), "Invalid HEX color")
			color = Color3.fromHex(hex)
		end
		assert(color.R >= 0 and color.R <= 1 and color.G >= 0 and color.G <= 1 and color.B >= 0 and color.B <= 1, "Invalid RGB color")
		return { Hex = "#" .. string.upper(color:ToHex()), Alpha = alpha }
	end
	control.Value = control.Validate(options.Default or window.Palette.Accent)
	function control:Get()
		assert(not self.Destroyed, "Control has been destroyed")
		return Color3.fromHex(self.Value.Hex), self.Value.Alpha
	end
	function control:SetAlpha(alpha, silent) return self:Set({ Hex = self.Value.Hex, Alpha = alpha }, silent) end
	function control:SetHSV(hue, saturation, value, silent)
		assert(finite(hue) and finite(saturation) and finite(value), "HSV values must be finite numbers")
		for _, channel in ipairs({ hue, saturation, value }) do assert(finite(channel) and channel >= 0 and channel <= 1, "HSV values must be from 0 to 1") end
		self._hue = hue
		return self:Set(Color3.fromHSV(hue, saturation, value), silent)
	end
	local field = button(control.Row, "")
	field.Name, field.Size, field.Position, field.ZIndex, field.BackgroundTransparency = "ColorPicker", UDim2.fromOffset(174, 29), UDim2.new(1, -174, 0.5, -14), 11, 0
	window:_skin(field, "BackgroundColor3", "Field"); window:_skin(field, "TextColor3", "Text"); window:_border(field, FIELD_RADIUS); window:_feedback(field)
	field.TextXAlignment = Enum.TextXAlignment.Left; padding(field, 10, 0)
	local swatch = make("Frame", { Name = "Swatch", Position = UDim2.new(1, -35, 0, 5), Size = UDim2.fromOffset(27, 18), ClipsDescendants = true, BackgroundTransparency = 1, ZIndex = 12 }, field)
	corner(swatch, 4); window:_checkerboard(swatch, Vector2.new(27, 18), 12)
	local colorFace = make("Frame", { Name = "Color", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, ZIndex = 13 }, swatch); corner(colorFace, 4)
	control.Field = field
	function control:_render()
		local color, alpha = self:Get()
		field.Text, colorFace.BackgroundColor3, colorFace.BackgroundTransparency = self.Value.Hex, color, 1 - alpha
		local hue, saturation, value = color:ToHSV()
		if saturation > 0 and value > 0 and not (window._colorDrag and window._colorDrag.control == self and window._colorDrag.kind == "Hue") then
			if math.abs(hue - self._hue) < 0.999 then self._hue = hue end
		end
		local menu = self._menu
		if menu and menu.Frame.Parent then
			menu.SV.BackgroundColor3 = Color3.fromHSV(self._hue, 1, 1)
			menu.Marker.Position, menu.HueMarker.Position = UDim2.fromScale(saturation, 1 - value), UDim2.fromScale(self._hue, 0.5)
			menu.AlphaColor.BackgroundColor3, menu.AlphaMarker.Position = color, UDim2.fromScale(alpha, 0.5)
			menu.AlphaValue.Text = tostring(math.round(alpha * 100)) .. "%"
			if not menu.Hex:IsFocused() then menu.Hex.Text = self.Value.Hex end
			for _, entry in ipairs({ { menu.R, color.R }, { menu.G, color.G }, { menu.B, color.B } }) do if not entry[1]:IsFocused() then entry[1].Text = tostring(math.round(entry[2] * 255)) end end
			menu.Error.Text = ""
		end
	end
	function control:Open()
		if self:_canOpenPopup() then window:_colorPopup(self) end
		return self
	end
	window:_connect(field.Activated, function() if window._popupOwner == control then control:Close() else control:Open() end end)
	control:_render(); window._refresh[control] = function() control:_render() end
	return control:_complete()
end

function Section:Input(options)
	options = options or {}
	local control, window = self:_row(options, "Input")
	local maxLength = options.MaxLength or 128
	assert(type(maxLength) == "number" and maxLength >= 0 and maxLength < math.huge and maxLength % 1 == 0, "MaxLength must be a nonnegative integer")
	control.Validate = function(value)
		assert(type(value) == "string", "Input expects a string")
		local characters = utf8.len(value)
		assert(characters, "Input must be valid UTF-8")
		if characters > maxLength then value = string.sub(value, 1, utf8.offset(value, maxLength + 1) - 1) end
		return value
	end
	control.Value = control.Validate(options.Default or "")
	local field = make("TextBox", {
		Name = "Input", Size = UDim2.fromOffset(174, 29), Position = UDim2.new(1, -174, 0.5, -14),
		Text = control.Value, PlaceholderText = options.Placeholder or "Enter text", Font = FONT, TextSize = 12,
		ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, ZIndex = 11,
	}, control.Row)
	window:_skin(field, "BackgroundColor3", "Field"); window:_skin(field, "TextColor3", "Text"); window:_skin(field, "PlaceholderColor3", "Muted")
	window:_border(field, FIELD_RADIUS); padding(field, 10, 0)
	window:_focusFeedback(field)
	function control:_render() field.Text = self.Value end
	window:_connect(field.FocusLost, function() if control:CanInteract() then control:Set(field.Text) end end)
	return control:_complete()
end

function Section:Keybind(options)
	options = options or {}
	local control, window = self:_row(options, "Keybind")
	control.Validate = function(value)
		if typeof(value) == "EnumItem" then value = value.Name end
		assert(type(value) == "string" and Enum.KeyCode[value] and value ~= "Unknown", "Invalid keybind")
		return value
	end
	control.Value = control.Validate(options.Default or "RightShift")
	control.OnPressed = options.OnPressed
	local field = button(control.Row, "")
	field.Name, field.Size, field.Position, field.ZIndex, field.BackgroundTransparency = "Keybind", UDim2.fromOffset(125, 29), UDim2.new(1, -125, 0.5, -14), 11, 0
	window:_skin(field, "BackgroundColor3", "Field"); window:_skin(field, "TextColor3", "Muted"); window:_border(field, FIELD_RADIUS)
	window:_feedback(field)
	local line = field:FindFirstChildOfClass("UIStroke")
	function control:_render()
		field.Text = self.Value
		window:_tween(line, { Color = window.Palette.Border, Thickness = 1, Transparency = 0.12 }, 0.65)
	end
	window:_connect(field.Activated, function()
		if not control:CanInteract() then return end
		window:_cancelInteractions()
		window._capturing = control; field.Text = "Press a key…"
		window:_tween(line, { Color = window.Palette.Accent, Thickness = 1.5, Transparency = 0 }, 0.65)
	end)
	control:_render()
	return control:_complete()
end

function Section:Button(options)
	options = options or {}
	local control, window = self:_row(options, "Button")
	local field = button(control.Row, options.Text or "Run")
	field.Name, field.Size, field.Position, field.ZIndex, field.BackgroundTransparency = "Button", UDim2.fromOffset(125, 29), UDim2.new(1, -125, 0.5, -14), 11, 0
	window:_skin(field, "BackgroundColor3", options.Primary and "Accent" or "Field")
	if options.Primary then field.TextColor3 = Color3.new(1, 1, 1) else window:_skin(field, "TextColor3", "Text") end
	window:_border(field, FIELD_RADIUS)
	window:_feedback(field)
	function control:_render() end
	window:_connect(field.Activated, function() if control:CanInteract() then window:_callback(control.Callback) end end)
	return control:_complete()
end

function Section:Label(options)
	if type(options) == "string" then options = { Label = options } end
	options = options or {}
	local control, window = self:_row(options, "Label")
	control.Value = options.Value or ""
	local value = window:_text(control.Row, control.Value, 11, false, "Muted")
	control.ValueText = value
	value.Position, value.Size, value.TextXAlignment, value.ZIndex = UDim2.fromScale(0.45, 0), UDim2.fromScale(0.55, 1), Enum.TextXAlignment.Right, 10
	control.LabelText.Size = UDim2.new(0.43, 0, control.LabelText.Size.Y.Scale, control.LabelText.Size.Y.Offset)
	function control:_render() value.Text = tostring(self.Value) end
	return control:_complete()
end

function Window:GetLayout()
	local function normalized(value, maximum) return math.clamp(value / math.max(1, maximum), 0, 1) end
	local position = self.Maximized and self._restorePosition or self:_target(self.Main, "Position")
	position = position or self.Main.Position
	local dockPosition = self._dockSide and self:_dockExpandedPosition(self._dockSide) or self:_target(self.Dock, "Position")
	local panels = {}
	for _, section in ipairs(self.Sections) do
		local point = section.Detached and section.Float and self:_target(section.Float, "Position") or section._lastFloatPosition
		panels[section.Id] = { Detached = section.Detached, X = point and normalized(point.X.Offset, self._rootWidth) or nil, Y = point and normalized(point.Y.Offset, self._rootHeight) or nil }
	end
	return {
		Version = 1, ActiveTab = self.ActiveTab and self.ActiveTab.Name or nil,
		Window = { Width = self.WindowSize.X, Height = self.WindowSize.Y, X = normalized(position.X.Offset, self._rootWidth), Y = normalized(position.Y.Offset, self._rootHeight), Columns = self.Columns, Maximized = self.Maximized == true, Visible = self.Visible, Minimized = self.Minimized },
		Dock = { X = normalized(dockPosition.X.Offset, self._dockWidth), Y = normalized(dockPosition.Y.Offset, self._dockHeight), Moved = self._dockMoved == true, Side = self._dockSide or false },
		Panels = panels,
	}
end

function Window:ExportLayout() return HttpService:JSONEncode(self:GetLayout()) end

function Window:_validateLayout(value)
	assert(type(value) == "table" and value.Version == 1, "Unsupported layout")
	local result = { Version = 1, Panels = {} }
	local function number(value, minimum, maximum, name)
		assert(finite(value) and value >= minimum and value <= maximum, "Invalid layout " .. name)
		return value
	end
	local function boolean(value, name) assert(type(value) == "boolean", "Invalid layout " .. name); return value end
	local window, dock = value.Window, value.Dock
	assert(type(window) == "table" and type(dock) == "table" and type(value.Panels) == "table", "Incomplete layout")
	assert(window.Columns == nil or window.Columns == 1 or window.Columns == 2, "Invalid layout columns")
	result.Window = {
		Width = number(window.Width, self.MinSize.X, self.MaxSize.X, "width"), Height = number(window.Height, self.MinSize.Y, self.MaxSize.Y, "height"),
		X = number(window.X, 0, 1, "window X"), Y = number(window.Y, 0, 1, "window Y"),
		Columns = window.Columns or self.Columns,
		Maximized = boolean(window.Maximized, "maximized"), Visible = boolean(window.Visible, "visible"), Minimized = boolean(window.Minimized, "minimized"),
	}
	assert(dock.Side == false or dock.Side == "Left" or dock.Side == "Right", "Invalid layout dock side")
	result.Dock = { X = number(dock.X, 0, 1, "dock X"), Y = number(dock.Y, 0, 1, "dock Y"), Moved = boolean(dock.Moved, "dock moved"), Side = dock.Side }
	assert(value.ActiveTab == nil or type(value.ActiveTab) == "string", "Invalid active tab")
	result.ActiveTab = value.ActiveTab
	for id, panel in pairs(value.Panels) do
		assert(type(id) == "string" and type(panel) == "table", "Invalid panel layout")
		local item = { Detached = boolean(panel.Detached, "detached") }
		if panel.X ~= nil or panel.Y ~= nil or item.Detached then
			item.X, item.Y = number(panel.X, 0, 1, "panel X"), number(panel.Y, 0, 1, "panel Y")
		end
		result.Panels[id] = item
	end
	return result
end

function Window:_applyLayout(layout)
	self:_closeMenu(); self:_hideTooltip()
	self.Search.Text = ""
	self:_settleVisibility(self.Main); self:_stop(self.Main)
	self.Maximized = false
	self.Columns = layout.Window.Columns
	self.WindowSize = Vector2.new(layout.Window.Width, layout.Window.Height)
	self:_layout()
	self.Main.Position = UDim2.fromOffset(layout.Window.X * self._rootWidth, layout.Window.Y * self._rootHeight)
	self:_clamp(self.Main)
	self._restorePosition = self.Main.Position
	for id, item in pairs(layout.Panels) do
		local section = self._sectionIds[id]
		if section then
			if item.Detached then section:Detach() else section:Dock() end
			if item.X then
				local position = UDim2.fromOffset(item.X * self._rootWidth, item.Y * self._rootHeight)
				section._lastFloatPosition = position
				if section.Detached and section.Float then
					self:_settleVisibility(section.Float); self:_stop(section.Float, "Position")
					section.Float.Position = position; self:_clamp(section.Float)
				end
			else
				section._lastFloatPosition = nil
			end
		end
	end
	if layout.ActiveTab then for _, tab in ipairs(self.Tabs) do if tab.Name == layout.ActiveTab then self:SelectTab(tab); break end end end
	self:_settleVisibility(self.Dock); self:_settleVisibility(self.DockHandle); self:_stop(self.Dock, "Position")
	self._dockSide, self._dockMoved = nil, layout.Dock.Moved
	self.Dock.Position = self._dockMoved and UDim2.fromOffset(layout.Dock.X * self._dockWidth, layout.Dock.Y * self._dockHeight) or UDim2.fromOffset(self._dockWidth / 2, 0)
	self:_clamp(self.Dock)
	self.Minimized = layout.Window.Minimized
	if layout.Dock.Side then self:StowDock(layout.Dock.Side) end
	if layout.Window.Maximized then self:SetMaximized(true) end
	self:SetVisible(layout.Window.Visible)
end

function Window:ImportLayout(value)
	local ok, message = pcall(function()
		if type(value) == "string" then value = HttpService:JSONDecode(value) end
		local layout = self:_validateLayout(value)
		self:_applyLayout(layout)
	end)
	return ok, ok and nil or tostring(message)
end

function Window:ExportProfile()
	local values = {}
	for id, control in pairs(self._ids) do if control.Persist then values[id] = control:Serialize() end end
	local accent = self.Palette.Accent
	return HttpService:JSONEncode({
		Version = 1, Values = values,
		Layout = self:GetLayout(),
		Appearance = { Theme = self.Theme, Accent = { accent.R, accent.G, accent.B }, AccentMode = self._accentOverride and "Custom" or "Theme", Scale = self.Scale, Opacity = self.Opacity },
	})
end

function Window:_prepareProfile(profile)
	assert(type(profile) == "table" and profile.Version == 1 and type(profile.Values) == "table", "Unsupported profile")
	local validated = {}
	for id, value in pairs(profile.Values) do
		local control = self._ids[id]
		if control and control.Persist then validated[id] = control.Validate and control.Validate(value) or value end
	end
	local appearance = profile.Appearance or {}
	assert(type(appearance) == "table", "Invalid appearance")
	if appearance.Theme then assert(THEMES[appearance.Theme], "Invalid theme") end
	assert(appearance.AccentMode == nil or appearance.AccentMode == "Theme" or appearance.AccentMode == "Custom", "Invalid accent mode")
	for _, key in ipairs({ "Scale", "Opacity" }) do
		if appearance[key] ~= nil then assert(type(appearance[key]) == "number" and appearance[key] == appearance[key] and math.abs(appearance[key]) < math.huge, "Invalid " .. key) end
	end
	if appearance.Accent then
		assert(type(appearance.Accent) == "table" and #appearance.Accent == 3, "Invalid accent")
		for _, channel in ipairs(appearance.Accent) do assert(type(channel) == "number" and channel >= 0 and channel <= 1, "Invalid accent channel") end
	end
	local layout = profile.Layout and self:_validateLayout(profile.Layout) or nil
	return { Values = validated, Appearance = deepCopy(appearance), Layout = layout }
end

function Window:ImportProfile(json)
	local ok, result = pcall(function()
		local prepared = self:_prepareProfile(HttpService:JSONDecode(json))
		local validated, appearance, layout = prepared.Values, prepared.Appearance, prepared.Layout
		-- Validate the whole document before applying any values.
		for _, control in ipairs(self.Controls) do if control.Id and validated[control.Id] ~= nil then control:Set(validated[control.Id]) end end
		if appearance.Theme then self:SetTheme(appearance.Theme) end
		if appearance.AccentMode == "Theme" then self:ResetAccent()
		elseif appearance.Accent then self:SetAccent(Color3.new(table.unpack(appearance.Accent))) end
		if appearance.Scale then self:SetScale(appearance.Scale) end
		if appearance.Opacity then self:SetOpacity(appearance.Opacity) end
		if layout then self:_applyLayout(layout) end
	end)
	return ok, ok and nil or tostring(result)
end

function Window:CaptureDefaults()
	assert(not self.Destroyed, "Window has been destroyed")
	self._defaults = HttpService:JSONDecode(self:ExportProfile())
	return self
end

function Window:Reset(scope)
	scope = scope or "All"
	assert(scope == "Appearance" or scope == "Controls" or scope == "Layout" or scope == "All", "Unknown reset scope")
	assert(self._defaults, "Call CaptureDefaults after constructing your UI")
	local profile = { Version = 1, Values = {} }
	if scope == "All" or scope == "Appearance" then profile.Appearance = deepCopy(self._defaults.Appearance) end
	if scope == "All" or scope == "Layout" then profile.Layout = deepCopy(self._defaults.Layout) end
	for id, value in pairs(self._defaults.Values) do
		local control = self._ids[id]
		if control and (scope == "All" or scope == control.ResetGroup) then profile.Values[id] = deepCopy(value) end
	end
	return self:ImportProfile(HttpService:JSONEncode(profile))
end

function Window:Confirm(options)
	assert(not self.Destroyed and type(options) == "table", "Invalid confirmation options")
	assert(options.Validate == nil or type(options.Validate) == "function", "Validate must be a function")
	assert(options.Text == nil or (type(options.Text) == "string" and #options.Text <= 100000), "Dialog text exceeds 100 KB")
	assert(options.OnConfirm == nil or type(options.OnConfirm) == "function", "OnConfirm must be a function")
	assert(options.OnCancel == nil or type(options.OnCancel) == "function", "OnCancel must be a function")
	if self._confirmation then self._confirmation:Cancel() end
	self:_cancelInteractions()
	self:SetVisible(true); self:SetMinimized(false)
	local root = make("Frame", { Name = "Confirmation", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 20000 }, self.Root)
	local dismiss = button(root, "")
	dismiss.Size, dismiss.ZIndex, dismiss.BackgroundColor3, dismiss.BackgroundTransparency = UDim2.fromScale(1, 1), 20000, Color3.new(), 0.45
	local hasEditor = options.Text ~= nil
	local panel = make("Frame", { Name = "Dialog", Size = UDim2.fromOffset(hasEditor and 480 or 380, hasEditor and 420 or 192), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BorderSizePixel = 0, Active = true, ZIndex = 20001 }, root)
	self:_surface(panel, "Card"); self:_border(panel, WINDOW_RADIUS)
	local title = self:_text(panel, options.Title or "Are you sure?", 17, true)
	title.Position, title.Size, title.ZIndex = UDim2.fromOffset(22, 22), UDim2.new(1, -44, 0, 25), 20002
	local description = self:_text(panel, options.Description or "", 12, false, "Muted")
	description.Position, description.Size, description.ZIndex = UDim2.fromOffset(22, 60), UDim2.new(1, -44, 0, 58), 20002
	description.TextWrapped, description.TextYAlignment = true, Enum.TextYAlignment.Top
	local editor, validationLabel
	if hasEditor then
		assert(type(options.Text) == "string", "Dialog text must be a string")
		description.Size = UDim2.new(1, -44, 0, 34)
		local scroll = make("ScrollingFrame", {Name="EditorScroll",Position=UDim2.fromOffset(22,100),Size=UDim2.new(1,-44,0,236),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=3,BorderSizePixel=0,ZIndex=20002},panel)
		self:_skin(scroll,"BackgroundColor3","Field");self:_border(scroll,FIELD_RADIUS)
		editor = make("TextBox",{Name="Editor",Text=options.Text,MultiLine=true,ClearTextOnFocus=false,TextEditable=options.ReadOnly~=true,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Font=Enum.Font.Code,TextSize=11,BackgroundTransparency=1,Position=UDim2.fromOffset(8,8),Size=UDim2.new(1,-20,0,220),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=20003},scroll)
		self:_skin(editor,"TextColor3","Text")
		validationLabel = self:_text(panel,"",10,false,"Muted")
		validationLabel.Position,validationLabel.Size,validationLabel.ZIndex=UDim2.fromOffset(22,340),UDim2.new(1,-44,0,30),20002
		validationLabel.TextWrapped=true
	end
	local cancel, accept = button(panel, "Cancel"), button(panel, options.ConfirmText or "Confirm")
	cancel.Name, accept.Name = "Cancel", "Confirm"
	cancel.Position, accept.Position = UDim2.fromOffset(22, hasEditor and 372 or 140), UDim2.new(1, -181, 0, hasEditor and 372 or 140)
	for _, item in ipairs({cancel, accept}) do item.Size, item.ZIndex, item.BackgroundTransparency = UDim2.fromOffset(159, 30), 20003, 0; self:_border(item, FIELD_RADIUS); self:_feedback(item) end
	self:_skin(cancel, "BackgroundColor3", "Field"); self:_skin(cancel, "TextColor3", "Text")
	self:_skin(accept, "BackgroundColor3", "Accent"); accept.TextColor3 = Color3.new(1, 1, 1)
	local window, connections = self, {}
	local handle = { Root = root, Pending = true, Editor = editor, ErrorLabel = validationLabel }
	local function finish(confirmed)
		if not handle.Pending then return end
		if confirmed and editor and options.Validate then
			local success, valid, message = pcall(options.Validate, editor.Text)
			if not success or not valid then validationLabel.Text = tostring((success and message or valid) or "Invalid config data"); return end
		end
		handle.Pending = false
		if window._confirmation == handle then window._confirmation = nil end
		for _, connection in ipairs(connections) do connection:Disconnect() end
		window:_show(root, false, false, function() root:Destroy(); window:_prune() end, Vector2.zero)
		if confirmed then window:_callback(options.OnConfirm, editor and editor.Text) else window:_callback(options.OnCancel) end
	end
	function handle:Confirm() finish(true) end
	function handle:Cancel() finish(false) end
	connections = { self:_connect(cancel.Activated, function() finish(false) end), self:_connect(dismiss.Activated, function() finish(false) end), self:_connect(accept.Activated, function() finish(true) end) }
	self._confirmation = handle
	self:_show(root, true, true, nil, Vector2.zero)
	return handle
end

function Window:RequestReset(scope)
	assert(self._defaults, "Call CaptureDefaults before requesting a reset")
	assert(scope == "Appearance" or scope == "Controls" or scope == "Layout" or scope == "All", "Unknown reset scope")
	local descriptions = {
		Appearance = "Restore the default theme, accent and appearance settings? Your controls and layout will stay as they are.",
		Controls = "Restore the default control values and keybinds? Your appearance and layout will stay as they are.",
		Layout = "Bring panels home and restore the original window and dock positions? Your settings will stay as they are.",
		All = "Restore all settings, appearance and window positions to their original values? Saved named profiles will stay available.",
	}
	return self:Confirm({Title = "Reset " .. string.lower(scope) .. "?", Description = descriptions[scope], ConfirmText = "Reset", OnConfirm = function()
		local ok, message = self:Reset(scope)
		self:Notify({Title = ok and "Defaults restored" or "Could not reset", Description = ok and "Your changes have been applied." or message, Preview = true})
	end})
end

local function equalSettings(a, b)
	if type(a) ~= type(b) then return false end
	if type(a) ~= "table" then return a == b end
	for key, value in pairs(a) do if not equalSettings(value, b[key]) then return false end end
	for key in pairs(b) do if a[key] == nil then return false end end
	return true
end

function Window:_settingsSnapshot()
	local current=HttpService:JSONDecode(self:ExportProfile())
	self:_configBank().Current=deepCopy(current)
	return { Version = 1, Current = current, Profiles = deepCopy(self._profiles), Configurations = {Version = 1, Banks = deepCopy(self._configBanks)} }
end

function Window:_storageStatus(status, message)
	local state = self._persistence
	if not state then return end
	state.Status, state.Error = status, message
	self:_callback(state.OnStatus, status, message)
end

function Window:GetPersistenceStatus()
	local state = self._persistence
	return state and state.Status or "Disabled", state and state.Error
end

function Window:LoadSettings()
	local state = self._persistence
	if not state then return false, "Persistence is not configured" end
	if state.Busy then return false, "Storage is busy" end
	state.Busy = true; self:_storageStatus("Loading")
	local ok, result = pcall(function()
		local raw = state.Adapter.Load(state.Key)
		assert(not self.Destroyed and self._persistence == state, "Storage session ended")
		if raw == nil then return nil end
		assert(type(raw) == "string" and #raw <= 200000, "Invalid settings document")
		local data = HttpService:JSONDecode(raw)
		assert(type(data) == "table" and data.Version == 1 and type(data.Current) == "table" and type(data.Profiles) == "table", "Unsupported settings document")
		for name, profile in pairs(data.Profiles) do
			assert(type(name) == "string" and #name <= 128 and type(profile) == "string", "Invalid saved profile")
			local value = HttpService:JSONDecode(profile)
			assert(type(value) == "table" and value.Version == 1 and type(value.Values) == "table", "Invalid saved profile")
		end
		local banks = self:_validateConfigBanks(data)
		local scopeCount=0;for _ in pairs(banks)do scopeCount+=1 end
		assert(banks[self.ConfigScope] or scopeCount<32,"Settings already contain 32 game scopes")
		local bank = banks[self.ConfigScope] or {Profiles = deepCopy(self._profiles), Current = HttpService:JSONDecode(self:ExportProfile())}
		banks[self.ConfigScope] = bank
		local current=bank.Current or data.Current
		self:_prepareProfile(current)
		if bank.AutoLoad then self:_prepareProfile(HttpService:JSONDecode(bank.Profiles[bank.AutoLoad])) end
		local loaded, message = self:ImportProfile(HttpService:JSONEncode(current))
		assert(loaded, message)
		if bank.AutoLoad then
			local applied, err = self:ImportProfile(bank.Profiles[bank.AutoLoad]); assert(applied, err)
			bank.Active = bank.AutoLoad
		end
		data._LoadedBanks = banks
		return data
	end)
	if self.Destroyed or self._persistence ~= state then return false, "Storage session ended" end
	state.Busy, state.Writable = false, ok
	if not ok then self:_storageStatus("Error", tostring(result)); return false, tostring(result) end
	if result then
		self._configBanks = result._LoadedBanks
		self._profiles = self._configBanks[self.ConfigScope].Profiles
		self:_configsChanged()
	end
	state.Observed = self:_settingsSnapshot()
	state.LastSaved = result and deepCopy(state.Observed) or nil
	state.ChangedAt = not result and os.clock() or nil
	self:_storageStatus(result and "Saved" or "Ready")
	return true, result ~= nil
end

function Window:SaveSettings()
	local state = self._persistence
	if not state or self.Destroyed then return false, "Persistence is not configured" end
	if state.Busy then return false, "Storage is busy" end
	if not state.Writable then return false, "Load failed; retry loading before saving" end
	local snapshot = self:_settingsSnapshot()
	if equalSettings(snapshot, state.LastSaved) then self:_storageStatus("Saved"); return true end
	state.Busy = true; self:_storageStatus("Saving")
	local ok, result = pcall(function()
		local json = HttpService:JSONEncode(snapshot)
		assert(#json <= 200000, "Settings exceed storage limit")
		local saved, message = state.Adapter.Save(state.Key, json)
		assert(saved == true, message or "Storage did not acknowledge the save")
	end)
	if self.Destroyed or self._persistence ~= state then return false, "Storage session ended" end
	state.Busy = false
	if not ok then state.RetryAfter = os.clock() + 6; self:_storageStatus("Error", tostring(result)); return false, tostring(result) end
	state.LastSaved, state.Observed, state.ChangedAt, state.RetryAfter = snapshot, deepCopy(snapshot), nil, nil
	self:_storageStatus("Saved")
	return true
end

function Window:DisablePersistence(flush)
	local state = self._persistence
	if not state then return end
	if flush then self:SaveSettings() end
	if state.Job and self._jobs[state.Job] then task.cancel(state.Job); self._jobs[state.Job] = nil end
	self._persistence = nil
end

function Window:ConfigurePersistence(options)
	assert(not self.Destroyed and type(options) == "table", "Invalid persistence options")
	assert(not self._persistence or not self._persistence.Busy, "Storage is busy")
	assert(type(options.Adapter) == "table" and type(options.Adapter.Load) == "function" and type(options.Adapter.Save) == "function", "Adapter requires Load and Save functions")
	assert(type(options.Key) == "string" and #options.Key > 0 and #options.Key <= 64, "Invalid storage key")
	assert(options.Debounce == nil or (finite(options.Debounce) and options.Debounce >= 0.05), "Invalid save debounce")
	assert(options.OnStatus == nil or type(options.OnStatus) == "function", "Invalid status callback")
	self:DisablePersistence(false)
	local state = { Adapter = options.Adapter, Key = options.Key, AutoSave = options.AutoSave ~= false, Debounce = options.Debounce or 1.5, OnStatus = options.OnStatus, Writable = options.Load == false, Status = "Ready" }
	self._persistence = state
	local ok, message = true, nil
	if options.Load ~= false then ok, message = self:LoadSettings() else state.Observed = self:_settingsSnapshot(); state.ChangedAt = os.clock() end
	local function tick()
		if self.Destroyed or self._persistence ~= state then return end
		if state.AutoSave and state.Writable and not state.Busy then
			local snapshot = self:_settingsSnapshot()
			if not equalSettings(snapshot, state.Observed) then state.Observed, state.ChangedAt = snapshot, os.clock(); self:_storageStatus("Unsaved") end
			if state.ChangedAt and os.clock() - state.ChangedAt >= state.Debounce and os.clock() >= (state.RetryAfter or 0) then self:SaveSettings() end
		end
		if not self.Destroyed and self._persistence == state then state.Job = self:_later(0.5, tick) end
	end
	if self._persistence == state then state.Job = self:_later(0.5, tick) end
	return ok, message
end

local function configName(name)
	assert(type(name) == "string", "Enter a config name")
	name = name:match("^%s*(.-)%s*$")
	local length = utf8.len(name)
	assert(length and length > 0 and length <= 32 and #name <= 128 and not name:find("[%z\1-\31\127]"), "Use 1–32 characters without control characters")
	return name
end

function Window:_configBank()
	local bank = self._configBanks[self.ConfigScope]
	if not bank then bank = {Profiles = self._profiles}; self._configBanks[self.ConfigScope] = bank end
	bank.Profiles = self._profiles
	return bank
end

function Window:_validateConfigBanks(data)
	local banks
	if data.Configurations == nil then
		banks = {[self.ConfigScope] = {Profiles = deepCopy(data.Profiles)}}
	else
		local configs = data.Configurations
		assert(type(configs) == "table" and configs.Version == 1 and type(configs.Banks) == "table", "Unsupported config storage")
		banks = deepCopy(configs.Banks)
	end
	local count = 0
	for scope, bank in pairs(banks) do
		count += 1
		assert(type(scope) == "string" and #scope > 0 and #scope <= 64 and type(bank) == "table" and type(bank.Profiles) == "table", "Invalid config scope")
		local entries = 0
		assert(bank.Current==nil or (type(bank.Current)=="table" and bank.Current.Version==1 and type(bank.Current.Values)=="table"),"Invalid game settings")
		for name, raw in pairs(bank.Profiles) do
			assert(type(name)=="string" and #name<=128 and utf8.len(name) and name:match("%S") and not name:find("[%z\1-\31\127]"),"Invalid saved config name"); entries += 1
			assert(type(raw) == "string" and #raw <= 50000, "Invalid saved config")
			local profile = HttpService:JSONDecode(raw)
			assert(type(profile) == "table" and profile.Version == 1 and type(profile.Values) == "table", "Invalid saved config")
		end
		assert(entries <= 20, "A game can store up to 20 configs")
		for _, field in ipairs({"Active", "AutoLoad"}) do
			assert(bank[field] == nil or bank[field] == false or (type(bank[field]) == "string" and bank.Profiles[bank[field]] ~= nil), "Invalid config selection")
			if bank[field] == false then bank[field] = nil end
		end
	end
	assert(count <= 32, "Settings can contain up to 32 game scopes")
	return banks
end

function Window:_configsChanged()
	for callback in pairs(self._configListeners) do self:_callback(callback) end
end

function Window:OnConfigsChanged(callback)
	assert(type(callback) == "function" and not self.Destroyed, "Invalid config listener")
	self._configListeners[callback] = true
	local listeners = self._configListeners
	return {Disconnect = function() listeners[callback] = nil end}
end

function Window:ListConfigs()
	local names = {}
	for name in pairs(self._profiles) do table.insert(names, name) end
	table.sort(names, function(a,b) local x,y=string.lower(a),string.lower(b);return x==y and a<b or x<y end)
	return names
end

function Window:_resolveConfig(name)
	if type(name) == "string" and self._profiles[name] then return name end
	return configName(name)
end

function Window:_putConfig(name, raw, replacing, activate)
	assert(type(raw) == "string" and #raw <= 50000, "Config exceeds 50 KB")
	for existing in pairs(self._profiles) do assert(existing == replacing or string.lower(existing) ~= string.lower(name), "A config with that name already exists") end
	local candidate = deepCopy(self._profiles)
	if replacing then candidate[replacing] = nil end
	candidate[name] = raw
	local count = 0; for _ in pairs(candidate) do count += 1 end
	assert(count <= 20, "A game can store up to 20 configs")
	local snapshot = self:_settingsSnapshot()
	local bank = snapshot.Configurations.Banks[self.ConfigScope]
	local active = bank.Active
	if activate ~= false or (replacing and bank.Active == replacing) then active = name end
	local auto = replacing and bank.AutoLoad == replacing and name or bank.AutoLoad
	bank.Profiles, bank.Active, bank.AutoLoad = candidate, active, auto
	snapshot.Profiles = candidate
	local scopes=0;for _ in pairs(snapshot.Configurations.Banks)do scopes+=1 end
	assert(scopes<=32,"Settings can contain up to 32 game scopes")
	assert(#HttpService:JSONEncode(snapshot) <= 200000, "Settings storage is full; remove an unused config first")
	if replacing and replacing ~= name then self._profiles[replacing] = nil end
	self._profiles[name] = raw
	self:_configBank().Active, self:_configBank().AutoLoad = active, auto
	self:_configsChanged()
	return name
end

function Window:CreateConfig(name)
	local ok,result=pcall(function() name=configName(name);return self:_putConfig(name,self:ExportProfile()) end)
	return ok, result
end

function Window:SaveConfig(name)
	local ok,result=pcall(function()
		name=self:_resolveConfig(name);assert(self._profiles[name],"Config not found")
		return self:_putConfig(name,self:ExportProfile(),name)
	end)
	return ok,result
end

function Window:LoadConfig(name)
	local ok,result=pcall(function()
		name=self:_resolveConfig(name);assert(self._profiles[name],"Config not found")
		local loaded,message=self:ImportProfile(self._profiles[name]);assert(loaded,message)
		self:_configBank().Active=name;self:_configsChanged();return name
	end)
	return ok,result
end

function Window:RenameConfig(name, replacement)
	local ok,result=pcall(function()
		name=self:_resolveConfig(name);replacement=configName(replacement);assert(self._profiles[name],"Config not found")
		self:_putConfig(replacement,self._profiles[name],name,false)
		return replacement
	end)
	return ok,result
end

function Window:DeleteConfig(name)
	local ok,result=pcall(function()
		name=self:_resolveConfig(name);assert(self._profiles[name],"Config not found")
		self._profiles[name]=nil;local bank=self:_configBank()
		if bank.Active==name then bank.Active=nil end
		if bank.AutoLoad==name then bank.AutoLoad=nil end
		self:_configsChanged();return name
	end)
	return ok,result
end

function Window:SetAutoLoadConfig(name)
	local ok,result=pcall(function()
		if name~=nil then name=self:_resolveConfig(name);assert(self._profiles[name],"Config not found") end
		self:_configBank().AutoLoad=name;self:_configsChanged();return name
	end)
	return ok,result
end

function Window:GetConfigStatus()
	local bank=self:_configBank()
	local dirty=false
	if bank.Active and self._profiles[bank.Active] then
		local function comparable(raw)
			local profile=HttpService:JSONDecode(raw)
			for id in pairs(profile.Values) do if self._ids[id] and not self._ids[id].Persist then profile.Values[id]=nil end end
			if profile.Layout then
				profile.Layout.ActiveTab=nil
				if profile.Layout.Window then profile.Layout.Window.Visible=nil;profile.Layout.Window.Minimized=nil end
			end
			return profile
		end
		local ok,same=pcall(function()return equalSettings(comparable(self:ExportProfile()),comparable(self._profiles[bank.Active]))end)
		dirty=not ok or not same
	end
	return {Scope=self.ConfigScope,Active=bank.Active,AutoLoad=bank.AutoLoad,Dirty=dirty,Count=#self:ListConfigs()}
end

function Window:ExportConfig(name)
	local ok,result=pcall(function()
		name=self:_resolveConfig(name);assert(self._profiles[name],"Config not found")
		return HttpService:JSONEncode({Kind="PearlUIConfig",Version=1,Name=name,Scope=self.ConfigScope,Profile=HttpService:JSONDecode(self._profiles[name])})
	end)
	return ok and result or nil, not ok and result or nil
end

function Window:_decodeConfig(json)
	assert(type(json)=="string" and #json<=100000,"Paste a config smaller than 100 KB")
	local data=HttpService:JSONDecode(json)
	assert(type(data)=="table" and data.Version==1,"Unsupported config version")
	local profile=data
	if data.Kind~=nil then assert(data.Kind=="PearlUIConfig" and type(data.Profile)=="table","Invalid config document");profile=data.Profile end
	self:_prepareProfile(profile)
	local raw=HttpService:JSONEncode(profile);assert(#raw<=50000,"Config exceeds 50 KB")
	return raw
end

function Window:ValidateConfig(json)
	local ok,result=pcall(function()return self:_decodeConfig(json)end)
	return ok,not ok and tostring(result) or nil
end

function Window:ImportConfig(name,json,overwrite)
	local ok,result=pcall(function()
		name=configName(name);local raw=self:_decodeConfig(json)
		local existing=self._profiles[name]
		assert(not existing or overwrite==true,"A config with that name already exists")
		return self:_putConfig(name,raw,existing and name or nil,false)
	end)
	return ok,result
end

function Window:SaveProfile(name)
	assert(type(name) == "string" and #name <= 64 and name:match("%S"), "Profile name must contain 1 to 64 bytes")
	local raw=self:ExportProfile()
	self:_putConfig(name,raw,self._profiles[name] and name or nil,false)
	return raw
end

function Window:LoadProfile(name)
	if not self._profiles[name] then return false, "Profile not found" end
	return self:ImportProfile(self._profiles[name])
end

function Window:Destroy()
	if self.Destroyed or self._destroying then return end
	self._destroying = true
	if self._persistence and self._persistence.AutoSave and not self._persistence.Busy then self:SaveSettings() end
	self:DisablePersistence(false)
	if self._confirmation then self._confirmation:Cancel() end
	self.Destroyed = true
	local animated = {}
	for object in pairs(self._tweens) do table.insert(animated, object) end
	for _, object in ipairs(animated) do self:_stop(object) end
	for thread in pairs(self._jobs) do task.cancel(thread) end
	self._jobs, self._tweens, self._visibility = {}, {}, {}
	for _, connection in ipairs(self._connections) do connection:Disconnect() end
	self._connections = {}
	self._dragging, self._slider, self._capturing, self._resizing = nil, nil, nil, nil
	self.Gui:Destroy()
	self.DockGui:Destroy()
	for _, control in ipairs(self.Controls) do control.Destroyed = true; control._ownedConnections = {} end
	self._skins, self._surfaces, self._refresh, self._configListeners = {}, {}, {}, {}
end

for _, name in ipairs({ "Toggle", "Slider", "Dropdown", "ColorPicker", "Input", "Keybind", "Button", "Label" }) do
	local builder = Section[name]
	Section[name] = function(section, options)
		local window = section.Window
		local count, connections = #section.Controls, #window._connections
		local ok, result = pcall(builder, section, options)
		if ok then return result end
		for index = #window._connections, connections + 1, -1 do window._connections[index]:Disconnect(); table.remove(window._connections, index) end
		while #section.Controls > count do
			local control = section.Controls[#section.Controls]
			control._ownedConnections = {}; control:Destroy()
		end
		window:_prune()
		error(result, 2)
	end
end

return PearlUI

end)()
--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local persistenceAdapter
local fileEnvironment = getfenv()
if type(fileEnvironment.readfile) == "function" and type(fileEnvironment.writefile) == "function" then
    local factory = (function()
--!nocheck
-- Optional local-file adapter. The core library uses only injected Load/Save functions.
return function(options)
	options = options or {}
	local fs = options.FileSystem or getfenv()
	local folder = options.Folder or "PearlUI"
	local prefix = options.Prefix or ""
	assert(folder:match("^[%w_%-]+$"), "Folder must be a simple name")
	assert(type(prefix) == "string" and #prefix <= 32 and (prefix == "" or prefix:match("^[%w_%-]+$")), "Invalid file prefix")
	for _, name in ipairs({"isfile", "readfile", "writefile", "isfolder", "makefolder"}) do assert(type(fs[name]) == "function", "File adapter requires " .. name) end
	if not fs.isfolder(folder) then fs.makefolder(folder) end
	local Http = game:GetService("HttpService")
	local function path(key)
		assert(type(key) == "string" and #key <= 64 and key:match("^[%w_%-]+$"), "Invalid local storage key")
		return folder .. "/" .. prefix .. key .. ".json"
	end
	local function valid(raw)
		local ok, data = pcall(Http.JSONDecode, Http, raw)
		return ok and type(data) == "table" and data.Version == 1 and type(data.Current) == "table" and type(data.Profiles) == "table"
	end
	return {
		Load = function(key)
			local file, found = path(key), false
			for _, candidate in ipairs({file, file .. ".tmp", file .. ".bak"}) do
				if fs.isfile(candidate) then
					found = true
					local ok, raw = pcall(fs.readfile, candidate)
					if ok and valid(raw) then return raw end
				end
			end
			assert(not found, "Saved settings could not be read; existing files were preserved")
			return nil
		end,
		Save = function(key, raw)
			assert(valid(raw), "Refusing an invalid settings document")
			local file = path(key)
			fs.writefile(file .. ".tmp", raw)
			assert(fs.readfile(file .. ".tmp") == raw, "Temporary settings write failed")
			if fs.isfile(file) then
				local previous = fs.readfile(file)
				if valid(previous) then fs.writefile(file .. ".bak", previous) end
			end
			fs.writefile(file, raw)
			assert(fs.readfile(file) == raw, "Settings write verification failed")
			return true
		end,
	}
end

    end)()
    local ok, adapter = pcall(factory, { FileSystem = fileEnvironment, Folder = "PearlUI", Prefix = "u" .. tostring(game:GetService("Players").LocalPlayer.UserId) .. "_" })
    if ok then persistenceAdapter = adapter end
end


local window = PearlUI.new({ Title = "Pearl UI", Name = "PearlUIDemo", Theme = "Light", Columns = 2, ConfigScope = "game_" .. tostring(game.GameId) })
local general = window:Tab({ Name = "General", Icon = "general", Description = "A calmer space. Made for the way you play." })
local appearance = window:Tab({ Name = "Appearance", Icon = "appearance", Description = "Your palette, your atmosphere." })
local controls = window:Tab({ Name = "Controls", Icon = "controls", Description = "Small details. A more comfortable workspace." })
local profiles = window:Tab({ Name = "Profiles", Icon = "profiles", Description = "Keep a setup you can come back to." })
local defaultLayout

local interface = general:Section({ Title = "Interface", Column = "Left" })
interface:Toggle({ Id = "showNotifications", Label = "Show notifications", Default = true, Callback = function(value) window.NotificationsEnabled = value end })
interface:Dropdown({ Id = "theme", ResetGroup = "Appearance", Label = "Theme", Options = PearlUI.GetThemes(), Default = "Light", Callback = function(value) window:SetTheme(value) end })

local behavior = general:Section({ Title = "Controls", Column = "Right" })
behavior:Keybind({ Id = "menuKey", Label = "Toggle menu", Default = "RightShift", Callback = function(value) window:SetToggleKey(value) end })
behavior:Toggle({ Id = "reduceMotion", Label = "Reduce motion", Default = false, Callback = function(value) window.ReduceMotion = value end })
behavior:Slider({ Id = "animation", Label = "Animation speed", Min = 0.05, Max = 0.5, Step = 0.05, Default = 0.2, Suffix = " s", Callback = function(value) window.AnimationSpeed = value end })

local favorites = interface
local favoriteSummary
favorites:Dropdown({
	Id = "favorites", Label = "Favorite tools", Multi = true, Searchable = true,
	Options = { "Interface", "Appearance", "Controls", "Profiles", "Notifications", "Color picker", "Floating panels" },
	Default = { "Appearance", "Profiles" },
	Callback = function(values) if favoriteSummary then favoriteSummary:Set(#values == 0 and "None" or table.concat(values, ", ")) end end,
})
favoriteSummary = favorites:Label({ Label = "Selected", Value = "Appearance, Profiles" })

local accentColors = {
	Blue = Color3.fromRGB(0, 113, 246), Violet = Color3.fromRGB(151, 101, 238),
	Rose = Color3.fromRGB(231, 105, 163), Mint = Color3.fromRGB(44, 164, 139),
}
local palette = appearance:Section({ Title = "Personalization", Column = "Left" })
local accentPicker
palette:Dropdown({ Id = "accent", ResetGroup = "Appearance", Label = "Accent preset", Options = { "Blue", "Violet", "Rose", "Mint" }, Default = "Blue", Callback = function(value) if accentPicker then accentPicker:Set(accentColors[value]) else window:SetAccent(accentColors[value]) end end })
accentPicker = palette:ColorPicker({ Id = "accentColor", ResetGroup = "Appearance", Label = "Custom accent", Default = accentColors.Blue, Alpha = 1, Callback = function(color) window:SetAccent(color) end })
window._accentControl = accentPicker
palette:Button({ Label = "Use this theme's accent", Text = "Use theme color", Callback = function() window:ResetAccent() end })
palette:Slider({ Id = "opacity", ResetGroup = "Appearance", Label = "Panel opacity", Min = 75, Max = 100, Default = 97, Suffix = "%", Callback = function(value) window:SetOpacity(value / 100) end })
palette:Button({ Label = "Try a notification", Text = "Preview", Callback = function() window:Notify({ Title = "Hello from Pearl", Description = "A little less noise. A little more you.", Preview = true }) end })
palette:Button({ Label = "Reset appearance", Text = "Reset…", Callback = function() window:RequestReset("Appearance") end })
local panels = appearance:Section({ Title = "Floating panels", Column = "Right" })
panels:Label({ Label = "Pull a section out", Value = "Use the detach icon" })
panels:Button({ Label = "Detach personalization", Text = "Detach", Callback = function() palette:Detach() end })
panels:Button({ Label = "Bring all panels home", Text = "Dock all", Callback = function() for _, section in ipairs(window.Sections) do section:Dock() end end })

local interaction = controls:Section({ Title = "Workspace", Column = "Left" })
interaction:Button({ Label = "Compact mode", Text = "Minimize", Callback = function() window:SetMinimized(true) end })
interaction:Button({ Label = "Fill the screen", Text = "Maximize", Callback = function() window:SetMaximized(not window.Maximized) end })
interaction:Button({ Label = "Reset window size", Text = "Reset", Callback = function() window:SetSize(900, 610) end })
interaction:Button({ Label = "Reset control values", Text = "Reset…", Callback = function() window:RequestReset("Controls") end })
local components = controls:Section({ Title = "Component playground", Column = "Right" })
local example
local function createExample()
	return components:Button({ Label = "Example action", Text = "Try it", Primary = true, Callback = function() window:Notify({ Title = "Action completed", Description = "This control is enabled and ready." }) end })
end
example = createExample()
local disableExample = components:Toggle({ Id = "disableExample", Label = "Disable example", Default = false, Callback = function(value) if not example.Destroyed then example:SetDisabled(value, "Turn off Disable example to use this action.") end end })
local showExample = components:Toggle({ Id = "showExample", Label = "Show example", Default = true, Callback = function(value) if not example.Destroyed then example:SetVisible(value) end end })
local exampleLabel = components:Input({ Id = "exampleLabel", Label = "Action label", Default = "Example action", MaxLength = 32, Callback = function(value) if not example.Destroyed then example:SetLabel(value) end end })
components:Button({ Label = "Remove example", Text = "Remove", Callback = function() example:Destroy() end })
components:Button({ Label = "Recreate example", Text = "Recreate", Callback = function()
	if example.Destroyed then example = createExample(); example:SetLabel(exampleLabel:Get()); example:SetDisabled(disableExample:Get(), "Turn off Disable example to use this action."); example:SetVisible(showExample:Get()) end
end })
local about = interaction
about:Label({ Label = "Version", Value = PearlUI.Version })
about:Label({ Label = "Dependencies", Value = "None" })
about:Label({ Label = "Made for", Value = "Roblox / Luau" })

local profile = profiles:Section({ Title = "Configurations", Id = "Profiles.Your profiles", Column = "Left" })
local transfer = profiles:Section({ Title = "Transfer & storage", Id = "Profiles.Window layout", Column = "Right" })
local name = profile:Input({ Id = "profileName", Persist = false, Label = "Config name", Default = "", Placeholder = "Name your config", MaxLength = 32 })
local selected, automatic, activeLabel, refresh
local refreshing = false
selected = profile:Dropdown({ Id = "selectedConfig", Persist = false, Label = "Saved configs", Options = {"(no configs)"}, Callback = function(value)
	if refreshing then return end
	name:Set(value, true)
	if automatic then automatic:Set(window:GetConfigStatus().AutoLoad == value, true) end
end })
local function feedback(ok, message, title)
	window:Notify({Title = ok and title or "Could not update config", Description = ok and "Your config list has been updated." or tostring(message), Preview = true})
end
profile:Button({ Label = "Create from current setup", Text = "Create", Primary = true, Callback = function()
	local ok, result = window:CreateConfig(name:Get()); if ok then refresh(result) end; feedback(ok, result, "Config created")
end })
profile:Button({ Label = "Update selected config", Text = "Save changes", Callback = function()
	local ok, result = window:SaveConfig(selected:Get()); if ok then refresh(result) end; feedback(ok, result, "Config updated")
end })
profile:Button({ Label = "Apply selected config", Text = "Load", Callback = function()
	local target = selected:Get()
	local function apply() local ok, result = window:LoadConfig(target); if ok then refresh(target) end; feedback(ok, result, "Config loaded") end
	if window:GetConfigStatus().Dirty then window:Confirm({Title = "Load config?", Description = "Unsaved edits to the active config will be replaced.", ConfirmText = "Load", OnConfirm = apply}) else apply() end
end })
profile:Button({ Label = "Rename selected config", Text = "Rename", Callback = function()
	local ok, result = window:RenameConfig(selected:Get(), name:Get()); if ok then refresh(result) end; feedback(ok, result, "Config renamed")
end })
profile:Button({ Label = "Remove selected config", Text = "Delete…", Callback = function()
	local target = selected:Get()
	if not window._profiles[target] then feedback(false, "Select a saved config first."); return end
	window:Confirm({Title = "Delete config?", Description = "Delete \"" .. target .. "\"? Your current settings will stay as they are.", ConfirmText = "Delete", OnConfirm = function()
		local ok, result = window:DeleteConfig(target); refresh(); feedback(ok, result, "Config deleted")
	end})
end })
automatic = profile:Toggle({ Id = "autoLoadConfig", Persist = false, Label = "Auto-load selected", Default = false, Callback = function(value)
	local ok, result = window:SetAutoLoadConfig(value and selected:Get() or nil); refresh(); if not ok then feedback(ok, result) end
end })
activeLabel = profile:Label({Label = "Active config", Value = "None"})
profile:Label({Label = "Config scope", Value = "This game"})
local function updateStatus()
	local status = window:GetConfigStatus()
	activeLabel:Set(status.Active and (status.Active .. (status.Dirty and " · edited" or " · saved")) or "None loaded")
end
refresh = function(preferred)
	if refreshing then return end
	refreshing = true
	local names = window:ListConfigs()
	local status = window:GetConfigStatus()
	local choice = preferred or (window._profiles[selected:Get()] and selected:Get()) or status.Active or names[1] or "(no configs)"
	selected:SetOptions(#names > 0 and names or {"(no configs)"}, choice, true)
	selected:SetDisabled(#names == 0, #names == 0 and "Create or import a config first." or nil)
	automatic:SetDisabled(#names == 0)
	automatic:Set(status.AutoLoad == choice, true)
	if preferred then name:Set(preferred, true) end
	updateStatus()
	refreshing = false
end
window:OnConfigsChanged(function() refresh(window:GetPersistenceStatus() == "Loading" and window:GetConfigStatus().Active or nil) end)
local function statusTick()
	updateStatus()
	window:_later(0.75, statusTick)
end
window:_later(0.75, statusTick)
transfer:Button({ Label = "Share selected config", Text = "Export JSON", Callback = function()
	local raw, message = window:ExportConfig(selected:Get())
	if not raw then feedback(false, message); return end
	window:Confirm({Title = "Export config", Description = "Select and copy the text. Paste it into Import on another setup.", Text = raw, ReadOnly = true, ConfirmText = "Done"})
end })
transfer:Button({ Label = "Paste a shared config", Text = "Import JSON…", Callback = function()
	local target = name:Get():match("^%s*(.-)%s*$")
	if target == "" then feedback(false,"Enter a config name first.");return end
	window:Confirm({Title = "Import config", Description = "Paste JSON below. It will be saved under the config name you entered.", Text = "", ConfirmText = "Import", Validate = function(raw) return window:ValidateConfig(raw) end, OnConfirm = function(raw)
		local function apply(overwrite)
			local ok, result = window:ImportConfig(target, raw, overwrite); if ok then refresh(result) end; feedback(ok, result, "Config imported")
		end
		if window._profiles[target] then window:Confirm({Title = "Replace existing config?", Description = "The saved values in \"" .. target .. "\" will be replaced. Current settings will not be applied automatically.", ConfirmText = "Replace", OnConfirm = function() apply(true) end}) else apply(false) end
	end})
end })
local storageStatus = transfer:Label({ Label = "Auto-save", Value = persistenceAdapter and "Connecting…" or "Not connected" })
transfer:Button({ Label = "Write latest settings", Text = "Save now", Callback = function()
	local ok, message = window:SaveSettings()
	window:Notify({ Title = ok and "Settings saved" or "Could not save", Description = ok and "Your settings are ready for next time." or message, Preview = true })
end })
transfer:Button({ Label = "Read saved settings", Text = "Reload", Callback = function()
	local ok, loaded = window:LoadSettings(); refresh()
	window:Notify({ Title = ok and "Settings loaded" or "Could not load", Description = ok and (loaded and "Your saved setup has been restored." or "No saved setup yet.") or loaded, Preview = true })
end })
transfer:Button({ Label = "Reset window layout", Text = "Reset layout…", Callback = function() window:RequestReset("Layout") end })
transfer:Button({ Label = "Reset all preferences", Text = "Reset all…", Callback = function() window:RequestReset("All") end })

local showcaseFactory = (function()
--!nocheck
return function(PearlUI, window)
	local Http = game:GetService("HttpService")
	local bench = { Coverage = {}, Actions = {}, Controls = {}, Factories = {}, Results = {}, CallbackCount = 0, ConfigEvents = 0 }
	local components = window:Tab({Name="Components",Icon="controls",Description="Every control. Live values, callbacks and editable states."})
	local windows = window:Tab({Name="Window lab",Icon="general",Description="Try window geometry, the dock, panels and navigation."})
	local tools = window:Tab({Name="API tools",Icon="profiles",Description="Inspect data and test persistence in an isolated sample window."})
	local showcase = components:Section({Title="All components",Column="Left"})
	local controlActions = components:Section({Title="Control inspector",Column="Right"})
	local geometry = windows:Section({Title="Window & dock",Column="Left"})
	local panels = windows:Section({Title="Panels & navigation",Column="Right"})
	local sandboxActions = tools:Section({Title="Sample window",Column="Left"})
	local dataActions = tools:Section({Title="Data & feedback",Column="Right"})
	local lastResult, callbackLabel, valueLabel
	local function describe(value)
		if value == nil then return "nil" end
		if typeof(value)=="Color3" then return "#"..value:ToHex():upper() end
		if type(value)=="table" then local ok,json=pcall(Http.JSONEncode,Http,value);return ok and json or tostring(value) end
		return tostring(value)
	end
	local function report(name,value)
		local text=name.." → "..describe(value)
		table.insert(bench.Results,text);if #bench.Results>30 then table.remove(bench.Results,1)end
		if lastResult then lastResult:Set(text)end
		return value
	end
	local function register(key,location,fn)
		bench.Coverage[key]=location
		if fn then bench.Actions[key]=fn end
	end
	function bench.Run(key,...)
		assert(bench.Actions[key],"No runnable showcase action: "..key)
		local ok,result=pcall(bench.Actions[key],...)
		if ok then report(key,result)else report(key,"Error: "..tostring(result))end
		return ok,result
	end
	local function run(name,fn)
		local ok,result=pcall(fn);if ok then report(name,result)else report(name,"Error: "..tostring(result))end;return ok,result
	end
	local function action(section,label,text,key,fn)
		register(key,section.Title.." / "..label,fn)
		return section:Button({Label=label,Text=text,Callback=function()bench.Run(key)end})
	end
	local function menu(section,label,entries)
		local names={};for _,entry in ipairs(entries)do table.insert(names,entry[1]);register(entry[2],section.Title.." / "..label.." / "..entry[1],entry[3])end
		local selected=section:Dropdown({Id="lab.menu."..label,Persist=false,Label=label,Options=names})
		section:Button({Label="Run selected action",Text="Run",Primary=true,Callback=function()
			for _,entry in ipairs(entries)do if entry[1]==selected:Get()then bench.Run(entry[2]);break end end
		end})
		return selected
	end
	local function changed(name,value,alpha)
		bench.CallbackCount+=1
		if callbackLabel then callbackLabel:Set(bench.CallbackCount)end
		if valueLabel then valueLabel:Set(name..": "..describe(value)..(alpha and " / "..tostring(alpha) or ""))end
	end
	local definitions={
		{"Toggle","Toggle",{Default=true}},
		{"Slider","Slider",{Min=0,Max=100,Step=5,Default=35,Suffix="%"}},
		{"Single dropdown","Dropdown",{Options={"Alpha","Beta","Gamma"},Default="Alpha"}},
		{"Multi dropdown","Dropdown",{Options={"Alpha","Beta","Gamma","Delta"},Multi=true,Default={"Alpha","Gamma"}}},
		{"No-search dropdown","Dropdown",{Options={"One","Two","Three"},Searchable=false}},
		{"Color picker","ColorPicker",{Default="#55A879",Alpha=0.7}},
		{"Text input","Input",{Default="Hello, Pearl",MaxLength=64,Placeholder="Type here"}},
		{"Keybind","Keybind",{Default="F6",OnPressed=function(key)report("Key pressed",key.Name)end}},
		{"Button","Button",{Text="Press me",Primary=true}},
		{"Label","Label",{Value="Live output"}},
	}
	local names={}
	for _,definition in ipairs(definitions)do
		local name,kind,settings=definition[1],definition[2],definition[3]
		table.insert(names,name)
		bench.Factories[name]=function()
			local options=table.clone(settings);options.Label=name;options.Id="lab.control."..name;options.Persist=false
			options.Callback=function(value,alpha)changed(name,value,alpha)end
			local control=showcase[kind](showcase,options);bench.Controls[name]=control;return control
		end
		bench.Factories[name]()
		register("Section."..kind,"Components / All components / "..name)
	end
	local target=controlActions:Dropdown({Id="lab.target",Persist=false,Label="Target control",Options=names})
	local function current()
		local control=bench.Controls[target:Get()];assert(control and not control.Destroyed,"Recreate the selected control first.");return control
	end
	local function setExample(silent)
		local c=current();local values={Slider=75,Input="Updated in the inspector",Keybind="F7",ColorPicker="#C777AA",Label="Updated label"}
		local value=values[c.Type]
		if c.Type=="Toggle" then value=not c:Get()
		elseif c.Type=="Dropdown" then value=c.Multi and {c.Options[#c.Options]} or c.Options[#c.Options]
		elseif c.Type=="Button" then return "Buttons use Activated; select a value control." end
		c:Set(value,silent);return c:Get()
	end
	menu(controlActions,"Control API",{
		{"Read value","Control.Get",function()return current():Get()end},
		{"Serialize value","Control.Serialize",function()return current():Serialize()end},
		{"Set sample value","Control.Set",function()return setExample(false)end},
		{"Set silently","Control.SetSilent",function()local n=bench.CallbackCount;setExample(true);return "Callbacks: "..n.." → "..bench.CallbackCount end},
		{"Attach callback","Control.OnChanged",function()local c=current();c:OnChanged(function(v,a)changed(c.Label,v,a)end);return "Callback attached"end},
		{"Remove callback","Control.RemoveCallback",function()current():OnChanged(nil);return "Callback removed"end},
		{"Can interact?","Control.CanInteract",function()return current():CanInteract()end},
		{"Disable / enable","Control.SetDisabled",function()local c=current();c:SetDisabled(not c.Disabled,"Enable this control from the inspector.");return c.Disabled and "Disabled" or "Enabled"end},
		{"Hide / show","Control.SetVisible",function()local c=current();c:SetVisible(not c.Visible);return c.Visible and "Visible" or "Hidden"end},
		{"Change label","Control.SetLabel",function()local c=current();c:SetLabel(c.Label==target:Get() and "Renamed example" or target:Get());return c.Label end},
		{"Close editor","Control.Close",function()current():Close();return "Editor closed"end},
		{"Destroy selected","Control.Destroy",function()current():Destroy();return "Destroyed; choose Recreate next."end},
		{"Recreate selected","Control.Recreate",function()local c=bench.Controls[target:Get()];if c and not c.Destroyed then c:Destroy()end;bench.Factories[target:Get()]();return "Recreated with its original ID"end},
	})
	callbackLabel=controlActions:Label({Label="Callback count",Value=0})
	valueLabel=controlActions:Label({Label="Last value",Value="Interact with a control"})
	lastResult=controlActions:Label({Label="Action result",Value="Choose an action and press Run"})
	local function dropdown()
		local c=current();assert(c.Type=="Dropdown","Select a dropdown first.");return c
	end
	local function openEditor(c)
		assert(c:CanInteract(),"Show and enable the selected control first.")
		window:SelectTab(c.Section.Tab)
		if c.Section.Detached then c.Section:Reveal()end
		local scroll=c.Section.Detached and c.Section.FloatScroll or c.Section.Tab.Page
		local y=scroll.CanvasPosition.Y+(c.Row.AbsolutePosition.Y-scroll.AbsolutePosition.Y)/window._actualScale-12
		scroll.CanvasPosition=Vector2.new(0,math.max(0,y))
		window:_later(.03,function()if not c.Destroyed then c:Open()end end)
		return "Editor opening at the selected control"
	end
	menu(controlActions,"Dropdown API",{
		{"Open dropdown","Dropdown.Open",function()return openEditor(dropdown())end},
		{"Replace options","Dropdown.SetOptions",function()local c=dropdown();c:SetOptions({"New one","New two","New three"});return c:Get()end},
	})
	local function picker()
		local c=bench.Controls["Color picker"];assert(c and not c.Destroyed,"Recreate the color picker first.");return c
	end
	menu(controlActions,"Color API",{
		{"Open color editor","ColorPicker.Open",function()return openEditor(picker())end},
		{"Read color + alpha","ColorPicker.Get",function()local c,a=picker():Get();return describe(c).." / "..a end},
		{"Set alpha to 35%","ColorPicker.SetAlpha",function()picker():SetAlpha(.35);return picker():Serialize()end},
		{"Set HSV green","ColorPicker.SetHSV",function()picker():SetHSV(.38,.55,.65);return picker():Serialize()end},
	})
	geometry:Slider({Id="lab.scale",Persist=false,Label="Interface scale",Min=.65,Max=1.3,Step=.05,Default=window.Scale,Callback=function(v)window:SetScale(v);report("Scale",v)end})
	register("Window.SetScale","Window lab / Interface scale")
	geometry:Slider({Id="lab.opacity",Persist=false,Label="Panel opacity",Min=75,Max=100,Default=window.Opacity*100,Suffix="%",Callback=function(v)window:SetOpacity(v/100);report("Opacity",v)end})
	register("Window.SetOpacity","Window lab / Panel opacity")
	geometry:Dropdown({Id="lab.columns",Persist=false,Label="Section columns",Options={"Two","One"},Callback=function(v)window:SetColumns(v=="Two" and 2 or 1);report("Columns",window.Columns)end})
	register("Window.SetColumns","Window lab / Section columns")
	geometry:Dropdown({Id="lab.size",Persist=false,Label="Window size",Options={"Default 900 × 610","Compact 680 × 420","Wide 1200 × 760","Custom / drag the corner"},Callback=function(v)
		if v:find("Compact")then window:SetSize(680,420)elseif v:find("Wide")then window:SetSize(1200,760)elseif v:find("Default")then window:SetSize(900,610)end
		report("Size",window.WindowSize)
	end})
	register("Window.SetSize","Window lab / Window size")
	menu(geometry,"Window actions",{
		{"Hide for two seconds","Window.SetVisible",function()window:SetVisible(false);window:_later(2,function()window:SetVisible(true)end);return "Returns in two seconds"end},
		{"Minimize to dock","Window.SetMinimized",function()window:SetMinimized(true);return "Use Open Pearl UI on the dock"end},
		{"Maximize / restore","Window.SetMaximized",function()window:SetMaximized(not window.Maximized);return window.Maximized end},
		{"Stow dock left","Window.StowDock",function()window:SetMinimized(true);window:StowDock("Left");return "Use the handle on the left edge"end},
		{"Stow dock right","Window.StowDockRight",function()window:SetMinimized(true);window:StowDock("Right");return "Use the handle on the right edge"end},
		{"Reveal dock","Window.RevealDock",function()window:SetMinimized(true);window:RevealDock();return "Dock revealed"end},
	})
	local sectionNames,sections={},{}
	for _,s in ipairs(window.Sections)do local name=s.Tab.Name.." / "..s.Title;table.insert(sectionNames,name);sections[name]=s end
	local selectedPanel=panels:Dropdown({Id="lab.panel",Persist=false,Label="Target panel",Options=sectionNames})
	menu(panels,"Panel actions",{
		{"Detach selected","Section.Detach",function()sections[selectedPanel:Get()]:Detach();return selectedPanel:Get()end},
		{"Reveal selected","Section.Reveal",function()sections[selectedPanel:Get()]:Reveal();return selectedPanel:Get()end},
		{"Dock selected","Section.Dock",function()sections[selectedPanel:Get()]:Dock();return selectedPanel:Get()end},
	})
	panels:Button({Label="Bring every panel home",Text="Dock all",Callback=function()for _,s in ipairs(window.Sections)do s:Dock()end;report("Panels","All docked")end})
	local tabNames={};for _,tab in ipairs(window.Tabs)do table.insert(tabNames,tab.Name)end
	local selectedTab=panels:Dropdown({Id="lab.tab",Persist=false,Label="Jump to tab",Options=tabNames})
	action(panels,"Open selected tab","Open","Window.SelectTab",function()window.Search.Text="";window:SelectTab(selectedTab:Get());return selectedTab:Get()end)
	action(panels,"Refresh user card","Refresh","Window.RefreshUserProfile",function()window:RefreshUserProfile();return window.UserDisplayName.Text end)
	panels:Keybind({Id="lab.menuKey",Persist=false,Label="Menu toggle key",Default=window.ToggleKey.Name,Callback=function(v)window:SetToggleKey(v);report("Menu key",v)end})
	register("Window.SetToggleKey","Window lab / Menu toggle key")
	local sample,sampleFlag,memory,listener
	local function createSample()
		if sample and not sample.Destroyed then return sample end
		if listener then listener:Disconnect();listener=nil end
		sample=PearlUI.new({Name="PearlUISample",Title="Pearl sample",Theme=window.Theme,ReduceMotion=window.ReduceMotion,DisplayOrder=window.Gui.DisplayOrder+2,ConfigScope="showcase"})
		sample:SetSize(680,420)
		local tab=sample:Tab({Name="Sample",Description="An isolated window for lifecycle and data tests."})
		local section=tab:Section("Sample controls")
		sampleFlag=section:Toggle({Id="sample.flag",Label="Sample value",Default=false,Callback=function(v)report("Sample value",v)end})
		section:Button({Label="Close this sample",Text="Destroy sample",Callback=function()sample:Destroy();report("Sample","Destroyed")end})
		sample:CaptureDefaults();bench.Sample=sample;return sample
	end
	local function sampleWindow()return createSample()end
	action(sandboxActions,"Open an isolated window","Open sample","PearlUI.new",function()createSample();return "Sample window opened"end)
	register("Window.Tab","API tools / Open an isolated window")
	register("Tab.Section","API tools / Open an isolated window")
	menu(sandboxActions,"Lifecycle & reset",{
		{"Destroy sample window","Window.Destroy",function()if sample then sample:Destroy()end;return "Main demo is still available"end},
		{"Capture sample defaults","Window.CaptureDefaults",function()sampleWindow():CaptureDefaults();return "Sample defaults captured"end},
		{"Toggle sample value","Sample.Toggle",function()sampleWindow();sampleFlag:Set(not sampleFlag:Get());return sampleFlag:Get()end},
		{"Reset sample controls now","Window.Reset",function()local w=sampleWindow();local ok,e=w:Reset("Controls");assert(ok,e);return sampleFlag:Get()end},
		{"Request sample reset","Window.RequestReset",function()sampleWindow():RequestReset("All");return "Confirm or cancel in the sample"end},
	})
	menu(sandboxActions,"Storage adapter",{
		{"Connect memory storage","Window.ConfigurePersistence",function()local w=sampleWindow();memory=memory or {};local adapter={Load=function(k)return memory[k]end,Save=function(k,v)memory[k]=v;return true end};local ok,e=w:ConfigurePersistence({Adapter=adapter,Key="sample",AutoSave=false});assert(ok,e);return w:GetPersistenceStatus()end},
		{"Save sample settings","Window.SaveSettings",function()local ok,e=sampleWindow():SaveSettings();assert(ok,e);return "Sample settings saved"end},
		{"Reload sample settings","Window.LoadSettings",function()local ok,e=sampleWindow():LoadSettings();assert(ok,e);return "Sample settings restored"end},
		{"Read storage status","Window.GetPersistenceStatus",function()return sampleWindow():GetPersistenceStatus()end},
		{"Disconnect sample storage","Window.DisablePersistence",function()sampleWindow():DisablePersistence(true);return sampleWindow():GetPersistenceStatus()end},
	})
	local configName=sandboxActions:Input({Id="lab.configName",Persist=false,Label="Sample config name",Default="Sample",MaxLength=32})
	local rename=sandboxActions:Input({Id="lab.rename",Persist=false,Label="New sample name",Default="Renamed",MaxLength=32})
	local configJSON=""
	menu(sandboxActions,"Sample configs",{
		{"Create config","Window.CreateConfig",function()local ok,e=sampleWindow():CreateConfig(configName:Get());assert(ok,e);return e end},
		{"Save config changes","Window.SaveConfig",function()local ok,e=sampleWindow():SaveConfig(configName:Get());assert(ok,e);return e end},
		{"Load config","Window.LoadConfig",function()local ok,e=sampleWindow():LoadConfig(configName:Get());assert(ok,e);return e end},
		{"Rename config","Window.RenameConfig",function()local ok,e=sampleWindow():RenameConfig(configName:Get(),rename:Get());assert(ok,e);configName:Set(e,true);return e end},
		{"Delete config","Window.DeleteConfig",function()local ok,e=sampleWindow():DeleteConfig(configName:Get());assert(ok,e);return e end},
		{"Set startup config","Window.SetAutoLoadConfig",function()local ok,e=sampleWindow():SetAutoLoadConfig(configName:Get());assert(ok,e);return e end},
		{"Clear startup config","Window.ClearAutoLoadConfig",function()local ok,e=sampleWindow():SetAutoLoadConfig(nil);assert(ok,e);return "Auto-load cleared"end},
		{"List configs","Window.ListConfigs",function()return sampleWindow():ListConfigs()end},
		{"Read config status","Window.GetConfigStatus",function()return sampleWindow():GetConfigStatus()end},
		{"Export to sample buffer","Window.ExportConfig",function()local raw,e=sampleWindow():ExportConfig(configName:Get());assert(raw,e);configJSON=raw;return "JSON stored in the sample buffer"end},
		{"Validate sample buffer","Window.ValidateConfig",function()local ok,e=sampleWindow():ValidateConfig(configJSON);assert(ok,e);return "Valid config JSON"end},
		{"Import as a copy","Window.ImportConfig",function()local ok,e=sampleWindow():ImportConfig("Imported copy",configJSON,true);assert(ok,e);return e end},
		{"Save legacy profile","Window.SaveProfile",function()sampleWindow():SaveProfile("Legacy sample");return "Legacy sample saved"end},
		{"Load legacy profile","Window.LoadProfile",function()local ok,e=sampleWindow():LoadProfile("Legacy sample");assert(ok,e);return "Legacy sample loaded"end},
	})
	menu(sandboxActions,"Config observer",{
		{"Listen for config changes","Window.OnConfigsChanged",function()if listener then listener:Disconnect()end;listener=sampleWindow():OnConfigsChanged(function()bench.ConfigEvents+=1;report("Config events",bench.ConfigEvents)end);return "Observer connected"end},
		{"Disconnect observer","Window.DisconnectConfigObserver",function()if listener then listener:Disconnect();listener=nil end;return "Observer disconnected"end},
	})
	local function inspect(title,value)
		local raw=type(value)=="string" and value or describe(value)
		window:Confirm({Title=title,Description="Read-only output. Select and copy any text you need.",Text=raw,ReadOnly=true,ConfirmText="Done"})
		return "Output opened"
	end
	menu(dataActions,"Read main demo data",{
		{"Read layout table","Window.GetLayout",function()return inspect("Layout table",window:GetLayout())end},
		{"Export layout JSON","Window.ExportLayout",function()return inspect("Layout JSON",window:ExportLayout())end},
		{"Export profile JSON","Window.ExportProfile",function()return inspect("Profile JSON",window:ExportProfile())end},
		{"List available themes","PearlUI.GetThemes",function()return inspect("Available themes",PearlUI.GetThemes())end},
		{"Read recent results","Showcase.Results",function()return inspect("Recent actions",bench.Results)end},
	})
	local layoutJSON,profileJSON
	menu(dataActions,"Sample JSON roundtrip",{
		{"Capture sample layout","Sample.CaptureLayout",function()layoutJSON=sampleWindow():ExportLayout();return "Layout captured"end},
		{"Restore sample layout","Window.ImportLayout",function()assert(layoutJSON,"Capture a sample layout first.");local ok,e=sampleWindow():ImportLayout(layoutJSON);assert(ok,e);return "Layout restored"end},
		{"Capture sample profile","Sample.CaptureProfile",function()profileJSON=sampleWindow():ExportProfile();return "Profile captured"end},
		{"Restore sample profile","Window.ImportProfile",function()assert(profileJSON,"Capture a sample profile first.");local ok,e=sampleWindow():ImportProfile(profileJSON);assert(ok,e);return "Profile restored"end},
	})
	menu(dataActions,"Dialogs & notifications",{
		{"Show a notification","Window.Notify",function()window:Notify({Title="Pearl showcase",Description="This is a notification preview.",Preview=true});return "Notification shown"end},
		{"Confirm or cancel","Window.Confirm",function()window:Confirm({Title="Test confirmation",Description="Try Confirm, Cancel or Escape. This test changes no settings.",OnConfirm=function()report("Dialog","Confirmed")end,OnCancel=function()report("Dialog","Cancelled")end});return "Dialog opened"end},
		{"Open a text editor","Showcase.TextEditor",function()window:Confirm({Title="Test text editor",Description="Type something, then confirm or cancel.",Text="Hello from Pearl",OnConfirm=function(text)report("Editor",text)end});return "Editor opened"end},
	})
	local themes=dataActions:Dropdown({Id="lab.theme",Persist=false,Label="Theme preview",Options=PearlUI.GetThemes(),Default=window.Theme,Callback=function(v)window:SetTheme(v);report("Theme",v)end})
	register("Window.SetTheme","API tools / Theme preview")
	dataActions:ColorPicker({Id="lab.accent",Persist=false,Label="Accent preview",Default=window.Palette.Accent,Callback=function(v)window:SetAccent(v);report("Accent",v)end})
	register("Window.SetAccent","API tools / Accent preview")
	action(dataActions,"Follow theme accent again","Use theme color","Window.ResetAccent",function()window:ResetAccent();return window.Palette.Accent end)
	dataActions:Label({Label="Sandbox storage",Value="Memory only · no real configs"})
	dataActions:Label({Label="Keyboard testing",Value="F6/F7 · ignores typing in fields"})
	bench.Coverage["Control.SetSilent"]="Components / Set silently"
	bench.ComponentTab=components
	bench.SampleWindow=sampleWindow
	bench.Target=target
	bench.ShowcaseSection=showcase
	function bench.Sync()
		local size=window.WindowSize
		local sizeName=size==Vector2.new(900,610) and "Default 900 × 610" or size==Vector2.new(680,420) and "Compact 680 × 420" or size==Vector2.new(1200,760) and "Wide 1200 × 760" or "Custom / drag the corner"
		local values={["lab.scale"]=window.Scale,["lab.opacity"]=window.Opacity*100,["opacity"]=window.Opacity*100,["lab.columns"]=window.Columns==2 and "Two" or "One",["lab.size"]=sizeName,["lab.theme"]=window.Theme,["theme"]=window.Theme,["lab.menuKey"]=window.ToggleKey.Name,["menuKey"]=window.ToggleKey.Name}
		for id,value in pairs(values)do local c=window._ids[id];if c and not c.Destroyed and window._capturing~=c then local normalized=c.Validate and c.Validate(value) or value;if c:Get()~=normalized then c:Set(normalized,true)end end end
		local c=window._ids["lab.accent"]
		if c and not c.Destroyed and c.Value.Hex~="#"..window.Palette.Accent:ToHex():upper()then c:Set(window.Palette.Accent,true)end
		c=window._accentControl
		if c and not c.Destroyed and c.Value.Hex~="#"..window.Palette.Accent:ToHex():upper()then c:Set(window.Palette.Accent,true)end
	end
	local function syncTick()bench.Sync();window:_later(.75,syncTick)end
	window:_later(.75,syncTick)
	bench.Dispose=function()if listener then listener:Disconnect()end;if sample and not sample.Destroyed then sample:Destroy()end end
	window:_connect(window.Gui.Destroying,bench.Dispose)
	local destroy=window.Destroy
	function window:Destroy()bench.Dispose();return destroy(self)end
	return bench
end

end)()
window._testBench = showcaseFactory(PearlUI, window)


window:SelectTab(general)
defaultLayout = window:ExportLayout()
window:SaveProfile("Default")
window:CaptureDefaults()
refresh()
if persistenceAdapter then
	window:ConfigurePersistence({ Adapter = persistenceAdapter, Key = "demo", Debounce = 1.5, OnStatus = function(status)
		storageStatus:Set(status == "Error" and "Save unavailable — retry" or status)
	end })
end

if window._testBench then window._testBench.Sync() end

-- Return a handle for the standalone preview and runtime test harness.
return window
