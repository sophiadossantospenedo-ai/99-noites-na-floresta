-- 99 Noites na Floresta - Menu Final Completo
repeat wait() until game:IsLoaded() and game.Players.LocalPlayer.Character
local LocalPlayer = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

-- ===============================
-- Criação da GUI Principal
-- ===============================
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NoitesMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Window = Instance.new("Frame")
Window.Size = UDim2.new(0, 450, 0, 350)
Window.Position = UDim2.new(0.5, -225, 0.5, -175)
Window.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Window.BorderSizePixel = 0
Window.Parent = ScreenGui
Window.Active = true
Window.Draggable = true

-- Título Principal
local Title = Instance.new("TextLabel")
Title.Text = "99 Noites na Floresta | Menu - Feito por Ewerton"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 0, 128)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Window

-- ===============================
-- Variáveis e funções auxiliares
-- ===============================
local TabButtons = {}
local Tabs = {}
local ActiveTab
local tabOffsetY = 40
local elementSpacing = 5
local Toggles = {AutoCollect=false, AutoCraft=false, AutoEat=false, Fly=false, Aimbot=false, ESP=false}
local FlySpeed = 50
local FlyControl = {Forward=0, Backward=0, Left=0, Right=0, Up=0, Down=0}
local ESPs = {}

-- Nomes de itens e eventos do jogo
local ITEM_WOOD = "Wood"
local ITEM_APPLE = "Apple"
local ITEM_PLANK = "Plank"
local EVENT_CRAFT = "CraftEvent"
local EVENT_EAT = "EatEvent"

-- Função de tween de cor
local function TweenColor(obj, newColor, time)
    local tweenInfo = TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(obj, tweenInfo, {BackgroundColor3 = newColor}):Play()
end

-- ===============================
-- Funções de criação GUI
-- ===============================
local function CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0, 100, 0, 30)
    TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.Text = name
    TabButton.Font = Enum.Font.SourceSansBold
    TabButton.Position = UDim2.new(0, (#TabButtons * 105 + 10), 0, tabOffsetY)
    TabButton.Parent = Window

    TabButton.MouseEnter:Connect(function() TweenColor(TabButton, Color3.fromRGB(50,0,128)) end)
    TabButton.MouseLeave:Connect(function() TweenColor(TabButton, Color3.fromRGB(30,30,30)) end)

    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1,-20,1,-tabOffsetY-15)
    TabFrame.Position = UDim2.new(0,10,0,tabOffsetY+35)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.Parent = Window

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1,0,0,20)
    Label.Position = UDim2.new(0,0,0,0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255,255,255)
    Label.TextScaled = true
    Label.Font = Enum.Font.SourceSansBold
    Label.Text = "Menu feito por Ewerton"
    Label.Parent = TabFrame

    TabButton.MouseButton1Click:Connect(function()
        for _,v in pairs(Tabs) do v.Frame.Visible = false end
        TabFrame.Visible = true
        ActiveTab = name
    end)

    table.insert(TabButtons, TabButton)
    table.insert(Tabs, {Name=name, Frame=TabFrame})
    return TabFrame
end

local function CreateToggle(parent, name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,200,0,30)
    btn.Position = UDim2.new(0,10,0,#parent:GetChildren()*(30+elementSpacing))
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSans
    btn.Text = name.." [OFF]"
    btn.Parent = parent

    local state = false

    btn.MouseEnter:Connect(function() TweenColor(btn, Color3.fromRGB(0,128,255)) end)
    btn.MouseLeave:Connect(function() TweenColor(btn, Color3.fromRGB(50,50,50)) end)

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name.." ["..(state and "ON" or "OFF").."]"
        pcall(function() callback(state) end)
    end)
    return btn
end

local function CreateSlider(parent, name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,200,0,40)
    frame.Position = UDim2.new(0,10,0,#parent:GetChildren()*(40+elementSpacing))
    frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0.5,0)
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.Font = Enum.Font.SourceSans
    label.Text = name..": "..default
    label.Parent = frame

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1,0,0.5,0)
    slider.Position = UDim2.new(0,0,0.5,0)
    slider.BackgroundColor3 = Color3.fromRGB(100,100,100)
    slider.Text = ""
    slider.Parent = frame

    local mouseDown = false
    slider.MouseButton1Down:Connect(function() mouseDown = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then mouseDown=false end
    end)

    RunService.RenderStepped:Connect(function()
        if mouseDown then
            local mousePos = UserInputService:GetMouseLocation()
            local x = math.clamp(mousePos.X - slider.AbsolutePosition.X,0,slider.AbsoluteSize.X)
            local value = math.floor((x/slider.AbsoluteSize.X)*(max-min)+min)
            label.Text = name..": "..value
            pcall(function() callback(value) end)
        end
    end)
end

-- ===============================
-- Criando Abas
-- ===============================
local ColetaTab = CreateTab("Coleta")
local CombatTab = CreateTab("Combate")
local MoveTab = CreateTab("Movimento")
local OutrosTab = CreateTab("Outros")

-- ===============================
-- Funções Coleta
-- ===============================
CreateToggle(ColetaTab,"Auto-Collect",function(v) Toggles.AutoCollect=v
    spawn(function()
        while Toggles.AutoCollect do wait(0.5)
            for _,item in pairs(workspace:GetChildren()) do
                if item:IsA("Part") and string.find(item.Name,"Item") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function() item.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame end)
                end
            end
        end
    end)
end)

CreateToggle(ColetaTab,"Auto Craft",function(v) Toggles.AutoCraft=v
    spawn(function()
        while Toggles.AutoCraft do wait(1)
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                local count = 0
                for _,i in pairs(backpack:GetChildren()) do if i.Name==ITEM_WOOD then count=count+1 end end
                if count>=5 then
                    local craft = ReplicatedStorage:FindFirstChild(EVENT_CRAFT)
                    if craft then pcall(function() craft:FireServer(ITEM_PLANK) end) end
                end
            end
        end
    end)
end)

CreateToggle(ColetaTab,"Auto Eat",function(v) Toggles.AutoEat=v
    spawn(function()
        while Toggles.AutoEat do wait(1)
            local hunger = LocalPlayer:FindFirstChild("Hunger")
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if hunger and hunger.Value<50 and backpack then
                for _,i in pairs(backpack:GetChildren()) do
                    if i.Name==ITEM_APPLE then
                        local eat = ReplicatedStorage:FindFirstChild(EVENT_EAT)
                        if eat then pcall(function() eat:FireServer(i) end) end
                        break
                    end
                end
            end
        end
    end)
end)

-- ===============================
-- Funções Combate
-- ===============================
CreateToggle(CombatTab,"Aimbot",function(v) Toggles.Aimbot=v
    spawn(function()
        while Toggles.Aimbot do wait()
            local closest; local dist=math.huge
            for _,p in pairs(Players:GetPlayers()) do
                if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local h = p.Character:FindFirstChild("Humanoid")
                    if h and h.Health>0 then
                        local mag = (p.Character.Head.Position - Camera.CFrame.Position).Magnitude
                        if mag<dist then dist=mag closest=p end
                    end
                end
            end
            if closest and closest.Character and closest.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position,closest.Character.Head.Position)
            end
        end
    end)
end)

-- ===============================
-- Funções Movimento
-- ===============================
CreateToggle(MoveTab,"Fly",function(v) Toggles.Fly=v
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if Toggles.Fly then
            hrp.Anchored = true
            spawn(function()
                while Toggles.Fly do wait()
                    local vec = Vector3.new(FlyControl.Right-FlyControl.Left,FlyControl.Up-FlyControl.Down,FlyControl.Forward-FlyControl.Backward)
                    hrp.CFrame = hrp.CFrame + vec*FlySpeed*wait()
                end
            end)
        else
            hrp.Anchored = false
        end
    end
end)

CreateSlider(MoveTab,"Fly Speed",10,200,FlySpeed,function(v) FlySpeed=v end)

-- ===============================
-- Funções ESP / Outros
-- ===============================
CreateToggle(OutrosTab,"ESP Jogadores",function(v) Toggles.ESP=v
    spawn(function()
        while Toggles.ESP do wait(1)
            for _,player in pairs(Players:GetPlayers()) do
                if player~=LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
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
                        text.TextScaled = true
                        text.Font = Enum.Font.SourceSansBold
                        billboard.Parent = game.CoreGui
                        table.insert(ESPs,billboard)
                    end
                end
            end
        end
        if not Toggles.ESP then
            for _,esp in pairs(ESPs) do
                if esp then esp:Destroy() end
            end
            ESPs = {}
        end
    end)
end)