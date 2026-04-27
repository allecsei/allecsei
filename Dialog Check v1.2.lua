script_name('Dialog Check')
script_author('allecsei')
script_version('v1.4')

require 'lib.moonloader'
local keys = require 'vkeys'
local sampev = require 'lib.samp.events'
local inicfg = require 'inicfg'

local dialogs = {}
local dialogCount = 0
local configPath = 'DialogCheck\\Config.ini' -- Fișier separat pentru setări
local savePath = 'DialogCheck\\DialogCheck.ini' -- Fișier pentru log-ul dialogurilor

-- Structura default pentru setări
local mainIni = inicfg.load({
    settings = {
        enabled = true
    }
}, configPath)

-- Verificăm dacă fișierul există, dacă nu, îl creăm
if not doesFileExist('moonloader\\config\\' .. configPath) then
    inicfg.save(mainIni, configPath)
end

local dialogCheckEnabled = mainIni.settings.enabled

function dialog_id()
    sampAddChatMessage(string.format('{FFFFFF}Dialog Check is %s. Cached dialogs: %d', dialogCheckEnabled and '{00FF00}enabled' or '{FF0000}disabled', dialogCount), 0xFFFFFF)
end

function enable_dialogcheck()
    if dialogCheckEnabled then
        sampAddChatMessage('{FFFF00}DialogCheck is already enabled.', 0xFFFFFF)
        return
    end
    dialogCheckEnabled = true
    mainIni.settings.enabled = true
    inicfg.save(mainIni, configPath) -- Salvăm starea în INI
    sampAddChatMessage('{00FF00}DialogCheck enabled and saved.', 0xFFFFFF)
end

function disable_dialogcheck()
    if not dialogCheckEnabled then
        sampAddChatMessage('{FFFF00}DialogCheck is already disabled.', 0xFFFFFF)
        return
    end
    dialogCheckEnabled = false
    mainIni.settings.enabled = false
    inicfg.save(mainIni, configPath) -- Salvăm starea în INI
    sampAddChatMessage('{FF0000}DialogCheck disabled and saved.', 0xFFFFFF)
end

function save_dialogs()
    if dialogCount == 0 then
        sampAddChatMessage('{FF0000}No dialogs have been captured yet.', 0xFFFFFF)
        return
    end

    local iniData = {}
    for index, dialog in ipairs(dialogs) do
        iniData['Dialog' .. index] = {
            id = dialog.id,
            style = dialog.style,
            title = dialog.title,
            button1 = dialog.button1,
            button2 = dialog.button2,
            text = dialog.text,
            timestamp = dialog.timestamp,
        }
    end

    if inicfg.save(iniData, savePath) then
        sampAddChatMessage(string.format('{00FF00}Saved %d dialog(s) to {FFFFFF}moonloader\\config\\DialogCheck\\DialogCheck.ini', dialogCount), 0xFFFFFF)
    else
        sampAddChatMessage('{FF0000}Failed to save dialog info to DialogCheck.ini', 0xFFFFFF)
    end
end

function main()
    if not isSampLoaded or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    
    -- Notificare stare la încărcare
    local statusText = dialogCheckEnabled and '{00FF00}ENABLED' or '{FF0000}DISABLED'
    sampAddChatMessage('{AA3322}Dialog Check script loaded. Use {FFFFFF}/checkdialog{AA3322}, {FFFFFF}/enable{AA3322} and {FFFFFF}/disable{AA3322}. Use {FFFFFF}/savedialogs {AA3322}to save them to an INI file.', 0xFFFFFF)
    
    sampRegisterChatCommand('checkdialog', dialog_id)
    sampRegisterChatCommand('savedialogs', save_dialogs)
    sampRegisterChatCommand('enable', enable_dialogcheck)
    sampRegisterChatCommand('disable', disable_dialogcheck)

    while true do
        wait(0)
    end
end

local function sendWrappedDialogText(text)
    local prefix = '{AA5211}Dialog Text: '
    local color = 0xFFFFFF
    local chunkSize = 200
    if #text <= chunkSize then
        sampAddChatMessage(prefix .. text, color)
        return
    end

    sampAddChatMessage(prefix .. text:sub(1, chunkSize), color)
    local pos = chunkSize + 1
    while pos <= #text do
        sampAddChatMessage(text:sub(pos, pos + chunkSize - 1), 0xFFFFFF)
        pos = pos + chunkSize
    end
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
    if not dialogCheckEnabled then
        return
    end

    dialogCount = dialogCount + 1
    dialogs[dialogCount] = {
        id = id,
        style = style,
        title = title,
        button1 = button1,
        button2 = button2,
        text = text,
        timestamp = os.date('%Y-%m-%d %H:%M:%S'),
    }

    sampAddChatMessage(string.format('{FF0000}Dialog ID: %d', id), 0xFFFFFF)
    sampAddChatMessage(string.format('{FF6622}Dialog Style: %d', style), 0xFFFFFF)
    sampAddChatMessage(string.format('{AA5555}Dialog Title: %s', title), 0xFFFFFF)
    sampAddChatMessage(string.format('{DD5625}Button 1: %s', button1), 0xFFFFFF)
    sampAddChatMessage(string.format('{BBdd55}Button 2: %s', button2), 0xFFFFFF)
    sendWrappedDialogText(text)
end
