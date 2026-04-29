script_name('Auto Accept')
script_author('allecsei')
script_version('v1.6')

require 'lib.moonloader'
local sampev = require 'lib.samp.events'

local imgui
local imguiAvailable = false
local ok, loaded = pcall(require, 'imgui')
if ok then
    imgui = loaded
    imguiAvailable = true
end

local successColor = imguiAvailable and imgui.ImVec4(0.10, 0.75, 0.10, 1.0) or nil
local dangerColor = imguiAvailable and imgui.ImVec4(0.75, 0.10, 0.10, 1.0) or nil

local currentTheme = 1
local autoAcceptEnabled = true
local autoGetjobEnabled = true
local show_ui = imguiAvailable and imgui.ImBool(false) or { v = false }
local showSettingsMenu = imguiAvailable and imgui.ImBool(false) or { v = false }
local showHotkeysMenu = imguiAvailable and imgui.ImBool(false) or { v = false }

local iniPath = getWorkingDirectory() .. '/config/AutoAccept_settings.ini'

local themes = {
    {
        name = "Ocean Blue",
        WindowBg = imgui.ImVec4(0.07, 0.07, 0.09, 0.94),
        Header = imgui.ImVec4(0.15, 0.45, 0.85, 1.0),
        HeaderHovered = imgui.ImVec4(0.20, 0.55, 0.95, 1.0),
        Button = imgui.ImVec4(0.12, 0.12, 0.15, 1.0),
        ButtonHovered = imgui.ImVec4(0.18, 0.18, 0.22, 1.0),
        ButtonActive = imgui.ImVec4(0.15, 0.45, 0.85, 1.0),
        FrameBg = imgui.ImVec4(0.12, 0.12, 0.16, 1.0),
        Text = imgui.ImVec4(0.90, 0.90, 0.95, 1.0),
        TextSecondary = imgui.ImVec4(0.60, 0.60, 0.70, 1.0),
        Border = imgui.ImVec4(0.20, 0.20, 0.28, 1.0),
        Accent = imgui.ImVec4(0.15, 0.45, 0.85, 1.0),
    },
    {
        name = "Royal Purple",
        WindowBg = imgui.ImVec4(0.08, 0.06, 0.12, 0.95),
        Header = imgui.ImVec4(0.55, 0.20, 0.80, 1.0),
        HeaderHovered = imgui.ImVec4(0.70, 0.30, 0.95, 1.0),
        Button = imgui.ImVec4(0.15, 0.10, 0.20, 1.0),
        ButtonHovered = imgui.ImVec4(0.22, 0.15, 0.28, 1.0),
        ButtonActive = imgui.ImVec4(0.55, 0.20, 0.80, 1.0),
        FrameBg = imgui.ImVec4(0.12, 0.08, 0.18, 1.0),
        Text = imgui.ImVec4(0.92, 0.88, 0.95, 1.0),
        TextSecondary = imgui.ImVec4(0.65, 0.58, 0.75, 1.0),
        Border = imgui.ImVec4(0.30, 0.18, 0.40, 1.0),
        Accent = imgui.ImVec4(0.65, 0.30, 0.95, 1.0),
    },
    {
        name = "Emerald Teal",
        WindowBg = imgui.ImVec4(0.05, 0.09, 0.08, 0.94),
        Header = imgui.ImVec4(0.05, 0.65, 0.50, 1.0),
        HeaderHovered = imgui.ImVec4(0.10, 0.80, 0.60, 1.0),
        Button = imgui.ImVec4(0.08, 0.12, 0.10, 1.0),
        ButtonHovered = imgui.ImVec4(0.12, 0.18, 0.14, 1.0),
        ButtonActive = imgui.ImVec4(0.05, 0.65, 0.50, 1.0),
        FrameBg = imgui.ImVec4(0.08, 0.14, 0.12, 1.0),
        Text = imgui.ImVec4(0.90, 0.95, 0.92, 1.0),
        TextSecondary = imgui.ImVec4(0.55, 0.68, 0.60, 1.0),
        Border = imgui.ImVec4(0.12, 0.30, 0.25, 1.0),
        Accent = imgui.ImVec4(0.05, 0.80, 0.60, 1.0),
    },
    {
        name = "Crimson Fire",
        WindowBg = imgui.ImVec4(0.09, 0.05, 0.05, 0.94),
        Header = imgui.ImVec4(0.80, 0.15, 0.15, 1.0),
        HeaderHovered = imgui.ImVec4(0.95, 0.25, 0.20, 1.0),
        Button = imgui.ImVec4(0.18, 0.08, 0.08, 1.0),
        ButtonHovered = imgui.ImVec4(0.25, 0.12, 0.10, 1.0),
        ButtonActive = imgui.ImVec4(0.80, 0.15, 0.15, 1.0),
        FrameBg = imgui.ImVec4(0.15, 0.08, 0.08, 1.0),
        Text = imgui.ImVec4(0.95, 0.90, 0.88, 1.0),
        TextSecondary = imgui.ImVec4(0.70, 0.55, 0.50, 1.0),
        Border = imgui.ImVec4(0.35, 0.15, 0.12, 1.0),
        Accent = imgui.ImVec4(0.95, 0.30, 0.15, 1.0),
    },
    {
        name = "Sunset Amber",
        WindowBg = imgui.ImVec4(0.10, 0.08, 0.05, 0.94),
        Header = imgui.ImVec4(0.85, 0.55, 0.15, 1.0),
        HeaderHovered = imgui.ImVec4(0.98, 0.70, 0.25, 1.0),
        Button = imgui.ImVec4(0.18, 0.14, 0.08, 1.0),
        ButtonHovered = imgui.ImVec4(0.25, 0.20, 0.12, 1.0),
        ButtonActive = imgui.ImVec4(0.85, 0.55, 0.15, 1.0),
        FrameBg = imgui.ImVec4(0.16, 0.12, 0.08, 1.0),
        Text = imgui.ImVec4(0.95, 0.92, 0.88, 1.0),
        TextSecondary = imgui.ImVec4(0.72, 0.65, 0.52, 1.0),
        Border = imgui.ImVec4(0.40, 0.28, 0.12, 1.0),
        Accent = imgui.ImVec4(0.98, 0.75, 0.20, 1.0),
    },
}

local keyNames = {
    [0x30] = "0", [0x31] = "1", [0x32] = "2", [0x33] = "3", [0x34] = "4",
    [0x35] = "5", [0x36] = "6", [0x37] = "7", [0x38] = "8", [0x39] = "9",
    [0x41] = "A", [0x42] = "B", [0x43] = "C", [0x44] = "D", [0x45] = "E",
    [0x46] = "F", [0x47] = "G", [0x48] = "H", [0x49] = "I", [0x4A] = "J",
    [0x4B] = "K", [0x4C] = "L", [0x4D] = "M", [0x4E] = "N", [0x4F] = "O",
    [0x50] = "P", [0x51] = "Q", [0x52] = "R", [0x53] = "S", [0x54] = "T",
    [0x55] = "U", [0x56] = "V", [0x57] = "W", [0x58] = "X", [0x59] = "Y",
    [0x5A] = "Z",
    [0x60] = "Num0", [0x61] = "Num1", [0x62] = "Num2", [0x63] = "Num3",
    [0x64] = "Num4", [0x65] = "Num5", [0x66] = "Num6", [0x67] = "Num7",
    [0x68] = "Num8", [0x69] = "Num9",
    [0x6B] = "Num+", [0x6D] = "Num-", [0x6E] = "Num.",
    [0x21] = "PgUp", [0x22] = "PgDn", [0x23] = "End", [0x24] = "Home",
    [0x25] = "Left", [0x26] = "Up", [0x27] = "Right", [0x28] = "Down",
    [0x2D] = "Ins", [0x2E] = "Del",
    [0x70] = "F1", [0x71] = "F2", [0x72] = "F3", [0x73] = "F4",
    [0x74] = "F5", [0x75] = "F6", [0x76] = "F7", [0x77] = "F8",
    [0x78] = "F9", [0x79] = "F10", [0x7A] = "F11", [0x7B] = "F12",
    [0x09] = "Tab", [0x20] = "Space", [0x0D] = "Enter",
    [0xBC] = ",", [0xBE] = ".", [0xBF] = "/", [0xBA] = ";",
    [0xBD] = "-", [0xBB] = "=", [0xDB] = "[", [0xDD] = "]",
    [0xDC] = "\\", [0xC0] = "`", [0xDE] = "'",
}

local services = {
    'drugs', 'repair', 'job', 'live', 'refill', 'ticket', 'paper', 'licenses', 'escape', 'trade', 'towtruck', 'license',
    'taxi', 'medic', 'lawyer', 'free', 'gun', 'materials', 'needlicense', 'lawyercall', 'lesson', 'rob', 'barbut',
    'alliance', 'eventhelper', 'pubg', 'friend', 'bunker', 'quest', 'kit', 'flower',
}

local serviceEnabled = {}
local serviceHotkeys = {}
local acceptServices = {}

for _, service in ipairs(services) do
    acceptServices[service] = true
    serviceEnabled[service] = imguiAvailable and imgui.ImBool(true) or { v = true }
    serviceHotkeys[service] = { ctrl = false, shift = false, alt = false, key = 0 }
end

 
local pendingInvitations = {}   
local lastInviteTime = {}      

local editingHotkeyFor = nil
local recordingKey = false

local function save_settings()
    local ini = io.open(iniPath, 'w')
    if ini then
        ini:write('[Settings]\n')
        ini:write('currentTheme = ' .. tostring(currentTheme) .. '\n')
        ini:write('autoAcceptEnabled = ' .. tostring(autoAcceptEnabled) .. '\n')
        ini:write('autoGetjobEnabled = ' .. tostring(autoGetjobEnabled) .. '\n')
        ini:write('\n[Hotkeys]\n')
        for _, service in ipairs(services) do
            local hk = serviceHotkeys[service]
            local modifierStr = ''
            if hk.ctrl then modifierStr = modifierStr .. 'CTRL+' end
            if hk.shift then modifierStr = modifierStr .. 'SHIFT+' end
            if hk.alt then modifierStr = modifierStr .. 'ALT+' end
            ini:write(service .. ' = ' .. modifierStr .. string.format("0x%X", hk.key) .. '\n')
        end
        ini:close()
    end
end

local function load_settings()
    local ini = io.open(iniPath, 'r')
    local inHotkeysSection = false
    if ini then
        for line in ini:lines() do
            if line == '[Hotkeys]' then inHotkeysSection = true
            elseif line == '[Settings]' then inHotkeysSection = false
            elseif inHotkeysSection then
                local key, value = line:match('^([%w]+)%s*=%s*(.+)$')
                if key and value then
                    local hk = { ctrl = false, shift = false, alt = false, key = 0 }
                    if value:find('CTRL') then hk.ctrl = true end
                    if value:find('SHIFT') then hk.shift = true end
                    if value:find('ALT') then hk.alt = true end
                    local hexKey = value:match('0x(%x+)')
                    hk.key = tonumber(hexKey, 16) or 0
                    if serviceHotkeys[key] then serviceHotkeys[key] = hk end
                end
            else
                local key, value = line:match('^([%w]+)%s*=%s*(.+)$')
                if key == 'currentTheme' then currentTheme = tonumber(value) or 1
                elseif key == 'autoAcceptEnabled' then autoAcceptEnabled = (value == 'true')
                elseif key == 'autoGetjobEnabled' then autoGetjobEnabled = (value == 'true') end
            end
        end
        ini:close()
    end
end

local function apply_modern_style()
    if not imguiAvailable then return end
    local style = imgui.GetStyle()
    style.WindowRounding = 8.0
    style.FrameRounding = 4.0
    style.ScrollbarRounding = 10.0
    style.WindowPadding = imgui.ImVec2(15, 15)

    local theme = themes[currentTheme]
    local colors = style.Colors
    colors[imgui.Col.WindowBg] = theme.WindowBg
    colors[imgui.Col.Header] = theme.Header
    colors[imgui.Col.HeaderHovered] = theme.HeaderHovered
    colors[imgui.Col.Button] = theme.Button
    colors[imgui.Col.ButtonHovered] = theme.ButtonHovered
    colors[imgui.Col.ButtonActive] = theme.ButtonActive
    colors[imgui.Col.FrameBg] = theme.FrameBg
    colors[imgui.Col.CheckMark] = theme.Accent
end

function get_hotkey_display_string(service)
    local hk = serviceHotkeys[service]
    if hk.key == 0 then return "None" end
    local parts = {}
    if hk.ctrl then table.insert(parts, "CTRL") end
    if hk.shift then table.insert(parts, "SHIFT") end
    if hk.alt then table.insert(parts, "ALT") end
    table.insert(parts, keyNames[hk.key] or string.format("0x%X", hk.key))
    return table.concat(parts, " + ")
end

function draw_auto_accept_ui()
    if not imguiAvailable then return end
    apply_modern_style()
    local io = imgui.GetIO()
    imgui.SetNextWindowPos(imgui.ImVec2(io.DisplaySize.x * 0.5, io.DisplaySize.y * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(500, 560), imgui.Cond.Always)

    if imgui.Begin('##MainUI', show_ui, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar) then
        imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowWidth() - 30, 10))
        if imgui.Button('X', imgui.ImVec2(20, 20)) then show_ui.v = false end

        imgui.Spacing()
        local title = "Auto Accept System"
        imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(title).x) / 2)
        imgui.TextColored(themes[currentTheme].Accent, title)
        imgui.Separator()

        imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(10, 10))
        if imgui.Button(autoAcceptEnabled and 'DISABLE AUTO-ACCEPT' or 'ENABLE AUTO-ACCEPT', imgui.ImVec2(-1, 40)) then
            autoAcceptEnabled = not autoAcceptEnabled
            if autoAcceptEnabled then
            sampAddChatMessage("{00FF00}[Auto-Accept]: {FFFFFF}Sistemul a fost activat.", -1)
             else
            sampAddChatMessage("{FF0000}[Auto-Accept]: {FFFFFF}Sistemul a fost dezactivat.", -1)
            end
        end
        if imgui.Button(autoGetjobEnabled and 'DISABLE AUTO-GETJOB' or 'ENABLE AUTO-GETJOB', imgui.ImVec2(-1, 40)) then
            autoGetjobEnabled = not autoGetjobEnabled
            if autoGetjobEnabled then
            sampAddChatMessage("{00FF00}[Auto-GetJob]: {FFFFFF}Sistemul a fost activat.", -1)
             else
            sampAddChatMessage("{FF0000}[Auto-GetJob]: {FFFFFF}Sistemul a fost dezactivat.", -1)
            end
        end
        imgui.PopStyleVar()

        imgui.Spacing()
        imgui.Text('Servicii Monitorizate:')
        if imgui.BeginChild('##ServicesScroll', imgui.ImVec2(0, 280), true) then
            imgui.Columns(3, '##Cols', false)
            for _, service in ipairs(services) do
                imgui.Checkbox(service:gsub('^%l', string.upper), serviceEnabled[service])
                imgui.NextColumn()
            end
            imgui.Columns(1)
            imgui.EndChild()
        end

        imgui.SetCursorPos(imgui.ImVec2(15, imgui.GetWindowHeight() - 25))
        imgui.TextDisabled('Created by [TLG]allecsei')

        imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowWidth() - 180, imgui.GetWindowHeight() - 30))
        if imgui.Button('Hotkeys', imgui.ImVec2(55, 20)) then showHotkeysMenu.v = true end
        imgui.SameLine()
        if imgui.Button('Settings', imgui.ImVec2(55, 20)) then showSettingsMenu.v = true end
        imgui.SameLine()
        if imgui.Button('Close', imgui.ImVec2(50, 20)) then show_ui.v = false end
    end
    imgui.End()
end

function draw_hotkeys_menu()
    if not imguiAvailable or not showHotkeysMenu.v then return end
    apply_modern_style()
    imgui.SetNextWindowSize(imgui.ImVec2(600, 900), imgui.Cond.Always)
    if imgui.Begin('Hotkeys Configuration', showHotkeysMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
        imgui.TextWrapped("Click pe un serviciu pentru a schimba hotkey-ul. Apasa ESC pentru a anula.")
        imgui.Separator()

        if imgui.BeginChild('##HotkeysScroll', imgui.ImVec2(0, 800), true) then
            imgui.Columns(3, '##HKCols', false)
            for _, service in ipairs(services) do
                imgui.Text(service:gsub('^%l', string.upper))
                imgui.NextColumn()
                
                local display = (editingHotkeyFor == service) and "Press Key..." or get_hotkey_display_string(service)
                if imgui.Button(display .. "##" .. service, imgui.ImVec2(200, 25)) then
                    editingHotkeyFor = service
                    recordingKey = true  
                end
                imgui.NextColumn()
                
                if serviceHotkeys[service].key ~= 0 then
                    if imgui.Button("Clear##" .. service, imgui.ImVec2(80, 25)) then
                        serviceHotkeys[service] = { ctrl = false, shift = false, alt = false, key = 0 }
                        save_settings()
                    end
                end
                imgui.NextColumn()
            end
            imgui.Columns(1)
            imgui.EndChild()
        end
        if imgui.Button('Inchide', imgui.ImVec2(-1, 30)) then showHotkeysMenu.v = false end
        imgui.End()
    end
end

function draw_settings_menu()
    if not imguiAvailable or not showSettingsMenu.v then return end
    apply_modern_style()
    imgui.SetNextWindowSize(imgui.ImVec2(400, 380), imgui.Cond.Always)
    if imgui.Begin('Settings - Theme', showSettingsMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
        for i, theme in ipairs(themes) do
            if imgui.Button(theme.name .. (i == currentTheme and ' [Activ]' or ''), imgui.ImVec2(-1, 35)) then
                currentTheme = i
                save_settings()
            end
        end
        imgui.End()
    end
end

function sampev.onServerMessage(color, text)
        for _, service in ipairs(services) do
        local pattern1 = "%{.-%}%s*%((%w+)%)%s*va oferi serviciul%s*%[" .. service .. "%]%s*pentru tine%s*%.%s*Scrie%s*/accept%s*" .. service .. "%s*(%d+)"
        local player, inviteId = text:match(pattern1)
        if player and inviteId then
            pendingInvitations[service] = { player = player, id = tonumber(inviteId), timestamp = os.time() }
            lastInviteTime[service] = os.time()
            if autoAcceptEnabled and serviceEnabled[service].v then
                lua_thread.create(function()
                    wait(100)
                    sampSendChat('/accept ' .. service .. ' ' .. inviteId)
                end)
            end
            return
        end

        local pattern2 = '/accept%s*' .. service .. '%s*(%d+)'
        local extractedId = text:match(pattern2)
        if extractedId then
            local existing = pendingInvitations[service]
            if not existing or existing.id ~= tonumber(extractedId) then
                pendingInvitations[service] = { player = "unknown", id = tonumber(extractedId), timestamp = os.time() }
                lastInviteTime[service] = os.time()
            end
            if autoAcceptEnabled and serviceEnabled[service].v then
                lua_thread.create(function()
                    wait(100)
                    sampSendChat('/accept ' .. service .. ' ' .. extractedId)
                end)
            end
            return
        end

        local altPattern = "(%w+) ti%-a trimis o invitatie pentru %[" .. service .. "%]"
        local altPlayer = text:match(altPattern)
        if altPlayer then
            pendingInvitations[service] = { player = altPlayer, id = 1, timestamp = os.time() }
            lastInviteTime[service] = os.time()
            if autoAcceptEnabled and serviceEnabled[service].v then
                lua_thread.create(function()
                    wait(100)
                    sampSendChat('/accept ' .. service .. ' 1')
                end)
            end
            return
        end
    end
end

function main()
    while not isSampAvailable() do wait(100) end
    load_settings()

    lua_thread.create(function()
        while true do
            wait(60000) 
            local now = os.time()
            for service, invite in pairs(pendingInvitations) do
                if now - invite.timestamp > 60 then
                    pendingInvitations[service] = nil
                end
            end
        end
    end)
    sampAddChatMessage("{4dbce9}[Auto-Accept]: {FFFFFF}Scriptul a fost incarcat. Foloseste {4dbce9}/autoaccept {FFFFFF}pentru setari.", -1)
    sampAddChatMessage("{4dbce9}[Auto-Accept]: {FFFFFF}Author: {4dbce9}allecsei{FFFFFF}, Version: {4dbce9}1.6.3{FFFFFF} | Discord: {4dbce9}allecsei", -1)
    sampRegisterChatCommand('autoaccept', function() show_ui.v = not show_ui.v end)

    lua_thread.create(function()
        while true do
            wait(0)
            if recordingKey and editingHotkeyFor then
                for code, name in pairs(keyNames) do
                    if wasKeyPressed(code) then
                        if code == 0x1B then -- ESC
                            editingHotkeyFor = nil
                            recordingKey = false
                        else
                            serviceHotkeys[editingHotkeyFor] = {
                                ctrl = isKeyDown(0x11),
                                shift = isKeyDown(0x10),
                                alt = isKeyDown(0x12),
                                key = code
                            }
                            sampAddChatMessage("{00FF00}Hotkey salvat pentru " .. editingHotkeyFor, -1)
                            editingHotkeyFor = nil
                            recordingKey = false
                            save_settings()
                        end
                    end
                end
            end
        end
    end)

    lua_thread.create(function()
        while true do
            wait(0)
            if not recordingKey then
                for _, service in ipairs(services) do
                    local hk = serviceHotkeys[service]
                    if hk.key ~= 0 and wasKeyPressed(hk.key) then
                        if (not hk.ctrl or isKeyDown(0x11)) and (not hk.shift or isKeyDown(0x10)) and (not hk.alt or isKeyDown(0x12)) then
                            if serviceEnabled[service].v then
                                local invite = pendingInvitations[service]
                                local inviteId = invite and invite.id or 1
                                sampSendChat('/accept ' .. service .. ' ' .. inviteId)
                                lastInviteTime[service] = os.time()
                            end
                        end
                    end
                end
            end
        end
    end)

    while true do
        wait(0)
        if imguiAvailable then
            imgui.Process = show_ui.v or showSettingsMenu.v or showHotkeysMenu.v
        end
    end
end

if imguiAvailable then
    imgui.OnDrawFrame = function()
        draw_auto_accept_ui()
        draw_settings_menu()
        draw_hotkeys_menu()
    end
end