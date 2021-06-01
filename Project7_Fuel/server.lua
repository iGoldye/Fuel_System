local Tunnel = module("Project7_Base", "lib/Tunnel")
local Proxy = module("Project7_Base", "lib/Proxy")

Project7 = Proxy.getInterface("Project7")

TriggerEvent("esx:getSharedObject", function(obj)
	ESX = obj
end)

RegisterServerEvent("Project7_Fuel:pumpGet")
AddEventHandler("Project7_Fuel:pumpGet", function(pump)
    local source = source
    Project7.getSData({pump, function(datas)
        local data = json.decode(datas)
        if not data then
            data = 0
        end
        TriggerClientEvent("Project7_Fuel:pumpGet", source, data)
    end})
end)

RegisterServerEvent("Project7_Fuel:pumpSet")
AddEventHandler("Project7_Fuel:pumpSet", function(pump, q)
    local source = source
    Project7.setSData({pump, json.encode(q)})
end)

RegisterServerEvent("Project7_Fuel:PayFuel")
AddEventHandler("Project7_Fuel:PayFuel", function(price)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local amount = round(price, 0)
    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(amount)
        print("You Paid €"..amount.."")
    else
        print("You have no money")
    end
end)

local Vehicles = {
    {
        vmodel = "nil",
        plate = "nil",
        fuel = 100
    }
}

RegisterServerEvent("Project7_Fuel:UpdateServerFuelTable")
AddEventHandler("Project7_Fuel:UpdateServerFuelTable", function(vmodel, plate, fuel)
    local found = false
    for i = 1, #Vehicles do
        if Vehicles[i].plate == plate and Vehicles[i].vmodel == vmodel then
            found = true
            if fuel ~= Vehicles[i].fuel then
                table.remove(Vehicles, i)
                table.insert(Vehicles, {vmodel = vmodel, plate = plate, fuel = fuel})
            end
            break
        end
    end
    if not found then
        table.insert(Vehicles, {vmodel = vmodel, plate = plate, fuel = fuel})
    end
end)

RegisterServerEvent("Project7_Fuel:CheckServerFuelTable")
AddEventHandler("Project7_Fuel:CheckServerFuelTable", function(plate, vmodel)
    for i = 1, #Vehicles do
        if Vehicles[i].plate == plate and Vehicles[i].vmodel == vmodel then
            local vehInfo = {vmodel = Vehicles[i].vmodel, plate = Vehicles[i].plate, fuel = Vehicles[i].fuel}
            TriggerClientEvent("Project7_Fuel:ReturnFuelFromServerTable", source, vehInfo)
            break
        end
    end
end)

RegisterServerEvent("Project7_Fuel:CheckCashOnHand")
AddEventHandler("Project7_Fuel:CheckCashOnHand", function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local cb = xPlayer.getMoney()
    TriggerClientEvent("Project7_Fuel:RecieveCashOnHand", source, cb)
end)

function dump(o)
    if type(o) == "table" then
        local s = "{ "
        for k, v in pairs(o) do
            if type(k) ~= "number" then
                k = ""..k..""
            end
            s = s .. "["..k.."] = " .. dump(v) .. ","
        end
        return s .. "} "
    else
        return tostring(o)
    end
end

RegisterServerEvent("Project7_Fuel:buyCan")
AddEventHandler("Project7_Fuel:buyCan", function(price)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        xPlayer.addInventoryItem("WEAPON_PETROLCAN", 1)
        print("You Purchased a Gallon")
    else
        print("You have no money")
    end
end)

function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end