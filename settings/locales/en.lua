--[[
    Thank you for using our script. We are happy to have you here. If you need help, you can join our Discord server.
    https://discord.gg/zppUXj4JRm
]]

DreamLocales['en'] = {
    ['NotifyHeader'] = '🎅 Christmas',

    ['PickupSnowball'] = '❄️ You picked up %s snowballs!',
    ['PickupSnowballCooldown'] = '❄️ You can pick up snowballs again in a few seconds!',
    ['PickupSnowballLimit'] = '❄️ You have reached the snowball limit!',
    ['PickupSnowballHelpNotify'] = 'Press ~g~E~s~ to pickup %s snowballs!',

    ['MoneyAccount'] = {
        ['unknown'] = 'Unknown Wallet',
        ['cash'] = 'Cash',
        ['money'] = 'Money',
        ['bank'] = 'Bank',
        ['dirty_money'] = 'Dirty Money'
    },
    ['Weapons'] = {
        ['unknown'] = 'Unknown Weapon',
        ['weapon_pistol'] = 'Pistol',
    },

    ['PropPlacer'] = {
        ['Rotate'] = 'Rotate +/-',
        ['Cancel'] = 'Cancel',
        ['Place'] = 'Place'
    },

    ['PropSystem'] = {
        ['TargetLabel'] = 'Search for a gift',
        ['ProgressBar'] = '🎁 Searching for a gift',
        ['ActivityPopup'] = {
            ['snowman'] = 'Searching for gift...'
        },
        ['Success'] = {
            ['PropSystemClaimedItem'] = '🎁 You found %sx %s',
            ['PropSystemClaimedWeapon'] = '🎁 You found a %s with %s ammo',
            ['PropSystemClaimedMoney'] = '🎁 You found %s$ (%s)'
        },
        ['Error'] = {
            ['PropSystemNotFound'] = '🎁 The gift was not found',
            ['PropSystemAlreadyClaimed'] = '🎁 This gift has already been claimed',
        }
    },

    ['ChristmasTree'] = {
        ['Decorate'] = {
            ['TargetLabel'] = 'Decorate the Christmas tree',
            ['ProgressBar'] = '🎄 Decorating the Christmas tree',
            ['ActivityPopup'] = 'Decorating Tree...',
        },
        ['Success'] = {
            ['ChristmasTreeDecorate'] = '🎄 You have successfully decorated the Christmas tree and got $%s'
        },
        ['Error'] = {
            ['ChristmasTreeInvalid'] = '🎄 The Christmas tree is invalid',
            ['ChristmasTreeAlreadyDecorated'] = '🎄 The Christmas tree has already been decorated'
        }
    },

    ['ChristmasPresent'] = {
        ['Claim'] = {
            ['TargetLabel'] = 'Claim your present',
            ['ProgressBar'] = '🎁 Claiming your present',
            ['ActivityPopup'] = 'Opening Present...',
        },
        ['Success'] = {
            ['ChristmasPresentItem'] = '🎁 You got %sx %s',
            ['ChristmasPresentWeapon'] = '🎁 You got a %s with %s ammo',
            ['ChristmasPresentMoney'] = '🎁 You got %s$ (%s)'
        },
        ['Error'] = {
            ['ChristmasPresentInvalid'] = '🎁 The Christmas present is invalid',
            ['ChristmasPresentAlreadyClaimed'] = '🎁 This Christmas present has already been claimed'
        }
    },

    ['ChristmasSnowman'] = {
        ['Build'] = {
            ['Start'] = '❄️ Build now the snowman!',
        },
        ['Error'] = {
            ['General'] = '❄️ You cannot build a snowman right now!',
            ['AlreadyBuilding'] = '❄️ You are already building a snowman!',
            ['InPropPlacer'] = '❄️ You are already something in the prop placer!',
            ['MaxCountReached'] = '❄️ You have reached the maximum number of snowmen you can build!',
            ['NoCarrotItem'] = '❄️ You do not have a snowman carrot to build a snowman!',
        }
    },

    ['AdventCalendar'] = {
        ['Open'] = {
            ['TargetLabel'] = 'Open the advent calendar',
            ['ProgressBar'] = '🎅 Opening the Advent Calendar',
            ['ActivityPopup'] = 'Opening Calendar...',
        },
        ['Status'] = {
            ['Claimed'] = 'Claimed',
            ['NotClaimed'] = 'Not Claimed',
        },
        ['Success'] = {
            ['AdventCalendarItem'] = '🎅 You got %sx %s',
            ['AdventCalendarWeapon'] = '🎅 You got a %s with %s ammo',
            ['AdventCalendarMoney'] = '🎅 You got %s$ (%s)'
        },
        ['Error'] = {
            ['AdventCalendarNotToday'] = '🎅 You can only claim today\'s gift',
            ['AdventCalendarNotDecember'] = '🎅 The advent calendar is only available in December',
            ['AdventCalendarAlreadyClaimed'] = '🎅 You have already claimed today\'s gift',
            ['AdventCalendarNoReward'] = '🎅 There is no reward for today',
        }
    }
}
