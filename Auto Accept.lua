script_name('Auto Accept')
script_author('allecsei')
script_version('v1.3')

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

-- Culori noul stil modern
local primaryColor = imguiAvailable and imgui.ImVec4(0.15, 0.45, 0.85, 1.0) or nil
local successColor = imguiAvailable and imgui.ImVec4(0.10, 0.75, 0.10, 1.0) or nil
local dangerColor = imguiAvailable and imgui.ImVec4(0.75, 0.10, 0.10, 1.0) or nil

local autoAcceptEnabled = true
local show_ui = imguiAvailable and imgui.ImBool(false) or { v = false }

local services = {
    'drugs','repair','live','refill','ticket','paper','licenses','escape','trade','towtruck','license',
    'taxi','medic','lawyer','free','gun','materials','needlicense','lawyercall','lesson','rob','barbut',
    'alliance','eventhelper','pubg','friend','bunker','quest','kit','flower',
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

-- Stilul vizual modern
local function apply_modern_style()
    local style = imgui.GetStyle()
    style.WindowRounding = 8.0
    style.FrameRounding = 4.0
    style.ScrollbarRounding = 10.0
    style.WindowPadding = imgui.ImVec2(15, 15)
    
    local colors = style.Colors
    colors[imgui.Col.WindowBg] = imgui.ImVec4(0.07, 0.07, 0.09, 0.94)
    colors[imgui.Col.Header] = imgui.ImVec4(0.20, 0.25, 0.35, 1.00)
    colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.26, 0.35, 0.50, 1.00)
    colors[imgui.Col.Button] = imgui.ImVec4(0.12, 0.12, 0.15, 1.00)
    colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.18, 0.18, 0.22, 1.00)
    colors[imgui.Col.ButtonActive] = primaryColor
    colors[imgui.Col.FrameBg] = imgui.ImVec4(0.15, 0.15, 0.18, 1.00)
    colors[imgui.Col.CheckMark] = primaryColor
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

    -- WindowFlags.NoTitleBar pentru un aspect modern, fara bara de sus a windows-ului
    if imgui.Begin('##MainUI', show_ui, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar) then
        
        -- Buton de Close (X) in coltul din dreapta sus
        imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowWidth() - 30, 10))
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0, 0, 0)) -- Transparent normal
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.8, 0.1, 0.1, 1)) -- Rosu la hover
        if imgui.Button('X', imgui.ImVec2(20, 20)) then
            show_ui.v = false
            imgui.Process = false
        end
        imgui.PopStyleColor(2)

        imgui.Spacing()
        -- Centrare titlu principal "Auto Accept System"
        local mainTitle = "Auto Accept System"
        local mainTitleSize = imgui.CalcTextSize(mainTitle)
        imgui.SetCursorPosX((imgui.GetWindowWidth() - mainTitleSize.x) / 2)
        imgui.TextColored(primaryColor, mainTitle)            
        imgui.Separator()
        imgui.Spacing()

        -- Centrare Status General
        local statusLabel = "Global Status: "
        local statusState = autoAcceptEnabled and "Enabled" or "Disabled"
        local totalWidth = imgui.CalcTextSize(statusLabel).x + imgui.CalcTextSize(statusState).x
        imgui.SetCursorPosX((imgui.GetWindowWidth() - totalWidth) / 2)
        imgui.Text(statusLabel)
        imgui.SameLine()
        imgui.TextColored(autoAcceptEnabled and successColor or dangerColor, statusState)

        imgui.Spacing()

        -- Buton mare activare
        imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(10, 10))
        if imgui.Button(autoAcceptEnabled and 'DISABLE AUTO-ACCEPT' or 'ENABLE AUTO-ACCEPT', imgui.ImVec2(-1, 40)) then
            autoAcceptEnabled = not autoAcceptEnabled
        end
        imgui.PopStyleVar()
        
        imgui.Spacing()
        
        -- Butoane Actiuni Rapide
        if imgui.Button('Select All', imgui.ImVec2(225, 30)) then set_all_service_toggles(true) end
        imgui.SameLine()
        if imgui.Button('Deselect All', imgui.ImVec2(225, 30)) then set_all_service_toggles(false) end

        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()

        imgui.Text('Servicii Monitorizate:')
        if imgui.BeginChild('##ServicesScroll', imgui.ImVec2(0, 260), true) then
            imgui.Columns(3, '##Cols', false)
            for index, service in ipairs(services) do
                local label = service:gsub('^%l', string.upper)
                imgui.Checkbox(label, serviceEnabled[service])
                imgui.NextColumn()
            end
            imgui.Columns(1)
            imgui.EndChild()
        end
        
        -- Attribution fixat in stanga jos
        imgui.SetCursorPos(imgui.ImVec2(15, imgui.GetWindowHeight() - 25))
        imgui.TextDisabled('Created by [TLG]allecsei')

        -- Buton de inchidere in dreapta jos
        imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowWidth() - 85, imgui.GetWindowHeight() - 30))
        if imgui.Button('Close', imgui.ImVec2(70, 20)) then
            show_ui.v = false
        end
    end
    imgui.End()
end

if imguiAvailable then
    imgui.Process = false
    imgui.OnDrawFrame = function()
        if show_ui.v then
            draw_auto_accept_ui()
        end
    end
end

function main()
    if not isSampLoaded or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    sampAddChatMessage ('{ff4400}Auto Accept script loaded. Use {FFFFFF}/autoui{ff4400}, {FFFFFF}/on{ff4400} and {FFFFFF}/end{ff4400}.', 0xFFFFFF)
    sampRegisterChatCommand('autoui', function()
        show_ui.v = not show_ui.v
        imgui.Process = show_ui.v
    end)
    sampRegisterChatCommand('on', enable_autotext)
    sampRegisterChatCommand('end', disable_autotext)

    while true do
        wait(0)
        if imguiAvailable then
            imgui.Process = show_ui.v
        end
    end
end

function sampev.onServerMessage(color, text)
    if not autoAcceptEnabled then return end
    
    local service, id = text:match('Tasteaza%s+"%/accept%s+([%w_]+)%s+(%d+)"')
    if not service then
        service, id = text:match('Use%s+"%/accept%s+([%w_]+)%s+(%d+)"')
    end

    if service and id then
        service = service:lower()
        if acceptServices[service] and serviceEnabled[service].v then
            sampSendChat('/accept ' .. service .. ' ' .. id)
            sampAddChatMessage(string.format('{00FF00}Auto Accept: {FFFFFF}%s (%s)', service, id), 0xFFFFFF)
        end
    end
    
    -- Auto Engine
    if text:find('Scrie %/engine sau apasa 2') or text:find('Use %/engine or press 2') then
        sampSendChat('/engine')
    end
end
