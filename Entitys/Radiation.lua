local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Настройки
local DAMAGE_PER_SECOND = 10
local RADIUS = 100 -- Радиус действия (в стадах)
local DURATION = 20 -- Сколько секунд комната остается радиоактивной

local currentRoom = nil
local isActive = false
local damageTimer = 0

-- Находим комнату
local roomNum = game.ReplicatedStorage.GameData.LatestRoom.Value
currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))

if not currentRoom then return end

print("[Radiation] Комната заражена!")

-- 1. Визуал (зеленоватый оттенок)
local cc = Lighting:FindFirstChild("MainColorCorrection")
if cc then
    TweenService:Create(cc, TweenInfo.new(2), {
        TintColor = Color3.fromRGB(100, 255, 100),
        Contrast = 0.3
    }):Play()
end

-- 2. Звук счетчика Гейгера
local geiger = Instance.new("Sound")
geiger.SoundId = "rbxassetid://131238238" -- Звук счетчика
geiger.Volume = 3
geiger.Looped = true
geiger.Parent = workspace
geiger:Play()

-- 3. Главный цикл (наносим урон)
isActive = true
task.spawn(function()
    local startTime = tick()
    
    while isActive do
        task.wait(0.1) -- Проверяем каждые 0.1 секунды
        
        -- Если время вышло, отключаем
        if tick() - startTime >= DURATION then
            isActive = false
            break
        end
        
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if hrp and hum and hum.Health > 0 then
            -- Проверяем, находится ли игрок в этой комнате (или рядом с ней)
            local dist = (hrp.Position - currentRoom.PrimaryPart.Position).Magnitude
            
            if dist <= RADIUS then
                damageTimer = damageTimer + 0.1
                
                -- Каждую 1 секунду наносим урон
                if damageTimer >= 1 then
                    damageTimer = 0
                    hum:TakeDamage(DAMAGE_PER_SECOND)
                    
                    -- Эффект тошноты
                    local nausea = Instance.new("BlurEffect")
                    nausea.Size = 10
                    nausea.Parent = Lighting
                    TweenService:Create(nausea, TweenInfo.new(0.5), {Size = 0}):Play()
                    game.Debris:AddItem(nausea, 1)
                end
            end
        end
    end
    
    -- Очистка после окончания
    if geiger then geiger:Destroy() end
    if cc then
        TweenService:Create(cc, TweenInfo.new(2), {
            TintColor = Color3.fromRGB(255, 255, 255),
            Contrast = 0
        }):Play()
    end
    print("[Radiation] Комната очищена.")
end)
