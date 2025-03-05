-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPS = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface("hud",src)
vSERVER = Tunnel.getInterface("hud")
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
Display = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
local Gemstone = 0
local Hood = false
local Pause = false
local Road = "Alta Street"
local Crossing = "Alta Street"
-----------------------------------------------------------------------------------------------------------------------------------------
-- PRINCIPAL | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
local Health = 999
local Armour = 999
-----------------------------------------------------------------------------------------------------------------------------------------
-- THIRST | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
local Thirst = 999
local ThirstTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUNGER | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
local Hunger = 999
local HungerTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- STRESS | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
local Stress = 999
local StressTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- WANTED | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
local Wanted = 0
local WantedTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- OXIGEN | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
local Mask = nil
local Tank = nil
local Oxigen = 100
local OxigenTimers = GetGameTimer()
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADTIMER | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    while true do
        if LocalPlayer["state"]["Active"] then
			local Pid = PlayerId()
            local Ped = PlayerPedId()

            if IsPauseMenuActive() then
                if not Pause and Display then
                    SendNUIMessage({ Action = "Body", Status = false })
                    Pause = true
                end
            else
                if Display then
                    if Pause then
                        SendNUIMessage({ Action = "Body", Status = true })
                        Pause = false
                    end

                    local Coords = GetEntityCoords(Ped)
                    local Armouring = GetPedArmour(Ped)
                    local Healing = GetEntityHealth(Ped) - 100
					local Staminaing = 100 - GetPlayerSprintStaminaRemaining(Pid)
                    local MinRoad, MinCross = GetStreetNameAtCoord(Coords["x"], Coords["y"], Coords["z"])
                    local FullRoad = GetStreetNameFromHashKey(MinRoad)
                    local FullCross = GetStreetNameFromHashKey(MinCross)

                    if Health ~= Healing then
                        if Healing < 0 then
                            Healing = 0
                        end

                        SendNUIMessage({ Action = "Health", Number = Healing })
                        Health = Healing
                    end

                    if Armour ~= Armouring then
                        SendNUIMessage({ Action = "Armour", Number = Armouring })
                        Armour = Armouring
                    end

                    if Oxigen ~= Staminaing then
                        SendNUIMessage({ Action = "Oxigen", Number = Staminaing })
                        Oxigen = Staminaing
                    end

                    if FullRoad ~= "" and Road ~= FullRoad then
                        SendNUIMessage({ Action = "Road", Name = FullRoad })
                        Road = FullRoad
                    end

                    if FullCross ~= "" and Crossing ~= FullCross then
                        SendNUIMessage({ Action = "Crossing", Name = FullCross })
                        Crossing = FullCross
                    end
                end
            end

			if Wanted > 0 and WantedTimer <= GetGameTimer() then
				Wanted = Wanted - 1
				WantedTimer = GetGameTimer() + 1000
				SendNUIMessage({ Action = "Wanted", Number = Wanted })
			end

			if GlobalState["Hours"] and GlobalState["Minutes"] then
				SendNUIMessage({ Action = "Clock", Hours = GlobalState["Hours"], Minutes = GlobalState["Minutes"] })
			end

			SendNUIMessage({ Action = "Voice", Status = MumbleIsPlayerTalking(Pid) and "#ef6c37" or "#ffffff3d" })

            if GetEntityHealth(Ped) > 100 then
				if Hunger < 15 and HungerTimer <= GetGameTimer() then
					HungerTimer = GetGameTimer() + 10000
					ApplyDamageToPed(Ped, math.random(2), false)
					TriggerEvent("Notify", "amarelo", "Sofrendo com a <b>Fome</b>.",2500)
				end

				if Thirst < 15 and ThirstTimer <= GetGameTimer() then
					ThirstTimer = GetGameTimer() + 10000
					ApplyDamageToPed(Ped, math.random(2), false)
					TriggerEvent("Notify", "amarelo", "Sofrendo com a <b>Sede</b>.", 2500)
				end

				if Stress >= 40 and StressTimer <= GetGameTimer() then
					StressTimer = GetGameTimer() + 10000
					TriggerEvent("Notify", "amarelo", "Sofrendo com o <b>Estresse</b>.", 2500)

					AnimpostfxPlay("MenuMGIn")
					SetTimeout(1500, function()
						AnimpostfxStop("MenuMGIn")
					end)
				end
			end
        end

        Wait(1000)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:PASSPORT | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("hud:Passport",function(Number)
	SendNUIMessage({ Action = "Passport", Number = Number })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:VOIP | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("hud:Voip",function(Number)
	local Target = { "Baixo","Normal", "Alto" }

	SendNUIMessage({ Action = "Voip", Voip = Target[Number] })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:WANTED | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Wanted")
AddEventHandler("hud:Wanted",function(Seconds)
	Wanted = Seconds
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WANTED | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Wanted", function()
	return Wanted > 0 and true or false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:ACTIVE | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("hud:Active",function(Status)
	SendNUIMessage({ Action = "Body", Status = Status })
	Display = Status
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("hud",function()
	Display = not Display
	SendNUIMessage({ Action = "Body", Status = Display, Hours = GlobalState["Hours"], Minutes = GlobalState["Minutes"] })

	if not Display then
		if IsMinimapRendering() then
			DisplayRadar(false)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:THIRST | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Thirst")
AddEventHandler("hud:Thirst",function(Number)
	if Thirst ~= Number then
		SendNUIMessage({ Action = "Thirst", Number = Number })
		Thirst = Number
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:HUNGER | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Hunger")
AddEventHandler("hud:Hunger",function(Number)
	if Hunger ~= Number then
		SendNUIMessage({ Action = "Hunger", Number = Number })
		Hunger = Number
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:STRESS | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Stress")
AddEventHandler("hud:Stress",function(Number)
	if Stress ~= Number then
		SendNUIMessage({ Action = "Stress", Number = Number })
		Stress = Number
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:OXIGEN | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Oxigen")
AddEventHandler("hud:Oxigen", function(Number)
	if Oxigen ~= Number then
		SendNUIMessage({ Action = "Oxigen", Number = Number })
		Oxigen = Number
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:RADIO | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("hud:Radio",function(Frequency)
	if type(Frequency) == "number" then
		SendNUIMessage({ Action = "Frequency", Frequency = Frequency.."0.Mhz" })
	else
		SendNUIMessage({ Action = "Frequency", Frequency = Frequency })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:ADDGEMSTONE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:AddGemstone")
AddEventHandler("hud:AddGemstone",function(Number)
	Gemstone = Gemstone + Number

	SendNUIMessage({ Action = "Gemstone", Number = Gemstone })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:REMOVEGEMSTONE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:RemoveGemstone")
AddEventHandler("hud:RemoveGemstone",function(Number)
	Gemstone = Gemstone - Number

	if Gemstone < 0 then
		Gemstone = 0
	end

	SendNUIMessage({ Action = "Gemstone", Number = Gemstone })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:NOTIFY | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Notify")
AddEventHandler("Notify",function(type,mensagem,timer)
	SendNUIMessage({ Action = "Notify", css = type, text = mensagem, length = timer })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:HOOD | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Hood")
AddEventHandler("hud:Hood",function()
	if Hood then
		DoScreenFadeIn(0)
		Hood = false
	else
		DoScreenFadeOut(0)
		Hood = true
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:SCUBAREMOVE | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:ScubaRemove")
AddEventHandler("hud:ScubaRemove",function()
	if DoesEntityExist(Mask) then
		TriggerServerEvent("DeleteObject",ObjToNet(Mask))
		Mask = nil
	end

	if DoesEntityExist(Tank) then
		TriggerServerEvent("DeleteObject",ObjToNet(Tank))
		Tank = nil
	end

	SetEnableScuba(PlayerPedId(),false)
	SetPedMaxTimeUnderwater(PlayerPedId(),10.0)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:SCUBA | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Scuba")
AddEventHandler("hud:Scuba",function()
	if Mask or Tank then
		TriggerEvent("hud:ScubaRemove")
	else
		local Ped = PlayerPedId()
		local Coords = GetEntityCoords(Ped)

		local Progression,Network = vRPS.CreateObject("p_s_scuba_tank_s",Coords["x"],Coords["y"],Coords["z"])
		if Progression then
			Tank = LoadNetwork(Network)
			AttachEntityToEntity(Tank,Ped,GetPedBoneIndex(Ped,24818),-0.28,-0.24,0.0,180.0,90.0,0.0,true,true,false,true,2,true)
			SetModelAsNoLongerNeeded("p_s_scuba_tank_s")
		end

		local Progression,Network = vRPS.CreateObject("p_s_scuba_mask_s",Coords["x"],Coords["y"],Coords["z"])
		if Progression then
			Mask = LoadNetwork(Network)
			AttachEntityToEntity(Mask,Ped,GetPedBoneIndex(Ped,12844),0.0,0.0,0.0,180.0,90.0,0.0,true,true,false,true,2,true)
			SetModelAsNoLongerNeeded("p_s_scuba_tank_s")
		end

		SetEnableScuba(Ped,true)
		SetPedMaxTimeUnderwater(Ped,2000.0)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADMASK | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		if LocalPlayer["state"]["Active"] then
			if Mask ~= nil then
				if GetGameTimer() >= OxigenTimers then
					OxigenTimers = GetGameTimer() + 30000

					Oxigen = Oxigen - 1
					vSERVER.Oxigen(1)
				end
			end
		end

		Wait(1000)
	end
end)