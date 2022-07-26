local players = game:GetService("Players")
local local_player = players.LocalPlayer
local Invis = true

local function invisible(player_)
	for i,v in pairs (player_.Character:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("Decal") then
			v.Transparency = 1
		else
		end
	end
end

local function Show(player_)
	for i,v in pairs (player_.Character:GetDescendants()) do
		if (v:IsA("BasePart") or v:IsA("Decal")) and v.Name ~= "HumanoidRootPart" then
			v.Transparency = 0
		else
		end
	end
end
