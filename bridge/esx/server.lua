-- Serverside ESX bridge
if GetResourceState('es_extended') ~= 'started' then return end

ESX = exports['es_extended']:getSharedObject()

while not ESX do
    ESX = exports['es_extended']:getSharedObject()
    Citizen.Wait(500)
end
DreamFramework.ServerFramework = 'esx'
DreamFramework.ServerFrameworkLoaded = true

-- Bridge Functions
function DreamFramework.RegisterCallback(name, cb)
    ESX.RegisterServerCallback(name, cb)
end

function DreamFramework.GetIdentifier(source)
    local source = source -- Save Variable
    local Identifier = nil -- Create new Variable
    local xPlayer = DreamFramework.getPlayerFromId(source)

    if xPlayer then
        Identifier = xPlayer.getIdentifier()
    else
        for k, v in pairs(GetPlayerIdentifiers(source)) do
            if string.sub(v, 1, string.len("license:")) == "license:" then
                Identifier = v:gsub("license:", "") -- Returns XXX License
            end
        end
    end

    return Identifier
end

-- Player Data
local xPlayer = nil
function DreamFramework.getPlayerFromId(source)
    xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then xPlayer = ESX.GetPlayerFromIdentifier(source) end
    return xPlayer
end

function DreamFramework.getPlayerSourceFromPlayer(xPlayer)
    return xPlayer.source
end

function DreamFramework.getPlayerName(source)
    local xPlayer = DreamFramework.getPlayerFromId(source)
    return xPlayer.getName()
end

function DreamFramework.getPlayerHeight(source)
    local xPlayer = DreamFramework.getPlayerFromId(source)
    return xPlayer.variables.height
end

function DreamFramework.getPlayerDOB(source)
    local xPlayer = DreamFramework.getPlayerFromId(source)
    return xPlayer.variables.dateofbirth
end

function DreamFramework.getPlayerSex(source)
    local xPlayer = DreamFramework.getPlayerFromId(source)
    return xPlayer.variables.sex
end

function DreamFramework.getPlayerGroup(source)
    local xPlayer = DreamFramework.getPlayerFromId(source)
    return xPlayer.getGroup()
end

function DreamFramework.getPlayerJob(source, dataType)
    local xPlayer = DreamFramework.getPlayerFromId(source)
    if dataType == 'label' then
        return xPlayer.getJob().label
    elseif dataType == 'name' then
        return xPlayer.getJob().name
    elseif dataType == 'grade' then
        return xPlayer.getJob().grade
    elseif dataType == 'gradeLabel' then
        return xPlayer.getJob().grade_label
    end
end

function DreamFramework.getPlayerMoney(source, account)
    local xPlayer = DreamFramework.getPlayerFromId(source)
    if account == 'money' then
        return xPlayer.getMoney()
    else
        return xPlayer.getAccount(account).money
    end
end

function DreamFramework.addPlayerMoney(source, moneyWallet, amount)
    local xPlayer = DreamFramework.getPlayerFromId(source)
    if moneyWallet == 'money' then
        xPlayer.addMoney(amount)
    else
        xPlayer.addAccountMoney(moneyWallet, amount)
    end
end

function DreamFramework.removePlayerMoney(source, moneyWallet, amount)
    local xPlayer = DreamFramework.getPlayerFromId(source)
    if moneyWallet == 'money' then
        xPlayer.removeMoney(amount)
    else
        xPlayer.removeAccountMoney(moneyWallet, amount)
    end
end

function DreamFramework.InventoryManagement(source, data)
    local xPlayer = DreamFramework.getPlayerFromId(source)

    if data.type == 'valid' then
        return xPlayer.getInventoryItem(data.item) ~= nil
    elseif data.type == 'label' then
        return xPlayer.getInventoryItem(data.item).label
    elseif data.type == 'count' then
        return xPlayer.getInventoryItem(data.item).count
    elseif data.type == 'weight' then
        return xPlayer.getInventoryItem(data.item).weight
    elseif data.type == 'add' then
        xPlayer.addInventoryItem(data.item, data.amount)
    elseif data.type == 'remove' then
        xPlayer.removeInventoryItem(data.item, data.amount)
    end
end

-- Dream Christmas
function DreamFramework.addPlayerWeapon(source, weaponName, ammo)
    if DreamCore.Inventory() == 'ox' then
        if weaponName == 'WEAPON_SNOWBALL' then
            local SnowballSlot = exports['ox_inventory']:GetSlotWithItem(source, 'WEAPON_SNOWBALL')

            if SnowballSlot then
                SnowballSlot.metadata.ammo = SnowballSlot.metadata.ammo + ammo
                exports['ox_inventory']:SetMetadata(source, SnowballSlot.slot, SnowballSlot.metadata)
            else
                exports['ox_inventory']:AddItem(source, weaponName, 1, {
                    ammo = ammo
                })
            end
        else
            exports['ox_inventory']:AddItem(source, weaponName, 1, {
                ammo = ammo
            })
        end
    else
        local xPlayer = DreamFramework.getPlayerFromId(source)

        if xPlayer.hasWeapon(weaponName) then
            xPlayer.addWeaponAmmo(weaponName, ammo)
        else
            xPlayer.addWeapon(weaponName, ammo)
        end
    end
end

RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew)
    OnPlayerLoaded(player)
end)
