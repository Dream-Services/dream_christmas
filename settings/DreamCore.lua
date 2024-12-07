--[[
    Thank you for using our script. We are happy to have you here. If you need help, you can join our Discord server.
    https://discord.gg/zppUXj4JRm
]]

DreamLocales = {} -- Do not touch this!!!
DreamFramework = {} -- Do not touch this!!!
DreamCore = {} -- Do not touch this!!!

-- Dream Christmas Settings
DreamCore.Language = 'en'
DreamCore.GiveCredits = true -- Set to false if you don't want to give credits
DreamCore.Inventory = function()
    if GetResourceState('ox_inventory') == 'started' then
        return 'ox'
    else
        return 'default' -- For all other inventory systems which not have special systems
    end
end
DreamCore.Target = function()
    if GetResourceState('ox_target') == 'started' then
        return 'ox'
    elseif GetResourceState('qb-target') == 'started' then
        return 'qb'
    else
        return error('No target system found! Please adjust DreamCore.Target!!!')
    end
end
DreamCore.Notify = function(text, type, duration)
    -- Always clientside

    -- Params:
    -- text: message: string
    -- type: info, success, warning, error
    -- duration: time in ms

    -- Default Values
    local type = type or 'info'
    local duration = duration or 5000

    -- Ox Notification (ox_lib)
    lib.notify({
        type        = type,
        position    = 'center-right',
        title       = DreamLocales[DreamCore.Language]['NotifyHeader'],
        description = text,
        duration    = duration
    })
end

-- Snow System (Snowballs &  Overlay)
DreamCore.XmasSnow = true -- Set to false if you don't want snow
DreamCore.PreventOtherWeatherResources = true -- Set to true if you want to prevent other weather resources | ⚠️ We will stop all other weather resources!!!!!!

DreamCore.SnowOverlay = true -- Set to false if you don't want the snow overlay | Requires DreamCore.XmasSnow = true
DreamCore.Snowballs = true -- Set to false if you don't want snowballs | Requires DreamCore.XmasSnow = true
DreamCore.SnowballDamageModifier = 0.0 -- Set the damage of the snowball | 0.0 - 0.1 for realism | Requires DreamCore.Snowballs = true
DreamCore.SnowballLimit = 10 -- Set the limit of snowballs | Requires DreamCore.Snowballs = true
DreamCore.PickupSnowball = 'E' -- Set the control to pickup snowballs
DreamCore.PickupSnowballCooldown = 1500 -- Set the cooldown to pickup snowballs
DreamCore.PickupSnowballAmount = 2 -- Set the amount of snowballs to pickup

-- Prop System (e.g. Snowman)
DreamCore.PropSystemInterval = 30 * 60000 -- Set the interval to spawn props
DreamCore.PropSystemAmount = { min = 5, max = 15 } -- Set the amount of props to spawning
DreamCore.PropSystemMode = 'fixed' -- Set the mode to spawn the props | random (zones) or fixed | ⚠️ I recommend fixed because random can have collisions etc.
DreamCore.PropSystemFixed = { -- For fixed mode
    { coords = vector3(194.1701, -1053.7688, 28.3114), heading = 105.4966 },
    { coords = vector3(250.7730, -826.2747, 28.7891),  heading = 348.0432 },
    { coords = vector3(2466.7573, 5006.8872, 44.8591), heading = 168.2948 },
    { coords = vector3(-433.1840, 5955.4243, 30.6656), heading = 70.1822 },
}
DreamCore.PropSystemZones = { -- For random mode
    { pos = vector3(222.3756, 2131.8733, 350.000), size = vector2(3300.0, 5500.0) }
}
DreamCore.CheckPropCoords = function(Coords) -- Check if the coords are valid | This also can prevent to spawn fixed positions!
    -- Clientside

    if GetWaterQuadAtCoords(Coords.x, Coords.y) ~= -1 then return false end -- Check if the coords are in the water

    -- Add more checks :)
    return true
end
DreamCore.PropSystemProgressBar = 5000 -- Set the progress bar time to search for a gift
DreamCore.PropSystemTeleportToProp = true -- Set to true if you want to teleport to the prop while animation | Deactivate this when you have problems e.g. The Player falling out of the map while the animation
DreamCore.PropSystemRewards = {
    { type = 'item',   item = 'bread',           amount = { min = 1, max = 5 } },
    { type = 'weapon', weapon = 'weapon_pistol', ammo = { min = 12, max = 24 } },
    { type = 'money',  account = 'bank',         amount = { min = 100, max = 2500 } },
}
DreamCore.PropSystem = {
    {
        model = 'xm3_prop_xm3_snowman_01a',
        blip = {
            sprite = 161,
            color = 0,
            scale = 0.6,
            name = '☃️ Snowman'
        }
    },
    {
        model = 'xm3_prop_xm3_snowman_01b',
        blip = {
            sprite = 161,
            color = 0,
            scale = 0.6,
            name = '☃️ Snowman'
        }
    },
    {
        model = 'xm3_prop_xm3_snowman_01c',
        blip = {
            sprite = 161,
            color = 0,
            scale = 0.6,
            name = '☃️ Snowman'
        }
    }
}

-- Christmas Tree System
DreamCore.ChristmasTreeCooldown = {
    decorate = 30 * 60, -- Set the cooldown to decorate the Christmas tree | In seconds
}
DreamCore.ChristmasTreeProgressBar = {
    decorate = 5000, -- Set the progress bar time to decorate the Christmas tree | In ms
}
DreamCore.ChristmasTreeRewards = {
    decorate = { account = 'money', amount = { min = 100, max = 500 } } -- Set the amount of money to decorate the Christmas tree
}
DreamCore.ChristmasTreeTeleportToProp = true -- Set to true if you want to teleport to the prop while animation
DreamCore.ChristmasTree = {
    {
        id = 'meeting_point',
        model = 'xm_prop_x17_xmas_tree_int',
        coords = vector3(131.3546, -1031.0220, 28.4320),
        heading = 159.9564,
        blip = {
            sprite = 855,
            color = 69,
            scale = 0.9,
            name = '🎄 Christmas Tree'
        }
    },
    {
        id = 'san_andreas_ave',
        model = 'xm_prop_x17_xmas_tree_int',
        coords = vector3(-617.3683, -643.3155, 30.6546),
        heading = 0.0,
        blip = {
            sprite = 855,
            color = 69,
            scale = 0.9,
            name = '🎄 Christmas Tree'
        }
    },
    {
        id = 'davis_ave',
        model = 'xm_prop_x17_xmas_tree_int',
        coords = vector3(-63.7769, -1697.1208, 28.1574),
        heading = 0.0,
        blip = {
            sprite = 855,
            color = 69,
            scale = 0.9,
            name = '🎄 Christmas Tree'
        }
    },
    {
        id = 'panorama_dr',
        model = 'xm_prop_x17_xmas_tree_int',
        coords = vector3(1656.2031, 3600.1863, 34.4232),
        heading = 0.0,
        blip = {
            sprite = 855,
            color = 69,
            scale = 0.9,
            name = '🎄 Christmas Tree'
        }
    },
    {
        id = 'paleto_bay',
        model = 'xm_prop_x17_xmas_tree_int',
        coords = vector3(144.7091, 6494.2085, 30.3744),
        heading = 0.0,
        blip = {
            sprite = 855,
            color = 69,
            scale = 0.9,
            name = '🎄 Christmas Tree'
        }
    },
    {
        id = 'seaview_rd',
        model = 'xm_prop_x17_xmas_tree_int',
        coords = vector3(1900.0555, 4699.8032, 39.3020),
        heading = 0.0,
        blip = {
            sprite = 855,
            color = 69,
            scale = 0.9,
            name = '🎄 Christmas Tree'
        }
    },
    {
        id = 'buen_vino_rd',
        model = 'xm_prop_x17_xmas_tree_int',
        coords = vector3(-2041.0638, 1960.2732, 187.8092),
        heading = 0.0,
        blip = {
            sprite = 855,
            color = 69,
            scale = 0.9,
            name = '🎄 Christmas Tree'
        }
    }
}

-- Present System
DreamCore.ChristmasPresentCooldown = {
    open = 2 * 60 * 60, -- Set the cooldown to claim the Christmas present | In seconds
}
DreamCore.ChristmasPresentProgressBar = {
    open = 5000 -- Set the progress bar time to claim the Christmas present | In ms
}
DreamCore.ChristmasPresentTeleportToProp = true -- Set to true if you want to teleport to the prop while animation
DreamCore.ChristmasPresentRewards = {
    { type = 'item',   item = 'bread',           amount = { min = 1, max = 5 } },
    { type = 'weapon', weapon = 'weapon_pistol', ammo = { min = 12, max = 24 } },
    { type = 'money',  account = 'bank',         amount = { min = 10, max = 250 } },
}
DreamCore.ChristmasPresents = {
    {
        id = 'meeting_point_1',
        model = 'xm3_prop_xm3_present_01a',
        coords = vector3(127.4975, -1025.7442, 28.3574),
        heading = 0.0,
        blip = {
            sprite = 781,
            color = 59,
            scale = 0.6,
            name = '🎁 Christmas Present'
        }
    },
    {
        id = 'meeting_point_2',
        model = 'xm3_prop_xm3_present_01a',
        coords = vector3(138.9978, -1029.6219, 28.3524),
        heading = 0.0,
        blip = {
            sprite = 781,
            color = 59,
            scale = 0.6,
            name = '🎁 Christmas Present'
        }
    },
    {
        id = 'meeting_point_3',
        model = 'xm3_prop_xm3_present_01a',
        coords = vector3(147.3483, -1032.5691, 28.3446),
        heading = 0.0,
        blip = {
            sprite = 781,
            color = 59,
            scale = 0.6,
            name = '🎁 Christmas Present'
        }
    },
    {
        id = 'meeting_point_4',
        model = 'xm3_prop_xm3_present_01a',
        coords = vector3(164.9707, -1038.2676, 28.3233),
        heading = 0.0,
        blip = {
            sprite = 781,
            color = 59,
            scale = 0.6,
            name = '🎁 Christmas Present'
        }
    }
}
