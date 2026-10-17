local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- Загружаем движок
local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Entity%20Spawner/V2/Source.lua"))()

local Radiation = spawner.Create({
    Entity = {
        Name = "Radiation", 
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
            "You died to Radiation...", 
            "You stayed in the contaminated room for too long.", 
            "Run to the next door immediately.", 
            "Did you not see the green light?"
        },
        Cause = "Radiation"
    }
})

Radiation:SetCallback("OnSpawned", function()
    print("[Radiation] Комната заражена!")
    task.wait(0.1)

    local roomNum = game.ReplicatedStorage.GameData.LatestRoom.Value
    local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))
    
    if not currentRoom then return end

    -- Удаляем модель движка
    local dummyModel = currentRoom:FindFirstChild("Radiation") or workspace:FindFirstChild("Radiation")
    if dummyModel then dummyModel:Destroy() end

    -- Включаем зеленый свет
    local cc = Lighting:FindFirstChild("MainColorCorrection")
    if cc then
        TweenService:Create(cc, TweenInfo.new(2), {
            TintColor = Color3.fromRGB(100, 255, 100),
            Contrast = 0.3
        }):Play()
    end

    -- Звук Гейгера
    local geiger = Instance.new("Sound")
    geiger.SoundId = "rbxassetid://131238238" 
    geiger.Volume = 2
    geiger.Looped = true
    geiger.Parent = workspace
    geiger:Play()

    local damageTimer = 0
    local isActive = true
    local startTime = tick()

    -- ГЛАВНЫЙ ЦИКЛ (Исправленный)
    task.spawn(function()
        while isActive and (tick() - startTime < 20) do
            task.wait(0.1)
            
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                -- ПРОВЕРКА: Игрок должен быть В ТОЙ САМОЙ КОМНАТЕ
                -- Проверяем, является ли комната предком игрока (или просто дистанцию до центра)
                local isInside = false
                
                -- Если у комнаты есть PrimaryPart, проверяем дистанцию (примерно 40 стадов)
                if currentRoom.PrimaryPart then
                    local dist = (hrp.Position - currentRoom.PrimaryPart.Position).Magnitude
                    if dist <= 40 then isInside = true end
                else
                    -- Если PrimaryPart нет, проверяем по родителю (находится ли HRP внутри CurrentRooms[roomNum])
                    local currentParent = hrp
                    while currentParent do
                        if currentParent == currentRoom then
                            isInside = true
                            break
                        end
                        currentParent = currentParent.Parent
                    end
                end
                
                -- Урон идет ТОЛЬКО если игрок внутри зараженной комнаты
                if isInside then
                    damageTimer = damageTimer + 0.1
                    
                    if damageTimer >= 1 then
                        damageTimer = 0
                        hum:TakeDamage(10)
                        
                        -- Эффект размытия (тошнота)
                        local nausea = Instance.new("BlurEffect")
                        nausea.Size = 8
                        nausea.Parent = Lighting
                        TweenService:Create(nausea, TweenInfo.new(0.4), {Size = 0}):Play()
                        game.Debris:AddItem(nausea, 0.5)
                    end
                end
            end
        end
        
        -- Очистка (если прошло 20 сек)
        isActive = false
        if geiger then geiger:Destroy() end
        if cc then
            TweenService:Create(cc, TweenInfo.new(2), {
                TintColor = Color3.fromRGB(255, 255, 255),
                Contrast = 0
            }):Play()
        end
        print("[Radiation] Комната очищена.")
    end)
end)

Radiation:Run()
