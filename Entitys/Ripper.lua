local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- Загружаем движок
local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Entity%20Spawner/V2/Source.lua"))()

local Ripper = spawner.Create({
    Entity = {
        Name = "Ripper", 
        Asset = "rbxassetid://13942047057", -- Твой ID модели
        HeightOffset = 3, -- Поднимаем выше, чтобы не застрял в полу
    },
    Lights = {
        Flicker = { Enabled = false, Duration = 0 },
        Shatter = false,
        Repair = false,
    },
    Earthquake = { Enabled = false },
    CameraShake = {
        Enabled = true,
        Range = 100,
        Values = {5, 30, 0.1, 1.2},
    },
    Movement = {
        Speed = 150,
        Delay = 8, 
        Reversed = false, 
    },
    Rebounding = {
        Enabled = false,
        Type = "Rush",
        Min = 1,
        Max = 1,
        Delay = 1,
    },
    Damage = {
        Enabled = true,
        Range = 80,
        Amount = 100, 
    },
    Crucifixion = {
        Enabled = true,
        Range = 90,
        Resist = false,
        Break = true,
    },
    Death = {
        Type = "Curious",
        Hints = {
            "You died to...", 
            "She said this entity named Ripper, okay.", 
            "Oh, she also said what you need to do.", 
            "Hm, I won't say, just return and try again."
        },
        Cause = "Ripper"
    }
})

Ripper:SetCallback("OnSpawned", function()
    print("[Ripper] Спавн начался. Готовим комнату...")
    
    task.wait(0.5) -- Небольшая пауза, чтобы модель успела прогрузиться
    
    local roomNum = game.ReplicatedStorage.GameData.LatestRoom.Value
    local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))
    
    if currentRoom then
        -- 1. Ищем модель, чтобы вживить ей Humanoid
        local model = currentRoom:FindFirstChild("Ripper") or workspace:FindFirstChild("Ripper")
        if model then
            -- Принудительно назначаем PrimaryPart
            if not model.PrimaryPart then
                local firstPart = model:FindFirstChildWhichIsA("BasePart")
                if firstPart then model.PrimaryPart = firstPart end
            end
            
            -- Вживляем Humanoid, чтобы движок смог её толкать
            if not model:FindFirstChildOfClass("Humanoid") then
                local hum = Instance.new("Humanoid")
                hum.Parent = model
                print("[Ripper] Humanoid добавлен принудительно!")
            end
            
            -- Убираем якоря (Anchored) со всех деталей, иначе он не поедет
            for _, part in pairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = false
                    part.CanCollide = false
                end
            end
        end

        -- 2. Разбиваем все лампы
        for _, obj in pairs(currentRoom:GetDescendants()) do
            if obj:IsA("Light") then
                obj.Enabled = false
                if obj.Parent.Name == "LightFixture" or obj.Parent:FindFirstChild("Glass") then
                    obj.Parent.Transparency = 0.8
                end
            end
            if obj:IsA("ParticleEmitter") and obj.Name:lower():find("spark") then
                obj:Emit(20)
            end
        end
        
        -- 3. Звук разбития стекла
        local breakSound = Instance.new("Sound")
        breakSound.SoundId = "rbxassetid://6737582037" 
        breakSound.Volume = 5
        breakSound.Parent = currentRoom
        breakSound:Play()
        game.Debris:AddItem(breakSound, 3)

        -- 4. Красим комнату в красный
        local cc = Lighting:FindFirstChild("MainColorCorrection")
        if cc then
            TweenService:Create(cc, TweenInfo.new(2), {
                TintColor = Color3.fromRGB(255, 50, 50),
                Contrast = 0.5,
                Saturation = 0.5
            }):Play()
            
            -- Через 7 секунд возвращаем всё обратно
            task.delay(7, function()
                TweenService:Create(cc, TweenInfo.new(3), {
                    TintColor = Color3.fromRGB(255, 255, 255),
                    Contrast = 0,
                    Saturation = 0
                }):Play()
            end)
        end
    end
end)

Ripper:SetCallback("OnStartMoving", function()
    print("[Ripper] ДВИЖЕНИЕ НАЧАЛОСЬ!")
end)

Ripper:Run()
