-----------------For support, scripts, and more----------------
----------------- https://discord.gg/XJFNyMy3Bv ---------------
---------------------------------------------------------------

local version = nil

if GetResourceState("es_extended") == "started" or GetResourceState("es_extended") == "starting" then
    version = GetResourceMetadata("es_extended", "version")
    if version < "1.3.0" then
        Citizen.CreateThread(function()
            while ESX == nil do
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                Citizen.Wait(0)
            end
        end)

		Citizen.CreateThread(function()
			Citizen.Wait(4000)
			print("^0[^2INFO^0] Script successfully started!")
			print("^0[^2INFO^0] ESX Version detected: ^2" .. version .. "^0")
		end)
    elseif version >= "1.3.0" then
        ESX = exports["es_extended"]:getSharedObject()

		Citizen.CreateThread(function()
			Citizen.Wait(4000)
			print("^0[^2INFO^0] Script successfully started!")
			print("^0[^2INFO^0] ESX Version detected: ^2" .. version .. "^0")
		end)
    else
        Citizen.CreateThread(function()
            Citizen.Wait(4000)
            print("^0[^1ERROR^0] ^3Could not initialized ESX Version!")
            print("^0[^1ERROR^0] ^3Script may not work!")
        end)
	end
end

MySQL.ready(function()
	MySQL.Sync.execute(
		"CREATE TABLE IF NOT EXISTS `outfits` (" ..
			"`id` int NOT NULL AUTO_INCREMENT, " ..
			"`identifier` varchar(60) NOT NULL, " ..
			"`name` longtext, " ..
			"`ped` longtext, " ..
			"`components` longtext, " ..
			"`props` longtext, " ..
			"PRIMARY KEY (`id`), " ..
			"UNIQUE KEY `id_UNIQUE` (`id`) " ..
		") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8; "
	)
end)

RegisterServerEvent('fivem-appearance:save')
AddEventHandler('fivem-appearance:save', function(appearance)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local payment = Config.PriceClothingShop
	xPlayer.removeAccountMoney('bank', payment)
	MySQL.Async.execute('UPDATE users SET skin = @skin WHERE identifier = @identifier', {
		['@skin'] = json.encode(appearance),
		['@identifier'] = xPlayer.identifier
	})
end)

ESX.RegisterServerCallback('fivem-appearance:getPlayerSkin', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT skin FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(users)
		local user, appearance = users[1]
		if user.skin then
			appearance = json.decode(user.skin)
		end
		cb(appearance)
	end)
end)

--- ej added start ---
RegisterServerEvent('fivem-appearance:saveOut')
AddEventHandler('fivem-appearance:saveOut', function(appearance)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.execute('UPDATE users SET skin = @skin WHERE identifier = @identifier', {
		['@skin'] = json.encode(appearance),
		['@identifier'] = xPlayer.identifier
	})
end)


RegisterServerEvent('fivem-appearance:saveEjSurgery')
AddEventHandler('fivem-appearance:saveEjSurgery', function(appearance)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local payment = Config.PriceEjSurgery
	xPlayer.removeAccountMoney('bank', payment)
	MySQL.Async.execute('UPDATE users SET skin = @skin WHERE identifier = @identifier', {
		['@skin'] = json.encode(appearance),
		['@identifier'] = xPlayer.identifier
	})
end)

RegisterServerEvent('fivem-appearance:saveBarberShop')
AddEventHandler('fivem-appearance:saveBarberShop', function(appearance)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local payment = Config.PriceBarberShop
	xPlayer.removeAccountMoney('bank', payment)
	MySQL.Async.execute('UPDATE users SET skin = @skin WHERE identifier = @identifier', {
		['@skin'] = json.encode(appearance),
		['@identifier'] = xPlayer.identifier
	})
end)

RegisterServerEvent('fivem-appearance:saveTattooShop')
AddEventHandler('fivem-appearance:saveTattooShop', function(appearance)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local payment = Config.PriceTattooShop
	xPlayer.removeAccountMoney('bank', payment)
	MySQL.Async.execute('UPDATE users SET skin = @skin WHERE identifier = @identifier', {
		['@skin'] = json.encode(appearance),
		['@identifier'] = xPlayer.identifier
	})
end)

--- ej added end ---

RegisterServerEvent("fivem-appearance:saveOutfit")
AddEventHandler("fivem-appearance:saveOutfit", function(name, pedModel, pedComponents, pedProps)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.insert('INSERT INTO `outfits` (`identifier`, `name`, `ped`, `components`, `props`) VALUES (@identifier, @name, @ped, @components, @props)', {
		['@ped'] = json.encode(pedModel),
		['@components'] = json.encode(pedComponents),
		['@props'] = json.encode(pedProps),
		['@name'] = name,
		['@identifier'] = xPlayer.identifier
	})
end)

ESX.RegisterServerCallback('fivem-appearance:getOutfits', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local outfits = {}
    MySQL.Async.fetchAll('SELECT id, name, ped, components, props FROM outfits WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		for i=1, #result, 1 do
			table.insert(outfits, {id = result[i].id, name = result[i].name, ped = json.decode(result[i].ped), components = json.decode(result[i].components), props = json.decode(result[i].props)})
		end
        if outfits then
		    cb(outfits)
        else
            cb(false)
        end
	end)
end)

RegisterServerEvent("fivem-appearance:deleteOutfit")
AddEventHandler("fivem-appearance:deleteOutfit", function(id)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.execute('DELETE FROM `outfits` WHERE `id` = @id', {
		['@id'] = id
	})
end)

-- ESX Skin Compatibility

getGender = function(model)
    if model == 'mp_f_freemode_01' then
        return 1
    else
        return 0
    end
end

ESX.RegisterServerCallback('esx_skin:getPlayerSkin', function(source, cb)
	if ESX.PlayerLoaded then
		local xPlayer = ESX.GetPlayerFromId(source)
		MySQL.Async.fetchAll('SELECT skin FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		}, function(users)
			local user, appearance = users[1]
			local jobSkin = {
				skin_male   = xPlayer.job.skin_male,
				skin_female = xPlayer.job.skin_female
			}
			if user.skin then
				appearance = json.decode(user.skin)
			end
			appearance.sex = getGender(appearance.model)
			cb(appearance, jobSkin)
		end)
	end
end)

ESX.RegisterCommand('skin', 'admin', function(xPlayer)
	xPlayer.triggerEvent('fivem-appearance:skinCommand')
end, false, {help = 'Change Skin'})

ESX.RegisterUsableItem('surgerycard', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.triggerEvent('fivem-appearance:EjSurgery')
end)

RegisterNetEvent('ej:removesurgerycard')
AddEventHandler('ej:removesurgerycard',function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('surgerycard', 1)
end)