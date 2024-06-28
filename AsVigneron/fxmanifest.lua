fx_version 'cerulean'
game 'gta5'

author 'Astrxwrld'
description 'Job Vigneron utilisant RageUI et ESX'
version '1.0.0'
shared_script 'config.lua'


client_scripts {
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",

    "src/components/*.lua",

    "src/menu/elements/*.lua",

    "src/menu/items/*.lua",

    "src/menu/panels/*.lua",

    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua",

}


client_scripts {
    'client/*.lua',
    '@es_extended/locale.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'config.lua',
    'server/main.lua'
}

dependencies {
    'es_extended',
}
