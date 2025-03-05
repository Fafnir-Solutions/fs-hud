-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
local Fuel = 0
local Speed = 0
local Engine = 0
local Locked = false
local Headbeams = false
local Headlights = false
local ActualVehicle = nil
local IndicatorLights = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- SEATBELT | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
local SeatbeltSpeed = 0
local SeatbeltLock = false
local SeatbeltVelocity = vec3(0,0,0)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSYSTEM | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 999
		if Display then
			local Ped = PlayerPedId()
			if IsPedInAnyVehicle(Ped) then
				TimeDistance = 100

				if not IsMinimapRendering() then
					SetBigmapActive(false,false)
					DisplayRadar(true)
				end

				local Vehicle = GetVehiclePedIsUsing(Ped)
				local Rpm = GetVehicleCurrentRpm(Vehicle)
				local VFuel = GetVehicleFuelLevel(Vehicle)
				local Gear = GetVehicleCurrentGear(Vehicle)
				local VSpeed = GetEntitySpeed(Vehicle) * 3.6
				local VDrift = GetDriftTyresEnabled(Vehicle)
				local VLocked = GetVehicleDoorLockStatus(Vehicle)
				local VEngine = GetVehicleEngineHealth(Vehicle) / 10
				local _,VHeadlight,VHighBeam = GetVehicleLightsState(Vehicle)

				if GetPedInVehicleSeat(Vehicle, -1) == Ped then
					if GetVehicleDirtLevel(Vehicle) > 0.0 then
						SetVehicleDirtLevel(Vehicle, 0.0)
					end

					local Class = GetVehicleClass(Vehicle)
					if (Class >= 0 and Class <= 7) or Class == 9 then
						if IsControlPressed(1, 21) then
							if VSpeed <= 75.0 and not VDrift then
								SetDriftTyresEnabled(Vehicle, true)
								SetVehicleReduceGrip(Vehicle, true)
								SetReduceDriftVehicleSuspension(Vehicle, true)
							end
						else
							if VDrift then
								SetDriftTyresEnabled(Vehicle, false)
								SetVehicleReduceGrip(Vehicle, false)
								SetReduceDriftVehicleSuspension(Vehicle, false)
							end
						end
					end
				end

				if ActualVehicle ~= Vehicle then
					SendNUIMessage({ Action = "Vehicle", Status = true })
					ActualVehicle = Vehicle
				end

				if Engine ~= VEngine then
					SendNUIMessage({ Action = "Engine", Number = VEngine })
					Engine = VEngine
				end

				if Locked ~= VLocked then
					SendNUIMessage({ Action = "Locked", Status = VLocked })
					Locked = VLocked
				end

				if Headlights ~= VHeadlight or Headbeams ~= VHighBeam then
					SendNUIMessage({ Action = "Headlight", Status = VHeadlight, Beam = VHighBeam })
					Headlights = VHeadlight
					Headbeams = VHighBeam
				end

				if Fuel ~= VFuel then
					SendNUIMessage({ Action = "Fuel", Number = VFuel })
					Fuel = VFuel
				end

				if Speed ~= VSpeed then
					SendNUIMessage({ Action = "Speed", Number = VSpeed })
					Speed = VSpeed
				end

				if (VSpeed == 0 and Gear == 0) or (VSpeed == 0 and Gear == 1) then
					Gear = "N"
				elseif (VSpeed > 0 and Gear == 0) then
					Gear = "R"
				end

				SendNUIMessage({ Action = "Rpm", Number = Rpm, Gear = Gear })
			else
				if ActualVehicle then
					ActualVehicle = nil
					SendNUIMessage({ Action = "Vehicle", Status = false })

					Locked = false
					SendNUIMessage({ Action = "Locked", Status = false })

					Headbeams = false
					Headlights = false
					SendNUIMessage({ Action = "Headlight", Status = 0, Beam = 0 })

					Speed = 0
					SendNUIMessage({ Action = "Speed", Number = 0 })

					Engine = 0
					SendNUIMessage({ Action = "Engine", Number = 0 })

					if IsMinimapRendering() then
						DisplayRadar(false)
					end
				end
			end
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADBELT | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 999
		local Ped = PlayerPedId()

		if IsPedInAnyVehicle(Ped) then
			if not IsPedOnAnyBike(Ped) and not IsPedInAnyHeli(Ped) and not IsPedInAnyPlane(Ped) then
				TimeDistance = 1

				local Vehicle = GetVehiclePedIsUsing(Ped)
				local Speed = GetEntitySpeed(Vehicle) * 2.236936
				if GetVehicleDoorLockStatus(Vehicle) >= 2 or SeatbeltLock then
					DisableControlAction(0,75,true)
					DisableControlAction(27,75,true)
				end

				if Speed ~= SeatbeltSpeed then
					if (SeatbeltSpeed - Speed) >= 60 and not SeatbeltLock then
						SmashVehicleWindow(Vehicle,6)
						SetEntityNoCollisionEntity(Ped,Vehicle,false)
						SetEntityNoCollisionEntity(Vehicle,Ped,false)
						TriggerServerEvent("hud:VehicleEject",SeatbeltVelocity)

						Wait(500)

						SetEntityNoCollisionEntity(Ped,Vehicle,true)
						SetEntityNoCollisionEntity(Vehicle,Ped,true)
					end

					SeatbeltVelocity = GetEntityVelocity(Vehicle)
					SeatbeltSpeed = Speed
				end
			end
		else
			if SeatbeltSpeed ~= 0 then
				SeatbeltSpeed = 0
			end

			if SeatbeltLock then
				SendNUIMessage({ Action = "Seatbelt", Status = false })
				SeatbeltLock = false
			end
		end

		Wait(timeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- LIGHTS | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("Lights", function()
	local Ped = PlayerPedId()
	local Vehicle = GetVehiclePedIsIn(Ped, false)
	if IsPedInAnyVehicle(Ped) and not IsPedInAnyHeli(Ped) and not IsPedInAnyPlane(Ped) and not IsPauseMenuActive() then
		if GetPedInVehicleSeat(Vehicle,-1) == Ped then

			if DoesEntityExist(Vehicle) and not IsEntityDead(Vehicle) then
				IndicatorLights = not IndicatorLights
				if IndicatorLights then
					SetVehicleIndicatorLights(Vehicle,0,true)
					SetVehicleIndicatorLights(Vehicle,1,true)
				else
					SetVehicleIndicatorLights(Vehicle,0,false)
					SetVehicleIndicatorLights(Vehicle,1,false)
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SEATBELT | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("Beltz",function(source)
	local Ped = PlayerPedId()
	if IsPedInAnyVehicle(Ped) and not IsPedOnAnyBike(Ped) and not IsPedInAnyHeli(Ped) and not IsPedInAnyPlane(Ped) and not IsPauseMenuActive() then
		if SeatbeltLock then
			TriggerEvent("sounds:Private", "beltoff", 0.5)
			SendNUIMessage({ Action = "Seatbelt", Status = false })
			SeatbeltLock = false
		else
			TriggerEvent("sounds:Private", "belton", 0.5)
			SendNUIMessage({ Action = "Seatbelt", Status = true })
			SeatbeltLock = true
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CRUISER | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("cr",function(source,Message)
	local Ped = PlayerPedId()
	if IsPedInAnyVehicle(Ped) then
		local Vehicle = GetVehiclePedIsUsing(Ped)
		if GetPedInVehicleSeat(Vehicle,-1) == Ped and not IsEntityInAir(Vehicle) and (GetEntitySpeed(Vehicle) * 2.236936) >= 10 then
			if not Message[1] then
				SetEntityMaxSpeed(Vehicle, GetVehicleEstimatedMaxSpeed(Vehicle))
				TriggerEvent("Notify","amarelo","<b>Controle de Cruzeiro</b> desativado.",5000)
			else
				if parseInt(Message[1]) > 10 then
					SetEntityMaxSpeed(Vehicle, 0.45 * Message[1])
					TriggerEvent("Notify","amarelo","<b>Controle de Cruzeiro</b> ativado.",5000)
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANCORAR | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("ancorar", function()
	local Ped = PlayerPedId()
	if IsPedInAnyBoat(Ped) then
		local Vehicle = GetVehiclePedIsUsing(Ped)
		if CanAnchorBoatHere(Vehicle) then
			TriggerEvent("Notify", "amarelo", "Embarcação desancorada.", 5000)
			SetBoatAnchor(Vehicle, false)
		else
			TriggerEvent("Notify", "amarelo", "Embarcação ancorada.", 5000)
			SetBoatAnchor(Vehicle, true)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- KEYMAPPING | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("Beltz", "Colocar/Retirar o cinto.", "keyboard", "G")
RegisterKeyMapping("Lights", "Ligar as luzes de emergência.", "keyboard", "BACK")