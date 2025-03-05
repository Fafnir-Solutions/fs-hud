-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface("hud", src)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
GlobalState["Work"] = 0
GlobalState["Hours"] = 07
GlobalState["Minutes"] = 30
GlobalState["Weather"] = "EXTRASUNNY"
GlobalState["Blackout"] = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT:CLEAR | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("clearchat",function(source,Message)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",2) then
		local Players = vRPC.Players(source)
		for _,v in pairs(Players) do
			async(function()
				TriggerClientEvent("chat:Clear",v)
			end)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TIMESET | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("timeset",function(source,Message)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",2) and parseInt(Message[1]) and parseInt(Message[2]) then
		GlobalState["Hours"] = Message[1]
		GlobalState["Minutes"] = Message[2]

		if Message[3] then
			GlobalState["Weather"] = Message[3]
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLACKOUT | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("blackout",function(source,Message)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",2) then
		GlobalState["Blackout"] = not GlobalState["Blackout"]
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSYNC | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		GlobalState["Work"] = GlobalState["Work"] + 1
		GlobalState["Minutes"] = GlobalState["Minutes"] + 1

		if GlobalState["Minutes"] >= 60 then
			GlobalState["Hours"] = GlobalState["Hours"] + 1
			GlobalState["Minutes"] = 0

			if GlobalState["Hours"] >= 24 then
				GlobalState["Hours"] = 0
			end
		end

		Wait(10000)
	end
end)