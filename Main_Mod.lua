local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local lp = players.LocalPlayer

--[[ 
    НАСТРОЙКА СУЩНОСТЕЙ
    weight = шанс выпадения. (Больше = чаще).
]]
local entityList = {
    { name = "Ripper", url = "https://raw.githubusercontent.com/sigmacool617-arch/Doors-Worst-Nightmare-Mode/refs/heads/main/Entitys/Ripper.lua", weight = 20 },
    { name = "Rebound", url = "https://raw.githubusercontent.com/sigmacool617-arch/Doors-Worst-Nightmare-Mode/refs/heads/main/Entitys/Rebound.lua", weight = 3 }, -- Пример: Раш будет выпадать чаще
}

local isRunning = true
local activeMonsters = {}
local nextTimeSpawn = tick() + 120

-- Функция выбора монстра по весам
local function getRandomEntity()
    local totalWeight = 0
    for _, entity in ipairs(entityList) do totalWeight = totalWeight + entity.weight end
    
    local randomVal = math.random(1, totalWeight)
    local currentWeight = 0
    
    for _, entity in ipairs(entityList) do
        currentWeight = currentWeight + entity.weight
        if randomVal <= currentWeight then return entity end
    end
    return entityList[1]
end

-- Очистка мертвых монстров
local function cleanActiveMonsters()
    for i = #activeMonsters, 1, -1 do
        if not activeMonsters[i].Parent then table.remove(activeMonsters, i) end
    end
end

-- Спавн монстра
local function spawnRandomEntity(reason)
    cleanActiveMonsters()
    if #activeMonsters > 0 then return end -- Не спавним, если кто-то уже есть

    local chosen = getRandomEntity()
    print("[Мод] Спавним: " .. chosen.name .. " (Причина: " .. reason .. ")")

    task.spawn(function()
        local success, err = pcall(function()
            local source = game:HttpGet(chosen.url)
            local func = loadstring(source)
            if func then
                func()
                task.wait(1) 
                local model = workspace:FindFirstChild(chosen.name)
                if model then
                    table.insert(activeMonsters, model)
                else
                    -- Заглушка на случай, если модель не нашлась (на 30 сек)
                    local dummy = Instance.new("Folder")
                    dummy.Name = chosen.name
                    dummy.Parent = workspace
                    table.insert(activeMonsters, dummy)
                    task.delay(30, function() if dummy then dummy:Destroy() end end)
                end
            end
        end)
        if not success then warn("[Мод] Ошибка: " .. tostring(err)) end
    end)
end

-- 1. ТРИГГЕР ПО ВРЕМЕНИ (с ускорением после 90 комнаты)
task.spawn(function()
    while isRunning do
        task.wait(1)
        if tick() >= nextTimeSpawn then
            spawnRandomEntity("Таймер")
            
            local currentRoom = replicatedStorage.GameData.LatestRoom.Value
            
            -- Если комната >= 90, монстры спавнятся чаще (каждые 1.5 - 3 минуты)
            -- Иначе - каждые 3 - 6 минут
            if currentRoom >= 90 then
                nextTimeSpawn = tick() + math.random(90, 180) 
            else
                nextTimeSpawn = tick() + math.random(180, 360)
            end
        end
    end
end)

-- 2. ТРИГГЕР ПО КОМНАТАМ (динамический шанс)
replicatedStorage.GameData.LatestRoom.Changed:Connect(function(newRoom)
    task.wait(1.5) -- Ждем, пока игрок зайдет
    
    -- Считаем шанс спавна в комнате
    local spawnChance = 10 -- Базовый шанс 10%
    
    if newRoom >= 90 then
        spawnChance = 50 -- После 90 комнаты шанс 50% (как в оригинале)
    elseif newRoom > 50 then
        spawnChance = 25 -- С 50 по 89 комнату - 25%
    end
    
    -- Бросаем кубик
    if math.random(1, 100) <= spawnChance then
        spawnRandomEntity("Комната " .. newRoom .. " (Шанс " .. spawnChance .. "%)")
        
        -- Сбрасываем таймер, так как только что заспавнили
        nextTimeSpawn = tick() + math.random(180, 360)
    end
end)

-- Сброс при смерти
lp.CharacterAdded:Connect(function()
    nextTimeSpawn = tick() + 120
    activeMonsters = {}
end)

print("[Мод] Динамическая сложность активирована.")