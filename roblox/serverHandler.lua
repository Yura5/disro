-- A regular server-side script

local CONNECT_ENDPOINT = "127.0.0.1:3000/rbxwebhook"
local CONNECT_API_KEY = "df3Vjt5FxL2ZWnn4YkLues"

local connection = require(script.Parent:WaitForChild("modClient"))
local client = connection.new({ apiKey = CONNECT_API_KEY });

local players = game:GetService("Players")
local modFuncs = require(script.Parent:WaitForChild("modFunctions"))

client:connect(CONNECT_ENDPOINT)

--------------------------------PLAYERS DATA------------------------------------

local playerSendData = {}

do
	for i, player in ipairs(players:GetPlayers()) do
		playerSendData[player.UserId] = player.Name
	end

	client:send("allServerPlayers", {
		serverId = client.Id;
		players = playerSendData;
	})
end

players.PlayerAdded:Connect(function(player)
	client:send("addServerPlayer", {
		serverId = client.Id;
		player = {
			userId = player.UserId;
			username = player.Name;
		};
	})
end)

players.PlayerRemoving:Connect(function(player)
	client:send("removeServerPlayer", {
		serverId = client.Id;
		player = player.UserId;
	})
end)

--------------------------------MODERATION------------------------------------

client:on("gamekick", function(data)

	local target = players:GetPlayerByUserId(data.targetId)

	-- Player not in the game
	if target == nil then return end

	modFuncs.handleKick(target, data.reason)

end)

client:on("gameban", function(data)

	local TargetName = players:GetNameFromUserIdAsync(data.targetId)

	modFuncs.handleBan(data.targetId, data.reason)

end)

client:on("gameunban", function(data)

	modFuncs.handleUnban(data.targetId)

end)

game:BindToClose(function()
	client:disconnect()
end)