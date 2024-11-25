-- Serverside QBCore bridge
if GetResourceState('qb-core') ~= 'started' then return end

QBCore = exports['qb-core']:GetCoreObject()

while not QBCore do
    QBCore = exports['qb-core']:GetCoreObject()
    Citizen.Wait(500)
end
DreamFramework.ServerFramework = 'qb-core'
DreamFramework.ServerFrameworkLoaded = true

-- Bridge Functions
function DreamFramework.ServerCallback(name, cb, ...)
    QBCore.Functions.TriggerCallback(name, cb, ...)
end

function DreamFramework.showHelpNotification(text)
    AddTextEntry('qbHelpNotification', text)
    BeginTextCommandDisplayHelp('qbHelpNotification')
    EndTextCommandDisplayHelp(0, false, false, -1)
end

-- Player Data
function DreamFramework.IsPlayerDataValid()
    return QBCore.Functions.GetPlayerData() ~= nil
end

function DreamFramework.getPlayerJob()
    if not DreamFramework.IsPlayerDataValid() then return false end
    return QBCore.Functions.GetPlayerData().job.name
end

function DreamFramework.getPlayerMoney(moneyWallet)
    local Player = QBCore.Functions.GetPlayerData()
    if moneyWallet == 'money' then
        return Player.money['cash']
    elseif moneyWallet == 'bank' then
        return Player.money['bank']
    elseif moneyWallet == 'black_money' then
        return Player.money['blackmoney']
    end
end
