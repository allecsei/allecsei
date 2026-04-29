script_author('allecsei')
script_version('3.0.0')

local imgui = require 'imgui'
local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
local vkeys = require 'vkeys'
local inicfg = require 'inicfg'

encoding.default = 'CP1251'
local u8 = encoding.UTF8


---------------- shortcuts list ----------------
local cmds_hitmen = {
    {cmd = "lgh", desc = "Leave + GetHit"},
    {cmd = "uc", desc = "Undercover"},
    {cmd = "afvr", desc = "Faction Vehicle Respawn"},
    {cmd = "kc", desc = "Kill Checkpoint"},
    {cmd = "cf", desc = "Cancel Find"},
    {cmd = "o1", desc = "Order 1"},
    {cmd = "o2", desc = "Order 2"},
    {cmd = "gu", desc = "Gethit + Undercover"},
    {cmd = "gh", desc = "GetHit"},
    {cmd = "cmc", desc = "Clear Chat"},
    {cmd = "lh", desc = "Leave Hit"},
    {cmd = "myc", desc = "Mycontract"},
    {cmd = "lg", desc = "Logout"},
    {cmd = "pt", desc = "Portable"},
    {cmd = "ex", desc = "Exit"},
    {cmd = "rr", desc = "Refill Repair"},
    {cmd = "acr", desc = "Accept Contract"},
    {cmd = "en", desc = "Engine Toggle"},
    {cmd = "ee", desc = "Enter Exit"},
    {cmd = "fd", desc = "Find Player"},
    {cmd = "ftr", desc = "Find + Track Player"},
    {cmd = "bg", desc = "Buy Gunpack"},
    {cmd = "sa", desc = "Stop Animation"},
    {cmd = "sp", desc = "Spawn Point"},
    {cmd = "co", desc = "Costumes"},
    {cmd = "cmb", desc = "Clanmembers"},
    {cmd = "mb", desc = "Faction Members"},
    {cmd = "cx", desc = "Clan XP"},
    {cmd = "ct", desc = "Clan Turfs"},
    {cmd = "cdt", desc = "Clan Duty"},
    {cmd = "missm", desc = "Miss messages"},
    {cmd = "missc", desc = "Miss calls"},
    {cmd = "gj", desc = "Good Job"},
    {cmd = "ra", desc = "Faction Raport"},
    {cmd = "ha", desc = "Heal"},
    {cmd = "ntf", desc = "Notification"},
    {cmd = "czs", desc = "Clan Zones"},
    {cmd = "li", desc = "Lights Toggle"},
    {cmd = "staxi", desc = "Service Taxi"},
    {cmd = "smech", desc = "Service Mechanic"},
    {cmd = "smedic", desc = "Service Medic"},
    {cmd = "ctaxi", desc = "Cancel Taxi"},
    {cmd = "cmedic", desc = "Cancel Medic"},
    {cmd = "cmech", desc = "Cancel Mechanic"},
    {cmd = "emer", desc = "Emergency"},    
    {cmd = "svc", desc = "Service"},
    {cmd = "st", desc = "Stats"},
    {cmd = "autofind", desc = "Auto Find Contract"},  
    {cmd = "tso", desc = "The Silent One Mode"},    
    {cmd = "ghremind", desc = "GetHit Reminder"},  
}
----------------------- CONFIG & INI -----------------------
local direct_ini = "HitmenHelper.ini"
local main_ini = inicfg.load({
    appearance = {
        theme = 0,
        opacity = 0.94,
        rounding = 5.0
    },
    cursor = { enabled = true },
    recolorer = { active = true },
    protection = {
        min_dist = 160
    },
    features = {
        tso = false,
        tracker = false,
        screenshot = false,
        english = false,
        hitcooldown = false
    },
    shortcuts = {
        lgh = true, uc = true, afvr = true, kc = true, cf = true,
        o1 = true, o2 = true, gu = true, gh = true, cmc = true, lh = true,
        myc = true, lg = true, pt = true, ex = true, rr = true,
        acr = true, en = true, ee = true, fd = true, ftr = true,
        bg = true, sa = true, sp = true, co = true, cmb = true,
        mb = true, cx = true, ct = true, cdt = true, missm = true,
        missc = true, gj = true, ra = true, ha = true, ntf = true,
        czs = true, li = true, staxi = true, smech = true, smedic = true,
        ctaxi = true, cmedic = true, cmech = true, emer = true, svc = true, 
        tso = true, ghremind = true, autofind = true, st = true,
    }
}, direct_ini)

local shortcut_states = {}
local needs_initial_save = false
for _, v in ipairs(cmds_hitmen) do
    local key = v.cmd:gsub("/", "_")
    local iniValue = main_ini.shortcuts[key]
    -- Asigura ca valoarea din INI este intotdeauna boolean
    if type(iniValue) ~= "boolean" then
        iniValue = true -- Default la true daca valoarea nu e boolean sau nu exista
        main_ini.shortcuts[key] = true
        needs_initial_save = true
    end
    shortcut_states[key] = imgui.ImBool(iniValue)
end

------------------ save in inicfg -----------------
if not doesFileExist("moonloader/config/" .. direct_ini) or needs_initial_save then
    inicfg.save(main_ini, direct_ini)
end

----------------------- VARIABLES -----------------------
local main_window_state = imgui.ImBool(false)
local shorts_window_state = imgui.ImBool(false)
local appearance_window_state = imgui.ImBool(false)

local tso_state = imgui.ImBool(main_ini.features.tso)
local track_state = imgui.ImBool(main_ini.features.tracker)
local screenshot_state = imgui.ImBool(main_ini.features.screenshot)
local english_state = imgui.ImBool(main_ini.features.english)
local hitcooldown_state = imgui.ImBool(main_ini.features.hitcooldown)

local selected_theme = imgui.ImInt(main_ini.appearance.theme)
local menu_opacity = imgui.ImFloat(main_ini.appearance.opacity)
local cWindowStyle = imgui.ImInt(main_ini.appearance.style or 0)
local sniper_dist_val = imgui.ImInt(main_ini.protection.min_dist)

------------------------- Local Colors -------------------------
 local hitmenColor = 4284357388
local colorGreen  = 4278255360
local colorRed    = 4294901760
local colorWhite  = -1
local pID = -1
local contractID = -1

----------------------- THEMES FUNCTION -----------------------
function ApplyFantasticThemes(theme_idx)
    local style = imgui.GetStyle()
    local alpha = menu_opacity.v
    style.WindowRounding = main_ini.appearance.rounding

    local titleAlpha = math.min(alpha + 0.2, 1.0)

    if theme_idx == 0 then -- 1. NEON CYBER
        local accent = imgui.ImVec4(0.00, 0.60, 1.00, titleAlpha)
        style.Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.05, 0.05, 0.09, alpha)
        style.Colors[imgui.Col.TitleBg] = accent
        style.Colors[imgui.Col.TitleBgActive] = accent
        style.Colors[imgui.Col.Button] = imgui.ImVec4(0.50, 0.00, 0.50, 0.60)
        style.Colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.80, 0.00, 0.80, 0.80)
        style.Colors[imgui.Col.CheckMark] = imgui.ImVec4(0.00, 1.00, 1.00, 1.00)

    elseif theme_idx == 1 then -- 2. VOLCANO FURY
        local accent = imgui.ImVec4(0.60, 0.00, 0.00, titleAlpha)
        style.Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.08, 0.02, 0.02, alpha)
        style.Colors[imgui.Col.TitleBg] = accent
        style.Colors[imgui.Col.TitleBgActive] = accent
        style.Colors[imgui.Col.Button] = imgui.ImVec4(0.40, 0.00, 0.00, 0.70)
        style.Colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.60, 0.00, 0.00, 0.90)
        style.Colors[imgui.Col.CheckMark] = imgui.ImVec4(1.00, 0.30, 0.00, 1.00)

    elseif theme_idx == 2 then -- 3. DEEP OCEAN
        local accent = imgui.ImVec4(0.00, 0.40, 0.50, titleAlpha)
        style.Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.01, 0.08, 0.12, alpha)
        style.Colors[imgui.Col.TitleBg] = accent
        style.Colors[imgui.Col.TitleBgActive] = accent
        style.Colors[imgui.Col.Button] = imgui.ImVec4(0.00, 0.30, 0.40, 0.60)
        style.Colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.00, 0.50, 0.60, 0.80)
        style.Colors[imgui.Col.CheckMark] = imgui.ImVec4(0.20, 1.00, 0.80, 1.00)

    elseif theme_idx == 3 then -- 4. ROYAL PURPLE
        local accent = imgui.ImVec4(0.30, 0.00, 0.50, titleAlpha)
        style.Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.10, 0.05, 0.15, alpha)
        style.Colors[imgui.Col.TitleBg] = accent
        style.Colors[imgui.Col.TitleBgActive] = accent
        style.Colors[imgui.Col.Button] = imgui.ImVec4(0.40, 0.10, 0.60, 0.60)
        style.Colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.60, 0.20, 0.80, 0.80)
        style.Colors[imgui.Col.CheckMark] = imgui.ImVec4(1.00, 0.80, 0.00, 1.00)

    elseif theme_idx == 4 then -- 5. FOREST SPIRIT
        local accent = imgui.ImVec4(0.00, 0.40, 0.10, titleAlpha)
        style.Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.02, 0.05, 0.02, alpha)
        style.Colors[imgui.Col.TitleBg] = accent
        style.Colors[imgui.Col.TitleBgActive] = accent
        style.Colors[imgui.Col.Button] = imgui.ImVec4(0.10, 0.30, 0.10, 0.60)
        style.Colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.20, 0.50, 0.20, 0.80)
        style.Colors[imgui.Col.CheckMark] = imgui.ImVec4(0.40, 1.00, 0.40, 1.00)
    end
end

function ApplyWindowStyle(style_id)
    local style = imgui.GetStyle()

    if style_id == 0 then -- Clasic
        style.WindowRounding = 8.0
        style.ChildWindowRounding = 6.0
        style.FrameRounding = 5.0
        style.ScrollbarRounding = 6.0
        style.GrabRounding = 5.0
    elseif style_id == 1 then -- Modern
        style.WindowRounding = 15.0
        style.ChildWindowRounding = 12.0
        style.FrameRounding = 10.0
        style.ScrollbarRounding = 12.0
        style.GrabRounding = 10.0
    elseif style_id == 2 then -- Compact
        style.WindowRounding = 3.0
        style.ChildWindowRounding = 2.0
        style.FrameRounding = 2.0
        style.ScrollbarRounding = 2.0
        style.GrabRounding = 2.0
    elseif style_id == 3 then -- Glass
        style.WindowRounding = 20.0
        style.ChildWindowRounding = 15.0
        style.FrameRounding = 12.0
        style.ScrollbarRounding = 15.0
        style.GrabRounding = 12.0
    end
end

----------------------- TRANSLATION SYSTEM -----------------------
function t(str)
    local translations = {
        -- Main menu
        ["Hitmen Helper - Organizare Contracte"] = {"Hitmen Helper - Contract Organization"},
        ["AUTO GETHIT"] = {"AUTO GETHIT"},
        ["Nu uita contractele active!"] = {"Don't forget active contracts!"},
        ["REMINDER"] = {"REMINDER"},
        ["SETTINGS"] = {"SETTINGS"},
        ["Echipament ORDERS:"] = {"Equipment ORDERS:"},
        ["Order 1-3: Iti iei automat armele din HQ / casa de 3 ori consecutiv."] = {"Order 1-3: Automatically take weapons from HQ / house 3 times consecutively."},
        ["Order 1"] = {"Order 1"},
        ["Order 2"] = {"Order 2"},
        ["Order 3"] = {"Order 3"},
        ["SHORTS"] = {"SHORTS"},
        ["Close Menu"] = {"Close Menu"},

        -- Info section
        ["Info despre Hitmen Helper:"] = {"About Hitmen Helper:"},
        ["Auto Gethit:"] = {"Auto Gethit:"},
        [" Ia contractul si pune /undercover automat."] = {" Takes the contract and puts /undercover automatically."},
        ["Reminder:"] = {"Reminder:"},
        [" Trimite notificare sa nu uiti de contracte."] = {" Sends notification to not forget contracts."},
        ["Settings:"] = {"Settings:"},
        [" Personalizare teme, stiluri si opacitate."] = {" Customize themes, styles and opacity."},
        ["Module Active:"] = {"Active Modules:"},
        ["Track:"] = {"Track:"},
        ["Sistem avansat de urmarire tinta."] = {" Advanced target tracking system."},
        ["TSO:"] = {"TSO:"},
        [" Mod de lucru discret (The Silent One)."] = {" Discrete work mode (The Silent One)."},
        ["Screenshot:"] = {"Screenshot:"},
        [" Captureaza automat dovezile contractului."] = {" Automatically captures contract evidence."},

        -- Appearance window
        ["Appearance Settings"] = {"Appearance Settings"},
        ["Themes Selector"] = {"Theme Selector"},
        ["Window Styles"] = {"Window Styles"},
        ["Select style"] = {"Select style"},
        ["Opacity"] = {"Opacity"},
        ["Sniper Distance Protection"] = {"Sniper Distance Protection"},
        ["Distance"] = {"Distance"},
        ["Distanta setata: "] = {"Distance set: "},
        ["Save Distance"] = {"Save Distance"},
        ["Setarile Sniper Distance au fost salvate!"] = {"Sniper Distance settings have been saved!"},
        ["Close"] = {"Close"},

        -- Shortcuts window
        ["Shortcuts List"] = {"Shortcuts List"},
        ["Enable All"] = {"Enable All"},
        ["Disable All"] = {"Disable All"},

        -- Feature names
        ["The Silent One (TSO)"] = {"The Silent One (TSO)"},
        ["Tracking System (TRACK)"] = {"Tracking System (TRACK)"},
        ["English Lang"] = {"English Lang"},

        -- Themes
        ["Neon Cyber"] = {"Neon Cyber"},
        ["Volcano Fury"] = {"Volcano Fury"},
        ["Deep Ocean"] = {"Deep Ocean"},
        ["Royal Purple"] = {"Royal Purple"},
        ["Forest Spirit"] = {"Forest Spirit"},
        ["Clasic"] = {"Classic"},
        ["Modern"] = {"Modern"},
        ["Compact"] = {"Compact"},
        ["Glass"] = {"Glass"},
        ["Select theme"] = {"Select theme"},

        -- Chat messages
        ["Script incarcat! Foloseste %s/meniu%s sau tasta %sF2%s."] = {"Script loaded! Use %s/meniu%s or key %sF2%s."},
        ["Utilizare: /track [ID]"] = {"Usage: /track [ID]"},
        ["Acum urmaresti ID: %s"] = {"Now tracking ID: %s"},
        ["Functia %sThe Silent One%s a fost %sACTIVATA%s."] = {"%sThe Silent One%s function has been %sACTIVATED%s."},
        ["Functia %sThe Silent One%s a fost %sDEZACTIVATA%s."] = {"%sThe Silent One%s function has been %sDEACTIVATED%s."},
        ["Functia %sTracking System%s a fost %sACTIVATA%s."] = {"%sTracking System%s function has been %sACTIVATED%s."},
        ["Functia %sTracking System%s a fost %sDEZACTIVATA%s."] = {"%sTracking System%s function has been %sDEACTIVATED%s."},
        ["Functia %sScreenshot Mode%s a fost %sACTIVATA%s."] = {"%sScreenshot Mode%s function has been %sACTIVATED%s."},
        ["Functia %sScreenshot Mode%s a fost %sDEZACTIVATA%s."] = {"%sScreenshot Mode%s function has been %sDEACTIVATED%s."},
        ["Limba schimbata in %sENGLEZA%s."] = {"Language changed to %sENGLISH%s."},
        ["Limba schimbata in %sROMANA%s."] = {"Language changed to %sROMANIAN%s."},
    }

    -- Simple string translation (for strings without patterns)
    if translations[str] then
        return english_state.v and translations[str][1] or str
    end

    -- Pattern-based translation
    for ro, en in pairs(translations) do
        if string.find(str, ro:gsub("%%", "%%%%")) then
            return english_state.v and en[1] or str
        end
    end

    return str
end

-- Helper function for translated text with formatting
function tf(str, ...)
    local translated = t(str)
    local args = {...}
    for i, v in ipairs(args) do
        translated = translated:gsub("%%s", v, 1)
    end
    return translated
end

----------------------- FUNCTIONS -----------------------
function cf()
    sampSendChat("/cancel find")
end

function kc()
    sampSendChat("/killcp")
end

function gh()
    sampSendChat("gethit")
end

function pt()
    sampSendChat("/portable")
end

function st()
    sampSendChat("/stats")
end

function lgh()
    lua_thread.create(function()
        sampSendChat("leavehit")
        wait(200)
        sampSendChat("gethit")
        wait(2000)
        sampSendChat("undercover")
    end)
end

function uc()
    sampSendChat("undercover")
end

function o1()
    lua_thread.create(function()
        sampSendChat("order 1")
        wait(100)
        sampSendChat("order 1")
        wait(100)
        sampSendChat("order 1")
    end)
end

function o2()
    lua_thread.create(function()
        sampSendChat("order 2")
        wait(100)
        sampSendChat("order 2")
        wait(100)
        sampSendChat("order 2")
    end)
end

function gu()
    lua_thread.create(function()
        sampSendChat("gethit")
        wait(1500)
        sampSendChat("undercover")
    end)
end

function lh()
    sampSendChat("leavehit")
end

function myc()
    sampSendChat("mycontract")
end

function lg()
    sampSendChat("logout")
end

function ex()
    sampSendChat("/exit")
end

function rr(arg)
    lua_thread.create(function()
        sampSendChat("/repair " .. arg)
        wait(100)
        sampSendChat("/refill " .. arg)
    end)
end

function ee()
    sampSendChat("/enter")
end

function bg()
    lua_thread.create(function()
        sampSendChat("/buygun deagle 100")
        wait(100)
        sampSendChat("/buygun m4 200")
        wait(100)
        sampSendChat("/buygun rifle 100")
    end)
end

function sa()
    lua_thread.create(function()
        sampSendChat("/stopanim")
    end)
end

function sp()
    lua_thread.create(function()
        sampSendChat("/spawnchange")
    end)
end

function en()
    lua_thread.create(function()
        sampSendChat("/engine")
    end)
end

function co()
    lua_thread.create(function()
        sampSendChat("/costumes")
    end)
end

function cmb()
    lua_thread.create(function()
        sampSendChat("/clanmembers")
    end)
end

function mb()
    lua_thread.create(function()
        sampSendChat("/members")
    end)
end

function cx()
    lua_thread.create(function()
        sampSendChat("/clanxp")
    end)
end

function ct()
    lua_thread.create(function()
        sampSendChat("/clanturfs")
    end)
end

function cdt()
    lua_thread.create(function()
        sampSendChat("/clanduty")
    end)
end

function missm()
    lua_thread.create(function()
        sampSendChat("/missed messages")
    end)
end

function missc()
    lua_thread.create(function()
        sampSendChat("/missed calls")
    end)
end

function gj()
    lua_thread.create(function()
        sampSendChat("/getjob")
    end)
end

function ha()
    lua_thread.create(function()
        sampSendChat("/heal")
    end)
end

function ntf()
    lua_thread.create(function()
        sampSendChat("/notifications")
    end)
end

function czs()
    lua_thread.create(function()
        sampSendChat("/clanzones")
    end)
end

function li()
    lua_thread.create(function()
        sampSendChat("/lights")
    end)
end

function staxi()
    lua_thread.create(function()
        sampSendChat("/service taxi")
    end)
end

function smech()
    lua_thread.create(function()
        sampSendChat("/service mechanic")
    end)
end

function smedic()
    lua_thread.create(function()
        sampSendChat("/service medic")
    end)
end

function ctaxi()
    lua_thread.create(function()
        sampSendChat("/cancel taxi")
    end)
end

function cmedic()
    lua_thread.create(function()
        sampSendChat("/cancel medic")
    end)
end

function cmech()
    lua_thread.create(function()
        sampSendChat("/cancel mechanic")
    end)
end

function emer()
    lua_thread.create(function()
        sampSendChat("/emergency")
    end)
end

function cmc()
    lua_thread.create(function()
        for i = 1, 50 do
            sampAddChatMessage(" ", -1)
        end
    end)
end

function svc()
    lua_thread.create(function()
        sampSendChat("/servicecalls")
    end)
end

function afvr()
    lua_thread.create(function()
        sampSendChat("/f FVR in 10 secunde.")
        wait(10000)
        sampSendChat("/fvr")
        sampSendChat("/f Done.")
    end)
end

function acr(arg)
    lua_thread.create(function()
        sampSendChat("/accept repair " .. arg)
        wait(100)
        sampSendChat("/accept refill " .. arg)
    end)
end

function ftr(arg)
    lua_thread.create(function()
        sampSendChat("/find " .. arg)
        wait(100)
        sampProcessChatInput("/track " .. arg)
    end)
end

function ra()
    sampSendChat("/raport")
end

function autofind()
    shortcut_states["autofind"].v = not shortcut_states["autofind"].v
    main_ini.shortcuts.autofind = shortcut_states["autofind"].v
    inicfg.save(main_ini, direct_ini)
    local status = shortcut_states["autofind"].v and "{00FF00}ON{ffffff}." or "{FF0000}OFF{ffffff}."
    sampAddChatMessage("{5e150c}[Hitmen Helper]{FFFFFF} Auto Find has been turned " .. status, -1)
end

function toggleTSOMain()
    tso_state.v = not tso_state.v
    main_ini.features.tso = tso_state.v
    inicfg.save(main_ini, direct_ini)
    
    local status = tso_state.v and "{00FF00}ACTIVATA" or "{FF0000}DEZACTIVATA"
    sampAddChatMessage("{5e150c}[Hitmen Helper]{FFFFFF} Functia {00FFFF}The Silent One{FFFFFF} a fost " .. status .. "{FFFFFF}.", -1)
end

function ghremind()
    shortcut_states["ghremind"].v = not shortcut_states["ghremind"].v
    main_ini.shortcuts.ghremind = shortcut_states["ghremind"].v
    inicfg.save(main_ini, direct_ini)
    local status = shortcut_states["ghremind"].v and "{00FF00}ON{ffffff}." or "{FF0000}OFF{ffffff}."
    if english_state.v then
        sampAddChatMessage("[Hitmen Helper]{FFFFFF} Gethit Reminder has been turned " .. status, -1)
    else
        sampAddChatMessage("{5e150c}[Hitmen Helper]{FFFFFF} Gethit Reminder a fost " .. status, -1)
    end
end

function toggleEnglish()
    english_state.v = not english_state.v
    main_ini.features.english = english_state.v
    inicfg.save(main_ini, direct_ini)
    if english_state.v then
        sampAddChatMessage("{5e150c}[Hitmen Helper]{FFFFFF} Limba schimbata in {00FF00}ENGLEZA{FFFFFF}.", -1)
    else
        sampAddChatMessage("{5e150c}[Hitmen Helper]{FFFFFF} Limba schimbata in {00FF00}ROMANA{FFFFFF}.", -1)
    end
end

function makeScreenshot(clean)
    lua_thread.create(function()
        if clean then
            displayHud(false)
            sampSetChatDisplayMode(0)
            wait(150)  
        end
        
        local memory = require("memory")
        memory.setuint8(sampGetBase() + 1154236, 1)

        if clean then
            wait(200) 
            displayHud(true)
            sampSetChatDisplayMode(2)
        end
    end)
end

----------------------- MAIN -----------------------
function onWindowMessage(msg, wparam, lparam)
    if msg == 0x0100 or msg == 0x0101 then
        if wparam == vkeys.VK_ESCAPE and (main_window_state.v or shorts_window_state.v or appearance_window_state.v) then
            if msg == 0x0101 then
                if shorts_window_state.v then shorts_window_state.v = false
                elseif appearance_window_state.v then appearance_window_state.v = false
                else main_window_state.v = false end
            end
            consumeWindowMessage()
        end
    end
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    local loadedMsg = english_state.v and "Script loaded! Use %s/meniu%s or key %sF2%s." or "Script incarcat! Foloseste %s/meniu%s sau tasta %sF2%s."
    sampAddChatMessage("{5e150c}[Hitmen Helper]{FFFFFF} " .. string.format(loadedMsg, "{5e150c}", "{FFFFFF}", "{5e150c}", "{FFFFFF}"), -1)

    sampRegisterChatCommand("meniu", function()
        main_window_state.v = not main_window_state.v
    end)

    sampRegisterChatCommand("track", function(arg)
        local id = tonumber(arg)
        if not id or not sampIsPlayerConnected(id) then
            local usageMsg = english_state.v and "Usage: /track [ID]" or "Utilizare: /track [ID]"
            sampAddChatMessage("{5e150c}[Hitmen Helper]{FFFFFF} " .. usageMsg, -1)
            pID = -1
            return
        end
        pID = id
        local trackMsg = english_state.v and "Now tracking ID: %s" or "Acum urmaresti ID: %s"
        sampAddChatMessage("{5e150c}[Hitmen Helper]{FFFFFF} " .. string.format(trackMsg, "{5e150c}" .. pID), -1)
    end)

    ------------------------ Register shortcuts commands ------------------------
    sampRegisterChatCommand("lgh", function() if shortcut_states["lgh"].v then lgh() end end)
    sampRegisterChatCommand("uc", function() if shortcut_states["uc"].v then uc() end end)
    sampRegisterChatCommand("afvr", function() if shortcut_states["afvr"].v then afvr() end end)
    sampRegisterChatCommand("kc", function() if shortcut_states["kc"].v then kc() end end)
    sampRegisterChatCommand("cf", function() if shortcut_states["cf"].v then cf() end end)
    sampRegisterChatCommand("o1", function() if shortcut_states["o1"].v then o1() end end)
    sampRegisterChatCommand("o2", function() if shortcut_states["o2"].v then o2() end end)
    sampRegisterChatCommand("gu", function() if shortcut_states["gu"].v then gu() end end)
    sampRegisterChatCommand("gh", function() if shortcut_states["gh"].v then gh() end end)
    sampRegisterChatCommand("cmc", function() if shortcut_states["cmc"].v then cmc() end end)
    sampRegisterChatCommand("lh", function() if shortcut_states["lh"].v then lh() end end)
    sampRegisterChatCommand("myc", function() if shortcut_states["myc"].v then myc() end end)
    sampRegisterChatCommand("lg", function() if shortcut_states["lg"].v then lg() end end)
    sampRegisterChatCommand("pt", function() if shortcut_states["pt"].v then pt() end end)
    sampRegisterChatCommand("st", function() if shortcut_states["st"].v then st() end end)
    sampRegisterChatCommand("ex", function() if shortcut_states["ex"].v then ex() end end)
    sampRegisterChatCommand("rr", function(arg) if shortcut_states["rr"].v then rr(arg) end end)
    sampRegisterChatCommand("acr", function(arg) if shortcut_states["acr"].v then acr(arg) end end)
    sampRegisterChatCommand("en", function() if shortcut_states["en"].v then en() end end)
    sampRegisterChatCommand("ee", function() if shortcut_states["ee"].v then ee() end end)
    sampRegisterChatCommand("ftr", function(arg) if shortcut_states["ftr"].v then ftr(arg) end end)
    sampRegisterChatCommand("bg", function() if shortcut_states["bg"].v then bg() end end)
    sampRegisterChatCommand("sa", function() if shortcut_states["sa"].v then sa() end end)
    sampRegisterChatCommand("sp", function() if shortcut_states["sp"].v then sp() end end)
    sampRegisterChatCommand("co", function() if shortcut_states["co"].v then co() end end)
    sampRegisterChatCommand("cmb", function() if shortcut_states["cmb"].v then cmb() end end)
    sampRegisterChatCommand("mb", function() if shortcut_states["mb"].v then mb() end end)
    sampRegisterChatCommand("cx", function() if shortcut_states["cx"].v then cx() end end)
    sampRegisterChatCommand("ct", function() if shortcut_states["ct"].v then ct() end end)
    sampRegisterChatCommand("cdt", function() if shortcut_states["cdt"].v then cdt() end end)
    sampRegisterChatCommand("missm", function() if shortcut_states["missm"].v then missm() end end)
    sampRegisterChatCommand("missc", function() if shortcut_states["missc"].v then missc() end end)
    sampRegisterChatCommand("gj", function() if shortcut_states["gj"].v then gj() end end)
    sampRegisterChatCommand("ra", function() if shortcut_states["ra"].v then ra() end end)
    sampRegisterChatCommand("ha", function() if shortcut_states["ha"].v then ha() end end)
    sampRegisterChatCommand("ntf", function() if shortcut_states["ntf"].v then ntf() end end)
    sampRegisterChatCommand("czs", function() if shortcut_states["czs"].v then czs() end end)
    sampRegisterChatCommand("li", function() if shortcut_states["li"].v then li() end end)
    sampRegisterChatCommand("staxi", function() if shortcut_states["staxi"].v then staxi() end end)
    sampRegisterChatCommand("smech", function() if shortcut_states["smech"].v then smech() end end)
    sampRegisterChatCommand("smedic", function() if shortcut_states["smedic"].v then smedic() end end)
    sampRegisterChatCommand("ctaxi", function() if shortcut_states["ctaxi"].v then ctaxi() end end)
    sampRegisterChatCommand("cmedic", function() if shortcut_states["cmedic"].v then cmedic() end end)
    sampRegisterChatCommand("cmech", function() if shortcut_states["cmech"].v then cmech() end end)
    sampRegisterChatCommand("emer", function() if shortcut_states["emer"].v then emer() end end)
    sampRegisterChatCommand("svc", function() if shortcut_states["svc"].v then svc() end end)
    sampRegisterChatCommand("autofind", function() if shortcut_states["autofind"].v ~= nil then autofind() end end)
    sampRegisterChatCommand("tso", function() if shortcut_states["tso"].v then toggleTSOMain() end end)
    sampRegisterChatCommand("ghremind", function() if shortcut_states["ghremind"].v ~= nil then ghremind() end end)
    sampRegisterChatCommand("english", function() toggleEnglish() end)

    -- Titlu principal
    sampTextdrawCreate(2222, "Hitmen_Helper", 612.5, 424)
    sampTextdrawSetLetterSizeAndColor(2222, 0.25, 1.2, hitmenColor)
    sampTextdrawSetShadow(2222, 0.5, 4278190080)
    sampTextdrawSetStyle(2222, 1)
    sampTextdrawSetAlign(2222, 3)

    -- Versiune
    sampTextdrawCreate(2223, "v3.0", 614, 426)
    sampTextdrawSetLetterSizeAndColor(2223, 0.15, 1, -1)
    sampTextdrawSetShadow(2223, 0.5, 4278190080)
    sampTextdrawSetStyle(2223, 1)
    sampTextdrawSetAlign(2223, 1)

    -- TSO Indicator - Label
    sampTextdrawCreate(2224, "TSO_Mode:", 612, 416)
    sampTextdrawSetLetterSizeAndColor(2224, 0.19, 1.05, hitmenColor)
    sampTextdrawSetShadow(2224, 0.5, 4278190080)
    sampTextdrawSetStyle(2224, 1)
    sampTextdrawSetAlign(2224, 3)

    -- TSO Indicator - Status
    sampTextdrawCreate(2225, "OFF", 614.5, 416)
    sampTextdrawSetLetterSizeAndColor(2225, 0.15, 1.1, 4294901760)
    sampTextdrawSetShadow(2225, 0.5, 4278190080)
    sampTextdrawSetStyle(2225, 1)
    sampTextdrawSetAlign(2225, 1)

    -- Tracker Indicator - Label
    sampTextdrawCreate(2226, "Tracker:", 612.5, 407)
    sampTextdrawSetLetterSizeAndColor(2226, 0.19, 1.05, hitmenColor)
    sampTextdrawSetShadow(2226, 0.5, 4278190080)
    sampTextdrawSetStyle(2226, 1)
    sampTextdrawSetAlign(2226, 3)

    -- Tracker Indicator - Status
    sampTextdrawCreate(2227, "OFF", 614.5, 406.5)
    sampTextdrawSetLetterSizeAndColor(2227, 0.15, 1.1, 4294901760)
    sampTextdrawSetShadow(2227, 0.5, 4278190080)
    sampTextdrawSetStyle(2227, 1)
    sampTextdrawSetAlign(2227, 1)

    -- Distanta
    sampTextdrawCreate(2231, "", 597, 345)
    sampTextdrawSetLetterSizeAndColor(2231, 0.2, 1.2, colorWhite)
    sampTextdrawSetOutlineColor(2231, 0.5, 4278190080)
    sampTextdrawSetAlign(2231, 3)

    -- Sniper Distance Overlay
    sampTextdrawCreate(2230, "", 325, 229)
    sampTextdrawSetLetterSizeAndColor(2230, 0.4, 2.0, colorWhite)
    sampTextdrawSetOutlineColor(2230, 0.5, 4278190080)

    -- In vehicle / On foot
    sampTextdrawCreate(2275, "", 597, 336)
    sampTextdrawSetLetterSizeAndColor(2275, 0.18, 1, colorGreen)
    sampTextdrawSetOutlineColor(2275, 0.5, 4278190080)
    sampTextdrawSetAlign(2275, 3)

    -- AFK Status
    sampTextdrawCreate(2235, "", 612.5, 315)
    sampTextdrawSetLetterSizeAndColor(2235, 0.2, 1.2, colorRed)
    sampTextdrawSetOutlineColor(2235, 0.5, 4278190080)
    sampTextdrawSetAlign(2235, 2)

    while true do
        wait(0)
        if wasKeyPressed(0x71) and not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive() then
            main_window_state.v = not main_window_state.v
        end

        -- LOGICA IMGUI
        imgui.Process = main_window_state.v or shorts_window_state.v or appearance_window_state.v
        imgui.ShowCursor = imgui.Process

        -- Actualizeaza TSO status
        local tsoStatus = tso_state.v and "ON" or "OFF"
        sampTextdrawSetString(2225, tsoStatus)
        sampTextdrawSetLetterSizeAndColor(2225, 0.15, 1.1, tso_state.v and 4278255360 or 4294901760)

        -- Actualizeaza Tracker status 
        local trackMenuStatus = track_state.v and "ON" or "OFF"
        sampTextdrawSetString(2227, trackMenuStatus)
        sampTextdrawSetLetterSizeAndColor(2227, 0.15, 1.1, track_state.v and 4278255360 or 4294901760)

        -- LOGICA DE URMARIRE 
        if track_state.v and pID ~= -1 then
            local result, targetPed = sampGetCharHandleBySampPlayerId(pID)
            if result then
                local px, py, pz = getCharCoordinates(PLAYER_PED)
                local tx, ty, tz = getCharCoordinates(targetPed)
                local dist = getDistanceBetweenCoords3d(px, py, pz, tx, ty, tz)

                -- Actualizeaza distanta
                sampTextdrawSetString(2231, string.format("%.2fm", dist))

                -- Sniper distance overlay
                if isKeyDown(0x02) and getCurrentCharWeapon(PLAYER_PED) == 34 then
                    sampTextdrawSetString(2230, string.format("%.2fm", dist))
                else
                    sampTextdrawSetString(2230, "")
                end

                -- In vehicle / On foot
                local statusText = isCharInAnyCar(targetPed) and "In vehicle" or "On foot"
                local statusCol  = isCharInAnyCar(targetPed) and colorRed or colorGreen
                sampTextdrawSetString(2275, statusText)
                sampTextdrawSetLetterSizeAndColor(2275, 0.18, 1, statusCol)

                -- AFK Status
                if sampIsPlayerPaused(pID) then
                    sampTextdrawSetString(2235, "AFK")
                else
                    sampTextdrawSetString(2235, "")
                end
            else
                -- Clear tracking textdraws daca tinta nu mai e valida
                sampTextdrawSetString(2231, "")
                sampTextdrawSetString(2230, "")
                sampTextdrawSetString(2275, "")
                sampTextdrawSetString(2235, "")
            end
        else
            -- Clear tracking textdraws cand tracker e OFF sau nu e selectat ID
            sampTextdrawSetString(2231, "")
            sampTextdrawSetString(2230, "")
            sampTextdrawSetString(2275, "")
            sampTextdrawSetString(2235, "")
        end
    end
end

function DrawCmdRow(item, width)
    local key = item.cmd:gsub("/", "_")

    imgui.BeginGroup()
        imgui.TextColored(imgui.ImVec4(0.0, 1.0, 1.0, 1.0), "/" .. item.cmd)
        imgui.SameLine(70)
        imgui.Text(u8(item.desc))

        imgui.SameLine(width - 35)
        if imgui.Checkbox("##" .. key, shortcut_states[key]) then
            main_ini.shortcuts[key] = shortcut_states[key].v
            inicfg.save(main_ini, direct_ini)
        end
    imgui.EndGroup()
end

function set_all_shortcuts(state)
    for _, v in ipairs(cmds_hitmen) do
        local key = v.cmd:gsub("/", "_")
        if shortcut_states[key] then
            shortcut_states[key].v = state
            main_ini.shortcuts[key] = state
        end
    end
    inicfg.save(main_ini, direct_ini)
end

----------------------- IMGUI MAIN -----------------------
function imgui.OnDrawFrame()
    ApplyFantasticThemes(selected_theme.v)
    ApplyWindowStyle(cWindowStyle.v)

    if main_window_state.v then
        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(600, 620), imgui.Cond.FirstUseEver)

        imgui.Begin("Hitmen Helper V3.0", main_window_state, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
        imgui.Text(t("Hitmen Helper - Organizare Contracte"))
        imgui.Separator()
        imgui.Spacing()

        if imgui.Button(t("AUTO GETHIT"), imgui.ImVec2(-1, 30)) then
            sampSendChat("gethit")
            sampSendChat("undercover")
        end
        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()
        if imgui.Button(t("REMINDER"), imgui.ImVec2(-1, 35)) then
            sampAddChatMessage("{5e150c}[Hitmen Reminder]{FFFFFF} " .. t("Nu uita contractele active!"), -1)
        end
        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()
        if imgui.Button(t("SETTINGS"), imgui.ImVec2(-1, 30)) then
            appearance_window_state.v = not appearance_window_state.v
        end
        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()
        imgui.Text(t("Echipament ORDERS:"))
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.7, 0.7, 0.7, 1.0))
        imgui.TextWrapped(t("Order 1-3: Iti iei automat armele din HQ / casa de 3 ori consecutiv."))
        imgui.PopStyleColor()

        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()
        if imgui.Button(t("Order 1"), imgui.ImVec2(188, 30)) then for i = 1, 3 do sampSendChat("order 1") end end
        imgui.SameLine()
        if imgui.Button(t("Order 2"), imgui.ImVec2(188, 30)) then for i = 1, 3 do sampSendChat("order 2") end end
        imgui.SameLine()
        if imgui.Button(t("Order 3"), imgui.ImVec2(188, 30)) then for i = 1, 3 do sampSendChat("order 3") end end

        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()

        local windowWidth = 600
        local checkboxWidth = 145
        local numElements = 4
        local totalElementsWidth = checkboxWidth * numElements
        local spacing = -10

        local startX = (windowWidth - (totalElementsWidth + (spacing * (numElements - 1)))) / 2
        imgui.SetCursorPosX(startX)

        ----------------------- THE SILENT ONE -----------------------
        if imgui.Checkbox(t("The Silent One (TSO)"), tso_state) then
            main_ini.features.tso = tso_state.v
            inicfg.save(main_ini, direct_ini)
            if tso_state.v then
                sampAddChatMessage("{5e150c}[Hitmen Helper]{FFFFFF} " .. string.format(t("Functia %sThe Silent One%s a fost %sACTIVATA%s."), "{00FFFF}", "{00FFFF}", "{00FF00}", "{FFFFFF}"), -1)
            else
                sampAddChatMessage("{5e150c}[Hitmen Helper]{FFFFFF} " .. string.format(t("Functia %sThe Silent One%s a fost %sDEZACTIVATA%s."), "{00FFFF}", "{00FFFF}", "{FF0000}", "{FFFFFF}"), -1)
            end
        end

        imgui.SameLine(nil, 20)

        ----------------------- TRACKING SYSTEM -----------------------
        if imgui.Checkbox(t("Tracking System (TRACK)"), track_state) then
            main_ini.features.tracker = track_state.v
            inicfg.save(main_ini, direct_ini)
            if track_state.v then
                sampAddChatMessage("{5e150c}[Hitmen Helper]{FFFFFF} " .. string.format(t("Functia %sTracking System%s a fost %sACTIVATA%s."), "{00FFFF}", "{00FFFF}", "{00FF00}", "{FFFFFF}"), -1)
            else
                sampAddChatMessage("{5e150c}[Hitmen Helper]{FFFFFF} " .. string.format(t("Functia %sTracking System%s a fost %sDEZACTIVATA%s."), "{00FFFF}", "{00FFFF}", "{FF0000}", "{FFFFFF}"), -1)
            end
        end

        imgui.SameLine(nil, 20)

        ----------------------- SCREENSHOT -----------------------
        if imgui.Checkbox(t("Screenshot"), screenshot_state) then
            main_ini.features.screenshot = screenshot_state.v
            inicfg.save(main_ini, direct_ini)
            if screenshot_state.v then
                sampAddChatMessage("{5e150c}[Hitmen Helper]{FFFFFF} " .. string.format(t("Functia %sScreenshot Mode%s a fost %sACTIVATA%s."), "{00FFFF}", "{00FFFF}", "{00FF00}", "{FFFFFF}"), -1)
            else
                sampAddChatMessage("{5e150c}[Hitmen Helper]{FFFFFF} " .. string.format(t("Functia %sScreenshot Mode%s a fost %sDEZACTIVATA%s."), "{00FFFF}", "{00FFFF}", "{FF0000}", "{FFFFFF}"), -1)
            end
        end

        imgui.SameLine(nil, 20)

        ----------------------- LANGUAGE (ENGLISH) -----------------------
        if imgui.Checkbox(t("English Lang"), english_state) then
            main_ini.features.english = english_state.v
            inicfg.save(main_ini, direct_ini)
            if english_state.v then
                sampAddChatMessage("{5e150c}[Hitmen Helper]{FFFFFF} " .. string.format(t("Limba schimbata in %sENGLEZA%s."), "{00FF00}", "{FFFFFF}"), -1)
            else
                sampAddChatMessage("{5e150c}[Hitmen Helper]{FFFFFF} " .. string.format(t("Limba schimbata in %sROMANA%s."), "{00FF00}", "{FFFFFF}"), -1)
            end
        end

        imgui.Separator()

        ------------------------ INFO HITMEN HELPER CENTRAT ------------------------
        imgui.Spacing()

        local windowWidth = imgui.GetWindowSize().x
        local blockWidth = 400
        local startX = (windowWidth - blockWidth) / 2


        imgui.SetCursorPosX((windowWidth - imgui.CalcTextSize(t("Info despre Hitmen Helper:")).x) / 2)
        imgui.TextColored(imgui.ImVec4(1.0, 1.0, 0.0, 1.0), t("Info despre Hitmen Helper:"))
        imgui.Spacing()

        local gethitcolor = imgui.ImVec4(0.67, 0.20, 0.20, 1.0)
        local remindercolor = imgui.ImVec4(1.0, 0.0, 0.0, 1.0)

        imgui.SetCursorPosX(startX)
        imgui.TextColored(gethitcolor, t("Auto Gethit:"))
        imgui.SameLine()
        imgui.Text(t(" Ia contractul si pune /undercover automat."))

        imgui.SetCursorPosX(startX)
        imgui.TextColored(remindercolor, t("Reminder:"))
        imgui.SameLine()
        imgui.Text(t(" Trimite notificare sa nu uiti de contracte."))

        imgui.SetCursorPosX(startX)
        imgui.TextColored(imgui.ImVec4(0.0, 1.0, 1.0, 1.0), t("Settings:"))
        imgui.SameLine()
        imgui.Text(t(" Personalizare teme, stiluri si opacitate."))

        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()

        -- Descriere Module (Checkboxes)
        imgui.SetCursorPosX((windowWidth - imgui.CalcTextSize(t("Module Active:")).x) / 2)
        imgui.TextColored(imgui.ImVec4(1.0, 0.5, 0.0, 1.0), t("Module Active:"))

        imgui.Spacing()

        local colorHitmen = imgui.ImVec4(0.67, 0.20, 0.20, 1.0)

        ---------------- Track ----------------
        imgui.SetCursorPosX(startX + 20)
        imgui.TextColored(colorHitmen, t("Track:"))
        imgui.SameLine()
        imgui.Text(t("Sistem avansat de urmarire tinta."))

        ---------------- The Silent One ----------------
        imgui.SetCursorPosX(startX + 20)
        imgui.TextColored(colorHitmen, t("TSO:"))
        imgui.SameLine()
        imgui.Text(t(" Mod de lucru discret (The Silent One)."))

        ---------------- Screenshot ----------------
        imgui.SetCursorPosX(startX + 20)
        imgui.TextColored(colorHitmen, t("Screenshot:"))
        imgui.SameLine()
        imgui.Text(t(" Captureaza automat dovezile contractului."))
        imgui.Spacing()

      -------------- Shortcuts imgui ----------------
        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()
          if imgui.Button(t("SHORTS"), imgui.ImVec2(-1, 35)) then
            shorts_window_state.v = not shorts_window_state.v
        end
        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()

      ------------------------ CREATOR CREDIT ------------------------
        local textStatic = "Created by "
        local textTag = "[TLG]"
        local textName = "allecsei"

        local totalWidth = imgui.CalcTextSize(textStatic .. textTag .. textName).x
        local windowWidth = imgui.GetWindowSize().x

        imgui.SetCursorPos(imgui.ImVec2((windowWidth - totalWidth) / 2, 595))

        imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), textStatic)
        imgui.SameLine(0, 0)

        imgui.TextColored(imgui.ImVec4(0.05, 0.80, 0.89, 1.00), textTag)
        imgui.SameLine(0, 0)

        imgui.TextColored(imgui.ImVec4(0.67, 0.20, 0.20, 1.00), textName)

    ------------------------ Close Menu ------------------------
        imgui.SetCursorPosY(565)
        if imgui.Button(t("Close Menu"), imgui.ImVec2(-1, 25)) then main_window_state.v = false end

        imgui.End()
    end
    ------------------------ Appearance  ------------------------
    if appearance_window_state.v then
        local sw, sh = getScreenResolution()
        local windowWidth = 350
        imgui.SetNextWindowPos(imgui.ImVec2(sw - windowWidth - 5, sh / 3), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(windowWidth, 350), imgui.Cond.FirstUseEver)
        imgui.Begin(t("Appearance Settings"), appearance_window_state, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

        imgui.Text(t("Themes Selector"))
        imgui.Separator()

        local themes_list = {t("Neon Cyber"), t("Volcano Fury"), t("Deep Ocean"), t("Royal Purple"), t("Forest Spirit")}
        if imgui.Combo(t("Select theme"), selected_theme, themes_list) then
            main_ini.appearance.theme = selected_theme.v
            inicfg.save(main_ini, direct_ini)
        end
        imgui.Spacing()
        imgui.Text(t("Window Styles"))
        imgui.Separator()

        local windowStyles = {t("Clasic"), t("Modern"), t("Compact"), t("Glass")}
        if imgui.Combo(t("Select style"), cWindowStyle, windowStyles) then
            main_ini.appearance.style = cWindowStyle.v
            inicfg.save(main_ini, direct_ini)

            local style = imgui.GetStyle()
            local ws = cWindowStyle.v

            if ws == 0 then -- Clasic
                style.WindowRounding = 8.0
                style.ChildWindowRounding = 6.0
                style.FrameRounding = 5.0
                style.ScrollbarRounding = 6.0
                style.GrabRounding = 5.0
            elseif ws == 1 then -- Modern Rotunjit
                style.WindowRounding = 15.0
                style.ChildWindowRounding = 12.0
                style.FrameRounding = 10.0
                style.ScrollbarRounding = 12.0
                style.GrabRounding = 10.0
            elseif ws == 2 then -- Compact
                style.WindowRounding = 3.0
                style.ChildWindowRounding = 2.0
                style.FrameRounding = 2.0
                style.ScrollbarRounding = 2.0
                style.GrabRounding = 2.0
            elseif ws == 3 then -- Glass
                style.WindowRounding = 20.0
                style.ChildWindowRounding = 15.0
                style.FrameRounding = 12.0
                style.ScrollbarRounding = 15.0
                style.GrabRounding = 12.0
            end
        end

        imgui.Spacing()
        if imgui.SliderFloat(t("Opacity"), menu_opacity, 0.1, 1.0) then
            main_ini.appearance.opacity = menu_opacity.v
            inicfg.save(main_ini, direct_ini)
        end
        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()
        imgui.TextColored(imgui.ImVec4(1.0, 0.2, 0.2, 1.0), t("Sniper Distance Protection"))
        imgui.Spacing()
        imgui.Separator()
        imgui.SliderInt(t("Distance"), sniper_dist_val, 150, 1000)
        imgui.Separator()
        imgui.Spacing()
        imgui.Text(t("Distanta setata: ") .. sniper_dist_val.v .. "m")
        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()
        if imgui.Button(t("Save Distance"), imgui.ImVec2(-1, 25)) then
        imgui.Spacing()
        imgui.Separator()
            main_ini.protection.min_dist = sniper_dist_val.v
            inicfg.save(main_ini, direct_ini)
            sampAddChatMessage("{5e150c}[Hitmen Helper]{FFFFFF} " .. t("Setarile Sniper Distance au fost salvate!"), -1)
        end

        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()
        if imgui.Button(t("Close"), imgui.ImVec2(-1, 25)) then appearance_window_state.v = false end
        imgui.Spacing()
        imgui.Separator()

        local textStatic = "Created by "
        local textTag = "[TLG]"
        local textName = "allecsei"

        local totalWidth = imgui.CalcTextSize(textStatic .. textTag .. textName).x
        local windowWidth = imgui.GetWindowSize().x

        imgui.SetCursorPos(imgui.ImVec2((windowWidth - totalWidth) / 2, 330))

        imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), textStatic)
        imgui.SameLine(0, 0)

        imgui.TextColored(imgui.ImVec4(0.05, 0.80, 0.89, 1.00), textTag)
        imgui.SameLine(0, 0)

        imgui.TextColored(imgui.ImVec4(0.67, 0.20, 0.20, 1.00), textName)
        imgui.End()
    end



----------------- shortcuts window -----------------
function reloadShortcutsFromINI()
    for _, v in ipairs(cmds_hitmen) do
        local key = v.cmd:gsub("/", "_")
        local iniValue = main_ini.shortcuts[key]
        if type(iniValue) ~= "boolean" then
            iniValue = true
            main_ini.shortcuts[key] = true
        end
        shortcut_states[key].v = iniValue
    end
    inicfg.save(main_ini, direct_ini)
end

if shorts_window_state.v then
    -- Reincarca setarile din INI la deschiderea ferestrei
    reloadShortcutsFromINI()
    imgui.SetNextWindowSize(imgui.ImVec2(550, 850), imgui.Cond.FirstUseEver)
    if imgui.Begin(t("Shortcuts List"), shorts_window_state, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then

        -- Butoane pentru Enable/Disable All
        if imgui.Button(t("Enable All"), imgui.ImVec2(265, 25)) then
            set_all_shortcuts(true)
        end
        imgui.SameLine()
        if imgui.Button(t("Disable All"), imgui.ImVec2(265, 25)) then
            set_all_shortcuts(false)
        end

        imgui.Separator()
        imgui.Spacing()

        imgui.BeginChild("CommandsRegion", imgui.ImVec2(0, -35), true)
            local windowWidth = imgui.GetContentRegionAvailWidth()
            local columnWidth = (windowWidth / 2) - 10

            for i = 1, #cmds_hitmen, 2 do
                imgui.BeginGroup()
                    DrawCmdRow(cmds_hitmen[i], columnWidth)
                imgui.EndGroup()

                if cmds_hitmen[i+1] then
                    imgui.SameLine(columnWidth + 20)
                    imgui.BeginGroup()
                        DrawCmdRow(cmds_hitmen[i+1], columnWidth)
                    imgui.EndGroup()
                end
                imgui.Separator()
            end
        imgui.EndChild()

        if imgui.Button(t("Close"), imgui.ImVec2(-1, 25)) then
            shorts_window_state.v = false
        end

        local textStatic = "Created by "
        local textTag = "[TLG]"
        local textName = "allecsei"

        local totalWidth = imgui.CalcTextSize(textStatic .. textTag .. textName).x
        local windowWidth = imgui.GetWindowSize().x

        imgui.SetCursorPos(imgui.ImVec2((windowWidth - totalWidth) / 2, 780))

        imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), textStatic)
        imgui.SameLine(0, 0)

        imgui.TextColored(imgui.ImVec4(0.05, 0.80, 0.89, 1.00), textTag)
        imgui.SameLine(0, 0)

        imgui.TextColored(imgui.ImVec4(0.67, 0.20, 0.20, 1.00), textName)

        imgui.End()
      end
    end
end

---------------------------- SAMP EVENTS ----------------------------

function sampev.onServerMessage(color, text)
    local playerName = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))

    -- ========================= AUTOFIND SECTION =========================
    if shortcut_states["autofind"] and shortcut_states["autofind"].v then
        -- Detect contract taken (English)
        if text:find("%* .+ took the contract on%: .+ %((%d+)%)") then
            local nickname, targetId = text:match("%* (.+) took the contract on%: .+ %((%d+)%)")
            if nickname == playerName then
                lua_thread.create(function()
                    wait(50)
                    sampSendChat("/find " .. targetId)
                    sampProcessChatInput("/track " .. targetId)
                end)
            end
        end

        -- Detect contract started (Romanian)
        if text:find("%* .+ a pornit spre asasinarea lui%: .+ %((%d+)%)") then
            local nickname, targetId = text:match("%* (.+) a pornit spre asasinarea lui%: .+ %((%d+)%)")
            if nickname == playerName then
                lua_thread.create(function()
                    wait(50)
                    sampSendChat("/find " .. targetId)
                    sampProcessChatInput("/track " .. targetId)
                    wait(676)
                    sampSendChat("/id " .. targetId)
                end)
            end
        end

        -- Undercover OFF notification
        if text:find("Undercover OFF") then
            lua_thread.create(function()
                wait(50)
                if english_state.v then
                    printStyledString("~w~Undercover ~r~OFF", 5000, 5)
                else
                    printStyledString("~w~Undercover-ul a fost ~r~inlaturat", 5000, 5)
                end
            end)
        end

        -- Undercover DEZACTIVAT notification
        if text:find("Undercover DEZACTIVAT") then
            lua_thread.create(function()
                wait(50)
                if english_state.v then
                    printStyledString("~w~Undercover ~r~OFF", 5000, 5)
                else
                    printStyledString("~w~Undercover-ul a fost ~r~inlaturat", 5000, 5)
                end
                sampProcessChatInput("/track")
            end)
        end
    end

    -- ========================= TSO (THE SILENT ONE) SECTION =========================
    if tso_state and tso_state.v then
        -- Romanian contract fulfillment
        if text:find("<< Asasinul (.+) a finalizat contractul pe (.+) de la (.+)m si a obtinut (.+)%$ >>") then
            lua_thread.create(function()
                wait(50)
                local nickname, target, dist, reward = text:match("<< Asasinul (.+) a finalizat contractul pe (.+) de la (.+)m si a obtinut (.+)%$ >>")
                if nickname == playerName then
                    sampProcessChatInput("/track")
                    if tonumber(dist) > 299 then
                        wait(200)
                        makeScreenshot()
                    end
                end
            end)
        end

        -- English contract fulfillment
        if text:find("<< Hitman (.+) has fulfilled the contract on (.+) from (.+)m and collected %$(.+) >>") then
            lua_thread.create(function()
                wait(50)
                local nickname, target, dist, reward = text:match("<< Hitman (.+) has fulfilled the contract on (.+) from (.+)m and collected %$(.+) >>")
                if nickname == playerName then
                    sampProcessChatInput("/track")
                    if tonumber(dist) > 299 then
                        wait(200)
                        makeScreenshot()
                    end
                end
            end)
        end
    end

    -- ========================= GETHIT COOLDOWN SECTION =========================
    if hitcooldown_state and hitcooldown_state.v then
        -- Agency waiting time over notification
        if text:find("%* Agentie%: Timpul tau de asteptare pentru gethit s%-a terminat%. Poti da gethit din nou%.") or
           text:find("%* Agency%: Your gethit waiting time is over%. You can now gethit again%.") then
            lua_thread.create(function()
                wait(50)
                local notifMsg = english_state.v and "Your waiting time for getting a new contract has ended. You can now get a new contract." or "Timpul tau de asteptare s-a incheiat. Poti lua un nou contract."
                showWindowsNotification(nil, "Agency Reminder", notifMsg)
            end)
        end

        -- Contract fulfillment handling (both languages)
        local nickname, target, dist, reward = text:match("<< Asasinul (.+) a finalizat contractul pe (.+) de la (%d+)m si a obtinut (.+)%$ >>") or
                                           text:match("<< Hitman (.+) has fulfilled the contract on (.+) from (%d+)m and collected %$(.+) >>")

        if nickname == playerName and dist then
            local distance = tonumber(dist)
            local waitTime = 0

            -- Determine cooldown based on distance
            if text:find("tinta s%-a sinucis") then
                waitTime = 300
            elseif distance >= 300 then
                waitTime = 0 -- No cooldown
            elseif distance >= 250 then
                waitTime = 300
            elseif distance >= 200 then
                waitTime = 600
            elseif distance >= 150 then
                waitTime = 900
            else
                waitTime = 900
            end

            if waitTime > 0 then
                lua_thread.create(function()
                    for i = waitTime, 0, -1 do
                        if i == 0 then
                            if english_state.v then
                                sampAddChatMessage("{aa3333}[Hitmen Helper]{ffffff} You can now gethit.", -1)
                                printStringNow("You can now ~g~gethit.", 2000)
                            else
                                sampAddChatMessage("{aa3333}[Hitmen Helper]{ffffff} Poti procura un nou contract. ({aa3333}gethit{ffffff})", -1)
                                printStringNow("Poti procura un nou ~g~contract.", 2000)
                            end
                        else
                            local timerMsg = english_state.v and ("Gethit time:~r~ " .. string.format("%02d:%02d", math.floor(i / 60), i % 60)) or ("Timp gethit:~r~ " .. string.format("%02d:%02d", math.floor(i / 60), i % 60))
                            printStringNow(timerMsg, 1000)
                        end
                        wait(1000)
                    end
                end)
            else
                -- Instant notification for distance >= 300
                if english_state.v then
                    printStringNow("You can now ~g~gethit.", 2000)
                else
                    printStringNow("Poti procura un nou ~g~contract.", 2000)
                end
            end
        end
    end
end