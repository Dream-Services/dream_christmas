-- Do not change anything in this file if you do not know what you are doing!

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Dream Services | Tuncion'
description 'https://discord.gg/zppUXj4JRm'
version '1.0.8'
patch '#89'
released '29.11.2025, 19:15 by Tuncion'

ui_page 'web/index.html'

client_scripts {
    'bridge/**/client.lua',
    'client/functions.lua',
    'client/main.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'settings/DreamCore.lua',
    'settings/locales/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'settings/DreamCoreExt.lua',
    'bridge/**/server.lua',
    'server/main.lua'
}

files {
    'web/*.**',
    'web/**/*.**'
}

exports {
    'ProgressBar'
}

dependencies {
    '/gameBuild:2802', -- FiveM Build 2802+ for the xmas props
    'ox_lib'
}
