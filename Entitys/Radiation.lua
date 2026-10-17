local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- Загружаем движок
local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Entity%20Spawner/V2/Source.lua"))()

-- Создаем "пустышку" через движок, чтобы он показал красивый экран смерти
local Radiation = spawner.Create({
    Entity = {
        Name = "Radiation", 
        Asset = "rbxassetid://11851409651", -- Модель не важна, мы её спрячем
        HeightOffset = 0, 
    },
    Lights = { Flicker = { Enabled = false }, Shatter = false, Repair = false },
    Earthquake = { Enabled = false },
    CameraShake = { Enabled = false },
    Movement = { Speed = 0, Delay = 999 }, -- Он никогда не побежит
    Rebounding = { Enabled = false },
    Damage = { Enabled = false }, -- Отключаем урон движка, у нас свой
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

    -- 1. СРАЗУ УБИРАЕМ МОДЕЛЬ (чтобы она не висела в комнате)
    local roomNum = game.ReplicatedStorage.GameData.LatestRoom.Value
    local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))
    
    if currentRoom then
        local model = currentRoom:FindFirstChild("Radiation") or workspace:FindFirstChild("Radiation")
        if model then model:Destroy() end
    end

    -- 2. ЭФФЕКТ ЗЕЛЕНОГО СВЕТА
    local cc = Lighting:FindFirstChild("MainColorCorrection")
    if cc then
        TweenService:Create(cc, TweenInfo.new(2), {
            TintColor = Color3.fromRGB(100, 255, 100),
            Contrast = 0.3
        }):Play()
    end

    -- 3. ЗВУК СЧЕТЧИКА ГЕЙГЕРА
    local geiger = Instance.new("Sound")
    geiger.SoundId = "rbxassetid://131238238" 
    geiger.Volume = 2
    geiger.Looped = true
    geiger.Parent = workspace
    geiger:Play()

    -- 4. ЛОГИКА УРОНА
    local damageTimer = 0
    local isActive = true
    local startTime = tick()

    -- Цикл работает 20 секунд, потом комната очищается
    task.spawn(function()
        while isActive and (tick() - startTime < 20) do
            task.wait(0.1)
            
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                damageTimer = damageTimer + 0.1
                
                -- Каждую секунду отнимаем 10 HP
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
        
        -- Очистка
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
