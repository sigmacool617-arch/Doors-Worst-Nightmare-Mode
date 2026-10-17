local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Загружаем движок
local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Entity%20Spawner/V2/Source.lua"))()

-- Создаем сущность (модель скрыта, урон наносим вручную)
local Mimic = spawner.Create({
    Entity = {
        Name = "Mimic", 
        Asset = "rbxassetid://11851409651", -- Модель не важна, мы её удалим
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

    -- 1. Удаляем модель движка из комнаты, она нам не нужна
    local dummyModel = currentRoom:FindFirstChild("Mimic") or workspace:FindFirstChild("Mimic")
    if dummyModel then dummyModel:Destroy() end

    -- 2. Ищем шкаф (Wardrobe или Closet) во всей комнате
    local closet = currentRoom:FindFirstChild("Wardrobe", true) 
                or currentRoom:FindFirstChild("Closet", true)
                or currentRoom:FindFirstChild("Wardrobe", true)

    if not closet then
        print("[Mimic] В комнате нет шкафа. Мимик отменяется.")
        return
    end

    print("[Mimic] Шкаф заражен!")

    -- 3. Делаем шкаф "неровным" (наклоняем)
    local closetPart = closet:FindFirstChildWhichIsA("BasePart")
    if closetPart then
        -- Наклоняем вперед и в бок
        closetPart.CFrame = closetPart.CFrame * CFrame.Angles(math.rad(3), 0, math.rad(4))
    end

    -- 4. Добавляем красный свет изнутри
    local redLight = Instance.new("PointLight")
    redLight.Color = Color3.fromRGB(255, 0, 0)
    redLight.Brightness = 3
    redLight.Range = 6
    redLight.Parent = closetPart or closet

    -- 5. Слежка за игроком (Проверка на посадку в шкаф)
    local isDead = false
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

            -- Проверяем, сидит ли игрок внутри шкафа (расстояние меньше 4 стадов)
            if closetPart and hrp then
                local dist = (hrp.Position - closetPart.Position).Magnitude
                
                if dist < 4.5 then
                    print("[Mimic] Игрок залез в шкаф!")
                    isDead = true
                    
                    -- Красный экран
                    local cc = Lighting:FindFirstChild("MainColorCorrection")
                    if cc then
                        TweenService:Create(cc, TweenInfo.new(0.2), {
                            TintColor = Color3.fromRGB(255, 0, 0),
                            Contrast = 1
                        }):Play()
                    end
                    
                    -- Убиваем
                    hum.Health = 0
                end
            end
        end
        
        -- Убираем свет через 20 сек, если никто не умер
        if redLight then redLight:Destroy() end
    end)
end)

Mimic:Run()
