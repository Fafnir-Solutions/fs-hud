-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT:SERVERMESSAGE | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("chat:ServerMessage")
AddEventHandler("chat:ServerMessage", function(Mode, Message)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		if "global" == Mode then
			local Messages = Message:gsub("[<>]", "")

			local Players = vRPC.ClosestPeds(source, ClosestDistance)
			for _,v in pairs(Players) do
				async(function()
					TriggerClientEvent("chat:ClientMessage", v, vRP.FullName(Passport), Messages, Mode)
				end)
			end
		else
			TriggerClientEvent("chat:ClientMessage", -1, vRP.FullName(vRP.Passport(source)), Message.gsub(Message, "[<>]", ""), Mode)
		end
	end
end)