--[[BUGS:



	ADD:
		Keep track of bans, and prevent people from joining if they were banned.
		Make temp bans.
--]]

local function OnPlayerConnecting(name, setReason, deferrals)
	local identifiers, steamIdentifier = GetPlayerIdentifiers(source)

	for _,v in pairs(identifiers)do
		print(v)
		if string.match(v, "steam") then
			steamIdentifier = v
			break
		end
	end
	print(steamIdentifier)

	if steamIdentifier == nil then
		setReason("You must have Steam open to be able to play on this FiveM server, thank you bossman B)")
		CancelEvent()


	end
end

AddEventHandler("playerConnecting", OnPlayerConnecting)
