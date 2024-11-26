--[[
    Open-Source Conditions
	Please read the license conditions in the LICENSE file. By using this script, you agree to these conditions.
]]

-- Set Script Metadata
local ScriptMetadata = {
    id = 'dream_christmas',
    name = 'Dream-Christmas',
    label = 'Dream Christmas',
    version = GetResourceMetadata(GetCurrentResourceName(), 'version', 0),
    patch = GetResourceMetadata(GetCurrentResourceName(), 'patch', 0),
}

-- Check DreamCore
if not DreamCore or type(DreamCore) ~= 'table' then
    print(('\27[1;46m[%s]\27[0m \27[1;37m The ^3DreamCore^7\27[1;37m does not work as it should! It might be a syntax error which caused by changes.^7'):format(ScriptMetadata.name))
    return
end

-- Check Locales
if not DreamLocales[DreamCore.Language] then
    print(('\27[1;46m[%s]\27[0m \27[1;37m The locales prefix (^3%s\27[1;37m) is invalid! Please check that the locales for ^3%s\27[1;37m was created correctly in ^4settings/locales/%s.lua\27[1;37m with the prefix!^7'):format(ScriptMetadata.name, DreamCore.Language, DreamCore.Language, DreamCore.Language))
    return
end

-- Set Dream Services Convar
if DreamCore.GiveCredits then SetConvarServerInfo("Dream Services", "❤️") end

-- Available Print
print(('\27[1;46m[%s]\27[0m \27[1;37m🎅 The ^3%s^7\27[1;37m on version ^3%s^7\27[1;37m (^4Patch %s^7\27[1;37m) is now running 🎄^7'):format(ScriptMetadata.name, ScriptMetadata.label, ScriptMetadata.version, ScriptMetadata.patch))

-- Check for Updates
Citizen.CreateThread(function()
    PerformHttpRequest('https://api.github.com/repos/Dream-Services/dream_christmas/releases/latest', function(Code, Response, Headers, ErrorResponse)
        -- Alert when GitHub API is unreachable
        if Code == 0 then
            print(('\27[1;46m[%s]\27[0m \27[1;37m The ^3GitHub API^7\27[1;37m is unreachable! Tried Endpoint: ^3%s^7'):format(ScriptMetadata.name, 'https://api.github.com/repos/Dream-Services/dream_christmas/releases/latest'))
            print(('\27[1;46m[%s]\27[0m \27[1;37m Please check your internet connection/firewall or the status of the GitHub API^7'):format(ScriptMetadata.name))
            return
        end

        if Code >= 200 and Code < 300 then
            ResponseData = json.decode(Response)

            -- Check if a new version is available
            if ResponseData.tag_name ~= ScriptMetadata.version then
                print(('\27[1;46m[%s]\27[0m \27[1;37m🎄 A new version ^3%s\27[1;37m is available since ^3%s UTC\27[1;37m.^7'):format(ScriptMetadata.name, ResponseData.tag_name, os.date('%d.%m.%Y %H:%M:%S', ParseISODateString(ResponseData.published_at))))
                print(('\27[1;46m[%s]\27[0m \27[1;37mPlease update it on ^5GitHub^7:\27[1;37m %s'):format(ScriptMetadata.name, ResponseData.html_url))
            end
        else
            ResponseData = json.decode(ErrorResponse:gsub('HTTP %d+: (.+)', '%1'))
            print(('\27[1;46m[%s]\27[0m \27[1;37m An error occurred while checking for updates. Error: ^1%s^7'):format(ScriptMetadata.name, ResponseData.message))
        end
    end, 'GET', '', {
        ['Content-Type'] = 'application/json',
        ['script'] = ScriptMetadata.id
    })
end)

function ParseISODateString(IsoString)
    local year, month, day, hour, min, sec = IsoString:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
    return os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec })
end

-- Locales
local Locales = DreamLocales[DreamCore.Language]

-- Global Variables

local CurrentRandomProps = {}
Citizen.CreateThread(function()
    Citizen.Wait(2500)
    while true do
        local SpawnAmount = math.random(DreamCore.RandomPropsAmount.min, DreamCore.RandomPropsAmount.max)
        for i = 1, SpawnAmount do
            local RandomProp = DreamCore.RandomProps[math.random(1, #DreamCore.RandomProps)]
            local RandomZone = DreamCore.RandomPropsZones[math.random(1, #DreamCore.RandomPropsZones)]
            local RandomCoords = vector3(
                RandomZone.pos.x + math.random(-RandomZone.size.x, RandomZone.size.x),
                RandomZone.pos.y + math.random(-RandomZone.size.y, RandomZone.size.y),
                RandomZone.pos.z
            )

            CurrentRandomProps[i] = {
                id = i,
                prop = RandomProp,
                coords = RandomCoords,
                claimed = false
            }
        end
        TriggerClientEvent('dream_christmas:client:createRandomProps', -1, CurrentRandomProps)
        Citizen.Wait(DreamCore.RandomPropsInterval)
    end
end)

function OnPlayerLoaded(player)
    Citizen.Wait(5000)
    TriggerClientEvent('dream_christmas:client:createRandomProps', player, CurrentRandomProps)
end

lib.callback.register('dream_christmas:server:rewardRandomProp', function(source, PropId)
    local src = source
    local PropId = PropId
    local RandomPropData = CurrentRandomProps[PropId]

    if RandomPropData then
        if not RandomPropData.claimed then
            CurrentRandomProps[PropId].claimed = true
            local RewardData = GiveRandomRewardToPlayer(src, DreamCore.RandomPropRewards)

            local NotifyMessage = 'Unknown Reward Type'
            if RewardData.type == 'item' then
                NotifyMessage = Locales['RandomProp']['Success']['RandomPropClaimedItem']:format(RewardData.amount, DreamFramework.InventoryManagement(src, { type = 'label', item = RewardData.item }))
            elseif RewardData.type == 'weapon' then
                NotifyMessage = Locales['RandomProp']['Success']['RandomPropClaimedWeapon']:format(Locales['Weapons'][RewardData.weapon] or Locales['Weapons']['unknown'], lib.math.groupdigits(RewardData.ammo))
            elseif RewardData.type == 'money' then
                NotifyMessage = Locales['RandomProp']['Success']['RandomPropClaimedMoney']:format(lib.math.groupdigits(RewardData.amount), Locales['MoneyAccount'][RewardData.account] or Locales['MoneyAccount']['unknown'])
            end

            TriggerClientEvent('dream_christmas:client:removeRandomProp', -1, PropId)

            return { success = true, message = NotifyMessage }
        else
            return { success = false, message = Locales['RandomProp']['Error']['RandomPropAlreadyClaimed'] }
        end
    else
        return { success = false, message = Locales['RandomProp']['Error']['RandomPropNotFound'] }
    end
end)

local ChristmasTreeCooldown = {
    decorate = {}
}
lib.callback.register('dream_christmas:server:decorateChristmasTree', function(source, TreeId)
    local src = source
    local TreeData = nil

    for k, v in pairs(DreamCore.ChristmasTree) do
        if v.id == TreeId then
            TreeData = DreamCore.ChristmasTree[k]
        end
    end

    if TreeData then
        local PlayerIdentifier = DreamFramework.GetIdentifier(source)

        if
            not ChristmasTreeCooldown.decorate?[TreeId]?[PlayerIdentifier]
            or (ChristmasTreeCooldown.decorate[TreeId][PlayerIdentifier] > (os.time() + DreamCore.ChristmasTreeCooldown.decorate))
        then
            ChristmasTreeCooldown.decorate[TreeId] = {
                [PlayerIdentifier] = os.time()
            }
            local MoneyAmount = math.random(DreamCore.ChristmasTreeRewards.decorate.amount.min, DreamCore.ChristmasTreeRewards.decorate.amount.max)
            DreamFramework.addPlayerMoney(src, DreamCore.ChristmasTreeRewards.decorate.account, MoneyAmount)
            return { success = true, message = Locales['ChristmasTree']['Success']['ChristmasTreeDecorate']:format(lib.math.groupdigits(MoneyAmount)) }
        else
            return { success = false, message = Locales['ChristmasTree']['Error']['ChristmasTreeAlreadyDecorated'] }
        end
    else
        return { success = false, message = Locales['ChristmasTree']['Error']['ChristmasTreeInvalid'] }
    end
end)

local ChristmasPresentCooldown = {}
lib.callback.register('dream_christmas:server:claimChristmasPresent', function(source, PresentId)
    local src = source
    local PresentData = nil

    for k, v in pairs(DreamCore.ChristmasPresents) do
        if v.id == PresentId then
            PresentData = DreamCore.ChristmasPresents[k]
        end
    end

    if PresentData then
        local PlayerIdentifier = DreamFramework.GetIdentifier(source)

        if
            not ChristmasPresentCooldown?[PresentId]?[PlayerIdentifier]
            or (ChristmasPresentCooldown[PresentId][PlayerIdentifier] > (os.time() + DreamCore.ChristmasPresentCooldown))
        then
            ChristmasPresentCooldown[PresentId] = {
                [PlayerIdentifier] = os.time()
            }

            local RewardData = GiveRandomRewardToPlayer(src, DreamCore.ChristmasPresentRewards)

            local NotifyMessage = 'Unknown Reward Type'
            if RewardData.type == 'item' then
                NotifyMessage = Locales['ChristmasPresent']['Success']['ChristmasPresentItem']:format(RewardData.amount, DreamFramework.InventoryManagement(src, { type = 'label', item = RewardData.item }))
            elseif RewardData.type == 'weapon' then
                NotifyMessage = Locales['ChristmasPresent']['Success']['ChristmasPresentWeapon']:format(Locales['Weapons'][RewardData.weapon] or Locales['Weapons']['unknown'], lib.math.groupdigits(RewardData.ammo))
            elseif RewardData.type == 'money' then
                NotifyMessage = Locales['ChristmasPresent']['Success']['ChristmasPresentMoney']:format(lib.math.groupdigits(RewardData.amount), Locales['MoneyAccount'][RewardData.account] or Locales['MoneyAccount']['unknown'])
            end

            return { success = true, message = NotifyMessage }
        else
            return { success = false, message = Locales['ChristmasPresent']['Error']['ChristmasPresentAlreadyClaimed'] }
        end
    else
        return { success = false, message = Locales['ChristmasPresent']['Error']['ChristmasPresentInvalid'] }
    end
end)

function GiveRandomRewardToPlayer(src, RewardsPool)
    local RandomReward = lib.table.deepclone(RewardsPool[math.random(1, #RewardsPool)])
    if RandomReward.type == 'item' then
        local ItemAmount = math.random(RandomReward.amount.min, RandomReward.amount.max)
        RandomReward.amount = ItemAmount
        DreamFramework.InventoryManagement(src, { type = 'add', item = RandomReward.item, amount = ItemAmount })
    elseif RandomReward.type == 'weapon' then
        local WeaponAmmo = math.random(RandomReward.ammo.min, RandomReward.ammo.max)
        RandomReward.ammo = WeaponAmmo
        DreamFramework.addPlayerWeapon(src, RandomReward.weapon, WeaponAmmo)
    elseif RandomReward.type == 'money' then
        local MoneyAmount = math.random(RandomReward.amount.min, RandomReward.amount.max)
        RandomReward.amount = MoneyAmount
        DreamFramework.addPlayerMoney(src, RandomReward.account, MoneyAmount)
    end
    return RandomReward
end
