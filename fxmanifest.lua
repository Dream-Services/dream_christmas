-- Do not change anything in this file if you do not know what you are doing!

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Dream Services | Tuncion'
description 'https://discord.gg/zppUXj4JRm'
version '1.0.7'
patch '#82'
released '23.11.2025, 00:32 by Tuncion'

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
    'ox_lib'
}
