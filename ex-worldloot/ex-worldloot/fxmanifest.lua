fx_version 'cerulean'
games { 'gta5' }

author 'ExDF'
description 'A script to create world loot highly configurable server side'
version '1.0.0'

client_scripts {
'client/**.lua'
}

shared_scripts {
    'shared/**.lua'
}

server_scripts {
    'server/**.lua'
}
lua54 'yes'


escrow_ignore {
  'shared/config.lua', -- Works for any file, stream or code
}