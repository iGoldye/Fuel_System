ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent("esx:getSharedObject", function(obj)
            ESX = obj
        end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
	ESX.PlayerData.job = job
end)

models = {
	[1] = -2007231801,
	[2] = 1339433404,
	[3] = 1694452750,
	[4] = 1933174915,
	[5] = -462817101,
	[6] = -469694731,
	[7] = -164877493,
}

blacklistedVehicles = {
	[1] = "BMX",
	[2] = "CRUISER",
	[3] = "FIXTER",
	[4] = "SCORCHER",
	[5] = "TRIBIKE",
	[6] = "TRIBIKE2",
	[7] = "TRIBIKE3",
	[8] = "SEASHARK",
	[9] = "DINGHY",
}

local Vehicles = {}
local pumpLoc = {}

local nearPump = false
local IsFueling = false
local IsFuelingWithJerryCan = false
local InBlacklistedVehicle = false
local NearVehicleWithJerryCan = false
local emEntrega = false

local nveh = nil
local nvehBlip = nil
local quantidade = nil

local price = 0
local cash = 0
local currentCans = 0
local combustivel = 0

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(1)
    end
end

function FuelVehicle()
    local ped = GetPlayerPed(-1)
    local coords = GetEntityCoords(ped)
    local vehicle = GetPlayersLastVehicle()
    FreezeEntityPosition(ped, true)
    FreezeEntityPosition(vehicle, false)
    SetVehicleEngineOn(vehicle, false, false, false)
    loadAnimDict("timetable@gardener@filling_can")
    TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 1.0, 2, -1, 49, 0, 0, 0, 0)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if not InBlacklistedVehicle then
            if nearPump then
				if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
                    ESX.Game.Utils.DrawText3D(vector3(pumpLoc["x"], pumpLoc["y"], pumpLoc["z"] + 0.3), "[~r~Get Out Of The Vehicle To Buy/Fill The Gallon~w~]", 0.8, 4)
				else
                    ESX.Game.Utils.DrawText3D(vector3(pumpLoc["x"], pumpLoc["y"], pumpLoc["z"] + 0.4), "[~b~E~w~ - Buy/Supply Gallon] [~r~Gallon Price~w~: ~r~€200.00~w~]", 0.8, 4)
                    ESX.Game.Utils.DrawText3D(vector3(pumpLoc["x"], pumpLoc["y"], pumpLoc["z"] + 0.2), "[~r~Price to Supply the Gallon~w~: ~r~€150.00~w~]", 0.8, 4)
					if IsControlJustReleased(0, 46) then
						TriggerServerEvent("Project7_Fuel:buyCan", Config.petrolCanPrice)
					end
				end
			end
            if nearPump and IsCloseToLastVehicle then
                local vehicle = GetPlayersLastVehicle()
                local fuel = round(GetVehicleFuelLevel(vehicle), 1)
                local veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
                    if veh and (GetHashKey(Config.caminhao) == GetEntityModel(veh)) and (IsEntityAttachedToEntity(nveh,veh)) then
                        ESX.Game.Utils.DrawText3D(vector3(pumpLoc["x"], pumpLoc["y"], pumpLoc["z"]), "[~b~G~w~ - Fuel Pump] [~r~Fuel Available~w~: ~r~"..pumpLoc["q"].."%~w~]", 0.8, 4)
                        if IsControlJustReleased(0, 47) then
                            FreezeEntityPosition(veh, true)
                            while combustivel > 0 do
                                combustivel = combustivel - 1
                                pumpLoc["q"] = pumpLoc["q"] + 1
                                Wait(Config.veloc_preenche)
                            end
                            TriggerServerEvent("Project7_Fuel:pumpSet", tostring(math.floor(pumpLoc["x"]))..tostring(math.floor(pumpLoc["y"])), pumpLoc["q"])
                            FreezeEntityPosition(veh, false)
                        end
                    else
                        ESX.Game.Utils.DrawText3D(vector3(pumpLoc["x"], pumpLoc["y"], pumpLoc["z"]), "[~r~Get Out Of The Vehicle To Fuel~w~]", 0.8, 4)
                    end
                elseif IsFueling then
                    local position = GetEntityCoords(vehicle)
                    ESX.Game.Utils.DrawText3D(vector3(pumpLoc["x"], pumpLoc["y"], pumpLoc["z"]), "[~b~G~w~ - Cancel Vehicle Supply] [~r~Price~w~: ~r~€"..price.."~w~]", 0.8, 4)
                    ESX.Game.Utils.DrawText3D(vector3(pumpLoc["x"], pumpLoc["y"], pumpLoc["z"] + 0.7), "[~r~Fuel Available~w~: ~r~"..pumpLoc["q"].."%~w~]", 0.8, 4)
                    ESX.Game.Utils.DrawText3D(vector3(position.x, position.y, position.z + 0.5), "[~r~Fuel~w~: "..fuel.."~r~%~w]", 0.8, 4)
                    DisableControlAction(0, 0, true)
                    DisableControlAction(0, 22, true)
					DisableControlAction(0, 23, true)
					DisableControlAction(0, 24, true)
					DisableControlAction(0, 29, true)
					DisableControlAction(0, 30, true)
					DisableControlAction(0, 31, true)
					DisableControlAction(0, 37, true)
					DisableControlAction(0, 44, true)
					DisableControlAction(0, 56, true)
					DisableControlAction(0, 82, true)
					DisableControlAction(0, 140, true)
					DisableControlAction(0, 166, true)
					DisableControlAction(0, 167, true)
					DisableControlAction(0, 168, true)
					DisableControlAction(0, 170, true)
					DisableControlAction(0, 288, true)
					DisableControlAction(0, 289, true)
                    DisableControlAction(1, 323, true)
                    if IsControlJustReleased(0, 47) then
                        loadAnimDict("reaction@male_stand@small_intro@forward")
                        TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)
                        TriggerServerEvent("Project7_Fuel:PayFuel", price)
                        Citizen.Wait(2500)
                        ClearPedTasksImmediately(GetPlayerPed(-1))
                        FreezeEntityPosition(GetPlayerPed(-1), false)
                        FreezeEntityPosition(vehicle, false)
                        price = 0
                        IsFueling = false
                    end
                elseif fuel > 95.0 then
                    ESX.Game.Utils.DrawText3D(vector3(pumpLoc["x"], pumpLoc["y"], pumpLoc["z"]), "[~r~The vehicle is already fueled~w~]", 0.8, 4)
                elseif cash <= 0 then
                    ESX.Game.Utils.DrawText3D(vector3(pumpLoc["x"], pumpLoc["y"], pumpLoc["z"]), "[~r~You have no money to fill the vehicle~w~]", 0.8, 4)
                else
                    ESX.Game.Utils.DrawText3D(vector3(pumpLoc["x"], pumpLoc["y"], pumpLoc["z"]), "[~b~G~w~ - Refueling Vehicle]", 0.8, 4)
                    ESX.Game.Utils.DrawText3D(vector3(pumpLoc["x"], pumpLoc["y"], pumpLoc["z"] - 0.1), "[~b~Price: ~r~€2.00~w~/L] [~r~Fuel Available~w~: ~r~"..pumpLoc["q"].."%~w~]", 0.8, 4)
                    if IsControlJustReleased(0, 47) then
                        local vehicle = GetPlayersLastVehicle()
                        local plate = GetVehicleNumberPlateText(vehicle)
                        ClearPedTasksImmediately(GetPlayerPed(-1))
                        if GetSelectedPedWeapon(GetPlayerPed(-1)) ~= -1569615261 then
                            SetCurrentPedWeapon(GetPlayerPed(-1), -1569615261, true)
                            Citizen.Wait(1000)
                        end
                        IsFueling = true
                        FuelVehicle()
                    end
                end
            elseif NearVehicleWithJerryCan and not nearPump and Config.EnableJerryCans then
                local vehicle = GetPlayersLastVehicle()
                local coords = GetEntityCoords(vehicle)
                local fuel = round(GetVehicleFuelLevel(vehicle), 1)
                local jerrycan = GetAmmoInPedWeapon(GetPlayerPed(-1), 883325847)
                if IsFuelingWithJerryCan then
                    ESX.Game.Utils.DrawText3D(vector3(coords.x, coords.y, coords.z + 0.5), "[~b~G~w~ - Cancel Vehicle Supply] [~r~Fuel~w~: "..fuel.."~r~%~w~]", 0.8, 4)
                    DisableControlAction(0, 0, true)
					DisableControlAction(0, 22, true)
					DisableControlAction(0, 23, true)
					DisableControlAction(0, 24, true)
					DisableControlAction(0, 29, true)
					DisableControlAction(0, 30, true)
					DisableControlAction(0, 31, true)
					DisableControlAction(0, 37, true)
					DisableControlAction(0, 44, true)
					DisableControlAction(0, 56, true)
					DisableControlAction(0, 82, true)
					DisableControlAction(0, 140, true)
					DisableControlAction(0, 166, true)
					DisableControlAction(0, 167, true)
					DisableControlAction(0, 168, true)
					DisableControlAction(0, 170, true)
					DisableControlAction(0, 288, true)
					DisableControlAction(0, 289, true)
                    DisableControlAction(1, 323, true)
                    if IsControlJustReleased(0, 47) then
                        loadAnimDict("reaction@male_stand@small_intro@forward")
                        TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)
                        Citizen.Wait(2500)
                        ClearPedTasksImmediately(GetPlayerPed(-1))
                        FreezeEntityPosition(GetPlayerPed(-1), false)
                        FreezeEntityPosition(vehicle, false)
                        IsFuelingWithJerryCan = false
                    end
                else
                    ESX.Game.Utils.DrawText3D(vector3(coords.x, coords.y, coords.z + 0.5), "[~b~G~w~ - Refuel Vehicle with Gallon]", 0.8, 4)
                    if IsControlJustReleased(0, 47) then
                        local vehicle = GetPlayersLastVehicle()
                        local plate = GetVehicleNumberPlateText(vehicle)
                        ClearPedTasksImmediately(GetPlayerPed(-1))
                        IsFuelingWithJerryCan = true
                        FuelVehicle()
                    end
                end
            end
        else
            Citizen.Wait(500)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if IsFueling then
            local vehicle = GetPlayersLastVehicle()
            local vehicleModel = GetEntityModel(vehicle)
            local plate = GetVehicleNumberPlateText(vehicle)
            local fuel = GetVehicleFuelLevel(vehicle)
            local integer = math.random(42, 60)
            local fuelthis = integer / 10
            local newfuel = fuel + fuelthis
            quantidade = nil
            TriggerServerEvent("Project7_Fuel:pumpGet", tostring(math.floor(pumpLoc["x"]))..tostring(math.floor(pumpLoc["y"])))
            while quantidade == nil do
                Wait(0)
            end
            if (quantidade - fuelthis) > 0 then
                price = price + fuelthis*Config.FuelPrice
                pumpLoc["q"] = quantidade - fuelthis
                TriggerServerEvent("Project7_Fuel:pumpSet", tostring(math.floor(pumpLoc["x"]))..tostring(math.floor(pumpLoc["y"])), pumpLoc["q"])
                if cash >= price then
                    TriggerServerEvent("Project7_Fuel:CheckServerFuelTable", plate, vehicleModel)
                    Citizen.Wait(150)
                    if newfuel < 100 then
                        SetVehicleFuelLevel(vehicle, newfuel)
                        for i = 1, #Vehicles do
                            if Vehicles[i].plate == plate and Vehicles[i].vmodel == vehicleModel then
                                TriggerServerEvent("Project7_Fuel:UpdateServerFuelTable", vehicleModel, plate, round(GetVehicleFuelLevel(vehicle), 1))
                                table.remove(Vehicles, i)
                                table.insert(Vehicles, {vmodel = vehicleModel, plate = plate, fuel = newfuel})
                                break
                            end
                        end
                    else
                        SetVehicleFuelLevel(vehicle, 100.0)
                        loadAnimDict("reaction@male_stand@small_intro@forward")
                        TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)
                        TriggerServerEvent("Project7_Fuel:PayFuel", price)
                        Citizen.Wait(2500)
                        ClearPedTasksImmediately(GetPlayerPed(-1))
                        FreezeEntityPosition(GetPlayerPed(-1), false)
                        FreezeEntityPosition(vehicle, false)
                        price = 0
                        IsFueling = false
                        for i = 1, #Vehicles do
                            if Vehicles[i].plate == plate and Vehicles[i].vmodel == vehicleModel then
                                TriggerServerEvent("Project7_Fuel:UpdateServerFuelTable", vehicleModel, plate, round(GetVehicleFuelLevel(vehicle), 1))
                                table.remove(Vehicles, i)
                                table.insert(Vehicles, {vmodel = vehicleModel, plate = plate, fuel = newfuel})
                                break
                            end
                        end
                    end
                else
                    SetVehicleFuelLevel(vehicle, newfuel)
                    loadAnimDict("reaction@male_stand@small_intro@forward")
                    TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)
                    TriggerServerEvent("Project7_Fuel:PayFuel", price)
                    Citizen.Wait(2500)
                    ClearPedTasksImmediately(GetPlayerPed(-1))
                    FreezeEntityPosition(GetPlayerPed(-1), false)
                    FreezeEntityPosition(vehicle, false)
                    price = 0
                    IsFueling = false
                    for i = 1, #Vehicles do
                        if Vehicles[i].plate == plate and Vehicles[i].vmodel == vehicleModel then
                            TriggerServerEvent("Project7_Fuel:UpdateServerFuelTable", vehicleModel, plate, round(GetVehicleFuelLevel(vehicle), 1))
                            table.remove(Vehicles, i)
                            table.insert(Vehicles, {vmodel = vehicleModel, plate = plate, fuel = newfuel})
                            break
                        end
                    end
                end
            end
        elseif IsFuelingWithJerryCan then
            local vehicle = GetPlayersLastVehicle()
            local vehicleModel = GetEntityModel(vehicle)
            local plate = GetVehicleNumberPlateText(vehicle)
            local fuel = GetVehicleFuelLevel(vehicle)
            local integer = math.random(30, 45)
            local fuelthis = integer / 10
            local newfuel = fuel + fuelthis
			local jerryfuel = fuelthis * 100
			local jerrycurr = GetAmmoInPedWeapon(GetPlayerPed(-1), 883325847)
            local jerrynew = jerrycurr - jerryfuel
            if jerrycurr >= jerryfuel then
                TriggerServerEvent("Project7_Fuel:CheckServerFuelTable", plate, vehicleModel)
                Citizen.Wait(150)
                SetPedAmmo(GetPlayerPed(-1), 883325847, round(jerrynew, 0))
                if newfuel < 100 then
                    SetVehicleFuelLevel(vehicle, newfuel)
                    for i = 1, #Vehicles do
                        if Vehicles[i].plate == plate and Vehicles[i].vmodel == vehicleModel then
                            TriggerServerEvent("Project7_Fuel:UpdateServerFuelTable", vehicleModel, plate, round(GetVehicleFuelLevel(vehicle), 1))
                            table.remove(Vehicles, i)
                            table.insert(Vehicles, {vmodel = vehicleModel, plate = plate, fuel = newfuel})
                            break
                        end
                    end
                else
                    SetVehicleFuelLevel(vehicle, 100.0)
                    loadAnimDict("reaction@male_stand@small_intro@forward")
                    TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)
                    Citizen.Wait(2500)
                    ClearPedTasksImmediately(GetPlayerPed(-1))
                    FreezeEntityPosition(GetPlayerPed(-1), false)
                    FreezeEntityPosition(vehicle, false)
                    IsFuelingWithJerryCan = false
                    for i = 1, #Vehicles do
                        if Vehicles[i].plate == plate and Vehicles[i].vmodel == vehicleModel then
                            TriggerServerEvent("Project7_Fuel:UpdateServerFuelTable", vehicleModel, plate, round(GetVehicleFuelLevel(vehicle), 1))
                            table.remove(Vehicles, i)
                            table.insert(Vehicles, {vmodel = vehicleModel, plate = plate, fuel = newfuel})
                            break
                        end
                    end
                end
            else
                loadAnimDict("reaction@male_stand@small_intro@forward")
                TaskPlayAnim(GetPlayerPed(-1), "reaction@male_stand@small_intro@forward", "react_forward_small_intro_a", 1.0, 2, -1, 49, 0, 0, 0, 0)
                Citizen.Wait(2500)
                ClearPedTasksImmediately(GetPlayerPed(-1))
                FreezeEntityPosition(GetPlayerPed(-1), false)
                FreezeEntityPosition(vehicle, false)
                IsFuelingWithJerryCan = false
                for i = 1, #Vehicles do
                    if Vehicles[i].plate == plate and Vehicles[i].vmodel == vehicleModel then
                        TriggerServerEvent("Project7_Fuel:UpdateServerFuelTable", vehicleModel, plate, round(GetVehicleFuelLevel(vehicle), 1))
                        table.remove(Vehicles, i)
                        table.insert(Vehicles, {vmodel = vehicleModel, plate = plate, fuel = newfuel})
                        break
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1500)
        nearPump = false
        IsCloseToLastVehicle = false
		found = false
        NearVehicleWithJerryCan = false
        local myCoords = GetEntityCoords(GetPlayerPed(-1))
        for i = 1, #models do
            local closestPump = GetClosestObjectOfType(myCoords.x, myCoords.y, myCoords.z, 1.5, models[i], false, false)
            if closestPump ~= nil and closestPump ~= 0 then
                local coords = GetEntityCoords(closestPump)
                local vehicle = GetPlayersLastVehicle()
                if (pumpLoc["x"]) then
                    if (tostring(math.floor(tonumber(coords.x)))..tostring(math.floor(tonumber(coords.y))) ~= tostring(math.floor(tonumber(pumpLoc["x"])))..tostring(math.floor(tonumber(pumpLoc["y"])))) then
                        quantidade = nil
                        TriggerServerEvent("Project7_Fuel:pumpGet", tostring(math.floor(coords.x))..tostring(math.floor(coords.y)))
                        while quantidade == nil do
                            Wait(0)
                        end
                    else
                        quantidade = pumpLoc["q"]
                    end
                else
                    quantidade = nil
                    TriggerServerEvent("Project7_Fuel:pumpGet", tostring(math.floor(coords.x))..tostring(math.floor(coords.y)))
                    while quantidade == nil do
                        Wait(0)
                    end
                end
                nearPump = true
                pumpLoc = {["x"] = coords.x, ["y"] = coords.y, ["z"] = coords.z + 1.2, ["q"] = quantidade}
                if vehicle ~= nil then
                    local vehcoords = GetEntityCoords(vehicle)
                    local mycoords = GetEntityCoords(GetPlayerPed(-1))
                    local distance = GetDistanceBetweenCoords(vehcoords.x, vehcoords.y, vehcoords.z, mycoords.x, mycoords.y, mycoords.z)
                    if distance < 3 then
                        IsCloseToLastVehicle = true
                    end
                end
                break
            end
        end
        if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
            local vehicle = GetPlayersLastVehicle()
			local vehicleModel = GetEntityModel(vehicle)
			local plate = GetVehicleNumberPlateText(vehicle)
			local fuel = GetVehicleFuelLevel(vehicle)
            local found = false
            TriggerServerEvent("Project7_Fuel:CheckServerFuelTable", plate, vehicleModel)
            Citizen.Wait(500)
            for i = 1, #Vehicles do
                if Vehicles[i].plate == plate and Vehicles[i].vmodel == vehicleModel then
                    found = true
                    fuel = round(Vehicles[i].fuel, 1)
                    break
                end
            end
            if not found then
                integer = math.random(200, 800)
                fuel = integer / 10
                table.insert(Vehicles, {vmodel = vehicleModel, plate = plate, fuel = fuel})
                TriggerServerEvent("Project7_Fuel:UpdateServerFuelTable", vehicleModel, plate, fuel)
            end
            SetVehicleFuelLevel(vehicle, fuel)
        end
        local currentVeh = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(GetPlayerPed(-1))))
        for i = 1, #blacklistedVehicles do
            if blacklistedVehicles[i] == currentVeh then
                InBlacklistedVehicle = true
                found = true
                break
            end
        end
        if not found then
            InBlacklistedVehicle = false
        end
        if nearPump then
            TriggerServerEvent("Project7_Fuel:CheckCashOnHand")
        end
        local CurrentWeapon = GetSelectedPedWeapon(GetPlayerPed(-1))
        if CurrentWeapon == 883325847 then
            local MyCoords = GetEntityCoords(GetPlayerPed(-1))
            local Vehicle = GetClosestVehicle(MyCoords.x, MyCoords.y, MyCoords.z, 3.0, false, 23)
            if Vehicle ~= 0 then
                NearVehicleWithJerryCan = true
            end
        end
    end
end)

function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function GetSeatPedIsIn(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    for i = -2, GetVehicleMaxNumberOfPassengers(vehicle) do
        if GetPedInVehicleSeat(vehicle, i) == ped then
            return i
        end
    end
    return -2
end

RegisterNetEvent("Project7_Fuel:ReturnFuelFromServerTable")
AddEventHandler("Project7_Fuel:ReturnFuelFromServerTable", function(vehInfo)
    local fuel = round(vehInfo.fuel, 1)
    for i = 1, #Vehicles do
        if Vehicles[i].plate == vehInfo.plate and Vehicles[i].vmodel == vehInfo.vmodel then
            table.remove(Vehicles, i)
            break
        end
    end
    table.insert(Vehicles, {vmodel = vehInfo.vmodel, plate = vehInfo.plate, fuel = fuel})
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
		local vehicleModel = GetEntityModel(vehicle)
        local engine = Citizen.InvokeNative(0xAE31E7DF9B5B132E, vehicle)
        if vehicle and engine then
            local plate = GetVehicleNumberPlateText(vehicle)
			local rpm = GetVehicleCurrentRpm(vehicle)
			local fuel = GetVehicleFuelLevel(vehicle)
            local rpmfuelusage = 0
            if rpm > 0.9 then
				rpmfuelusage = fuel - rpm / 1.0
				Citizen.Wait(1000)
			elseif rpm > 0.8 then
				rpmfuelusage = fuel - rpm / 1.5
				Citizen.Wait(1500)
			elseif rpm > 0.7 then
				rpmfuelusage = fuel - rpm / 2.8
				Citizen.Wait(2000)
			elseif rpm > 0.6 then
				rpmfuelusage = fuel - rpm / 4.1
				Citizen.Wait(3000)
			elseif rpm > 0.5 then
				rpmfuelusage = fuel - rpm / 5.7
				Citizen.Wait(4000)
			elseif rpm > 0.4 then
				rpmfuelusage = fuel - rpm / 6.4
				Citizen.Wait(5000)
			elseif rpm > 0.3 then
				rpmfuelusage = fuel - rpm / 6.9
				Citizen.Wait(6000)
			elseif rpm > 0.2 then
				rpmfuelusage = fuel - rpm / 7.3
				Citizen.Wait(8000)
			else
				rpmfuelusage = fuel - rpm / 7.4
				Citizen.Wait(15000)
            end
            for i = 1, #Vehicles do
                if Vehicles[i].plate == plate and Vehicles[i].vmodel == vehicleModel then
                    SetVehicleFuelLevel(vehicle, rpmfuelusage)
                    local updatedfuel = round(GetVehicleFuelLevel(vehicle), 1)
                    if updatedfuel ~= 0 then
                        TriggerServerEvent("Project7_Fuel:UpdateServerFuelTable", vehicleModel, plate, updatedfuel)
                        table.remove(Vehicles, i)
                        table.insert(Vehicles, {vmodel = vehicleModel, plate = plate, fuel = rpmfuelusage})
                    end
                    break
                end
            end
            if rpmfuelusage < Config.VehicleFailure then
				SetVehicleUndriveable(vehicle, true)
			elseif rpmfuelusage == 0 then
				SetVehicleEngineOn(vehicle, false, false, false)
			else
				SetVehicleUndriveable(vehicle, false)
            end
        end
    end
end)

RegisterNetEvent("Project7_Fuel:RecieveCashOnHand")
AddEventHandler("Project7_Fuel:RecieveCashOnHand", function(cb)
    cash = cb
end)

RegisterNetEvent("Project7_Fuel:pumpGet")
AddEventHandler("Project7_Fuel:pumpGet", function(cb)
	quantidade = cb
end)

local gas_stations = {
	{["x"] = 49.4187, ["y"] = 2778.793, ["z"] = 58.043, ["id"] = 1},
 	{["x"] = 263.894, ["y"] = 2606.463, ["z"] = 44.983, ["id"] = 2},
 	{["x"] = 1039.958, ["y"] = 2671.134, ["z"] = 39.550, ["id"] = 3},
 	{["x"] = 1207.260, ["y"] = 2660.175, ["z"] = 37.899, ["id"] = 4},
 	{["x"] = 2539.685, ["y"] = 2594.192, ["z"] = 37.944, ["id"] = 5},
 	{["x"] = 2679.858, ["y"] = 3263.946, ["z"] = 55.240, ["id"] = 6},
 	{["x"] = 2005.055, ["y"] = 3773.887, ["z"] = 32.403, ["id"] = 7},
 	{["x"] = 1687.156, ["y"] = 4929.392, ["z"] = 42.078, ["id"] = 8},
 	{["x"] = 1701.314, ["y"] = 6416.028, ["z"] = 32.763, ["id"] = 9},
 	{["x"] = 179.857, ["y"] = 6602.839, ["z"] = 31.868, ["id"] = 10},
 	{["x"] = -94.4619, ["y"] = 6419.594, ["z"] = 31.489, ["id"] = 11},
 	{["x"] = -2554.996, ["y"] = 2334.40, ["z"] = 33.078, ["id"] = 12},
 	{["x"] = -1800.375, ["y"] = 803.661, ["z"] = 138.651, ["id"] = 13},
 	{["x"] = -1437.622, ["y"] = -276.747, ["z"] = 46.207, ["id"] = 14},
 	{["x"] = -2096.243, ["y"] = -320.286, ["z"] = 13.168, ["id"] = 15},
 	{["x"] = -724.619, ["y"] = -935.1631, ["z"] = 19.213, ["id"] = 16},
 	{["x"] = -526.019, ["y"] = -1211.003, ["z"] = 18.184, ["id"] = 17},
 	{["x"] = -70.2148, ["y"] = -1761.792, ["z"] = 29.534, ["id"] = 18},
 	{["x"] = 265.648, ["y"] = -1261.309, ["z"] = 29.292, ["id"] = 19},
 	{["x"] = 819.653, ["y"] = -1028.846, ["z"] = 26.403, ["id"] = 20},
 	{["x"] = 1208.951, ["y"] = -1402.567, ["z"] = 35.224, ["id"] = 21},
 	{["x"] = 1181.381, ["y"] = -330.847, ["z"] = 69.316, ["id"] = 22},
 	{["x"] = 620.843, ["y"] = 269.100, ["z"] = 103.089, ["id"] = 23},
 	{["x"] = 2581.321, ["y"] = 362.039, ["z"] = 108.468, ["id"] = 24},
}

Citizen.CreateThread(function()
    if Config.EnableBlips then
        for k, v in ipairs(gas_stations) do
            local blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(blip, 361)
			SetBlipScale(blip, 0.9)
			SetBlipColour(blip, 6)
			SetBlipDisplay(blip, 4)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Fuel station")
            EndTextCommandSetBlipName(blip)
        end
    end
end)

Citizen.CreateThread(function()
    local x = Config.local_caminhao[1]
    local y = Config.local_caminhao[2]
    local z = Config.local_caminhao[3]
    local h = Config.local_caminhao[4]
    while true do
        Wait(0)
        if not emEntrega then
            local pos = GetEntityCoords(GetPlayerPed(-1))
            if (Vdist(pos.x, pos.y, pos.z, x, y, z) < 20.0) then
                DrawMarker(27, x, y, z-0.9, 0, 0, 0, 0, 0, 0, 2.0001, 2.0001, 0.5001, 132, 52, 0,255, 0, 0, 0,0)
            end
            if (Vdist(pos.x, pos.y, pos.z, x, y, z) < 2.0) then
                ESX.Game.Utils.DrawText3D(vector3(x, y, z), "[~b~Oil Center~w~]\n[~g~E~w~] Remove the Truck", 0.8, 4)
                if IsControlJustPressed(1, 38) then
                    --if ESX.PlayerData.job and ESX.PlayerData.job.name == "fuel" then
                        emEntrega = true
                        combustivel = 0
                        spawnVeiculo(Config.caminhao, x, y, z, h, false)
                        spawnVeiculo(Config.carga, Config.local_carga[1], Config.local_carga[2], Config.local_carga[3], Config.local_carga[4], true)
                        SetVehicleFuelLevel(Config.caminhao, 100)
                    --end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local pos = GetEntityCoords(GetPlayerPed(-1))
        for k, v in pairs(Config.Local_CaminhaoGuardar)do
            if (Vdist(pos.x, pos.y, pos.z, v[1], v[2], v[3]) < 20.0) then
                DrawMarker(27, v[1], v[2], v[3]-0.9, 0, 0, 0, 0, 0, 0, 2.0001, 2.0001, 0.5001, 132, 52, 0,255, 0, 0, 0,0)
            end
            if (Vdist(pos.x, pos.y, pos.z, v[1], v[2], v[3]) < 2.0) then
                ESX.Game.Utils.DrawText3D(vector3(v[1], v[2], v[3]), "[~b~Oil Center~w~]\n[~g~E~w~] Save the Truck", 0.8, 4)
                if IsControlJustPressed(1, 38) then
                    --if ESX.PlayerData.job and ESX.PlayerData.job.name == "fuel" then
                        combustivel = 0
                        local ped = GetPlayerPed(-1)
                        local veh = nil
                        if (IsPedSittingInAnyVehicle(ped)) then
                            veh = GetVehiclePedIsIn(ped, false)
                        end
                        if IsEntityAVehicle(veh) then
                            ESX.Game.DeleteVehicle(veh)
                            SetVehicleHasBeenOwnedByPlayer(veh, false)
                            --exports["vrp_notify"]:SendAlert("success", "Veiculo Guardado", 2500, {
                                --["background-color"] = "green",
                                --["color"] = "white"
                            --})
                        else
                            --exports["vrp_notify"]:SendAlert("error", "Tu Estás Muito Longe do Veiculo", 2500, {
                                --["background-color"] = "red",
                                --["color"] = "white"
                            --})
                        end
                    --end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local pos = GetEntityCoords(GetPlayerPed(-1))
        for k, v in pairs(Config.abastecimentos) do
            if emEntrega then
                if (Vdist(pos.x, pos.y, pos.z, v[1], v[2], v[3]) < 20.0) then
                    DrawMarker(27, v[1], v[2], v[3]-0.9, 0, 0, 0, 0, 0, 0, 2.0001, 2.0001, 0.5001, 132, 52, 0,255, 0, 0, 0,0)
                end
                if (Vdist(pos.x, pos.y, pos.z, v[1], v[2], v[3]) < 2.0) then
                    ESX.Game.Utils.DrawText3D(vector3(v[1], v[2], v[3]), "[~b~E~w~ - Fuel Truck]", 0.8, 4)
                    if IsControlJustPressed(1, 38) then
                        abastecer()
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if nveh then
            local pos = GetEntityCoords(nveh)
            local pedPos = GetEntityCoords(GetPlayerPed(-1))
            if (Vdist(pos.x, pos.y, pos.z, pedPos.x, pedPos.y, pedPos.z) < 20.0) then
                ESX.Game.Utils.DrawText3D(vector3(pos.x, pos.y, pos.z), "[~b~Tank~w~: - "..combustivel.."% Liters]", 1.0, 4)
            end
            if (IsEntityDead(nveh)) then
                nveh = nil
                emEntrega = false
            end
        end
    end
end)

function spawnVeiculo(name, x, y, z, h, blip)
    local mhash = GetHashKey(name)
    while not HasModelLoaded(mhash) do
        RequestModel(mhash)
        Citizen.Wait(10)
    end
    if HasModelLoaded(mhash) then
        nveh = CreateVehicle(mhash, x, y, z+0.5, h, true, false)
        if blip then
            nvehBlip = AddBlipForEntity(nveh)
            SetBlipSprite(nvehBlip, 68)
            SetBlipColour(nvehBlip, 2)
        else
            SetPedIntoVehicle(GetPlayerPed(-1), nveh, -1)
        end
        local netveh = VehToNet(nveh)
        local id = NetworkGetNetworkIdFromEntity(nveh)
        SetNetworkIdCanMigrate(id, true)
        SetVehRadioStation(netveh, "OFF")
        SetVehicleNumberPlateText(NetToVeh(netveh), "TRUCK")
        Citizen.InvokeNative(0xAD738C3085FE7E11, NetToVeh(netveh), true, true)
		SetVehicleHasBeenOwnedByPlayer(NetToVeh(netveh), true)
		SetVehicleNeedsToBeHotwired(NetToVeh(netveh), false)
        SetModelAsNoLongerNeeded(mhash)
    end
end

function abastecer()
    local veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
    if veh then
        if (GetHashKey(Config.caminhao) == GetEntityModel(veh)) and (IsEntityAttachedToEntity(nveh, veh)) then
            FreezeEntityPosition(veh, true)
            while combustivel < Config.tam_carga do
                combustivel = combustivel + 1
                Wait(Config.veloc_preenche)
            end
            FreezeEntityPosition(veh, false)
        end
    end
end