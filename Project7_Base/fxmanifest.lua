fx_version "cerulean"

game "gta5"

dependency "ghmattimysql"
dependency "Project7_db_mysql"

server_scripts {"lib/utils.lua", "base.lua"}

client_scripts {"lib/utils.lua", "client/snippets.lua"}