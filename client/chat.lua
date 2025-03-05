-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("ChatEvent", function()
	if LocalPlayer["state"]["Active"] and not LocalPlayer["state"]["Handcuff"] and not LocalPlayer["state"]["Rope"] and not IsNuiFocused() and not IsPauseMenuActive() then
		SendNUIMessage({ Action = "Chat", Block = Block })
		SetNuiFocus(true, true)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT:CLIENTMESSAGE | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("chat:ClientMessage")
AddEventHandler("chat:ClientMessage", function(Author, Message, Mode)
	SendNUIMessage({ Action = "Message", payload = { Author, Message, Mode } })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT:CLEAR | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("chat:Clear")
AddEventHandler("chat:Clear", function()
	SendNUIMessage({ Action = "Clear" })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHATSUBMIT | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("ChatSubmit", function(Data, Callback)
	SetNuiFocus(false, false)

	if LocalPlayer["state"]["Active"] and Data["message"] ~= "" then
		if Data["message"]:sub(1, 1) == "/" then
			ExecuteCommand(Data["message"]:sub(2))
		else
			TriggerServerEvent("chat:ServerMessage", Data["tag"], Data["message"])
		end
	end

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSE | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("close", function(Data, Callback)
	SetNuiFocus(false, false)

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- KEYMAPPING | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("ChatEvent", "Abrir o chat.", "keyboard", "T")
