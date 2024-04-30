local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/Guerric9018/OrionLibFixed/main/OrionLib.lua')))()

_G.CHATBOTHUB_BLACKLISTED = {
	--["Name"] = true,
}

_G.CHATBOTHUB_DISPLAYTOFULLNAME = {
	--["Display name"] = "Full name"
}

_G.CHATBOTHUB_BLACKLISTEDCONTENT = {
	--"Full name (Display name))"
}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local alreadyRan = true

if _G.CHATBOTHUB_RAN == nil then
    alreadyRan = false
	_G.CHATBOTHUB_ON = false
	_G.CHATBOTHUB_CREDITS = 0
	_G.CHATBOTHUB_LOGIN = false
	_G.CHATBOTHUB_PREMIUM = false
	_G.CHATBOTHUB_CUSTOMPROMPT = false
	_G.CHATBOTHUB_CUSTOMPROMPTTEXT = "Just be a normal AI."
end

local msg = function() return end


local success, textChannels = pcall(function()
	return game:GetService("TextChatService").TextChannels
end)

if success then
	print("New chat system detected")
	msg = function(txt) game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(txt) end
else
	print("Old chat system detected")
	msg = function(txt) game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(txt, "All") end
end


local AIs = {
	"Waifu",
	"Nerd",
	"Christian",
	"Robot",
	"Normal"
}

if _G.CHATBOTHUB_RAN == nil then
	_G.CHATBOTHUB_MaxDistance = 20
	_G.CHATBOTHUB_Character = "Waifu"
end

_G.CHATBOTHUB_RAN = true

local updateCredits = function() return end
local updatePremium = function() return end

local function login(key)
	key = HttpService:UrlEncode(key)
	local response = game:HttpGet("https://guerric.pythonanywhere.com/login?uid="..(tostring(LocalPlayer.UserId)) .. "&key=" .. key)
	if response == "REFUSED" then
		OrionLib:MakeNotification{
			Name = "Error",
			Content = "Wrong key given",
			Image = "rbxassetid://16661795528",
			Time = 3
		}
		return false
	end
	if response == "ACCEPTED" then
		
		_G.CHATBOTHUB_CREDITS = tonumber(game:HttpGet("https://guerric.pythonanywhere.com/credits?uid="..LocalPlayer.UserId))
		local premium = tonumber(game:HttpGet("https://guerric.pythonanywhere.com/premium?uid="..LocalPlayer.UserId))
		if premium == 1 then _G.CHATBOTHUB_PREMIUM = true else _G.CHATBOTHUB_PREMIUM = false end
		print(_G.CHATBOTHUB_PREMIUM)
		updateCredits()
		updatePremium()
		OrionLib:MakeNotification{
			Name = "Logged in",
			Content = "You successfully logged in!\nYou have ".._G.CHATBOTHUB_CREDITS.." points.",
			Image = "rbxassetid://7115671043",
			Time = 3
		}
		_G.CHATBOTHUB_KEY = key
		_G.CHATBOTHUB_LOGIN = true
		return true
	end
end

local findPlayerName = function(name)
	for i,player in pairs(game.Players:GetChildren()) do
		local prefix_length = #name
		local name_prefix = player.Name:sub(1, prefix_length)
		if(name_prefix == name) then
			return player.Name, player.DisplayName
		end
	end
	for i,player in pairs(game.Players:GetChildren()) do
		local prefix_length = #name
		local name_prefix = player.DisplayName:sub(1, prefix_length)
		if(name_prefix == name) then
			return player.Name, player.DisplayName
		end
	end
	return nil, nil
end


local Window = OrionLib:MakeWindow({
	Name = "ChatBot Hub",
	HidePremium = false,
	SaveConfig = false,
	IntroText = "ChatBot Hub",
	IntroEnabled = true,
	IntroIcon = "rbxassetid://13188306657"})


local MainTab = Window:MakeTab({
	Name = "Main",
	Icon = "rbxassetid://6034798461",
})

local CharacterTab = Window:MakeTab{
	Name = "AI",
	Icon = "rbxassetid://13680871118"
}

local PremiumTab = Window:MakeTab{
	Name = "Premium",
	Icon = "rbxassetid://11835491319",
}

local ChatTab = Window:MakeTab{
	Name = "Chat",
	Icon = "rbxassetid://14376097365"
}

local MoreTab = Window:MakeTab{
	Name = "More",
	Icon = "rbxassetid://5107175347",
}

local HelpTab = Window:MakeTab{
	Name = "Help",
	Icon = "rbxassetid://15668939723"
}

local resetToggle = function() return end
local doCallback = true

local RunningToggle = MainTab:AddToggle{
	Name = "Running",
	Default = _G.CHATBOTHUB_ON,
	Callback = function(state)

		if not _G.CHATBOTHUB_LOGIN then
			if doCallback then
				OrionLib:MakeNotification{
					Name = "Error",
					Content  = "You first need to login, go check the 'more' tab",
					Image = "rbxassetid://6723839910",
					Time = 3
				}
				resetToggle()
			end
		end
		_G.CHATBOTHUB_ON = state
	end
}

resetToggle = function()
	doCallback = false
	RunningToggle:Set(false)
	wait(0.3)
	doCallback = true
end

local CreditLabel = MainTab:AddLabel("Points balance: ".. _G.CHATBOTHUB_CREDITS)

updateCredits = function()
	CreditLabel:Set(_G.CHATBOTHUB_CREDITS)
end

local addPlayer = function() return end
local removePlayer = function() return end

MainTab:AddTextbox({
	Name = "Blacklist player",
	Default = "",
	TextDisappear = true,
	Callback = function(player)
		addPlayer(player)
	end	  
})

local BlacklistedDropdown = MainTab:AddDropdown({
	Name = "Blacklisted players",
	Description = "Select player to whitelist...",
	Default = "",
	Options = _G.CHATBOTHUB_BLACKLISTED,
	Callback = function(FullName) removePlayer(FullName) end
})

addPlayer = function(player)
	print(player)
	local FullName, Name = findPlayerName(player)
	if FullName==nil then return end
	_G.CHATBOTHUB_BLACKLISTED[FullName] = true
	_G.CHATBOTHUB_DISPLAYTOFULLNAME[FullName.." ("..Name..")"] = FullName
	table.insert(_G.CHATBOTHUB_BLACKLISTEDCONTENT, FullName.." ("..Name..")")
	BlacklistedDropdown:Refresh(_G.CHATBOTHUB_BLACKLISTEDCONTENT,true)
end

removePlayer = function(player)
	local FullName = _G.CHATBOTHUB_DISPLAYTOFULLNAME[player]
	if FullName==nil then return end
	_G.CHATBOTHUB_BLACKLISTED[FullName] = false
	for i, v in ipairs(_G.CHATBOTHUB_BLACKLISTEDCONTENT) do
		print(v)
		if v == player then 
			table.remove(_G.CHATBOTHUB_BLACKLISTEDCONTENT, i)
		end
	end
	BlacklistedDropdown:Refresh(_G.CHATBOTHUB_BLACKLISTEDCONTENT,true)
	BlacklistedDropdown:Set("")
end

MainTab:AddButton{
	Name = "Reset blacklist",
	Callback = function() 
		table.clear(_G.CHATBOTHUB_BLACKLISTED)
		table.clear(_G.CHATBOTHUB_DISPLAYTOFULLNAME)
		table.clear(_G.CHATBOTHUB_BLACKLISTEDCONTENT)
		BlacklistedDropdown:Refresh(_G.CHATBOTHUB_BLACKLISTEDCONTENT,true)
	end
}

MainTab:AddTextbox({
	Name = "Listening range",
	Default = "20",
	TextDisappear = false,
	Callback = function(value)
		_G.CHATBOTHUB_MaxDistance = tonumber(value)
	end	  
})

local resetTogglePrem = function() return end

local CharDropdown = CharacterTab:AddDropdown{
	Name = "Select the character of your AI",
	Default = _G.CHATBOTHUB_Character,
	Description = "List is subject to change in future updates! Give ideas in the Discord server!",
	Options = AIs,
	Callback = function(SelectedCharacter) 
		_G.CHATBOTHUB_Character = SelectedCharacter 
		resetTogglePrem()
	end
}


local PremiumLabel = PremiumTab:AddLabel("Premium is NOT activated")

updatePremium = function()
	local PremiumText = "Premium is NOT activated"
	if _G.CHATBOTHUB_PREMIUM then
		PremiumText = "Premium activated!"
	end
	PremiumLabel:Set(PremiumText)
end

updatePremium()

local doCallbackPrem = true

local CustomToggle = PremiumTab:AddToggle{
	Name = "Enable custom prompt",
	Default = _G.CHATBOTHUB_CUSTOMPROMPT,
	Callback = function(state)

		if not _G.CHATBOTHUB_PREMIUM then
			if doCallbackPrem then
				OrionLib:MakeNotification{
					Name = "Error",
					Content  = "You need to have premium to use this feature!",
					Image = "rbxassetid://6723839910",
					Time = 3
				}
				resetTogglePrem()
			end
		end
		_G.CHATBOTHUB_CUSTOMPROMPT = state
	end
}

resetTogglePrem = function()
	doCallbackPrem = false
	CustomToggle:Set(false)
	wait(0.3)
	doCallbackPrem = true
end

local updateCustomPrompt = function() return end

PremiumTab:AddTextbox({
	Name = "Enter custom prompt here: ",
	Default = "",
	TextDisappear = true,
	Callback = function(prompt)
		if not _G.CHATBOTHUB_PREMIUM then
			OrionLib:MakeNotification{
				Name = "Error",
				Content  = "You need to have premium to use this feature!",
				Image = "rbxassetid://6723839910",
				Time = 3
			}
		else
			_G.CHATBOTHUB_CUSTOMPROMPTTEXT = prompt
			updateCustomPrompt()
		end
	end	  
})

local CustomPrompt = PremiumTab:AddParagraph("Custom Prompt", _G.CHATBOTHUB_CUSTOMPROMPTTEXT)

updateCustomPrompt = function()
	CustomPrompt:Set(_G.CHATBOTHUB_CUSTOMPROMPTTEXT)
end

local updateChat = function(message) return end

ChatTab:AddButton{
	Name = "Clear chat",
	Callback = function() 
		updateChat("")
	end
}

local ChatLabel = ChatTab:AddParagraph("AI's answer","")

updateChat = function(message)
	ChatLabel:Set(message)
end

ChatTab:AddTextbox{
	Name = "Message",
	Default = "",
	TextDisappear = true,
	Callback = function(message) 
		message = HttpService:UrlEncode(message)
		local userDisplayURI = HttpService:UrlEncode(LocalPlayer.DisplayName)
		local Character = HttpService:UrlEncode(_G.CHATBOTHUB_Character)
		local custom = "no"
		local shownText = ""

		if _G.CHATBOTHUB_PREMIUM and _G.CHATBOTHUB_CUSTOMPROMPT then
			Character = HttpService:UrlEncode(_G.CHATBOTHUB_CUSTOMPROMPTTEXT)
			custom = "yes"
		end
		local response = game:HttpGet("https://guerric.pythonanywhere.com/chat?msg="..message.."&user="..userDisplayURI.."&key=" .. _G.CHATBOTHUB_KEY .. "&ai=" .. Character .. "&uid=" .. LocalPlayer.UserId .. "&custom=" .. custom .. "&gpt=4")
		
		local chunkSize = 70
		local numChunks = math.ceil(#response / chunkSize)
	 
		_G.CHATBOTHUB_CREDITS -= 1
		OrionLib:MakeNotification{
		 Name = "1 point used",
		 Content = tostring(_G.CHATBOTHUB_CREDITS) .. " points left",
		 Time = 1
		 }
		 CreditLabel:Set(_G.CHATBOTHUB_CREDITS)
	 
	 -- Print each chunk
		 for i = 1, numChunks do
			local startIndex = (i - 1) * chunkSize + 1
			local endIndex = math.min(i * chunkSize, #response)
			local chunk = string.sub(response, startIndex, endIndex)
			shownText = shownText .. chunk .. '\n'
		 end
		
		updateChat(shownText)
	end
}

MoreTab:AddTextbox{
	Name = "Key",
	Default = "",
	TextDisappear = true,
	Callback = function(key) login(key) end
}

MoreTab:AddButton{
	Name = "Official Discord server",
	Description = "Click to copy the link",
	Callback = function() 
		OrionLib:MakeNotification{
			Name = "Discord",
			Content = "Discord link copied to clipboard",
			Time = 3,
			Image = "rbxassetid://10337369764"
		}
		setclipboard("https://discord.gg/MJagjEv9VX") 
	end
}

HelpTab:AddParagraph("Help",
	"<b>\nIf you encounter issues. Please check the following:</b>\n\n" ..
		"<font color=\"rgb(255, 0, 0)\"><b>• Have you logged in?</b></font> Have you put your key in the 'more' tab? If not, go get your key on Discord then come back.\n" ..
		"<font color=\"rgb(255, 0, 0)\"><b>• Have you set 'Running' on in the main tab?</b></font>\n" ..
		"<font color=\"rgb(255, 0, 0)\"><b>• Do you have enough points to generate responses?</b></font>\n\n" ..
		"<b>If nothing works please ask your question in the Discord server.</b>")

OrionLib:Init()

local function main(message, userDisplay, uid)
    message = HttpService:UrlEncode(message)
    userDisplayURI = HttpService:UrlEncode(userDisplay)
    local Character = HttpService:UrlEncode(_G.CHATBOTHUB_Character)
	local custom = "no"
	if _G.CHATBOTHUB_PREMIUM and _G.CHATBOTHUB_CUSTOMPROMPT then
		Character = HttpService:UrlEncode(_G.CHATBOTHUB_CUSTOMPROMPTTEXT)
		custom = "yes"
	end
    local response = game:HttpGet("https://guerric.pythonanywhere.com/chat?msg="..message.."&user="..userDisplayURI.."&key=" .. _G.CHATBOTHUB_KEY .. "&ai=" .. Character .. "&uid=" .. uid .. "&custom=" .. custom .. "&gpt=3.5")
    print(response)
    local data = response
    
    local responseText = data:gsub("i love you", "ily"):gsub("wtf", "wt$"):gsub("zex", "zesty"):gsub("\n", " "):gsub("I love you", "ily"):gsub("I don't know what you're saying. Please teach me.", "I do not understand, try saying it without emojis and/or special characters.")
    if responseText == "" then return end
   wait()
   local chunkSize = 160
   local numChunks = math.ceil(#responseText / chunkSize)

   _G.CHATBOTHUB_CREDITS -= 1
   OrionLib:MakeNotification{
    Name = "1 points used",
    Content = tostring(_G.CHATBOTHUB_CREDITS) .. " points left",
    Time = 1
    }
    CreditLabel:Set(_G.CHATBOTHUB_CREDITS)

-- Print each chunk
    for i = 1, numChunks do
        local startIndex = (i - 1) * chunkSize + 1
        local endIndex = math.min(i * chunkSize, #responseText)
        local chunk = string.sub(responseText, startIndex, endIndex)
        local intro = "[ChatBot]: "
        local chunkProgress = " "..i.."/"..numChunks
        if numChunks == 1 then 
            chunkProgress = ""
        end
        if i == 1 then 
            intro = "[ChatBot]: "..userDisplay.. ", "
        end

        msg(intro .. chunk .. chunkProgress)

        wait(0.1)
    end

   print(userDisplay..", "..responseText)
end

local Players = game:GetService("Players")

if not alreadyRan then
	Players.PlayerChatted:Connect(function(type, plr, message)
		if _G.CHATBOTHUB_CUSTOMPROMPT and (not _G.CHATBOTHUB_PREMIUM) then resetTogglePrem() end
		if not _G.CHATBOTHUB_LOGIN then return end
		if _G.CHATBOTHUB_BLACKLISTED[plr.Name] then return end
		if _G.CHATBOTHUB_CREDITS == 0 then 
			CreditLabel:Set(0)
			OrionLib:MakeNotification{
				Name = "Alert",
				Content = "No points left on your account!",
				Time = 3,
				Image = "rbxassetid://14895395597"
			}
			return
		end
		if _G.CHATBOTHUB_ON and ((Players.LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).magnitude <= _G.CHATBOTHUB_MaxDistance) then
			if plr.Name ~= LocalPlayer.Name and string.sub(message, 1, 1) ~= "#" then
				main(message, plr.DisplayName, LocalPlayer.UserId)
			end
		end
	end)
end