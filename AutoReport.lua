getgenv().autoreport = {
	Advertise = true,
	Safe = false,
	Webhook = ""
};
--[[

	This property is protected.
	You are not allowed to claim this as your own.
	Removal of advertisements of https://www.discord.gg/outliershub is prohibited.
	Removal of initial credits to the authors is prohibited.

]]

if setfflag then
	setfflag("AbuseReportScreenshotPercentage", 0)
	setfflag("DFFlagAbuseReportScreenshot", "False") 
end

repeat task.wait() until game:IsLoaded()

local Default = {
	Advertise = true;
	Safe = false;
	Webhook = ""; -- Webhook URL

	Words = {
		Blacklist = "https://raw.githubusercontent.com/CF-Trail/Auto-Report/main/words/blacklisted.lua";
		Whitelist = "https://raw.githubusercontent.com/CF-Trail/Auto-Report/main/words/whitelisted.lua";
	};

	ReportFriends = false;
}

-- sorry for the executed check t hing taking 7 commits or sum
-- my 3:49 am brain cannot handle

if not autoreport then
	getgenv().autoreport = Default
elseif wasAutoReportExecuted then
	return warn("Auto-Report is already executed!")
end;

getgenv().wasAutoReportExecuted = true

for _,v in next, Default do
	if not autoreport[_] then getgenv().autoreport[_] = v end
end

if autoreport.library == nil then
	getgenv().autoreport.library = (loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source")))();
end;

local messages = {
	blacklisted = {},
	whitelisted = {},
};

pcall(function() -- Sometimes http get fails, or the link maybe invalid or missing.
	messages = {
		blacklisted = loadstring(game:HttpGet(autoreport.Words.Blacklist))(),
		whitelisted = loadstring(game:HttpGet(autoreport.Words.Whitelist))()
	};
end);

local players = game:GetService("Players");
local lastReportTick = 0;
local reportQueue = {};
local lib = {};
local success, error_message = pcall(function()
	function lib:notify(title, text)
		autoreport.library:MakeNotification({
			Name = title,
			Content = text,
			Time = 3
		});
	end;

	function lib:report(player, thing, reason)
		players:ReportAbuse(player, thing, reason)
	end;

	function lib:addToQueue(player, thing, reason, offensive, message) 
		if (reportQueue[player.UserId] and #reportQueue[player.UserId] > 0) then 
			return
		end
		for word, _ in next, messages.whitelisted do
			if string.match(message, word) then
				return false;
			end;
		end;
		if autoreport.Webhook ~= "" and autoreport.Webhook ~= nil then
			local data = 
				{
					["embeds"] = {{
						["title"] = "**" .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "**",
						["description"] = "Auto-reported a player",
						["type"] = "rich",
						["color"] = tonumber(0x00aff4),
						["url"] = "https://www.roblox.com/games/" .. game.PlaceId,
						["fields"] = {
							{
								["name"] = "Name",
								["value"] = "[" .. player.Name .. "](https://www.roblox.com/users/" .. player.UserId .. ")",
								["inline"] = true
							},
							{
								["name"] = "Message",
								["value"] =	message,
								["inline"] = true
							},
							{
								["name"] = "Offensive part",
								["value"] = offensive,
								["inline"] = true
							}
						},
						["footer"] = {
							["text"] = "\nIf you think this is a mistake, contact snnwer#1349 or .gg#1780"
						},
						["author"] = {
							["name"] = "Auto Report"
						}
					}}
				}
			local newdata = (game:GetService("HttpService")):JSONEncode(data);
			local request = http_request or request or HttpPost or syn.request;
			local abcdef = {
				Url = autoreport.Webhook,
				Body = newdata,
				Method = "POST",
				Headers = {
					["content-type"] = "application/json"
				}
			};
			request(abcdef);
		end;

		if not reportQueue[player.UserId] then 
			reportQueue[player.UserId] = {}
		end

		local reportAmount = autoreport.Safe and math.random(1,2) or math.random(5, 12)
		for i = 1, reportAmount do
			table.insert(reportQueue[player.UserId], {
				player = player,
				thing = thing,
				reason = reason,
				offensive = offensive,
				message = message,
			})
		end
	end

	function handler(player, msg)
		local report_type, reason;
		msg = string.lower(msg);
		for i, v in next, messages.blacklisted do
			if string.match(msg, i) then
				thing, reason, offensive = v[1], v[2], i;
				if autoreport.Advertise == true then (game:GetService("ReplicatedStorage")).DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w " .. player.Name .. " you got mass reported by .gg/outliershub", "All"); end;
			end;
		end;
		if thing and reason and offensive then
			lib:addToQueue(player, thing, reason, offensive, msg);
		end;
	end;

	local function getNextInQueue() -- returns the next player in the queue
		for i,v in next, reportQueue do 
			if #v > 0 then
				local a = v[1]
				table.remove(v, 1)
				return a, i;
			end
		end;
		return nil, 0;
	end;

	function handleQueue() -- report next player in queue
		local nextInQueue, index = getNextInQueue()
		if not nextInQueue then 
			return
		end;
		lib:report(nextInQueue.player, nextInQueue.thing, nextInQueue.reason)
		lib:notify("Report", "Reported " .. nextInQueue.player.Name .. " because of \"" .. nextInQueue.message .. "\"");
	end;
end);

if not success then
	error(error_message);
end;

for _, plr in pairs(players:GetPlayers()) do
	if plr ~= players.LocalPlayer and not (autoreport.ReportFriends and players.LocalPlayer:IsFriendsWith(plr.UserId) or false) then -- if 'or true' is still here, remove it. it was for testing purposes.
		plr.Chatted:Connect(function(msg)
			handler(plr, msg);
		end);
	end;
end;
players.PlayerAdded:Connect(function(plr)
	if plr ~= players.LocalPlayer and not (autoreport.ReportFriends and players.LocalPlayer:IsFriendsWith(plr.UserId) or false) then
		plr.Chatted:Connect(function(msg)
			handler(plr, msg);
		end);
	end;
end);

coroutine.wrap(function()
	while true do -- AutoReportQueue loop
		if tick() - lastReportTick > 10 then -- 1 Report per 10s is the max (unconfirmed).
			handleQueue()
			lastReportTick = tick()
		end
		task.wait(0.1)
	end
end)();

pcall(function()
	autoreport.library:MakeNotification({
		Name = "Loaded!",
		Content = "Script was made by .gg#1780 and snnwer#1349",
		Time = 8
	});

	autoreport.library:MakeNotification({
		Name = "Contribution",
		Content = "Contribution was made by engo#0320 // https://engo.gq",
		Time = 8
	});

	autoreport.library:MakeNotification({
		Name = "Join the creators' discord",
		Content = "discord.gg/outliershub",
		Time = 8
	});
end)
