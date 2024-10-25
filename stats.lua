local samp = require 'samp.events'

local sampev = require("lib.samp.events")



function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(0) end
    sampAddChatMessage("[AdmBot] This mod was created by {00FF00}allecsei{FFFFFF} and edited by {FF4500}BishopHeahmund.", -1)
    sampAddChatMessage("[AdmBot] {FFFF00}Version 0.1b has been successfully loaded. Type {FFFFFF}/cmd {FFFF00}for info!", -1)
end

------------------- Car engine ---------------------
function sampev.onServerMessage(color, text)
if text:find('Scrie %/engine sau apasa 2 pentru a porni motorul%.') then
sampSendChat('/engine')
end
if text:find('Use %/engine or press 2 to turn on the engine%.') then
sampSendChat('/engine')
end
if text:find('Use %/engine to turn on the engine%.') then
sampSendChat('/engine')
end
if text:find('Scrie %/engine pentru a porni motorul%.') then
sampSendChat('/engine')
end
end
------------------- Comenzi ---------------------
sampRegisterChatCommand('in', function()
sampSendChat('/buyinsurance')
end)
sampRegisterChatCommand('st', function()
    sampSendChat('/stats')
end)
sampRegisterChatCommand('sal', function()
    sampSendChat('/f Salutare!')
    sampSendChat('/C Salutare!!')
    sampSendChat('/ac Salutare.')
end)
sampRegisterChatCommand('kp', function()
    sampSendChat('/killcp')
end)
------------------- Dialog ---------------------
sampRegisterChatCommand('cmd', function()
    local titleMessage = "{FF4500}Commands List - Admbot by Allecsei"
    local command1 = "{00FF00}/st {FFFFFF}- stats"
    local command2 = "{00FF00}/in {FFFFFF}- buy insurance"
    local command3 = "{00FF00}/sal {FFFFFF}- salut global"
    local command4 = "{00FF00}/kp {FFFFFF}- kill checkpoint"

    sampAddChatMessage(titleMessage, -1)
    sampAddChatMessage(command1, -1)
    sampAddChatMessage(command2, -1)
    sampAddChatMessage(command3, -1)
    sampAddChatMessage(command4, -1)
end)

