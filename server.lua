--[[BUGS:
				If players table is empty, PlayerCheck() will return an error talking about trying to reach a nil value
]]

local function OnPlayerConnecting(name, setReason, deferrals)
	local banTime = ""
	local banReason = ""
	local banAdmin = ""

	deferrals.defer()
	deferrals.update("Checking Steam...")

	local identifiers = GetPlayerIdentifiers(source)

	local steamIdentifier = SteamCheck(identifiers, steamIdentifier)

	if steamIdentifier == nil then
		deferrals.done("You must have Steam open to be able to play on this FiveM server, thank you bossman B)")

	else
		deferrals.update("Checking Database...")
		checkBan, banReason, banAdmin, banTime = BanCheck(steamIdentifier)

		if checkBan == true then
			deferrals.done("YOU ARE BANNED FROM PROJECT REALITY\n\n Reason: " .. banReason .. "\nBy: " .. banAdmin .. "\nTime: " .. banTime)

		else
			PlayerCheck(name, steamIdentifier)
			deferrals.done()
		end
	end
end

function SteamCheck(identifiers, steamIdentifier)
	for _,v in pairs(identifiers)do
		if string.match(v, "steam") then
			steamIdentifier = v
			break
		end
	end
	print(name .. " : " .. steamIdentifier)
	return steamIdentifier
end

function BanCheck(steamIdentifier, banReason, banAdmin, banTime)
	local count = 0

	local findBan = MySQL.Sync.fetchAll("SELECT * FROM bans", {})
	for _, __ in pairs(findBan) do
		count = count + 1
		print(findBan[count].SteamID)
		if findBan[count].SteamID == steamIdentifier then
			banReason = findBan[count].Reason
			banAdmin = findBan[count].Admin
			banTime = findBan[count].BanTime
			return true, banReason, banAdmin, banTime
		end
	end

	return false
end

function PlayerCheck(name, steamIdentifier)
	local count = 0
	local found = false
	local searchPlayers = MySQL.Sync.fetchAll("SELECT * FROM players", {})

	for _, __ in pairs(searchPlayers) do
		count = count + 1

		if searchPlayers[count].SteamID == steamIdentifier then
			found = true
			if searchPlayers[count].SteamName ~= name then
				MySQL.Sync.fetchAll("UPDATE players SET SteamName = @name WHERE SteamID = @steamid", {["@name"] = name, ["@steamid"] = steamIdentifier})
			end
			break
		end
	end

	if found == false then
		count = 0
		while true do
			count = count + 1
			randomDCode = math.random(10000, 99999)
			if searchPlayers == nil or searchPlayers[count].DiscordCode ~= randomDCode then
				MySQL.Sync.fetchAll("INSERT INTO players (SteamName, SteamID, DiscordCode, Rank) VALUES (@steamname, @steamid, @discordcode, @rank)", {["@steamname"] = name, ["@steamid"] = steamIdentifier, ["@discordcode"] = randomDCode, ["@rank"] = "Citizen"})
				break

			elseif searchPlayers[count].DiscordCode == randomDCode then
				repeat until false
			end
		end
	end
end

AddEventHandler("playerConnecting", OnPlayerConnecting)
