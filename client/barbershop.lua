barberShops = {
	{335.4, -215.96, 54.09},
	{1932.0756835938, 3729.6706542969, 32.844413757324},
	{-278.19036865234, 6228.361328125, 31.695510864258},
	{1211.9903564453, -472.77117919922, 66.207984924316},
	{-33.224239349365, -152.62608337402, 57.076496124268},
	{136.7181854248, -1708.2673339844, 29.291622161865},
	{-815.18896484375, -184.53868103027, 37.568943023682},
	{-1283.2886962891, 1117.3210449219, 6.9901118278503}
}

local showbarberShops = false

RegisterNetEvent('hairDresser:ToggleHair')
AddEventHandler('hairDresser:ToggleHair', function()
    showbarberShops = not showbarberShops
   for _, item in pairs(barberShops) do
        if not showbarberShops then
            if item.blip ~= nil then
                RemoveBlip(item.blip)
            end
        else
            item.blip = AddBlipForCoord(item[1], item[2], item[3])
            SetBlipSprite(item.blip, 71)
		    SetBlipColour(item.blip, 1)
			SetBlipScale(item.blip, 0.6)
			SetBlipAsShortRange(item.blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Berber Dükkanı")
			EndTextCommandSetBlipName(item.blip)
        end
    end

end)

Citizen.CreateThread(function()
	showbarberShops = true
	TriggerEvent('hairDresser:ToggleHair')
end)