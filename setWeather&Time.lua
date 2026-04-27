__name__	= "Time & Weather"
__version__ = "1.0"
__author__	= "allecsei"

local inicfg = require 'inicfg'
local sampev = require 'samp.events'
local settingsFile = 'TWManager.ini'
local gameStartTimer = 0

-- Flag to trigger time/weather setting
local shouldSetTimeWeather = false
-- Flag to indicate automatic setting
local isAutoSetting = false
-- Last time we changed the weather
local lastWeatherChange = os.time()

local ini = inicfg.load({
    main = {
        chatInformers = true
    },
    time = {
        hours = 12,
        minutes = 0,
        autoload = false
    },
    weather = {
        value = 0,
        autoload = false
    }
}, settingsFile)
if not doesFileExist('moonloader/config/'..settingsFile) then inicfg.save(ini, settingsFile) end

function chatMessage(text)
    if ini.main.chatInformers and not isAutoSetting then
        sampAddChatMessage(text, -1)
    end
end

function main()
    -- Define allowed weather IDs
    local allowedWeatherIds = {0, 0, 0, 1, 2, 2, 2, 2, 3, 3, 3, 3, 5, 6, 8, 10, 11, 13, 14, 17, 18}

    while not isSampAvailable() do wait(100) end
    sampRegisterChatCommand("sett", cmdSetTime)
    sampRegisterChatCommand("setw", cmdSetWeather)
    sampRegisterChatCommand("twu", function()
        isAutoSetting = false  -- Ensure manual commands show messages
        cmdSetTime(ini.time.hours..' '..ini.time.minutes)
        cmdSetWeather(ini.weather.value)
    end)

    -- Show startup message
    sampAddChatMessage("{07fc03}[Time & Weather] {FFFFFF}Loaded! | Made by{07fc03} allecsei {FFFFFF}Commands: {07fc03}/sett{FFFFFF}, {07fc03}/setw{FFFFFF}, {07fc03}/twu {FFFFFF}| ", -1)


    while true do
        wait(0)

        -- Handle initial time/weather setting on connection
        if shouldSetTimeWeather then
            shouldSetTimeWeather = false
            isAutoSetting = true  -- Enable quiet mode

            wait(100)

            -- Safely read server hour with error protection
            local serverHour = 12  -- Default value
            local success, result = pcall(function()
                return readMemory(sampGetServerSettingsPtr() + 44, 1, true)
            end)

            if success and result then
                serverHour = result
            end

            if (serverHour >= 22 or serverHour < 7) then
                cmdSetTime("21 0")
            elseif (serverHour >= 19 and serverHour < 22) then
                cmdSetTime("20 0")
            elseif (serverHour >= 7 and serverHour <= 18) then
                cmdSetTime("8 0")
            end

            cmdSetWeather("1")

            isAutoSetting = false  -- Disable quiet mode after we're done
        end

        -- Check time since last weather change
        local currentTime = os.time()
        local timeToWait = 420  -- Default wait time (7 minutes = 420 seconds)

        -- If current weather is rain (ID 8), reduce wait time to 30 seconds
        if ini.weather.value == 8 then
            timeToWait = 30  -- 30 seconds for rain
        end

        if currentTime - lastWeatherChange >= timeToWait then
            -- Set random weather from allowed IDs
            isAutoSetting = true  -- Enable quiet mode
            local randomIndex = math.random(1, #allowedWeatherIds)
            cmdSetWeather(tostring(allowedWeatherIds[randomIndex]))
            isAutoSetting = false  -- Disable quiet mode

            -- Update last change time
            lastWeatherChange = currentTime
        end
    end
end

function sampev.onServerMessage(color, text)
    -- Skip if text is nil or empty
    if not text then return end

    -- Remove color codes for better text matching
    local cleanText = text:gsub("{%x+}", "")

    -- Only check for specific welcome/connection messages
    local welcomePatterns = {
        "Welcome to",            -- Common welcome message
        "Successfully connected", -- Common connection message
        "You have successfully logged in", -- Login success message
        "logged"
    }

    -- Check if the message matches any of our welcome patterns
    for _, pattern in ipairs(welcomePatterns) do
        if cleanText and cleanText:find(pattern, 1, true) then
            shouldSetTimeWeather = true
            return -- Exit after finding a match
        end
    end
end

function cmdSetTime(param)
    if not param or param == "" then
        if not isAutoSetting then
            chatMessage('Usage: {07fc03}/sett [ore] sau [minute]')
        end
        return false
    end

    local h, m = param:match('^(%d+)%s+(%d+)$')
    h = tonumber(h)
    m = tonumber(m)

    if m == nil or m == false then
        h = tonumber(param)
        m = 0
    end

    if h ~= nil and h >= 0 and h <= 23 and m >= 0 and m <= 59 then
        setTimeOfDay(h, m)
        patch_samp_time_set(true)
        ini.time.hours = h
        ini.time.minutes = m
        inicfg.save(ini, settingsFile)
        if not isAutoSetting then
            chatMessage('Ai setat {07fc03}timpul{FFFFFF} pe {07fc03}'..('%02d'):format(h)..'{ffffff}:{07fc03}'..('%02d'):format(m))
        end
    else
        if not isAutoSetting then
            chatMessage('Foloseste {07fc03}[0-23]{FFFFFF} pentru {07fc03}ore{FFFFFF} si {07fc03}[0-59]{ffffff} pentru {07fc03}minute')
        end
        return false
    end
end

function cmdSetWeather(param)
    -- If no parameter is provided, default to weather 0
    local v = param and tonumber(param) or 0

    if v and v >= 0 and v <= 45 then
        forceWeatherNow(v)
        ini.weather.value = v
        inicfg.save(ini, settingsFile)
        if not isAutoSetting then
            chatMessage('Tu ai setat {07fc03}vremea{ffffff} pe {07fc03}'..v)
        end
    else
        if not isAutoSetting then
            chatMessage('Foloseste {07fc03}[0-45]{ffffff} pentru {07fc03}vreme')
        end
        return false
    end
end


local default = nil  -- Local variable to store default memory value

function patch_samp_time_set(enable)
	if enable then
		if default == nil then
			local success, result = pcall(function()
				return readMemory(sampGetBase() + 0x9C0A0, 4, true)
			end)
			if success then
				default = result
				writeMemory(sampGetBase() + 0x9C0A0, 4, 0x000008C2, true)
			end
		end
	else
		if default ~= nil then
			local success = pcall(function()
				writeMemory(sampGetBase() + 0x9C0A0, 4, default, true)
			end)
			if success then
				default = nil
			end
		end
	end
end