-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
local showMe = {}
local showActive = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- SHOWME:PRESSME | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("showme:pressMe")
AddEventHandler("showme:pressMe", function(source, message, seconds, border)
	local pedsource = GetPlayerFromServerId(source)
	if pedsource ~= -1 then
		showMe[GetPlayerPed(pedsource)] = { message, seconds, border }
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SHOWME:REMOVEME | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("showme:removeMe")
AddEventHandler("showme:removeMe", function(source)
	local pedsource = GetPlayerFromServerId(source)
	if pedsource ~= -1 then
		local Ped = GetPlayerPed(pedsource)

		if showActive[Ped] then
			SendNUIMessage({ Action = "ShowMe", Status = "Remove", Id = Ped })
			showActive[Ped] = nil
			showMe[Ped] = nil
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSHOWMEDISPLAY | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 500
		local Ped = PlayerPedId()
		local Coords = GetEntityCoords(Ped)

		for k, v in pairs(showMe) do
			local CoordsMe = GetEntityCoords(k)
			local Distance = #(Coords - CoordsMe)
			if Distance <= 5 then
				TimeDistance = 1

				local _, x, y = GetScreenCoordFromWorldCoord(CoordsMe["x"], CoordsMe["y"], CoordsMe["z"] + 0.7)
				if not showActive[k] then
					SendNUIMessage({ Action = "ShowMe", Status = "Show", Text = v[1], Id = k, X = x, Y = y, Border = v[3] })
					showActive[k] = true
				end

				SendNUIMessage({ Action = "ShowMe", Status = "Update", Text = v[1], Id = k, X = x, Y = y, Border = v[3] })
			else
				if showActive[k] then
					SendNUIMessage({ Action = "ShowMe", Status = "Remove", Id = k })
					showActive[k] = nil
				end
			end
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRHEADSHOWMETIMER | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		for k, v in pairs(showMe) do
			if v[2] > 0 then
				v[2] = v[2] - 1

				if v[2] <= 0 then
					showMe[k] = nil

					if showActive[k] then
						SendNUIMessage({ Action = "ShowMe", Status = "Remove", Id = k })
						showActive[k] = nil
					end
				end
			end
		end

		Wait(1000)
	end
end)
