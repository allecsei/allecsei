local imgui = require 'imgui'
local vkeys = require 'vkeys'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local inicfg = require 'inicfg'
local memory = require "memory"
local events = require "lib.samp.events"
local bit = require "bit"

-- Config
local config_file = "ProCMDS.ini"
local config_path = getWorkingDirectory() .. "\\config\\" .. config_file

-- Default config organized by categories
local default_config = {
    -- CURSOR SETTINGS
    cursor = {
        figura = 99,
        radiusf = 30,
        sizeline = 3,
        r = 255,
        g = 255,
        b = 255,
        a = 255,
        active = false
    },
    -- RECOLORER HUD SETTINGS
    recolorer = {
        money = "4280179968",
        health = "4278190232",
        stars = "4278231295",
        armour = "4294967295",
        patron = "4278231295",
        hpHigh = "4294901760",
        hpLow = "4278231295",
        CHARHPR = "255",
        CHARHPG = "0",
        CHARHPB = "0",
        CHARHPR2 = "255",
        CHARHPG2 = "0",
        CHARHPB2 = "0"
    },
    -- CHECKPOINT BEAM SETTINGS
    checkpoint = {
        enabled = true,
        mode = "beam",
        beam_r = "255",
        beam_g = "30",
        beam_b = "30",
        beam_a = "255"
    },
    -- Marker Color
    marker = {
        red = 50,
        green = 205,
        blue = 50,
        alpha = 255
},
    -- THEME SETTINGS
    theme = {
        selected = 1,
        custom_bg_r = "0.10",
        custom_bg_g = "0.10",
        custom_bg_b = "0.10",
        custom_bg_a = "0.95",
        custom_btn_r = "0.20",
        custom_btn_g = "0.20",
        custom_btn_b = "0.20",
        custom_btn_a = "1.0",
        custom_btn_h_r = "0.30",
        custom_btn_h_g = "0.30",
        custom_btn_h_b = "0.30",
        custom_btn_h_a = "1.0",
        custom_btn_a_r = "0.40",
        custom_btn_a_g = "0.40",
        custom_btn_a_b = "0.40",
        custom_btn_a_a = "1.0",
        custom_text_r = "0.01",
        custom_text_g = "0.97",
        custom_text_b = "0.98",
        custom_text_a = "1.0"
    },
    -- AD (ANUNT) SETTINGS
    ad = {
        text = "Anunt aici - customizeaza din /cmds -> Special",
    }
}

-- Check if file exists, if not, create it and notify
if not doesFileExist(config_path) then
    print("[ProCMDS] Fisierul ini lipseste! Se creeaza acum...")
    -- Cream fisierul cu setarile default
    inicfg.save(default_config, config_file)
    
    -- Notificare in chat (daca SAMP este incarcat)
    lua_thread.create(function()
        while not isSampAvailable() do wait(100) end
        sampAddChatMessage("{FF0000}[ProCMDS] {FFFFFF}Fisierul {FFFF00}ProCMDS.ini {FFFFFF}a fost creat automat.", -1)
    end)
end

-- Load the actual config
local cfg = inicfg.load(default_config, config_file)

-- MARKER COLOR SETTINGS
local marker_r = tonumber(cfg.marker.red) or 50
local marker_g = tonumber(cfg.marker.green) or 205
local marker_b = tonumber(cfg.marker.blue) or 50
local marker_a = tonumber(cfg.marker.alpha) or 255

-- Helper function to save config easily
local function saveConfig()
    inicfg.save(cfg, config_file)
end

-- Interface state
local WinState = imgui.ImBool(false)
local SelectedTab = imgui.ImInt(1)
local SelectedTheme = imgui.ImInt(tonumber(cfg.theme.selected) or 1)

-- Cursor settings (RCC)
local cursorActive = cfg.cursor.active
if cursorActive == nil then cursorActive = false end
local figura = imgui.ImInt(tonumber(cfg.cursor.figura) or 99)
local radiusf = imgui.ImInt(tonumber(cfg.cursor.radiusf) or 30)
local sizeline = imgui.ImInt(tonumber(cfg.cursor.sizeline) or 3)
local cursorColor = imgui.ImFloat4(
    (tonumber(cfg.cursor.r) or 255)/255,
    (tonumber(cfg.cursor.g) or 255)/255,
    (tonumber(cfg.cursor.b) or 255)/255,
    (tonumber(cfg.cursor.a) or 255)/255
)
local aargb = 0xFFFFFFFF

-- Recolorer HUD color buffers (using imgui.ImColor for conversion)
local color_money = imgui.ImFloat4(imgui.ImColor(tonumber(cfg.recolorer.money) or 4280179968):GetFloat4())
local color_health = imgui.ImFloat4(imgui.ImColor(tonumber(cfg.recolorer.health) or 4278190232):GetFloat4())
local color_stars = imgui.ImFloat4(imgui.ImColor(tonumber(cfg.recolorer.stars) or 4278231295):GetFloat4())
local color_patron = imgui.ImFloat4(imgui.ImColor(tonumber(cfg.recolorer.patron) or 4278231295):GetFloat4())
local color_armour = imgui.ImFloat4(imgui.ImColor(tonumber(cfg.recolorer.armour) or 4294967295):GetFloat4())

local phr = tonumber(cfg.recolorer.CHARHPR) or 255
local phg = tonumber(cfg.recolorer.CHARHPG) or 0
local phb = tonumber(cfg.recolorer.CHARHPB) or 0
local phr2 = tonumber(cfg.recolorer.CHARHPR2) or 255
local phg2 = tonumber(cfg.recolorer.CHARHPG2) or 0
local phb2 = tonumber(cfg.recolorer.CHARHPB2) or 0

local color_phealth = imgui.ImFloat3(phr/255, phg/255, phb/255)
local color_phealth2 = imgui.ImFloat3(phr2/255, phg2/255, phb2/255)

-- Custom Color Buffers for Theme Picker (loaded from theme config)
local cust_bg = imgui.ImFloat4(
    tonumber(cfg.theme.custom_bg_r) or 0.10,
    tonumber(cfg.theme.custom_bg_g) or 0.10,
    tonumber(cfg.theme.custom_bg_b) or 0.10,
    tonumber(cfg.theme.custom_bg_a) or 0.95
)
local cust_btn = imgui.ImFloat4(
    tonumber(cfg.theme.custom_btn_r) or 0.20,
    tonumber(cfg.theme.custom_btn_g) or 0.20,
    tonumber(cfg.theme.custom_btn_b) or 0.20,
    tonumber(cfg.theme.custom_btn_a) or 1.0
)
local cust_text = imgui.ImFloat4(
    tonumber(cfg.theme.custom_text_r) or 0.01,
    tonumber(cfg.theme.custom_text_g) or 0.97,
    tonumber(cfg.theme.custom_text_b) or 0.98,
    tonumber(cfg.theme.custom_text_a) or 1.0
)

-- Ad (Anunt) Text Buffer
local ad_text_buffer = imgui.ImBuffer(cfg.ad.text or "Anunt aici", 256)

-- =============================================
-- CHECKPOINT BEAM SYSTEM (by mistus_)
-- =============================================
local cpBeamEnabled = cfg.checkpoint.enabled
if cpBeamEnabled == nil then cpBeamEnabled = true end
local cpMode = cfg.checkpoint.mode or "beam"

local cp = nil
local rcp = nil
local cpTex = nil
local cpFont = nil
local waypointTex = nil

-- Beam settings
local CP_PILLAR_HEIGHT = 380.0
local CP_SEGMENTS = 52
local CP_THICK_BOTTOM = 10
local CP_THICK_TOP = 3
-- Beam color
local CP_BEAM_R = tonumber(cfg.checkpoint.beam_r) or 255
local CP_BEAM_G = tonumber(cfg.checkpoint.beam_g) or 30
local CP_BEAM_B = tonumber(cfg.checkpoint.beam_b) or 30
local CP_BEAM_A = tonumber(cfg.checkpoint.beam_a) or 255

local cpBeamColor = imgui.ImFloat4(
    CP_BEAM_R / 255,
    CP_BEAM_G / 255,
    CP_BEAM_B / 255,
    CP_BEAM_A / 255
)
local CP_ALPHA_BOTTOM = 235
local CP_ALPHA_TOP = 3
local CP_GRADIENT_POW = 1.55
local CP_TOP_FADE_START = 0.85
local CP_TOP_FADE_POW = 2.4
local CP_BLOOM_MULT_1 = 3.2
local CP_BLOOM_MULT_2 = 2.0
local CP_BLOOM_ALPHA_1 = 0.16
local CP_BLOOM_ALPHA_2 = 0.28
local CP_CORE_ALPHA_MUL = 1.00
local CP_SCAN_ENABLED = true
local CP_SCAN_SPEED = 0.22
local CP_SCAN_WIDTH = 0.09
local CP_SCAN_STRENGTH_A = 85
local CP_SCAN_STRENGTH_T = 2
local CP_SCAN_SOFTNESS = 1.4
local CP_ICON_W, CP_ICON_H = 24, 24
local CP_FONT_SIZE = 14
local CP_DIST_TEXT_DY = 18
local CP_DIST_TEXT_DX = 10
local CP_OUTLINE_PX = 1

-- Checkpoint helper functions
local function cpNum(v) return tonumber(v) end

local function cpUnpackVec3(v)
    if type(v) ~= "table" then return nil end
    return cpNum(v.x or v[1]), cpNum(v.y or v[2]), cpNum(v.z or v[3])
end

local function cpExtractArgs(a, b, c, d)
    local x, y, z, r
    if type(a) == "table" then
        x, y, z = cpUnpackVec3(a)
        if type(b) == "table" then r = cpNum(b.radius or b.r or b[1]) else r = cpNum(b) end
    else
        x, y, z = cpNum(a), cpNum(b), cpNum(c)
        if type(d) == "table" then r = cpNum(d.radius or d.r or d[1]) else r = cpNum(d) end
    end
    if x and y and z then
        r = r or 3.0
        return x, y, z, r
    end
    return nil
end

local function cpDistTo(x, y, z)
    local px, py, pz = getCharCoordinates(PLAYER_PED)
    return math.sqrt((px - x)^2 + (py - y)^2 + (pz - z)^2)
end

local function cpIsInFront(wx, wy, wz)
    local a, b, c, d = convert3DCoordsToScreenEx(wx, wy, wz)
    if type(a) == "boolean" then
        if not a then return false end
        if d ~= nil then return d > 0 end
        return true
    else
        if d ~= nil then return d > 0 end
        return (a ~= nil and b ~= nil)
    end
end

local function cpWorldToScreen(wx, wy, wz)
    local sx, sy = convert3DCoordsToScreen(wx, wy, wz)
    if not sx or not sy then return false end
    if sx ~= sx or sy ~= sy then return false end
    return true, sx, sy
end

local function cpClamp01(x)
    if x < 0 then return 0 end
    if x > 1 then return 1 end
    return x
end

local function cpLerp(a, b, t)
    return a + (b - a) * t
end

local function cpSmoothstep(edge0, edge1, x)
    local t = cpClamp01((x - edge0) / (edge1 - edge0))
    return t * t * (3 - 2 * t)
end

local function cpArgb(a, r, g, b)
    a = math.floor(a + 0.5)
    if a < 0 then a = 0 elseif a > 255 then a = 255 end
    r = math.floor(r + 0.5)
    g = math.floor(g + 0.5)
    b = math.floor(b + 0.5)
    return bit.bor(bit.lshift(a, 24), bit.lshift(r, 16), bit.lshift(g, 8), b)
end

local function cpDrawOutlinedText(fnt, text, x, y)
    local outlineCol = 0xFF000000
    local mainColTag = "{b4FFFFFF}"
    renderFontDrawText(fnt, text, x - CP_OUTLINE_PX, y, outlineCol)
    renderFontDrawText(fnt, text, x + CP_OUTLINE_PX, y, outlineCol)
    renderFontDrawText(fnt, text, x, y - CP_OUTLINE_PX, outlineCol)
    renderFontDrawText(fnt, text, x, y + CP_OUTLINE_PX, outlineCol)
    renderFontDrawText(fnt, mainColTag .. text, x, y)
end

local function cpScanIntensity(p, timeSec)
    local center = (timeSec * CP_SCAN_SPEED) % 1.0
    local d = math.abs(p - center)
    if d > 0.5 then d = 1.0 - d end
    local w = CP_SCAN_WIDTH * 0.5
    if d >= w then return 0.0 end
    local t = 1.0 - (d / w)
    t = math.pow(t, CP_SCAN_SOFTNESS)
    return t
end

local function cpDrawDistanceAtBase(x, y, z)
    if not cpFont then return end
    local baseZ = z + 1.0
    if not cpIsInFront(x, y, baseZ) then return end
    local ok, sx, sy = cpWorldToScreen(x, y, baseZ)
    if not ok then return end
    local d = cpDistTo(x, y, z)
    cpDrawOutlinedText(cpFont, string.format("%.0f m", d), sx + CP_DIST_TEXT_DX, sy + CP_DIST_TEXT_DY)
end

local function cpDrawIconWithDistance(x, y, z)
    if not cpIsInFront(x, y, z) then return end
    local ok, sx, sy = cpWorldToScreen(x, y, z)
    if not ok then return end
    if waypointTex then
        renderDrawTexture(waypointTex, sx, sy, CP_ICON_W, CP_ICON_H, 0, -1)
    end
    local d = cpDistTo(x, y, z)
    if cpFont then
        cpDrawOutlinedText(cpFont, string.format("%.0f m", d), sx, sy + CP_DIST_TEXT_DY)
    end
end

local function cpDrawBeamCSAPlus(x, y, z)
    local baseZ = z + 1.0
    local height = CP_PILLAR_HEIGHT
    if not cpIsInFront(x, y, baseZ) then return end
    local timeSec = os.clock()
    local dz = height / CP_SEGMENTS
    for i = 0, CP_SEGMENTS - 1 do
        local p = i / CP_SEGMENTS
        local z0 = baseZ + dz * i
        local z1 = baseZ + dz * (i + 1)
        if cpIsInFront(x, y, z0) and cpIsInFront(x, y, z1) then
            local ok0, sx0, sy0 = cpWorldToScreen(x, y, z0)
            local ok1, sx1, sy1 = cpWorldToScreen(x, y, z1)
            if ok0 and ok1 then
                local thickCore = cpLerp(CP_THICK_BOTTOM, CP_THICK_TOP, p)
                local g = math.pow(1.0 - p, CP_GRADIENT_POW)
                local a = cpLerp(CP_ALPHA_TOP, CP_ALPHA_BOTTOM, g)
                if p >= CP_TOP_FADE_START then
                    local s = cpSmoothstep(CP_TOP_FADE_START, 1.0, p)
                    local extra = math.pow(1.0 - s, CP_TOP_FADE_POW)
                    a = a * extra
                end
                if CP_SCAN_ENABLED then
                    local sI = cpScanIntensity(p, timeSec)
                    if sI > 0 then
                        a = a + (CP_SCAN_STRENGTH_A * sI)
                        thickCore = thickCore + (CP_SCAN_STRENGTH_T * sI)
                    end
                end
                if a < 0 then a = 0 elseif a > 255 then a = 255 end
                local a1 = a * CP_BLOOM_ALPHA_1
                local c1 = cpArgb(a1, CP_BEAM_R, CP_BEAM_G, CP_BEAM_B)
                renderDrawLine(sx0, sy0, sx1, sy1, math.floor(thickCore * CP_BLOOM_MULT_1 + 0.5), c1)
                local a2 = a * CP_BLOOM_ALPHA_2
                local c2 = cpArgb(a2, CP_BEAM_R, CP_BEAM_G, CP_BEAM_B)
                renderDrawLine(sx0, sy0, sx1, sy1, math.floor(thickCore * CP_BLOOM_MULT_2 + 0.5), c2)
                local c3 = cpArgb(a * CP_CORE_ALPHA_MUL, CP_BEAM_R, CP_BEAM_G, CP_BEAM_B)
                renderDrawLine(sx0, sy0, sx1, sy1, math.floor(thickCore + 0.5), c3)
            end
        end
    end
end

local function cpDrawBasePulseImage(x, y, z)
    if not cpTex then return end
    local baseZ = z + 1.0
    if not cpIsInFront(x, y, baseZ) then return end
    local ok, sx, sy = cpWorldToScreen(x, y, baseZ)
    if not ok then return end
    local t = os.clock()
    local pulse = (math.sin(t * 4.0) + 1.0) * 0.5
    local size = 16 + pulse * 8
    renderDrawTexture(cpTex, sx - 1, sy, size, size, 0, -1)
    renderDrawTexture(cpTex, sx + 1, sy, size, size, 0, -1)
    renderDrawTexture(cpTex, sx, sy - 1, size, size, 0, -1)
    renderDrawTexture(cpTex, sx, sy + 1, size, size, 0, -1)
    renderDrawTexture(cpTex, sx, sy, size, size, 0, -1)
end

local function cpDrawTarget(x, y, z)
    if cpMode == "beam" then
        cpDrawBeamCSAPlus(x, y, z)
        cpDrawDistanceAtBase(x, y, z)
        cpDrawBasePulseImage(x, y, z)
    else
        cpDrawIconWithDistance(x, y, z)
    end
end

-- SA-MP Checkpoint Events
function events.onSetCheckpoint(a, b, c, d)
    local x, y, z, r = cpExtractArgs(a, b, c, d)
    if not x then return end
    cp = { x = x, y = y, z = z, r = r }
end

function events.onDisableCheckpoint()
    cp = nil
end

function events.onSetRaceCheckpoint(type_, a, b, c, nextX, nextY, nextZ, radius)
    local x, y, z, r = cpExtractArgs(a, b, c, radius)
    if not x then x, y, z, r = cpExtractArgs(a, radius, nil, nil) end
    if not x then return end
    rcp = { type = type_, x = x, y = y, z = z, r = r }
end

function events.onDisableRaceCheckpoint()
    rcp = nil
end

function applyMarkerColor()
    local r = marker_r
    local g = marker_g
    local b = marker_b
    local a = marker_a

    -- Set 1
    memory.write(7392527, r, 4, true)
    memory.write(7392525, g, 1, true)
    memory.write(7392523, b, 1, true)
    memory.write(7392518, a, 4, true)

    -- Set 2
    memory.write(7392604, r, 4, true)
    memory.write(7392602, g, 1, true)
    memory.write(7392600, b, 1, true)
    memory.write(7392595, a, 4, true)

    -- Set 3
    memory.write(7392687, r, 4, true)
    memory.write(7392685, g, 1, true)
    memory.write(7392683, b, 1, true)
    memory.write(7392678, a, 4, true)

    -- HEX
    memory.write(0x48110F, r, 4, true)
    memory.write(0x48110B, g, 1, true)
    memory.write(0x48110D, b, 1, true)
    memory.write(0x481106, a, 4, true)
end

-- Theme definitions
local Themes = {
    { name = "Classic", WindowBg = imgui.ImVec4(0.10,0.10,0.10,0.95), Button = imgui.ImVec4(0.20,0.20,0.20,1), ButtonHovered = imgui.ImVec4(0.30,0.30,0.30,1), ButtonActive = imgui.ImVec4(0.40,0.40,0.40,1) },
    { name = "Crimson", WindowBg = imgui.ImVec4(0.12,0.02,0.03,0.95), Button = imgui.ImVec4(0.70,0.05,0.10,1.0), ButtonHovered = imgui.ImVec4(0.85,0.10,0.15,1.0), ButtonActive = imgui.ImVec4(1.00,0.20,0.25,1.0) },
    { name = "Sunset", WindowBg = imgui.ImVec4(0.20,0.08,0.03,0.95), Button = imgui.ImVec4(0.95,0.40,0.10,1.0), ButtonHovered = imgui.ImVec4(1.00,0.55,0.20,1.0), ButtonActive = imgui.ImVec4(1.00,0.70,0.35,1.0) },
    { name = "Ice Mint", WindowBg = imgui.ImVec4(0.06,0.12,0.12,0.95), Button = imgui.ImVec4(0.00,0.70,0.60,1.0), ButtonHovered = imgui.ImVec4(0.20,0.90,0.75,1.0), ButtonActive = imgui.ImVec4(0.40,1.00,0.85,1.0) },
    { name = "Fantasy", WindowBg = imgui.ImVec4(0.07,0.04,0.14,0.95), Button = imgui.ImVec4(0.50,0.00,0.80,1.0), ButtonHovered = imgui.ImVec4(0.70,0.20,1.00,1.0), ButtonActive = imgui.ImVec4(0.20,0.50,1.00,1.0) },
    { name = "Cyberpunk", WindowBg = imgui.ImVec4(0.05,0.00,0.10,0.95), Button = imgui.ImVec4(1.00,0.00,0.60,1.0), ButtonHovered = imgui.ImVec4(1.00,0.20,0.80,1.0), ButtonActive = imgui.ImVec4(0.00,1.00,0.90,1.0) },
    { name = "Midnight", WindowBg = imgui.ImVec4(0.01,0.02,0.08,0.95), Button = imgui.ImVec4(0.10,0.25,0.80,1.0), ButtonHovered = imgui.ImVec4(0.20,0.40,1.00,1.0), ButtonActive = imgui.ImVec4(0.35,0.55,1.00,1.0) },
    { name = "Matrix Green", WindowBg = imgui.ImVec4(0.02, 0.06, 0.02, 0.98), Button = imgui.ImVec4(0.00, 0.59, 0.00, 0.59), ButtonHovered = imgui.ImVec4(0.00, 1.00, 0.00, 0.63), ButtonActive = imgui.ImVec4(0.00, 0.51, 0.00, 0.98) },
    { name = "Toxic Lime", WindowBg = imgui.ImVec4(0.06, 0.10, 0.02, 0.96), Button = imgui.ImVec4(0.55, 0.78, 0.00, 0.59), ButtonHovered = imgui.ImVec4(0.78, 1.00, 0.20, 0.63), ButtonActive = imgui.ImVec4(0.47, 0.71, 0.00, 0.98) },
    { name = "Neon Magenta", WindowBg = imgui.ImVec4(0.12, 0.02, 0.12, 0.96), Button = imgui.ImVec4(0.78, 0.00, 0.78, 0.59), ButtonHovered = imgui.ImVec4(1.00, 0.20, 1.00, 0.63), ButtonActive = imgui.ImVec4(0.71, 0.00, 0.71, 0.98) },
    { name = "Silver Steel", WindowBg = imgui.ImVec4(0.10, 0.11, 0.13, 0.97), Button = imgui.ImVec4(0.47, 0.51, 0.57, 0.59), ButtonHovered = imgui.ImVec4(0.67, 0.71, 0.78, 0.63), ButtonActive = imgui.ImVec4(0.39, 0.43, 0.49, 0.98) },
    { name = "Volcano Red", WindowBg = imgui.ImVec4(0.14, 0.04, 0.02, 0.96), Button = imgui.ImVec4(0.71, 0.24, 0.08, 0.59), ButtonHovered = imgui.ImVec4(0.98, 0.39, 0.16, 0.63), ButtonActive = imgui.ImVec4(0.63, 0.20, 0.04, 0.98) },
    { name = "Rose", WindowBg = imgui.ImVec4(0.18,0.08,0.12,0.95), Button = imgui.ImVec4(0.75,0.25,0.40,1.0), ButtonHovered = imgui.ImVec4(0.85,0.35,0.50,1.0), ButtonActive = imgui.ImVec4(0.95,0.45,0.60,1.0) },
    { name = "Graphite", WindowBg = imgui.ImVec4(0.08,0.08,0.09,0.95), Button = imgui.ImVec4(0.18,0.18,0.20,1.0), ButtonHovered = imgui.ImVec4(0.28,0.28,0.30,1.0), ButtonActive = imgui.ImVec4(0.38,0.38,0.40,1.0) },
    { name = "Purple Void", WindowBg = imgui.ImVec4(0.06,0.04,0.10,0.95), Button = imgui.ImVec4(0.20,0.10,0.30,1.0), ButtonHovered = imgui.ImVec4(0.35,0.20,0.50,1.0), ButtonActive = imgui.ImVec4(0.50,0.30,0.70,1.0) },
    { name = "Custom" }
}

local function ApplyTheme()
    local idx = SelectedTheme.v
    local bg, btn, btnH, btnA

    if Themes[idx].name == "Custom" then
        bg = imgui.ImVec4(cust_bg.v[1], cust_bg.v[2], cust_bg.v[3], cust_bg.v[4])
        btn = imgui.ImVec4(cust_btn.v[1], cust_btn.v[2], cust_btn.v[3], cust_btn.v[4])
        btnH = imgui.ImVec4(cust_btn.v[1]+0.1, cust_btn.v[2]+0.1, cust_btn.v[3]+0.1, cust_btn.v[4])
        btnA = imgui.ImVec4(cust_btn.v[1]+0.2, cust_btn.v[2]+0.2, cust_btn.v[3]+0.2, cust_btn.v[4])
    else
        local theme = Themes[idx]
        bg, btn, btnH, btnA = theme.WindowBg, theme.Button, theme.ButtonHovered, theme.ButtonActive
    end

    imgui.PushStyleColor(imgui.Col.WindowBg, bg)
    imgui.PushStyleColor(imgui.Col.Button, btn)
    imgui.PushStyleColor(imgui.Col.ButtonHovered, btnH)
    imgui.PushStyleColor(imgui.Col.ButtonActive, btnA)
end

local function PopTheme()
    imgui.PopStyleColor(4)
end

-- Helper function to save config
local function saveConfig()
    inicfg.save(cfg, config_file)
end

-- Shortcut functions
function cf() sampSendChat("/cancel find") end
function fd(id)
    sampSendChat("/find " .. id)
end
function kc() sampSendChat("/killcp") end
function ex() sampSendChat("/exit") end
function ee() sampSendChat("/enter") end
function ref() sampSendChat("/refill") end
function rep() sampSendChat("/repair") end
function st() sampSendChat("/stats") end

function bg()
    lua_thread.create(function()
        sampSendChat("/buygun deagle 100")
        sampSendChat("/buygun m4 200")
        sampSendChat("/buygun rifle 100")
    end)
end
function sal()
    lua_thread.create(function()
        sampSendChat("/f Sanatate! ")
        sampSendChat("/c Salutare!")
        sampSendChat("/ac Salut!")
    end)
end
function nb()
    lua_thread.create(function()
        sampSendChat("/f Noapte buna! Spor la joc! ")
        sampSendChat("/c Am iesit, noapte buna!")
        sampSendChat("/ac Noapte buna!")
    end)
end
function sa() sampSendChat("/stopanim") end
function en() sampSendChat("/engine") end
function co() sampSendChat("/costumes") end
function cmb() sampSendChat("/clanmembers") end
function mb() sampSendChat("/members") end
function cx() sampSendChat("/clanxp") end
function ct() sampSendChat("/clanturfs") end
function cdt() sampSendChat("/clanduty") end
function missm() sampSendChat("/missed messages") end
function missc() sampSendChat("/missed calls") end
function gj() sampSendChat("/getjob") end
function ha() sampSendChat("/heal") end
function ntf() sampSendChat("/notifications") end
function czs() sampSendChat("/clanzones") end
function li() sampSendChat("/lights") end
function ins() sampSendChat("/buyinsurance") end
function staxi() sampSendChat("/service taxi") end
function smech() sampSendChat("/service towtruck") end
function smedic() sampSendChat("/service medic") end
function ctaxi() sampSendChat("/cancel taxi") end
function cmedic() sampSendChat("/cancel medic") end
function cmech() sampSendChat("/cancel towtruck") end
function emer() sampSendChat("/emergency") end
function svc() sampSendChat("/servicecalls") end
function jbc() sampSendChat("/jobclash") end
function ra() sampSendChat("/raport") end
function sp() sampSendChat("/spawnchange") end
function bk() sampSendChat("/bunker") end
function mybk() sampSendChat("/mybunker") end
function cnbk() sampSendChat("/cancel bunker") end
function afvr()
    lua_thread.create(function()
        sampSendChat("/f FVR in 10 seconds.")
        wait(10000)
        sampSendChat("/fvr")
        sampSendChat("/f Done.")
    end)
end

function cmc()
    lua_thread.create(function()
    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)
	    sampAddChatMessage(" ", -1)

    end)
end

-- AD (Anunt) function for CNN
function sendAd()
    local ad_text = cfg.ad.text or "Anunt aici"
    if ad_text ~= "" then
        sampSendChat("/ad " .. ad_text)
        sampAddChatMessage("{00FF00}[ProCMDS] {FFFFFF}Anunt trimis: " .. ad_text, -1)
    else
        sampAddChatMessage("{FF0000}[ProCMDS] {FFFFFF}Anuntul este gol! Configureaza din /cmds -> Special", -1)
    end
end

local function DrawCmdRow(cmd, desc)
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(cust_text.v[1], cust_text.v[2], cust_text.v[3], cust_text.v[4]))
    imgui.Text("/" .. cmd)
    imgui.PopStyleColor()
    imgui.SameLine(120)
    imgui.TextColored(imgui.ImVec4(0.7,0.7,0.7,1), "->")
    imgui.SameLine(150)
    imgui.Text(u8(desc))
    imgui.Separator()
end

-- Cursor Helper Functions (RCC)
function join_argb(a, r, g, b)
    local argb = b
    argb = bit.bor(argb, bit.lshift(g, 8))
    argb = bit.bor(argb, bit.lshift(r, 16))
    argb = bit.bor(argb, bit.lshift(a, 24))
    return argb
end

function renderFigure2D(x, y, points, radius, color)
    local step = math.pi * 2 / points
    local render_start, render_end = {}, {}

    for i = 0, math.pi * 2, step do
        render_start[1] = radius * math.cos(i) + x
        render_start[2] = radius * math.sin(i) + y
        render_end[1] = radius * math.cos(i + step) + x
        render_end[2] = radius * math.sin(i + step) + y

        renderDrawLine(render_start[1], render_start[2], render_end[1], render_end[2], sizeline.v, color)
    end
end

-- Recolorer Functions
function setHealthColor(hpHigh, hpLow)
    local samp = getModuleHandle("samp.dll")
    if samp then
        memory.setuint32(samp + 0x68B0C, hpHigh, true)
        memory.setuint32(samp + 0x68B33, hpLow, true)
    end
end

function initRecolorerColors()
    -- Apply memory values for HUD
    local money = tonumber(cfg.recolorer.money) or 4280179968
    local health = tonumber(cfg.recolorer.health) or 4278190232
    local stars = tonumber(cfg.recolorer.stars) or 4278231295
    local armour = tonumber(cfg.recolorer.armour) or 4294967295
    local patron = tonumber(cfg.recolorer.patron) or 4278231295

    memory.write(0xBAB230, money, 4, false)
    memory.write(0xBAB22C, health, 4, false)
    memory.write(0xBAB244, stars, 4, false)
    memory.write(0xBAB23C, armour, 4, false)
    memory.write(0xBAB238, patron, 4, false)

    -- Apply SA-MP health bar colors
    local hpHigh = tonumber(cfg.recolorer.hpHigh) or 4294901760
    local hpLow = tonumber(cfg.recolorer.hpLow) or 4278231295
    setHealthColor(hpHigh, hpLow)
end

-- Marker Color init (moved message to main() function)
lua_thread.create(function()
    while not isSampAvailable() do wait(100) end
    sampAddChatMessage("{8000CC}[ProCMDS]{FFFFFF} Marker Color applied from config!", -1)
    while true do
        wait(1000)
        applyMarkerColor()
    end
end)

local sw, sh = getScreenResolution()

-- IMGUI DRAW FRAME
function imgui.OnDrawFrame()
    if not WinState.v then
        imgui.Process = false
        return
    end

    ApplyTheme()

    imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(720, 480), imgui.Cond.FirstUseEver)

    imgui.Begin("##MenuWindow", WinState, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)

    local winWidth = imgui.GetWindowSize().x
    local winHeight = imgui.GetWindowSize().y

    local title = u8"Complex Operations Hub"
    local textWidth = imgui.CalcTextSize(title).x
    imgui.SetCursorPosY(5)
    imgui.SetCursorPosX((winWidth - textWidth)/2)
    imgui.TextColored(imgui.ImVec4(1,1,1,1), title)

    imgui.SameLine(winWidth - 25)
    if imgui.Button(u8"X", imgui.ImVec2(20,20)) then
        WinState.v = false
    end

    imgui.BeginGroup()
    local tabs = {"General","Clan","Jobs & Stats","Services","Special","Checkpoint Mode","Cursor Click","Recolorer HUD","Themes"}
    for i, name in ipairs(tabs) do
        local isSelected = SelectedTab.v == i
        if isSelected then
            imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonActive])
        end
        if imgui.Button(u8(name), imgui.ImVec2(130,40)) then
            SelectedTab.v = i
        end
        if isSelected then imgui.PopStyleColor() end
    end
    imgui.SetCursorPosY(395)
    imgui.SetCursorPos(imgui.ImVec2(10, winHeight - 25))
    imgui.TextColored(imgui.ImVec4(1,1,1,1), u8"Created by allecsei")
    imgui.EndGroup()

    imgui.SameLine()
    imgui.BeginChild("ContentArea", imgui.ImVec2(0,0), true)

    if SelectedTab.v == 1 then
        imgui.TextColored(imgui.ImVec4(1,1,1,1), u8"GENERAL COMMANDS")
        imgui.Spacing()
        DrawCmdRow("sal","Salut Global")
        DrawCmdRow("nb","Noapte buna Global")
        DrawCmdRow("st","Stats")
        DrawCmdRow("cf","Cancel Find")
        DrawCmdRow("fd","Find [id] ")
        DrawCmdRow("kc","Kill Checkpoint")
        DrawCmdRow("ex/ee","Exit / Enter")
        DrawCmdRow("rep/ref","Repair + Refill")
        DrawCmdRow("sa","Stop Animation")
        DrawCmdRow("en","Engine Toggle")
        DrawCmdRow("li","Lights Toggle")
        DrawCmdRow("co","Costumes Menu")
        DrawCmdRow("ra","Raport")
        DrawCmdRow("ins","Buyinsurance")
        DrawCmdRow("sp","Spawnchange")
        DrawCmdRow("cmc","Clear Your Chat")
    elseif SelectedTab.v == 2 then
        imgui.TextColored(imgui.ImVec4(1,1,1,1), u8"CLAN SYSTEM")
        imgui.Spacing()
        DrawCmdRow("cmb","Clan Members")
        DrawCmdRow("mb","Faction Members")
        DrawCmdRow("cx","Clan XP")
        DrawCmdRow("ct","Clan Turfs")
        DrawCmdRow("cdt","Clan Duty")
        DrawCmdRow("czs","Clan Zones")
        DrawCmdRow("afvr","FVR Countdown (10s)")
    elseif SelectedTab.v == 3 then
        imgui.TextColored(imgui.ImVec4(1,1,1,1), u8"JOBS & STATUS")
        imgui.Spacing()
        DrawCmdRow("gj","Get Job")
        DrawCmdRow("jbc","Job Clash")
        DrawCmdRow("ha","Heal")
        DrawCmdRow("ntf","Notifications")
        DrawCmdRow("missm","Missed Messages")
        DrawCmdRow("missc","Missed Calls")
        DrawCmdRow("bk","Bunker")
        DrawCmdRow("mybk","MyBunker")
        DrawCmdRow("cnbk","Cancel Bunker")
    elseif SelectedTab.v == 4 then
        imgui.TextColored(imgui.ImVec4(1,1,1,1), u8"SERVICES & EMERGENCY")
        imgui.Spacing()
        DrawCmdRow("staxi","Service Taxi")
        DrawCmdRow("smech","Service TowTruck")
        DrawCmdRow("smedic","Service Medic")
        imgui.Spacing()
        DrawCmdRow("ctaxi","Cancel Taxi")
        DrawCmdRow("cmech","Cancel TowTruck")
        DrawCmdRow("cmedic","Cancel Medic")
        imgui.Spacing()
        DrawCmdRow("emer","Emergency Chat")
        DrawCmdRow("svc","Service Calls")
    elseif SelectedTab.v == 5 then
        imgui.TextColored(imgui.ImVec4(1,1,1,1), u8"COMBAT / PACKS")
        imgui.Spacing()
        DrawCmdRow("bg","BuyGun Pack (Deagle/M4/Rifle)")
        imgui.Spacing()
        imgui.Separator()

        -- AD (Anunt) Customization Section
        imgui.TextColored(imgui.ImVec4(0, 1, 0.8, 1), u8"CNN AD SYSTEM")
        imgui.Separator()
        imgui.Spacing()

        imgui.Text(u8"Scrie textul pentru anunt:")
        imgui.PushItemWidth(400)
        if imgui.InputText("##adtext", ad_text_buffer) then
            cfg.ad.text = u8:decode(ad_text_buffer.v)
            saveConfig()
        end
        imgui.PopItemWidth()

        imgui.Spacing()

        -- Preview button
        if imgui.Button(u8"Preview Ad", imgui.ImVec2(100, 25)) then
            sampAddChatMessage("{FFDEAD}[AD PREVIEW] {FFFFFF}" .. cfg.ad.text, -1)
        end
        imgui.SameLine()

        -- Send button
        if imgui.Button(u8"Trimite Acum", imgui.ImVec2(120, 25)) then
            sampSendChat("/ad " .. cfg.ad.text)
        end

        imgui.Spacing()
        imgui.Separator()
        imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), u8"Cum sa folosesti:")
        imgui.BulletText(u8"Scrie textul anuntului in casuta de mai sus")
        imgui.BulletText(u8"Foloseste /add in chat pentru a trimite automat")
        imgui.BulletText(u8"Sau apasa 'Trimite Acum' din acest meniu")
        imgui.Spacing()
        DrawCmdRow("add", "Trimite anuntul preset la CNN")

    elseif SelectedTab.v == 6 then
        -- CHECKPOINT BEAM SECTION (Now in its own tab)
        imgui.TextColored(imgui.ImVec4(1, 0.3, 0.3, 1), u8"CHECKPOINT BEAM SETTINGS")
        imgui.Separator()
        imgui.Spacing()

        -- Status and Toggle
        local cpStatusText = cpBeamEnabled and u8"ON" or u8"OFF"
        local cpStatusColor = cpBeamEnabled and imgui.ImVec4(0,1,0,1) or imgui.ImVec4(1,0,0,1)
        imgui.Text(u8"Status: ")
        imgui.SameLine()
        imgui.TextColored(cpStatusColor, cpStatusText)
        imgui.SameLine(200)
        if imgui.Button(cpBeamEnabled and u8"Disable Beam" or u8"Enable Beam", imgui.ImVec2(120, 25)) then
            cpBeamEnabled = not cpBeamEnabled
            cfg.checkpoint.enabled = cpBeamEnabled
            saveConfig()
            local status = cpBeamEnabled and "ON" or "OFF"
            sampAddChatMessage("{FF3030}[CP BEAM] {FFFFFF}Checkpoint beam: " .. status, -1)
        end

        imgui.Spacing()

        -- Mode selector
        imgui.Text(u8"Mode: ")
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(1,1,0,1), cpMode == "beam" and u8"BEAM" or u8"ICON")
        imgui.SameLine(200)
        if imgui.Button(u8"Beam", imgui.ImVec2(55, 25)) then
            cpMode = "beam"
            cfg.checkpoint.mode = "beam"
            saveConfig()
        end
        imgui.SameLine()
        if imgui.Button(u8"Icon", imgui.ImVec2(55, 25)) then
            cpMode = "icon"
            cfg.checkpoint.mode = "icon"
            saveConfig()
        end
        imgui.Spacing()
        imgui.Separator()
        imgui.TextColored(imgui.ImVec4(0, 1, 1, 1), u8"Beam Color")

        if imgui.ColorEdit4("##beamcolor", cpBeamColor) then
          CP_BEAM_R = math.floor(cpBeamColor.v[1] * 255)
          CP_BEAM_G = math.floor(cpBeamColor.v[2] * 255)
          CP_BEAM_B = math.floor(cpBeamColor.v[3] * 255)
          CP_BEAM_A = math.floor(cpBeamColor.v[4] * 255)
            cfg.checkpoint.beam_r = tostring(CP_BEAM_R)
            cfg.checkpoint.beam_g = tostring(CP_BEAM_G)
            cfg.checkpoint.beam_b = tostring(CP_BEAM_B)
            cfg.checkpoint.beam_a = tostring(CP_BEAM_A)
            saveConfig()
        end
        imgui.Spacing()
        imgui.Separator()
        imgui.TextColored(imgui.ImVec4(0.5, 1, 0.5, 1), u8"Marker Color")

        -- buffer culoare
        local markerColor = imgui.ImFloat4(
         marker_r / 255,
         marker_g / 255,
         marker_b / 255,
         marker_a / 255
        )

        if imgui.ColorEdit4("##markercolor", markerColor) then
         marker_r = math.floor(markerColor.v[1] * 255)
         marker_g = math.floor(markerColor.v[2] * 255)
         marker_b = math.floor(markerColor.v[3] * 255)
        marker_a = math.floor(markerColor.v[4] * 255)

         cfg.marker.red = tostring(marker_r)
         cfg.marker.green = tostring(marker_g)
         cfg.marker.blue = tostring(marker_b)
         cfg.marker.alpha = tostring(marker_a)

        saveConfig()

        applyMarkerColor()
        end
        imgui.Spacing()
        imgui.Separator()
        imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), u8"Cum sa folosesti:")
        imgui.BulletText(u8"Beam: Efect vizual CSA-like pentru checkpoint")
        imgui.BulletText(u8"Icon: Afiseaza doar iconita cu distanta")
        imgui.BulletText(u8"Foloseste /cp pentru toggle rapid")
        imgui.BulletText(u8"/cp mode beam sau /cp mode icon")
        imgui.Spacing()
        DrawCmdRow("cp", "Toggle checkpoint beam on/off")

    elseif SelectedTab.v == 7 then
        -- CURSOR HELP TAB (RCC Integration)
        imgui.TextColored(imgui.ImVec4(0, 1, 0.8, 1), u8"CURSOR CLICK EFFECT")
        imgui.Separator()
        imgui.Spacing()

        -- Toggle cursor
        local cursorStatusText = cursorActive and u8"ON" or u8"OFF"
        local cursorStatusColor = cursorActive and imgui.ImVec4(0,1,0,1) or imgui.ImVec4(1,0,0,1)
        imgui.Text(u8"Status: ")
        imgui.SameLine()
        imgui.TextColored(cursorStatusColor, cursorStatusText)
        imgui.SameLine(200)
        if imgui.Button(cursorActive and u8"Disable Cursor" or u8"Enable Cursor", imgui.ImVec2(150, 25)) then
            cursorActive = not cursorActive
            cfg.cursor.active = cursorActive
            saveConfig()
            if not cursorActive then
                sampToggleCursor(false)
            end
        end

        imgui.Spacing()
        imgui.Separator()
        imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), u8"Cursor Settings:")
        imgui.Spacing()

        -- Sliders
        if imgui.SliderInt(u8"Points", figura, 2, 99) then
            cfg.cursor.figura = figura.v
            saveConfig()
        end
        if imgui.SliderInt(u8"Radius", radiusf, 10, 30) then
            cfg.cursor.radiusf = radiusf.v
            saveConfig()
        end
        if imgui.SliderInt(u8"Line Size", sizeline, 1, 10) then
            cfg.cursor.sizeline = sizeline.v
            saveConfig()
        end

        if imgui.ColorEdit4(u8"Click Color", cursorColor) then
            cfg.cursor.r = math.floor(cursorColor.v[1] * 255)
            cfg.cursor.g = math.floor(cursorColor.v[2] * 255)
            cfg.cursor.b = math.floor(cursorColor.v[3] * 255)
            cfg.cursor.a = math.floor(cursorColor.v[4] * 255)
            aargb = join_argb(cfg.cursor.a, cfg.cursor.r, cfg.cursor.g, cfg.cursor.b)
            saveConfig()
        end

        imgui.Spacing()
        imgui.Separator()
        imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), u8"How to Use:")
        imgui.BulletText(u8"/rcc - Toggle cursor click effect on/off")
        imgui.BulletText(u8"When enabled, clicking shows animated effect")
        imgui.BulletText(u8"Points: 2=line, 3=triangle, 99=circle")
        imgui.BulletText(u8"Radius: Size of click animation")
        imgui.BulletText(u8"Line Size: Thickness of lines")
        imgui.Spacing()
        imgui.TextColored(imgui.ImVec4(1, 0.5, 0, 1), u8"Tip: Settings are saved automatically!")

    elseif SelectedTab.v == 8 then
        -- RECOLORER HUD TAB
        imgui.TextColored(imgui.ImVec4(0, 1, 0.5, 1), u8"RECOLORER HUD")
        imgui.Separator()
        imgui.Spacing()

        imgui.TextColored(imgui.ImVec4(0, 0.8, 0, 1), u8"GTA HUD Colors")
        imgui.Separator()

        imgui.Text(u8"Money:")
        imgui.SameLine(200)
        if imgui.ColorEdit4('##money', color_money, imgui.ColorEditFlags.NoInputs) then
            local mclr = imgui.ImColor.FromFloat4(color_money.v[1], color_money.v[2], color_money.v[3], color_money.v[4]):GetU32()
            cfg.recolorer.money = tostring(mclr)
            saveConfig()
            memory.write(0xBAB230, mclr, 4, false)
        end

        imgui.Text(u8"HP:")
        imgui.SameLine(200)
        if imgui.ColorEdit4('##health', color_health, imgui.ColorEditFlags.NoInputs) then
            local hclr = imgui.ImColor.FromFloat4(color_health.v[1], color_health.v[2], color_health.v[3], color_health.v[4]):GetU32()
            cfg.recolorer.health = tostring(hclr)
            saveConfig()
            memory.write(0xBAB22C, hclr, 4, false)
        end

        imgui.Text(u8"Wanted Stars:")
        imgui.SameLine(200)
        if imgui.ColorEdit4('##stars', color_stars, imgui.ColorEditFlags.NoInputs) then
            local sclr = imgui.ImColor.FromFloat4(color_stars.v[1], color_stars.v[2], color_stars.v[3], color_stars.v[4]):GetU32()
            cfg.recolorer.stars = tostring(sclr)
            saveConfig()
            memory.write(0xBAB244, sclr, 4, false)
        end

        imgui.Text(u8"Bullets and Oxygen:")
        imgui.SameLine(200)
        if imgui.ColorEdit4('##patron', color_patron, imgui.ColorEditFlags.NoInputs) then
            local pclr = imgui.ImColor.FromFloat4(color_patron.v[1], color_patron.v[2], color_patron.v[3], color_patron.v[4]):GetU32()
            cfg.recolorer.patron = tostring(pclr)
            saveConfig()
            memory.write(0xBAB238, pclr, 4, false)
        end

        imgui.Text(u8"Armour:")
        imgui.SameLine(200)
        if imgui.ColorEdit4('##armour', color_armour, imgui.ColorEditFlags.NoInputs) then
            local arclr = imgui.ImColor.FromFloat4(color_armour.v[1], color_armour.v[2], color_armour.v[3], color_armour.v[4]):GetU32()
            cfg.recolorer.armour = tostring(arclr)
            saveConfig()
            memory.write(0xBAB23C, arclr, 4, false)
        end

        imgui.Spacing()
        imgui.TextColored(imgui.ImVec4(0, 0.8, 0, 1), u8"SA-MP Player Health Bar")
        imgui.Separator()

        imgui.Text(u8"Foreground:")
        imgui.SameLine(200)
        if imgui.ColorEdit3(u8"##hpHigh", color_phealth, imgui.ColorEditFlags.NoInputs) then
            local clr = join_argb(0, color_phealth.v[3] * 255, color_phealth.v[2] * 255, color_phealth.v[1] * 255)
            local r, g, b = color_phealth.v[1] * 255, color_phealth.v[2] * 255, color_phealth.v[3] * 255
            cfg.recolorer.hpHigh = ("0xFF%06X"):format(clr)
            cfg.recolorer.CHARHPR = tostring(r)
            cfg.recolorer.CHARHPG = tostring(g)
            cfg.recolorer.CHARHPB = tostring(b)
            setHealthColor(tonumber(cfg.recolorer.hpHigh), tonumber(cfg.recolorer.hpLow))
            saveConfig()
        end

        imgui.Text(u8"Background:")
        imgui.SameLine(200)
        if imgui.ColorEdit3(u8"##hpLow", color_phealth2, imgui.ColorEditFlags.NoInputs) then
            local clr = join_argb(0, color_phealth2.v[3] * 255, color_phealth2.v[2] * 255, color_phealth2.v[1] * 255)
            local r, g, b = color_phealth2.v[1] * 255, color_phealth2.v[2] * 255, color_phealth2.v[3] * 255
            cfg.recolorer.hpLow = ("0xFF%06X"):format(clr)
            cfg.recolorer.CHARHPR2 = tostring(r)
            cfg.recolorer.CHARHPG2 = tostring(g)
            cfg.recolorer.CHARHPB2 = tostring(b)
            setHealthColor(tonumber(cfg.recolorer.hpHigh), tonumber(cfg.recolorer.hpLow))
            saveConfig()
        end

        imgui.Spacing()
        imgui.Separator()
        imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), u8"How to Use:")
        imgui.BulletText(u8"Click color boxes to change HUD colors")
        imgui.BulletText(u8"Changes apply instantly")
        imgui.BulletText(u8"Settings are saved automatically")
        imgui.Spacing()
        imgui.TextColored(imgui.ImVec4(1, 0.5, 0, 1), u8"The Recolorer added by allecsei")

        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()

        -- Reset Values Button
        local buttonWidth = 120
        local windowWidth = imgui.GetWindowSize().x
        imgui.SetCursorPosX((windowWidth - buttonWidth) / 2)
        if imgui.Button(u8"Reset Values", imgui.ImVec2(buttonWidth, 25)) then
            -- Reset to default values
            local def_money = 4280179968
            local def_health = 4278190232
            local def_stars = 4278231295
            local def_armour = 4294967295
            local def_patron = 4278231295
            local def_hpHigh = 4294901760
            local def_hpLow = 4278231295

            -- Update config
            cfg.recolorer.money = tostring(def_money)
            cfg.recolorer.health = tostring(def_health)
            cfg.recolorer.stars = tostring(def_stars)
            cfg.recolorer.armour = tostring(def_armour)
            cfg.recolorer.patron = tostring(def_patron)
            cfg.recolorer.hpHigh = tostring(def_hpHigh)
            cfg.recolorer.hpLow = tostring(def_hpLow)
            cfg.recolorer.CHARHPR = "255"
            cfg.recolorer.CHARHPG = "0"
            cfg.recolorer.CHARHPB = "0"
            cfg.recolorer.CHARHPR2 = "255"
            cfg.recolorer.CHARHPG2 = "0"
            cfg.recolorer.CHARHPB2 = "0"

            -- Update UI color buffers
            color_money = imgui.ImFloat4(imgui.ImColor(def_money):GetFloat4())
            color_health = imgui.ImFloat4(imgui.ImColor(def_health):GetFloat4())
            color_stars = imgui.ImFloat4(imgui.ImColor(def_stars):GetFloat4())
            color_patron = imgui.ImFloat4(imgui.ImColor(def_patron):GetFloat4())
            color_armour = imgui.ImFloat4(imgui.ImColor(def_armour):GetFloat4())
            color_phealth = imgui.ImFloat3(1, 0, 0)
            color_phealth2 = imgui.ImFloat3(1, 0, 0)

            -- Apply to memory
            memory.write(0xBAB230, def_money, 4, false)
            memory.write(0xBAB22C, def_health, 4, false)
            memory.write(0xBAB244, def_stars, 4, false)
            memory.write(0xBAB23C, def_armour, 4, false)
            memory.write(0xBAB238, def_patron, 4, false)
            setHealthColor(def_hpHigh, def_hpLow)

            saveConfig()
            sampAddChatMessage("{FFDEAD}[RECOLORER] {FFFFFF}HUD colors reset to default!", -1)
        end

    elseif SelectedTab.v == 9 then
        imgui.TextColored(imgui.ImVec4(1,1,1,1), u8"THEME SETTINGS")
        imgui.Separator()

        local items_per_row = 4
        local spacing = 8
            local btn_width = (imgui.GetContentRegionAvail().x - (items_per_row - 1) * spacing) / items_per_row

        for i, theme in ipairs(Themes) do
        if imgui.Button(theme.name, imgui.ImVec2(btn_width, 35)) then
        SelectedTheme.v = i
        cfg.theme.selected = i
        saveConfig()
         end

        if i % items_per_row ~= 0 then
        imgui.SameLine(nil, spacing)
            end
        end

        imgui.Spacing()
        imgui.Separator()

        imgui.Text(u8"Custom Theme Editor:")
        if imgui.ColorEdit4(u8"Window Background", cust_bg) then
            cfg.theme.custom_bg_r = tostring(cust_bg.v[1])
            cfg.theme.custom_bg_g = tostring(cust_bg.v[2])
            cfg.theme.custom_bg_b = tostring(cust_bg.v[3])
            cfg.theme.custom_bg_a = tostring(cust_bg.v[4])
            saveConfig()
        end
        if imgui.ColorEdit4(u8"Buttons Color", cust_btn) then
            cfg.theme.custom_btn_r = tostring(cust_btn.v[1])
            cfg.theme.custom_btn_g = tostring(cust_btn.v[2])
            cfg.theme.custom_btn_b = tostring(cust_btn.v[3])
            cfg.theme.custom_btn_a = tostring(cust_btn.v[4])
            saveConfig()
        end
        if imgui.ColorEdit4(u8"Text Color", cust_text) then
            cfg.theme.custom_text_r = tostring(cust_text.v[1])
            cfg.theme.custom_text_g = tostring(cust_text.v[2])
            cfg.theme.custom_text_b = tostring(cust_text.v[3])
            cfg.theme.custom_text_a = tostring(cust_text.v[4])
            saveConfig()
        end

        if SelectedTheme.v ~= 9 then
            imgui.TextColored(imgui.ImVec4(1,0.5,0,1), u8"Select 'Custom' above to apply these colors.")
        end
        imgui.Spacing()

        local buttonWidth = 140
        local windowWidth = imgui.GetWindowSize().x
        imgui.SetCursorPosX((windowWidth - buttonWidth) / 2)
        if imgui.Button(u8"Reset Values", imgui.ImVec2(buttonWidth,30)) then
            -- Reset UI buffers
            cust_bg.v[1], cust_bg.v[2], cust_bg.v[3], cust_bg.v[4] = 0.10, 0.10, 0.10, 0.95
            cust_btn.v[1], cust_btn.v[2], cust_btn.v[3], cust_btn.v[4] = 0.20, 0.20, 0.20, 1.0
            cust_text.v[1], cust_text.v[2], cust_text.v[3], cust_text.v[4] = 0.01, 0.97, 0.98, 1.0

            -- Reset config (flattened values)
            cfg.theme.custom_bg_r = "0.10"
            cfg.theme.custom_bg_g = "0.10"
            cfg.theme.custom_bg_b = "0.10"
            cfg.theme.custom_bg_a = "0.95"

            cfg.theme.custom_btn_r = "0.20"
            cfg.theme.custom_btn_g = "0.20"
            cfg.theme.custom_btn_b = "0.20"
            cfg.theme.custom_btn_a = "1.0"

            cfg.theme.custom_text_r = "0.01"
            cfg.theme.custom_text_g = "0.97"
            cfg.theme.custom_text_b = "0.98"
            cfg.theme.custom_text_a = "1.0"

            saveConfig()
        end
    end

    imgui.EndChild()
    imgui.End()
    PopTheme()
end

-- MAIN
function main()
    repeat wait(0) until isSampAvailable()

    -- Initialize cursor color
    aargb = join_argb(
        tonumber(cfg.cursor.a) or 255,
        tonumber(cfg.cursor.r) or 255,
        tonumber(cfg.cursor.g) or 255,
        tonumber(cfg.cursor.b) or 255
    )

    -- Initialize Recolorer HUD colors
    initRecolorerColors()

    local cmds = {
        "cf", "kc", "ex", "ee", "ref", "bg", "sa", "en", "co", "cmb", "mb", "cx", "ct", "cdt",
        "missm", "missc", "gj", "ha", "ntf", "czs", "li", "staxi", "smech", "smedic",
        "ctaxi", "cmedic", "cmech", "emer", "svc", "afvr", "jbc", "sal", "nb", "ra", "rep", "ins",
        "cnbk", "mybk", "sp", "bk", "cmc","fd", "st",
    }

    for _, cmd in ipairs(cmds) do
        sampRegisterChatCommand(cmd, _G[cmd])
    end

    sampRegisterChatCommand("cmds", function()
        WinState.v = not WinState.v
        imgui.Process = WinState.v
    end)

    -- AD (Anunt) command for CNN
    sampRegisterChatCommand("add", sendAd)

    -- Checkpoint Beam command
    sampRegisterChatCommand("cp", function(param)
        param = (param or ""):lower()
        if param == "" or param == "toggle" then
            cpBeamEnabled = not cpBeamEnabled
            cfg.checkpoint.enabled = cpBeamEnabled
            saveConfig()
            local status = cpBeamEnabled and "ON" or "OFF"
            sampAddChatMessage("{FF3030}[CP BEAM] {FFFFFF}Checkpoint beam: " .. status, -1)
            return
        end
        local m = param:match("^mode%s+(%w+)$")
        if m == "beam" or m == "icon" then
            cpMode = m
            cfg.checkpoint.mode = m
            saveConfig()
            sampAddChatMessage("{FF3030}[CP BEAM] {FFFFFF}Mode changed to: " .. m, -1)
            return
        end
    end)

    -- Initialize checkpoint beam resources
    cpFont = renderCreateFont("Arial Bold", CP_FONT_SIZE)
    waypointTex = renderLoadTextureFromFile("moonloader/resources/images/radar_waypoint.png")
    cpTex = renderLoadTextureFromFile("moonloader/resources/cp/cp.png")

    -- RCC cursor command
    sampRegisterChatCommand("rcc", function()
        cursorActive = not cursorActive
        cfg.cursor.active = cursorActive
        saveConfig()
        if not cursorActive then
            sampToggleCursor(false)
        end
        local status = cursorActive and "ON" or "OFF"
        sampAddChatMessage("{00FF00}[ProCMDS] {FFFFFF}Cursor effect: " .. status, -1)
    end)

    sampAddChatMessage("{8000CC}[ProCMDS] {FFFFFF}Mod successfully loaded. Use /cmds ", -1)
    sampAddChatMessage("{8000CC}[ProCMDS] {FFFFFF}Made by allecsei{FFFFFF} | Discord: allecsei", -1)

    while true do
        wait(0)

        -- Checkpoint Beam rendering
        if cpBeamEnabled then
            if cp then cpDrawTarget(cp.x, cp.y, cp.z) end
            if rcp then cpDrawTarget(rcp.x, rcp.y, rcp.z) end
        end

        -- Cursor effect rendering (RCC) - only click animation, no separate menu
        if cursorActive and sampIsCursorActive() and isKeyJustPressed(1) then
            local CursorPoseX, CursorPoseY = getCursorPos()
            lua_thread.create(function()
                -- Random color per click
                local rr = math.random(0, 255)
                local gg = math.random(0, 255)
                local bb = math.random(0, 255)
                local randomColor = join_argb(255, rr, gg, bb)

                local r = radiusf.v
                while r > 0 do
                    wait(0)
                    renderFigure2D(CursorPoseX, CursorPoseY, figura.v, r, randomColor)
                    r = r - 1
                end
            end)
        end
    end
end
