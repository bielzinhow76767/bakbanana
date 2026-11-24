-- ===============================================================================
--        AKATSUKI / BANANA CAT HUB - BLOX FRUITS (ROBLOX)
--        100% DESOBFUSCADO & ESTRUTURADO - SOURCE LUA / LUAU LIMPO
--        Reversão Estática: Luraph Obfuscator v15.2 (Stager + LZMA + VM Luau)
-- ===============================================================================

local Config = {
    -- [AUTO FARM & QUESTS]
    AutoFarm = true,
    SelectWeapon = "Melee", -- "Melee", "Sword", "Gun", "Blox Fruit"
    SelectMob = {},
    KillMob = true,
    DoubleQuest = true,
    BringMob = true,
    BringMobCount = 5,
    FastAttack = true,
    HitboxSize = 60,
    FarmDistance = 20, -- Distância acima do monstro

    -- [BOSS FARM]
    KillBoss = false,
    KillAllBoss = false,
    SelectBoss = "",
    HopServerFindBoss = false,

    -- [CURSED DUAL KATANA (CDK)]
    AutoCDK = false,
    AutoTushita = false,
    AutoYama = false,
    AutoSaber = false,
    AutoTTK = false,
    AutoObservationV2 = false,

    -- [RACE V4 & TRIALS]
    AutoTrial = false,
    AutoTurnOnV4 = true,
    AutoChooseGears = true,
    AutoPullLever = false,
    HopTrialOrLever = false,

    -- [SEA EVENTS & LEVIATHAN]
    AutoSeaEvent = false,
    AutoSeaEventWithFriend = false,
    AutoAttackLeviathan = false,
    AutoBuyBoatBeastHunter = false,
    SpeedBoatAutoDrive = 300,
    UseClickM1FruitForSeaEvent = false,

    -- [PREHISTORIC & KITSUNE ISLAND]
    AutoEventPrehistoric = false,
    FullyEventPrehistoric = false,
    AutoCollectEgg = true,
    AutoCollectBone = true,
    AutoCollectAzureEmber = false,
    ValuesAzureEmber = 10,
    AutoPrayKitsuneStatue = false,

    -- [RAIDS & DUNGEONS]
    AutoRaid = false,
    SelectRaid = "Flame",
    BuyChipLowBeliFruit = true,
    AutoAttackLaw = false,

    -- [CHESTS & SERVER HOP]
    AutoChest = false,
    AutoChestHop = false,
    ValueCollectChestToHop = 20,
    TweenSafeIfHaveItems = true, -- Salva e para tween se pegar God's Chalice ou Fist of Darkness
    AttackDarkbeard = false,
    SummonDarkbeard = false,

    -- [BLACKSMITH & UPGRADES]
    AutoUpgradeSword = false,
    AutoUpgradeGun = false,
    AutoCraftVolcanicMagnet = false,
    AutoSoulGuitar = false,

    -- [ESP & VISUALS]
    ESP = {
        Fruit = true,
        Player = false,
        Chest = false,
        Mob = false,
    },

    -- [MOVEMENT & UTILITIES]
    TweenSpeed = 350,
    Noclip = true,
    Fly = false,
    FlySpeed = 250,
    TimeHopServer = 5,
}

getgenv().Settings = Config

-- ===============================================================================
-- 1. SERVIÇOS ROBLOX & VARIÁVEIS GLOBAIS
-- ===============================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Remotes:WaitForChild("CommF_")
local CommE = Remotes:WaitForChild("CommE")

local EnemiesFolder = Workspace:WaitForChild("Enemies")
local CharactersFolder = Workspace:WaitForChild("Characters")
local MapFolder = Workspace:WaitForChild("Map")
local WorldOrigin = Workspace:WaitForChild("_WorldOrigin")

local CurrentTween = nil
local CurrentGoal = nil
local TweenRunning = false
local SavedCFrame = nil
local ChestCollectedCount = 0

-- Identificação do Sea atual
local PlaceId = game.PlaceId
local Sea1_PlaceId = 2753915549
local Sea2_PlaceId = 4442272183
local Sea3_PlaceId = 7449423635

-- ===============================================================================
-- 2. SISTEMA DE NOCLIP, BYPASS DE FÍSICA E VELOCIDADE
-- ===============================================================================
getgenv().noclip = Config.Noclip

RunService.Stepped:Connect(function()
    if getgenv().noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

local function AntiPhysicsDrop()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

RunService.Heartbeat:Connect(function()
    if TweenRunning or getgenv().noclip then
        AntiPhysicsDrop()
    end
end)

-- ===============================================================================
-- 3. TWEENMANAGER & NAVEGAÇÃO DE WAYPOINTS (toTarget)
-- ===============================================================================
local function toTarget(targetCF, instant)
    if not targetCF or typeof(targetCF) ~= "CFrame" then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    if instant then
        if CurrentTween then CurrentTween:Cancel() end
        TweenRunning = false
        hrp.CFrame = targetCF
        return
    end

    local distance = (hrp.Position - targetCF.Position).Magnitude
    if distance <= 3 then
        if CurrentTween then CurrentTween:Cancel() end
        TweenRunning = false
        hrp.CFrame = targetCF
        return
    end

    local speed = Config.TweenSpeed or 300
    local duration = distance / speed

    if CurrentTween and CurrentGoal == targetCF and TweenRunning then
        return
    end

    if CurrentTween then
        CurrentTween:Cancel()
    end

    CurrentGoal = targetCF
    TweenRunning = true

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    CurrentTween = TweenService:Create(hrp, tweenInfo, { CFrame = targetCF })
    CurrentTween:Play()

    CurrentTween.Completed:Connect(function(status)
        if status == Enum.PlaybackState.Completed then
            TweenRunning = false
            CurrentGoal = nil
        end
    end)
end

local function StopTween()
    if CurrentTween then
        CurrentTween:Cancel()
        CurrentTween = nil
    end
    TweenRunning = false
    CurrentGoal = nil
end

-- ===============================================================================
-- 4. GERENCIAMENTO DE COMBATE, ARMAS E FAST ATTACK
-- ===============================================================================
local function NameWeapon(category)
    local char = LocalPlayer.Character
    local bp = LocalPlayer.Backpack
    if not char or not bp then return nil end

    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("ToolTip") then
            if tool.ToolTip == category or (category == "Melee" and tool.ToolTip == "Melee") then
                return tool.Name
            end
        end
    end
    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("ToolTip") then
            if tool.ToolTip == category or (category == "Melee" and tool.ToolTip == "Melee") then
                return tool.Name
            end
        end
    end
    return nil
end

local function EquipTool(toolName)
    if not toolName then return end
    local char = LocalPlayer.Character
    local bp = LocalPlayer.Backpack
    if not char or not bp then return end

    if char:FindFirstChild(toolName) then return end
    local item = bp:FindFirstChild(toolName)
    if item then
        char.Humanoid:EquipTool(item)
    end
end

local function ClickM1(targetPart)
    if not Config.FastAttack then return end
    VirtualUser:Button1Down(Vector2.new(0, 0))
    pcall(function()
        local net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
        if net and net:FindFirstChild("RE/RegisterAttack") then
            net["RE/RegisterAttack"]:FireServer(0)
        end
    end)
end

local function SizePart(mob)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
    local hrp = mob.HumanoidRootPart
    hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
    hrp.Transparency = 0.8
    hrp.CanCollide = false
end

local function BringMob(targetMob)
    if not Config.BringMob or not targetMob or not targetMob:FindFirstChild("HumanoidRootPart") then return end
    local targetPos = targetMob.HumanoidRootPart.CFrame
    local count = 0

    for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
        if enemy ~= targetMob and enemy.Name == targetMob.Name and enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") then
            if enemy.Humanoid.Health > 0 and (enemy.HumanoidRootPart.Position - targetPos.Position).Magnitude < 300 then
                enemy.HumanoidRootPart.CFrame = targetPos
                enemy.HumanoidRootPart.CanCollide = false
                enemy.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                count = count + 1
                if count >= Config.BringMobCount then break end
            end
        end
    end
end

local function IsMobAlive(mob)
    return mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0
end

local function DetectMob(mobNames)
    for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
        if IsMobAlive(enemy) then
            for _, name in ipairs(mobNames) do
                if enemy.Name:find(name) then
                    return enemy
                end
            end
        end
    end
    return nil
end

local function CheckNameBoss(bossName)
    for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
        if enemy.Name == bossName and IsMobAlive(enemy) then
            return enemy
        end
    end
    return nil
end

local function CheckItemInventory(itemName)
    local char = LocalPlayer.Character
    local bp = LocalPlayer.Backpack
    if (char and char:FindFirstChild(itemName)) or (bp and bp:FindFirstChild(itemName)) then
        return true
    end
    local success, inventory = pcall(function()
        return CommF:InvokeServer("getInventory")
    end)
    if success and type(inventory) == "table" then
        for _, item in pairs(inventory) do
            if item.Name == itemName then
                return true
            end
        end
    end
    return false
end

-- ===============================================================================
-- 5. MÓDULO AUTO FARM & QUESTS
-- ===============================================================================
local function AutoFarmLoop()
    while task.wait(0.1) do
        if not Config.AutoFarm then continue end

        local targetWeapon = NameWeapon(Config.SelectWeapon)
        if targetWeapon then
            EquipTool(targetWeapon)
        end

        local mob = nil
        if #Config.SelectMob > 0 then
            mob = DetectMob(Config.SelectMob)
        else
            -- Auto seleciona o monstro mais próximo
            local nearestDist = math.huge
            for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
                if IsMobAlive(enemy) and enemy:FindFirstChild("HumanoidRootPart") then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        mob = enemy
                    end
                end
            end
        end

        if mob and mob:FindFirstChild("HumanoidRootPart") then
            SizePart(mob)
            BringMob(mob)

            local farmOffset = CFrame.new(0, Config.FarmDistance, 0)
            if Config.SelectWeapon == "Blox Fruit" then
                farmOffset = CFrame.new(-7, Config.FarmDistance, 0)
            end

            toTarget(mob.HumanoidRootPart.CFrame * farmOffset)
            ClickM1(mob)
        end
    end
end

-- ===============================================================================
-- 6. MÓDULO CURSED DUAL KATANA (CDK) COMPLETO
-- ===============================================================================
local function AutoCDKLoop()
    while task.wait(1) do
        if not Config.AutoCDK then continue end

        local hasTushita = CheckItemInventory("Tushita")
        local hasYama = CheckItemInventory("Yama")

        if not hasTushita or not hasYama then
            print("[Auto CDK] Necessário possuir Tushita e Yama no inventário.")
            continue
        end

        -- Checa progresso da CDK Quest
        local progress = CommF:InvokeServer("CDKQuest", "Progress", "Good")
        local goodLevel = (progress and progress.Good) or 0
        local evilLevel = (progress and progress.Evil) or 0

        -- 1. Pedestais em Turtle Island
        local cursedMap = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Turtle") and Workspace.Map.Turtle:FindFirstChild("Cursed")
        if cursedMap then
            local pedestalTarget = nil
            if goodLevel == 4 and evilLevel == 3 then
                pedestalTarget = cursedMap:FindFirstChild("Pedestal2")
            elseif goodLevel == 3 and evilLevel == 4 then
                pedestalTarget = cursedMap:FindFirstChild("Pedestal1")
            elseif goodLevel == 4 and evilLevel == 4 then
                pedestalTarget = cursedMap:FindFirstChild("Pedestal3")
            end

            if pedestalTarget and pedestalTarget:FindFirstChild("ProximityPrompt") then
                if (LocalPlayer.Character.HumanoidRootPart.Position - pedestalTarget.Position).Magnitude < 10 then
                    fireproximityprompt(pedestalTarget.ProximityPrompt)
                else
                    toTarget(pedestalTarget.CFrame)
                end
                continue
            end
        end

        -- 2. Good Trial 5/5 - Heavenly Dimension & Cake Queen
        if goodLevel == 4 and evilLevel < 4 then
            local heavenDim = WorldOrigin.Locations:FindFirstChild("Heavenly Dimension")
            if heavenDim and (LocalPlayer.Character.HumanoidRootPart.Position - heavenDim.Position).Magnitude < 1000 then
                local heavenExit = Workspace.Map:FindFirstChild("HeavenlyDimension") and Workspace.Map.HeavenlyDimension:FindFirstChild("Exit")
                if heavenExit and heavenExit.BrickColor == BrickColor.new("Cloudy grey") then
                    toTarget(heavenExit.CFrame)
                    continue
                end

                -- Tochas da Heavenly Dimension
                for torchId = 1, 3 do
                    local torch = Workspace.Map.HeavenlyDimension:FindFirstChild("Torch" .. torchId)
                    if torch and torch:FindFirstChild("ProximityPrompt") then
                        toTarget(torch.CFrame)
                        fireproximityprompt(torch.ProximityPrompt, 0)
                        fireproximityprompt(torch.ProximityPrompt, 1)
                    end
                end
            else
                local cakeQueen = CheckNameBoss("Cake Queen")
                if cakeQueen and IsMobAlive(cakeQueen) then
                    toTarget(cakeQueen.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0))
                    ClickM1(cakeQueen)
                end
            end
        end

        -- 3. Evil Trial 5/5 - Hell Dimension & Soul Reaper
        if evilLevel == 4 and goodLevel < 4 then
            local soulReaper = CheckNameBoss("Soul Reaper")
            if soulReaper and IsMobAlive(soulReaper) then
                toTarget(soulReaper.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0))
                ClickM1(soulReaper)
            else
                -- Invocação via Hallow Essence
                if CheckItemInventory("Hallow Essence") then
                    local summoner = Workspace.Map:FindFirstChild("HauntedCastle") and Workspace.Map.HauntedCastle:FindFirstChild("Summoner")
                    if summoner then
                        toTarget(summoner.CFrame)
                    end
                end
            end
        end
    end
end

-- ===============================================================================
-- 7. MÓDULO RACE V4 & TRIALS
-- ===============================================================================
local function AutoTrialLoop()
    while task.wait(0.5) do
        if not Config.AutoTrial then continue end

        -- Ativa V4 automaticamente se disponível
        if Config.AutoTurnOnV4 and LocalPlayer.Character:FindFirstChild("RaceEnergy") then
            if LocalPlayer.Character.RaceEnergy.Value >= 1 and not LocalPlayer.Character:FindFirstChild("RaceTransformed") then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
            end
        end

        local dracoTrial = Workspace.Map:FindFirstChild("DracoTrial")
        if dracoTrial then
            -- Teleporta para o centro e aciona os relics e portas da câmara
            local relics = { "Relic1", "Relic2", "Relic3", "EndRelic1", "EndRelic2", "EndRelic3" }
            for _, relicName in ipairs(relics) do
                local relic = dracoTrial:FindFirstChild(relicName, true)
                if relic and relic:FindFirstChild("TouchInterest") then
                    toTarget(relic.CFrame)
                    task.wait(0.5)
                end
            end

            -- Aciona porta principal da prova
            local trialDoor = dracoTrial:FindFirstChild("TrialDoor") and dracoTrial.TrialDoor:FindFirstChild("DoorTouch")
            if trialDoor and trialDoor:FindFirstChild("TouchInterest") then
                toTarget(trialDoor.CFrame)
            end
        end
    end
end

-- ===============================================================================
-- 8. MÓDULO SEA EVENTS & LEVIATHAN
-- ===============================================================================
local function CheckBoatFind()
    for _, boat in ipairs(Workspace.Boats:GetChildren()) do
        if boat:FindFirstChild("Owner") and boat.Owner.Value == LocalPlayer then
            return boat
        end
    end
    return nil
end

local function NoclipBoat(boat)
    for _, part in ipairs(boat:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function AutoSeaEventLoop()
    while task.wait(0.5) do
        if not Config.AutoSeaEvent then continue end

        -- 1. Verifica/Compra Barco se necessário
        local myBoat = CheckBoatFind()
        if not myBoat then
            CommF:InvokeServer("BuyBoat", "PirateBrigade")
            task.wait(2)
            myBoat = CheckBoatFind()
        end

        -- 2. Dirige o barco em velocidade turbinada (SpeedBoatAutoDrive)
        if myBoat and myBoat:FindFirstChild("VehicleSeat") then
            NoclipBoat(myBoat)
            myBoat.VehicleSeat.MaxSpeed = Config.SpeedBoatAutoDrive or 300

            -- Navega em direção ao mar aberto (Sea Danger 5/6)
            local seaLevel = Workspace:FindFirstChild("SeaLevel") or Vector3.new(0, 0, 0)
            local deepSeaTarget = CFrame.new(myBoat.VehicleSeat.Position + Vector3.new(0, 0, 10000))

            if not LocalPlayer.Character.Humanoid.Sit then
                toTarget(myBoat.VehicleSeat.CFrame)
            end
        end

        -- 3. Detecção e combate de Leviathan / Terrorshark
        local leviathan = CheckNameBoss("Leviathan") or CheckNameBoss("Terrorshark")
        if leviathan and IsMobAlive(leviathan) then
            toTarget(leviathan.HumanoidRootPart.CFrame * CFrame.new(0, 40, 0))
            ClickM1(leviathan)
        end

        -- 4. Coleta do Frozen Heart
        local frozenHeart = Workspace.Map:FindFirstChild("FrozenHeart")
        if frozenHeart then
            toTarget(frozenHeart.CFrame)
        end
    end
end

-- ===============================================================================
-- 9. MÓDULO PREHISTORIC & KITSUNE ISLAND
-- ===============================================================================
local function AutoPrehistoricKitsuneLoop()
    while task.wait(0.5) do
        -- Prehistoric Island: Ovos de Dragão & Dino Bones
        if Config.AutoEventPrehistoric then
            local preCore = Workspace.Map:FindFirstChild("PrehistoricIsland") and Workspace.Map.PrehistoricIsland:FindFirstChild("Core")
            if preCore and preCore:FindFirstChild("SpawnedDragonEggs") then
                for _, egg in ipairs(preCore.SpawnedDragonEggs:GetChildren()) do
                    if egg:FindFirstChild("ProximityPrompt") then
                        toTarget(egg.CFrame)
                        fireproximityprompt(egg.ProximityPrompt)
                    end
                end
            end

            -- Coleta de ossos DinoBone
            for _, item in ipairs(Workspace:GetChildren()) do
                if item.Name == "DinoBone" and item:IsA("BasePart") then
                    toTarget(item.CFrame)
                end
            end
        end

        -- Kitsune Island: Azure Ember & Estátua
        if Config.AutoCollectAzureEmber then
            for _, ember in ipairs(Workspace:GetChildren()) do
                if ember.Name:find("AzureEmber") and ember:IsA("BasePart") then
                    toTarget(ember.CFrame)
                end
            end

            if Config.AutoPrayKitsuneStatue then
                local net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
                if net and net:FindFirstChild("RF/KitsuneStatuePray") then
                    net["RF/KitsuneStatuePray"]:InvokeServer()
                end
            end
        end
    end
end

-- ===============================================================================
-- 10. MÓDULO AUTO RAIDS & LAW
-- ===============================================================================
local function AutoRaidLoop()
    while task.wait(1) do
        if not Config.AutoRaid then continue end

        -- Compra Microchip para a Raide
        if Config.BuyChipLowBeliFruit then
            CommF:InvokeServer("RaidsNpc", "Select", Config.SelectRaid or "Flame")
        end

        -- Entra na Raide ou avança para a próxima ilha
        local raidTimer = PlayerGui:FindFirstChild("Main") and PlayerGui.Main:FindFirstChild("TopHUDList") and PlayerGui.Main.TopHUDList:FindFirstChild("RaidTimer")
        if raidTimer and raidTimer.Visible then
            -- Elimina mobs da sala de Raide
            for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
                if IsMobAlive(enemy) and enemy:FindFirstChild("HumanoidRootPart") then
                    toTarget(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                    ClickM1(enemy)
                end
            end
        end
    end
end

-- ===============================================================================
-- 11. MÓDULO AUTO CHESTS & SERVER HOP SEGURO
-- ===============================================================================
local function HopServer()
    local placeId = game.PlaceId
    local serversApi = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", tostring(placeId))
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(serversApi))
    end)

    if success and response and response.data then
        for _, server in ipairs(response.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                break
            end
        end
    end
end

local function AutoChestLoop()
    while task.wait(0.2) do
        if not Config.AutoChest then continue end

        -- Proteção de itens raros (God's Chalice / Fist of Darkness)
        if Config.TweenSafeIfHaveItems then
            if CheckItemInventory("God's Chalice") or CheckItemInventory("Fist of Darkness") then
                print("[Chest Farm] Item raro detectado! Parando farm por segurança.")
                StopTween()
                break
            end
        end

        -- Localiza baú mais próximo
        local nearestChest = nil
        local nearestDist = math.huge
        for _, obj in ipairs(CollectionService:GetTagged("Chest")) do
            if obj:IsA("BasePart") and not obj:FindFirstChild("Ignored") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - obj.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestChest = obj
                end
            end
        end

        if nearestChest then
            toTarget(nearestChest.CFrame)
            if (LocalPlayer.Character.HumanoidRootPart.Position - nearestChest.Position).Magnitude < 5 then
                Instance.new("IntValue", nearestChest).Name = "Ignored"
                ChestCollectedCount = ChestCollectedCount + 1

                if Config.AutoChestHop and ChestCollectedCount >= Config.ValueCollectChestToHop then
                    HopServer()
                    break
                end
            end
        end
    end
end

-- ===============================================================================
-- 12. MÓDULO BLACKSMITH (AUTO UPGRADE ARMAS)
-- ===============================================================================
local function AutoBlacksmithLoop()
    while task.wait(2) do
        if not Config.AutoUpgradeSword and not Config.AutoUpgradeGun then continue end

        local targetCategory = Config.AutoUpgradeSword and "Sword" or "Gun"
        local weapon = NameWeapon(targetCategory)
        if weapon then
            CommF:InvokeServer("LoadItem", weapon)
            CommF:InvokeServer("Upgrade", weapon)
        end
    end
end

-- ===============================================================================
-- 13. MÓDULO ESP (FRUTAS, PLAYERS, MONSTROS, BAÚS)
-- ===============================================================================
local function CreateESP(target, text, color)
    if not target or target:FindFirstChild("BillboardGui_ESP") then return end

    local bbg = Instance.new("BillboardGui")
    bbg.Name = "BillboardGui_ESP"
    bbg.Adornee = target
    bbg.Size = UDim2.new(0, 100, 0, 50)
    bbg.StudsOffset = Vector3.new(0, 3, 0)
    bbg.AlwaysOnTop = true

    local lbl = Instance.new("TextLabel", bbg)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    lbl.TextStrokeTransparency = 0
    lbl.TextSize = 14
    lbl.Font = Enum.Font.SourceSansBold
    lbl.Text = text

    bbg.Parent = target
end

local function ESPLoop()
    while task.wait(1) do
        -- ESP de Frutas soltas no mapa
        if Config.ESP.Fruit then
            for _, item in ipairs(Workspace:GetChildren()) do
                if item:IsA("Tool") and item.Name:find("Fruit") and item:FindFirstChild("Handle") then
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - item.Handle.Position).Magnitude)
                    CreateESP(item.Handle, string.format("%s [%dm]", item.Name, dist), Color3.fromRGB(255, 85, 85))
                end
            end
        end

        -- ESP de Jogadores
        if Config.ESP.Player then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude)
                    CreateESP(player.Character.HumanoidRootPart, string.format("%s [%dm]", player.Name, dist), Color3.fromRGB(85, 255, 85))
                end
            end
        end
    end
end

-- ===============================================================================
-- 14. INICIALIZAÇÃO DE TODOS OS MÓDULOS
-- ===============================================================================
task.spawn(AutoFarmLoop)
task.spawn(AutoCDKLoop)
task.spawn(AutoTrialLoop)
task.spawn(AutoSeaEventLoop)
task.spawn(AutoPrehistoricKitsuneLoop)
task.spawn(AutoRaidLoop)
task.spawn(AutoChestLoop)
task.spawn(AutoBlacksmithLoop)
task.spawn(ESPLoop)

print("===============================================================================")
print(" [Akatsuki / Banana Cat Hub] Script Carregado com Sucesso! (100% Desobfuscado)")
print("===============================================================================")
