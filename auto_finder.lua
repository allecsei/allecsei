script_name("Auto Finder")
script_author("allecsei / Lua conversion")

require "lib.moonloader"
local inicfg = require "inicfg"

local config_dir = getWorkingDirectory() .. "\\config\\"
local config_file = config_dir .. "auto_finder.ini"

local cfg = inicfg.load({
    settings = {
        find_id = 1,
        delay = 121000
    }
}, "auto_finder")

local active = false

function main()
    while not isSampAvailable() do wait(100) end
    wait(2000)

    inicfg.save(cfg, config_file)

    sampAddChatMessage("{8000CC}Auto Finder{FFFFFF} Mod successfully loaded. Use /afd", -1)
    sampAddChatMessage("{8000CC}Auto Finder,{FFFFFF} for set use /afd [id]{FFFFFF} |{8000CC} Discord: {FFFFFF}allecsei", -1)
    sampRegisterChatCommand("afd", cmd_afd)

    while true do
        wait(0)

        if active then
            sampSendChat("/find "..cfg.settings.find_id)
            wait(cfg.settings.delay)
        end
    end
end

function cmd_afd(arg)

    if arg ~= nil and arg ~= "" then
        local id = tonumber(arg)

        if id then
            cfg.settings.find_id = id
            inicfg.save(cfg, config_file)
            sampAddChatMessage("{8000CC}Auto Finder ID set to {FFFFFF}"..id, -1)
            return
        end
    end

    active = not active

    if active then
        printStringNow("~g~Auto Finder ON", 2000)
    else
        printStringNow("~r~Auto Finder OFF", 2000)
    end
end