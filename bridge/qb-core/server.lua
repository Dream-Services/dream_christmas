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
function DreamFramework.RegisterCallback(name, cb)
    QBCore.Functions.CreateCallback(name, cb)
end

function DreamFramework.GetIdentifier(source)
    local source = source -- Save Variable
    local Identifier = nil -- Create new Variable
    local Player = QBCore.Functions.GetPlayer(source)

    if Player then
        Identifier = Player.PlayerData.citizenid
    end

    return Identifier
end

-- Player Data
local Player = nil
function DreamFramework.getPlayerFromId(source)
    Player = QBCore.Functions.GetPlayer(source)
    if not Player then Player = QBCore.Functions.GetPlayerByCitizenId(source) end
    return Player
end

function DreamFramework.getPlayerSourceFromPlayer(Player)
    return Player.PlayerData.source
end

function DreamFramework.getPlayerName(source)
    local Player = QBCore.Functions.GetPlayer(source)
    return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
end

function DreamFramework.getPlayerHeight(source)
    return '/' -- TODO:
end

function DreamFramework.getPlayerDOB(source)
    local Player = QBCore.Functions.GetPlayer(source)
    return Player.PlayerData.charinfo.birthdate
end

function DreamFramework.getPlayerSex(source)
    local Player = QBCore.Functions.GetPlayer(source)
    return Player.PlayerData.charinfo.gender == 0 and 'm' or 'f'
end

function DreamFramework.getPlayerGroup(source)
    local PlayerPerms = QBCore.Functions.GetPermission(source)
    if DreamFramework.Object.length(PlayerPerms) > 0 then
        local PlayerPermsString = 'Unknown'
        for k, v in pairs(PlayerPerms) do
            if PlayerPermsString == 'Unknown' then
                PlayerPermsString = k
            else
                PlayerPermsString = PlayerPermsString .. ', ' .. k
            end
        end
        return PlayerPermsString
    else
        return 'user'
    end
end

function DreamFramework.getPlayerJob(source, dataType)
    local Player = DreamFramework.getPlayerFromId(source)
    if dataType == 'label' then
        return Player.PlayerData.job.label
    elseif dataType == 'name' then
        return Player.PlayerData.job.name
    elseif dataType == 'grade' then
        return Player.PlayerData.job.grade.level
    elseif dataType == 'gradeLabel' then
        return Player.PlayerData.job.grade.name
    end
end

function DreamFramework.getPlayerMoney(source, moneyWallet)
    local Player = DreamFramework.getPlayerFromId(source)
    if moneyWallet == 'money' then
        return Player.PlayerData.money['cash']
    elseif moneyWallet == 'bank' then
        return Player.PlayerData.money['bank']
    elseif moneyWallet == 'black_money' then
        return Player.PlayerData.money['blackmoney']
    end
end

function DreamFramework.addPlayerMoney(source, moneyWallet, amount)
    local Player = DreamFramework.getPlayerFromId(source)
    if moneyWallet == 'money' then
        Player.Functions.AddMoney('cash', amount)
    elseif moneyWallet == 'bank' then
        Player.Functions.AddMoney('bank', amount)
    elseif moneyWallet == 'black_money' then
        Player.Functions.AddMoney('blackmoney', amount)
    end
end

function DreamFramework.removePlayerMoney(source, moneyWallet, amount)
    local Player = DreamFramework.getPlayerFromId(source)
    if moneyWallet == 'money' then
        Player.Functions.RemoveMoney('cash', amount)
    elseif moneyWallet == 'bank' then
        Player.Functions.RemoveMoney('bank', amount)
    elseif moneyWallet == 'black_money' then
        Player.Functions.RemoveMoney('blackmoney', amount)
    end
end

function DreamFramework.InventoryManagement(source, data)
    local Player = DreamFramework.getPlayerFromId(source)

    if data.type == 'valid' then
        return QBCore.Shared.Items[data.item:lower()] ~= nil
    elseif data.type == 'label' then
        return QBCore.Shared.Items[data.item:lower()].label
    elseif data.type == 'count' then
        local PlayerItem = Player.Functions.GetItemByName(data.item)
        if not PlayerItem then return 0 end -- Return 0 if player does not have item in inventory
        return Player.Functions.GetItemByName(data.item).amount
    elseif data.type == 'weight' then
        return QBCore.Shared.Items[data.item:lower()].weight
    elseif data.type == 'add' then
        Player.Functions.AddItem(data.item, data.amount)
    elseif data.type == 'remove' then
        Player.Functions.RemoveItem(data.item, data.amount)
    end
end

-- Dream Christmas
function DreamFramework.addPlayerWeapon(source, weaponName, ammo)
    if DreamCore.Inventory() == 'qb' then
        exports['ox_inventory']:AddItem(source, weaponName, 1, {
            ammo = ammo
        })
    else
        local Player = DreamFramework.getPlayerFromId(source)
        Player.Functions.AddItem(weaponName, 1)
        -- TODO: QBCore Weapon Ammo
    end
end

-- Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function(player, xPlayer, isNew)
    OnPlayerLoaded(player)
end)
