fx_version "adamant"

game "gta5"

dependency "Project7_Base"

client_scripts {"lib/Tunnel.lua", "lib/Proxy.lua", "client.lua", "config.lua"}
server_scripts {"@Project7_Base/lib/utils.lua", "server.lua", "config.lua"}