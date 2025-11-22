--[[
    Thank you for using our script. We are happy to have you here. If you need help, you can join our Discord server.
    https://discord.gg/zppUXj4JRm
]]

-- 💬 This is a extension for the DreamCore
-- This file is only available for the serverside and contains the data the client should NEVER EVER see!!

DreamCore.Webhooks = {
    Enabled = true,

    -- Base Data
    Color = '10169855', -- Change the Color of the Webhook
    Author = 'Dream Christmas', -- Change the Author of the Webhook
    IconURL = 'https://i.ibb.co/KNS96CM/dreamservices-round.png', -- Change the IconURL of the Webhook

    -- Webhook URLs
    PropSystemReward = 'https://discord.com/api/webhooks/XXX/XXX',
    DecorateChristmasTree = 'https://discord.com/api/webhooks/XXX/XXX',
    ChristmasPresent = 'https://discord.com/api/webhooks/XXX/XXX',
    ChristmasAdventCalendar = 'https://discord.com/api/webhooks/XXX/XXX',
}

-- 🎄 Advent Calendar Configuration
DreamCore.AdventCalendar.days = {
    -- This are just examples. Please adjust the rewards to your liking.
    -- ℹ️ Note: No worry the players can't leak the next rewards, because we don't send future data ;)

    [1] = {
        label = 'Bread (1-2)', -- Label shown in the calendar
        image = 'https://cdn-icons-png.flaticon.com/512/3348/3348075.png', -- Direct link or relative path to image (e.g. 'assets/img/gift.png')
        reward = { type = 'item', item = 'bread', amount = { min = 1, max = 2 } }, -- Reward given when opening the day
    },

    [2] = {
        label = 'Bank (50–150)',
        image = 'https://cdn-icons-png.flaticon.com/512/8983/8983163.png',
        reward = { type = 'money', account = 'bank', amount = { min = 50, max = 150 } },
    },

    [3] = {
        label = 'Water (1-2)',
        image = 'https://cdn-icons-png.flaticon.com/512/2447/2447764.png',
        reward = { type = 'item', item = 'water', amount = { min = 1, max = 2 } },
    },

    [4] = {
        label = 'Cash (20–80)',
        image = 'https://cdn-icons-png.flaticon.com/512/7630/7630510.png',
        reward = { type = 'money', account = 'cash', amount = { min = 20, max = 80 } },
    },

    [5] = {
        label = 'Bank (250-300)',
        image = 'https://cdn-icons-png.flaticon.com/512/8983/8983163.png',
        reward = { type = 'money', account = 'bank', amount = { min = 250, max = 300 } },
    },

    [6] = {
        label = 'Surprise',
        image = 'https://cdn-icons-png.flaticon.com/512/9011/9011713.png',
        reward = { type = 'money', account = 'bank', amount = { min = 1000, max = 2000 } },
    },

    [7] = {
        label = 'Pistol',
        image = 'https://cdn-icons-png.flaticon.com/512/3857/3857393.png',
        reward = { type = 'weapon', weapon = 'weapon_pistol', ammo = { min = 50, max = 100 } },
    },

    [8] = {
        label = 'Cash (45–90)',
        image = 'https://cdn-icons-png.flaticon.com/512/7630/7630510.png',
        reward = { type = 'money', account = 'cash', amount = { min = 45, max = 90 } },
    },

    [9] = {
        label = 'Sandwich (1–3)',
        image = 'https://cdn-icons-png.flaticon.com/512/8512/8512379.png',
        reward = { type = 'item', item = 'sandwich', amount = { min = 1, max = 3 } },
    },

    [10] = {
        label = 'Bank (120–220)',
        image = 'https://cdn-icons-png.flaticon.com/512/8983/8983163.png',
        reward = { type = 'money', account = 'bank', amount = { min = 120, max = 220 } },
    },

    [11] = {
        label = 'Cola (1–2)',
        image = 'https://cdn-icons-png.flaticon.com/512/1257/1257653.png',
        reward = { type = 'item', item = 'cola', amount = { min = 1, max = 2 } },
    },

    [12] = {
        label = 'Cash (60–120)',
        image = 'https://cdn-icons-png.flaticon.com/512/7630/7630510.png',
        reward = { type = 'money', account = 'cash', amount = { min = 60, max = 120 } },
    },

    [13] = {
        label = 'Phone',
        image = 'https://cdn-icons-png.flaticon.com/512/2482/2482945.png',
        reward = { type = 'item', item = 'phone', amount = { min = 1, max = 2 } },
    },

    [14] = {
        label = 'Burger (1–2)',
        image = 'https://cdn-icons-png.flaticon.com/512/878/878052.png',
        reward = { type = 'item', item = 'burger', amount = { min = 1, max = 2 } },
    },

    [15] = {
        label = 'Bank (200–350)',
        image = 'https://cdn-icons-png.flaticon.com/512/8983/8983163.png',
        reward = { type = 'money', account = 'bank', amount = { min = 200, max = 350 } },
    },

    [16] = {
        label = 'Ammo (25–50)',
        image = 'https://cdn-icons-png.flaticon.com/512/3836/3836818.png',
        reward = { type = 'weapon_ammo', weapon = 'WEAPON_PISTOL', ammo = { min = 25, max = 50 } },
    },

    [17] = {
        label = 'Water (1–3)',
        image = 'https://cdn-icons-png.flaticon.com/512/2447/2447764.png',
        reward = { type = 'item', item = 'water', amount = { min = 1, max = 3 } },
    },

    [18] = {
        label = 'Cash (80–160)',
        image = 'https://cdn-icons-png.flaticon.com/512/7630/7630510.png',
        reward = { type = 'money', account = 'cash', amount = { min = 80, max = 160 } },
    },

    [19] = {
        label = 'Repairkit',
        image = 'https://cdn-icons-png.flaticon.com/512/479/479404.png',
        reward = { type = 'item', item = 'repairkit', amount = { min = 1, max = 2 } },
    },

    [20] = {
        label = 'Bandage (1–2)',
        image = 'https://cdn-icons-png.flaticon.com/512/4302/4302186.png',
        reward = { type = 'item', item = 'bandage', amount = { min = 1, max = 2 } },
    },

    [21] = {
        label = 'Bank (300–500)',
        image = 'https://cdn-icons-png.flaticon.com/512/8983/8983163.png',
        reward = { type = 'money', account = 'bank', amount = { min = 300, max = 500 } },
    },

    [22] = {
        label = 'Cash (100–180)',
        image = 'https://cdn-icons-png.flaticon.com/512/7630/7630510.png',
        reward = { type = 'money', account = 'cash', amount = { min = 100, max = 180 } },
    },

    [23] = {
        label = 'First Aid Kit',
        image = 'https://cdn-icons-png.flaticon.com/512/5043/5043367.png',
        reward = { type = 'item', item = 'firstaid', amount = { min = 1, max = 2 } },
    },

    [24] = {
        label = 'Big Surprise 🎄',
        image = 'https://cdn-icons-png.flaticon.com/512/744/744546.png',
        reward = { type = 'money', account = 'bank', amount = { min = 2000, max = 4000 } },
    }
}
