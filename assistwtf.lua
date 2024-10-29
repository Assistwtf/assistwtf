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

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- ESP Section
local espEnabled = false
local espConnections = {}

local function rainbowColor()
    local time = tick() * 3
    return Color3.new(math.sin(time), math.sin(time + 2), math.sin(time + 4))
end

local function createESP(player)
    if not player.Character then return end -- Ensure character exists
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.new(128, 128, 128) -- Gray fill color
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

local function toggleESP(enabled)
    espEnabled = enabled
    if espEnabled then
        -- Enable ESP for all current players
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESP(player)
            end
        end

        -- Update ESP for newly joined players only if ESP is enabled
        espConnections[#espConnections + 1] = Players.PlayerAdded:Connect(function(player)
            if espEnabled then
                player.CharacterAdded:Wait() -- Wait for character to load
                createESP(player)
            end
        end)
    else
        -- Disconnect and destroy ESP for all players
        for _, connection in ipairs(espConnections) do
            connection:Disconnect()
        end
        espConnections = {}

        -- Clear existing highlights
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
    Notification:Notify("info", enabled and "ESP Enabled!" or "ESP Disabled!")
end

-- Non-Blatant Section
local AimSection = NonBlatantTab:AddSection("Aim", "left")
AimSection:AddToggle("Silent Aim", false, function(val)
    if val then
        Notification:Notify("info", "Success!", "Silent aim has been enabled!")
        -- Silent aim logic here
    else
        Notification:Notify("info", "Disabled", "Silent aim has been disabled!")
        -- Disable silent aim logic here
    end
end)

-- Visuals Section (for ESP)
local VisualsSection = NonBlatantTab:AddSection("Visuals", "right")
VisualsSection:AddToggle("Toggle ESP", false, function(val)
    toggleESP(val)
end)

-- Add additional Non-Blatant features here
-- Example:
local MiscSection = NonBlatantTab:AddSection("Misc", "right")
MiscSection:AddToggle("No Recoil", false, function(val)
    if val then
        Notification:Notify("info", "No Recoil Enabled", "Recoil has been disabled.")
        -- No Recoil logic here
    else
        Notification:Notify("info", "No Recoil Disabled", "Recoil has been re-enabled.")
        -- Re-enable recoil logic here
    end
end)

-- Blatant Section (Bannable features)
local BannableSection = BlatantTab:AddSection("Bannable", "left")

-- Autokill Toggle
BannableSection:AddToggle("Autokill", false, function(val)
    if val then
        Notification:Notify("warning", "Be careful!", "Autokill is enabled. This can get you banned!")
        -- Autokill logic here
    else
        Notification:Notify("info", "Autokill Disabled", "Autokill has been disabled.")
        -- Disable autokill logic here
    end
end)

-- Aimbot Toggle with Lock-On Logic
local aimbotEnabled = false
local aimbotConnection

local function getClosestEnemy()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("Head") then
            local headPosition = player.Character.Head.Position
            local screenPoint, onScreen = Camera:WorldToViewportPoint(headPosition)

            if onScreen then
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end

    return closestPlayer
end

BannableSection:AddToggle("Aimbot", false, function(val)
    aimbotEnabled = val
    if aimbotEnabled then
        Notification:Notify("warning", "Be careful!", "Aimbot is enabled. This can get you banned!")
        aimbotConnection = RunService.RenderStepped:Connect(function()
            local closestEnemy = getClosestEnemy()
            if closestEnemy and closestEnemy.Character and closestEnemy.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestEnemy.Character.Head.Position)
            end
        end)
    else
        Notification:Notify("info", "Aimbot Disabled", "Aimbot has been disabled.")
        if aimbotConnection then
            aimbotConnection:Disconnect()
            aimbotConnection = nil
        end
    end
end)

-- Rejoin Button
BannableSection:AddButton("Rejoin", function()
    local placeId = game.PlaceId
    local jobId = game.JobId
    TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    print("Attempting to rejoin the current game...")
end)

