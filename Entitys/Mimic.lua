local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Находим комнату
local roomNum = game.ReplicatedStorage.GameData.LatestRoom.Value
local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))
if not currentRoom then return end

-- Ищем шкаф (в Doors они обычно называются Wardrobe или Closet)
local closet = currentRoom:FindFirstChild("Wardrobe", true) or currentRoom:FindFirstChild("Closet", true)

if not closet then
    print("[Mimic] В комнате нет шкафа, мимик отменяется.")
    return
end

print("[Mimic] Шкаф заражен...")

-- 1. Делаем шкаф "неровным" (наклоняем на пару градусов)
if closet:FindFirstChildWhichIsA("BasePart") then
    local mainPart = closet:FindFirstChildWhichIsA("BasePart")
    -- Наклоняем на 5 градусов в случайную сторону
    mainPart.CFrame = mainPart.CFrame * CFrame.Angles(math.rad(5), math.rad(0), math.rad(math.random(-5, 5)))
end

-- 2. Добавляем красный свет внутри шкафа
local redLight = Instance.new("PointLight")
redLight.Color = Color3.fromRGB(255, 0, 0)
redLight.Brightness = 2
redLight.Range = 5
redLight.Parent = closet:FindFirstChildWhichIsA("BasePart") or closet

-- 3. Следим за игроком
local isDead = false
local checkConn

checkConn = task.spawn(function()
    while not isDead do
        task.wait(0.2)
        
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if not hum or hum.Health <= 0 then
            isDead = true
            break
        end
        
        -- Проверяем, не сидит ли игрок в этом шкафу
        -- В Doors при посадке в шкаф создается объект или меняется позиция
        if char and char:FindFirstChild("HumanoidRootPart") then
            local dist = (char.HumanoidRootPart.Position - (closet:FindFirstChildWhichIsA("BasePart") and closet:FindFirstChildWhichIsA("BasePart").Position or Vector3.new())).Magnitude
            
            if dist < 4 then -- Если игрок очень близко (сел в шкаф)
                print("[Mimic] Игрок залез в шкаф. Убиваем!")
                isDead = true
                
                -- Эффект
                if Lighting:FindFirstChild("MainColorCorrection") then
                    TweenService:Create(Lighting.MainColorCorrection, TweenInfo.new(0.5), {
                        TintColor = Color3.fromRGB(255, 0, 0),
                        Contrast = 1
                    }):Play()
                end
                
                hum.Health = 0 -- Убиваем
            end
        end
    end
end)

-- Если игрок не залез за 15 секунд, убираем свечение
task.delay(15, function()
    if redLight then redLight:Destroy() end
    isDead = true
end)
