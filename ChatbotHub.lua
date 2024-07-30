-- Custom OrionLib
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/Guerric9018/OrionLibFixed/main/OrionLib.lua')))()

-- Initialiazing
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

local GUI = Instance.new("ScreenGui")
GUI.Parent = game.CoreGui
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if _G.CHATBOTHUB_RAN == nil then
    alreadyRan = false
	_G.CHATBOTHUB_TTA = false
	_G.CHATBOTHUB_AI_MODEL = "Llama-8B ( default | 5 points )"
	_G.CHATBOTHUB_ON = false
	_G.CHATBOTHUB_CREDITS = 0
	_G.CHATBOTHUB_LOGIN = false
	_G.CHATBOTHUB_PREMIUM = false
	_G.CHATBOTHUB_CUSTOMPROMPT = false
	_G.CHATBOTHUB_CUSTOMPROMPTTEXT = "Just be a normal AI."
    _G.CHATBOTHUB_WHITELIST = false
	_G.CHATBOTHUB_BOTFORMAT = false
	_G.CHATBOTHUB_TTA_RUNNING = true
	_G.CHATBOTHUB_CHAT_BYPASS = false
	_G.CHATBOTHUB_KEY = "default"
	_G.CHATBOTHUB_LOADED = false
	_G.CHATBOTHUB_DELAYED_CHAT = false
	_G.CHATBOTHUB_REMINDING_STATE = false
	_G.CHATBOTHUB_MaxDistance = 20
	_G.CHATBOTHUB_Character = "Normal"
	_G.CHATBOTHUB_BUFFER = false
	_G.CHATBOTHUB_LANGUAGE = "en"
end

_G.CHATBOTHUB_RAN = true

-- Chat system detection
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

-- Checks if the executor has writefile
function writeFileAvailable()
	if writefile then
		return true
	end
end

-- AI characters
local AIs = {
	"Furry",
	"Roast",
	"Waifu",
	"Nerd",
	"Christian",
	"Robot",
    "Brainrot",
	"Normal"
}

-- AI models
local AiModels = {
	"Llama-8B ( default | 5 points )",
	"Llama2-7B ( if default one fails | 5 points )",
	"Llama-70B ( 50 points )"
}

-- Cost of each AI model
local AiCost = {
	["Llama-8B ( default | 5 points )"] = 5,
	["Llama2-7B ( if default one fails | 5 points )"] = 5,
	["Llama-70B ( 50 points )"] = 50
}

-- Languages
local Languages = {
	"en",
	"fr",
	"ru",
	"es",
	"ar"
}


local updateCredits = function() return end
local updatePremium = function() return end


-- Finds player's username and name from its username or displayname
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

-- Finds a player from its username or displayname
local findPlayer = function(name)
	for i,player in pairs(game.Players:GetChildren()) do
		local prefix_length = #name
		local name_prefix = player.Name:sub(1, prefix_length)
		if(string.lower(name_prefix) == name) then
			return player
		end
	end
	for i,player in pairs(game.Players:GetChildren()) do
		local prefix_length = #name
		local name_prefix = player.DisplayName:sub(1, prefix_length)
		if(string.lower(name_prefix) == name) then
			return player
		end
	end
	return nil, nil
end

-- Stops every ongoing action
local function stopAction()
	print(stopping)
	_G.CHATBOTHUB_TTA_RUNNING = false
	wait(1)
	_G.CHATBOTHUB_TTA_RUNNING = true
end

-- TTA actioons
local function jump()
	LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
end

local function spin()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = LocalPlayer.Character.HumanoidRootPart
        
        while _G.CHATBOTHUB_TTA_RUNNING do
            humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(15), 0)
            wait(0.1)
        end
	end
end

local function follow(player)
	local TargetPlayer = findPlayer(player)
	print("following " .. TargetPlayer.DisplayName)
	_G.CHATBOTHUB_TARGET_PLAYER = TargetPlayer
	while _G.CHATBOTHUB_TTA_RUNNING  and TargetPlayer == _G.CHATBOTHUB_TARGET_PLAYER do
		LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):MoveTo(TargetPlayer.Character.HumanoidRootPart.Position)
		wait(0.05)
	end
end

-- Does the actions depending on the AI response
local function checkCommand(input)
	input = string.lower(input)
    if input == "stop" then 
		stopAction()
		return
	end
	if input == "jump" then 
		jump()
		return
	end
	if input == "spin" then 
		spin()
		return
	end
	if input == "null" then
		return
	end

    local followPattern = "^follow%s+(.+)"
    local match = string.match(input, followPattern)

    if match then
        follow(match)
    end
end

-- Login
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
		_G.CHATBOTHUB_KEY = key
		if writeFileAvailable() then
			print("New key saved")
			writefile("chatbothub_key.cb", key)
		end
		_G.CHATBOTHUB_CREDITS = tonumber(game:HttpGet("https://guerric.pythonanywhere.com/credits?uid="..LocalPlayer.UserId))
		local premium = tonumber(game:HttpGet("https://guerric.pythonanywhere.com/premium?uid="..LocalPlayer.UserId.."&key=".._G.CHATBOTHUB_KEY))
		if premium == 1 then _G.CHATBOTHUB_PREMIUM = true else _G.CHATBOTHUB_PREMIUM = false end
		updateCredits()
		updatePremium()
		OrionLib:MakeNotification{
			Name = "Logged in",
			Content = "You successfully logged in!\nYou have ".._G.CHATBOTHUB_CREDITS.." points.",
			Image = "rbxassetid://7115671043",
			Time = 3
		}
		_G.CHATBOTHUB_LOGIN = true
		return true
	end
end

-- Repeats 'I am an AI'
local function remindAIState(state)
	if not _G.CHATBOTHUB_REMINDING_STATE and state then
		_G.CHATBOTHUB_REMINDING_STATE = true
		while _G.CHATBOTHUB_REMINDING_STATE do
			msg("Hello, I am an AI! Please chat with me!")
			wait(10)
		end
	end
	if not state then
		_G.CHATBOTHUB_REMINDING_STATE = false
	end
end

-- For anti spam, messages to be sent
local requestsList = {}

local function addRequestToList(message)
    table.insert(requestsList, message)
    if #requestsList > 5 then
        table.remove(requestsList, 1)
    end
end

local function delayedChat(state)
	if not _G.CHATBOTHUB_DELAYED_CHAT and state then
		_G.CHATBOTHUB_DELAYED_CHAT = true
		while _G.CHATBOTHUB_DELAYED_CHAT do
			if #requestsList > 0 then
				local firstMessage = requestsList[1]
				table.remove(requestsList, 1)
				msg(firstMessage)
			end
			wait(2)
		end
	end
	if not state then
		_G.CHATBOTHUB_DELAYED_CHAT = false
	end
end

-- GUI building
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

local BlacklistTextbox = MainTab:AddTextbox({
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

MainTab:AddToggle{
	Name = "Whitelist mode",
    Default = _G.CHATBOTHUB_WHITELIST,
	Callback = function(state) 
        if state == false then
		    BlacklistedDropdown:Title("Blacklisted players")
            BlacklistTextbox:Title("Blacklist player")
            _G.CHATBOTHUB_WHITELIST = state
        else
            BlacklistedDropdown:Title("Whitelisted players")
            BlacklistTextbox:Title("Whitelist player")
            _G.CHATBOTHUB_WHITELIST = state
        end
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

MainTab:AddToggle{
	Name = "Anti spam",
    Default = _G.CHATBOTHUB_DELAYED_CHAT,
	Callback = function(state) 
        delayedChat(state)
	end
}

MainTab:AddToggle{
	Name = "Buffer (adds a 3 seconds delay)",
    Default = _G.CHATBOTHUB_BUFFER,
	Callback = function(state) 
        _G.CHATBOTHUB_BUFFER = state
	end
}

local resetHistory = function() return end

MainTab:AddButton{
	Name = "Reset AI memory",
	Callback = function() 
		resetHistory()
		OrionLib:MakeNotification{
			Name = "Success",
			Content = "Memory was successfully reset!",
			Image = "rbxassetid://7115671043",
			Time = 3
		}
	end
}

MainTab:AddToggle{
	Name = "Chatbot message formatting ([Chatbot] ...)",
    Default = _G.CHATBOTHUB_BOTFORMAT,
	Callback = function(state) 
        _G.CHATBOTHUB_BOTFORMAT = state
	end
}


MainTab:AddToggle{
	Name = "Auto remind you're a chatbot",
    Default = _G.CHATBOTHUB_REMINDING_STATE,
	Callback = function(state) 
        remindAIState(state)
	end
}


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

local AiDropDown = CharacterTab:AddDropdown{
	Name = "Select the AI model",
	Default = _G.CHATBOTHUB_AI_MODEL,
	Description = "Some AIs are smarter but cost more points!",
	Options = AiModels,
	Callback = function(SelectedModel) 
		_G.CHATBOTHUB_AI_MODEL = SelectedModel
	end
}

local LanguageDropDown = CharacterTab:AddDropdown{
	Name = "Language",
	Default = _G.CHATBOTHUB_LANGUAGE,
	Description = "New languages can be added if there is enough demand",
	Options = Languages,
	Callback = function(SelectedLanguage) 
		_G.CHATBOTHUB_LANGUAGE = SelectedLanguage
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

local resetToggleTTA = function() return end
local doCallbackTTA = true

local TTAToggle = PremiumTab:AddToggle{
	Name = "Text to action mode ( 1.5x points )",
	Default = _G.CHATBOTHUB_TTA,
	Callback = function(state)
		if _G.CHATBOTHUB_LOADED then
			if not _G.CHATBOTHUB_PREMIUM then
				if doCallbackTTA then
					OrionLib:MakeNotification{
						Name = "Error",
						Content  = "You need to have premium to use this feature!",
						Image = "rbxassetid://6723839910",
						Time = 3
					}
					resetToggleTTA()
				end
			end
			_G.CHATBOTHUB_TTA = state
		end
	end
}

resetToggleTTA = function()
	doCallbackTTA = false
	TTAToggle:Set(false)
	wait(0.3)
	doCallbackTTA = true
end

local CustomToggle = PremiumTab:AddToggle{
	Name = "Enable custom prompt",
	Default = _G.CHATBOTHUB_CUSTOMPROMPT,
	Callback = function(state)
		if _G.CHATBOTHUB_LOADED then
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
		if _G.CHATBOTHUB_LOADED then
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

local ChatText = ""

local ChatLabel = ChatTab:AddParagraph("AI's answer","")

local CopyButton = ChatTab:AddButton{
	Name = "Copy the answer",
	Description = "Click to copy the full answer",
	Callback = function() 
		OrionLib:MakeNotification{
			Name = "ChatBot response",
			Content = "ChatBot response copied to clipboard",
			Time = 3,
			Image = "rbxassetid://10337369764"
		}
		setclipboard(ChatText) 
	end
}

updateChat = function(message)
	ChatText = message
	ChatLabel:Set(message)
end

local getHistory = function(player) return "" end
local addMessageHistory = function(player, message, response) return end

ChatTab:AddTextbox{
	Name = "Message",
	Default = "",
	TextDisappear = true,
	Callback = function(message)
		local messageDecoded = HttpService:UrlEncode(message)
		local history = HttpService:UrlEncode(getHistory(LocalPlayer))
		local userDisplayURI = HttpService:UrlEncode(LocalPlayer.DisplayName)
		local Character = HttpService:UrlEncode(_G.CHATBOTHUB_Character)
		local model = HttpService:UrlEncode(_G.CHATBOTHUB_AI_MODEL)
		local custom = "no"
		local shownText = ""

		if _G.CHATBOTHUB_PREMIUM and _G.CHATBOTHUB_CUSTOMPROMPT then
			Character = HttpService:UrlEncode(_G.CHATBOTHUB_CUSTOMPROMPTTEXT)
			custom = "yes"
		end
		local response = game:HttpGet("https://guerric.pythonanywhere.com/chat?msg="..messageDecoded.."&user="..userDisplayURI.."&key=" .. _G.CHATBOTHUB_KEY .. "&history=" .. history .. "&ai=" .. Character .. "&uid=" .. LocalPlayer.UserId .. "&custom=" .. custom .. "&model=" .. model .. "&lang=" .. _G.CHATBOTHUB_LANGUAGE .. "&long=yes&tta=no")
		if responseText == "" then return end
		addMessageHistory(LocalPlayer, message, response)

		_G.CHATBOTHUB_CREDITS -= AiCost[_G.CHATBOTHUB_AI_MODEL]
		OrionLib:MakeNotification{
		 Name = tostring(AiCost[_G.CHATBOTHUB_AI_MODEL]) .. " points used",
		 Content = tostring(_G.CHATBOTHUB_CREDITS) .. " points left",
		 Time = 1
		 }
		 CreditLabel:Set(_G.CHATBOTHUB_CREDITS)
		
		updateChat(response)
	end
}

MoreTab:AddTextbox{
	Name = "Key",
	Default = "",
	TextDisappear = true,
	Callback = function(key) 
		if _G.CHATBOTHUB_LOADED then
			login(key)
		end
	end
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

MoreTab:AddButton{
	Name = "Chat bypass by Guerric",
	Description = "Click to execute the script",
	Callback = function() 
		OrionLib:MakeNotification{
			Name = "Chat bypass by Guerric",
			Content = "Chat bypass script launched",
			Time = 3,
			Image = "rbxassetid://7115671043"
		}
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Guerric9018/chat_bypass/main/main.lua"))()
	end
}

HelpTab:AddParagraph("Help",
	"<b>\nIf you encounter issues. Please check the following:</b>\n\n" ..
		"<font color=\"rgb(255, 0, 0)\"><b>• Have you logged in?</b></font> Have you put your key in the 'more' tab? If not, go get your key on Discord then come back.\n" ..
		"<font color=\"rgb(255, 0, 0)\"><b>• Have you set 'Running' on in the main tab?</b></font>\n" ..
		"<font color=\"rgb(255, 0, 0)\"><b>• Do you have enough points to generate responses?</b></font>\n\n" ..
		"<b>If nothing works please ask your question in the Discord server.</b>")

OrionLib:Init()

-- Sends a message
local function main(message, userDisplay, uid, history)
	local messageDecoded = HttpService:UrlEncode(message)
    userDisplayURI = HttpService:UrlEncode(userDisplay:gsub("%d+", ""))
	history = HttpService:UrlEncode(history)
    local Character = HttpService:UrlEncode(_G.CHATBOTHUB_Character)
	local model = HttpService:UrlEncode(_G.CHATBOTHUB_AI_MODEL)
	local custom = "no"
	if _G.CHATBOTHUB_PREMIUM and _G.CHATBOTHUB_CUSTOMPROMPT then
		Character = HttpService:UrlEncode(_G.CHATBOTHUB_CUSTOMPROMPTTEXT)
		custom = "yes"
	end
    local response = game:HttpGet("https://guerric.pythonanywhere.com/chat?msg="..messageDecoded.."&user="..userDisplayURI.. "&key=" .. _G.CHATBOTHUB_KEY .. "&history=" .. history .. "&ai=" .. Character .. "&uid=" .. uid .. "&custom=" .. custom .. "&model=" .. model .. "&lang=" .. _G.CHATBOTHUB_LANGUAGE .. "&long=no&tta=no")
    local data = response
    
	if _G.CHATBOTHUB_CHAT_BYPASS then data = translate(data) end
			
	if _G.CHATBOTHUB_TTA then
		ttaResponse = game:HttpGet("https://guerric.pythonanywhere.com/chat?msg="..messageDecoded.."&user="..userDisplayURI.."&key=" .. _G.CHATBOTHUB_KEY .. "&history=" .. history .. "&ai=" .. Character .. "&uid=" .. uid .. "&custom=" .. custom .. "&model=" .. model .. "&lang=" .. _G.CHATBOTHUB_LANGUAGE .. "&long=no&tta=yes")
		checkCommand(ttaResponse)
	end

    local responseText = data:gsub("i love you", "ily"):gsub("wtf", "wt$"):gsub("zex", "zesty"):gsub("\n", " "):gsub("I love you", "ily"):gsub("I don't know what you're saying. Please teach me.", "I do not understand, try saying it without emojis and/or special characters.")
    if responseText == "" then return end
	addMessageHistory(LocalPlayer, message, responseText)
   wait()
   local offset = 0
   if _G.CHATBOTHUB_BOTFORMAT then
	offset = 12 + #userDisplay
   end
   local chunkSize = 195 - offset
   local numChunks = math.ceil(#responseText / chunkSize)

   local mult = 1

   if _G.CHATBOTHUB_TTA then
		mult = 1.5
   end

   _G.CHATBOTHUB_CREDITS -= AiCost[_G.CHATBOTHUB_AI_MODEL]*mult
   OrionLib:MakeNotification{
    Name = tostring(math.floor(AiCost[_G.CHATBOTHUB_AI_MODEL]*mult)) .. " points used",
    Content = tostring(_G.CHATBOTHUB_CREDITS) .. " points left",
    Time = 1
    }
    CreditLabel:Set(_G.CHATBOTHUB_CREDITS)

    for i = 1, numChunks do
        local startIndex = (i - 1) * chunkSize + 1
        local endIndex = math.min(i * chunkSize, #responseText)
		local intro = ""
        local chunk = string.sub(responseText, startIndex, endIndex)
		if _G.CHATBOTHUB_BOTFORMAT then
        	local intro = "[ChatBot]: "
		end
        local chunkProgress = " "..i.."/"..numChunks
        if numChunks == 1 then 
            chunkProgress = ""
        end
        if _G.CHATBOTHUB_BOTFORMAT and i == 1 then 
            intro = "[ChatBot]: "..userDisplay.. ", "
        end

		addRequestToList(intro .. chunk .. chunkProgress)

		if not _G.CHATBOTHUB_DELAYED_CHAT then
        	msg(intro .. chunk .. chunkProgress)
		end

        wait(0.1)
    end

end

local Players = game:GetService("Players")

-- Buffer system

local playerBuffers = {}


local function startBufferTimer(player)
	print(playerBuffers)
	print(table.concat(playerBuffers[player].buffer, " "))
    wait(3)
    if playerBuffers[player] then
        main(table.concat(playerBuffers[player].buffer, " "), player.DisplayName, LocalPlayer.UserId, getHistory(player))
        playerBuffers[player].buffer = {}
        playerBuffers[player].timerStarted = false
    end
end

-- Auto spam detection system
local playerMessageTimestamps = {}

local MESSAGE_LIMIT = 7
local TIME_FRAME = 10

local function isSpamming(player)
    local timestamps = playerMessageTimestamps[player]
    local currentTime = tick()
    
    while #timestamps > 0 and currentTime - timestamps[1] > TIME_FRAME do
        table.remove(timestamps, 1)
    end

    return #timestamps >= MESSAGE_LIMIT
end

local function onPlayerChatted(player)
    if not playerMessageTimestamps[player] then
        playerMessageTimestamps[player] = {}
    end
    
    table.insert(playerMessageTimestamps[player], tick())
    
    if isSpamming(player) then
        print(player.Name .. " (" .. player.DisplayName .. ") is spamming and has been blacklisted!")
        addPlayer(player.Name)
    end
end

-- Messages history handled locally. It is recommended NOT TO increase MESSAGE_HISTORY_LIMIT
local playerMessageHistory = {}
local MESSAGE_HISTORY_LIMIT = 4

addMessageHistory = function(player, message, response)
	if not playerMessageHistory[player] then
        playerMessageHistory[player] = {}
    end

	local history = playerMessageHistory[player]
    
	message = string.sub(message, 1, 100)
	response = string.sub(response, 1, 100)

    table.insert(history, "Previous user message: " .. message)
	table.insert(history, "Previous AI assistant message: " .. response)
    
    if #history > MESSAGE_HISTORY_LIMIT then
        table.remove(history, 1)
    end
	if #history > MESSAGE_HISTORY_LIMIT then
        table.remove(history, 1)
    end
end
    
resetHistory = function()
	for _, player in ipairs(Players:GetPlayers()) do
		playerMessageHistory[player] = {}
	end
end

getHistory = function(player)
	if not playerMessageHistory[player] then
        playerMessageHistory[player] = {}
    end
	return table.concat(playerMessageHistory[player], " --> ")
end

local function initializePlayer(player)
    playerBuffers[player] = {buffer = {}, timerStarted = false}
	playerMessageTimestamps[player] = {}
	playerMessageHistory[player] = {}
end

for _, player in ipairs(Players:GetPlayers()) do
    initializePlayer(player)
end

Players.PlayerAdded:Connect(function(player)
    initializePlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
    playerBuffers[player] = nil
	playerMessageTimestamps[player] = nil
	playerMessageHistory[player] = nil
end)


if not alreadyRan then
	Players.PlayerChatted:Connect(function(type, plr, message)
		if _G.CHATBOTHUB_CUSTOMPROMPT and (not _G.CHATBOTHUB_PREMIUM) then resetTogglePrem() end
		if not _G.CHATBOTHUB_LOGIN then return end
		if (_G.CHATBOTHUB_BLACKLISTED[plr.Name] and not _G.CHATBOTHUB_WHITELIST) or (_G.CHATBOTHUB_WHITELIST and not _G.CHATBOTHUB_BLACKLISTED[plr.Name]) then return end
		if _G.CHATBOTHUB_CREDITS == 0 then 
			CreditLabel:Set(0)
			OrionLib:MakeNotification{
				Name = "Alert",
				Content = "No points left on your account! If you think this is an error, please login again.",
				Time = 3,
				Image = "rbxassetid://14895395597"
			}
			return
		end
		if #message <= 1 then return end
		if _G.CHATBOTHUB_ON and ((LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).magnitude <= _G.CHATBOTHUB_MaxDistance) then
			if plr.Name ~= LocalPlayer.Name and string.sub(message, 1, 1) ~= "#" then
				onPlayerChatted(plr)
				if _G.CHATBOTHUB_BUFFER then
					table.insert(playerBuffers[plr].buffer, message)
        			if not playerBuffers[plr].timerStarted then
            			playerBuffers[plr].timerStarted = true
            			coroutine.wrap(function() startBufferTimer(plr) end)()
        			end
					return
				end
				main(message, plr.DisplayName, LocalPlayer.UserId, getHistory(plr))
			end
		end
	end)
end

-- Toggle GUI button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 70, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 1, -160)
ToggleButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Text = "Toggle ChatbotHub"
ToggleButton.Parent = GUI
ToggleButton.TextWrapped = true
ToggleButton.Font = Enum.Font.Code
local ToggleButtonCornerFrame = Instance.new("UICorner")
ToggleButtonCornerFrame.CornerRadius = UDim.new(0.2, 0)
ToggleButtonCornerFrame.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    OrionLib:Switch()
end)

_G.CHATBOTHUB_LOADED = true

-- Auto login
if writeFileAvailable() then
	if readfile("chatbothub_key.cb") ~= nil then
		login(readfile("chatbothub_key.cb"))
	end
end

-- Anti chat logger (not for Celery)

if string.sub(identifyexecutor(), 1, 6) ~= "Celery" then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/AnthonyIsntHere/anthonysrepository/main/scripts/AntiChatLogger.lua", true))()
else
	print("Celery detected, no anti-chat logger. Use with caution!")
end