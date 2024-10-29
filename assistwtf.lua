-- Load the NEVERLOSE-UI-Nightly library
local NEVERLOSE = loadstring(game:HttpGet("https://raw.githubusercontent.com/alriceeeee/NEVERLOSE-UI-Nightly/main/source.lua"))()

-- Set the theme for the UI
NEVERLOSE:Theme("dark")

-- Create the main window
local Window = NEVERLOSE:AddWindow("Assist.wtf", "TEXT HERE")
local Notification = NEVERLOSE:Notification()
Notification.MaxNotifications = 6

-- Add a "Home" tab label
Window:AddTabLabel("Home")

-- Define tabs
local NonBlatantTab = Window:AddTab("Non-Blatant", "earth")
local BlatantTab = Window:AddTab("Blatant", "ads")

-- Non-Blatant Section (e.g., Aim features)
local AimSection = NonBlatantTab:AddSection("Aim", "left")

-- Silent Aim Toggle
AimSection:AddToggle("Silent Aim", false, function(val)
    if val then
        Notification:Notify("info", "Success!", "Silent aim has been enabled!")
        -- Enable silent aim logic here
    else
        Notification:Notify("info", "Disabled", "Silent aim has been disabled!")
        -- Disable silent aim logic here
    end
end)

-- Visuals Section
local VisualsSection = NonBlatantTab:AddSection("Visuals", "right")
VisualsSection:AddLabel("Highlight a user.")

-- ESP Toggle in Visuals Section
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local espEnabled = false
local espConnections = {}

-- Function to create rainbow color
local function rainbowColor()
    local time = tick() * 3
    return Color3.new(math.sin(time), math.sin(time + 2), math.sin(time + 4))
end

-- Function to create ESP outline
local function createESP(player)
    if not player.Character then return end -- Ensure character exists
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.new(128, 128, 128) -- Optional: set fill color (gray)
    highlight.OutlineColor = rainbowColor() -- Set outline color to rainbow
    highlight.OutlineTransparency = 0 -- Fully visible outline
    highlight.Parent = player.Character

    -- Update ESP outline when character spawns
    player.CharacterAdded:Connect(function(character)
        highlight.Parent = character
    end)

    -- Update rainbow color continuously
    local connection = RunService.RenderStepped:Connect(function()
        if espEnabled then
            highlight.OutlineColor = rainbowColor()
        else
            connection:Disconnect()
            highlight:Destroy()
        end
    end)

    table.insert(espConnections, connection)
end

-- Function to enable or disable ESP
local function toggleESP(enabled)
    espEnabled = enabled
    if espEnabled then
        -- Loop through players and create ESP for each
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESP(player)
            end
        end
        
        -- Update ESP for new players
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Wait() -- Wait for character to load
            createESP(player)
        end)
    else
        -- Disable ESP by disconnecting all connections and clearing highlights
        for _, connection in ipairs(espConnections) do
            connection:Disconnect()
        end
        espConnections = {}
        
        -- Destroy highlights of all players
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                for _, obj in ipairs(player.Character:GetChildren()) do
                    if obj:IsA("Highlight") then
                        obj:Destroy()
                    end
                end
            end
        end
    end
    Notification:Notify("info", enabled and "ESP Enabled!" or "ESP Disabled!") -- Notify user
end

-- Add ESP toggle to the UI
VisualsSection:AddToggle("Toggle ESP", false, function(val)
    toggleESP(val)
end)

-- Blatant Section (e.g., Bannable features)
local BannableSection = BlatantTab:AddSection("Bannable", "left")

-- Autokill Toggle
BannableSection:AddToggle("Autokill", false, function(val)
    if val then
        Notification:Notify("warning", "Be careful!", "Autokill is enabled. This can get you banned!")
        -- Enable autokill logic here
    else
        Notification:Notify("info", "Autokill Disabled", "Autokill has been disabled.")
        -- Disable autokill logic here
    end
end)

-- Aimbot Toggle
BannableSection:AddToggle("Aimbot", false, function(val)
    if val then
        Notification:Notify("warning", "Be careful!", "Aimbot is enabled. This can get you banned!")
        -- Enable aimbot logic here
    else
        Notification:Notify("info", "Aimbot Disabled", "Aimbot has been disabled.")
        -- Disable aimbot logic here
    end
end)

-- Rejoin Button
BannableSection:AddButton("Rejoin", function()
    local Players = game:GetService("Players")
    local TeleportService = game:GetService("TeleportService")

    local function rejoinGame()
        local player = Players.LocalPlayer
        local placeId = game.PlaceId
        local jobId = game.JobId

        TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
    end

    -- Call the function to rejoin immediately
    rejoinGame()
    print("Attempting to rejoin the current game...")
end)
