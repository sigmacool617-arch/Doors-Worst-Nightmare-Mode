local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Entity%20Spawner/V2/Source.lua"))()

local Ripper = spawner.Create({
    Entity = {
        Name = "Ripper", 
        Asset = "rbxassetid://13942047057", 
        HeightOffset = 3, 
    },
    Lights = { Flicker = { Enabled = false }, Shatter = false, Repair = false },
    Earthquake = { Enabled = false },
    CameraShake = { Enabled = true, Range = 100, Values = {5, 30, 0.1, 1.2} },
    Movement = { Speed = 0, Delay = 8, Reversed = false }, -- Отключили стандартное движение
    Rebounding = { Enabled = false },
    Damage = { Enabled = true, Range = 80, Amount = 100 },
    Crucifixion = { Enabled = true, Range = 90 },
    Death = { Type = "Curious", Hints = {"You died to Ripper..."}, Cause = "Ripper" }
})

Ripper:SetCallback("OnSpawned", function()
    print("[Ripper] Спавн начался. Готовим комнату...")
    task.wait(0.5) 
    
    local roomNum = game.ReplicatedStorage.GameData.LatestRoom.Value
    local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))
    
    if currentRoom then
        -- ==========================================
        -- 1. ЭФФЕКТЫ КОМНАТЫ (Свет, звук, краснота)
        -- ==========================================
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
        
        local breakSound = Instance.new("Sound")
        breakSound.SoundId = "rbxassetid://6737582037" 
        breakSound.Volume = 5
        breakSound.Parent = currentRoom
        breakSound:Play()
        game.Debris:AddItem(breakSound, 3)

        local cc = Lighting:FindFirstChild("MainColorCorrection")
        if cc then
            TweenService:Create(cc, TweenInfo.new(2), {
                TintColor = Color3.fromRGB(255, 50, 50),
                Contrast = 0.5,
                Saturation = 0.5
            }):Play()
            
            task.delay(7, function()
                TweenService:Create(cc, TweenInfo.new(3), {
                    TintColor = Color3.fromRGB(255, 255, 255),
                    Contrast = 0,
                    Saturation = 0
                }):Play()
            end)
        end

        -- ==========================================
        -- 2. ДВИЖЕНИЕ МОДЕЛИ (Принудительный полет)
        -- ==========================================
        local model = currentRoom:FindFirstChild("Ripper") or workspace:FindFirstChild("Ripper")
        if model then
            -- Создаем невидимый блок-платформу
            local root = Instance.new("Part")
            root.Name = "RipperRoot"
            root.Size = Vector3.new(2, 2, 2)
            root.Transparency = 1
            root.CanCollide = false
            root.Anchored = true
            
            -- Ставим блок туда, где появилась модель
            if model.PrimaryPart then
                root.CFrame = model.PrimaryPart.CFrame
            elseif model:FindFirstChildWhichIsA("BasePart") then
                root.CFrame = model:FindFirstChildWhichIsA("BasePart").CFrame
            end
            
            root.Parent = currentRoom
            
            -- Привариваем детали модели к блоку
            for _, part in pairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = false
                    part.CanCollide = false
                    
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = root
                    weld.Part1 = part
                    weld.Parent = root
                end
            end
            
            -- Ищем, куда лететь (к двери)
            local door = currentRoom:FindFirstChild("Door")
            local targetPos = root.Position
            
            if door and door:FindFirstChild("Door") then
                targetPos = door.Door.Position
            else
                targetPos = root.Position + (root.CFrame.LookVector * 50)
            end
            
            -- Начинаем полет
            local distance = (root.Position - targetPos).Magnitude
            local speed = 50 
            local timeToMove = distance / speed
            
            local tween = TweenService:Create(root, TweenInfo.new(timeToMove, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
            tween:Play()
            
            -- Удаляем всё, когда он улетит
            task.delay(timeToMove + 1, function()
                if root then root:Destroy() end
                if model then model:Destroy() end
            end)
        end
    end
end)

Ripper:Run()
