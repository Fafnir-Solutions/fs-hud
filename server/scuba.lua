-----------------------------------------------------------------------------------------------------------------------------------------
-- OXIGEN | https://discord.gg/dRg5grEZFc
-----------------------------------------------------------------------------------------------------------------------------------------
function src.Oxigen(Value)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		vRP.DowngradeOxigen(Passport, Value)
	end
end