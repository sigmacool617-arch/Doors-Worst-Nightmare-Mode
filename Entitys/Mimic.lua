local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Entity%20Spawner/V2/Source.lua"))()

local Mimic = spawner.Create({
    Entity = {
        Name = "Mimic", 
        Asset = "rbxassetid://11851409651", 
        HeightOffset = 0, 
    },
    Lights = { Flicker = { Enabled = false }, Shatter = false, Repair = false },
    Earthquake = { Enabled = false },
    CameraShake = { Enabled = false },
    Movement = { Speed = 0, Delay = 999 }, 
    Rebounding = { Enabled = false },
    Damage = { Enabled = false }, 
    Crucifixion = { Enabled = false },
    Death = {
        Type = "Curious", 
        Hints = {
            "You died to Mimic...", 
            "It was hiding in the wardrobe.", 
            "Did you notice the red glow?", 
            "Never trust a closet that looks crooked."
        },
        Cause = "Mimic"
    }
})

Mimic:SetCallback("OnSpawned", function()
    print("[Mimic] Спавн начался. Ищем шкаф...")
    task.wait(0.2)

    local roomNum = game.ReplicatedStorage.GameData.LatestRoom.Value
    local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))
    if not currentRoom then return end

    -- Удаляем модель движка
    local dummyModel = currentRoom:FindFirstChild("Mimic") or workspace:FindFirstChild("Mimic")
    if dummyModel then dummyModel:Destroy() end

    -- Ищем шкаф. В Doors часто это Model с именем "Wardrobe" или "Closet"
    local closet = currentRoom:FindFirstChild("Wardrobe", true) 
                or currentRoom:FindFirstChild("Closet", true)
                or currentRoom:FindFirstChild("Wardrobe", true)

    if not closet then
        print("[Mimic] В комнате нет шкафа. Отмена.")
        return
    end

    local closetPart = closet:FindFirstChildWhichIsA("BasePart")
    
    -- Убрали наклон шкафа, чтобы выглядел ровно
    -- closetPart.CFrame = closetPart.CFrame * CFrame.Angles(math.rad(3), 0, math.rad(4)) -- Закомментировано

    -- Делаем МАЛЕНЬКОЕ и ТУСКЛОЕ свечение внутри
    local redLight = Instance.new("PointLight")
    redLight.Color = Color3.fromRGB(255, 0, 0)
    
    -- Уменьшаем яркость и радиус в 3 раза
    redLight.Brightness = 1       -- Было 3 (теперь светит еле-еле)
    redLight.Range = 2            -- Было 6 (светит только в радиусе 2 стадов)
    redLight.Shadows = false      -- Отключаем тени, чтобы не было резких перепадов
    
    -- Опускаем свет чуть ниже, чтобы он бил в пол шкафа, а не в потолок
    if closetPart then
        redLight.Parent = closetPart
        -- Смещаем свет вниз по оси Y
        redLight.Offset = Vector3.new(0, -1, 0) 
    else
        redLight.Parent = closet
    end

    -- Логика убийства
    local isDead = false
    local hasTriggered = false 
    local startTime = tick()

    task.spawn(function()
        while not isDead and (tick() - startTime < 20) do
            task.wait(0.1)
            
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if not hum or hum.Health <= 0 then
                isDead = true
                break
            end

            -- Проверка на посадку в шкаф
            if closetPart and hrp and not hasTriggered then
                local dist = (hrp.Position - closetPart.Position).Magnitude
                
                if dist < 2.5 then
                    hasTriggered = true
                    print("[Mimic] Игрок залез в шкаф! Активация...")
                    
                    local cc = Lighting:FindFirstChild("MainColorCorrection")
                    if cc then
                        TweenService:Create(cc, TweenInfo.new(0.2), {
                            TintColor = Color3.fromRGB(255, 0, 0),
                            Contrast = 1
                        }):Play()
                    end
                    
                    hum:TakeDamage(100) 
                end
            end
        end
        
        if redLight then redLight.Destroy(redLight) end
    end)
end)

Mimic:Run()
