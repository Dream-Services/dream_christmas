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

local CurrentPropSystem = {}
Citizen.CreateThread(function()
    Citizen.Wait(2500)
    while true do
        local SpawnAmount = math.random(DreamCore.PropSystemAmount.min, DreamCore.PropSystemAmount.max)
        local AvailableFixedPositions = lib.table.deepclone(DreamCore.PropSystemFixed)

        for i = 1, SpawnAmount do
            local PropSystem = DreamCore.PropSystem[math.random(1, #DreamCore.PropSystem)]

            if DreamCore.PropSystemMode == 'random' then
                local RandomZone = DreamCore.PropSystemZones[math.random(1, #DreamCore.PropSystemZones)]
                local RandomCoords = vector3(
                    RandomZone.pos.x + math.random(-RandomZone.size.x, RandomZone.size.x),
                    RandomZone.pos.y + math.random(-RandomZone.size.y, RandomZone.size.y),
                    RandomZone.pos.z
                )
                CurrentPropSystem[i] = {
                    id = i,
                    prop = PropSystem,
                    coords = RandomCoords,
                    heading = 0.0,
                    claimed = false
                }
            elseif DreamCore.PropSystemMode == 'fixed' then
                -- Amount is e.g. on 10 but you only have 3 fixed positions than break the loop after 3 and don't spawn more props
                -- This is useful when you have less fixed positions than the amount of props
                if #AvailableFixedPositions <= 0 then break end

                local RandomIndex = math.random(1, #AvailableFixedPositions)
                local RandomPosition = AvailableFixedPositions[RandomIndex]
                CurrentPropSystem[i] = {
                    id = i,
                    prop = PropSystem,
                    coords = RandomPosition.coords,
                    heading = RandomPosition.heading,
                    claimed = false
                }
                lib.table.remove(AvailableFixedPositions, RandomIndex)
            else
                error('Invalid Prop System Mode! Please check the DreamCore settings (DreamCore.PropSystemMode)!')
            end
        end

        TriggerClientEvent('dream_christmas:client:createPropSystem', -1, CurrentPropSystem)
        Citizen.Wait(DreamCore.PropSystemInterval)
    end
end)

function OnPlayerLoaded(player)
    Citizen.Wait(5000)
    TriggerClientEvent('dream_christmas:client:createPropSystem', player, CurrentPropSystem)
end

lib.callback.register('dream_christmas:server:rewardPropSystem', function(source, PropId)
    local src = source
    local PropId = PropId
    local PropSystemData = CurrentPropSystem[PropId]

    if PropSystemData then
        if not PropSystemData.claimed then
            CurrentPropSystem[PropId].claimed = true
            local RewardData = GiveRandomRewardToPlayer(src, DreamCore.PropSystemRewards)

            local NotifyMessage = 'Unknown Reward Type'
            if RewardData.type == 'item' then
                NotifyMessage = Locales['PropSystem']['Success']['PropSystemClaimedItem']:format(RewardData.amount, DreamFramework.InventoryManagement(src, { type = 'label', item = RewardData.item }))
            elseif RewardData.type == 'weapon' then
                NotifyMessage = Locales['PropSystem']['Success']['PropSystemClaimedWeapon']:format(Locales['Weapons'][RewardData.weapon] or Locales['Weapons']['unknown'], lib.math.groupdigits(RewardData.ammo))
            elseif RewardData.type == 'money' then
                NotifyMessage = Locales['PropSystem']['Success']['PropSystemClaimedMoney']:format(lib.math.groupdigits(RewardData.amount), Locales['MoneyAccount'][RewardData.account] or Locales['MoneyAccount']['unknown'])
            end

            TriggerClientEvent('dream_christmas:client:removePropSystem', -1, PropId)

            if DreamCore.Webhooks.Enabled then
                local WebhookReward = 'Unknown Reward'
                if RewardData.type == 'item' then
                    WebhookReward = ('**📦 Item:** `%s` (`%s`)\n**🔢 Amount:** `%s`'):format(DreamFramework.InventoryManagement(src, { type = 'label', item = RewardData.item }), RewardData.item, RewardData.amount)
                elseif RewardData.type == 'weapon' then
                    WebhookReward = ('**🔫 Weapon:** `%s` (`%s`)\n**🔢 Ammo:** `%s`'):format(Locales['Weapons'][RewardData.weapon] or Locales['Weapons']['unknown'], RewardData.weapon, lib.math.groupdigits(RewardData.ammo))
                elseif RewardData.type == 'money' then
                    WebhookReward = ('**🪙 Wallet:** `%s` (`%s`)\n**💸 Amount:** `%s$`'):format(Locales['MoneyAccount'][RewardData.account] or Locales['MoneyAccount']['unknown'], RewardData.account, lib.math.groupdigits(RewardData.amount))
                end

                SendDiscordWebhook({
                    link = DreamCore.Webhooks.PropSystemReward,
                    color = DreamCore.Webhooks.Color,
                    thumbnail = DreamCore.Webhooks.IconURL,
                    author = {
                        name = DreamCore.Webhooks.Author,
                        icon_url = DreamCore.Webhooks.IconURL
                    },
                    title = "☃️ Prop Reward",
                    description = ("%s\n**⚙️ Player:** `%s` (`%s`)\n**🏷️ Name:** `%s`"):format(WebhookReward, GetPlayerName(source), source, DreamFramework.getPlayerName(source)),
                    footer = {
                        text     = "Made with ❤️ by Dream Development",
                        icon_url = DreamCore.Webhooks.IconURL
                    },
                })
            end

            return { success = true, message = NotifyMessage }
        else
            return { success = false, message = Locales['PropSystem']['Error']['PropSystemAlreadyClaimed'] }
        end
    else
        return { success = false, message = Locales['PropSystem']['Error']['PropSystemNotFound'] }
    end
end)


RegisterNetEvent("dream_christmas:server:giveSnowballs")
AddEventHandler("dream_christmas:server:giveSnowballs", function()
    local src = source

    if DreamCore.Snowballs then
        if DreamFramework.getPlayerFromId(src) then
            DreamFramework.addPlayerWeapon(src, 'WEAPON_SNOWBALL', DreamCore.PickupSnowballAmount)
            TriggerClientEvent("dream_christmas:client:notify", src, Locales['PickupSnowball']:format(DreamCore.PickupSnowballAmount), "success", 5000)
        end
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

            if DreamCore.Webhooks.Enabled then
                local WebhookReward = ('**🆔 Id:** `%s`\n**🪙 Wallet:** `%s` (`%s`)\n**💸 Amount:** `%s$`'):format(TreeId, Locales['MoneyAccount'][DreamCore.ChristmasTreeRewards.decorate.account] or Locales['MoneyAccount']['unknown'], DreamCore.ChristmasTreeRewards.decorate.account, lib.math.groupdigits(MoneyAmount))
                SendDiscordWebhook({
                    link = DreamCore.Webhooks.DecorateChristmasTree,
                    color = DreamCore.Webhooks.Color,
                    thumbnail = DreamCore.Webhooks.IconURL,
                    author = {
                        name = DreamCore.Webhooks.Author,
                        icon_url = DreamCore.Webhooks.IconURL
                    },
                    title = "🎄 Decorate Christmas Tree",
                    description = ("%s\n**⚙️ Player:** `%s` (`%s`)\n**🏷️ Name:** `%s`"):format(WebhookReward, GetPlayerName(source), source, DreamFramework.getPlayerName(source)),
                    footer = {
                        text     = "Made with ❤️ by Dream Development",
                        icon_url = DreamCore.Webhooks.IconURL
                    },
                })
            end

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

            if DreamCore.Webhooks.Enabled then
                local WebhookReward = 'Unknown Reward'
                if RewardData.type == 'item' then
                    WebhookReward = ('**🆔 Id:** `%s`\n**📦 Item:** `%s` (`%s`)\n**🔢 Amount:** `%s`'):format(PresentId, DreamFramework.InventoryManagement(src, { type = 'label', item = RewardData.item }), RewardData.item, RewardData.amount)
                elseif RewardData.type == 'weapon' then
                    WebhookReward = ('**🆔 Id:** `%s`\n**🔫 Weapon:** `%s` (`%s`)\n**🔢 Ammo:** `%s`'):format(PresentId, Locales['Weapons'][RewardData.weapon] or Locales['Weapons']['unknown'], RewardData.weapon, lib.math.groupdigits(RewardData.ammo))
                elseif RewardData.type == 'money' then
                    WebhookReward = ('**🆔 Id:** `%s`\n**🪙 Wallet:** `%s` (`%s`)\n**💸 Amount:** `%s$`'):format(PresentId, Locales['MoneyAccount'][RewardData.account] or Locales['MoneyAccount']['unknown'], RewardData.account, lib.math.groupdigits(RewardData.amount))
                end

                SendDiscordWebhook({
                    link = DreamCore.Webhooks.ChristmasPresent,
                    color = DreamCore.Webhooks.Color,
                    thumbnail = DreamCore.Webhooks.IconURL,
                    author = {
                        name = DreamCore.Webhooks.Author,
                        icon_url = DreamCore.Webhooks.IconURL
                    },
                    title = "🎁 Christmas Present",
                    description = ("%s\n**⚙️ Player:** `%s` (`%s`)\n**🏷️ Name:** `%s`"):format(WebhookReward, GetPlayerName(source), source, DreamFramework.getPlayerName(source)),
                    footer = {
                        text     = "Made with ❤️ by Dream Development",
                        icon_url = DreamCore.Webhooks.IconURL
                    },
                })
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

function SendDiscordWebhook(WebhookData)
    local EmbedDataArray = {}
    local EmbedData = {}

    EmbedData.color = WebhookData.color

    if WebhookData.author then
        EmbedData.author = {}
        EmbedData.author.name = WebhookData.author.name
        EmbedData.author.icon_url = WebhookData.author.icon_url
    end

    if WebhookData.title then
        EmbedData.title = WebhookData.title
    end

    if WebhookData.thumbnail then
        EmbedData.thumbnail = {}
        EmbedData.thumbnail.url = WebhookData.thumbnail
    end

    EmbedData.description = WebhookData.description

    if WebhookData.footer then
        EmbedData.footer = {}
        EmbedData.footer.text = WebhookData.footer.text
        EmbedData.footer.icon_url = WebhookData.footer.icon_url
    end

    table.insert(EmbedDataArray, EmbedData)

    PerformHttpRequest(WebhookData.link, function(err, text, headers) end, 'POST', json.encode({ embeds = EmbedDataArray }), { ['Content-Type'] = 'application/json' })
end
