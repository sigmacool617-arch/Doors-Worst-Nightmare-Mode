-- Загружаем движок (Спавнер)
local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Entity%20Spawner/V2/Source.lua"))()

-- Создаем настройки для нашего Раша
local Rebound = spawner.Create({
    Entity = {
        Name = "Rebound", 
        -- Тут мы ставим ID модели (можно взять стандартный Rush или любой другой)
        Asset = "rbxassetid://75187343122961", 
        HeightOffset = 0, 
    },
    Lights = {
        Flicker = { Enabled = true, Duration = 2 }, -- Свет будет мигать 2 секунды
        Shatter = true, -- Лампы разобьются
        Repair = false,
    },
    Earthquake = { Enabled = false },
    CameraShake = {
        Enabled = true,
        Range = 50,
        Values = {5, 30, 0.1, 1.2}, -- Сила тряски камеры
    },
    Movement = {
        Speed = 180, -- Скорость Раша
        Delay = 3, -- Он начнет бежать через 3 секунды
        Reversed = false, 
    },
    Rebounding = {
        Enabled = true,
        Type = "Ambush", -- Может отскочить назад, как Амбаш
        Min = 3,
        Max = 7,
        Delay = 1.5,
    },
    Damage = {
        Enabled = true,
        Range = 80, -- Убьет, если ты будешь в 80 studs
        Amount = 100, 
    },
    Crucifixion = {
        Enabled = true,
        Range = 100,
        Resist = false,
        Break = true,
    },
    Death = {
        Type = "Curious",
        Hints = {"You died to Rebound...", "You need to hide in a closet!", "And Exit..", "and again", "and again again and again..", "Please return this hell place,hehe"},
        Cause = "Rebound"
    }
})

-- Добавляем свои эффекты при спавне
Rebound:SetCallback("OnSpawned", function()
    -- Можно добавить свой звук, если хочешь
end)

-- Запускаем!
Rebound:Run()
