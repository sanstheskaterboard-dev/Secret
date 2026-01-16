--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
--deobufscated sync hoooooooya
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = 'Rivals mobile script by Nagi',
    LoadingTitle = 'Loading Nagi hub...',
    LoadingSubtitle = '',
    ConfigurationSaving = {
        Enabled = true,
        FolderName = 'SpectrX_Hub',
        FileName = 'Config',
    },
    Discord = {Enabled = false},
    KeySystem = false,
})

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local CoreGui = game:GetService('CoreGui')

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local MainTab = Window:CreateTab('Main')

MainTab:CreateSection('Aimlock Settings')

local AimlockEnabled = false
local TeamCheck = true
local WallCheck = false
local AimPart = 'HumanoidRootPart'

local function IsVisible(targetPart)
    if not WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 1000
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result and result.Instance:IsDescendantOf(targetPart.Parent) or false
end

local function GetClosestEnemy()
    local closestDist = math.huge
    local closestPlayer = nil
    local localPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart').Position
    if not localPos then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
            local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
            if humanoid and humanoid.Health > 0 then
                if not TeamCheck or player.Team ~= LocalPlayer.Team then
                    local targetPart = player.Character:FindFirstChild(AimPart)
                    if targetPart then
                        local dist = (targetPart.Position - localPos).Magnitude
                        if dist < closestDist and IsVisible(targetPart) then
                            closestDist = dist
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

MainTab:CreateToggle({
    Name = 'Auto Aimlock',
    CurrentValue = false,
    Flag = 'AimlockToggle',
    Callback = function(value)
        AimlockEnabled = value
    end,
})

RunService.RenderStepped:Connect(function()
    if AimlockEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') then
        local target = GetClosestEnemy()
        if target then
            local targetPart = target.Character:FindFirstChild(AimPart)
            if targetPart then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            end
        end
    end
end)

MainTab:CreateToggle({
    Name = 'Team Check',
    CurrentValue = true,
    Flag = 'TeamCheckToggle',
    Callback = function(value)
        TeamCheck = value
    end,
})

MainTab:CreateToggle({
    Name = 'Wall Check',
    CurrentValue = false,
    Flag = 'WallCheckToggle',
    Callback = function(value)
        WallCheck = value
    end,
})

MainTab:CreateDropdown({
    Name = 'Aim Part',
    Options = {'Head', 'HumanoidRootPart', 'Torso'},
    CurrentOption = 'HumanoidRootPart',
    Flag = 'AimPartDropdown',
    Callback = function(option)
        AimPart = option
    end,
})

MainTab:CreateSection('Trigger Bot')

local TriggerBotEnabled = false
local lastTrigger = 0
local triggerDelay = 0.1

MainTab:CreateToggle({
    Name = 'Trigger Bot',
    CurrentValue = false,
    Flag = 'TriggerBotToggle',
    Callback = function(value)
        TriggerBotEnabled = value
    end,
})

RunService.RenderStepped:Connect(function()
    if TriggerBotEnabled and tick() - lastTrigger > triggerDelay then
        local target = Mouse.Target
        if target and target.Parent then
            local character = target.Parent
            local player = Players:GetPlayerFromCharacter(character)
            if player and player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
                local humanoid = character:FindFirstChildOfClass('Humanoid')
                if humanoid and humanoid.Health > 0 then
                    mouse1click()
                    lastTrigger = tick()
                end
            end
        end
    end
end)

local VisualsTab = Window:CreateTab('Visuals')

VisualsTab:CreateSection('ESP Settings')

local PlayerESPEnabled = false
local ShowDistance = true
local TeamColorESP = true
local ESPHighlights = {}
local ESPBillboards = {}

local function CreateESP(player)
    if player == LocalPlayer or not player.Character then return end

    local highlight = Instance.new('Highlight')
    highlight.Name = 'RGB_ESP_Highlight'
    highlight.FillTransparency = 0.9
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Parent = player.Character
    ESPHighlights[player] = highlight

    local billboard = Instance.new('BillboardGui')
    billboard.Name = 'RGB_ESP_Distance'
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.MaxDistance = 500
    billboard.Parent = player.Character
    ESPBillboards[player] = billboard

    local textLabel = Instance.new('TextLabel')
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = player.Name
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard
end

local function DestroyESP(player)
    if ESPHighlights[player] then
        ESPHighlights[player]:Destroy()
        ESPHighlights[player] = nil
    end
    if ESPBillboards[player] then
        ESPBillboards[player]:Destroy()
        ESPBillboards[player] = nil
    end
end

local function UpdateESP()
    for player, highlight in pairs(ESPHighlights) do
        if player.Character and player.Character:FindFirstChild('HumanoidRootPart') and player.Character:FindFirstChildOfClass('Humanoid') then
            local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
            if humanoid.Health <= 0 then
                highlight.Enabled = false
                if ESPBillboards[player] then ESPBillboards[player].Enabled = false end
            else
                highlight.Enabled = true
                if ESPBillboards[player] then ESPBillboards[player].Enabled = true end
            end
        end
    end
end

VisualsTab:CreateToggle({
    Name = 'Player ESP',
    CurrentValue = false,
    Flag = 'PlayerESPToggle',
    Callback = function(value)
        PlayerESPEnabled = value
        if value then
            for _, player in pairs(Players:GetPlayers()) do
                CreateESP(player)
            end
            Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(character)
                    CreateESP(player)
                end)
            end)
        else
            for player in pairs(ESPHighlights) do
                DestroyESP(player)
            end
        end
    end,
})

VisualsTab:CreateToggle({
    Name = 'Show Distance',
    CurrentValue = true,
    Flag = 'DistanceToggle',
    Callback = function(value)
        ShowDistance = value
    end,
})

VisualsTab:CreateToggle({
    Name = 'Team Color ESP',
    CurrentValue = true,
    Flag = 'TeamColorToggle',
    Callback = function(value)
        TeamColorESP = value
    end,
})

RunService.Heartbeat:Connect(function()
    if not PlayerESPEnabled then return end
    UpdateESP()
    local hue = (tick() * 0.8) % 1
    local rainbowColor = Color3.fromHSV(hue, 0.8, 1)
    local outlineColor = Color3.fromHSV(hue, 0.9, 0.8)

    for player, highlight in pairs(ESPHighlights) do
        if player.Character and player.Character:FindFirstChild('HumanoidRootPart') and player.Character:FindFirstChildOfClass('Humanoid') then
            local localChar = LocalPlayer.Character
            if localChar and localChar:FindFirstChild('HumanoidRootPart') then
                local dist = (player.Character.HumanoidRootPart.Position - localChar.HumanoidRootPart.Position).Magnitude
                local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
                if humanoid.Health > 0 then
                    if TeamColorESP and player.Team then
                        highlight.FillColor = player.TeamColor.Color
                    else
                        highlight.FillColor = rainbowColor
                    end
                    highlight.OutlineColor = outlineColor

                    local billboard = ESPBillboards[player]
                    if billboard then
                        local textLabel = billboard:FindFirstChildOfClass('TextLabel')
                        if textLabel then
                            if ShowDistance then
                                textLabel.Text = player.Name .. "\n" .. math.floor(dist) .. " studs"
                            else
                                textLabel.Text = player.Name
                            end
                        end
                    end
                end
            end
        end
    end
end)

VisualsTab:CreateSection('Hitbox')

local HitboxEnabled = false
local HitboxAdornments = {}

local function CreateHitbox(player)
    if player == LocalPlayer or not player.Character then return end
    for _, part in ipairs(player.Character:GetChildren()) do
        if part:IsA('BasePart') and part.Name ~= 'Head' then
            local box = Instance.new('BoxHandleAdornment')
            box.Adornee = part
            box.AlwaysOnTop = true
            box.ZIndex = 10
            box.Size = part.Size * 1.5
            box.Transparency = 0.7
            box.Color3 = Color3.fromRGB(170, 0, 255)
            box.Parent = part
            if not HitboxAdornments[player] then HitboxAdornments[player] = {} end
            table.insert(HitboxAdornments[player], box)
        end
    end
end

local function DestroyHitbox(player)
    if HitboxAdornments[player] then
        for _, adorn in ipairs(HitboxAdornments[player]) do
            adorn:Destroy()
        end
        HitboxAdornments[player] = nil
    end
end

VisualsTab:CreateToggle({
    Name = 'Hitbox Expander',
    CurrentValue = false,
    Flag = 'HitboxToggle',
    Callback = function(value)
        HitboxEnabled = value
        if value then
            for _, player in ipairs(Players:GetPlayers()) do
                CreateHitbox(player)
            end
            Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function()
                    CreateHitbox(player)
                end)
            end)
        else
            for player in pairs(HitboxAdornments) do
                DestroyHitbox(player)
            end
        end
    end,
})

VisualsTab:CreateSection('Skin Changer')

local function ApplySkin(weaponName, skinName)
    if skinName == 'Default' then
        Rayfield:Notify({
            Title = 'Skin Changer',
            Content = 'Default skin selected, no change applied.',
            Duration = 3,
        })
        return
    end
    local viewModels = LocalPlayer.PlayerScripts.Assets.ViewModels
    local weaponFolder = viewModels:FindFirstChild(weaponName)
    local skinFolder = viewModels:FindFirstChild(skinName)
    if weaponFolder and skinFolder then
        weaponFolder:ClearAllChildren()
        for _, child in pairs(skinFolder:GetChildren()) do
            child:Clone().Parent = weaponFolder
        end
        Rayfield:Notify({
            Title = 'Skin Changer',
            Content = 'Applied ' .. skinName .. ' to ' .. weaponName,
            Duration = 3,
        })
    end
end

VisualsTab:CreateDropdown({
    Name = 'Grenade Launcher Skin',
    Options = {'Default', 'Swashbuckler', 'Uranium Launcher'},
    CurrentOption = 'Default',
    Flag = 'Grenade LauncherSkinDropdown',
    Callback = function(option)
        ApplySkin('Grenade Launcher', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Assault Rifle Skin',
    Options = {'Default', 'AK-47', 'AUG'},
    CurrentOption = 'Default',
    Flag = 'Assault RifleSkinDropdown',
    Callback = function(option)
        ApplySkin('Assault Rifle', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Exogun Skin',
    Options = {'Default', 'Singularity', 'Wondergun'},
    CurrentOption = 'Default',
    Flag = 'ExogunSkinDropdown',
    Callback = function(option)
        ApplySkin('Exogun', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Subspace Tripmine Skin',
    Options = {'Default', "Don't Press", 'Spring'},
    CurrentOption = 'Default',
    Flag = 'Subspace TripmineSkinDropdown',
    Callback = function(option)
        ApplySkin('Subspace Tripmine', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Knife Skin',
    Options = {'Default', 'Karambit', 'Chancla'},
    CurrentOption = 'Default',
    Flag = 'KnifeSkinDropdown',
    Callback = function(option)
        ApplySkin('Knife', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Chainsaw Skin',
    Options = {'Default', 'Blobsaw', 'Handsaws'},
    CurrentOption = 'Default',
    Flag = 'ChainsawSkinDropdown',
    Callback = function(option)
        ApplySkin('Chainsaw', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Bow Skin',
    Options = {'Default', 'Compound Bow', 'Raven Bow'},
    CurrentOption = 'Default',
    Flag = 'BowSkinDropdown',
    Callback = function(option)
        ApplySkin('Bow', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Grenade Skin',
    Options = {'Default', 'Water Balloon', 'Whoopee Cushion'},
    CurrentOption = 'Default',
    Flag = 'GrenadeSkinDropdown',
    Callback = function(option)
        ApplySkin('Grenade', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Fists Skin',
    Options = {'Default', 'Boxing Gloves', 'Brass Knuckles'},
    CurrentOption = 'Default',
    Flag = 'FistsSkinDropdown',
    Callback = function(option)
        ApplySkin('Fists', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Handgun Skin',
    Options = {'Default', 'Blaster'},
    CurrentOption = 'Default',
    Flag = 'HandgunSkinDropdown',
    Callback = function(option)
        ApplySkin('Handgun', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'RPG Skin',
    Options = {'Default', 'Nuke Launcher', 'RPKEY', 'Spaceship Launcher'},
    CurrentOption = 'Default',
    Flag = 'RPGSkinDropdown',
    Callback = function(option)
        ApplySkin('RPG', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Katana Skin',
    Options = {'Default', 'Lightning Bolt', 'Saber'},
    CurrentOption = 'Default',
    Flag = 'KatanaSkinDropdown',
    Callback = function(option)
        ApplySkin('Katana', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Sniper Skin',
    Options = {'Default', 'Pixel Sniper', 'Hyper Sniper'},
    CurrentOption = 'Default',
    Flag = 'SniperSkinDropdown',
    Callback = function(option)
        ApplySkin('Sniper', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Revolver Skin',
    Options = {'Default', 'Sheriff'},
    CurrentOption = 'Default',
    Flag = 'RevolverSkinDropdown',
    Callback = function(option)
        ApplySkin('Revolver', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Uzi Skin',
    Options = {'Default', 'Electro Uzi', 'Water Uzi'},
    CurrentOption = 'Default',
    Flag = 'UziSkinDropdown',
    Callback = function(option)
        ApplySkin('Uzi', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Slingshot Skin',
    Options = {'Default', 'Goalpost', 'Stick'},
    CurrentOption = 'Default',
    Flag = 'SlingshotSkinDropdown',
    Callback = function(option)
        ApplySkin('Slingshot', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Paintball Gun Skin',
    Options = {'Default', 'Boba Gun', 'Slime Gun'},
    CurrentOption = 'Default',
    Flag = 'Paintball GunSkinDropdown',
    Callback = function(option)
        ApplySkin('Paintball Gun', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Minigun Skin',
    Options = {'Default', 'Lasergun 3000', 'Pixel Minigun'},
    CurrentOption = 'Default',
    Flag = 'MinigunSkinDropdown',
    Callback = function(option)
        ApplySkin('Minigun', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Flare Gun Skin',
    Options = {'Default', 'Dynamite Gun', 'Firework Gun'},
    CurrentOption = 'Default',
    Flag = 'Flare GunSkinDropdown',
    Callback = function(option)
        ApplySkin('Flare Gun', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Freeze Ray Skin',
    Options = {'Default', 'Bubble Ray', 'Temporal Ray'},
    CurrentOption = 'Default',
    Flag = 'Freeze RaySkinDropdown',
    Callback = function(option)
        ApplySkin('Freeze Ray', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Flamethrower Skin',
    Options = {'Default', 'Lamethrower', 'Pixel Flamethrower'},
    CurrentOption = 'Default',
    Flag = 'FlamethrowerSkinDropdown',
    Callback = function(option)
        ApplySkin('Flamethrower', option)
    end,
})

VisualsTab:CreateDropdown({
    Name = 'Burst Rifle Skin',
    Options = {'Default', 'Aqua Burst', 'Electro Rifle'},
    CurrentOption = 'Default',
    Flag = 'Burst RifleSkinDropdown',
    Callback = function(option)
        ApplySkin('Burst Rifle', option)
    end,
})

VisualsTab:CreateButton({
    Name = 'Apply Default Skins (AK-47 + Handsaws)',
    Callback = function()
        ApplySkin('Assault Rifle', 'AK-47')
        ApplySkin('Chainsaw', 'Handsaws')
        Rayfield:Notify({
            Title = 'Skin Changer',
            Content = 'Default skins applied!',
            Duration = 3,
        })
    end,
})

local InfoTab = Window:CreateTab('Info')

local Label = InfoTab:CreateLabel("Script made by Nagi. ", 4483362458, Color3.fromRGB(255, 255, 255), false) -- Title, Icon, Color, IgnoreTheme
