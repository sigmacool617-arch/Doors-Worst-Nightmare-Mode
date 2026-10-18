local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Entity%20Spawner/V2/Source.lua"))()

-- Создаем сущность через движок (чтобы работал экран смерти)
local Extortionist = spawner.Create({
    Entity = {
        Name = "Extortionist", 
        -- СЮДА ВСТАВЬ СВОЮ ССЫЛКУ НА МОДЕЛЬ С ГИТХАБА (через Raw)
        Asset = "https://raw.githubusercontent.com/sigmacool617-arch/Doors-Worst-Nightmare-Mode/main/models/Extortionist.rbxm", 
        HeightOffset = 0, 
    },
    Lights = { Flicker = { Enabled = false }, Shatter = false, Repair = false },
    Earthquake = { Enabled = false },
    CameraShake = { Enabled = false },
    Movement = { Speed = 0, Delay = 999 }, -- Отключаем встроенное движение
    Rebounding = { Enabled = false },
    Damage = { Enabled = false }, -- Урон наносим вручную
    Crucifixion = { Enabled = false },
    Death = {
        Type = "Curious", 
        Hints = {
            "You died to Extortionist...", 
            "He asked for a tribute, but you had nothing to give.", 
            "Try to keep at least one item in your inventory.", 
            "Or just run faster next time."
        },
        Cause = "Extortionist"
    }
})

Extortionist:SetCallback("OnSpawned", function()
    print("[Extortionist] Спавн начался.")
    task.wait(0.2)

    local roomNum = game.ReplicatedStorage.GameData.LatestRoom.Value
    local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))
    if not currentRoom then return end

    -- Ищем нашу модель
    local model = currentRoom:FindFirstChild("Extortionist") or workspace:FindFirstChild("Extortionist")
    if not model then return end
    
    -- Ищем главную деталь (чтобы определить позицию)
    local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not primaryPart then return end

    -- ==========================================
    -- 1. ЗВУКИ (Ты можешь заменить ID на свои)
    -- ==========================================
    local defaultSound = Instance.new("Sound")
    defaultSound.SoundId = "rbxassetid://84864462000645" -- Звук появления
    defaultSound.Volume = 3
    defaultSound.Parent = primaryPart
    defaultSound:Play()

    local stealSound = Instance.new("Sound")
    stealSound.SoundId = "rbxassetid://139258064958096" -- Звук кражи (шепот)
    stealSound.Volume = 4
    stealSound.Parent = primaryPart

    local hitSound = Instance.new("Sound")
    hitSound.SoundId = "rbxassetid://91272160888434" -- Звук удара (стекло)
    hitSound.Volume = 5
    hitSound.Parent = primaryPart

    -- ==========================================
    -- 2. ЛОГИКА (10 СЕКУНД ОЖИДАНИЯ)
    -- ==========================================
    local hasInteracted = false
    local isDespawning = false
    local startTime = tick()

    -- Функция для удаления случайного предмета
    local function stealItem()
        local backpack = LP:FindFirstChild("Backpack")
        if not backpack then return false end
        
        -- Собираем все инструменты из рюкзака
        local items = {}
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(items, tool)
            end
        end
        
        if #items > 0 then
            local randomItem = items[math.random(1, #items)]
            print("[Extortionist] Забрал предмет: " .. randomItem.Name)
            randomItem:Destroy()
            return true
        end
        return false
    end

    -- Функция плавного исчезновения
    local function despawnSmoothly()
        if isDespawning then return end
        isDespawning = true
        
        -- Плавно делаем модель прозрачной
        for _, part in pairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                TweenService:Create(part, TweenInfo.new(1), {Transparency = 1}):Play()
            elseif part:IsA("Decal") then
                TweenService:Create(part, TweenInfo.new(1), {Transparency = 1}):Play()
            end
        end
        
        task.wait(1.2)
        model:Destroy()
    end

    -- Цикл ожидания (10 секунд)
    task.spawn(function()
        while tick() - startTime < 10 do
            task.wait(0.1)
            
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp or hasInteracted then continue end
            
            -- Проверяем, подошел ли игрок к монстру (дистанция < 6 стадов)
            local dist = (hrp.Position - primaryPart.Position).Magnitude
            if dist < 6 then
                hasInteracted = true
                
                -- Пытаемся забрать предмет
                local success = stealItem()
                if success then
                    stealSound:Play()
                    task.wait(1)
                    despawnSmoothly()
                    break
                end
            end
        end
        
        -- Если время вышло, а игрок не подошел (или у него нечего было взять)
        if not hasInteracted and not isDespawning then
            print("[Extortionist] Время вышло! Начинаем погоню.")
            
            -- Отключаем коллизии, чтобы монстр не застрял в стенах при погоне
            for _, part in pairs(model:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end

            -- Запускаем погоню
            local chaseConn
            local chaseActive = true
            local speed = 21
            
            chaseConn = RunService.Heartbeat:Connect(function(dt)
                if not chaseActive then return end
                
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if not hrp or not hum or hum.Health <= 0 then
                    chaseActive = false
                    chaseConn:Disconnect()
                    return
                end

                -- Двигаем монстра к игроку
                local dir = (hrp.Position - primaryPart.Position).Unit
                primaryPart.CFrame = primaryPart.CFrame + (dir * speed * dt)
                
                -- Поворачиваем модель в сторону игрока
                primaryPart.CFrame = CFrame.lookAt(primaryPart.Position, hrp.Position)

                -- Проверяем, догнал ли он
                local dist = (hrp.Position - primaryPart.Position).Magnitude
                if dist < 4 then
                    chaseActive = false
                    chaseConn:Disconnect()
                    
                    -- Наносим урон и исчезаем
                    print("[Extortionist] Догнал игрока!")
                    hum:TakeDamage(40) 
                    hitSound:Play()
                    
                    task.wait(0.5)
                    despawnSmoothly()
                end
            end)
            
            -- Если игрок умер или перешел в другую комнату раньше, чем через 10 секунд, 
            -- модель удалится через 15 секунд в целях оптимизации.
            task.delay(15, function()
                if model and model.Parent then despawnSmoothly() end
            end)
        end
    end)
end)

Extortionist:Run()
