script_name('Auto Accept')
script_author('allecsei')
script_version('v1.5')

require 'lib.moonloader'
local sampev = require 'lib.samp.events'

local imgui
local imgui_load_error
local imguiAvailable = false
local ok, loaded = pcall(require, 'imgui')
if ok then
    imgui = loaded
    imguiAvailable = true
else
    imgui_load_error = loaded
end

local primaryColor = imguiAvailable and imgui.ImVec4(0.15, 0.45, 0.85, 1.0) or nil
local successColor = imguiAvailable and imgui.ImVec4(0.10, 0.75, 0.10, 1.0) or nil
local dangerColor = imguiAvailable and imgui.ImVec4(0.75, 0.10, 0.10, 1.0) or nil

local currentTheme = 1
local showSettingsMenu = imguiAvailable and imgui.ImBool(false) or { v = false }

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

local function save_settings()
    local ini = io.open(iniPath, 'w')
    if ini then
        ini:write('[Settings]\n')
        ini:write('currentTheme = ' .. tostring(currentTheme) .. '\n')
        ini:write('autoAcceptEnabled = ' .. tostring(autoAcceptEnabled) .. '\n')
        ini:write('autoGetjobEnabled = ' .. tostring(autoGetjobEnabled) .. '\n')
        ini:close()
    end
end

local function load_settings()
    local ini = io.open(iniPath, 'r')
    if ini then
        for line in ini:lines() do
            local key, value = line:match('^([%w]+)%s*=%s*(.+)$')
            if key == 'currentTheme' then
                local num = tonumber(value)
                if num and num >= 1 and num <= #themes then
                    currentTheme = num
                end
            elseif key == 'autoAcceptEnabled' then
                autoAcceptEnabled = value == 'true'
            elseif key == 'autoGetjobEnabled' then
                autoGetjobEnabled = value == 'true'
            end
        end
        ini:close()
    end
end

local autoAcceptEnabled = true
local autoGetjobEnabled = true
local show_ui = imguiAvailable and imgui.ImBool(false) or { v = false }

local services = {
    'drugs', 'repair', 'job', 'live', 'refill', 'ticket', 'paper', 'licenses', 'escape', 'trade', 'towtruck', 'license',
    'taxi', 'medic', 'lawyer', 'free', 'gun', 'materials', 'needlicense', 'lawyercall', 'lesson', 'rob', 'barbut',
    'alliance', 'eventhelper', 'pubg', 'friend', 'bunker', 'quest', 'kit', 'flower',
}

local acceptServices = {}
local serviceEnabled = {}
for _, service in ipairs(services) do
    acceptServices[service] = true
    if imguiAvailable then
        serviceEnabled[service] = imgui.ImBool(true)
    else
        serviceEnabled[service] = { v = true }
    end
end

local debugMode = true -- Pentru debugging

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

function enable_autotext()
    autoAcceptEnabled = true
    sampAddChatMessage('{00FF00}Auto Accept enabled.', 0xFFFFFF)
end

function disable_autotext()
    autoAcceptEnabled = false
    sampAddChatMessage('{FF0000}Auto Accept disabled.', 0xFFFFFF)
end

function set_all_service_toggles(state)
    for _, service in ipairs(services) do
        if serviceEnabled[service] then
            serviceEnabled[service].v = state
        end
    end
end

function draw_auto_accept_ui()
    if not imguiAvailable then return end
    apply_modern_style()

    local io = imgui.GetIO()
    imgui.SetNextWindowPos(imgui.ImVec2(io.DisplaySize.x * 0.5, io.DisplaySize.y * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(500, 560), imgui.Cond.Always)

    if imgui.Begin('##MainUI', show_ui, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar) then

        imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowWidth() - 30, 10))
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0, 0, 0))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.8, 0.1, 0.1, 1))
        if imgui.Button('X', imgui.ImVec2(20, 20)) then
            show_ui.v = false
            imgui.Process = false
        end
        imgui.PopStyleColor(2)

        imgui.Spacing()

        local mainTitle = "Auto Accept System"
        local mainTitleSize = imgui.CalcTextSize(mainTitle)
        imgui.SetCursorPosX((imgui.GetWindowWidth() - mainTitleSize.x) / 2)
        imgui.TextColored(themes[currentTheme].Accent, mainTitle)
        imgui.Separator()
        imgui.Spacing()

        local statusLabel = "Auto-Accept Status: "
        local statusState = autoAcceptEnabled and "Enabled" or "Disabled"
        local totalWidth = imgui.CalcTextSize(statusLabel).x + imgui.CalcTextSize(statusState).x
        imgui.SetCursorPosX((imgui.GetWindowWidth() - totalWidth) / 2)
        imgui.Text(statusLabel)
        imgui.SameLine()
        imgui.TextColored(autoAcceptEnabled and successColor or dangerColor, statusState)

        imgui.Spacing()

        imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(10, 10))
        if imgui.Button(autoAcceptEnabled and 'DISABLE AUTO-ACCEPT' or 'ENABLE AUTO-ACCEPT', imgui.ImVec2(-1, 40)) then
            autoAcceptEnabled = not autoAcceptEnabled
        end
        imgui.Spacing()
        if imgui.Button(autoGetjobEnabled and 'DISABLE AUTO-GETJOB' or 'ENABLE AUTO-GETJOB', imgui.ImVec2(-1, 40)) then
            autoGetjobEnabled = not autoGetjobEnabled
        end
        imgui.PopStyleVar()

        imgui.Spacing()

        if imgui.Button('Select All', imgui.ImVec2(225, 30)) then set_all_service_toggles(true) end
        imgui.SameLine()
        if imgui.Button('Deselect All', imgui.ImVec2(225, 30)) then set_all_service_toggles(false) end

        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()

        imgui.Text('Servicii Monitorizate:')
        if imgui.BeginChild('##ServicesScroll', imgui.ImVec2(0, 280), true) then
            imgui.Columns(3, '##Cols', false)
            for index, service in ipairs(services) do
                local label = service:gsub('^%l', string.upper)
                imgui.Checkbox(label, serviceEnabled[service])
                imgui.NextColumn()
            end
            imgui.Columns(1)
            imgui.EndChild()
        end

        imgui.SetCursorPos(imgui.ImVec2(15, imgui.GetWindowHeight() - 25))
        imgui.TextDisabled('Created by [TLG]allecsei')

        -- Close and Settings buttons
        imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowWidth() - 125, imgui.GetWindowHeight() - 30))
        if imgui.Button('Settings', imgui.ImVec2(50, 20)) then
            showSettingsMenu.v = true
        end
        imgui.SameLine()
        if imgui.Button('Close', imgui.ImVec2(50, 20)) then
            show_ui.v = false
        end
    end
    imgui.End()
end

function draw_settings_menu()
    if not imguiAvailable or not showSettingsMenu.v then return end
    
    apply_modern_style()

    local io = imgui.GetIO()
    imgui.SetNextWindowPos(imgui.ImVec2(io.DisplaySize.x * 0.5, io.DisplaySize.y * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(400, 380), imgui.Cond.Always)

    imgui.PushStyleColor(imgui.Col.TitleBg, themes[currentTheme].Accent)
    imgui.PushStyleColor(imgui.Col.TitleBgActive, themes[currentTheme].Accent)
    imgui.PushStyleColor(imgui.Col.TitleBgCollapsed, themes[currentTheme].Accent)

    if imgui.Begin('Settings - Theme', showSettingsMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
        
        imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowWidth() - 30, 10))
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0, 0, 0))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.8, 0.1, 0.1, 1))
        if imgui.Button('X', imgui.ImVec2(20, 20)) then
            showSettingsMenu.v = false
        end
        imgui.PopStyleColor(2)

        imgui.Spacing()

        local title = "Select Theme"
        local titleSize = imgui.CalcTextSize(title)
        imgui.SetCursorPosX((imgui.GetWindowWidth() - titleSize.x) / 2)
        imgui.TextColored(themes[currentTheme].Accent, title)
        imgui.Separator()
        imgui.Spacing()

        for i, theme in ipairs(themes) do
            local isSelected = (i == currentTheme)
            local btnWidth = -1

            imgui.PushStyleColor(imgui.Col.Button, isSelected and theme.Accent or theme.Button)
            imgui.PushStyleColor(imgui.Col.ButtonHovered, theme.ButtonHovered)
            imgui.PushStyleColor(imgui.Col.ButtonActive, theme.Accent)

            imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(15, 12))

            if imgui.Button(theme.name .. (isSelected and ' [Activ]' or ''), imgui.ImVec2(btnWidth, 38)) then
                currentTheme = i
                save_settings()
            end

            imgui.PopStyleVar()
            imgui.PopStyleColor(3)

            imgui.Spacing()
        end

        imgui.Spacing()

        local currentThemeName = themes[currentTheme].name
        local previewText = "Tema activa: " .. currentThemeName
        local previewSize = imgui.CalcTextSize(previewText)
        imgui.SetCursorPosX((imgui.GetWindowWidth() - previewSize.x) / 2)
        imgui.TextColored(themes[currentTheme].Accent, previewText)

        imgui.Spacing()
    
        imgui.SetCursorPosX((imgui.GetWindowWidth() - 80) / 2)
        if imgui.Button('Inchide', imgui.ImVec2(80, 30)) then
            showSettingsMenu.v = false
        end

        imgui.End() 
    end

    imgui.PopStyleColor(3)
end

if imguiAvailable then
    imgui.Process = false
    imgui.OnDrawFrame = function()
        apply_modern_style()
        if show_ui.v then
            draw_auto_accept_ui()
        end
        if showSettingsMenu.v then
            draw_settings_menu()
        end
    end
end

local lastGetjobTime = 0
local jobTexts = {}

function main()
    if not isSampLoaded or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    load_settings()

    if imguiAvailable then
        apply_modern_style()
    end

    sampAddChatMessage ('{ff4400}Auto Accept {FFFFFF}script loaded. {ff4400}Use {FFFFFF}/autoui, {FFFFFF}/on{ffff00} and {FFFFFF}/end.', 0xFFFFFF)
    sampRegisterChatCommand('autoui', function()
        show_ui.v = not show_ui.v
        imgui.Process = show_ui.v
    end)
    sampRegisterChatCommand('on', enable_autotext)
    sampRegisterChatCommand('end', disable_autotext)
    sampRegisterChatCommand('autogetjob', function()
        autoGetjobEnabled = not autoGetjobEnabled
        sampAddChatMessage(autoGetjobEnabled and '{00FF00}Auto GetJob enabled.' or '{FF0000}Auto GetJob disabled.', 0xFFFFFF)
    end)

    -- Auto GetJob Thread --
    lua_thread.create(function()
        while true do
            wait(500)
            if autoGetjobEnabled and os.clock() - lastGetjobTime > 10 then
                local pX, pY, pZ = getCharCoordinates(PLAYER_PED)
                for id, pos in pairs(jobTexts) do
                    if getDistanceBetweenCoords3d(pX, pY, pZ, pos.x, pos.y, pos.z) < 3.0 then
                        sampSendChat('/getjob')
                        lastGetjobTime = os.clock()
                        break
                    end
                end
            end
        end
    end)

    while true do
        wait(0)
        if imguiAvailable then
            imgui.Process = show_ui.v
        end
    end
end

local function extractAcceptInfo(text)
    local service, id = text:match('Tasteaza[^"]*"%/accept%s+([%w]+)[^%w]+(%d+)')
    if service and id then return service, id end

    service, id = text:match('[Uu]se[^"]*"%/accept%s+([%w]+)[^%w]+(%d+)')
    if service and id then return service, id end

    service, id = text:match('Tasteaza%s+%/?accept%s+([%w]+)%s+(%d+)')
    if service and id then return service, id end

    service, id = text:match('[Uu]se%s+%/?accept%s+([%w]+)%s+(%d+)')
    if service and id then return service, id end

    service, id = text:match('%/?accept%s+([%w]+)%s+(%d+)')
    if service and id then return service, id end

   
    service, id = text:match('([%w]+)%-(%d+)')
    if service and id then
        if text:lower():find('accept') then
            return service, id
        end
    end

    return nil, nil
end

function sampev.onServerMessage(color, text)
    if debugMode then   
    end

    if autoAcceptEnabled then
        local service, id = extractAcceptInfo(text)

        if service and id then
            service = service:lower()

            -- Debug message
            if debugMode then
                sampAddChatMessage(string.format('{FFFF00}[AUTO-DEBUG] {FFFFFF}Service: %s, ID: %s', service, id), 0xFFFF00)
            end

            if acceptServices[service] and serviceEnabled[service] and serviceEnabled[service].v then
                sampSendChat('/accept ' .. service .. ' ' .. id)
                sampAddChatMessage(string.format('{00FF00}Auto Accept: {FFFFFF}%s (%s)', service, id), 0xFFFFFF)
            end
        end
    end
   
    if text:find('Scrie %/engine sau apasa 2') or text:find('Use %/engine or press 2') then
        sampSendChat('/engine')
    end

    -- Auto GetJob
    if autoGetjobEnabled then
        if text:find('Tasteaza %/getjob') or text:find('Type %/getjob') or text:find('Use %/getjob') or text:find('Scrie %/getjob') then
            sampSendChat('/getjob')
        end
    end
end

function sampev.onDisplayGameText(style, time, text)
    if autoGetjobEnabled and text:lower():find('/getjob') then
        if os.clock() - lastGetjobTime > 10 then
            sampSendChat('/getjob')
            lastGetjobTime = os.clock()
        end
    end
end

function sampev.onCreate3DText(id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text)
    if text:lower():find('/getjob') then
        jobTexts[id] = {x = position.x, y = position.y, z = position.z}
    end
end

function sampev.onRemove3DText(id)
    jobTexts[id] = nil
end
