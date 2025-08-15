-- Espera o jogo carregar completamente
repeat wait() until game:IsLoaded() and game:GetService("CoreGui") and game.Players.LocalPlayer.Character
local LocalPlayer = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Carregar Rayfield
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
end)

if not success then
    warn("Não foi possível carregar Rayfield. Verifique a internet ou URL.")
    return
end

-- Criar janela principal estilo cheats PC
local Window = Rayfield:CreateWindow({
    Name = "99 Noites na Floresta | Menu Chique",
    LoadingTitle = "Carregando Menu...",
    LoadingSubtitle = "Feito por Ewerton",
    ConfigurationSaving = {Enabled = true, FolderName = "99NoitesMenu", FileName = "Config"},
    KeySystem = false,
    Theme = {
        Accent = Color3.fromRGB(255, 0, 128), -- cor de destaque
        Background = Color3.fromRGB(20,20,20), -- fundo escuro
        TextColor = Color3.fromRGB(255,255,255),
        ToggleColor = Color3.fromRGB(0,255,128)
    }
})

-- Teste rápido para garantir menu
local TestTab = Window:CreateTab("Teste")
TestTab:CreateButton({
    Name = "Clique Aqui",
    Callback = function()
        print("Menu funcionando!")
    end
})

-- Variáveis de toggles e sliders
local Toggles = {
    AutoCollect = false,
    ESP = false,
    Fly = false,
    Aimbot = false,
    AutoCraft = false,
    AutoEat = false
}

local FlySpeed = 50
local FlyControl = {Forward=0, Backward=0, Left=0, Right=0, Up=0, Down=0}

------------------------
-- ABA COLETA
------------------------
local ColetaTab = Window:CreateTab("Coleta")
ColetaTab:CreateToggle({
    Name = "Auto-Collect Itens",
    CurrentValue = false,
    Callback = function(Value)
        Toggles.AutoCollect = Value
        spawn(function()
            while Toggles.AutoCollect do
                wait(0.5)
                for _, item in pairs(workspace:GetChildren()) do
                    if item:IsA("Part") and string.find(item.Name, "Item") then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            item.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                        end
                    end
                end
            end
        end)
    end
})

ColetaTab:CreateToggle({
    Name = "Auto Craft",
    CurrentValue = false,
    Callback = function(Value)
        Toggles.AutoCraft = Value
        spawn(function()
            while Toggles.AutoCraft do
                wait(1)
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    local woodCount = 0
                    for _, item in pairs(backpack:GetChildren()) do
                        if item.Name == "Wood" then
                            woodCount = woodCount + 1
                        end
                    end
                    if woodCount >= 5 then
                        local craftEvent = ReplicatedStorage:FindFirstChild("CraftEvent")
                        if craftEvent then
                            craftEvent:FireServer("Plank")
                        end
                    end
                end
            end
        end)
    end
})

ColetaTab:CreateToggle({
    Name = "Auto Eat",
    CurrentValue = false,
    Callback = function(Value)
        Toggles.AutoEat = Value
        spawn(function()
            while Toggles.AutoEat do
                wait(1)
                local hunger = LocalPlayer:FindFirstChild("Hunger") -- Ajuste conforme o jogo
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if hunger and hunger.Value < 50 and backpack then
                    for _, item in pairs(backpack:GetChildren()) do
                        if item.Name == "Apple" then
                            local eatEvent = ReplicatedStorage:FindFirstChild("EatEvent")
                            if eatEvent then
                                eatEvent:FireServer(item)
                            end
                            break
                        end
                    end
                end
            end
        end)
    end
})

------------------------
-- ABA COMBAT / AIM
------------------------
local CombatTab = Window:CreateTab("Combat")
CombatTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(Value)
        Toggles.Aimbot = Value
        spawn(function()
            while Toggles.Aimbot do
                wait()
                local closest
                local dist = math.huge
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                        local magnitude = (player.Character.Head.Position - Camera.CFrame.Position).Magnitude
                        if magnitude < dist then
                            dist = magnitude
                            closest = player
                        end
                    end
                end
                if closest and closest.Character and closest.Character:FindFirstChild("Head") then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position)
                end
            end
        end)
    end
})

------------------------
-- ABA MOVIMENTO
------------------------
local MoveTab = Window:CreateTab("Movimento")
MoveTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(Value)
        Toggles.Fly = Value
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            if Toggles.Fly then
                hrp.Anchored = true
                spawn(function()
                    while Toggles.Fly do
                        wait()
                        local moveVector = Vector3.new(
                            FlyControl.Right - FlyControl.Left,
                            FlyControl.Up - FlyControl.Down,
                            FlyControl.Backward - FlyControl.Forward
                        )
                        hrp.CFrame = hrp.CFrame + moveVector * FlySpeed * RunService.Heartbeat:Wait()
                    end
                    hrp.Anchored = false
                end)
            end
        end
    end
})

MoveTab:CreateSlider({
    Name = "Fly Speed",
    CurrentValue = FlySpeed,
    Min = 10,
    Max = 200,
    Increment = 5,
    Suffix = "Speed",
    Callback = function(Value)
        FlySpeed = Value
    end
})

------------------------
-- ABA OUTROS
------------------------
local OutrosTab = Window:CreateTab("Outros")
OutrosTab:CreateToggle({
    Name = "ESP Jogadores",
    CurrentValue = false,
    Callback = function(Value)
        Toggles.ESP = Value
        spawn(function()
            while Toggles.ESP do
                wait(1)
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                        if not player.Character:FindFirstChild("ESP") then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "ESP"
                            billboard.Adornee = player.Character.Head
                            billboard.Size = UDim2.new(0,50,0,50)
                            billboard.AlwaysOnTop = true
                            local text = Instance.new("TextLabel", billboard)
                            text.Text = player.Name
                            text.Size = UDim2.new(1,0,1,0)
                            text.BackgroundTransparency = 1
                            text.TextColor3 = Color3.fromRGB(255,0,0)
                            billboard.Parent = game.CoreGui
                        end
                    end
                end
            end
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("ESP") then
                    player.Character.ESP:Destroy()
                end
            end
        end)
    end
})