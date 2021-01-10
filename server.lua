ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local function checkExistenceClothes(cid, cb)
   -- MySQL.Async.fetchall("SELECT cid FROM character_current WHERE cid = @cid LIMIT 1;", {["cid"] = cid}, function(result)
        MySQL.Async.fetchAll('SELECT cid FROM character_current WHERE cid = @cid LIMIT 1', {['@cid'] = cid}, function(result)
        local exists = result and result[1] and true or false
        cb(exists)
    end)
end




local function checkExistenceFace(cid, cb)
        MySQL.Async.fetchAll('SELECT identifier FROM users WHERE identifier = @identifier LIMIT 1', {['@identifier'] = cid}, function(result)
        local exists = result and result[1] and true or false
        cb(exists)
    end)
end

ESX.RegisterServerCallback('raid_clothes:getSex', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {["identifier"] = xPlayer.identifier}, function(result)
        cb(result[1].sex)
    end)
  end)



RegisterServerEvent("raid_clothes:insert_character_current")
AddEventHandler("raid_clothes:insert_character_current",function(data)
    if not data then return end
    local src = source
    local user = ESX.GetPlayerFromId(source)
    local characterId = user.identifier
    if not characterId then return end
    checkExistenceClothes(characterId, function(exists)
        local values = {
            ["identifier"] = characterId,
            ["model"] = json.encode(data.model),
            ["drawables"] = json.encode(data.drawables),
            ["props"] = json.encode(data.props),
            ["drawtextures"] = json.encode(data.drawtextures),
            ["proptextures"] = json.encode(data.proptextures),
        }

        if not exists then
            local cols = "identifier, model, drawables, props, drawtextures, proptextures"
            local vals = "@identifier, @model, @drawables, @props, @drawtextures, @proptextures"
            local set = "model = @model,drawables = @drawables,props = @props,drawtextures = @drawtextures,proptextures = @proptextures"
            MySQL.Async.execute("UPDATE users SET "..set.." WHERE identifier = @identifier", values, function()
            end)
            return
        end
        print(values)
        local set = "model = @model,drawables = @drawables,props = @props,drawtextures = @drawtextures,proptextures = @proptextures"
        MySQL.Async.execute("UPDATE users SET "..set.." WHERE identifier = @identifier", values)
    end)
end)

RegisterServerEvent("raid_clothes:insert_character_skin")
AddEventHandler("raid_clothes:insert_character_skin",function(data)
    if not data then return end
    local src = source
    local user = ESX.GetPlayerFromId(source)
    local characterId = user.identifier
    if not characterId then return end
    checkExistenceClothes(characterId, function(exists)

        MySQL.Async.execute('UPDATE users SET skin = @skin WHERE identifier = @identifier', {
            ['@skin'] = json.encode(data.drawables)..json.encode(data.props)..json.encode(data.drawtextures)..json.encode(data.proptextures),
            ['@identifier'] =characterId
        })

    end)
end)



RegisterServerEvent("raid_clothes:insert_character_face")
AddEventHandler("raid_clothes:insert_character_face",function(data)
    if not data then return end
    local src = source
    local user = ESX.GetPlayerFromId(source)
    local characterId = user.identifier
    if not characterId then return end
    checkExistenceFace(characterId, function(exists)
        local values = {
            ["identifier"] = characterId,
            ["hairColor"] = json.encode(data.hairColor),
            ["headBlend"] = json.encode(data.headBlend),
            ["headOverlay"] = json.encode(data.headOverlay),
            ["headStructure"] = json.encode(data.headStructure),
      
        }

        if not exists then
            local cols = "identifier, hairColor, headBlend, headOverlay, headStructure"
            local vals = "@identifier, @hairColor, @headBlend, @headOverlay, @headStructure"
            local set = "hairColor = @hairColor,headBlend = @headBlend,headOverlay = @headOverlay,headStructure = @headStructure"
            MySQL.Async.execute("UPDATE users SET "..set.." WHERE identifier = @identifier", values, function()
            end)
            return
        end

        local set = "hairColor = @hairColor,headBlend = @headBlend,headOverlay = @headOverlay,headStructure = @headStructure"
        MySQL.Async.execute("UPDATE users SET "..set.." WHERE identifier = @identifier", values)
    end)
end)


RegisterServerEvent("raid_clothes:get_character_face")
AddEventHandler("raid_clothes:get_character_face",function(pSrc)
    local src = (not pSrc and source or pSrc)
    local user = ESX.GetPlayerFromId(source)
    local characterId = user.identifier

    if not characterId then return end
    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {['@identifier'] = characterId}, function(result)
        local temp_data = {
            hairColor = json.decode(result[1].hairColor),
            headBlend = json.decode(result[1].headBlend),
            headOverlay = json.decode(result[1].headOverlay),
            headStructure = json.decode(result[1].headStructure),
            drawables = json.decode(result[1].drawables),
            props = json.decode(result[1].props),
            drawtextures = json.decode(result[1].drawtextures),
            proptextures = json.decode(result[1].proptextures),
            sex = result[1].sex,
        }
        local model = tonumber(result[1].model)
        if model == 1885233650 or model == -1667301416 then
            TriggerClientEvent("raid_clothes:setpedfeatures", src, temp_data)
        end
       
	end)
    --MySQL.Async.fetchall("SELECT cc.model, cf.hairColor, cf.headBlend, cf.headOverlay, cf.headStructure FROM character_face cf INNER JOIN users cc on cc.identifier = cf.identifier WHERE cf.identifier = @identifier", {['identifier'] = characterId}, function(result)
       
end)




RegisterServerEvent("raid_clothes:get_character_current")
AddEventHandler("raid_clothes:get_character_current",function(pSrc)
    local src = (not pSrc and source or pSrc)
    local user = ESX.GetPlayerFromId(source)
    local characterId = user.identifier

    if not characterId then return end

    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {['@identifier'] = characterId}, function(result)
        local temp_data = {
            model = result[1].model,
            drawables = json.decode(result[1].drawables),
            props = json.decode(result[1].props),
            drawtextures = json.decode(result[1].drawtextures),
            proptextures = json.decode(result[1].proptextures),
        }
        TriggerClientEvent("raid_clothes:setclothes", src, temp_data,0)
	end)
end)


RegisterNetEvent("raid_clothes:retrieve_tats")
AddEventHandler("raid_clothes:retrieve_tats", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local playerId = xPlayer.identifier
	MySQL.Async.fetchAll("SELECT * FROM playerstattoos WHERE identifier = @identifier", {['@identifier'] = playerId}, function(result)
        if result and result[1] ~= nil then
			TriggerClientEvent("raid_clothes:settattoos", src, json.decode(result[1].tattoos))
		else
			local tattooValue = "{}"
			MySQL.Async.execute("INSERT INTO playerstattoos (identifier, tattoos) VALUES (@identifier, @tattoo)", {['@identifier'] = playerId, ['@tattoo'] = tattooValue})
			TriggerClientEvent("raid_clothes:settattoos", src, {})
		end
	end)
end)

RegisterNetEvent("raid_clothes:set_tats")
AddEventHandler("raid_clothes:set_tats", function(tattoosList)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local playerId = xPlayer.identifier
	MySQL.Async.execute("UPDATE playerstattoos SET tattoos = @tattoos WHERE identifier = @identifier", {['@tattoos'] = json.encode(tattoosList), ['@identifier'] = playerId})
end)


RegisterServerEvent("raid_clothes:get_outfit")
AddEventHandler("raid_clothes:get_outfit",function(slot)
    if not slot then return end
    local src = source

    local user = ESX.GetPlayerFromId(src)
    local characterId = user.identifier

    if not characterId then return end

    MySQL.Async.fetchAll("SELECT * FROM character_outfits WHERE steamid = @steamid and slot = @slot", {
        ['steamid'] = characterId,
        ['slot'] = slot
    }, function(result)
        if result and result[1] then
            if result[1].model == nil then
                TriggerClientEvent('DoLongHudText', src, "Kullanılamıyor!", 2)
                return
            end

            local data = {
                model = result[1].model,
                drawables = json.decode(result[1].drawables),
                props = json.decode(result[1].props),
                drawtextures = json.decode(result[1].drawtextures),
                proptextures = json.decode(result[1].proptextures),
                hairColor = json.decode(result[1].hairColor)
            }

            TriggerClientEvent("raid_clothes:setclothes", src, data,0)

            local values = {
                ["identifier"] = characterId,
                ["model"] = data.model,
                ["drawables"] = json.encode(data.drawables),
                ["props"] = json.encode(data.props),
                ["drawtextures"] = json.encode(data.drawtextures),
                ["proptextures"] = json.encode(data.proptextures),
            }

            local set = "model = @model, drawables = @drawables, props = @props,drawtextures = @drawtextures,proptextures = @proptextures"
            MySQL.Async.execute("UPDATE users SET "..set.." WHERE identifier = @identifier",values)
        else
            TriggerClientEvent('DoLongHudText', src, "Bu slotta kıyafetiniz yok. Slot:" .. slot, 1)
            return
        end
	end)
end)


RegisterServerEvent("raid_clothes:set_outfit")
AddEventHandler("raid_clothes:set_outfit",function(slot, name, data)
    if not slot then return end
    local src = source

    local user = ESX.GetPlayerFromId(src)
    local characterId = user.identifier

    if not characterId then return end

    MySQL.Async.fetchAll("SELECT slot FROM character_outfits WHERE steamid = @steamid and slot = @slot", {
        ['steamid'] = characterId,
        ['slot'] = slot
    }, function(result)
        if result and result[1] then
            local values = {
                ["steamid"] = characterId,
                ["slot"] = slot,
                ["name"] = name,
                ["model"] = json.encode(data.model),
                ["drawables"] = json.encode(data.drawables),
                ["props"] = json.encode(data.props),
                ["drawtextures"] = json.encode(data.drawtextures),
                ["proptextures"] = json.encode(data.proptextures),
                ["hairColor"] = json.encode(data.hairColor),
            }

            local set = "model = @model,name = @name,drawables = @drawables,props = @props,drawtextures = @drawtextures,proptextures = @proptextures,hairColor = @hairColor"
            MySQL.Async.execute("UPDATE character_outfits SET "..set.." WHERE steamid = @steamid and slot = @slot",values)
        else
            local cols = "steamid, model, name, slot, drawables, props, drawtextures, proptextures, hairColor"
            local vals = "@steamid, @model, @name, @slot, @drawables, @props, @drawtextures, @proptextures, @hairColor"

            local values = {
                ["steamid"] = characterId,
                ["name"] = name,
                ["slot"] = slot,
                ["model"] = data.model,
                ["drawables"] = json.encode(data.drawables),
                ["props"] = json.encode(data.props),
                ["drawtextures"] = json.encode(data.drawtextures),
                ["proptextures"] = json.encode(data.proptextures),
                ["hairColor"] = json.encode(data.hairColor)
            }

            MySQL.Async.execute("INSERT INTO character_outfits ("..cols..") VALUES ("..vals..")", values, function()
                TriggerClientEvent('DoLongHudText', src,  name .. " isimli kıyafetiniz artık " .. slot.. ". slotta bulunuyor.", 1)
            end)
        end
	end)
end)

ESX.RegisterServerCallback('raid_clothes:getPlayerData', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(users)
		local user, skin = users[0].props

		if user.skin then
			skin = json.decode(user.skin)
		end

		cb(skin, jobSkin)
	end)
end)

RegisterServerEvent("raid_clothes:remove_outfit")
AddEventHandler("raid_clothes:remove_outfit",function(slot)

    local src = source
    local user = ESX.GetPlayerFromId(src)
    local steamid = user.identifier
    local slot = slot

    if not steamid then return end

    MySQL.Async.execute( "DELETE FROM character_outfits WHERE steamid = @steamid AND slot = @slot", { ['steamid'] = steamid,  ["slot"] = slot } )
    TriggerClientEvent('DoLongHudText', src, "" .. slot .. ". slottaki kıyafet silindi.", 1)
end)

RegisterServerEvent("raid_clothes:list_outfits")
AddEventHandler("raid_clothes:list_outfits",function()
    local src = source
    local user = ESX.GetPlayerFromId(src)
    local steamid = user.identifier
    local slot = slot
    local name = name

    if not steamid then return end

    MySQL.Async.fetchAll("SELECT slot, name FROM character_outfits WHERE steamid = @steamid", {['steamid'] = steamid}, function(skincheck)
    	TriggerClientEvent("raid_clothes:listOutfits",src, skincheck)
	end)
end)


RegisterServerEvent("clothing:checkIfNew")
AddEventHandler("clothing:checkIfNew", function()
    local src = source
    local user = ESX.GetPlayerFromId(src)
    local steamid = user.identifier

    MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier LIMIT 1", {
        ['identifier'] = steamid
    }, function(result)
        local isService = false;
        if user.job.name == "police" or user.job.name == "ambulance" then isService = true end

        if result[1] == nil then
            MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {["identifier"] = steamid}, function(result)
                if result[1].skin then
                    TriggerClientEvent('raid_clothes:setclothes',src,{},json.decode(result[1].skin))
                else
                    TriggerClientEvent('raid_clothes:setclothes',src,{},nil)
                end
                return
            end)
        else
            TriggerEvent("raid_clothes:get_character_current", src)
        end
        TriggerClientEvent("raid_clothes:inService",src,isService)
    end)
end)

RegisterServerEvent("clothing:checkMoney")
AddEventHandler("clothing:checkMoney", function(menu,askingPrice)
    
    local src = source
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getMoney() >= 100 then
		xPlayer.removeMoney(100)
		TriggerClientEvent("DoLongHudText", source,"You bought 100$.",1)
        TriggerClientEvent("raid_clothes:hasEnough",src,menu)
    else
        TriggerClientEvent("DoLongHudText", source,"You don't have money.",2)
	end
end)