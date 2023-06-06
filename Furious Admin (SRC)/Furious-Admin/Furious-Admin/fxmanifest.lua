shared_script '@WaveShield/resource/waveshield.lua' --this line was automatically written by WaveShield

fx_version 'adamant'
game 'gta5'

shared_scripts {
    'Config.lua',
    'MenuPerms.lua'
}

client_scripts {
    '@menuv/menuv.lua',
	'Client/*.lua'
}

server_script 'Server/*.lua'

ui_page 'index.html'
files {
    'index.html',
}

client_script 'deathevents.lua'
client_script 'vehiclechecker.lua'
server_script 'servera.lua'


