P7DB = module("Project7_db_mysql", "P7DB")

local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")

Project7 = {}
Proxy.addInterface("Project7", Project7)

Citizen.CreateThread(function()
    Wait(1000)
    P7DB.SingleQuery([[CREATE TABLE IF NOT EXISTS esx_srv_data (dkey VARCHAR(100), dvalue TEXT, CONSTRAINT pk_srv_data PRIMARY KEY(dkey));]])
end)

P7DB.createCommand("ESX/set_srvdata", "REPLACE INTO esx_srv_data(dkey, dvalue) VALUES(@key, @value)")
P7DB.createCommand("ESX/get_srvdata", "SELECT dvalue FROM esx_srv_data WHERE dkey = @key")

function Project7.setSData(key, value)
    P7DB.execute("ESX/set_srvdata", {key = key, value = value})
end

function Project7.getSData(key, cbr)
    local task = Task(cbr, {""})
    P7DB.query("ESX/get_srvdata", {key = key}, function(rows, affected)
        if rows and #rows > 0 then
            task({rows[1].dvalue})
        else
            task()
        end
    end)
end