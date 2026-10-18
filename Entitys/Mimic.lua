local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Entity%20Spawner/V2/Source.lua"))()

local Mimic = spawner.Create({
    Entity = { Name = "Mimic", Asset = "rbxassetid://11851409651", HeightOffset = 0 },
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
    task.wait(0.2)
    local roomNum = game.ReplicatedStorage.GameData.LatestRoom.Value
    local currentRoom = workspace.CurrentRooms:FindFirstChild(tostring(roomNum))
    if not currentRoom then return end

    local dummyModel = currentRoom:FindFirstChild("Mimic") or workspace:FindFirstChild("Mimic")
    if dummyModel then dummyModel:Destroy() end

    local closet = currentRoom:FindFirstChild("Wardrobe", true) or currentRoom:FindFirstChild("Closet", true)
    if not closet then return end

    local closetPart = closet:FindFirstChildWhichIsA("BasePart")
    if not closetPart then return end

    -- Красный свет
    local redLight = Instance.new("PointLight")
    redLight.Color = Color3.fromRGB(255, 0, 0)
    redLight.Brightness = 1
    redLight.Range = 2
    redLight.Shadows = false
    
    local attachment = Instance.new("Attachment")
    attachment.Position = Vector3.new(0, -1, 0) 
    attachment.Parent = closetPart
    redLight.Parent = attachment

    local isDead = false
    local hasTriggered = false 
    local startTime = tick()

    task.spawn(function()
        while not isDead and (tick() - startTime < 20) do
            task.wait(0.1)
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hum or hum.Health <= 0 then isDead = true; break end

            if hrp and not hasTriggered then
                local dist = (hrp.Position - closetPart.Position).Magnitude
                if dist < 2.5 then
                    hasTriggered = true
                    
                    -- Вызываем смерть через движок (чтобы был текст)
                    pcall(function() Mimic:Death() end)
                    
                    local cc = Lighting:FindFirstChild("MainColorCorrection")
                    if cc then
                        TweenService:Create(cc, TweenInfo.new(0.2), {TintColor = Color3.fromRGB(255, 0, 0), Contrast = 1}):Play()
                    end
                end
            end
        end
        if redLight then redLight:Destroy() end
    end)
end)

Mimic:Run()
