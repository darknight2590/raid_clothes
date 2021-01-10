local enabled = false
local player = false
local firstChar = false
local cam = false
local customCam = false
local oldPed = false
local startingMenu = false

local drawable_names = {"face", "masks", "hair", "torsos", "legs", "bags", "shoes", "neck", "undershirts", "vest", "decals", "jackets"}
local prop_names = {"hats", "glasses", "earrings", "mouth", "lhand", "rhand", "watches", "braclets"}
local head_overlays = {"Blemishes","FacialHair","Eyebrows","Ageing","Makeup","Blush","Complexion","SunDamage","Lipstick","MolesFreckles","ChestHair","BodyBlemishes","AddBodyBlemishes"}
local face_features = {"Nose_Width","Nose_Peak_Hight","Nose_Peak_Lenght","Nose_Bone_High","Nose_Peak_Lowering","Nose_Bone_Twist","EyeBrown_High","EyeBrown_Forward","Cheeks_Bone_High","Cheeks_Bone_Width","Cheeks_Width","Eyes_Openning","Lips_Thickness","Jaw_Bone_Width","Jaw_Bone_Back_Lenght","Chimp_Bone_Lowering","Chimp_Bone_Lenght","Chimp_Bone_Width","Chimp_Hole","Neck_Thikness"}
local tatCategory = GetTatCategs()
local tattooHashList = CreateHashList()

local StoreCosts = 100;
local barberCost = 70;
local tattooCost = 50;
local isService = false;


function RefreshUI()
    hairColors = {}
    for i = 0, GetNumHairColors()-1 do
        local outR, outG, outB= GetPedHairRgbColor(i)
        hairColors[i] = {outR, outG, outB}
    end

    makeupColors = {}
    for i = 0, GetNumMakeupColors()-1 do
        local outR, outG, outB= GetPedMakeupRgbColor(i)
        makeupColors[i] = {outR, outG, outB}
    end

    SendNUIMessage({
        type="colors",
        hairColors=hairColors,
        makeupColors=makeupColors,
        hairColor=GetPedHair()
    })
    SendNUIMessage({
        type = "menutotals",
        drawTotal = GetDrawablesTotal(),
        propDrawTotal = GetPropDrawablesTotal(),
        textureTotal = GetTextureTotals(),
        headoverlayTotal = GetHeadOverlayTotals(),
        skinTotal = GetSkinTotal()
    })
    SendNUIMessage({
        type = "barbermenu",
        headBlend = GetPedHeadBlendData(),
        headOverlay = GetHeadOverlayData(),
        headStructure = GetHeadStructureData()
    })
    SendNUIMessage({
        type = "clothesmenudata",
        drawables = GetDrawables(),
        props = GetProps(),
        drawtextures = GetDrawTextures(),
        proptextures = GetPropTextures(),
        skin = GetSkin(),
        oldPed = oldPed,
    })
    SendNUIMessage({
        type = "tattoomenu",
        totals = tatCategory,
        values = GetTats()
    })
end

function GetSkin()
    for i = 1, #frm_skins do
        if (GetHashKey(frm_skins[i]) == GetEntityModel(PlayerPedId())) then
            return {name="skin_male", value=i}
        end
    end
    for i = 1, #fr_skins do
        if (GetHashKey(fr_skins[i]) == GetEntityModel(PlayerPedId())) then
            return {name="skin_female", value=i}
        end
    end
    return false
end

function GetDrawables()
    drawables = {}
    local model = GetEntityModel(PlayerPedId())
    local mpPed = false
    if (model == `mp_f_freemode_01` or model == `mp_m_freemode_01`) then
        mpPed = true
    end
    for i = 0, #drawable_names-1 do
        if mpPed and drawable_names[i+1] == "undershirts" and GetPedDrawableVariation(player, i) == -1 then
            SetPedComponentVariation(player, i, 15, 0, 2)
        end
        drawables[i] = {drawable_names[i+1], GetPedDrawableVariation(player, i)}
    end
    return drawables
end

function GetProps()
    props = {}
    for i = 0, #prop_names-1 do
        props[i] = {prop_names[i+1], GetPedPropIndex(player, i)}
    end
    return props
end

function GetDrawTextures()
    textures = {}
    for i = 0, #drawable_names-1 do
        table.insert(textures, {drawable_names[i+1], GetPedTextureVariation(player, i)})
    end
    return textures
end

function GetPropTextures()
    textures = {}
    for i = 0, #prop_names-1 do
        table.insert(textures, {prop_names[i+1], GetPedPropTextureIndex(player, i)})
    end
    return textures
end

function GetDrawablesTotal()
    drawables = {}
    for i = 0, #drawable_names - 1 do
        drawables[i] = {drawable_names[i+1], GetNumberOfPedDrawableVariations(player, i)}
    end
    return drawables
end

function GetPropDrawablesTotal()
    props = {}
    for i = 0, #prop_names - 1 do
        props[i] = {prop_names[i+1], GetNumberOfPedPropDrawableVariations(player, i)}
    end
    return props
end

function GetTextureTotals()
    local values = {}
    local draw = GetDrawables()
    local props = GetProps()

    for idx = 0, #draw-1 do
        local name = draw[idx][1]
        local value = draw[idx][2]
        values[name] = GetNumberOfPedTextureVariations(player, idx, value)
    end

    for idx = 0, #props-1 do
        local name = props[idx][1]
        local value = props[idx][2]
        values[name] = GetNumberOfPedPropTextureVariations(player, idx, value)
    end
    return values
end

function SetClothing(drawables, props, drawTextures, propTextures)
    for i = 1, #drawable_names do
        if drawables[0] == nil then
            if drawable_names[i] == "undershirts" and drawables[tostring(i-1)][2] == -1 then
                SetPedComponentVariation(player, i-1, 15, 0, 2)
            else
                SetPedComponentVariation(player, i-1, drawables[tostring(i-1)][2], drawTextures[i][2], 2)
            end
        else
            if drawable_names[i] == "undershirts" and drawables[i-1][2] == -1 then
                SetPedComponentVariation(player, i-1, 15, 0, 2)
            else
                SetPedComponentVariation(player, i-1, drawables[i-1][2], drawTextures[i][2], 2)
            end
        end
    end

    for i = 1, #prop_names do
        local propZ = (drawables[0] == nil and props[tostring(i-1)][2] or props[i-1][2])
        ClearPedProp(player, i-1)
        SetPedPropIndex(
            player,
            i-1,
            propZ,
            propTextures[i][2], true)
    end
end

function GetSkinTotal()
    print(#frm_skins)
	return {
        #frm_skins,
        #fr_skins
    }
end

local toggleClothing = {}
function ToggleProps(data)
    local name = data["name"]

    selectedValue = has_value(drawable_names, name)
    if (selectedValue > -1) then
        if (toggleClothing[name] ~= nil) then
            SetPedComponentVariation(
                player,
                tonumber(selectedValue),
                tonumber(toggleClothing[name][1]),
                tonumber(toggleClothing[name][2]), 2)
            toggleClothing[name] = nil
        else
            toggleClothing[name] = {
                GetPedDrawableVariation(player, tonumber(selectedValue)),
                GetPedTextureVariation(player, tonumber(selectedValue))
            }

            local value = -1
            if name == "undershirts" or name == "torsos" then
                value = 15
                if name == "undershirts" and GetEntityModel(PlayerPedId()) == GetHashKey('mp_f_freemode_01') then
                    value = -1
                end
            end
            if name == "legs" then
                value = 14
            end

            SetPedComponentVariation(
                player,
                tonumber(selectedValue),
                value, 0, 2)
        end
    else
        selectedValue = has_value(prop_names, name)
        if (selectedValue > -1) then
            if (toggleClothing[name] ~= nil) then
                SetPedPropIndex(
                    player,
                    tonumber(selectedValue),
                    tonumber(toggleClothing[name][1]),
                    tonumber(toggleClothing[name][2]), true)
                toggleClothing[name] = nil
            else
                toggleClothing[name] = {
                    GetPedPropIndex(player, tonumber(selectedValue)),
                    GetPedPropTextureIndex(player, tonumber(selectedValue))
                }
                ClearPedProp(player, tonumber(selectedValue))
            end
        end
    end
end

function SaveToggleProps()
    for k in pairs(toggleClothing) do
        local name  = k
        selectedValue = has_value(drawable_names, name)
        if (selectedValue > -1) then
            SetPedComponentVariation(
                player,
                tonumber(selectedValue),
                tonumber(toggleClothing[name][1]),
                tonumber(toggleClothing[name][2]), 2)
            toggleClothing[name] = nil
        else
            selectedValue = has_value(prop_names, name)
            if (selectedValue > -1) then
                SetPedPropIndex(
                    player,
                    tonumber(selectedValue),
                    tonumber(toggleClothing[name][1]),
                    tonumber(toggleClothing[name][2]), true)
                toggleClothing[name] = nil
            end
        end
    end
end

function LoadPed(data)
    SetSkin(data.model, true)
    --print(data.model)
    SetClothing(data.drawables, data.props, data.drawtextures, data.proptextures)
    --print(data.drawables)
    --exports['mythic_notify']:SendAlert('inform', data.drawables, 22500)
    Citizen.Wait(500)
    SetPedHairColor(player, tonumber(data.hairColor[1]), tonumber(data.hairColor[2]))
    SetPedHeadBlend(data.headBlend)
    SetHeadStructure(data.headStructure)
    SetHeadOverlayData(data.headOverlay)
    PlayerModel(data.sex)
    return
end

function GetCurrentPed()
    player = PlayerPedId()
    return {
        model = GetEntityModel(PlayerPedId()),
        hairColor = GetPedHair(),
        headBlend = GetPedHeadBlendData(),
        headOverlay = GetHeadOverlayData(),
        headStructure = GetHeadStructure(),
        drawables = GetDrawables(),
        props = GetProps(),
        drawtextures = GetDrawTextures(),
        proptextures = GetPropTextures(),
    }
end

function PlayerModel(data)
    local skins = nil
    if (data['name'] == 'skin_male') then
        skins = frm_skins
    else
        skins = fr_skins
    end
    local skin = skins[tonumber(data['value'])]
    rotation(180.0)
    SetSkin(GetHashKey(skin), true)
    Citizen.Wait(1)
    rotation(180.0)
end

function SetSkin(model, setDefault)
    -- TODO: If not isCop and model not in copModellist, do below.
    -- Model is a hash, GetHashKey(modelName)
    SetEntityInvincible(PlayerPedId(),true)
    if IsModelInCdimage(model) and IsModelValid(model) then
        RequestModel(model)
        while (not HasModelLoaded(model)) do
            Citizen.Wait(0)
        end
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        player = PlayerPedId()
        FreezePedCameraRotation(player, true)
        if setDefault and model ~= nil and not isCustomSkin(model) then
            if (model ~= `mp_f_freemode_01` and model ~= `mp_m_freemode_01`) then
                SetPedRandomComponentVariation(PlayerPedId(), true)
            else
                SetPedHeadBlendData(player, 0, 0, 0, 15, 0, 0, 0, 1.0, 0, false)
                SetPedComponentVariation(player, 11, 0, 11, 0)
                SetPedComponentVariation(player, 8, 0, 1, 0)
                SetPedComponentVariation(player, 6, 1, 2, 0)
                SetPedHeadOverlayColor(player, 1, 1, 0, 0)
                SetPedHeadOverlayColor(player, 2, 1, 0, 0)
                SetPedHeadOverlayColor(player, 4, 2, 0, 0)
                SetPedHeadOverlayColor(player, 5, 2, 0, 0)
                SetPedHeadOverlayColor(player, 8, 2, 0, 0)
                SetPedHeadOverlayColor(player, 10, 1, 0, 0)
                SetPedHeadOverlay(player, 1, 0, 0.0)
                SetPedHairColor(player, 1, 1)
            end
        end
    end
    SetEntityInvincible(PlayerPedId(),false)
end


RegisterNUICallback('updateclothes', function(data, cb)
    toggleClothing[data["name"]] = nil
    selectedValue = has_value(drawable_names, data["name"])
    if (selectedValue > -1) then
        SetPedComponentVariation(player, tonumber(selectedValue), tonumber(data["value"]), tonumber(data["texture"]), 2)
        cb({
            GetNumberOfPedTextureVariations(player, tonumber(selectedValue), tonumber(data["value"]))
        })
    else
        selectedValue = has_value(prop_names, data["name"])
        if (tonumber(data["value"]) == -1) then
            ClearPedProp(player, tonumber(selectedValue))
        else
            SetPedPropIndex(
                player,
                tonumber(selectedValue),
                tonumber(data["value"]),
                tonumber(data["texture"]), true)
        end
        cb({
            GetNumberOfPedPropTextureVariations(
                player,
                tonumber(selectedValue),
                tonumber(data["value"])
            )
        })
    end
end)

RegisterNUICallback('customskin', function(data, cb)
    if canUseCustomSkins() then
        local valid_model = isInSkins(data)
        if valid_model then
            SetSkin(GetHashKey(data), true)
        end
    end
end)

RegisterNUICallback('setped', function(data, cb)
    PlayerModel(data)
    RefreshUI()
    cb('ok')
end)

RegisterNUICallback('resetped', function(data, cb)
    LoadPed(oldPed)
    cb('ok')
end)

AddEventHandler('playerSpawned', function(spawn)
    isDead = false
    --loadPed()
end)

------------------------------------------------------------------------------------------
-- Barber

function GetPedHeadBlendData()
    local blob = string.rep("\0\0\0\0\0\0\0\0", 6 + 3 + 1) -- Generate sufficient struct memory.
    if not Citizen.InvokeNative(0x2746BD9D88C5C5D0, player, blob, true) then -- Attempt to write into memory blob.
        return nil
    end

    return {
        shapeFirst = string.unpack("<i4", blob, 1),
        shapeSecond = string.unpack("<i4", blob, 9),
        shapeThird = string.unpack("<i4", blob, 17),
        skinFirst = string.unpack("<i4", blob, 25),
        skinSecond = string.unpack("<i4", blob, 33),
        skinThird = string.unpack("<i4", blob, 41),
        shapeMix = string.unpack("<f", blob, 49),
        skinMix = string.unpack("<f", blob, 57),
        thirdMix = string.unpack("<f", blob, 65),
        hasParent = string.unpack("b", blob, 73) ~= 0,
    }
end

function SetPedHeadBlend(data)
    SetPedHeadBlendData(player,
        tonumber(data['shapeFirst']),
        tonumber(data['shapeSecond']),
        tonumber(data['shapeThird']),
        tonumber(data['skinFirst']),
        tonumber(data['skinSecond']),
        tonumber(data['skinThird']),
        tonumber(data['shapeMix']),
        tonumber(data['skinMix']),
        tonumber(data['thirdMix']),
        false)
end

function GetHeadOverlayData()
    local headData = {}
    for i = 1, #head_overlays do
        local retval, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(player, i-1)
        if retval then
            headData[i] = {}
            headData[i].name = head_overlays[i]
            headData[i].overlayValue = overlayValue
            headData[i].colourType = colourType
            headData[i].firstColour = firstColour
            headData[i].secondColour = secondColour
            headData[i].overlayOpacity = overlayOpacity
        end
    end
    return headData
end

function SetHeadOverlayData(data)
    if json.encode(data) ~= "[]" then
        for i = 1, #head_overlays do
            SetPedHeadOverlay(player,  i-1, tonumber(data[i].overlayValue),  tonumber(data[i].overlayOpacity))
            -- SetPedHeadOverlayColor(player, i-1, data[i].colourType, data[i].firstColour, data[i].secondColour)
        end

        SetPedHeadOverlayColor(player, 0, 0, tonumber(data[1].firstColour), tonumber(data[1].secondColour))
        SetPedHeadOverlayColor(player, 1, 1, tonumber(data[2].firstColour), tonumber(data[2].secondColour))
        SetPedHeadOverlayColor(player, 2, 1, tonumber(data[3].firstColour), tonumber(data[3].secondColour))
        SetPedHeadOverlayColor(player, 3, 0, tonumber(data[4].firstColour), tonumber(data[4].secondColour))
        SetPedHeadOverlayColor(player, 4, 2, tonumber(data[5].firstColour), tonumber(data[5].secondColour))
        SetPedHeadOverlayColor(player, 5, 2, tonumber(data[6].firstColour), tonumber(data[6].secondColour))
        SetPedHeadOverlayColor(player, 6, 0, tonumber(data[7].firstColour), tonumber(data[7].secondColour))
        SetPedHeadOverlayColor(player, 7, 0, tonumber(data[8].firstColour), tonumber(data[8].secondColour))
        SetPedHeadOverlayColor(player, 8, 2, tonumber(data[9].firstColour), tonumber(data[9].secondColour))
        SetPedHeadOverlayColor(player, 9, 0, tonumber(data[10].firstColour), tonumber(data[10].secondColour))
        SetPedHeadOverlayColor(player, 10, 1, tonumber(data[11].firstColour), tonumber(data[11].secondColour))
        SetPedHeadOverlayColor(player, 11, 0, tonumber(data[12].firstColour), tonumber(data[12].secondColour))
    end
end

function GetHeadOverlayTotals()
    local totals = {}
    for i = 1, #head_overlays do
        totals[head_overlays[i]] = GetNumHeadOverlayValues(i-1)
    end
    return totals
end

function GetPedHair()
    local hairColor = {}
    hairColor[1] = GetPedHairColor(player)
    hairColor[2] = GetPedHairHighlightColor(player)
    return hairColor
end

function GetHeadStructureData()
    local structure = {}
    for i = 1, #face_features do
        structure[face_features[i]] = GetPedFaceFeature(player, i-1)
    end
    return structure
end

function GetHeadStructure(data)
    local structure = {}
    for i = 1, #face_features do
        structure[i] = GetPedFaceFeature(player, i-1)
    end
    return structure
end

function SetHeadStructure(data)
    for i = 1, #face_features do
        SetPedFaceFeature(player, i-1, data[i])
    end
end


RegisterNUICallback('saveheadblend', function(data, cb)
    SetPedHeadBlendData(player,
    tonumber(data.shapeFirst),
    tonumber(data.shapeSecond),
    tonumber(data.shapeThird),
    tonumber(data.skinFirst),
    tonumber(data.skinSecond),
    tonumber(data.skinThird),
    tonumber(data.shapeMix) / 100,
    tonumber(data.skinMix) / 100,
    tonumber(data.thirdMix) / 100, false)
    cb('ok')
end)

RegisterNUICallback('savehaircolor', function(data, cb)
    SetPedHairColor(player, tonumber(data['firstColour']), tonumber(data['secondColour']))
end)

RegisterNUICallback('savefacefeatures', function(data, cb)
    local index = has_value(face_features, data["name"])
    if (index <= -1) then return end
    local scale = tonumber(data["scale"]) / 100
    SetPedFaceFeature(player, index, scale)
    cb('ok')
end)

RegisterNUICallback('saveheadoverlay', function(data, cb)
    local index = has_value(head_overlays, data["name"])
    SetPedHeadOverlay(player,  index, tonumber(data["value"]), tonumber(data["opacity"]) / 100)
    cb('ok')
end)

RegisterNUICallback('saveheadoverlaycolor', function(data, cb)
    local index = has_value(head_overlays, data["name"])
    local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(player, index)
    local sColor = tonumber(data['secondColour'])
    if (sColor == nil) then
        sColor = tonumber(data['firstColour'])
    end
    SetPedHeadOverlayColor(player, index, colourType, tonumber(data['firstColour']), sColor)
    cb('ok')
end)


----------------------------------------------------------------------------------
-- UTIL SHIT


function has_value (tab, val)
    for index = 1, #tab do
        if tab[index] == val then
            return index-1
        end
    end
    return -1
end

function EnableGUI(enable, menu)
    enabled = enable
    SetNuiFocus(enable, enable)
    SendNUIMessage({
        type = "enableclothesmenu",
        enable = enable,
        menu = menu,
        isService = isService,
    })

    if (not enable) then
        SaveToggleProps()
        oldPed = {}
    end
end

function CustomCamera(position)
    if customCam or position == "torso" then
        FreezePedCameraRotation(player, false)
        SetCamActive(cam, false)
        RenderScriptCams(false,  false,  0,  true,  true)
        if (DoesCamExist(cam)) then
            DestroyCam(cam, false)
        end
        customCam = false
    else
        if (DoesCamExist(cam)) then
            DestroyCam(cam, false)
        end

        local pos = GetEntityCoords(player, true)
        SetEntityRotation(player, 0.0, 0.0, 0.0, 1, true)
        FreezePedCameraRotation(player, true)

        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        SetCamCoord(cam, player)
        SetCamRot(cam, 0.0, 0.0, 0.0)

        SetCamActive(cam, true)
        RenderScriptCams(true,  false,  0,  true,  true)

        SwitchCam(position)
        customCam = true
    end
end

function rotation(dir)
    local pedRot = GetEntityHeading(PlayerPedId())+dir
    SetEntityHeading(PlayerPedId(), pedRot % 360)
end

function TogRotation()
    local pedRot = GetEntityHeading(PlayerPedId())+90 % 360
    SetEntityHeading(PlayerPedId(), math.floor(pedRot / 90) * 90.0)
end

function SwitchCam(name)
    if name == "cam" then
        TogRotation()
        return
    end

    local pos = GetEntityCoords(player, true)
    local bonepos = false
    if (name == "head") then
        bonepos = GetPedBoneCoords(player, 31086)
        bonepos = vector3(bonepos.x - 0.1, bonepos.y + 0.4, bonepos.z + 0.05)
    end
    if (name == "torso") then
        bonepos = GetPedBoneCoords(player, 11816)
        bonepos = vector3(bonepos.x - 0.4, bonepos.y + 2.2, bonepos.z + 0.2)
    end
    if (name == "leg") then
        bonepos = GetPedBoneCoords(player, 46078)
        bonepos = vector3(bonepos.x - 0.1, bonepos.y + 1, bonepos.z)
    end

    SetCamCoord(cam, bonepos.x, bonepos.y, bonepos.z)
    SetCamRot(cam, 0.0, 0.0, 180.0)
end

RegisterNUICallback('escape', function(data, cb)
    Save(data['save'])
    EnableGUI(false, false)
    cb('ok')
end)

RegisterNUICallback('togglecursor', function(data, cb)
    CustomCamera("torso")
    SetNuiFocus(false, false)
    FreezePedCameraRotation(player, false)
    cb('ok')
end)

RegisterNUICallback('rotate', function(data, cb)
    if (data["key"] == "left") then
        rotation(20)
    else
        rotation(-20)
    end
    cb('ok')
end)

RegisterNUICallback('switchcam', function(data, cb)
    CustomCamera(data['name'])
    cb('ok')
end)

RegisterNUICallback('toggleclothes', function(data, cb)
    ToggleProps(data)
    cb('ok')
end)


------------------------------------------------------------------------
-- Tattooooooos


-- currentTats [[collectionHash, tatHash], [collectionHash, tatHash]]
-- loop tattooHashList [categ] find [tatHash, collectionHash]

function GetTats()
    local tempTats = {}
    if currentTats == nil then return {} end
    for i = 1, #currentTats do
        for key in pairs(tattooHashList) do
            for j = 1, #tattooHashList[key] do
                if tattooHashList[key][j][1] == currentTats[i][2] then
                    tempTats[key] = j
                end
            end
        end
    end
    return tempTats
end

function SetTats(data)
    currentTats = {}
    for k, v in pairs(data) do
        for categ in pairs(tattooHashList) do
            if k == categ then
                local something = tattooHashList[categ][tonumber(v)]
                if something ~= nil then
                    table.insert(currentTats, {something[2], something[1]})
                end
            end
        end
    end
    ClearPedDecorations(PlayerPedId())
    for i = 1, #currentTats do
        ApplyPedOverlay(PlayerPedId(), currentTats[i][1], currentTats[i][2])
    end
end

RegisterNUICallback('settats', function(data, cb)
    SetTats(data["tats"])
    cb('ok')
end)


--------------------------------------------------------------------
-- Main menu

function OpenMenu(name)
    player = PlayerPedId()
    oldPed = GetCurrentPed()
    local isAllowed = false
    if(oldPed.model == 1885233650 or oldPed.model == -1667301416) then isAllowed = true end
    if((oldPed.model ~= 1885233650 or oldPed.model ~= -1667301416) and (name == "clothesmenu" or name == "tattoomenu" or name == "healmenu")) then isAllowed = true end
    if isAllowed then
        FreezePedCameraRotation(player, true)
        RefreshUI()
        EnableGUI(true, name)
    else
        TriggerEvent("notification", "Buraya yeni gelmediniz.");
    end
end

function Save(save)
    if save then
        data = GetCurrentPed()
        TriggerServerEvent("raid_clothes:insert_character_current", data)
       -- TriggerServerEvent("raid_clothes:insert_character_skin", data)
        --TriggerServerEvent("raid_clothes:insert_character_face", data)
       -- TriggerServerEvent('esx_skin:save', data)
        if data.model == `mp_f_freemode_01` or data.model == `mp_m_freemode_01` then
            TriggerServerEvent("raid_clothes:insert_character_face", data)
            TriggerServerEvent("raid_clothes:set_tats", currentTats)
            TriggerServerEvent('esx_skin:save', data)
        end
    else
        LoadPed(oldPed)
    end

    TriggerEvent("ressurection:relationships:norevive")
    TriggerEvent("gangs:setDefaultRelations")
    TriggerEvent("facewear:update")
    TriggerEvent('np-weapons:getAmmo')
    CustomCamera('torso')
end

function IsNearShop(shops)
    local dstchecked = 1000
    local plyPos = GetEntityCoords(GetPlayerPed(PlayerId()), false)
	for i = 1, #shops do
		shop = shops[i]
		local comparedst = Vdist(plyPos.x, plyPos.y, plyPos.z,shop[1], shop[2], shop[3])
		if comparedst < dstchecked then
			dstchecked = comparedst
		end

		if comparedst < 3.0 then
			DrawMarker(27,shop[1], shop[2], shop[3], 0, 0, 0, 0, 0, 0, 1.001, 1.0001, 1.7001, 0, 55, 240, 20, 0, 0, 0, 0)
		end
	end
	return dstchecked
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
        local nearcloth = IsNearShop(clothingShops)
        local nearheal = IsNearShop(healingShops)
        local neartat = IsNearShop(tattoosShops)
        local nearbarber = IsNearShop(barberShops)
        local StoreCosts = 100;
        local barberCost = 70;
        local tattooCost = 50;

        local menu = nil

        if nearcloth < 5.0 then
            menu = {"clothesmenu",StoreCosts.. "$ karşılığında kıyafetlerini değiştirmek için ~g~M~s~ tuşuna bas."}
            local StoreCost = StoreCosts
        elseif neartat < 5.0 then
            menu = {"tattoomenu",tattooCost.. "$ karşılığında dövmelerini değiştirmek için ~g~M~s~ tuşuna bas."}
            local StoreCost = tattooCost
        elseif nearbarber < 5.0 then
            menu = {"barbermenu",barberCost.."$ karşılığında berbere girmek için ~g~M~s~ tuşuna bas."}
            local StoreCost = barberCost
        elseif nearheal < 2.0 then
            menu = {"healmenu", "~g~UP~s~ to Heal/Remove Bleeding"}
        elseif startingMenu then
            menu = "clothesmenu"
        end


        if (menu ~= nil) then

            if menu[1] == "healmenu" then
                if IsControlJustPressed(1, 188) then
                    SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()))
                    TriggerEvent("Evidence:ClearDamageStates")
                end
            end

            if (not enabled) then
                DisplayHelpText(menu[2])

                if IsControlJustPressed(1, 244) then
                    TriggerServerEvent("clothing:checkMoney",menu[1],StoreCost)
                end
            else
                if (IsControlJustReleased(1, 25)) then
                    SetNuiFocus(true, true)
                    FreezePedCameraRotation(player, true)
                end
                InvalidateIdleCam()
            end
        else
            local dist = math.min(nearcloth, neartat, nearbarber, nearheal)
            if dist > 10 then
                Citizen.Wait(math.ceil(dist * 10))
            end
		end
	end
end)

AddEventHandler("np-base:initialSpawnModelLoaded", function()
    TriggerServerEvent("clothing:checkIfNew")
end)



RegisterNetEvent("raid_clothes:inService")
AddEventHandler("raid_clothes:inService", function(service)
    isService = service
end)


RegisterNetEvent("raid_clothes:hasEnough")
AddEventHandler("raid_clothes:hasEnough", function(menu)
    if menu == "tattoomenu" then
        TriggerServerEvent("raid_clothes:retrieve_tats")
        while currentTats == nil do
            Citizen.Wait(1)
        end
    end

    OpenMenu(menu)
end)

--[[RegisterCommand('spawnme', function(source, args)
    --print("spawned me")
--TriggerEvent("raid_clothes:register")
    OpenMenu("barbermenu")
end)]]

RegisterNetEvent("raid_clothes:setclothes")
AddEventHandler("raid_clothes:setclothes", function(data,alreadyExist)

    player = PlayerPedId()
    local function setDefault()
        Citizen.CreateThread(function()
            firstChar = true
            local sex = nil
            local LocalPlayer = ESX.GetPlayerFromId(source)
            --local LocalPlayer = exports["np-base"]:getModule("LocalPlayer")
            local sex = LocalPlayer:getCurrentCharacter().sex
            Citizen.Wait(5000)
            if skin.sex ~= 0 then
                SetSkin(mp_f_freemode_01, true)
            else
                SetSkin(mp_m_freemode_01, true)
            end
            OpenMenu("clothesmenu")
            startingMenu = true
            SetEntityCoords(PlayerPedId(),-1038.2766113281 + (math.random(200) / 100),-2738.2648925781 + (math.random(200) / 100),20.169269561768)
            SetEntityHeading(PlayerPedId(),328.30828857422)
            DoScreenFadeIn(50)
            -- TriggerEvent("player:receiveItem","idcard",1,true)
            -- TriggerEvent("player:receiveItem","mobilephone",1)
            TriggerEvent("tokovoip:onPlayerLoggedIn", true)
            TriggerEvent("customNotification","Looks like you picked a character, nice job! You have a Hotel booked in the city, type /phone or press P to call a Taxi, Or, if you see one, hit F to jump inside it(this works anywhere). Once in the Taxi, mark the location on the map where you want to go for free! (Hotel 1).")
            SetNewWaypoint(312.96966552734,-218.2705078125)
            local dstHt = #(vector3(GetEntityCoords(PlayerPedId())) - vector3(312.96966552734,-218.2705078125,54.221797943115))

            while dstHt > 50.0 do
                dstHt = #(vector3(GetEntityCoords(PlayerPedId())) - vector3(312.96966552734,-218.2705078125,54.221797943115))
                Citizen.Wait(1)
            end

            TriggerEvent("customNotification","Theres the Hotel, finally, go inside and check it out. Be sure to save your clothing in the dresser by typing '/outfitadd 1 New Outfit' when you are near it. (P for Phone, F1 for Actions, K for inventory - most shops will show you what to do, also, you can use gurgle on your phone for more help!)")
            TriggerEvent("doApartHelp")
        end)
    end

	if not data.model and alreadyExist <= 0 then setDefault() return end
    if not data.model and alreadyExist >= 1 then return end
    model = data.model
    model = model ~= nil and tonumber(model) or false

	if not IsModelInCdimage(model) or not IsModelValid(model) then setDefault() return end

    SetSkin(model, false)
    Citizen.Wait(500)
    SetClothing(data.drawables, data.props, data.drawtextures, data.proptextures)
    Citizen.Wait(500)
	TriggerEvent("facewear:update")
    TriggerServerEvent("raid_clothes:get_character_face")
    --TriggerServerEvent("raid_clothes:retrieve_tats")
	TriggerServerEvent("Police:getMeta")
end)

RegisterNetEvent("raid_clothes:setclothes")
AddEventHandler("raid_clothes:setclothes", function(data,alreadyExist)
    player = PlayerPedId()
    local function setDefault()
        Citizen.CreateThread(function()
            firstChar = true
            local gender = nil
            ESX.TriggerServerCallback('raid_clothes:getSex', function(sex)
				gender = sex
			end)
            Citizen.Wait(1000)
            if gender ~= "m" then
                SetSkin(`mp_m_freemode_01`, true)
            else
                SetSkin(`mp_f_freemode_01`, true)
            end
            OpenMenu("clothesmenu")
            startingMenu = true
            SetEntityCoords(PlayerPedId(),-207.21757507324 + (math.random(200) / 100),-1015.7188110352 + (math.random(200) / 100),30.138160705566)
            SetEntityHeading(PlayerPedId(),328.30828857422)
            DoScreenFadeIn(50)
            Wait(5000)
            local dstHt = #(vector3(GetEntityCoords(PlayerPedId())) - vector3(312.96966552734,-218.2705078125,54.221797943115))

            while dstHt > 50.0 do
                dstHt = #(vector3(GetEntityCoords(PlayerPedId())) - vector3(312.96966552734,-218.2705078125,54.221797943115))
                Citizen.Wait(1)
            end
        end)
    end

	if not data.model and alreadyExist == nil then setDefault() return end
    if not data.model and alreadyExist ~= nil then ApplySkin(alreadyExist); return; 
    end

    model = data.model
    model = model ~= nil and tonumber(model) or false

	if not IsModelInCdimage(model) or not IsModelValid(model) then setDefault() return end
    SetSkin(model, false)
    Citizen.Wait(500)
    SetClothing(data.drawables, data.props, data.drawtextures, data.proptextures)
    Citizen.Wait(500)
	TriggerEvent("facewear:update")
    TriggerServerEvent("raid_clothes:get_character_face")
    TriggerServerEvent("raid_clothes:retrieve_tats")
end)



RegisterNetEvent("raid_clothes:defaultReset")
AddEventHandler("raid_clothes:defaultReset", function()
    local sex = LocalPlayer:getCurrentCharacter().sex
    local sex = nil
    Citizen.Wait(1000)
    if sex ~= 0 then
        SetSkin(mp_f_freemode_01, true)
    else
        SetSkin(mp_m_freemode_01, true)
    end
    --SetPedHeadBlendData(PlayerPedId(), 0, 0, 0, 15, 0, 0, 0, 1.0, 0, false)
    --menu = "clothesmenu"
    OpenMenu("clothesmenu")
    startingMenu = true
end)


RegisterNetEvent("raid_clothes:settattoos")
AddEventHandler("raid_clothes:settattoos", function(playerTattoosList)
    currentTats = playerTattoosList
    SetTats(GetTats())
end)

RegisterNetEvent("raid_clothes:setpedfeatures")
AddEventHandler("raid_clothes:setpedfeatures", function(data)
    player = PlayerPedId()
    if data == false then
        SetSkin(GetEntityModel(PlayerPedId()), true)
        return
    end
    local head = data.headBlend
    local haircolor = data.hairColor
    SetPedHeadBlendData(player,
        tonumber(head['shapeFirst']),
        tonumber(head['shapeSecond']),
        tonumber(head['shapeThird']),
        tonumber(head['skinFirst']),
        tonumber(head['skinSecond']),
        tonumber(head['skinThird']),
        tonumber(head['shapeMix']),
        tonumber(head['skinMix']),
        tonumber(head['thirdMix']),
        false)
    SetHeadStructure(data.headStructure)
    SetPedHairColor(player, tonumber(haircolor[1]), tonumber(haircolor[2]))
   -- print(tonumber(haircolor[1]), tonumber(haircolor[2]))
    SetHeadOverlayData(data.headOverlay)
    LoadPed(data)
end)

function DisplayHelpText(str)
    SetTextComponentFormat("STRING")
    AddTextComponentString(str)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end


RegisterNetEvent('raid_clothes:outfits')
AddEventHandler('raid_clothes:outfits', function(pAction, pId, pName)
    if pAction == 1 then
        TriggerServerEvent("raid_clothes:set_outfit",pId, pName, GetCurrentPed())
    elseif pAction == 2 then
        TriggerServerEvent("raid_clothes:remove_outfit",pId)
    elseif pAction == 3 then
        TriggerEvent('InteractSound_CL:PlayOnOne','Clothes1', 0.6)
        TriggerServerEvent("raid_clothes:get_outfit", pId)
    else
        TriggerServerEvent("raid_clothes:list_outfits")
    end
end)



--new regiser
AddEventHandler('raid_clothes:register', function(name)
    OpenMenu("clothesmenu")
    startingMenu = true
end)

RegisterCommand("outfitadd", function(source, args, rawCommand)
    if
    --  exports["grp-housing"]:imClosesToRoom2() or exports["grp-apartments"]:imClosesToRoom3() or
      (IsNearShop(clothingShops) < 9.0) then
    if args[1] and args[2] then
        TriggerEvent('raid_clothes:outfits', 1, args[1], args[2])
    else
        TriggerEvent('DoLongHudText', "Bu komutu /outfitadd 1 deneme şeklinde kullanabilirsin. | 1 kıyafete vereceğin slot, deneme ise kıyafetinin ismi olacak.", 1)
    end
else
    TriggerEvent('DoLongHudText', "Bir kıyafetçiye yakın değilsin!", 2)
end
end, false)

RegisterCommand("outfituse", function(source, args, rawCommand)
    if
    --  exports["grp-housing"]:imClosesToRoom2() or exports["grp-apartments"]:imClosesToRoom3() or
      (IsNearShop(clothingShops) < 9.0) then
    if args[1] then
        TriggerEvent('raid_clothes:outfits', 3, args[1])
    else
        TriggerEvent('DoLongHudText', "Bu komutu /outfituse 1 olarak kullanabilirsin.", 1)
    end
else
    TriggerEvent('DoLongHudText', "Bir gardıropa yakın değilsin!", 2)
end
end, false) 

RegisterCommand("outfitdel", function(source, args, rawCommand)
    if
    --  exports["grp-housing"]:imClosesToRoom2() or exports["grp-apartments"]:imClosesToRoom3() or
      (IsNearShop(clothingShops) < 9.0) then
    if args[1] then
        TriggerEvent('raid_clothes:outfits', 2, args[1])
    else
        TriggerEvent('DoLongHudText', "Bu komutu  /outfitdel 1 olarak kullanabilirsin.", 1)  
    end
else
    TriggerEvent('DoLongHudText', "Bir gardıropa yakın değilsin!", 2)
end
end, false) 

RegisterCommand("outfits", function(source, args, rawCommand)
        if
    --  exports["grp-housing"]:imClosesToRoom2() or exports["grp-apartments"]:imClosesToRoom3() or
      (IsNearShop(clothingShops) < 9.0) then
    TriggerEvent('raid_clothes:outfits', 4)
--else
--    TriggerEvent('DoLongHudText', "Bir gardıropa yakın değilsin!", 2)
end
end, false)  

RegisterNetEvent('raid_clothes:listOutfits')
AddEventHandler('raid_clothes:listOutfits', function(skincheck)
for i = 1, #skincheck do
    TriggerEvent('DoLongHudText',  skincheck[i].slot .. " | " .. skincheck[i].name, i)
end
end)

RegisterCommand("g1", function(source, args, rawCommand)
TriggerEvent("facewear:adjust",2,false)
end, false)

RegisterCommand("g0", function(source, args, rawCommand)
TriggerEvent("facewear:adjust",2,true)
end, false)

RegisterCommand("k1", function(source, args, rawCommand)
TriggerEvent("facewear:adjust",3,false)
end, false)

RegisterCommand("k0", function(source, args, rawCommand)
TriggerEvent("facewear:adjust",3,true)
end, false)

RegisterCommand("m1", function(source, args, rawCommand)
TriggerEvent("facewear:adjust",4,false)
end, false)

RegisterCommand("m0", function(source, args, rawCommand)
TriggerEvent("facewear:adjust",4,true)
TriggerEvent("DoLongHudText","Mask on. Fuck it, mask off. Mask on Fuck it, mask off.", 1)
end, false)

RegisterCommand("t1", function(source, args, rawCommand)
TriggerEvent("facewear:adjust",5,false)
end, false)

RegisterCommand("t0", function(source, args, rawCommand)
TriggerEvent("facewear:adjust",5,true)
end, false)

RegisterCommand("s1", function(source, args, rawCommand)
TriggerEvent("facewear:adjust",6,false)
end, false)

RegisterCommand("s0", function(source, args, rawCommand)
TriggerEvent("facewear:adjust",6,true)
end, false)


Citizen.CreateThread(function()
TriggerEvent('chat:addSuggestion', '/g1', "Gözlük tak.")
TriggerEvent('chat:addSuggestion', '/g0', "Gözlük çıkart.")
TriggerEvent('chat:addSuggestion', '/k1', "Kulaklık tak.")
TriggerEvent('chat:addSuggestion', '/k0', "Kulaklık çıkart.")
TriggerEvent('chat:addSuggestion', '/m1', "Maske tak.")
TriggerEvent('chat:addSuggestion', '/m0', "Maske çıkart.")
TriggerEvent('chat:addSuggestion', '/t1', "Üstünü giy.")
TriggerEvent('chat:addSuggestion', '/t0', "üstünü çıkart.")
TriggerEvent('chat:addSuggestion', '/s1', "Şapkanı tak.")
TriggerEvent('chat:addSuggestion', '/s0', "Şapkanı çıkart.")
TriggerEvent('chat:addSuggestion', '/outfits', "Kaydedilen kıyafetlerini gösterir.")
TriggerEvent('chat:addSuggestion', '/outfitadd', "Kıyafetlerini bu komutla kaydediyorsun.")
TriggerEvent('chat:addSuggestion', '/outfitdel', "Kıyafetlerini bu komutla siliyorsun.")
TriggerEvent('chat:addSuggestion', '/outfituse', "Kıyafetlerini bu komutla giyiyorsun.")
end)


local facialWear = {
[1] = { ["Prop"] = -1, ["Texture"] = -1 },
[2] = { ["Prop"] = -1, ["Texture"] = -1 },
[3] = { ["Prop"] = -1, ["Texture"] = -1 },
[4] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 }, -- this is actually a pedtexture variations, not a prop
[5] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 }, -- this is actually a pedtexture variations, not a prop
[6] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 }, -- this is actually a pedtexture variations, not a prop
}
--arms 4
-- face 0
RegisterNetEvent("facewear:update")
AddEventHandler("facewear:update",function()
for i = 0, 3 do
    if GetPedPropIndex(PlayerPedId(), i) ~= -1 then
        facialWear[i+1]["Prop"] = GetPedPropIndex(PlayerPedId(), i)
    end
    if GetPedPropTextureIndex(PlayerPedId(), i) ~= -1 then
        facialWear[i+1]["Texture"] = GetPedPropTextureIndex(PlayerPedId(), i)
    end
end

if GetPedDrawableVariation(PlayerPedId(), 1) ~= -1 then
    facialWear[4]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 1)
    facialWear[4]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 1)
    facialWear[4]["Texture"] = GetPedTextureVariation(PlayerPedId(), 1)
end

if GetPedDrawableVariation(PlayerPedId(), 11) ~= -1 then
    facialWear[5]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 11)
    facialWear[5]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 11)
    facialWear[5]["Texture"] = GetPedTextureVariation(PlayerPedId(), 11)
end
end)


RegisterNetEvent("facewear:adjust")
AddEventHandler("facewear:adjust",function(faceType,remove)
local AnimSet = "none"
local AnimationOn = "none"
local AnimationOff = "none"
local PropIndex = 0

local AnimSet = "mp_masks@on_foot"
local AnimationOn = "put_on_mask"
local AnimationOff = "put_on_mask"

facialWear[6]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 0)
facialWear[6]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 0)
facialWear[6]["Texture"] = GetPedTextureVariation(PlayerPedId(), 0)

for i = 0, 3 do
    if GetPedPropIndex(PlayerPedId(), i) ~= -1 then
        facialWear[i+1]["Prop"] = GetPedPropIndex(PlayerPedId(), i)
    end
    if GetPedPropTextureIndex(PlayerPedId(), i) ~= -1 then
        facialWear[i+1]["Texture"] = GetPedPropTextureIndex(PlayerPedId(), i)
    end
end

if GetPedDrawableVariation(PlayerPedId(), 1) ~= -1 then
    facialWear[4]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 1)
    facialWear[4]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 1)
    facialWear[4]["Texture"] = GetPedTextureVariation(PlayerPedId(), 1)
end

if GetPedDrawableVariation(PlayerPedId(), 11) ~= -1 then
    facialWear[5]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 11)
    facialWear[5]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 11)
    facialWear[5]["Texture"] = GetPedTextureVariation(PlayerPedId(), 11)
end

if faceType == 1 then
    PropIndex = 0
elseif faceType == 2 then
    PropIndex = 1

    AnimSet = "clothingspecs"
    AnimationOn = "take_off"
    AnimationOff = "take_off"

elseif faceType == 3 then
    PropIndex = 2
elseif faceType == 4 then
    PropIndex = 1
    if remove then
        AnimSet = "missfbi4"
        AnimationOn = "takeoff_mask"
        AnimationOff = "takeoff_mask"
    end
elseif faceType == 5 then
    PropIndex = 11
    AnimSet = "oddjobs@basejump@ig_15"
    AnimationOn = "puton_parachute"
    AnimationOff = "puton_parachute"	
end

loadAnimDict( AnimSet )
if faceType == 5 then
    if remove then
        SetPedComponentVariation(PlayerPedId(), 3, 2, facialWear[6]["Texture"], facialWear[6]["Palette"])
    end
end
if remove then
    TaskPlayAnim( PlayerPedId(), AnimSet, AnimationOff, 4.0, 3.0, -1, 49, 1.0, 0, 0, 0 )
    Citizen.Wait(500)
    if faceType ~= 5 then
        if faceType == 4 then
            SetPedComponentVariation(PlayerPedId(), PropIndex, -1, -1, -1)
        else
            if faceType ~= 2 then
                ClearPedProp(PlayerPedId(), tonumber(PropIndex))
            end
        end
    end
else
    TaskPlayAnim( PlayerPedId(), AnimSet, AnimationOn, 4.0, 3.0, -1, 49, 1.0, 0, 0, 0 )
    Citizen.Wait(500)
    if faceType ~= 5 and faceType ~= 2 then
        if faceType == 4 then
            SetPedComponentVariation(PlayerPedId(), PropIndex, facialWear[faceType]["Prop"], facialWear[faceType]["Texture"], facialWear[faceType]["Palette"])
        else
            SetPedPropIndex( PlayerPedId(), tonumber(PropIndex), tonumber(facialWear[PropIndex+1]["Prop"]), tonumber(facialWear[PropIndex+1]["Texture"]), false)
        end
    end
end
if faceType == 5 then
    if not remove then
        SetPedComponentVariation(PlayerPedId(), 3, 1, facialWear[6]["Texture"], facialWear[6]["Palette"])
        SetPedComponentVariation(PlayerPedId(), PropIndex, facialWear[faceType]["Prop"], facialWear[faceType]["Texture"], facialWear[faceType]["Palette"])
    else
        SetPedComponentVariation(PlayerPedId(), PropIndex, -1, -1, -1)
    end
    Citizen.Wait(1800)
end
if faceType == 2 then
    Citizen.Wait(600)
    if remove then
        ClearPedProp(PlayerPedId(), tonumber(PropIndex))
    end

    if not remove then
        Citizen.Wait(140)
        SetPedPropIndex( PlayerPedId(), tonumber(PropIndex), tonumber(facialWear[PropIndex+1]["Prop"]), tonumber(facialWear[PropIndex+1]["Texture"]), false)
    end
end
if faceType == 4 and remove then
    Citizen.Wait(1200)
end
ClearPedTasks(PlayerPedId())
end)


function loadAnimDict( dict )
while ( not HasAnimDictLoaded( dict ) ) do
    RequestAnimDict( dict )
    Citizen.Wait( 5 )
end
end