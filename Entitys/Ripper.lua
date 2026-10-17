local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Entity%20Spawner/V2/Source.lua"))()

local Cease = spawner.Create({
    Entity = {
        Name = "Cease", 
        Asset = "rbxassetid://16167836521", -- ТВОЙ ID МОДЕЛИ
        HeightOffset = 2, -- Поднимаем чуть выше, чтобы не застрял в полу
    },
    Lights = { Flicker = { Enabled = false }, Shatter = false, Repair = false },
    Earthquake = { Enabled = false },
    CameraShake = { Enabled = true, Range = 100, Values = {5, 30, 0.1, 1.2} },
    Movement = { Speed = 150, Delay = 8, Reversed = false },
    Rebounding = { Enabled = false },
    Damage = { Enabled = true, Range = 80, Amount = 100 },
    Crucifixion = { Enabled = true, Range = 90 },
    Death = { Type = "Curious", Hints = {"You died to...", "oh,she said this thing named cease", "okay,bye"}, Cause = "Cease" }
})

Ripper:SetCallback("OnSpawned", function()
    task.wait(0.5)
    
    -- Ищем модель в комнате
    local roomNum = game.ReplicatedStorage.GameData.LatestRoom.Value
    local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))
    
    if currentRoom then
        local model = currentRoom:FindFirstChild("Cease") or workspace:FindFirstChild("Cease")
        if model then
            -- 1. Ищем главную деталь (PrimaryPart)
            local firstPart = model:FindFirstChildWhichIsA("BasePart")
            if firstPart and not model.PrimaryPart then
                model.PrimaryPart = firstPart
            end
            
            -- 2. ДОБАВЛЯЕМ HUMANOID, ЕСЛИ ЕГО НЕТ
            if not model:FindFirstChildOfClass("Humanoid") then
                local hum = Instance.new("Humanoid")
                hum.Parent = model
                print("[Cease] Humanoid добавлен принудительно!")
            end
            
            -- 3. Отключаем коллизии, чтобы он не застрял в стенах
            for _, part in pairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.Anchored = false
                end
            end
        end
        
        -- Ломаем лампы
        for _, obj in pairs(currentRoom:GetDescendants()) do
            if obj:IsA("Light") then obj.Enabled = false end
        end
        
        -- Красим комнату
        local cc = Lighting:FindFirstChild("MainColorCorrection")
        if cc then
            TweenService:Create(cc, TweenInfo.new(2), { TintColor = Color3.fromRGB(255, 50, 50), Contrast = 0.5, Saturation = 0.5 }):Play()
        end
    end
end)

Cease:Run()
