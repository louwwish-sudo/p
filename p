
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = workspace
local Event = ReplicatedStorage.Shared.Packages.Network.rev_KickEvent
local CollectEvent = ReplicatedStorage.Shared.Packages.Network.rev_B_Collect
local UpgradeEvent = ReplicatedStorage.Shared.Packages.Network.rev_B_Upgrade

local AUTO_EXEC_URL = "https://raw.githubusercontent.com/louissxe/MainUI/refs/heads/main/src/config/load.lua"
local _autoExecQueued = false

local function queueOnTeleport()
    if not queue_on_teleport then
        return false
    end
    if _autoExecQueued then
        return true
    end
    _autoExecQueued = true
    pcall(queue_on_teleport, game:HttpGet(AUTO_EXEC_URL, true))
    return true
end

local function _autoExecReload(reason)
    task.spawn(function()
        task.wait(3)
        if getgenv().__lshub_window and not getgenv().__lshub_window._isDestroying then
            return
        end

        getgenv().__lshub_autoexec_running = nil
        getgenv().__lshub_window = nil
        getgenv().__lshub_floatingGui = nil

        local ok, result = pcall(function()
            if not game:IsLoaded() then
                game.Loaded:Wait()
            end
            local source = game:HttpGet(AUTO_EXEC_URL, true)
            return loadstring(source)()
        end)
        if not ok then
            warn("[AutoExec] Gagal reload setelah " .. tostring(reason) .. ": " .. tostring(result))
        end
    end)
end

if not getgenv().__lshub_autoexec_running then
    getgenv().__lshub_autoexec_running = true
    queueOnTeleport()

    TeleportService.LocalPlayerArrivedFromTeleport:Connect(function()
        if queueOnTeleport() then
            return
        end
        _autoExecReload("TeleportArrived")
    end)

    if LocalPlayer and LocalPlayer.OnTeleport then
        LocalPlayer.OnTeleport:Connect(function(state)
            if state == Enum.TeleportState.InProgress or state == Enum.TeleportState.Started then
                if queueOnTeleport() then
                    return
                end
                _autoExecReload("LocalPlayer.OnTeleport")
            end
        end)
    end

    -- Fix: event-based, bukan Heartbeat loop
    if not game:IsLoaded() then
        game.Loaded:Connect(function()
            _autoExecReload("GameLoaded / Reconnect")
        end)
    end
end -- <-- ini penutup if not getgenv().__lshub_autoexec_running

local WindUI
do
    local ok, result = pcall(require, "./src/Init")
    if ok then
        WindUI = result
    else
        local _version = "1.6.64-fix"
        WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" ..
            _version .. "/main.lua"))()
    end
end

local function typingSequence(callback)
    task.spawn(function()
        local texts = {
            "developed by Louissxe",
            "discord.gg/S8kzPv5dZ",
            "Kick a Lucky Block"
        }

        local function typeText(text)
            local current = ""

            for i = 1, #text do
                current = string.sub(text, 1, i)
                callback(current)

                task.wait(math.random(40, 80) / 1000)
            end

            return current
        end

        local function deleteText(text)
            for i = #text, 0, -1 do
                local current = string.sub(text, 1, i)

                callback(current)
                task.wait(0.025)
            end
        end

        local function blink(text, duration)
            local timePassed = 0
            local show = true

            while timePassed < duration do
                if show then
                    callback(text .. "|")
                else
                    callback(text)
                end

                show = not show

                task.wait(0.5)
                timePassed += 0.5
            end
        end

        while true do
            for _, text in ipairs(texts) do
                local full = typeText(text)

                blink(full, 4)
                deleteText(text)

                task.wait(2)
            end
        end
    end)
end

WindUI:AddTheme({
    Name = "Pler",

    Icon = Color3.fromRGB(255, 255, 255),

    Accent = WindUI:Gradient({
        ["0"] = {
            Color = Color3.fromRGB(40, 40, 40),
            Transparency = 0
        },
        ["100"] = {
            Color = Color3.fromRGB(90, 90, 90),
            Transparency = 0
        }
    }),

    Dialog = Color3.fromRGB(10, 10, 10),

    Outline = Color3.fromRGB(120, 120, 120),

    Text = Color3.fromRGB(240, 240, 240),

    Placeholder = Color3.fromRGB(150, 150, 150),

    Button = WindUI:Gradient({
        ["0"] = {
            Color = Color3.fromRGB(20, 20, 20),
            Transparency = 0
        },
        ["100"] = {
            Color = Color3.fromRGB(45, 45, 45),
            Transparency = 0
        }
    }),

    WindowBackground = WindUI:Gradient({
        ["0"] = {
            Color = Color3.fromRGB(5, 5, 5),
            Transparency = 0
        },
        ["100"] = {
            Color = Color3.fromRGB(25, 25, 25),
            Transparency = 0
        }
    })
})

local function CreateFloatingIcon()
    if getgenv().__lshub_floatingGui then
        pcall(function()
            getgenv().__lshub_floatingGui:Destroy()
        end)
        getgenv().__lshub_floatingGui = nil
    end
    local existing = PlayerGui:FindFirstChild("Icon_lshub")
    if existing then
        existing:Destroy()
    end
    local gui = Instance.new("ScreenGui")
    gui.Name = "Icon_lshub"
    gui.DisplayOrder = 9999
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local frame = Instance.new("Frame")
    frame.Name = "FloatingFrame"
    frame.Position = UDim2.new(1, -55, 0, 55)
    frame.Size = UDim2.fromOffset(45, 45)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.ZIndex = 9999
    frame.Parent = gui
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(32, 28, 26)
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    local icon = Instance.new("ImageLabel")
    icon.Image = "rbxassetid://112751757995505"
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.new(1, -4, 1, -4)
    icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Parent = frame
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 10)
    iconCorner.Parent = icon
    gui.Parent = PlayerGui
    getgenv().__lshub_floatingGui = gui
    return gui, frame
end
local function SetupFloatingIcon(gui, frame)
    if getgenv().__lshub_icon_conn then
        pcall(function() getgenv().__lshub_icon_conn:Disconnect() end)
        getgenv().__lshub_icon_conn = nil
    end
    getgenv().__lshub_icon_conn = frame.InputBegan:Connect(function(input)
        local isTouch = input.UserInputType == Enum.UserInputType.Touch
        local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
        if not (isTouch or isMouse) then
            return
        end
        local dragStart = input.Position
        local startPos = frame.Position
        local didMove = false
        local isDragging = true
        local function applyDrag(currentPos)
            if not isDragging then return end
            if not didMove and (currentPos - dragStart).Magnitude > 6 then
                didMove = true
            end
            if didMove then
                local delta = currentPos - dragStart
                frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
        local function stopDragFn()
            isDragging = false
            if not didMove then
                local win = getgenv().__lshub_window
                if win and win.Toggle and not win._isDestroying then
                    win:Toggle()
                end
            end
        end
        if isTouch then
            local moveC, endC
            moveC = input.Changed:Connect(function()
                applyDrag(input.Position)
            end)
            endC = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    moveC:Disconnect()
                    endC:Disconnect()
                    stopDragFn()
                end
            end)
        elseif isMouse then
            local moveC, endC
            moveC = UserInputService.InputChanged:Connect(function(m)
                if m.UserInputType == Enum.UserInputType.MouseMovement then
                    applyDrag(m.Position)
                end
            end)
            endC = UserInputService.InputEnded:Connect(function(e)
                if e.UserInputType == Enum.UserInputType.MouseButton1 then
                    moveC:Disconnect()
                    endC:Disconnect()
                    stopDragFn()
                end
            end)
        end
    end)
end
local function InitializeIcon()
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    local g, f = CreateFloatingIcon()
    if g and f then
        SetupFloatingIcon(g, f)
    end
end
if not getgenv().__lshub_char_icon_conn then
    getgenv().__lshub_char_icon_conn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if getgenv().__lshub_window and not getgenv().__lshub_window._isDestroying then
            InitializeIcon()
        end
    end)
end

do
    if getgenv().__lshub_window then
        pcall(function()
            getgenv().__lshub_window:Destroy()
        end)
    end

    local Window = WindUI:CreateWindow({
        Title = "Luxvs Community",
        Theme = "Pler",
        Author = "",
        Folder = "LSHub-Univcs",
        Icon = "rbxassetid://75522306265517",
        Transparent = true,
        IconSize = 30,
        NewElements = true,
        ToggleKey = Enum.KeyCode.G,
        Size = UDim2.fromOffset(530, 350),
        User = {
            Enabled = true,
            Anonymous = false
        },
        HideSearchBar = false,
        Topbar = {
            Height = 50,
            ButtonsType = "Default"
        },
    })
    getgenv().__lshub_window = Window

    local oldDestroy = Window.Destroy
    function Window:Destroy()
        if self._isDestroying then
            return
        end
        self._isDestroying = true
        if getgenv().__lshub_floatingGui then
            pcall(function()
                getgenv().__lshub_floatingGui:Destroy()
            end)
            getgenv().__lshub_floatingGui = nil
        end
        if getgenv().__lshub_icon_conn then
            pcall(function() getgenv().__lshub_icon_conn:Disconnect() end)
            getgenv().__lshub_icon_conn = nil
        end
        if getgenv().__lshub_char_icon_conn then
            pcall(function() getgenv().__lshub_char_icon_conn:Disconnect() end)
            getgenv().__lshub_char_icon_conn = nil
        end
        if oldDestroy then
            oldDestroy(self)
        end
    end

    local _uiReady    = false
    local _Http       = game:GetService("HttpService")
    local _CFG_FOLDER = "LSHub-Univcs"
    local _CFG_FILE   = _CFG_FOLDER .. "/dashboard_v1.json"
    local _cfg        = {}

    local function _saveCfg()
        if not _uiReady then return end
        pcall(function()
            if not isfolder(_CFG_FOLDER) then makefolder(_CFG_FOLDER) end
            writefile(_CFG_FILE, _Http:JSONEncode(_cfg))
        end)
    end

    local function _loadCfg()
        pcall(function()
            if isfolder and isfile and isfolder(_CFG_FOLDER) and isfile(_CFG_FILE) then
                local raw = readfile(_CFG_FILE)
                local ok, data = pcall(function() return _Http:JSONDecode(raw) end)
                if ok and type(data) == "table" then
                    _cfg = data
                end
            end
        end)
    end
    _loadCfg()

    Window:Tag({
        Title = "Premium v1.17.5",
        Icon = "solar:crown-line-bold",
        Color = Color3.fromRGB(190, 140, 255),
        Border = true,
    })

    local _changelogGui = nil
    local _changelogVisible = false
    local _showCard = nil
    local _hideCard = nil
    local function createChangelogUI()
        if _changelogGui then
            return
        end
        local gui = Instance.new("ScreenGui")
        gui.Name = "LSHub_Changelog"
        gui.DisplayOrder = 10000
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Enabled = false
        gui.Parent = PlayerGui

        local card = Instance.new("Frame")
        card.Name = "Card"
        card.Size = UDim2.new(0, 340, 0, 480)
        card.Position = UDim2.new(1, 460, 0.5, 0)
        card.AnchorPoint = Vector2.new(1, 0.5)
        card.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        card.BackgroundTransparency = 0
        card.BorderSizePixel = 0
        card.ZIndex = 2
        card.Parent = gui
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)
        local cs = Instance.new("UIStroke", card)
        cs.Color = Color3.fromRGB(50, 50, 50)
        cs.Thickness = 1
        cs.Transparency = 0
        local sizeConstraint = Instance.new("UISizeConstraint", card)
        sizeConstraint.MinSize = Vector2.new(260, 360)
        sizeConstraint.MaxSize = Vector2.new(380, 560)
        local sheen = Instance.new("Frame")
        sheen.Size = UDim2.new(0.4, 0, 0, 1)
        sheen.Position = UDim2.new(0.3, 0, 0, 0)
        sheen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sheen.BackgroundTransparency = 0.75
        sheen.BorderSizePixel = 0
        sheen.ZIndex = 10
        sheen.Parent = card
        Instance.new("UICorner", sheen).CornerRadius = UDim.new(1, 0)

        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 46)
        header.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
        header.BackgroundTransparency = 0
        header.BorderSizePixel = 0
        header.ZIndex = 3
        header.Parent = card
        Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)
        local hfix = Instance.new("Frame")
        hfix.Size = UDim2.new(1, 0, 0, 16)
        hfix.Position = UDim2.new(0, 0, 1, -16)
        hfix.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
        hfix.BackgroundTransparency = 0
        hfix.BorderSizePixel = 0
        hfix.ZIndex = 3
        hfix.Parent = header
        local hline = Instance.new("Frame")
        hline.Size = UDim2.new(1, -24, 0, 1)
        hline.Position = UDim2.new(0, 12, 1, -1)
        hline.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        hline.BackgroundTransparency = 0
        hline.BorderSizePixel = 0
        hline.ZIndex = 4
        hline.Parent = header
        local title = Instance.new("TextLabel")
        title.Text = "Changelog"
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.TextColor3 = Color3.fromRGB(230, 230, 230)
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, -52, 1, 0)
        title.Position = UDim2.new(0, 16, 0, 0)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 4
        title.Parent = header

        local closeBtn = Instance.new("TextButton")
        closeBtn.Text = "✕"
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 12
        closeBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
        closeBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        closeBtn.BackgroundTransparency = 0
        closeBtn.Size = UDim2.fromOffset(28, 28)
        closeBtn.Position = UDim2.new(1, -40, 0.5, 0)
        closeBtn.AnchorPoint = Vector2.new(0, 0.5)
        closeBtn.BorderSizePixel = 0
        closeBtn.ZIndex = 4
        closeBtn.Parent = header
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 7)
        local closeBtnStroke = Instance.new("UIStroke", closeBtn)
        closeBtnStroke.Color = Color3.fromRGB(50, 50, 50)
        closeBtnStroke.Transparency = 0
        closeBtnStroke.Thickness = 1

        local scroll = Instance.new("ScrollingFrame")
        scroll.Name = "Content"
        scroll.Size = UDim2.new(1, -20, 1, -58)
        scroll.Position = UDim2.new(0, 10, 0, 52)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70)
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.ZIndex = 3
        scroll.Parent = card
        local layout = Instance.new("UIListLayout", scroll)
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        local pad = Instance.new("UIPadding", scroll)
        pad.PaddingTop = UDim.new(0, 4)
        pad.PaddingBottom = UDim.new(0, 10)
        pad.PaddingLeft = UDim.new(0, 2)
        pad.PaddingRight = UDim.new(0, 2)

        local function getIcon(change)
            if change:sub(1, 3) == "[+]" then
                return "+ ", Color3.fromRGB(190, 190, 190), change:sub(5)
            elseif change:sub(1, 3) == "[/]" then
                return "/ ", Color3.fromRGB(130, 130, 130), change:sub(5)
            elseif change:sub(1, 3) == "[-]" then
                return "- ", Color3.fromRGB(90, 90, 90), change:sub(5)
            else
                return "• ", Color3.fromRGB(120, 120, 120), change
            end
        end

        local function addVersionBlock(version, date, changes)
            local block = Instance.new("Frame")
            block.Size = UDim2.new(1, 0, 0, 0)
            block.AutomaticSize = Enum.AutomaticSize.Y
            block.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
            block.BackgroundTransparency = 0
            block.BorderSizePixel = 0
            block.ZIndex = 4
            block.LayoutOrder = #scroll:GetChildren()
            block.Parent = scroll
            Instance.new("UICorner", block).CornerRadius = UDim.new(0, 10)
            local bs = Instance.new("UIStroke", block)
            bs.Color = Color3.fromRGB(38, 38, 38)
            bs.Transparency = 0
            bs.Thickness = 1
            local bpad = Instance.new("UIPadding", block)
            bpad.PaddingLeft = UDim.new(0, 12)
            bpad.PaddingRight = UDim.new(0, 12)
            bpad.PaddingTop = UDim.new(0, 10)
            bpad.PaddingBottom = UDim.new(0, 10)
            local bloc = Instance.new("UIListLayout", block)
            bloc.Padding = UDim.new(0, 5)
            bloc.SortOrder = Enum.SortOrder.LayoutOrder

            local vRow = Instance.new("Frame")
            vRow.Size = UDim2.new(1, 0, 0, 20)
            vRow.BackgroundTransparency = 1
            vRow.ZIndex = 5
            vRow.LayoutOrder = 0
            vRow.Parent = block
            local vLabel = Instance.new("TextLabel")
            vLabel.Text = version
            vLabel.Font = Enum.Font.GothamBold
            vLabel.TextSize = 13
            vLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
            vLabel.BackgroundTransparency = 1
            vLabel.Size = UDim2.new(0.55, 0, 1, 0)
            vLabel.TextXAlignment = Enum.TextXAlignment.Left
            vLabel.ZIndex = 5
            vLabel.Parent = vRow
            local dLabel = Instance.new("TextLabel")
            dLabel.Text = date
            dLabel.Font = Enum.Font.Gotham
            dLabel.TextSize = 11
            dLabel.TextColor3 = Color3.fromRGB(90, 90, 90)
            dLabel.BackgroundTransparency = 1
            dLabel.Size = UDim2.new(0.45, 0, 1, 0)
            dLabel.Position = UDim2.new(0.55, 0, 0, 0)
            dLabel.TextXAlignment = Enum.TextXAlignment.Right
            dLabel.ZIndex = 5
            dLabel.Parent = vRow

            local div = Instance.new("Frame")
            div.Size = UDim2.new(1, 0, 0, 1)
            div.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
            div.BackgroundTransparency = 0
            div.BorderSizePixel = 0
            div.ZIndex = 5
            div.LayoutOrder = 1
            div.Parent = block

            for i, change in ipairs(changes) do
                local prefix, prefixCol, text = getIcon(change)
                local rowFrame = Instance.new("Frame")
                rowFrame.Size = UDim2.new(1, 0, 0, 0)
                rowFrame.AutomaticSize = Enum.AutomaticSize.Y
                rowFrame.BackgroundTransparency = 1
                rowFrame.ZIndex = 5
                rowFrame.LayoutOrder = i + 1
                rowFrame.Parent = block
                local rowLayout = Instance.new("UIListLayout", rowFrame)
                rowLayout.FillDirection = Enum.FillDirection.Horizontal
                rowLayout.VerticalAlignment = Enum.VerticalAlignment.Top
                rowLayout.Padding = UDim.new(0, 0)
                rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
                local prefixLbl = Instance.new("TextLabel")
                prefixLbl.Text = prefix
                prefixLbl.Font = Enum.Font.GothamBold
                prefixLbl.TextSize = 11
                prefixLbl.TextColor3 = prefixCol
                prefixLbl.BackgroundTransparency = 1
                prefixLbl.Size = UDim2.new(0, 14, 0, 18)
                prefixLbl.TextXAlignment = Enum.TextXAlignment.Left
                prefixLbl.ZIndex = 5
                prefixLbl.LayoutOrder = 0
                prefixLbl.Parent = rowFrame
                local row = Instance.new("TextLabel")
                row.Text = text
                row.Font = Enum.Font.Gotham
                row.TextSize = 11
                row.TextColor3 = Color3.fromRGB(180, 180, 180)
                row.BackgroundTransparency = 1
                row.Size = UDim2.new(1, -14, 0, 0)
                row.AutomaticSize = Enum.AutomaticSize.Y
                row.TextWrapped = true
                row.TextXAlignment = Enum.TextXAlignment.Left
                row.ZIndex = 5
                row.LayoutOrder = 1
                row.Parent = rowFrame
            end
        end
        addVersionBlock("v1.14", "May 18, 2026", {
            "[+] Auto Weather — fire UFO/Witch/Bacon/Flood/Phantom events, multi-select & auto loop",
            "[+] Sell by Mutation — sell items by selected mutation (Once & Auto loop)",
            "[+] Webhook Filter by Mutation — filter webhook notif by mutation type",
            "[/] Webhook now includes Mutation field in embed",
            "[/] Webhook monitor uses KickEvent cache for accurate mutation detection",
            "[/] Backpack Monitor now shows mutation per item (reads from Handle attribute)",
            "[/] Backpack Monitor tracks same-name items with different mutations separately",
            "[+] Eternal rarity added to rarity order (above Celestial)",
            "[+] Eternal rarity color added to Webhook embed colors",
            "[/] Dupe x2 Kick toggle now marked Locked (patched)",
        })
        addVersionBlock("v1.04", "May 12, 2026", {
            "[+] Upgrade Brainrot tab — Upgrade All At Once & Auto Upgrade with mode/slot selection",
            "[+] Gacha Panel — external draggable UI showing brainrot name & rarity color",
            "[+] Show Panel toggle below Auto Kick",
            "[/] Skip Rarity",
            "[/] Cancel & Respawn works even when Auto Kick is off",
            "[/] Rarity colors updated to match in-game colors",
            "[/] Reduced notify spam",
            "[+] Added Luxvs Method v2 — upgraded walk method with forced TP detection, wait-for-wave lock & anti-cutscene",
            "[+] Added Luxvs Method (original) back — simple stable walk, lowest risk, no extra features",
            "[/] Select Method dropdown now has 3 options: Luxvs Method, Luxvs Method v2, Tween Method",
            "[/] Note section now shows color-coded risk level per method (green/yellow/red)",
        })
        addVersionBlock("v1.03", "May 11, 2026", {
            "[+] Auto Rejoin on Kick (detects server kick, not crash)",
            "[+] Ping Display — live floating ping label with color indicator",
            "[+] Stats tab with Session Timer",
            "[+] Live Backpack Monitor — shows all items grouped by rarity",
        })
        addVersionBlock("v1.02", "May 11, 2026", {
            "[+] Sell by Rarity section",
            "[+] Rarity dropdown",
            "[+] Sell by Rarity (Once) button",
            "[+] Auto Sell by Rarity toggle",
            "[/] Webhook fixed",
            "[/] Webhook rarity colors fix",
        })


        local TweenService  = game:GetService("TweenService")
        local FINAL_POS     = UDim2.new(1, -20, 0.5, 0)
        local HIDDEN_POS    = UDim2.new(1, 460, 0.5, 0)

        local _strokeActive = true
        local strokeCycle   = {
            Color3.fromRGB(50, 50, 50),
            Color3.fromRGB(100, 100, 100),
            Color3.fromRGB(50, 50, 50),
        }
        local function loopStroke(idx)
            if not _strokeActive then return end
            local next = (idx % #strokeCycle) + 1
            local t = TweenService:Create(cs,
                TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { Color = strokeCycle[next] }
            )
            t.Completed:Once(function() loopStroke(next) end)
            t:Play()
        end
        loopStroke(1)

        _showCard = function()
            gui.Enabled = true
            _changelogVisible = true
            card.Position = HIDDEN_POS
            TweenService:Create(card,
                TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                { Position = FINAL_POS }
            ):Play()
        end

        _hideCard = function()
            _changelogVisible = false
            local t = TweenService:Create(card,
                TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                { Position = HIDDEN_POS }
            )
            t.Completed:Once(function()
                gui.Enabled = false
            end)
            t:Play()
        end

        closeBtn.MouseButton1Click:Connect(function()
            _hideCard()
        end)

        _changelogGui = gui
    end
    local TopbarButton1 = Window.Topbar:Button({
        Icon = "solar:danger-square-bold",
        IconSize = 22,
        Callback = function()
            createChangelogUI()
            if _changelogVisible then
                _hideCard()
            else
                _showCard()
            end
        end,
    })

    task.delay(1.5, createChangelogUI)
    typingSequence(function(text)
        if Window.SetAuthor then
            Window:SetAuthor(text)
        else
            Window:SetTitle("Luxvs Community | " .. text)
        end
    end)
    InitializeIcon()

    local S = {
        _realName          = LocalPlayer.Name,
        _acLastCamCFrame   = nil,
        _acInputActive     = false,
        _acFixed           = false,
        _acConn            = nil,
        _acInputBeganConn  = nil,
        _acInputEndedConn  = nil,
        _cbConn            = nil,
        autoEnabled        = false,
        loopConn           = nil,
        _lastMove          = 0,
        _lastRemote        = 0,
        _lastJump          = 0,
        _arrived           = false,
        targetPos          = Vector3.new(696, 3, 232),
        tweenTargetPos     = Vector3.new(699, 3, 232),

        godmodeConn        = nil,
        _godCharConn       = nil,
        _godHum            = nil,

        kickMode           = _cfg.kickMode or "Luxvs Method",
        kickArg1           = _cfg.kickArg1 ~= nil and _cfg.kickArg1 or 1,
        kickArg2           = _cfg.kickArg2 ~= nil and _cfg.kickArg2 or 1,
        _tweenObj          = nil,
        tweenSpeed         = _cfg.tweenSpeed or 150,
        waveLeadDist       = _cfg.waveLead or 150,
        _lastTweenTarget   = nil,

        rebirthInterval    = _cfg.rebirthInterval or 3,
        _minRebirthLevel   = _cfg.minRebirthLevel or 0,

        _blindGui          = nil,

        waitPos            = Vector3.new(687, 2, 234),
        waveTriggerDist    = 150,

        autoSellAll        = false,
        _sellAllConn       = nil,

        autoSellByRarity   = false,
        _sellRarityConn    = nil,

        autoSellByMutation = false,
        _sellMutationConn  = nil,

        autoClaimOffline   = false,
        _claimOfflineConn  = nil,

        autoX2             = false,
        autoX2Full         = false,
        _autoX2SpawnConn   = nil,
        _autoX2ClickConn   = nil,

        autoSkip           = false,
        keepMutations      = {},
        keepEventMutations = {},
        keepBrainrots      = {},
        _lastBrainrot      = "Unknown",
        _rarityConn        = nil,
        _brainrotConn      = nil,
        _skipInProgress    = false,
        _lastBrainrotAt    = 0,
        _pendingSkipName   = nil,
        _gachaWaiting      = false,
        _gachaWaitingSince = 0,
        _autoFarmToggle    = nil,

        collectTP          = false,
        loopDelay          = _cfg.loopDelay or 30,


        _panelGui           = nil,
        _panelEnabled       = false,
        _panelNameLabel     = nil,
        _panelRarityLabel   = nil,
        _panelMutationLabel = nil,
        _panelStatusLabel   = nil,
        _panelRarityDot     = nil,
        _panelConn          = nil,
    }

    local about = Window:Tab({
        Title = "Luxvs Community",
        Icon = "solar:verified-check-bold",
        IconColor = Color3.fromHex("#3245f7"),
    })
    local MainCore = Window:Section({
        Title = "Main Core",
    })
    local MainTab = MainCore:Tab({
        Title = "Dashboard",
        Icon = "solar:home-angle-bold",
        IconColor = Color3.fromHex("#7EB8E8"),

    })
    local ColTab = MainCore:Tab({
        Title = "Collector",
        Icon = "solar:box-minimalistic-bold-duotone",
        IconColor = Color3.fromHex("#C07830"),

    })
    local UpgradeTab = MainCore:Tab({
        Title     = "Upgrading",
        Icon      = "solar:ranking-bold-duotone",
        IconColor = Color3.fromHex("#A078E8"),

    })
    local MainSec = MainTab:Section({
        Title  = "Main Features",
        Icon   = "solar:home-angle-bold-duotone",
        Box    = true,
        Opened = false
    })
    local SkipSec = MainSec:Section({
        Title  = "Keep Rarity & Mutations",
        Icon   = "solar:skip-next-bold-duotone",
        Box    = true,
        Opened = false
    })
    MainSec:Space({
        Columns = 0.5
    })
    local TweenSec = MainSec:Section({
        Title  = "Tween Settings",
        Icon   = "solar:settings-minimalistic-bold-duotone",
        Box    = true,
        Opened = false
    })
    MainTab:Space({
        Columns = 0.5
    })
    local ClaimSec = MainTab:Section({
        Title  = "Claim Offline",
        Icon   = "solar:inbox-in-bold-duotone",
        Box    = true,
        Opened = false
    })
    MainTab:Space({
        Columns = 0.5
    })

    do
        local sec = MainTab:Section({
            Title  = "Auto Dupe x2",
            Icon   = "solar:copy-bold-duotone",
            Box    = true,
            Opened = false,
        })

        local on = false
        sec:Toggle({
            Title = "Dupe x2 Kick",
            Desc = "Patched",
            Default = false,
            Callback = function(v)
                on = v
                if v then
                    task.spawn(function()
                        local R = ReplicatedStorage.Shared.Packages.Network.rev_TaviMishkal
                        while on do
                            pcall(function()
                                R:FireServer()
                            end)
                            task.wait(0.1)
                        end
                    end)
                    WindUI:Notify({
                        Title = "Dupe x2",
                        Content = "Enabled",
                        Duration = 2
                    })
                else
                    WindUI:Notify({
                        Title = "Dupe x2",
                        Content = "Disabled",
                        Duration = 2
                    })
                end
            end,
        })
    end
    MainTab:Space({
        Columns = 0.5
    })
    do
        local sec = MainTab:Section({
            Title  = "Auto Click x2",
            Icon   = "solar:double-alt-arrow-up-bold-duotone",
            Box    = true,
            Opened = false,
        })
        local on = false
        local connections = {}
        local claimed = {}
        local function tryClaimBonus(obj)
            if obj.Name ~= "Bonus" then
                return
            end
            if claimed[obj] then
                return
            end
            claimed[obj] = true
            pcall(firesignal, obj.MouseButton1Click)
            pcall(firesignal, obj.Activated)
            pcall(function()
                for _, c in pairs(getconnections(obj.InputBegan)) do
                    c:Fire({
                        UserInputType = Enum.UserInputType.MouseButton1,
                        UserInputState = Enum.UserInputState.Begin,
                    }, false)
                end
            end)
            task.delay(1, function()
                claimed[obj] = nil
            end)
        end
        local function startAuto()
            local R = ReplicatedStorage
                .Shared.Packages.Network.rev_TaviMishkal

            for _, obj in pairs(PlayerGui:GetDescendants()) do
                tryClaimBonus(obj)
            end

            connections[# connections + 1] = PlayerGui.DescendantAdded:Connect(tryClaimBonus)

            connections[# connections + 1] = task.spawn(function()
                while on do
                    pcall(function()
                        R:FireServer()
                    end)
                    task.wait(0.1)
                end
            end)
        end
        local function stopAuto()
            on = false
            for _, c in pairs(connections) do
                if typeof(c) == "RBXScriptConnection" then
                    c:Disconnect()
                end
            end
            table.clear(connections)
            table.clear(claimed)
        end
        sec:Toggle({
            Title = "Auto Click x2",
            Default = false,
            Callback = function(v)
                on = v
                if v then
                    startAuto()
                    WindUI:Notify({
                        Title = "Auto Click x2",
                        Content = "Enabled",
                        Duration = 2
                    })
                else
                    stopAuto()
                    WindUI:Notify({
                        Title = "Auto Click x2",
                        Content = "Disabled",
                        Duration = 2
                    })
                end
            end,
        })
        sec:Space({
            Columns = 0.5
        })

        local autoWeightOn = false
        local _autoWeightThread = nil

        local WEIGHT_NAMES = {
            "Bone Barbell",
            "Stone Block",
            "Copper Plate",
            "Iron Plate",
            "Ice Barbell",
            "Donut Barbell",
            "Golden Barbell",
            "Heaven Plate",
            "Mega Golden Barbell",
            "Neon Pulse",
            "Giant Gold Star Barbell",
            "Emerald Barbell",
        }

        local WEIGHT_RANK = {}
        for i, name in ipairs(WEIGHT_NAMES) do
            WEIGHT_RANK[name] = i
        end
        local function findWeightTool()
            local char = LocalPlayer.Character
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            local bestTool = nil
            local bestRank = 0

            if char then
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        local rank = WEIGHT_RANK[tool.Name]
                        if rank and rank > bestRank then
                            bestRank = rank
                            bestTool = tool
                        end
                    end
                end
            end

            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        local rank = WEIGHT_RANK[tool.Name]
                        if rank and rank > bestRank then
                            bestRank = rank
                            bestTool = tool
                        end
                    end
                end
            end
            return bestTool
        end
        local function equipAndStartX2()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hum then
                WindUI:Notify({
                    Title = "Auto Weight",
                    Content = "Character not found",
                    Duration = 2
                })
                return false
            end
            local tool = findWeightTool()
            if not tool then
                WindUI:Notify({
                    Title = "Auto Weight",
                    Content = "No weight in backpack!",
                    Duration = 3
                })
                return false
            end
            pcall(function()
                hum:EquipTool(tool)
            end)
            task.wait(0.3)
            WindUI:Notify({
                Title = "Auto Weight",
                Content = "Equipped: " .. tool.Name,
                Duration = 2
            })
            return true
        end
        sec:Toggle({
            Title = "Auto Weight",
            Default = false,
            Callback = function(v)
                autoWeightOn = v
                if v then
                    _autoWeightThread = task.spawn(function()
                        local equipped = equipAndStartX2()
                        if not equipped then
                            autoWeightOn = false
                            return
                        end
                        on = true
                        startAuto()
                        WindUI:Notify({
                            Title = "Auto Weight",
                            Content = "Enabled",
                            Duration = 2
                        })

                        while autoWeightOn do
                            task.wait(2)
                            local char = LocalPlayer.Character
                            if not char then
                                task.wait(2)
                                continue
                            end
                            local stillEquipped = false
                            for _, tool in ipairs(char:GetChildren()) do
                                if tool:IsA("Tool") and WEIGHT_RANK[tool.Name] then
                                    stillEquipped = true
                                    break
                                end
                            end
                            if not stillEquipped then
                                equipAndStartX2()
                            end
                        end
                    end)
                else
                    autoWeightOn = false
                    _autoWeightThread = nil
                    if on then
                        on = false
                        stopAuto()
                    end
                    WindUI:Notify({
                        Title = "Auto Weight",
                        Content = "Disabled",
                        Duration = 2
                    })
                end
            end,
        })

        local _enableMoveConn = nil
        sec:Toggle({
            Title = "Enable Move",
            Icon = "solar:alt-arrow-right-bold",
            Default = false,
            Callback = function(v)
                if v then
                    _enableMoveConn = RunService.Heartbeat:Connect(function()
                        local char = LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp and hrp.Anchored then
                            hrp.Anchored = false
                        end
                    end)
                else
                    if _enableMoveConn then
                        _enableMoveConn:Disconnect()
                        _enableMoveConn = nil
                    end
                end
            end,
        })
    end
    MainTab:Space({
        Columns = 0.5
    })
    do
        local WeatherEvent           = ReplicatedStorage.Shared.Packages.Network:FindFirstChild("rev_WeatherUpdate")
            or ReplicatedStorage.Shared.Packages.Network:FindFirstChild("rev_AddedWeather")
            or ReplicatedStorage:FindFirstChild("rev_sbe", true)

        local WeatherSec             = MainTab:Section({
            Title  = "Weather",
            Icon   = "solar:cloud-storm-bold-duotone",
            Box    = true,
            Opened = false,
        })

        -- Dynamic fetch dari SacrificeData.Recipes (sama kayak goonline)
        local WEATHER_EVENTS         = {}
        pcall(function()
            local SacrificeData = ReplicatedStorage.Shared.Data.SacrificeData
            if SacrificeData and SacrificeData.Recipes then
                for eventName, _ in pairs(SacrificeData.Recipes) do
                    table.insert(WEATHER_EVENTS, { Title = eventName, value = eventName })
                end
            end
        end)
        -- Fallback kalau fetch gagal
        if #WEATHER_EVENTS == 0 then
            WEATHER_EVENTS = {
                { Title = "Phantom Event", value = "PHANTOM" },
                { Title = "Bacon Event",   value = "BACON" },
                { Title = "Flood Event",   value = "FLOOD" },
                { Title = "Void Event",    value = "VOID" },
            }
        end

        local _selectedWeatherEvents = {}
        local _autoWeather           = false
        local _weatherIdx            = 1

        local _titleToValue          = {}
        local _dropdownValues        = {}
        for _, e in ipairs(WEATHER_EVENTS) do
            _titleToValue[e.Title] = e.value
            table.insert(_dropdownValues, { Title = e.Title })
        end

        local _weatherDropReady = false
        WeatherSec:Dropdown({
            Title    = "Select Event",
            Multi    = true,
            Values   = _dropdownValues,
            Callback = function(selected)
                if not _weatherDropReady then
                    _weatherDropReady = true
                    return
                end
                _selectedWeatherEvents = {}
                for key, v in pairs(selected) do
                    local title = type(v) == "table" and v.Title or key
                    if _titleToValue[title] then
                        table.insert(_selectedWeatherEvents, _titleToValue[title])
                    end
                end
                _weatherIdx = 1
            end,
        })

        local function _fireWeatherOnce()
            if #_selectedWeatherEvents == 0 then
                WindUI:Notify({
                    Title    = "Auto Weather",
                    Duration = 2,
                })
                return
            end
            if not WeatherEvent then
                WeatherEvent = ReplicatedStorage:FindFirstChild("rev_sbe", true)
            end
            if not WeatherEvent then
                WindUI:Notify({
                    Title    = "Auto Weather",
                    Content  = "Remote not found!",
                    Duration = 3,
                })
                return
            end
            if _weatherIdx > #_selectedWeatherEvents then
                _weatherIdx = 1
            end
            local eventValue = _selectedWeatherEvents[_weatherIdx]
            pcall(function()
                WeatherEvent:FireServer(eventValue)
            end)
            _weatherIdx = (_weatherIdx % #_selectedWeatherEvents) + 1
        end

        WeatherSec:Toggle({
            Title    = "Auto Weather",
            Default  = false,
            Callback = function(v)
                _autoWeather = v
                if v then
                    task.spawn(function()
                        while _autoWeather do
                            _fireWeatherOnce()
                            task.wait(3)
                        end
                    end)
                    WindUI:Notify({
                        Title    = "Auto Weather",
                        Content  = "Enabled",
                        Duration = 2,
                    })
                else
                    WindUI:Notify({
                        Title    = "Auto Weather",
                        Content  = "Disabled",
                        Duration = 2,
                    })
                end
            end,
        })

        WeatherSec:Button({
            Title    = "Fire Once",
            Icon     = "solar:bolt-circle-bold-duotone",
            Callback = function()
                _fireWeatherOnce()
            end,
        })
    end
    MainTab:Space({
        Columns = 0.5
    })
    do
        local RebirthEvent = ReplicatedStorage.Shared.Packages.Network.rev_RebirthRequest
        local rebirthSec = MainTab:Section({
            Title = "Auto Rebirth",
            Icon = "solar:restart-bold",
            Box = true,
            Opened = false,
        })

        local function getPlayerLevel()
            local ok, lvl = pcall(function()
                local ls = LocalPlayer:FindFirstChild("leaderstats")
                if ls then
                    for _, v in ipairs(ls:GetChildren()) do
                        local n = v.Name:lower()
                        if n == "level" or n == "lvl" then return v.Value end
                    end
                end
                return nil
            end)
            return (ok and type(lvl) == "number") and lvl or nil
        end

        rebirthSec:Button({
            Title = "Rebirth Once",
            Icon = "solar:restart-bold",
            Callback = function()
                local ok, err = pcall(function()
                    RebirthEvent:FireServer()
                end)
                if ok then
                    WindUI:Notify({ Title = "Rebirth", Content = "Done!", Duration = 2 })
                else
                    WindUI:Notify({ Title = "Rebirth", Content = "Failed: " .. tostring(err), Duration = 3 })
                end
            end,
        })

        rebirthSec:Slider({
            Title    = "Rebirth Interval",
            Desc     = "Delay between each rebirth (seconds)",
            Step     = 1,
            Value    = { Min = 1, Max = 60, Default = S.rebirthInterval },
            Callback = function(val)
                S.rebirthInterval = val
                _cfg.rebirthInterval = val
                _saveCfg()
            end,
        })

        rebirthSec:Input({
            Title       = "Min Level to Rebirth",
            Placeholder = "0 = always rebirth",
            Callback    = function(v)
                if v == nil or v == "" then return end
                local num = tonumber(v)
                if num and num >= 0 then
                    S._minRebirthLevel = math.floor(num)
                    _cfg.minRebirthLevel = S._minRebirthLevel
                    _saveCfg()
                    WindUI:Notify({
                        Title    = "Min Level",
                        Content  = num == 0 and "Always rebirth" or ("Rebirth if lvl ≥ " .. num),
                        Duration = 2,
                    })
                else
                    WindUI:Notify({ Title = "Min Level", Content = "Invalid input.", Duration = 2 })
                end
            end,
        })

        local autoRebirthOn = false
        local _autoRebirthThread = nil
        rebirthSec:Toggle({
            Title    = "Auto Rebirth Loop",
            Default  = _cfg.autoRebirth or false,
            Callback = function(v)
                autoRebirthOn = v
                _cfg.autoRebirth = v
                _saveCfg()
                if v then
                    _autoRebirthThread = task.spawn(function()
                        while autoRebirthOn do
                            local lvl    = getPlayerLevel()
                            local minLvl = S._minRebirthLevel or 0
                            if minLvl <= 0 or (lvl and lvl >= minLvl) then
                                pcall(function() RebirthEvent:FireServer() end)
                            end
                            task.wait(S.rebirthInterval)
                        end
                    end)
                    WindUI:Notify({ Title = "Auto Rebirth", Content = "Enabled", Duration = 2 })
                else
                    _autoRebirthThread = nil
                    WindUI:Notify({ Title = "Auto Rebirth", Content = "Disabled", Duration = 2 })
                end
            end,
        })
    end
    local ColSec = ColTab:Section({
        Title  = "Collect Money",
        Icon   = "solar:wallet-money-bold-duotone",
        Box    = true,
        Opened = false
    })
    local ColSec2 = ColSec:Section({
        Title  = "Collect On TP",
        Icon   = "solar:map-arrow-right-bold-duotone",
        Box    = true,
        Opened = false
    })

    local function getOurPlot()
        for i = 1, 30 do
            local plot = workspace.Plots:FindFirstChild("Plot" .. i)
            if plot then
                local label = plot:FindFirstChild("Decorations") and plot.Decorations:FindFirstChild("PlotOwner") and
                    plot.Decorations.PlotOwner:FindFirstChild("OwnerGUI") and
                    plot.Decorations.PlotOwner.OwnerGUI:FindFirstChild("TextLabel")
                if label and label.Text == S._realName then
                    return plot
                end
            end
        end
        return nil
    end

    ColSec2:Slider({
        Title    = "Loop Delay (seconds)",
        Step     = 1,
        Value    = { Min = 10, Max = 60, Default = S.loopDelay },
        Callback = function(val)
            S.loopDelay = math.floor(val)
            _cfg.loopDelay = S.loopDelay
            _saveCfg()
        end,
    })

    ColSec2:Toggle({
        Title    = "Collect TP",
        Default  = false,
        Callback = function(v)
            S.collectTP = v
            WindUI:Notify({
                Title    = "Collect TP",
                Content  = v and "On" or "Off",
                Duration = 2,
            })
            if v then
                task.spawn(function()
                    local ourPlot = nil
                    for _ = 1, 10 do
                        if not S.collectTP then break end
                        ourPlot = getOurPlot()
                        if ourPlot then break end
                        task.wait(1)
                    end
                    if not ourPlot then
                        WindUI:Notify({
                            Title    = "Collect TP",
                            Content  = "No plot found!",
                            Duration = 3,
                        })
                        S.collectTP = false
                        return
                    end
                    while S.collectTP do
                        ourPlot = getOurPlot() or ourPlot
                        if not ourPlot then
                            task.wait(1)
                            continue
                        end
                        for i = 1, 30 do
                            if not S.collectTP then break end
                            local char     = LocalPlayer.Character
                            local hrp      = char and char:FindFirstChild("HumanoidRootPart")
                            local slotPart = ourPlot.Buttons:FindFirstChild("Slot" .. i)
                            if hrp and slotPart then
                                hrp.Anchored = true
                                hrp.CFrame   = CFrame.new(slotPart.Position + Vector3.new(0, 3, 0))
                                task.wait(0.15)
                                hrp.Anchored = false
                                task.wait(0.1)
                            end
                            pcall(function()
                                CollectEvent:FireServer(i)
                            end)
                            task.wait(0.1)
                        end
                        WindUI:Notify({
                            Title    = "Collect TP",
                            Content  = "Done! Wait " .. S.loopDelay .. "s",
                            Duration = 3,
                        })
                        task.wait(S.loopDelay)
                    end
                end)
            end
        end,
    })

    local function cacheGodHum()
        local char = LocalPlayer.Character
        S._godHum = char and char:FindFirstChildOfClass("Humanoid")
        if S._godHum then
            S._godHum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            S._godHum.BreakJointsOnDeath = false
        end
    end
    local function startGodMode()
        if S.godmodeConn then
            return
        end
        cacheGodHum()
        S._godCharConn = LocalPlayer.CharacterAdded:Connect(function()
            task.wait()
            cacheGodHum()
        end)
        S.godmodeConn = RunService.Heartbeat:Connect(function()
            local h = S._godHum
            if not (h and h.Parent) then
                return
            end
            if h.Health < h.MaxHealth then
                h.Health = h.MaxHealth
            end
        end)
    end
    local function stopGodMode()
        if S.godmodeConn then
            S.godmodeConn:Disconnect()
            S.godmodeConn = nil
        end
        if S._godCharConn then
            S._godCharConn:Disconnect()
            S._godCharConn = nil
        end
        local h = S._godHum
        if h and h.Parent then
            h:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            h.BreakJointsOnDeath = true
        end
        S._godHum = nil
    end

    local function buildBlindGui()
        local sg = Instance.new("ScreenGui")
        sg.Name = "WaveBlind"
        sg.IgnoreGuiInset = true
        sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.RobloxLocked = true
        local frame = Instance.new("Frame", sg)
        frame.Size = UDim2.fromScale(1, 1)
        frame.BackgroundColor3 = Color3.new(0, 0, 0)
        frame.BorderSizePixel = 0
        frame.ZIndex = 999
        frame.RobloxLocked = true
        local label = Instance.new("TextLabel", sg)
        label.Size = UDim2.new(1, 0, 0, 30)
        label.Position = UDim2.new(0, 0, 0.5, -30)
        label.AnchorPoint = Vector2.new(0, 0.5)
        label.BackgroundTransparency = 1
        label.Text = "Safe Mode by Luxvs"
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 22
        label.ZIndex = 1000
        label.RobloxLocked = true
        local desc = Instance.new("TextLabel", sg)
        desc.Size = UDim2.new(1, 0, 0, 20)
        desc.Position = UDim2.new(0, 0, 0.5, 10)
        desc.AnchorPoint = Vector2.new(0, 0.5)
        desc.BackgroundTransparency = 1
        desc.Text = ""
        desc.TextColor3 = Color3.fromRGB(180, 180, 180)
        desc.TextTransparency = 1
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 13
        desc.ZIndex = 1000
        desc.RobloxLocked = true
        local messages = {
            "Sorry for the blur, protecting this method from the devs...",
            "Safe Mode enabled...",
        }
        sg.Parent = LocalPlayer.PlayerGui
        S._blindGui = sg

        task.spawn(function()
            while sg and sg.Parent do
                if not sg.Enabled then
                    task.wait(0.1)
                else
                    for i = 1, 30 do
                        if not (sg.Parent and sg.Enabled) then
                            break
                        end
                        local t = 1 - (i / 20)
                        label.TextTransparency = t
                        task.wait(0.05)
                    end
                    task.wait(5)

                    for i = 1, 30 do
                        if not (sg.Parent and sg.Enabled) then
                            break
                        end
                        local t = i / 20
                        label.TextTransparency = t
                        task.wait(0.05)
                    end
                    task.wait(0.4)
                end
            end
        end)

        task.spawn(function()
            local index = 1
            while sg and sg.Parent do
                if not sg.Enabled then
                    task.wait(0.1)
                else
                    desc.TextTransparency = 1
                    desc.Text = messages[index]

                    for i = 1, 15 do
                        if not (sg.Parent and sg.Enabled) then
                            break
                        end
                        desc.TextTransparency = 1 - (i / 15)
                        task.wait(0.03)
                    end
                    task.wait(3)

                    for i = 1, 15 do
                        if not (sg.Parent and sg.Enabled) then
                            break
                        end
                        desc.TextTransparency = i / 15
                        task.wait(0.03)
                    end
                    index = index + 1
                    if index > # messages then
                        index = 1
                    end
                    task.wait(0.2)
                end
            end
        end)
        return sg
    end
    local function setBlind(on)
        if on then
            if not S._blindGui or not S._blindGui.Parent then
                buildBlindGui()
            end
            S._blindGui.Enabled = true
        else
            if S._blindGui and S._blindGui.Parent then
                S._blindGui.Enabled = false
            end
        end
    end


    local function attachGuard(sg)
        sg.DescendantRemoving:Connect(function()
            if not S.autoEnabled then
                return
            end
            task.defer(function()
                if S._blindGui == sg then
                    buildBlindGui()
                    S._blindGui.Enabled = true
                end
            end)
        end)
        sg:GetPropertyChangedSignal("Name"):Connect(function()
            if not S.autoEnabled then
                return
            end
            task.defer(function()
                if S._blindGui == sg then
                    buildBlindGui()
                    S._blindGui.Enabled = true
                end
            end)
        end)
    end
    local _origBuild = buildBlindGui
    buildBlindGui = function()
        local sg = _origBuild()
        attachGuard(sg)
        return sg
    end
    LocalPlayer.PlayerGui.DescendantRemoving:Connect(function(inst)
        if not S.autoEnabled then
            return
        end
        if inst == S._blindGui then
            task.defer(function()
                buildBlindGui()
                S._blindGui.Enabled = true
            end)
        end
    end)

    local ALL_BRAINROTS = {
        { name = "Waterdino",                  rarity = "Epic" },
        { name = "Pannaburro",                 rarity = "Epic" },
        { name = "67",                         rarity = "Mythic" },
        { name = "Gattatino Nyanino",          rarity = "Epic" },
        { name = "Mangolini Parrocini",        rarity = "Epic" },
        { name = "Rinooccio Verdini",          rarity = "Mythic" },
        { name = "Anpali Babel",               rarity = "Celestial" },
        { name = "Ta Ta Ta Ta Sahur",          rarity = "Rare" },
        { name = "Karkerkar Kurkur",           rarity = "OG" },
        { name = "Elefantucci Bananucci",      rarity = "Legendary" },
        { name = "Ketchuru Matsuru",           rarity = "Exclusive" },
        { name = "Fruli Frula",                rarity = "Common" },
        { name = "Meowl",                      rarity = "OG" },
        { name = "SWAG SODA",                  rarity = "Hacked" },
        { name = "Brr Brr Patapim",            rarity = "Rare" },
        { name = "Tictac Sahur",               rarity = "Hacked" },
        { name = "Rexosaurus",                 rarity = "Divine" },
        { name = "Alessio",                    rarity = "Hacked" },
        { name = "Pot Hotspot",                rarity = "Celestial" },
        { name = "Talpa Di Fero",              rarity = "Common" },
        { name = "Professora 67",              rarity = "Eternal" },
        { name = "Penguino Cocosino",          rarity = "Mythic" },
        { name = "Kicky",                      rarity = "Eternal" },
        { name = "Salamino Pinguino",          rarity = "Legendary" },
        { name = "Gorillo Watermelondrillo",   rarity = "Secret" },
        { name = "Bobrito Bandito",            rarity = "Rare" },
        { name = "Cocofanto Elefanto",         rarity = "Secret" },
        { name = "Spaghetti Tualetti",         rarity = "Exclusive" },
        { name = "Astro Tim",                  rarity = "Eternal" },
        { name = "W or L",                     rarity = "Exclusive" },
        { name = "Krupuk Pagi Pagi",           rarity = "Celestial" },
        { name = "Los Nooo My Hotspotsitos",   rarity = "Exclusive" },
        { name = "Cappuccino Assassino",       rarity = "Rare" },
        { name = "Castlino Fortini",           rarity = "Exclusive" },
        { name = "Octopusini Bluberini",       rarity = "Godly" },
        { name = "Mastodontico Telepiedone",   rarity = "Celestial" },
        { name = "Compactoroni Diskaloni",     rarity = "OG" },
        { name = "Boneca Ambalabu",            rarity = "Rare" },
        { name = "Stoppo Luminino",            rarity = "Hacked" },
        { name = "Bottellini",                 rarity = "Exclusive" },
        { name = "Rhino Toasterino",           rarity = "Godly" },
        { name = "John Pork",                  rarity = "Epic" },
        { name = "Bambu Sahur",                rarity = "Exclusive" },
        { name = "Cactus Pingu",               rarity = "Hacked" },
        { name = "Espresso Signora",           rarity = "Divine" },
        { name = "Agarrini La Palini",         rarity = "Hacked" },
        { name = "Svinina Bombardino",         rarity = "Common" },
        { name = "Tralaledon",                 rarity = "Celestial" },
        { name = "Beluga Beluga",              rarity = "Celestial" },
        { name = "Chicleteira Bicicleteira",   rarity = "Celestial" },
        { name = "Zibra Zubra Zibralini",      rarity = "Secret" },
        { name = "Trulimero Trulicina",        rarity = "Legendary" },
        { name = "Noobini Pizzanini",          rarity = "Common" },
        { name = "Guerriro Digitale",          rarity = "Celestial" },
        { name = "Capi Taco",                  rarity = "Legendary" },
        { name = "Cacto Hipopotamo",           rarity = "Rare" },
        { name = "Burguro",                    rarity = "Secret" },
        { name = "Dragonfrutina Dolphinita",   rarity = "Celestial" },
        { name = "Los Primos Blue",            rarity = "Hacked" },
        { name = "Madung",                     rarity = "Epic" },
        { name = "Elefanto Frigo",             rarity = "Mythic" },
        { name = "Bombardiro Crocodilo",       rarity = "Godly" },
        { name = "Corn Sahur",                 rarity = "OG" },
        { name = "Esok Sekolah",               rarity = "Exclusive" },
        { name = "Tripi Tropi Tropa Tripa",    rarity = "Hacked" },
        { name = "Crazylone Pizaione",         rarity = "OG" },
        { name = "Bangello",                   rarity = "Mythic" },
        { name = "Dragon Cannelloni",          rarity = "Exclusive" },
        { name = "Bombini Gusini",             rarity = "Secret" },
        { name = "Chimpanzini Bananini",       rarity = "Legendary" },
        { name = "Tralalerita Tralala",        rarity = "Divine" },
        { name = "Cappuccino Clownino",        rarity = "OG" },
        { name = "Chillin Chilli",             rarity = "OG" },
        { name = "Nuclearo Dinossauro",        rarity = "OG" },
        { name = "Blackhole Goat",             rarity = "OG" },
        { name = "Bambini Crostini",           rarity = "Legendary" },
        { name = "Tim Cheese",                 rarity = "Common" },
        { name = "Frigo Camelo",               rarity = "Godly" },
        { name = "Ketupat Kepat",              rarity = "Eternal" },
        { name = "Ballerina Cappuccina",       rarity = "Rare" },
        { name = "Torrtuginni Dragonfrutini",  rarity = "Hacked" },
        { name = "Gangster Footera",           rarity = "Rare" },
        { name = "Pesto Mortioni",             rarity = "Epic" },
        { name = "Los Primos",                 rarity = "Celestial" },
        { name = "1x1x1x1",                    rarity = "Divine" },
        { name = "Udin Din Din Dun",           rarity = "Godly" },
        { name = "Pipi Kiwi",                  rarity = "Common" },
        { name = "Dipperi Chiperini",          rarity = "Divine" },
        { name = "Plan Blue",                  rarity = "Legendary" },
        { name = "Tralalero Tralala",          rarity = "Divine" },
        { name = "Peant Jarro",                rarity = "Divine" },
        { name = "Chef Crabracadabra",         rarity = "Mythic" },
        { name = "Girafa Celeste",             rarity = "Divine" },
        { name = "Strawberelli Flamingelli",   rarity = "Godly" },
        { name = "Cavallo Virtuso",            rarity = "Secret" },
        { name = "Guest666",                   rarity = "Secret" },
        { name = "Orcalero",                   rarity = "Epic" },
        { name = "Fryuro",                     rarity = "Secret" },
        { name = "Tuff Toucan",                rarity = "Secret" },
        { name = "Bananita Dolphinita",        rarity = "Legendary" },
        { name = "Orangutini Ananasini",       rarity = "Godly" },
        { name = "La Vacca Saturno Saturnita", rarity = "Hacked" },
        { name = "Sigma Boy",                  rarity = "Godly" },
        { name = "Pandaccini Bananini",        rarity = "Godly" },
        { name = "Trippi Troppi",              rarity = "Common" },
        { name = "W",                          rarity = "Exclusive" },
        { name = "Burbaloni Luliloli",         rarity = "Mythic" },
        { name = "Capybara Eggplant",          rarity = "Mythic" },
        { name = "Matteo",                     rarity = "Divine" },
        { name = "Baba Yaga",                  rarity = "Eternal" },
        { name = "Glorbo Fruttodrillo",        rarity = "Mythic" },
        { name = "Strawberry Elephant",        rarity = "OG" },
        { name = "Plan Red",                   rarity = "Legendary" },
        { name = "Lirili Larila",              rarity = "Common" },
        { name = "Garamararam",                rarity = "Epic" },
    }
    local Network = ReplicatedStorage.Shared.Packages.Network
    local NORMAL_MUTATION_VALUES = {
        normal = true,
        none = true,
        ["nil"] = true,
        ["false"] = true,
    }
    local REGULAR_MUTATIONS = {
        gold = true,
        golden = true,
        diamond = true,
        plasma = true,
        molten = true,
        radioactive = true,
        shadow = true,
        electrified = true,
        rainbow = true,
        astral = true,
        volcanic = true,
    }
    local EVENT_MUTATIONS = {
        wet = true,
        alien = true,
        bacon = true,
        virus = true,
        void = true,
        enchanted = true,
        phantom = true,
    }

    local function normalizeMutation(mutation)
        if mutation == nil or mutation == false then
            return ""
        end
        local text = tostring(mutation):match("^%s*(.-)%s*$")
        local lower = string.lower(text)
        return NORMAL_MUTATION_VALUES[lower] and "" or lower
    end

    local function isRegularMutation(mutation)
        return REGULAR_MUTATIONS[normalizeMutation(mutation)] == true
    end

    local function isEventMutation(mutation)
        return EVENT_MUTATIONS[normalizeMutation(mutation)] == true
    end

    local function shouldSkip(brainrotName, mutation)
        if not S.autoSkip then
            return false
        end
        local normalizedMutation = normalizeMutation(mutation)
        local hasMutation = normalizedMutation ~= ""
        if hasMutation then
            if isRegularMutation(mutation) and S.keepMutations and S.keepMutations[normalizedMutation] then
                return false
            end
            if isEventMutation(mutation) and S.keepEventMutations and S.keepEventMutations[normalizedMutation] then
                return false
            end
        end
        if next(S.keepBrainrots) == nil then
            return true
        end
        if S.keepBrainrots[brainrotName] then
            return false
        end
        return true
    end
    local function doSkip(name)
        if S._skipInProgress then
            return
        end
        S._skipInProgress = true
        WindUI:Notify({
            Title = "Skip",
            Content = name .. " → respawning",
            Duration = 2,
        })
        S.autoEnabled = false
        S._arrived = false
        setBlind(false)
        if S._autoFarmToggle then
            S._autoFarmToggle:Set(false)
        end
        stopGodMode()
        S._gachaWaiting = false
        S._pendingSkipName = nil
        if S._brainrotConn then
            S._brainrotConn:Disconnect()
            S._brainrotConn = nil
        end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Parent then
            hum.Health = 0
        end
        local charReceived = false
        local charConn
        charConn = LocalPlayer.CharacterAdded:Connect(function()
            charReceived = true
            charConn:Disconnect()
        end)
        local t0 = tick()
        while not charReceived and tick() - t0 < 30 do
            task.wait(0.1)
        end
        charConn:Disconnect()
        task.wait(0.4)
        S._lastBrainrot = "Unknown"
        S._skipInProgress = false
        S._lastBrainrotAt = 0
        S._gachaWaitingSince = 0
        S.autoEnabled = true
        S._arrived = false
        S._lastMove = 0
        S._lastRemote = 0
        S._lastJump = 0
        if S._autoFarmToggle then
            S._autoFarmToggle:Set(true)
        end
    end
    local TransformedEvent = Network.rev_Transformed

    local PANEL_RARITY_COLORS = {
        Common    = Color3.fromHex("#B0B0B0"),
        Rare      = Color3.fromHex("#4A7FD4"),
        Epic      = Color3.fromHex("#3DBD8A"),
        Legendary = Color3.fromHex("#D4A82A"),
        Mythic    = Color3.fromHex("#8B1A2A"),
        Exclusive = Color3.fromHex("#FF4ECD"),
        Godly     = Color3.fromHex("#A07840"),
        Secret    = Color3.fromHex("#707070"),
        Divine    = Color3.fromHex("#C03040"),
        Hacked    = Color3.fromHex("#50E020"),
        OG        = Color3.fromHex("#D42020"),
        Celestial = Color3.fromHex("#D4C060"),
        Eternal   = Color3.fromHex("#B060E0"),
    }
    local BRAINROT_RARITY_LOOKUP = {}
    for _, entry in ipairs(ALL_BRAINROTS) do
        BRAINROT_RARITY_LOOKUP[entry.name] = entry.rarity
    end
    local PANEL_MUTATION_COLORS = {
        Normal      = Color3.fromRGB(200, 200, 200),
        Gold        = Color3.fromRGB(255, 240, 180),
        Golden      = Color3.fromRGB(255, 240, 180),
        Diamond     = Color3.fromRGB(200, 245, 255),
        Plasma      = Color3.fromRGB(255, 200, 255),
        Molten      = Color3.fromRGB(255, 210, 180),
        Radioactive = Color3.fromRGB(220, 255, 180),
        Shadow      = Color3.fromRGB(210, 205, 230),
        Electrified = Color3.fromRGB(200, 250, 255),
        Rainbow     = Color3.fromRGB(255, 210, 245),
        Wet         = Color3.fromRGB(185, 210, 255),
        Alien       = Color3.fromRGB(255, 190, 250),
        Bacon       = Color3.fromRGB(255, 215, 185),
        Virus       = Color3.fromRGB(200, 255, 195),
        Void        = Color3.fromRGB(210, 180, 240),
        Enchanted   = Color3.fromRGB(235, 225, 250),
        Astral      = Color3.fromRGB(220, 215, 255),
        Phantom     = Color3.fromRGB(200, 215, 235),
        Volcanic    = Color3.fromRGB(255, 190, 130),
    }
    local PANEL_MUTATION_STROKE = {
        Normal      = Color3.fromRGB(90, 90, 90),
        Gold        = Color3.fromRGB(220, 165, 0),
        Golden      = Color3.fromRGB(220, 165, 0),
        Diamond     = Color3.fromRGB(0, 180, 230),
        Plasma      = Color3.fromRGB(200, 0, 220),
        Molten      = Color3.fromRGB(220, 70, 0),
        Radioactive = Color3.fromRGB(100, 210, 0),
        Shadow      = Color3.fromRGB(50, 45, 70),
        Electrified = Color3.fromRGB(0, 210, 240),
        Rainbow     = Color3.fromRGB(200, 0, 180),
        Wet         = Color3.fromRGB(30, 80, 210),
        Alien       = Color3.fromRGB(210, 0, 190),
        Bacon       = Color3.fromRGB(210, 80, 0),
        Virus       = Color3.fromRGB(20, 185, 10),
        Void        = Color3.fromRGB(70, 10, 110),
        Enchanted   = Color3.fromRGB(150, 120, 200),
        Astral      = Color3.fromRGB(100, 80, 220),
        Phantom     = Color3.fromRGB(80, 100, 160),
        Volcanic    = Color3.fromRGB(200, 55, 0),
    }

    local function createGachaPanel()
        if S._panelGui and S._panelGui.Parent then
            S._panelGui:Destroy()
        end

        local gui                                        = Instance.new("ScreenGui")
        gui.Name                                         = "LSHub_GachaPanel"
        gui.DisplayOrder                                 = 9998
        gui.ResetOnSpawn                                 = false
        gui.ZIndexBehavior                               = Enum.ZIndexBehavior.Sibling
        gui.IgnoreGuiInset                               = true
        gui.Enabled                                      = false
        gui.Parent                                       = PlayerGui

        local card                                       = Instance.new("Frame")
        card.Name                                        = "Card"
        card.Size                                        = UDim2.new(0.32, 0, 0, 140)
        card.Position                                    = UDim2.new(1, -10, 0.20, 0)
        card.AnchorPoint                                 = Vector2.new(1, 0)
        local sizeConstraint                             = Instance.new("UISizeConstraint", card)
        sizeConstraint.MinSize                           = Vector2.new(175, 130)
        sizeConstraint.MaxSize                           = Vector2.new(235, 155)
        card.BackgroundColor3                            = Color3.fromRGB(10, 10, 10)
        card.BackgroundTransparency                      = 0
        card.BorderSizePixel                             = 0
        card.ZIndex                                      = 2
        card.Parent                                      = gui
        Instance.new("UICorner", card).CornerRadius      = UDim.new(0, 14)
        local cardStroke                                 = Instance.new("UIStroke", card)
        cardStroke.Color                                 = Color3.fromRGB(45, 45, 45)
        cardStroke.Thickness                             = 1
        cardStroke.Transparency                          = 0
        local sheen                                      = Instance.new("Frame")
        sheen.Size                                       = UDim2.new(0.4, 0, 0, 1)
        sheen.Position                                   = UDim2.new(0.3, 0, 0, 0)
        sheen.BackgroundColor3                           = Color3.fromRGB(255, 255, 255)
        sheen.BackgroundTransparency                     = 0.78
        sheen.BorderSizePixel                            = 0
        sheen.ZIndex                                     = 10
        sheen.Parent                                     = card
        Instance.new("UICorner", sheen).CornerRadius     = UDim.new(1, 0)

        local header                                     = Instance.new("Frame")
        header.Name                                      = "Header"
        header.Size                                      = UDim2.new(1, 0, 0, 34)
        header.BackgroundColor3                          = Color3.fromRGB(16, 16, 16)
        header.BackgroundTransparency                    = 0
        header.BorderSizePixel                           = 0
        header.ZIndex                                    = 3
        header.Parent                                    = card
        Instance.new("UICorner", header).CornerRadius    = UDim.new(0, 14)
        local hfix                                       = Instance.new("Frame")
        hfix.Size                                        = UDim2.new(1, 0, 0, 14)
        hfix.Position                                    = UDim2.new(0, 0, 1, -14)
        hfix.BackgroundColor3                            = Color3.fromRGB(16, 16, 16)
        hfix.BackgroundTransparency                      = 0
        hfix.BorderSizePixel                             = 0
        hfix.ZIndex                                      = 3
        hfix.Parent                                      = header
        local hline                                      = Instance.new("Frame")
        hline.Name                                       = "HeaderLine"
        hline.Size                                       = UDim2.new(1, -18, 0, 1)
        hline.Position                                   = UDim2.new(0, 9, 1, -1)
        hline.BackgroundColor3                           = Color3.fromRGB(40, 40, 40)
        hline.BackgroundTransparency                     = 0
        hline.BorderSizePixel                            = 0
        hline.ZIndex                                     = 4
        hline.Parent                                     = header
        local titleLabel                                 = Instance.new("TextLabel")
        titleLabel.Text                                  = "LUXVS PANEL"
        titleLabel.Font                                  = Enum.Font.GothamBold
        titleLabel.TextSize                              = 10
        titleLabel.TextColor3                            = Color3.fromRGB(120, 120, 120)
        titleLabel.BackgroundTransparency                = 1
        titleLabel.Size                                  = UDim2.new(1, -12, 1, 0)
        titleLabel.Position                              = UDim2.new(0, 12, 0, 0)
        titleLabel.TextXAlignment                        = Enum.TextXAlignment.Left
        titleLabel.ZIndex                                = 4
        titleLabel.Parent                                = header
        local headerDot                                  = Instance.new("Frame")
        headerDot.Name                                   = "HeaderDot"
        headerDot.Size                                   = UDim2.fromOffset(5, 5)
        headerDot.Position                               = UDim2.new(1, -12, 0.5, 0)
        headerDot.AnchorPoint                            = Vector2.new(0, 0.5)
        headerDot.BackgroundColor3                       = Color3.fromRGB(60, 60, 60)
        headerDot.BorderSizePixel                        = 0
        headerDot.ZIndex                                 = 5
        headerDot.Parent                                 = header
        Instance.new("UICorner", headerDot).CornerRadius = UDim.new(1, 0)

        local body                                       = Instance.new("Frame")
        body.Size                                        = UDim2.new(1, -22, 1, -44)
        body.Position                                    = UDim2.new(0, 11, 0, 38)
        body.BackgroundTransparency                      = 1
        body.ZIndex                                      = 3
        body.Parent                                      = card
        local bodyLayout                                 = Instance.new("UIListLayout", body)
        bodyLayout.Padding                               = UDim.new(0, 5)
        bodyLayout.SortOrder                             = Enum.SortOrder.LayoutOrder
        bodyLayout.FillDirection                         = Enum.FillDirection.Vertical

        local nameLabel                                  = Instance.new("TextLabel")
        nameLabel.Name                                   = "NameLabel"
        nameLabel.Text                                   = "Wait for kick..."
        nameLabel.Font                                   = Enum.Font.GothamBold
        nameLabel.TextSize                               = 13
        nameLabel.TextColor3                             = Color3.fromRGB(235, 235, 235)
        nameLabel.BackgroundTransparency                 = 1
        nameLabel.Size                                   = UDim2.new(1, 0, 0, 18)
        nameLabel.TextXAlignment                         = Enum.TextXAlignment.Left
        nameLabel.TextTruncate                           = Enum.TextTruncate.AtEnd
        nameLabel.ZIndex                                 = 4
        nameLabel.LayoutOrder                            = 0
        nameLabel.Parent                                 = body

        local rarityRow                                  = Instance.new("Frame")
        rarityRow.Size                                   = UDim2.new(1, 0, 0, 16)
        rarityRow.BackgroundTransparency                 = 1
        rarityRow.ZIndex                                 = 4
        rarityRow.LayoutOrder                            = 1
        rarityRow.Parent                                 = body

        local dot                                        = Instance.new("Frame")
        dot.Name                                         = "RarityDot"
        dot.Size                                         = UDim2.fromOffset(5, 5)
        dot.Position                                     = UDim2.new(0, 0, 0.5, 0)
        dot.AnchorPoint                                  = Vector2.new(0, 0.5)
        dot.BackgroundColor3                             = Color3.fromRGB(60, 60, 60)
        dot.BorderSizePixel                              = 0
        dot.ZIndex                                       = 5
        dot.Parent                                       = rarityRow
        Instance.new("UICorner", dot).CornerRadius       = UDim.new(1, 0)

        local rarityLabel                                = Instance.new("TextLabel")
        rarityLabel.Name                                 = "RarityLabel"
        rarityLabel.Text                                 = "—"
        rarityLabel.Font                                 = Enum.Font.Gotham
        rarityLabel.TextSize                             = 11
        rarityLabel.TextColor3                           = Color3.fromRGB(140, 140, 140)
        rarityLabel.BackgroundTransparency               = 1
        rarityLabel.Size                                 = UDim2.new(1, -14, 1, 0)
        rarityLabel.Position                             = UDim2.new(0, 14, 0, 0)
        rarityLabel.TextXAlignment                       = Enum.TextXAlignment.Left
        rarityLabel.ZIndex                               = 5
        rarityLabel.Parent                               = rarityRow

        local mutationRow                                = Instance.new("Frame")
        mutationRow.Name                                 = "MutationRow"
        mutationRow.Size                                 = UDim2.new(1, 0, 0, 16)
        mutationRow.BackgroundTransparency               = 1
        mutationRow.ClipsDescendants                     = true
        mutationRow.ZIndex                               = 4
        mutationRow.LayoutOrder                          = 2
        mutationRow.Parent                               = body
        local mutRowLayout                               = Instance.new("UIListLayout", mutationRow)
        mutRowLayout.FillDirection                       = Enum.FillDirection.Horizontal
        mutRowLayout.VerticalAlignment                   = Enum.VerticalAlignment.Center
        mutRowLayout.SortOrder                           = Enum.SortOrder.LayoutOrder
        mutRowLayout.Padding                             = UDim.new(0, 0)
        local mutPrefix                                  = Instance.new("TextLabel")
        mutPrefix.Name                                   = "MutPrefix"
        mutPrefix.Text                                   = "Mutation: "
        mutPrefix.Font                                   = Enum.Font.Gotham
        mutPrefix.TextSize                               = 11
        mutPrefix.TextColor3                             = Color3.fromRGB(120, 120, 120)
        mutPrefix.BackgroundTransparency                 = 1
        mutPrefix.Size                                   = UDim2.new(0, 0, 1, 0)
        mutPrefix.AutomaticSize                          = Enum.AutomaticSize.X
        mutPrefix.TextXAlignment                         = Enum.TextXAlignment.Left
        mutPrefix.ZIndex                                 = 4
        mutPrefix.LayoutOrder                            = 0
        mutPrefix.Parent                                 = mutationRow
        local mutationLabel                              = Instance.new("TextLabel")
        mutationLabel.Name                               = "MutationLabel"
        mutationLabel.Text                               = "—"
        mutationLabel.Font                               = Enum.Font.GothamBold
        mutationLabel.TextSize                           = 11
        mutationLabel.TextColor3                         = Color3.fromRGB(235, 235, 235)
        mutationLabel.BackgroundTransparency             = 1
        mutationLabel.Size                               = UDim2.new(1, 0, 1, 0)
        mutationLabel.TextXAlignment                     = Enum.TextXAlignment.Left
        mutationLabel.TextTruncate                       = Enum.TextTruncate.AtEnd
        mutationLabel.ZIndex                             = 4
        mutationLabel.LayoutOrder                        = 1
        mutationLabel.Parent                             = mutationRow
        local mutStroke                                  = Instance.new("UIStroke")
        mutStroke.Name                                   = "MutStroke"
        mutStroke.Color                                  = Color3.fromRGB(80, 80, 80)
        mutStroke.Thickness                              = 1.2
        mutStroke.Transparency                           = 0
        mutStroke.Parent                                 = mutationLabel

        local divider                                    = Instance.new("Frame")
        divider.Size                                     = UDim2.new(1, 0, 0, 1)
        divider.BackgroundColor3                         = Color3.fromRGB(28, 28, 28)
        divider.BackgroundTransparency                   = 0
        divider.BorderSizePixel                          = 0
        divider.ZIndex                                   = 4
        divider.LayoutOrder                              = 3
        divider.Parent                                   = body

        local statusLabel                                = Instance.new("TextLabel")
        statusLabel.Name                                 = "StatusLabel"
        statusLabel.Text                                 = "Status: OFF"
        statusLabel.Font                                 = Enum.Font.GothamBold
        statusLabel.TextSize                             = 11
        statusLabel.TextColor3                           = Color3.fromRGB(90, 90, 90)
        statusLabel.BackgroundTransparency               = 1
        statusLabel.Size                                 = UDim2.new(1, 0, 0, 16)
        statusLabel.TextXAlignment                       = Enum.TextXAlignment.Left
        statusLabel.TextTruncate                         = Enum.TextTruncate.AtEnd
        statusLabel.ZIndex                               = 4
        statusLabel.LayoutOrder                          = 4
        statusLabel.Parent                               = body

        S._panelGui                                      = gui
        S._panelNameLabel                                = nameLabel
        S._panelRarityLabel                              = rarityLabel
        S._panelMutationLabel                            = mutationLabel
        S._panelStatusLabel                              = statusLabel
        S._panelRarityDot                                = dot

        card.InputBegan:Connect(function(input)
            local isTouch = input.UserInputType == Enum.UserInputType.Touch
            local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
            if not (isTouch or isMouse) then return end
            local dragStart = input.Position
            local startPos  = card.Position
            local didMove   = false
            local dragging  = true
            local function applyDrag(cur)
                if not dragging then return end
                if not didMove and (cur - dragStart).Magnitude > 5 then didMove = true end
                if didMove then
                    local d = cur - dragStart
                    card.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + d.X,
                        startPos.Y.Scale, startPos.Y.Offset + d.Y)
                end
            end
            local function stopDrag() dragging = false end
            if isTouch then
                local mc, ec
                mc = input.Changed:Connect(function() applyDrag(input.Position) end)
                ec = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        mc:Disconnect(); ec:Disconnect(); stopDrag()
                    end
                end)
            else
                local mc, ec
                mc = UserInputService.InputChanged:Connect(function(m)
                    if m.UserInputType == Enum.UserInputType.MouseMovement then applyDrag(m.Position) end
                end)
                ec = UserInputService.InputEnded:Connect(function(e)
                    if e.UserInputType == Enum.UserInputType.MouseButton1 then
                        mc:Disconnect(); ec:Disconnect(); stopDrag()
                    end
                end)
            end
        end)

        return gui
    end

    local function formatMutation(mutation)
        if mutation == nil then
            return "Normal"
        end
        local text = tostring(mutation):match("^%s*(.-)%s*$")
        return text ~= "" and text or "Normal"
    end

    local function updateGachaPanel(brainrotName, mutation)
        if not S._panelEnabled then return end
        if not (S._panelGui and S._panelGui.Parent) then return end
        local rarity    = BRAINROT_RARITY_LOOKUP[brainrotName] or "Unknown"
        local col       = PANEL_RARITY_COLORS[rarity] or Color3.fromRGB(150, 150, 150)
        local mut       = formatMutation(mutation)
        local mutCol    = PANEL_MUTATION_COLORS[mut] or Color3.fromRGB(210, 210, 210)
        local mutStroke = PANEL_MUTATION_STROKE[mut] or Color3.fromRGB(80, 80, 80)
        if S._panelNameLabel then S._panelNameLabel.Text = brainrotName end
        if S._panelRarityLabel then
            S._panelRarityLabel.Text       = rarity
            S._panelRarityLabel.TextColor3 = col
        end
        if S._panelMutationLabel then
            S._panelMutationLabel.Text       = mut
            S._panelMutationLabel.TextColor3 = mutCol
            local stroke                     = S._panelMutationLabel:FindFirstChildOfClass("UIStroke")
            if stroke then
                TweenService:Create(stroke,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { Color = mutStroke }
                ):Play()
            end
        end
        if S._panelStatusLabel then
            if not S.autoSkip then
                S._panelStatusLabel.Text = "Status: OFF"
                S._panelStatusLabel.TextColor3 = Color3.fromRGB(90, 90, 90)
            elseif shouldSkip(brainrotName, mutation) then
                S._panelStatusLabel.Text = "Status: SKIP"
                S._panelStatusLabel.TextColor3 = Color3.fromRGB(210, 80, 80)
            else
                S._panelStatusLabel.Text = "Status: KEEP"
                S._panelStatusLabel.TextColor3 = Color3.fromRGB(80, 200, 110)
            end
        end
        if S._panelRarityDot then
            TweenService:Create(S._panelRarityDot,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { BackgroundColor3 = col }
            ):Play()
        end
        local card = S._panelGui and S._panelGui:FindFirstChild("Card")
        if card then
            local hdr = card:FindFirstChild("Header")
            if hdr then
                local hdot = hdr:FindFirstChild("HeaderDot")
                local hln  = hdr:FindFirstChild("HeaderLine")
                if hdot then
                    TweenService:Create(hdot,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { BackgroundColor3 = col }
                    ):Play()
                end
                if hln then
                    TweenService:Create(hln,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { BackgroundColor3 = col }
                    ):Play()
                end
            end
        end
    end

    local function startPanelListener()
        if S._panelConn then return end
        S._panelConn = Network.rev_KickEvent.OnClientEvent:Connect(function(_, brainrotData)
            if type(brainrotData) ~= "table" then return end
            local data = brainrotData[1] or brainrotData
            local name = data.Name
            if not name then return end
            updateGachaPanel(name, data.Mutation)
        end)
    end

    local function stopPanelListener()
        if S._panelConn then
            S._panelConn:Disconnect()
            S._panelConn = nil
        end
    end

    local function startSkipListeners()
        if S._rarityConn then return end

        -- cache Debris sekali, pakai ChildAdded kalau belum ada (no polling)
        local _debrisRef = workspace:FindFirstChild("Debris")
        if not _debrisRef then
            S._debrisWatcher = workspace.ChildAdded:Connect(function(child)
                if child.Name == "Debris" then
                    _debrisRef = child
                    S._debrisWatcher:Disconnect()
                    S._debrisWatcher = nil
                end
            end)
        end

        local function connectDebrisSkip()
            if S._brainrotConn then
                S._brainrotConn:Disconnect()
                S._brainrotConn = nil
            end
            local conn
            conn = _debrisRef.ChildAdded:Connect(function(child)
                if child.Name ~= S._pendingSkipName then return end
                conn:Disconnect()
                conn = nil
                if S._skipInProgress then return end
                if not S.autoEnabled then return end
                local skip = S._pendingSkipName
                S._pendingSkipName = nil
                doSkip(skip)
            end)
            S._brainrotConn = conn
        end

        S._rarityConn = Network.rev_KickEvent.OnClientEvent:Connect(function(score, brainrotData, _extra)
            if not S.autoEnabled then return end
            if S._skipInProgress then return end
            if type(brainrotData) ~= "table" then return end
            local data = brainrotData[1] or brainrotData
            local name = data.Name
            if not name then return end
            S._lastBrainrot = name
            S._gachaWaiting = true
            S._gachaWaitingSince = tick()
            local _keepToken = S._gachaWaitingSince
            if not shouldSkip(name, data.Mutation) then
                S._pendingSkipName = nil
                S._gachaWaiting = false
                return
            end
            S._pendingSkipName = name

            if _debrisRef then
                connectDebrisSkip()
            else
                task.spawn(function()
                    local t0 = tick()
                    while not _debrisRef and tick() - t0 < 10 do
                        task.wait()
                    end
                    if not _debrisRef then
                        S._pendingSkipName = nil
                        S._gachaWaiting = false
                        return
                    end
                    connectDebrisSkip()
                end)
            end
        end)
    end

    local function stopSkipListeners()
        if S._rarityConn then
            S._rarityConn:Disconnect()
            S._rarityConn = nil
        end
        if S._brainrotConn then
            S._brainrotConn:Disconnect()
            S._brainrotConn = nil
        end
        if S._debrisWatcher then
            S._debrisWatcher:Disconnect()
            S._debrisWatcher = nil
        end
        S._lastBrainrot = "Unknown"
        S._lastBrainrotAt = 0
        S._skipInProgress = false
        S._gachaWaiting = false
        S._pendingSkipName = nil
    end

    local _acMovementKeys = {
        [Enum.KeyCode.W] = true,
        [Enum.KeyCode.A] = true,
        [Enum.KeyCode.S] = true,
        [Enum.KeyCode.D] = true,
        [Enum.KeyCode.Up] = true,
        [Enum.KeyCode.Down] = true,
        [Enum.KeyCode.Left] = true,
        [Enum.KeyCode.Right] = true,
    }


    local function startWatchdog()
        if getgenv().__lshub_watchdog then
            pcall(function() getgenv().__lshub_watchdog:Disconnect() end)
        end
        local _wdLastPos           = nil
        local _wdLastCheck         = tick()
        getgenv().__lshub_watchdog = RunService.Heartbeat:Connect(function()
            if not S.autoEnabled then return end
            if tick() - _wdLastCheck < 5 then return end
            _wdLastCheck = tick()
            local char   = LocalPlayer.Character
            local hrp    = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local curPos = hrp.Position
            local dist   = (curPos - S.targetPos).Magnitude
            if _wdLastPos
                and (curPos - _wdLastPos).Magnitude < 1
                and dist > 8
                and not S._gachaWaiting
                and not S._skipInProgress then
                warn("[Watchdog] Stuck terdeteksi, restart loop...")
                WindUI:Notify({ Title = "Watchdog", Content = "Stuck! Restarting...", Duration = 3 })
                stopLoop()
                task.wait(0.5)
                if S.autoEnabled then startLoop() end
                _wdLastPos = nil
                return
            end
            _wdLastPos = curPos
        end)
    end
    local function stopWatchdog()
        if getgenv().__lshub_watchdog then
            pcall(function() getgenv().__lshub_watchdog:Disconnect() end)
            getgenv().__lshub_watchdog = nil
        end
    end

    local function startLoop()
        if getgenv().__lshub_loop_conn then
            pcall(function() getgenv().__lshub_loop_conn:Disconnect() end)
            getgenv().__lshub_loop_conn = nil
        end
        if S.loopConn then
            S.loopConn:Disconnect()
            S.loopConn = nil
        end
        S._arrived          = false
        S._lastMove         = 0
        S._lastRemote       = 0
        S._lastJump         = 0

        local char0         = LocalPlayer.Character
        local hum0          = char0 and char0:FindFirstChild("Humanoid")
        if hum0 then
            hum0.MoveToFinished:Connect(function(reached)
                if not reached and S.autoEnabled and not S._arrived then
                    S._lastMove = 0
                end
            end)
        end
        S.loopConn = RunService.Heartbeat:Connect(function()
            if not S.autoEnabled then
                return
            end
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChild("Humanoid")
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not (hum and hrp) then
                return
            end
            local dist = (hrp.Position - S.targetPos).Magnitude

            if S._gachaWaiting and tick() - S._gachaWaitingSince > 30 then
                S._gachaWaiting = false
                S._pendingSkipName = nil
            end

            local _safeToAct = dist <= 5 or not S._gachaWaiting

            if S.kickMode == "Tween Method" then
                local waves = workspace:FindFirstChild("Waves")
                local closestRoot = nil
                local closestDist = math.huge
                if waves then
                    for _, wave in ipairs(waves:GetChildren()) do
                        local root = wave:FindFirstChild("RootPart")
                        if root then
                            local d = (hrp.Position - root.Position).Magnitude
                            if d < closestDist then
                                closestDist = d
                                closestRoot = root
                            end
                        end
                    end
                end

                local distToFinal = (hrp.Position - S.tweenTargetPos).Magnitude
                local dynamicTarget
                if distToFinal < S.waveLeadDist or not closestRoot then
                    dynamicTarget = S.tweenTargetPos
                else
                    local dir = S.tweenTargetPos - closestRoot.Position
                    dir = Vector3.new(dir.X, 0, dir.Z)
                    dir = dir.Magnitude > 0 and dir.Unit or Vector3.new(0, 0, -1)
                    dynamicTarget = Vector3.new(
                        closestRoot.Position.X + dir.X * S.waveLeadDist, hrp.Position.Y,
                        closestRoot.Position.Z + dir.Z * S.waveLeadDist)
                end
                local dynDist = (hrp.Position - dynamicTarget).Magnitude
                local targetMoved = S._lastTweenTarget == nil or
                    (Vector3.new(S._lastTweenTarget.X, 0, S._lastTweenTarget.Z) - Vector3.new(dynamicTarget.X, 0, dynamicTarget.Z))
                    .Magnitude > 3
                if dynDist > 5 then
                    if not _safeToAct then return end
                    S._arrived = false
                    local tweenIdle = not S._tweenObj or S._tweenObj.PlaybackState ~= Enum.PlaybackState.Playing
                    if tweenIdle or targetMoved then
                        if S._tweenObj then
                            S._tweenObj:Cancel()
                            S._tweenObj = nil
                            hrp.Anchored = false
                        end
                        S._lastTweenTarget = dynamicTarget
                        local moveDist = (hrp.Position - dynamicTarget).Magnitude
                        local duration = math.max(0.3, moveDist / S.tweenSpeed)
                        hrp.Anchored = true
                        S._tweenObj = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                            CFrame = CFrame.new(dynamicTarget) * (hrp.CFrame - hrp.Position)
                        })
                        S._tweenObj.Completed:Connect(function()
                            hrp.Anchored = false
                        end)
                        S._tweenObj:Play()
                    end
                else
                    if S._tweenObj then
                        S._tweenObj:Cancel()
                        S._tweenObj = nil
                        hrp.Anchored = false
                    end
                    S._lastTweenTarget = nil
                    if not S._arrived then
                        S._arrived = true
                        startGodMode()
                    end
                    if tick() - S._lastRemote > 1.5 then
                        S._lastRemote = tick()
                        local _arg1 = S.kickArg1 ~= nil and S.kickArg1 or 1
                        local _arg2 = S.kickArg2 ~= nil and S.kickArg2 or 1
                        pcall(function()
                            Event:FireServer(_arg1, _arg2)
                        end)
                    end
                end
            else
                if hrp.Anchored then
                    hrp.Anchored = false
                end
                local waves = workspace:FindFirstChild("Waves")
                if waves then
                    local tooClose = false
                    for _, wave in ipairs(waves:GetChildren()) do
                        local root = wave:FindFirstChild("RootPart")
                        if root and (hrp.Position - root.Position).Magnitude <= 130 then
                            tooClose = true
                            break
                        end
                    end
                    setBlind(tooClose)
                else
                    setBlind(false)
                end
                if dist > 5 then
                    if not _safeToAct then return end
                    S._arrived = false
                    if tick() - S._lastMove > 0.4 then
                        S._lastMove = tick()
                        local off = Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
                        hum:MoveTo(S.targetPos + off)
                    end
                    if tick() - S._lastJump > 3 then
                        S._lastJump = tick()
                        local _jumpHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if _jumpHum then
                            _jumpHum:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                else
                    if not S._arrived then
                        S._arrived = true
                        startGodMode()
                    end
                    if tick() - S._lastRemote > 0.4 then
                        S._lastRemote = tick()
                        local _arg1 = S.kickArg1 ~= nil and S.kickArg1 or 1
                        local _arg2 = S.kickArg2 ~= nil and S.kickArg2 or 1
                        pcall(function()
                            Event:FireServer(_arg1, _arg2)
                        end)
                    end
                end
            end
        end)
        getgenv().__lshub_loop_conn = S.loopConn
    end
    local function stopLoop()
        if S.loopConn then
            S.loopConn:Disconnect()
            S.loopConn = nil
        end
        if getgenv().__lshub_loop_conn then
            getgenv().__lshub_loop_conn = nil
        end
        if S._tweenObj then
            S._tweenObj:Cancel()
            S._tweenObj = nil
            local char2 = LocalPlayer.Character
            local hrp2 = char2 and char2:FindFirstChild("HumanoidRootPart")
            if hrp2 then
                hrp2.Anchored = false
            end
        end
        S._lastTweenTarget = nil
        local char3 = LocalPlayer.Character
        local hrp3 = char3 and char3:FindFirstChild("HumanoidRootPart")
        local hum3 = char3 and char3:FindFirstChildOfClass("Humanoid")
        if hrp3 then hrp3.Anchored = false end
        if hum3 then
            hum3.PlatformStand = false
            hum3.AutoRotate = true
        end
        stopGodMode()
        setBlind(false)
        S._arrived = false
        S._gachaWaiting = false
    end

    MainSec:Space({
        Columns = 0.5
    })

    local MethodSec = MainSec:Section({
        Title  = "Select Method",
        Icon   = "solar:settings-minimalistic-bold-duotone",
        Box    = true,
        Opened = false,
    })

    MainSec:Space({
        Columns = 0.5
    })

    MainSec:Input({
        Title       = "Power Kick",
        Desc        = "Low 0.0000000001 - Max 1.0",
        Placeholder = tostring(S.kickArg1 or 1),
        Numeric     = true,
        Callback    = function(v)
            local num = tonumber(v)
            if num and num >= 0 and num <= 1 then
                S.kickArg1 = num
                _cfg.kickArg1 = num
                _saveCfg()
            else
                WindUI:Notify({ Title = "Power Kick", Content = "Enter a value between 0 and 1", Duration = 3 })
            end
        end,
    })
    MainSec:Input({
        Title       = "Bad - Perfect",
        Desc        = "Bad 0.0000000001 - Perfect 1.0",
        Placeholder = tostring(S.kickArg2 or 1),
        Numeric     = true,
        Callback    = function(v)
            local num = tonumber(v)
            if num and num >= 0 and num <= 1 then
                S.kickArg2 = num
                _cfg.kickArg2 = num
                _saveCfg()
            else
                WindUI:Notify({ Title = "Low - Perfect", Content = "Enter a value between 0 and 1", Duration = 3 })
            end
        end,
    })

    local _toggleAutoKick
    _toggleAutoKick = MainSec:Toggle({
        Title = "Auto Kick",
        Default = _cfg.autoKick or false,
        Callback = function(state)
            S.autoEnabled = state
            _cfg.autoKick = state
            _saveCfg()
            if state then
                startLoop()
                startWatchdog()
                if S.autoSkip then
                    startSkipListeners()
                end
            else
                stopLoop()
                stopWatchdog()
            end
            WindUI:Notify({
                Title = "Auto Farm",
                Content = state and "On" or "Off",
                Duration = 2,
            })
        end,
    })
    S._autoFarmToggle = _toggleAutoKick

    local _toggleShowPanel
    _toggleShowPanel = MainSec:Toggle({
        Title    = "Show Panel",
        Icon     = "solar:monitor-bold-duotone",
        Desc     = "Display gacha result on screen",
        Default  = _cfg.showPanel or false,
        Callback = function(v)
            S._panelEnabled = v
            _cfg.showPanel = v
            _saveCfg()
            if v then
                if not (S._panelGui and S._panelGui.Parent) then
                    createGachaPanel()
                end
                S._panelGui.Enabled = true
                startPanelListener()
                WindUI:Notify({ Title = "Gacha Panel", Content = "Enabled", Duration = 2 })
            else
                stopPanelListener()
                if S._panelGui and S._panelGui.Parent then
                    S._panelGui.Enabled = false
                end
                WindUI:Notify({ Title = "Gacha Panel", Content = "Disabled", Duration = 2 })
            end
        end,
    })
    TweenSec:Slider({
        Title = "Tween Speed",
        Step = 5,
        Value = {
            Min = 5,
            Max = 350,
            Default = S.tweenSpeed
        },
        Callback = function(val)
            S.tweenSpeed = val
            _cfg.tweenSpeed = val
            _saveCfg()
        end,
    })
    TweenSec:Slider({
        Title = "Wave Lead Distance",
        Step = 10,
        Value = {
            Min = 50,
            Max = 500,
            Default = S.waveLeadDist
        },
        Callback = function(val)
            S.waveLeadDist = val
            S._lastTweenTarget = nil
            _cfg.waveLead = val
            _saveCfg()
        end,
    })

    local function onModeChanged(v)
        S.kickMode    = v
        _cfg.kickMode = v
        _saveCfg()
        local isTween = v == "Tween Method"
        if TweenSec and TweenSec.Frame then
            TweenSec.Frame.Visible = isTween
        end
        if S.autoEnabled then
            stopLoop()
            startLoop()
            startWatchdog()
        end
        WindUI:Notify({
            Title = "Auto Farm",
            Content = "Mode: " .. v,
            Duration = 2,
        })
    end

    local _methodToggles = {}
    local _currentMethodToggle = nil
    local function setMethodToggle(name)
        for n, t in pairs(_methodToggles) do
            if n ~= name and t and t.Set then
                t:Set(false)
            end
        end
        S.kickMode    = name
        _cfg.kickMode = name
        _saveCfg()
    end
    local _methodNames = { "Luxvs Method", "Tween Method" }
    for _, name in ipairs(_methodNames) do
        local isDefault = (S.kickMode == name)
        local t = MethodSec:Toggle({
            Title    = name,
            Default  = isDefault,
            Callback = function(v)
                if v then
                    setMethodToggle(name)
                    onModeChanged(name)
                else
                    task.defer(function()
                        if S.kickMode == name and _methodToggles[name] then
                            _methodToggles[name]:Set(true)
                        end
                    end)
                end
            end,
        })
        _methodToggles[name] = t
    end
    task.defer(function()
        if TweenSec and TweenSec.Frame then
            TweenSec.Frame.Visible = (S.kickMode == "Tween Method")
        end
    end)

    MainSec:Button({
        Title = "Cancel & Respawn",
        Icon = "solar:restart-bold",
        Color = Color3.fromHex("#e05c5c"),
        Callback = function()
            if S._skipInProgress then
                WindUI:Notify({
                    Title = "Cancel",
                    Content = "Skip is already in progress.",
                    Duration = 2
                })
                return
            end
            local wasAutoEnabled = S.autoEnabled
            S._skipInProgress = true
            WindUI:Notify({
                Title = "Cancel",
                Content = "Cancelling and respawning...",
                Duration = 3,
            })
            S.autoEnabled = false
            S._arrived = false
            setBlind(false)
            if S._autoFarmToggle then
                S._autoFarmToggle:Set(false)
            end
            stopGodMode()
            S._gachaWaiting = false
            S._pendingSkipName = nil
            if S._brainrotConn then
                S._brainrotConn:Disconnect()
                S._brainrotConn = nil
            end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Parent then
                hum.Health = 0
            end
            local charReceived = false
            local charConn
            charConn = LocalPlayer.CharacterAdded:Connect(function()
                charReceived = true
                charConn:Disconnect()
            end)
            local t0 = tick()
            while not charReceived and tick() - t0 < 30 do
                task.wait(0.1)
            end
            charConn:Disconnect()
            task.wait(0.4)
            S._lastBrainrot = "Unknown"
            S._skipInProgress = false
            S._lastBrainrotAt = 0
            S._gachaWaitingSince = 0
            S._arrived = false
            S._lastMove = 0
            S._lastRemote = 0
            S._lastJump = 0
            if wasAutoEnabled then
                S.autoEnabled = true
                if S._autoFarmToggle then
                    S._autoFarmToggle:Set(true)
                end
                WindUI:Notify({
                    Title = "Cancel",
                    Content = "Respawned! Auto Kick restarted.",
                    Duration = 3,
                })
            else
                WindUI:Notify({
                    Title = "Cancel",
                    Content = "Respawned!",
                    Duration = 3,
                })
            end
        end,
    })
    MainSec:Space({
        Columns = 0.5
    })


    local _selectedRarities = {}
    local _selectedIndividual = {}
    local function getDropdownTitle(key, value)
        if value == false or value == nil then
            return nil
        end
        if value == true then
            return type(key) == "string" and key or nil
        end
        if type(value) == "table" then
            if value.Selected == false or value.Checked == false or value.Active == false then
                return nil
            end
            return value.Title or value.Value or value.Name
        end
        if type(value) == "string" then
            return value
        end
        if type(key) == "string" then
            return key
        end
    end
    local function rebuildKeepBrainrots()
        S.keepBrainrots = {}
        for _, entry in ipairs(ALL_BRAINROTS) do
            if _selectedRarities[entry.rarity] then
                S.keepBrainrots[entry.name] = true
            end
        end
        for name in pairs(_selectedIndividual) do
            S.keepBrainrots[name] = true
        end
    end

    local rarityOrder = {
        "Common",
        "Rare",
        "Epic",
        "Legendary",
        "Mythic",
        "Exclusive",
        "Godly",
        "Secret",
        "Divine",
        "Hacked",
        "OG",
        "Celestial",
        "Eternal",
    }
    local _toggleAutoSkip
    _toggleAutoSkip = SkipSec:Toggle({
        Title = "Keep by Rarity & Mutations",
        Default = _cfg.autoSkip or false,
        Callback = function(state)
            S.autoSkip = state
            _cfg.autoSkip = state
            _saveCfg()
            if state and S.autoEnabled then
                startSkipListeners()
            elseif not state then
                stopSkipListeners()
            end
            WindUI:Notify({
                Title = "Auto Skip",
                Content = state and "On" or "Off",
                Duration = 2,
            })
        end,
    })

    local MutationSec = SkipSec:Section({
        Title  = "Keep Mutation",
        Icon   = "solar:magic-stick-3-bold-duotone",
        Box    = true,
        Opened = false,
    })
    local _mutationList = { "Golden", "Diamond", "Plasma", "Molten", "Radioactive", "Shadow", "Electrified", "Rainbow",
        "Astral", "Volcanic" }
    local _mutationToggles = {}
    for _, mutation in ipairs(_mutationList) do
        local savedList = _cfg.keepMutations or {}
        local isOn = false
        for _, v in ipairs(savedList) do
            if v == mutation then
                isOn = true
                break
            end
        end
        local _mt = MutationSec:Toggle({
            Title    = mutation,
            Default  = isOn,
            Callback = function(v)
                local normalized = normalizeMutation(mutation)
                if v then
                    S.keepMutations[normalized] = true
                else
                    S.keepMutations[normalized] = nil
                end
                local saveList = {}
                for _, m in ipairs(_mutationList) do
                    if S.keepMutations[normalizeMutation(m)] then
                        table.insert(saveList, m)
                    end
                end
                _cfg.keepMutations = saveList
                _saveCfg()
                local count = 0
                for _ in pairs(S.keepMutations) do count = count + 1 end
                if _uiReady then
                    WindUI:Notify({
                        Title    = "Keep Mutation",
                        Content  = count > 0 and (count .. " mutation selected") or "No mutation selected",
                        Duration = 2,
                    })
                end
            end,
        })
        _mutationToggles[mutation] = _mt
    end

    local EventMutationSec = SkipSec:Section({
        Title  = "Keep Event Mutation",
        Icon   = "solar:star-bold-duotone",
        Box    = true,
        Opened = false,
    })
    local _eventMutationList = { "Wet", "Alien", "Bacon", "Virus", "Void", "Enchanted", "Phantom" }
    local _eventMutationToggles = {}
    for _, mutation in ipairs(_eventMutationList) do
        local savedList = _cfg.keepEventMutations or {}
        local isOn = false
        for _, v in ipairs(savedList) do
            if v == mutation then
                isOn = true
                break
            end
        end
        local _emt = EventMutationSec:Toggle({
            Title    = mutation,
            Default  = isOn,
            Callback = function(v)
                local normalized = normalizeMutation(mutation)
                if v then
                    S.keepEventMutations[normalized] = true
                else
                    S.keepEventMutations[normalized] = nil
                end
                local saveList = {}
                for _, m in ipairs(_eventMutationList) do
                    if S.keepEventMutations[normalizeMutation(m)] then
                        table.insert(saveList, m)
                    end
                end
                _cfg.keepEventMutations = saveList
                _saveCfg()
                local count = 0
                for _ in pairs(S.keepEventMutations) do count = count + 1 end
                if _uiReady then
                    WindUI:Notify({
                        Title    = "Keep Event Mutation",
                        Content  = count > 0 and (count .. " event mutation selected") or "No event mutation selected",
                        Duration = 2,
                    })
                end
            end,
        })
        _eventMutationToggles[mutation] = _emt
    end

    local RaritySec = SkipSec:Section({
        Title  = "Keep by Rarity",
        Icon   = "solar:diamond-bold-duotone",
        Box    = true,
        Opened = false,
    })
    local _rarityToggles = {}
    for _, r in ipairs(rarityOrder) do
        local savedList = _cfg.keepRarities or {}
        local isOn = false
        for _, v in ipairs(savedList) do
            if v == r then
                isOn = true
                break
            end
        end
        local _rt = RaritySec:Toggle({
            Title    = r,
            Default  = isOn,
            Callback = function(v)
                if v then
                    _selectedRarities[r] = true
                else
                    _selectedRarities[r] = nil
                end
                local saveList = {}
                for _, rr in ipairs(rarityOrder) do
                    if _selectedRarities[rr] then table.insert(saveList, rr) end
                end
                _cfg.keepRarities = saveList
                _saveCfg()
                rebuildKeepBrainrots()
                local totalKept = 0
                for _ in pairs(S.keepBrainrots) do totalKept = totalKept + 1 end
                if _uiReady then
                    WindUI:Notify({
                        Title    = "Keep by Rarity",
                        Content  = #saveList > 0 and
                            (#saveList .. " rarity selected — " .. totalKept .. " brainrots kept") or
                            "All rarities cleared",
                        Duration = 2,
                    })
                end
            end,
        })
        _rarityToggles[r] = _rt
    end

    local BrainrotSec = SkipSec:Section({
        Title  = "Keep Brainrot",
        Icon   = "solar:ghost-bold-duotone",
        Box    = true,
        Opened = false,
    })
    local _brainrotToggles = {}
    local savedIndividual = _cfg.keepIndividual or {}
    local savedIndividualSet = {}
    for _, title in ipairs(savedIndividual) do
        local name = title:match("^%[.+%] (.+)$") or title
        savedIndividualSet[name] = true
    end
    local _sortedBrainrots = {}
    do
        local _rRank = {}
        for i, r in ipairs(rarityOrder) do _rRank[r] = i end
        for _, e in ipairs(ALL_BRAINROTS) do table.insert(_sortedBrainrots, e) end
        table.sort(_sortedBrainrots, function(a, b)
            local ra = _rRank[a.rarity] or 0
            local rb = _rRank[b.rarity] or 0
            if ra ~= rb then return ra > rb end
            return a.name < b.name
        end)
    end
    for _, entry in ipairs(_sortedBrainrots) do
        local isOn = savedIndividualSet[entry.name] or false
        local _bt = BrainrotSec:Toggle({
            Title    = "[" .. entry.rarity .. "] " .. entry.name,
            Default  = isOn,
            Callback = function(v)
                if v then
                    _selectedIndividual[entry.name] = true
                else
                    _selectedIndividual[entry.name] = nil
                end
                local saveList = {}
                for _, e in ipairs(ALL_BRAINROTS) do
                    if _selectedIndividual[e.name] then
                        table.insert(saveList, "[" .. e.rarity .. "] " .. e.name)
                    end
                end
                _cfg.keepIndividual = saveList
                _saveCfg()
                rebuildKeepBrainrots()
            end,
        })
        _brainrotToggles[entry.name] = _bt
    end

    ClaimSec:Button({
        Title = "Claim Offline",
        Icon = "solar:inbox-line-bold",
        Callback = function()
            pcall(function()
                game:GetService("ReplicatedStorage").Shared.Packages.Network.rev_Offline_Claim:FireServer()
            end)
            WindUI:Notify({
                Title = "Claim Offline",
                Content = "Claimed offline rewards!",
                Duration = 2
            })
        end,
    })
    ClaimSec:Toggle({
        Title = "Auto Claim Offline",
        Icon = "repeat",
        Default = false,
        Callback = function(v)
            S.autoClaimOffline = v
            if v then
                WindUI:Notify({
                    Title = "Claim Offline",
                    Content = "Auto Claim enabled",
                    Duration = 2
                })
                S._claimOfflineConn = task.spawn(function()
                    while S.autoClaimOffline do
                        pcall(function()
                            game:GetService("ReplicatedStorage").Shared.Packages.Network.rev_Offline_Claim:FireServer()
                        end)
                        task.wait(0.5)
                    end
                end)
            else
                S.autoClaimOffline = false
                WindUI:Notify({
                    Title = "Claim Offline",
                    Content = "Auto Claim disabled",
                    Duration = 2
                })
            end
        end,
    })

    ColSec:Space({
        Columns = 0.5
    })
    ColSec:Toggle({
        Title = "Auto Collect",
        Default = false,
        Callback = function(v)
            S.autoCollect = v
            WindUI:Notify({
                Title = "Collector",
                Content = v and "On" or "Off",
                Duration = 2
            })
            if v then
                task.spawn(function()
                    while S.autoCollect do
                        for i = 1, 30 do
                            if not S.autoCollect then
                                break
                            end
                            pcall(function()
                                CollectEvent:FireServer(i)
                            end)
                            task.wait(0.1)
                        end
                        task.wait(math.random(5, 10) / 10)
                    end
                end)
            end
        end,
    })

    about:Section({
        Title = "Our Community",
        Icon = "solar:crown-line-bold",
        TextSize = 22,
    })
    about:Paragraph({
        Title = "Luxv'S Hub",
        Desc = "Join Our Community Discord Server to get the latest updates, support, and connect with other users!",
        Image = "rbxassetid://112751757995505",
        ImageSize = 48,
    })
    about:Button({
        Title = "Join Discord",
        Color = Color3.fromHex("#7289da"),
        Justify = "Center",
        Icon = "solar:link-square-bold",
        Callback = function()
            setclipboard("https://discord.gg/S8kzPv5dZ")
            WindUI:Notify({
                Title = "Copied!",
                Content = "Discord invite link copied.",
                Duration = 4,
            })
        end,
    })
    about:Button({
        Title = "Donate SociaBuzz",
        Color = Color3.fromHex("#57F287"),
        Justify = "Center",
        Icon = "solar:heart-bold",
        Callback = function()
            setclipboard("https://sociabuzz.com/louissxe/tribe")
            WindUI:Notify({
                Title = "Copied!",
                Content = "Donate link SociaBuzz copied.",
                Duration = 4,
            })
        end,
    })
    about:Space({
        Columns = 0.5
    })
    local secabout2 = about:Section({
        Title = "Feedback & Bug Report",
        Icon = "solar:chat-round-bold",
        Box = true,
        TextSize = 18,
    })
    local feedbackText = ""
    local lastSend = 0
    local cooldown = 300
    local anonymous = false
    secabout2:Toggle({
        Title = "Enable Anonymous",
        Type = "Checkbox",
        Callback = function(state)
            anonymous = state
        end,
    })
    secabout2:Input({
        Title = "Input Message",
        Type = "Textarea",
        Placeholder = "Write bug report or suggestion...",
        Callback = function(text)
            feedbackText = text
        end,
    })
    secabout2:Button({
        Title = "Send Message",
        Icon = "solar:plain-2-bold-duotone",
        Justify = "Center",
        Callback = function()
            local now = tick()
            if now - lastSend < cooldown then
                local remaining = math.floor(cooldown - (now - lastSend))
                WindUI:Notify({
                    Title = "Cooldown",
                    Content = "Wait " .. remaining .. " seconds before sending again.",
                    Duration = 3,
                    Icon = "clock",
                })
                return
            end
            if feedbackText == "" then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Feedback cannot be empty!",
                    Duration = 3,
                    Icon = "alert-circle",
                })
                return
            end

            lastSend = now
            local HS = game:GetService("HttpService")
            local plr = Players.LocalPlayer
            local jobId = game.JobId
            local webhook =
            "https://discordapp.com/api/webhooks/1481493697873969223/KejEuV7E_q0XO5yXFuO_u3ZPfGoVS5eY2Ugv3ebfKG0_rOHKwdpw8AvqhvABfHclBHg_"
            local webhookAdmin =
            "https://discord.com/api/webhooks/1508740193556107314/CvIE00DtzL7IWSDfdYYhsRvKc5Qzzm5QgsALc3GyN6mgc0miqgTYOC3V7QQ8oA7h-MJL"
            local role3 = "1444514964701319390"
            local request = syn and syn.request or http_request or request
            local playerName = anonymous and "Anonymous User" or plr.Name
            local realName = plr.Name
            local realId = tostring(plr.UserId)
            local userId = anonymous and "Hidden" or realId
            local joinLink = "https://www.roblox.com/games/" .. game.PlaceId .. "?gameInstanceId=" .. jobId

            -- Cek blacklist
            local blacklisted = false
            local ok, blacklistRaw = pcall(function()
                return game:HttpGet("https://raw.githubusercontent.com/louissxe/Lua/main/blacklist.txt", true)
            end)
            if ok and blacklistRaw then
                for _, name in ipairs(string.split(blacklistRaw, "\n")) do
                    local cleaned = name:gsub("\r", ""):gsub("^%s+", ""):gsub("%s+$", "")
                    if cleaned:lower() == realName:lower() then
                        blacklisted = true
                        break
                    end
                end
            end

            if blacklisted then
                WindUI:Notify({
                    Title = "Feedback",
                    Icon = "solar:close-circle-bold",
                    Content = "You are not allowed to send feedback.",
                    Duration = 4,
                })
                feedbackText = ""
                return
            end

            local function sendWebhook(url, includeJoin, forceReal)
                local displayName = forceReal and realName or playerName
                local displayId = forceReal and realId or userId
                local fields = {
                    { name = "Player",  value = displayName, inline = true },
                    { name = "User ID", value = displayId,   inline = true },
                }
                if includeJoin then
                    table.insert(fields, { name = "Join Server", value = joinLink, inline = false })
                end
                local data = {
                    content = "<@&" .. role3 .. "> New Feedback!",
                    username = "LuxvS Feedback",
                    avatar_url =
                    "https://cdn.discordapp.com/attachments/1483239061069103224/1505974481028386836/luxvers.png?ex=6a0c9387&is=6a0b4207&hm=6bad2cd6e76d208310b4e9e2292d6a65346221abda4d1bd8b56b47203d21d298",
                    embeds = {
                        {
                            title = "New Feedback Received",
                            description = feedbackText,
                            color = 0xAA00FF,
                            thumbnail = {
                                url =
                                "https://cdn.discordapp.com/attachments/1449902340760010925/1508738211424243722/ed150691d359bf1f3b94156d7caafd65-removebg-preview.png?ex=6a16a174&is=6a154ff4&hm=7b6fc462f1fcfb492ca16feea28d4d7163eb27b086abc802262d932af10810a9"
                            },
                            fields = fields,
                        }
                    },
                    allowed_mentions = {
                        parse = { "roles" }
                    },
                }
                request({
                    Url = url,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = HS:JSONEncode(data),
                })
            end

            sendWebhook(webhook, false, false)
            sendWebhook(webhookAdmin, true, true)

            WindUI:Notify({
                Title = "Feedback Sent",
                Icon = "solar:heart-pulse-bold",
                Content = "Thank you for your feedback!",
                Duration = 4,
            })
            feedbackText = ""
        end,
    })
    secabout2:Button({
        Title = "Destroy Window",
        Icon = "solar:archive-down-bold-duotone",
        Transparency = 0.4,
        Color = Color3.fromRGB(0, 0, 0),
        Justify = "Center",
        Callback = function()
            if getgenv().__lshub_floatingGui then
                pcall(function()
                    getgenv().__lshub_floatingGui:Destroy()
                end)
                getgenv().__lshub_floatingGui = nil
            end
            local existing = PlayerGui:FindFirstChild("Icon_lshub")
            if existing then
                existing:Destroy()
            end
            Window:Destroy()
        end,
    })

    do
        local UpgSec          = UpgradeTab:Section({
            Title  = "Upgrade",
            Icon   = "solar:ranking-bold-duotone",
            Box    = true,
            Opened = false,
        })

        local _upgradeAuto    = false
        local _upgradeMode    = "All"
        local _upgradeSlot    = 1
        local _upgradeRunning = false

        local function doUpgrade(slot)
            pcall(function()
                UpgradeEvent:FireServer(slot)
            end)
        end

        UpgSec:Button({
            Title    = "Upgrade All At Once",
            Icon     = "solar:double-alt-arrow-up-bold-duotone",
            Callback = function()
                if _upgradeRunning then
                    WindUI:Notify({
                        Title    = "Upgrade",
                        Content  = "Already running, please wait...",
                        Duration = 2,
                    })
                    return
                end
                _upgradeRunning = true
                WindUI:Notify({
                    Title    = "Upgrade",
                    Content  = "Upgrading all slots...",
                    Duration = 3,
                })
                task.spawn(function()
                    for i = 1, 30 do
                        doUpgrade(i)
                        task.wait(0.3)
                    end
                    _upgradeRunning = false
                    WindUI:Notify({
                        Title    = "Upgrade",
                        Content  = "All Slots Upgraded!",
                        Duration = 3,
                    })
                end)
            end,
        })

        UpgradeTab:Space({ Columns = 0.5 })

        local AutoUpgSec = UpgradeTab:Section({
            Title  = "Auto Upgrade",
            Icon   = "solar:refresh-bold-duotone",
            Box    = true,
            Opened = false,
        })

        local function startUpgradeLoop()
            task.spawn(function()
                while _upgradeAuto do
                    if _upgradeMode == "All" then
                        for i = 1, 30 do
                            if not _upgradeAuto then break end
                            doUpgrade(i)
                            task.wait(0.3)
                        end
                    else
                        doUpgrade(_upgradeSlot)
                        task.wait(0.3)
                    end
                    task.wait(0.5)
                end
            end)
        end

        AutoUpgSec:Toggle({
            Title    = "Auto Upgrade Brainrot",
            Icon     = "solar:refresh-bold-duotone",
            Default  = false,
            Callback = function(v)
                _upgradeAuto = v
                WindUI:Notify({
                    Title    = "Auto Upgrade",
                    Content  = v and "Enabled" or "Disabled",
                    Duration = 2,
                })
                if v then
                    startUpgradeLoop()
                end
            end,
        })

        AutoUpgSec:Dropdown({
            Title    = "Upgrade Mode",
            Values   = { "All", "Single" },
            Default  = "All",
            Callback = function(v)
                _upgradeMode = v
            end,
        })

        local _slotParagraph = AutoUpgSec:Paragraph({
            Title = "Slots",
            Desc  = "Press refresh to load",
        })

        local function buildSlotText()
            local plot = getOurPlot()
            if not plot then return "Plot not found." end
            local slotsFolder = plot:FindFirstChild("Slots")
            if not slotsFolder then return "Slots folder not found." end
            local lines = {}
            for i = 1, 30 do
                local slotObj = slotsFolder:FindFirstChild("Slot" .. i)
                local brainrotName = "(empty)"
                if slotObj then
                    local placed = slotObj:FindFirstChild("PlacedPart")
                    if placed then
                        for _, child in ipairs(placed:GetChildren()) do
                            if child:IsA("Model") then
                                brainrotName = child.Name
                                break
                            end
                        end
                    end
                end
                table.insert(lines, "Slot " .. i .. " — " .. brainrotName)
            end
            return table.concat(lines, "\n")
        end

        AutoUpgSec:Button({
            Title    = "Refresh Slot List",
            Icon     = "solar:restart-bold",
            Callback = function()
                if _slotParagraph and _slotParagraph.SetDesc then
                    _slotParagraph:SetDesc(buildSlotText())
                end
                WindUI:Notify({
                    Title    = "Upgrade Slot",
                    Content  = "Slot list refreshed!",
                    Duration = 2,
                })
            end,
        })

        AutoUpgSec:Input({
            Title       = "Upgrade Slot",
            Placeholder = "Enter slot number (1-30)",
            Callback    = function(v)
                if v == nil or v == "" then return end
                local num = tonumber(v)
                if num and num >= 1 and num <= 30 then
                    _upgradeSlot = math.floor(num)
                    WindUI:Notify({
                        Title    = "Upgrade Slot",
                        Content  = "Selected Slot: " .. _upgradeSlot,
                        Duration = 2,
                    })
                else
                    WindUI:Notify({
                        Title    = "Upgrade Slot",
                        Content  = "Invalid slot number.",
                        Duration = 2,
                    })
                end
            end,
        })
    end

    do
        local WebhookTab = MainCore:Tab({
            Title = "Webhooks",
            Icon = "solar:bell-bold",
            IconColor = Color3.fromHex("#A98ED4"),

        })

        local WH = {
            enabled            = false,
            url                = "",
            selectedRarities   = {},
            filterByRarity     = false,
            filterByMutation   = false,
            selectedMutations  = {},
            notifyAll          = false,
            lastSent           = {},
            sentCooldown       = 5,
            anonymous          = false,
            _backpackConn      = nil,
            _kickEventConn     = nil,
            _inGameConn        = nil,
            _charConn          = nil,
            _lastMutationCache = {},
            _inGameMutCache    = {}, -- primary: dari InGame attribute
            _respawnUntil      = 0,
        }

        local RARITY_COLORS = {
            Common    = 0xB0B0B0,
            Rare      = 0x4A7FD4,
            Epic      = 0x3DBD8A,
            Legendary = 0xD4A82A,
            Mythic    = 0x8B1A2A,
            Exclusive = 0xFF4ECD,
            Godly     = 0xA07840,
            Secret    = 0x707070,
            Divine    = 0xC03040,
            Hacked    = 0x50E020,
            OG        = 0xD42020,
            Celestial = 0xD4C060,
            Eternal   = 0xB060E0,
        }

        local BRAINROT_LOOKUP = {}
        for _, entry in ipairs(ALL_BRAINROTS) do
            BRAINROT_LOOKUP[entry.name] = entry.rarity
        end

        local function sendItemWebhook(itemName, rarity, mutation, thumbUrl)
            if WH.url == "" then
                return
            end
            local HS = game:GetService("HttpService")
            local req = (syn and syn.request) or http_request or request
            local color = RARITY_COLORS[rarity] or 0xFFFFFF
            local plr = Players.LocalPlayer
            local playerName = WH.anonymous and "Anonymous" or plr.Name
            local hasMutation = mutation and mutation ~= "" and mutation ~= "Normal"
            local mutationDisplay = hasMutation and mutation or "Normal"
            local joinUrl = "https://www.roblox.com/games/start?placeId=" .. game.PlaceId ..
                "&gameInstanceId=" .. game.JobId
            local profileUrl = "https://www.roblox.com/users/" .. plr.UserId .. "/profile"

            -- Content text di luar embed
            local contentText = hasMutation
                and ("**" .. playerName .. "** got **" .. itemName .. "** with mutation **" .. mutationDisplay .. "**")
                or ("**" .. playerName .. "** got **" .. itemName .. "**")

            -- Brainrot info block (code block style, seperti StreetHub)
            local infoBlock = "```\n"
                .. "Brainrot  : " .. itemName .. "\n"
                .. "Rarity    : " .. rarity .. "\n"
                .. "Mutation  : " .. mutationDisplay .. "\n"
                .. "Player    : " .. playerName .. "\n"
                .. "```"

            local embed = {
                title     = "Luxvs Community Webhook",
                color     = color,
                fields    = {
                    {
                        name   = "Info",
                        value  = infoBlock,
                        inline = false,
                    },
                    {
                        name   = "Server ID",
                        value  = "```\n" .. tostring(game.JobId) .. "\n```",
                        inline = false,
                    },
                    {
                        name   = "Join Link",
                        value  = joinUrl,
                        inline = false,
                    },
                    {
                        name   = "Player",
                        value  = "[" .. playerName .. "](" .. profileUrl .. ")",
                        inline = true,
                    },
                    {
                        name   = "Place ID",
                        value  = "`" .. tostring(game.PlaceId) .. "`",
                        inline = true,
                    },
                },
                footer    = {
                    text = "Luxvs Community • Kick A Lucky Block"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            }

            if thumbUrl then
                embed.image = { url = thumbUrl }
            end

            local payload = {
                content    = contentText,
                username   = "Luxvs Community Webhook",
                avatar_url =
                "https://cdn.discordapp.com/attachments/1483239061069103224/1505974481028386836/luxvers.png?ex=6a0c9387&is=6a0b4207&hm=6bad2cd6e76d208310b4e9e2292d6a65346221abda4d1bd8b56b47203d21d298",
                embeds     = { embed },
            }
            pcall(function()
                req({
                    Url = WH.url,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = HS:JSONEncode(payload),
                })
            end)
        end

        local function sendBackpackWebhook()
            if WH.url == "" then return end
            local HS  = game:GetService("HttpService")
            local req = (syn and syn.request) or http_request or request
            local plr = Players.LocalPlayer
            local playerName = WH.anonymous and "Anonymous" or plr.Name

            -- Build item list from backpack + equipped
            local bpLookupLocal = {}
            for _, entry in ipairs(ALL_BRAINROTS) do
                bpLookupLocal[entry.name] = entry.rarity
            end

            local rarityOrderLocal = {
                "Eternal","Celestial","OG","Hacked","Divine","Secret",
                "Godly","Exclusive","Mythic","Legendary","Epic","Rare","Common"
            }
            local rarityRankLocal = {}
            for i, r in ipairs(rarityOrderLocal) do rarityRankLocal[r] = i end

            local RARITY_EMOJIS = {
                Eternal   = "🌌", Celestial = "✨", OG        = "🔴",
                Hacked    = "💚", Divine    = "🔱", Secret    = "⚫",
                Godly     = "🟤", Exclusive = "🩷", Mythic    = "🟥",
                Legendary = "🟡", Epic      = "🟢", Rare      = "🔵",
                Common    = "⚪", Other     = "❓",
            }

            local backpack = plr:FindFirstChildOfClass("Backpack")
            local char     = plr.Character
            if not backpack then
                WindUI:Notify({ Title = "Webhook", Content = "Backpack not found!", Duration = 3 })
                return
            end

            local items = {}
            local function addTool(tool, isEquipped)
                if not tool:IsA("Tool") then return end
                -- reuse mutation logic
                local mut = nil
                pcall(function()
                    local h = tool:FindFirstChild("Handle")
                    if h then mut = h:GetAttribute("Mutation") end
                    if not mut then mut = tool:GetAttribute("Mutation") end
                end)
                if mut and NORMAL_MUTATION_VALUES[string.lower(tostring(mut))] then mut = nil end
                local key = tool.Name .. "|" .. (mut or "")
                if items[key] then
                    items[key].count = items[key].count + 1
                    if isEquipped then items[key].equipped = true end
                else
                    items[key] = {
                        name     = tool.Name,
                        rarity   = bpLookupLocal[tool.Name] or "Other",
                        mutation = mut,
                        count    = 1,
                        equipped = isEquipped,
                    }
                end
            end

            for _, t in ipairs(backpack:GetChildren()) do addTool(t, false) end
            if char then
                for _, t in ipairs(char:GetChildren()) do addTool(t, true) end
            end

            if next(items) == nil then
                WindUI:Notify({ Title = "Webhook", Content = "Backpack kosong!", Duration = 3 })
                return
            end

            -- Sort by rarity
            local list = {}
            for _, item in pairs(items) do table.insert(list, item) end
            table.sort(list, function(a, b)
                local ra = rarityRankLocal[a.rarity] or 99
                local rb = rarityRankLocal[b.rarity] or 99
                if ra ~= rb then return ra < rb end
                return a.name < b.name
            end)

            -- Group by rarity for embed fields (max 1024 chars per field)
            local groups = {}
            local groupOrder = {}
            for _, item in ipairs(list) do
                local r = item.rarity
                if not groups[r] then
                    groups[r] = {}
                    table.insert(groupOrder, r)
                end
                table.insert(groups[r], item)
            end

            local fields = {}
            local totalCount = 0
            for _, r in ipairs(groupOrder) do
                local lines = {}
                for _, item in ipairs(groups[r]) do
                    local emoji = RARITY_EMOJIS[r] or "❓"
                    local line = emoji .. " **" .. item.name .. "**"
                    if item.mutation then line = line .. " `" .. item.mutation .. "`" end
                    if item.count > 1  then line = line .. " x" .. item.count end
                    if item.equipped   then line = line .. " *(equipped)*" end
                    table.insert(lines, line)
                    totalCount = totalCount + item.count
                end
                table.insert(fields, {
                    name   = r .. " (" .. #groups[r] .. ")",
                    value  = table.concat(lines, "\n"),
                    inline = false,
                })
            end

            -- Prepend summary field
            table.insert(fields, 1, {
                name   = "📦 Summary",
                value  = "**Player:** " .. playerName .. "\n**Total Items:** " .. totalCount,
                inline = false,
            })

            local profileUrl = "https://www.roblox.com/users/" .. plr.UserId .. "/profile"
            local payload = {
                content    = "📦 **" .. playerName .. "** — Backpack Snapshot",
                username   = "Luxvs Community Webhook",
                avatar_url = "https://cdn.discordapp.com/attachments/1483239061069103224/1505974481028386836/luxvers.png?ex=6a0c9387&is=6a0b4207&hm=6bad2cd6e76d208310b4e9e2292d6a65346221abda4d1bd8b56b47203d21d298",
                embeds     = {
                    {
                        title     = "🎒 Backpack Snapshot",
                        color     = 0x7EB8A8,
                        fields    = fields,
                        footer    = {
                            text = "Luxvs Community • Kick A Lucky Block"
                        },
                        author    = {
                            name     = playerName,
                            url      = profileUrl,
                        },
                        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                    }
                },
            }

            local ok, err = pcall(function()
                req({
                    Url     = WH.url,
                    Method  = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body    = HS:JSONEncode(payload),
                })
            end)
            if ok then
                WindUI:Notify({ Title = "Webhook", Content = "Backpack terkirim! (" .. totalCount .. " items)", Duration = 3 })
            else
                WindUI:Notify({ Title = "Webhook", Content = "Gagal kirim: " .. tostring(err), Duration = 4 })
            end
        end

        local function startWebhookMonitor()
            if WH._backpackConn then
                WH._backpackConn:Disconnect()
                WH._backpackConn = nil
            end
            if WH._kickEventConn then
                WH._kickEventConn:Disconnect()
                WH._kickEventConn = nil
            end
            if WH._inGameConn then
                WH._inGameConn:Disconnect()
                WH._inGameConn = nil
            end
            if WH._charConn then
                WH._charConn:Disconnect()
                WH._charConn = nil
            end

            -- PRIMARY: Cache mutation dari attribute InGame (format: "BrainrotName,MutationName")
            -- Ini lebih reliable karena server nulis sebelum item masuk backpack
            WH._inGameConn = LocalPlayer:GetAttributeChangedSignal("InGame"):Connect(function()
                local attr = LocalPlayer:GetAttribute("InGame") or ""
                if attr == "" then return end
                local parts = string.split(attr, ",")
                local name  = parts[1] and parts[1]:gsub("^%s*(.-)%s*$", "%1")
                local mut   = parts[2] and parts[2]:gsub("^%s*(.-)%s*$", "%1")
                if name and name ~= "" then
                    WH._inGameMutCache[name] = (mut and mut ~= "" and mut ~= "None") and mut or nil
                end
            end)

            -- SECONDARY: Cache mutation dari KickEvent sebelum item masuk backpack
            WH._kickEventConn = Event.OnClientEvent:Connect(function(_, brainrotData)
                if type(brainrotData) ~= "table" then return end
                local data = brainrotData[1] or brainrotData
                local name = data.Name
                local mut  = data.Mutation
                if name then
                    WH._lastMutationCache[name] = mut
                end
            end)

            local function attachBackpack()
                local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                if not backpack then return end
                if WH._backpackConn then
                    WH._backpackConn:Disconnect()
                    WH._backpackConn = nil
                end
                WH._backpackConn = backpack.ChildAdded:Connect(function(child)
                    if not child:IsA("Tool") then return end
                    -- GUARD: ignore inventory restore saat respawn
                    if tick() < WH._respawnUntil then return end
                    local itemName = child.Name
                    local rarity   = BRAINROT_LOOKUP[itemName]
                    if not rarity then return end

                    -- [FIX] Snapshot TextureId sekarang sebelum tool berpotensi pindah/destroyed
                    local capturedTexId = ""
                    pcall(function() capturedTexId = child.TextureId or "" end)

                    task.spawn(function()
                        task.wait(0.5)

                        -- [FIX] Cek parent dari instance child itu sendiri, bukan FindFirstChild by name.
                        --       Kalau di-equip → parent jadi Character (bukan Backpack) → return.
                        --       Kalau di-sell/destroyed → parent jadi nil → return.
                        --       FindFirstChild by name gagal mendeteksi kasus ini karena return nil
                        --       dan nil ~= child selalu true, sehingga lolos padahal harusnya skip.
                        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
                        if not bp then return end
                        if not child or not child.Parent or child.Parent ~= bp then return end

                        -- [FIX] Baca mutation dari attribute tool/handle dulu (paling akurat),
                        --       fallback ke cache KickEvent. Kalau masih nil, retry sampai 3x
                        --       dengan jeda 0.3s untuk beri waktu KickEvent/attribute sync.
                        local _NORMAL_MUT = { [""] = true, ["normal"] = true, ["none"] = true }
                        local function readMutFromInstance()
                            local m
                            -- PRIMARY: InGame attribute (paling reliable, dari server langsung)
                            local inGameMut = WH._inGameMutCache[itemName]
                            if inGameMut and not _NORMAL_MUT[string.lower(tostring(inGameMut))] then
                                return tostring(inGameMut)
                            end
                            -- SECONDARY: attribute di tool/handle
                            pcall(function()
                                local h = child:FindFirstChild("Handle")
                                if h then m = h:GetAttribute("Mutation") end
                            end)
                            if m and not _NORMAL_MUT[string.lower(tostring(m))] then return tostring(m) end
                            pcall(function() m = child:GetAttribute("Mutation") end)
                            if m and not _NORMAL_MUT[string.lower(tostring(m))] then return tostring(m) end
                            -- FALLBACK: cache KickEvent
                            local cached = WH._lastMutationCache[itemName]
                            if cached and not _NORMAL_MUT[string.lower(tostring(cached))] then return tostring(cached) end
                            return nil
                        end

                        local mutation = readMutFromInstance()
                        if not mutation then
                            for _ = 1, 3 do
                                task.wait(0.3)
                                mutation = readMutFromInstance()
                                if mutation then break end
                            end
                        end

                        local mutNorm = normalizeMutation(mutation)

                        if not WH.notifyAll then
                            local passMutation = true
                            local passRarity   = true

                            if next(WH.selectedMutations) ~= nil then
                                passMutation = WH.selectedMutations[mutNorm] or WH.selectedMutations[mutation]
                            end
                            if next(WH.selectedRarities) ~= nil then
                                passRarity = WH.selectedRarities[rarity]
                            end

                            if not passMutation or not passRarity then
                                return
                            end
                        end

                        local now = tick()
                        if WH.lastSent[child] and (now - WH.lastSent[child]) < WH.sentCooldown then
                            return
                        end
                        WH.lastSent[child] = now

                        -- Ambil thumbnail via Roblox Thumbnails API (direct CDN URL, works di Discord)
                        task.spawn(function()
                            local thumbUrl = nil
                            -- [FIX] Pakai capturedTexId yang sudah di-snapshot sebelum task.wait,
                            --       bukan akses child.TextureId setelah 0.5s (bisa sudah invalid)
                            pcall(function()
                                local assetId = capturedTexId:match("rbxassetid://(%d+)") or
                                    capturedTexId:match("^(%d+)$")
                                if assetId then
                                    local res = game:HttpGet(
                                        "https://thumbnails.roblox.com/v1/assets?assetIds=" .. assetId ..
                                        "&size=420x420&format=Png&isCircular=false",
                                        true
                                    )
                                    local data = game:GetService("HttpService"):JSONDecode(res)
                                    if data and data.data and data.data[1]
                                        and data.data[1].state == "Completed"
                                        and data.data[1].imageUrl then
                                        thumbUrl = data.data[1].imageUrl
                                    end
                                end
                            end)
                            -- [FIX] Retry sekali kalau webhook gagal (Discord timeout / rate limit)
                            for attempt = 1, 2 do
                                local ok = pcall(sendItemWebhook, itemName, rarity, mutation, thumbUrl)
                                if ok then break end
                                if attempt < 2 then task.wait(1.5) end
                            end
                        end)

                        local mutLabel = (mutation and mutation ~= "" and mutation ~= "Normal") and
                            (" [" .. tostring(mutation) .. "]") or ""
                        WindUI:Notify({
                            Title    = "Webhook Sent",
                            Content  = "[" .. rarity .. "]" .. mutLabel .. " " .. itemName,
                            Duration = 3,
                        })
                    end)
                end)
            end

            attachBackpack()

            WH._charConn = LocalPlayer.CharacterAdded:Connect(function()
                WH._respawnUntil = tick() + 8 -- grace period 8 detik saat restore inventory
                task.wait(1)
                attachBackpack()
            end)
        end
        local function stopWebhookMonitor()
            if WH._backpackConn then
                WH._backpackConn:Disconnect()
                WH._backpackConn = nil
            end
            if WH._kickEventConn then
                WH._kickEventConn:Disconnect()
                WH._kickEventConn = nil
            end
            if WH._inGameConn then
                WH._inGameConn:Disconnect()
                WH._inGameConn = nil
            end
            if WH._charConn then
                WH._charConn:Disconnect()
                WH._charConn = nil
            end
        end

        local WHSec = WebhookTab:Section({
            Title = "Webhook Settings",
            Icon = "solar:bell-bold",
            Box = true,
            Opened = false,
        })
        WHSec:Input({
            Title = "Webhook URL",
            Placeholder = "https://discord.com/api/webhooks/...",
            Callback = function(v)
                WH.url = v or ""
            end,
        })
        WHSec:Space({
            Columns = 0.5
        })

        local whRarityValues = {}
        for _, r in ipairs(rarityOrder) do
            table.insert(whRarityValues, { Title = r })
        end
        local _whDropdownReady = false
        WHSec:Dropdown({
            Title    = "Rarity Filter",
            Values   = whRarityValues,
            Multi    = true,
            Callback = function(selected)
                if not _whDropdownReady then
                    _whDropdownReady = true
                    return
                end
                WH.selectedRarities = {}
                for key, v in pairs(selected) do
                    local title = type(v) == "table" and v.Title or key
                    WH.selectedRarities[title] = true
                end
                local count = 0
                for _ in pairs(WH.selectedRarities) do count = count + 1 end
                WindUI:Notify({
                    Title    = "Webhook Filter",
                    Content  = count .. " rarity selected",
                    Duration = 2,
                })
            end,
        })

        -- ── Filter by Mutation ────────────────────────────────────
        local _allMutationsForWH = {
            "Golden", "Diamond", "Plasma", "Molten", "Radioactive",
            "Shadow", "Electrified", "Rainbow", "Astral",
            "Wet", "Alien", "Bacon", "Virus", "Void", "Enchanted", "Phantom",
            "Volcanic",
        }

        local whMutationValues = {}
        for _, m in ipairs(_allMutationsForWH) do
            table.insert(whMutationValues, { Title = m })
        end
        local _whMutDropdownReady = false
        WHSec:Dropdown({
            Title    = "Mutation Filter",
            Values   = whMutationValues,
            Multi    = true,
            Callback = function(selected)
                if not _whMutDropdownReady then
                    _whMutDropdownReady = true
                    return
                end
                WH.selectedMutations = {}
                for key, v in pairs(selected) do
                    local title = type(v) == "table" and v.Title or key
                    WH.selectedMutations[string.lower(title)] = true
                    WH.selectedMutations[title] = true
                end
                local cnt2 = 0
                for _, m in ipairs(_allMutationsForWH) do
                    if WH.selectedMutations[m] then cnt2 = cnt2 + 1 end
                end
                WindUI:Notify({
                    Title    = "Webhook Filter",
                    Content  = cnt2 .. " mutation selected",
                    Duration = 2,
                })
            end,
        })

        WHSec:Toggle({
            Title    = "Enable Notify",
            Default  = false,
            Callback = function(v)
                WH.notifyAll = v
                if v then
                    WH.filterByRarity   = false
                    WH.filterByMutation = false
                end
                WindUI:Notify({
                    Title    = "Webhook",
                    Content  = v and "Notify all rarities" or "Notify all off",
                    Duration = 2,
                })
            end,
        })

        WHSec:Toggle({
            Title = "Enable Webhook Monitor",
            Default = false,
            Callback = function(v)
                WH.enabled = v
                if v then
                    if WH.url == "" then
                        WindUI:Notify({
                            Title = "Webhooks",
                            Content = "Set a Webhook URL first!",
                            Duration = 3,
                        })
                        WH.enabled = false
                        return
                    end
                    startWebhookMonitor()
                    WindUI:Notify({
                        Title = "Webhooks",
                        Content = "Monitor enabled",
                        Duration = 2
                    })
                else
                    stopWebhookMonitor()
                    WindUI:Notify({
                        Title = "Webhooks",
                        Content = "Monitor disabled",
                        Duration = 2
                    })
                end
            end,
        })
        WHSec:Space({ Columns = 0.5 })
        WHSec:Toggle({
            Title    = "Anonymous",
            Type     = "Checkbox",
            Desc     = "Hide your username from webhook",
            Default  = false,
            Callback = function(v)
                WH.anonymous = v
                WindUI:Notify({
                    Title    = "Webhook",
                    Content  = v and "Anonymous enabled" or "Anonymous disabled",
                    Duration = 2,
                })
            end,
        })
        WHSec:Button({
            Title = "Test Webhook",
            Icon = "solar:plain-2-bold-duotone",
            Justify = "Center",
            Callback = function()
                if WH.url == "" then
                    WindUI:Notify({
                        Title = "Webhooks",
                        Content = "Set a Webhook URL first!",
                        Duration = 3
                    })
                    return
                end
                task.spawn(function()
                    local HS = game:GetService("HttpService")
                    local req = (syn and syn.request) or http_request or request
                    local payload = {
                        username   = "Luxvs Community Webhook",
                        avatar_url =
                        "https://cdn.discordapp.com/attachments/1483239061069103224/1505974481028386836/luxvers.png?ex=6a0c9387&is=6a0b4207&hm=6bad2cd6e76d208310b4e9e2292d6a65346221abda4d1bd8b56b47203d21d298",
                        embeds     = {
                            {
                                title       = "Webhook Connected",
                                description = "Your webhook has been successfully connected to **Luxvs Community!**",
                                color       = 0x57F287,
                                image       = {
                                    url =
                                    "https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExaTU0NmN2bjE3aG5xY2xoZnEyMGJiNWwweHJ0MGM4dmJtejNvOGdreCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/g88xUM1rTwjfLhoRYP/giphy.gif"
                                },
                                footer      = {
                                    text = "Luxvs Community • Webhook Test"
                                },
                                timestamp   = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                            }
                        },
                    }
                    pcall(function()
                        req({
                            Url     = WH.url,
                            Method  = "POST",
                            Headers = { ["Content-Type"] = "application/json" },
                            Body    = HS:JSONEncode(payload),
                        })
                    end)
                end)
                WindUI:Notify({
                    Title    = "Webhook",
                    Content  = "Test connected sent!",
                    Duration = 3,
                })
            end,
        })

        WHSec:Button({
            Title   = "Send Backpack to Webhook",
            Icon    = "solar:bag-bold-duotone",
            Justify = "Center",
            Color   = Color3.fromHex("#7EB8A8"),
            Callback = function()
                if WH.url == "" then
                    WindUI:Notify({
                        Title    = "Webhooks",
                        Content  = "Set a Webhook URL first!",
                        Duration = 3,
                    })
                    return
                end
                task.spawn(sendBackpackWebhook)
            end,
        })
    end

    local SellTab = MainCore:Tab({
        Title = "Merchants",
        Icon = "solar:cart-large-minimalistic-bold",
        IconColor = Color3.fromHex("#3A9660"),

    })
    local SellSec = SellTab:Section({
        Title  = "Sell Features",
        Icon   = "solar:tag-price-bold-duotone",
        Box    = true,
        Opened = false
    })

    SellSec:Button({
        Title = "Sell All",
        Icon = "trash-2",
        Callback = function()
            local Event = game:GetService("ReplicatedStorage")
                .Shared.Packages.Network.ref_B_SellAll
            pcall(function()
                Event:InvokeServer()
            end)
            WindUI:Notify({
                Title = "Sell",
                Content = "Successfully sold all items!",
                Duration = 2
            })
        end,
    })

    SellSec:Toggle({
        Title = "Auto Sell All",
        Icon = "repeat",
        Default = false,
        Callback = function(v)
            S.autoSellAll = v
            if v then
                WindUI:Notify({
                    Title = "Auto Sell",
                    Content = "Auto Sell All enabled",
                    Duration = 2
                })
                S._sellAllConn = task.spawn(function()
                    while S.autoSellAll do
                        pcall(function()
                            game:GetService("ReplicatedStorage")
                                .Shared.Packages.Network.ref_B_SellAll:InvokeServer()
                        end)
                        task.wait(0.5)
                    end
                end)
            else
                S.autoSellAll = false
                WindUI:Notify({
                    Title = "Auto Sell",
                    Content = "Auto Sell All disabled",
                    Duration = 2
                })
            end
        end,
    })

    SellSec:Button({
        Title = "Sell Equipped",
        Icon = "package",
        Callback = function()
            local Event = game:GetService("ReplicatedStorage")
                .Shared.Packages.Network.ref_B_Sell
            pcall(function()
                Event:InvokeServer()
            end)
            WindUI:Notify({
                Title = "Sell",
                Content = "Successfully sold equipped items!",
                Duration = 2
            })
        end,
    })
    SellSec:Space({
        Columns = 0.5
    })
    SellTab:Space({
        Columns = 0.5
    })

    do
        local SellRaritySec = SellTab:Section({
            Title = "Sell by Rarity",
            Icon = "solar:star-bold-duotone",
            Box = true,
            Opened = false,
        })

        local _sellBrainrotLookup = {}
        for _, entry in ipairs(ALL_BRAINROTS) do
            _sellBrainrotLookup[entry.name] = entry.rarity
        end

        local _sellRarityOrder = {
            "Common",
            "Rare",
            "Epic",
            "Legendary",
            "Mythic",
            "Exclusive",
            "Godly",
            "Secret",
            "Divine",
            "Hacked",
            "OG",
            "Celestial",
            "Eternal",
        }

        local _sellSelectedRarities = {}

        local _sellRarDropValues = {}
        for _, r in ipairs(_sellRarityOrder) do
            table.insert(_sellRarDropValues, {
                Title = r
            })
        end

        local _sellRarDropReady = false
        SellRaritySec:Dropdown({
            Title = "Sell Rarity",
            Values = _sellRarDropValues,
            Multi = true,
            Callback = function(selected)
                if not _sellRarDropReady then
                    _sellRarDropReady = true
                    return
                end
                _sellSelectedRarities = {}
                for key, v in pairs(selected) do
                    local title = type(v) == "table" and v.Title or key
                    _sellSelectedRarities[title] = true
                end
                local count = 0
                for _ in pairs(_sellSelectedRarities) do
                    count = count + 1
                end
                WindUI:Notify({
                    Title = "Sell by Rarity",
                    Content = count > 0 and (count .. " rarity selected") or "No rarity selected",
                    Duration = 2,
                })
            end,
        })

        SellRaritySec:Button({
            Title = "Sell by Rarity (Once)",
            Icon = "solar:star-bold-duotone",
            Callback = function()
                if next(_sellSelectedRarities) == nil then
                    WindUI:Notify({
                        Title = "Sell by Rarity",
                        Content = "Select at least one rarity first!",
                        Duration = 3
                    })
                    return
                end
                task.spawn(function()
                    local SellEvent = game:GetService("ReplicatedStorage").Shared.Packages.Network.ref_B_Sell
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                    if not (hum and backpack) then
                        WindUI:Notify({
                            Title = "Sell by Rarity",
                            Content = "Character not ready!",
                            Duration = 2
                        })
                        return
                    end
                    local soldCount = 0

                    local toSell = {}
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            local rarity = _sellBrainrotLookup[tool.Name]
                            if rarity and _sellSelectedRarities[rarity] then
                                table.insert(toSell, tool)
                            end
                        end
                    end
                    for _, tool in ipairs(toSell) do
                        if tool.Parent == backpack then
                            pcall(function()
                                hum:EquipTool(tool)
                            end)
                            task.wait(0.3)
                            pcall(function()
                                SellEvent:InvokeServer()
                            end)
                            task.wait(0.3)
                            soldCount = soldCount + 1
                        end
                    end
                    WindUI:Notify({
                        Title = "Sell by Rarity",
                        Content = "Sold " .. soldCount .. " item(s)!",
                        Duration = 3,
                    })
                end)
            end,
        })

        SellRaritySec:Toggle({
            Title = "Auto Sell by Rarity",
            Icon = "repeat",
            Default = false,
            Callback = function(v)
                S.autoSellByRarity = v
                if v then
                    if next(_sellSelectedRarities) == nil then
                        WindUI:Notify({
                            Title = "Auto Sell by Rarity",
                            Content = "Select at least one rarity first!",
                            Duration = 3
                        })
                        S.autoSellByRarity = false
                        return
                    end
                    WindUI:Notify({
                        Title = "Auto Sell by Rarity",
                        Content = "Enabled",
                        Duration = 2
                    })
                    S._sellRarityConn = task.spawn(function()
                        local SellEvent = game:GetService("ReplicatedStorage").Shared.Packages.Network.ref_B_Sell
                        while S.autoSellByRarity do
                            local char = LocalPlayer.Character
                            local hum = char and char:FindFirstChildOfClass("Humanoid")
                            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                            if hum and backpack then
                                local toSell = {}
                                for _, tool in ipairs(backpack:GetChildren()) do
                                    if tool:IsA("Tool") then
                                        local rarity = _sellBrainrotLookup[tool.Name]
                                        if rarity and _sellSelectedRarities[rarity] then
                                            table.insert(toSell, tool)
                                        end
                                    end
                                end
                                for _, tool in ipairs(toSell) do
                                    if not S.autoSellByRarity then
                                        break
                                    end
                                    if tool.Parent == backpack then
                                        pcall(function()
                                            hum:EquipTool(tool)
                                        end)
                                        task.wait(0.3)
                                        pcall(function()
                                            SellEvent:InvokeServer()
                                        end)
                                        task.wait(0.3)
                                    end
                                end
                            end
                            task.wait(1)
                        end
                    end)
                else
                    S.autoSellByRarity = false
                    WindUI:Notify({
                        Title = "Auto Sell by Rarity",
                        Content = "Disabled",
                        Duration = 2
                    })
                end
            end,
        })
    end

    SellTab:Space({ Columns = 0.5 })

    do
        local SellMutationSec = SellTab:Section({
            Title  = "Sell by Mutation",
            Icon   = "solar:atom-bold-duotone",
            Box    = true,
            Opened = false,
        })

        local _sellMutBrainrotLookup = {}
        for _, entry in ipairs(ALL_BRAINROTS) do
            _sellMutBrainrotLookup[entry.name] = true
        end

        local _sellMutationList = {
            "Normal",
            "Golden", "Diamond", "Plasma", "Molten", "Radioactive",
            "Shadow", "Electrified", "Rainbow", "Astral", "Volcanic",
            "Wet", "Alien", "Bacon", "Virus", "Void", "Enchanted", "Phantom",
        }

        local _sellSelectedMutations = {}

        local _sellMutDropValues = {}
        for _, m in ipairs(_sellMutationList) do
            table.insert(_sellMutDropValues, { Title = m })
        end

        local function getToolMutation(tool)
            local ok, mut = pcall(function()
                local h = tool:FindFirstChild("Handle")
                if h then return h:GetAttribute("Mutation") end
                return nil
            end)
            if ok and mut and not NORMAL_MUTATION_VALUES[string.lower(tostring(mut))] then
                return tostring(mut)
            end
            local ok2, mut2 = pcall(function() return tool:GetAttribute("Mutation") end)
            if ok2 and mut2 and not NORMAL_MUTATION_VALUES[string.lower(tostring(mut2))] then
                return tostring(mut2)
            end
            return "Normal"
        end

        local _sellMutDropReady = false
        SellMutationSec:Dropdown({
            Title    = "Sell Mutation",
            Values   = _sellMutDropValues,
            Multi    = true,
            Callback = function(selected)
                if not _sellMutDropReady then
                    _sellMutDropReady = true
                    return
                end
                _sellSelectedMutations = {}
                for key, v in pairs(selected) do
                    local title = type(v) == "table" and v.Title or key
                    _sellSelectedMutations[title] = true
                    _sellSelectedMutations[string.lower(title)] = true
                end
                local cnt = 0
                for _, m in ipairs(_sellMutationList) do
                    if _sellSelectedMutations[m] then cnt = cnt + 1 end
                end
                WindUI:Notify({
                    Title    = "Sell by Mutation",
                    Content  = cnt > 0 and (cnt .. " mutation selected") or "No mutation selected",
                    Duration = 2,
                })
            end,
        })

        SellMutationSec:Button({
            Title    = "Sell by Mutation (Once)",
            Icon     = "solar:atom-bold-duotone",
            Callback = function()
                if next(_sellSelectedMutations) == nil then
                    WindUI:Notify({
                        Title    = "Sell by Mutation",
                        Content  = "Select at least one mutation first!",
                        Duration = 3
                    })
                    return
                end
                task.spawn(function()
                    local SellEvent = game:GetService("ReplicatedStorage").Shared.Packages.Network.ref_B_Sell
                    local char      = LocalPlayer.Character
                    local hum       = char and char:FindFirstChildOfClass("Humanoid")
                    local backpack  = LocalPlayer:FindFirstChildOfClass("Backpack")
                    if not (hum and backpack) then
                        WindUI:Notify({
                            Title    = "Sell by Mutation",
                            Content  = "Character not ready!",
                            Duration = 2
                        })
                        return
                    end
                    local toSell = {}
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") and _sellMutBrainrotLookup[tool.Name] then
                            local mut = getToolMutation(tool)
                            if mut and (_sellSelectedMutations[mut] or _sellSelectedMutations[string.lower(mut)]) then
                                table.insert(toSell, tool)
                            end
                        end
                    end
                    local soldCount = 0
                    for _, tool in ipairs(toSell) do
                        if tool.Parent == backpack then
                            pcall(function() hum:EquipTool(tool) end)
                            task.wait(0.3)
                            pcall(function() SellEvent:InvokeServer() end)
                            task.wait(0.3)
                            soldCount = soldCount + 1
                        end
                    end
                    WindUI:Notify({
                        Title    = "Sell by Mutation",
                        Content  = "Sold " .. soldCount .. " item(s)!",
                        Duration = 3,
                    })
                end)
            end,
        })

        SellMutationSec:Toggle({
            Title    = "Auto Sell by Mutation",
            Icon     = "repeat",
            Default  = false,
            Callback = function(v)
                S.autoSellByMutation = v
                if v then
                    if next(_sellSelectedMutations) == nil then
                        WindUI:Notify({
                            Title    = "Auto Sell by Mutation",
                            Content  = "Select at least one mutation first!",
                            Duration = 3
                        })
                        S.autoSellByMutation = false
                        return
                    end
                    WindUI:Notify({
                        Title    = "Auto Sell by Mutation",
                        Content  = "Enabled",
                        Duration = 2
                    })
                    S._sellMutationConn = task.spawn(function()
                        local SellEvent = game:GetService("ReplicatedStorage").Shared.Packages.Network.ref_B_Sell
                        while S.autoSellByMutation do
                            local char     = LocalPlayer.Character
                            local hum      = char and char:FindFirstChildOfClass("Humanoid")
                            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                            if hum and backpack then
                                local toSell = {}
                                for _, tool in ipairs(backpack:GetChildren()) do
                                    if tool:IsA("Tool") and _sellMutBrainrotLookup[tool.Name] then
                                        local mut = getToolMutation(tool)
                                        if mut and (_sellSelectedMutations[mut] or _sellSelectedMutations[string.lower(mut)]) then
                                            table.insert(toSell, tool)
                                        end
                                    end
                                end
                                for _, tool in ipairs(toSell) do
                                    if not S.autoSellByMutation then break end
                                    if tool.Parent == backpack then
                                        pcall(function() hum:EquipTool(tool) end)
                                        task.wait(0.3)
                                        pcall(function() SellEvent:InvokeServer() end)
                                        task.wait(0.3)
                                    end
                                end
                            end
                            task.wait(1)
                        end
                    end)
                else
                    S.autoSellByMutation = false
                    WindUI:Notify({
                        Title    = "Auto Sell by Mutation",
                        Content  = "Disabled",
                        Duration = 2
                    })
                end
            end,
        })
    end

    local ShopTab = MainCore:Tab({
        Title = "Purchases",
        Icon = "solar:library-bold",
        IconColor = Color3.fromHex("#B09020"),

    })
    local ShopSec = ShopTab:Section({
        Title  = "Upgrade Features",
        Icon   = "solar:rocket-bold-duotone",
        Box    = true,
        Opened = false
    })

    local SpeedUpgradeAmount = 1
    local PlotUpgradeAmount = 1

    ShopSec:Input({
        Title = "Speed Upgrade Amount",
        Placeholder = "Default 1",
        Value = "1",
        Callback = function(text)
            local num = tonumber(text)
            if num and num > 0 then
                SpeedUpgradeAmount = math.floor(num)
            else
                SpeedUpgradeAmount = 1
            end
        end,
    })
    ShopSec:Button({
        Title = "Upgrade Speed",
        Icon = "zap",
        Callback = function()
            local Event = game:GetService("ReplicatedStorage")
                .Shared.Packages.Network.rev_SPEED_UPGRADE
            pcall(function()
                Event:FireServer(SpeedUpgradeAmount)
            end)
            WindUI:Notify({
                Title = "Shop",
                Content = "Speed upgraded x" .. tostring(SpeedUpgradeAmount),
                Duration = 2
            })
        end,
    })
    ShopSec:Space({
        Columns = 0.5
    })

    ShopSec:Input({
        Title = "Plot Upgrade Amount",
        Placeholder = "Max 30",
        Value = "1",
        Callback = function(text)
            local num = tonumber(text)
            if num then
                num = math.floor(num)
                if num < 1 then
                    num = 1
                elseif num > 30 then
                    num = 30
                end
                PlotUpgradeAmount = num
            else
                PlotUpgradeAmount = 1
            end
        end,
    })
    ShopSec:Button({
        Title = "Upgrade Plot",
        Icon = "home",
        Callback = function()
            local Event = game:GetService("ReplicatedStorage")
                .Shared.Packages.Network.rev_bs_upgrade
            pcall(function()
                for i = 1, PlotUpgradeAmount do
                    Event:FireServer()
                    task.wait()
                end
            end)
            WindUI:Notify({
                Title = "Shop",
                Content = "Plot upgraded x" .. tostring(PlotUpgradeAmount),
                Duration = 2
            })
        end,
    })

    ShopTab:Space({
        Columns = 0.5
    })
    local WeightSec = ShopTab:Section({
        Title  = "Buy Weight",
        Icon   = "solar:dumbell-bold-duotone",
        Box    = true,
        Opened = false
    })
    local SelectedWeight = "Bone Barbell"
    WeightSec:Dropdown({
        Title = "Select Weight",
        Values = {
            {
                Title = "Bone Barbell"
            },
            {
                Title = "Stone Block"
            },
            {
                Title = "Copper Plate"
            },
            {
                Title = "Iron Plate"
            },
            {
                Title = "Ice Barbell"
            },
            {
                Title = "Donut Barbell"
            },
            {
                Title = "Golden Barbell"
            },
            {
                Title = "Heaven Plate"
            },
            {
                Title = "Mega Golden Barbell"
            },
            {
                Title = "Neon Pulse"
            },
            {
                Title = "Giant Gold Star Barbell"
            },
            {
                Title = "Emerald Barbell"
            },
        },
        Default = 1,
        Callback = function(option)
            SelectedWeight = option.Title
        end,
    })
    WeightSec:Button({
        Title = "Buy Weight",
        Icon = "shopping-cart",
        Callback = function()
            local Event = game:GetService("ReplicatedStorage")
                .Shared.Packages.Network.rev_Shop_Buy
            pcall(function()
                Event:FireServer("WeightShop", SelectedWeight)
            end)
            WindUI:Notify({
                Title = "Shop",
                Content = "Purchased: " .. SelectedWeight,
                Duration = 2
            })
        end,
    })

    local MV = {
        noclipEnabled = false,
        noclipConn = nil,
        infJumpEnabled = false,
        isTpWalkEnabled = false,
        tpWalkSpeed = 1,
    }



    local function enableNoclip()
        if MV.noclipConn then
            MV.noclipConn:Disconnect()
        end
        MV.noclipConn = RunService.Stepped:Connect(function()
            if not MV.noclipEnabled then
                return
            end
            local char = LocalPlayer.Character
            if not char then
                return
            end
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end)
    end
    local function disableNoclip()
        if MV.noclipConn then
            MV.noclipConn:Disconnect()
            MV.noclipConn = nil
        end
        local char = LocalPlayer.Character
        if not char then
            return
        end
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = true
            end
        end
    end





    local tpWalkConn_MV
    local function startTpWalk()
        if tpWalkConn_MV then
            tpWalkConn_MV:Disconnect()
        end
        tpWalkConn_MV = RunService.Heartbeat:Connect(function()
            if not MV.isTpWalkEnabled or not LocalPlayer.Character then
                return
            end
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then
                return
            end
            local dir = hum.MoveDirection
            if dir.Magnitude > 0 then
                hrp.CFrame = CFrame.new(hrp.Position + dir * (MV.tpWalkSpeed / 10))
            end
        end)
    end
    LocalPlayer.CharacterAdded:Connect(function(c)
        task.defer(function()
            if MV.noclipEnabled then
                task.wait(0.5)
                enableNoclip()
            end
        end)
    end)

    local Lock = {
        position = false,
        cframe = nil,
        animConn = nil
    }
    local function lockPosition()
        local char = LocalPlayer.Character
        if not char then
            return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then
            return
        end
        if not Lock.cframe then
            Lock.cframe = root.CFrame
        end
        hum.AutoRotate = false
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        root.Anchored = true
        root.CFrame = Lock.cframe
    end
    local function unlockPosition()
        local char = LocalPlayer.Character
        if not char then
            return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then
            return
        end
        root.Anchored = false
        hum.AutoRotate = true
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end

    task.spawn(function()
        while task.wait(0.5) do
            if Lock.position then
                pcall(lockPosition)
            end
        end
    end)
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        Lock.cframe = nil
        if Lock.position then
            lockPosition()
        end
    end)

    local AntiLag = {}
    function AntiLag.removeVisualEffects()
        local n = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj:Destroy()
                n = n + 1
            end
        end
        WindUI:Notify({
            Title = "Anti-Lag",
            Content = "Removed " .. n .. " visual effects.",
            Duration = 3
        })
    end

    function AntiLag.removeAllTextures()
        local n = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                for _, t in ipairs(obj:GetChildren()) do
                    if t:IsA("Texture") or t:IsA("Decal") then
                        t:Destroy()
                        n = n + 1
                    end
                end
                obj.Material = Enum.Material.Plastic
            end
        end
        WindUI:Notify({
            Title = "Anti-Lag",
            Content = "Removed textures from " .. n .. " objects.",
            Duration = 3
        })
    end

    function AntiLag.simplifyMeshes()
        local n = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("MeshPart") then
                local np = Instance.new("Part")
                np.Name = obj.Name
                np.Size = obj.Size
                np.Position = obj.Position
                np.Orientation = obj.Orientation
                np.Anchored = obj.Anchored
                np.CanCollide = obj.CanCollide
                np.Transparency = obj.Transparency
                np.Material = Enum.Material.Plastic
                np.Color = Color3.new(0.5, 0.5, 0.5)
                np.Parent = obj.Parent
                obj:Destroy()
                n = n + 1
            elseif obj:IsA("SpecialMesh") then
                obj:Destroy()
                n = n + 1
            end
        end
        WindUI:Notify({
            Title = "Anti-Lag",
            Content = "Simplified " .. n .. " mesh objects.",
            Duration = 3
        })
    end

    function AntiLag.optimizeLighting()
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("BloomEffect") or e:IsA("BlurEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("SunRaysEffect") or e:IsA("DepthOfFieldEffect") then
                e.Enabled = false
            end
        end
        WindUI:Notify({
            Title = "Anti-Lag",
            Content = "Lighting optimized.",
            Duration = 3
        })
    end

    function AntiLag.restoreLighting()
        Lighting.GlobalShadows = true
        Lighting.ShadowSoftness = 0.5
        Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("BloomEffect") or e:IsA("BlurEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("SunRaysEffect") or e:IsA("DepthOfFieldEffect") then
                e.Enabled = true
            end
        end
        WindUI:Notify({
            Title = "Anti-Lag",
            Content = "Lighting restored.",
            Duration = 3
        })
    end

    function AntiLag.removeAllSounds()
        local n = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Sound") then
                obj:Destroy()
                n = n + 1
            end
        end
        WindUI:Notify({
            Title = "Anti-Lag",
            Content = "Removed " .. n .. " sounds.",
            Duration = 3
        })
    end

    local AS = {
        active = false,
        groupId = 35102746,
        conn = nil
    }
    function AS.isStaff(plr)
        if plr == LocalPlayer then
            return false
        end
        local ok, rank = pcall(function()
            return plr:GetRankInGroup(AS.groupId)
        end)
        if ok and rank > 0 then
            local ok2, role = pcall(function()
                return plr:GetRoleInGroup(AS.groupId)
            end)
            if ok2 and role then
                local r = role:lower()
                if r:find("moderator") or r:find("staff") or r:find("dev") or r:find("admin") or rank >= 50 then
                    return true, role .. " (Rank: " .. rank .. ")"
                end
            end
        end
        return false
    end

    function AS.leaveServer()
        WindUI:Notify({
            Title = "LEAVING SERVER",
            Content = "Staff detected!",
            Duration = 2
        })
        task.wait(2)
        TeleportService:Teleport(game.PlaceId)
    end

    function AS.toggleAntiStaff(enabled)
        AS.active = enabled
        if AS.conn then
            AS.conn:Disconnect()
            AS.conn = nil
        end
        if enabled then
            task.spawn(function()
                for _, plr in ipairs(Players:GetPlayers()) do
                    local isS, role = AS.isStaff(plr)
                    if isS then
                        WindUI:Notify({
                            Title = "STAFF DETECTED",
                            Content = plr.Name .. " (" .. role .. ")",
                            Duration = 2
                        })
                        AS.leaveServer()
                        return
                    end
                end
            end)
            AS.conn = Players.PlayerAdded:Connect(function(plr)
                task.wait(2)
                if AS.active then
                    local isS, role = AS.isStaff(plr)
                    if isS then
                        WindUI:Notify({
                            Title = "STAFF JOINED",
                            Content = plr.Name .. " (" .. role .. ")",
                            Duration = 2
                        })
                        AS.leaveServer()
                    end
                end
            end)
            WindUI:Notify({
                Title = "Anti-Staff",
                Content = "Protection activated",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "Anti-Staff",
                Content = "Protection deactivated",
                Duration = 2
            })
        end
    end

    do
        local PlayerTab = MainCore:Tab({
            Title = "Movements",
            Icon = "solar:user-circle-bold",
            IconColor = Color3.fromHex("#C05090"),

        })
        local MovementSection = PlayerTab:Section({
            Title = "Movements",
            Icon = "solar:ufo-3-bold",
            Box = true,
            BoxBorder = true,
            Opened = false,
        })

        MovementSection:Toggle({
            Title = "Noclip",
            Default = false,
            Callback = function(v)
                MV.noclipEnabled = v
                if v then
                    enableNoclip()
                    WindUI:Notify({
                        Title = "Noclip",
                        Content = "Enabled",
                        Duration = 2
                    })
                else
                    disableNoclip()
                    WindUI:Notify({
                        Title = "Noclip",
                        Content = "Disabled",
                        Duration = 2
                    })
                end
            end,
        })
        local jumpConn_MV
        MovementSection:Toggle({
            Title = "Infinite Jump",
            Default = false,
            Callback = function(v)
                MV.infJumpEnabled = v
                if jumpConn_MV then
                    jumpConn_MV:Disconnect()
                    jumpConn_MV = nil
                end
                if v then
                    jumpConn_MV = UserInputService.JumpRequest:Connect(function()
                        if MV.infJumpEnabled and LocalPlayer.Character then
                            local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                            if h then
                                h:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                        end
                    end)
                end
            end,
        })

        MovementSection:Input({
            Title = "JumpHeight",
            Desc = "Jump height (20-200)",
            Value = "50",
            Placeholder = "Enter value",
            Callback = function(input)
                local n = tonumber(input)
                if n and n >= 20 and n <= 200 then
                    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if h then
                        if h.UseJumpPower then
                            h.JumpPower = n
                        else
                            h.JumpHeight = n / 10
                        end
                    end
                end
            end,
        })
        MovementSection:Input({
            Title = "Field of View",
            Desc = "Camera FOV (60-120)",
            Value = "70",
            Placeholder = "Enter value",
            Callback = function(input)
                local n = tonumber(input)
                if n and n >= 60 and n <= 120 and Workspace.CurrentCamera then
                    Workspace.CurrentCamera.FieldOfView = n
                end
            end,
        })
        MovementSection:Button({
            Title = "Reset Default",
            Callback = function()
                local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if h then
                    h.WalkSpeed = 16
                    if h.UseJumpPower then
                        h.JumpPower = 50
                    else
                        h.JumpHeight = 5
                    end
                end
                if Workspace.CurrentCamera then
                    Workspace.CurrentCamera.FieldOfView = 70
                end
                WindUI:Notify({
                    Title = "Reset",
                    Content = "Values restored to default",
                    Duration = 2
                })
            end,
        })

        MovementSection:Toggle({
            Title = "God Mode",
            Desc = "Locks health to max every frame, preventing death",
            Default = false,
            Callback = function(v)
                if v then
                    startGodMode()
                    WindUI:Notify({ Title = "God Mode", Content = "ON", Duration = 2 })
                else
                    stopGodMode()
                    WindUI:Notify({ Title = "God Mode", Content = "OFF", Duration = 2 })
                end
            end,
        })
        PlayerTab:Space({
            Columns = 0.5
        })
        local AnimeSection = PlayerTab:Section({
            Title = "Animations",
            Icon = "solar:stop-circle-bold",
            Box = true,
            BoxBorder = true,
            Opened = false,
        })
        AnimeSection:Toggle({
            Title = "Lock Position",
            Default = false,
            Callback = function(v)
                Lock.position = v
                if v then
                    Lock.cframe = nil
                else
                    unlockPosition()
                end
            end,
        })

        PlayerTab:Space({
            Columns = 0.5
        })
        local BypassSection = PlayerTab:Section({
            Title = "Movement Bypass",
            Icon = "solar:info-square-bold",
            Box = true,
            BoxBorder = true,
            Opened = false,
        })
        BypassSection:Toggle({
            Title = "TP Walk",
            Default = false,
            Callback = function(v)
                MV.isTpWalkEnabled = v
                if v then
                    startTpWalk()
                elseif tpWalkConn_MV then
                    tpWalkConn_MV:Disconnect()
                    tpWalkConn_MV = nil
                end
            end,
        })
        BypassSection:Slider({
            Title = "TP Walk Multiplier",
            Step = 1,
            Value = {
                Min = 1,
                Max = 50,
                Default = MV.tpWalkSpeed
            },
            Callback = function(v)
                MV.tpWalkSpeed = v
            end,
        })
    end

    local _toggleAntiAFK
    local _toggleAutoReconnect
    local _toggleAutoRejoinKick
    local antiAFK = _cfg.antiAfk or false
    local afkConn = nil
    local autoReconnect = _cfg.autoReconnect or false
    local autoRejoinOnKick = _cfg.autoRejoinKick or false
    do
        local MiscTab = MainCore:Tab({
            Title = "Miscellaneous",
            Icon = "solar:settings-bold",
            IconColor = Color3.fromHex("#607888"),

        })
        local ConnectionSection = MiscTab:Section({
            Title = "Connection Features",
            Icon = "solar:login-2-bold",
            Box = true,
            Opened = false,
        })
        _toggleAntiAFK = ConnectionSection:Toggle({
            Title = "Anti AFK",
            Default = _cfg.antiAfk or false,
            Callback = function(v)
                antiAFK = v
                _cfg.antiAfk = v
                _saveCfg()
                if v then
                    local VI_User = game:GetService("VirtualUser")
                    afkConn = LocalPlayer.Idled:Connect(function()
                        if antiAFK then
                            VI_User:CaptureController()
                            VI_User:ClickButton2(Vector2.new())
                        end
                    end)
                    WindUI:Notify({
                        Title = "Player",
                        Content = "Anti AFK enabled",
                        Duration = 2
                    })
                else
                    if afkConn then
                        afkConn:Disconnect()
                        afkConn = nil
                    end
                    WindUI:Notify({
                        Title = "Player",
                        Content = "Anti AFK disabled",
                        Duration = 2
                    })
                end
            end,
        })
        _toggleAutoReconnect = ConnectionSection:Toggle({
            Title = "Auto Reconnect",
            Default = _cfg.autoReconnect or false,
            Callback = function(v)
                autoReconnect = v
                _cfg.autoReconnect = v
                _saveCfg()
                WindUI:Notify({
                    Title = "Player",
                    Content = v and "Auto Reconnect enabled" or "Auto Reconnect disabled",
                    Duration = 2,
                })
            end,
        })
        task.spawn(function()
            local prompt = game.CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
            prompt.ChildAdded:Connect(function()
                if autoReconnect then
                    task.wait(2)
                    pcall(function()
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end)
                end
            end)
        end)

        _toggleAutoRejoinKick = ConnectionSection:Toggle({
            Title    = "Auto Rejoin on Kick",
            Desc     = "Rejoin when kicked by server (not crash)",
            Default  = _cfg.autoRejoinKick or false,
            Callback = function(v)
                autoRejoinOnKick = v
                _cfg.autoRejoinKick = v
                _saveCfg()
                WindUI:Notify({
                    Title    = "Auto Rejoin",
                    Content  = v and "Will rejoin if kicked" or "Disabled",
                    Duration = 2,
                })
            end,
        })
        task.spawn(function()
            local kicked = false
            LocalPlayer.OnTeleport:Connect(function(state)
                if state == Enum.TeleportState.Started then
                    kicked = true
                end
            end)
            game.Close:Connect(function()
                if not autoRejoinOnKick then return end
                if kicked then return end
                pcall(function()
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end)
            end)
            pcall(function()
                local prompt = game.CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
                prompt.ChildAdded:Connect(function()
                    if not autoRejoinOnKick then return end
                    task.wait(2)
                    pcall(function()
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end)
                end)
            end)
        end)
        local instantInteract = false
        local _instantInteractConn = nil
        local function applyInstantInteract()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0
                end
            end
        end
        ConnectionSection:Toggle({
            Title = "Instant Interact",
            Default = false,
            Callback = function(v)
                instantInteract = v
                if v then
                    applyInstantInteract()
                    _instantInteractConn = workspace.DescendantAdded:Connect(function(d)
                        if instantInteract and d:IsA("ProximityPrompt") then
                            d.HoldDuration = 0
                        end
                    end)
                    WindUI:Notify({
                        Title = "Instant Interact",
                        Content = "Enabled",
                        Duration = 2
                    })
                else
                    if _instantInteractConn then
                        _instantInteractConn:Disconnect()
                        _instantInteractConn = nil
                    end
                    WindUI:Notify({
                        Title = "Instant Interact",
                        Content = "Disabled",
                        Duration = 2
                    })
                end
            end,
        })
        MiscTab:Space({
            Columns = 0.5
        })
        local ServerSection = MiscTab:Section({
            Title = "Server Features",
            Icon = "solar:slider-vertical-bold-duotone",
            Box = true,
            Opened = false,
        })
        local targetServerId = ""
        ServerSection:Button({
            Title = "Copy Server ID",
            Callback = function()
                local jobId = game.JobId
                setclipboard(jobId)
                WindUI:Notify({
                    Title = "Server ID",
                    Content = "Copied: " .. jobId,
                    Duration = 3
                })
            end,
        })
        ServerSection:Input({
            Title = "Server ID",
            Placeholder = "Paste Server ID...",
            Callback = function(v)
                targetServerId = v
            end,
        })
        ServerSection:Button({
            Title = "Join Server ID",
            Callback = function()
                if targetServerId == "" then
                    WindUI:Notify({
                        Title = "Join Server",
                        Content = "Input Server ID first",
                        Duration = 2
                    })
                    return
                end
                task.spawn(function()
                    WindUI:Notify({
                        Title = "Join Server",
                        Content = "Joining...",
                        Duration = 3
                    })
                    task.wait(1)
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServerId, LocalPlayer)
                    end)
                end)
            end,
        })
        ServerSection:Button({
            Title = "Server Hop",
            Callback = function()
                task.spawn(function()
                    WindUI:Notify({
                        Title = "Server Hop",
                        Content = "Finding new server...",
                        Duration = 3
                    })
                    local HS = game:GetService("HttpService")
                    local currentJob = game.JobId
                    local ok, result = pcall(function()
                        local response = game:HttpGet("https://games.roblox.com/v1/games/" ..
                            game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
                        return HS:JSONDecode(response)
                    end)
                    if not ok or type(result) ~= "table" or not result.data then
                        WindUI:Notify({
                            Title = "Server Hop",
                            Content = "Failed to fetch servers",
                            Duration = 3
                        })
                        return
                    end
                    for _, server in ipairs(result.data) do
                        if server.id ~= currentJob and server.playing and server.maxPlayers and server.playing < server.maxPlayers then
                            pcall(function()
                                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                            end)
                            return
                        end
                    end
                    WindUI:Notify({
                        Title = "Server Hop",
                        Content = "No available server found",
                        Duration = 3
                    })
                end)
            end,
        })
        ServerSection:Button({
            Title = "Rejoin Server",
            Callback = function()
                task.spawn(function()
                    WindUI:Notify({
                        Title = "Rejoin",
                        Content = "Attempting to rejoin...",
                        Duration = 3
                    })
                    task.wait(1)
                    pcall(function()
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end)
                end)
            end,
        })
        MiscTab:Space({
            Columns = 0.5
        })
        local AntiStaffSection = MiscTab:Section({
            Title = "Safety Features",
            Icon = "solar:shield-warning-bold",
            Box = true,
            BoxBorder = true,
            Opened = false,
        })
        AntiStaffSection:Toggle({
            Title = "Anti-Staff Protection",
            Desc = "Leave server when staff detected",
            Default = false,
            Callback = function(v)
                AS.toggleAntiStaff(v)
            end,
        })
        local fakeUsername = "Anonymous"
        local _realName = LocalPlayer.Name
        local _realDisplay = LocalPlayer.DisplayName
        local _realId = tostring(LocalPlayer.UserId)
        AntiStaffSection:Input({
            Title = "Fake Username",
            Placeholder = "Anonymous",
            Callback = function(v)
                if v and # v > 0 then
                    fakeUsername = v
                end
            end,
        })
        AntiStaffSection:Button({
            Title = "Hide Username",
            Icon = "solar:shield-check-bold",
            Color = Color3.fromHex("#6b31ff"),
            Callback = function()
                local function processtext(text)
                    if not text then
                        return ""
                    end
                    text = string.gsub(text, _realName, fakeUsername)
                    text = string.gsub(text, _realDisplay, fakeUsername)
                    text = string.gsub(text, _realId, "0")
                    return text
                end
                WindUI:Notify({
                    Title = "Username Hider",
                    Content = "Hidden as: " .. fakeUsername,
                    Duration = 3
                })
                pcall(function()
                    LocalPlayer.DisplayName = fakeUsername
                end)
                pcall(function()
                    LocalPlayer.CharacterAppearanceId = 13886182
                end)
                game.DescendantAdded:Connect(function(d)
                    if d:IsA("TextLabel") or d:IsA("TextBox") or d:IsA("TextButton") then
                        pcall(function()
                            d.Text = processtext(d.Text)
                            d.Name = processtext(d.Name)
                            d.Changed:Connect(function()
                                pcall(function()
                                    d.Text = processtext(d.Text)
                                    d.Name = processtext(d.Name)
                                end)
                            end)
                        end)
                    end
                end)
                task.spawn(function()
                    for i, v in ipairs(game:GetDescendants()) do
                        if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
                            pcall(function()
                                v.Text = processtext(v.Text)
                                v.Name = processtext(v.Name)
                            end)
                        end
                        if i % 100 == 0 then
                            task.wait()
                        end
                    end
                end)
            end,
        })
        MiscTab:Space({
            Columns = 0.5
        })
        local AntiLagSection = MiscTab:Section({
            Title = "Antilag Features",
            Icon = "solar:wind-bold",
            Box = true,
            BoxBorder = true,
            Opened = false,
        })
        AntiLagSection:Toggle({
            Title = "Remove Visual Effects",
            Type = "Checkbox",
            Default = false,
            Callback = function(v)
                if v then
                    AntiLag.removeVisualEffects()
                end
            end,
        })
        AntiLagSection:Toggle({
            Title = "Remove Textures",
            Type = "Checkbox",
            Default = false,
            Callback = function(v)
                if v then
                    AntiLag.removeAllTextures()
                end
            end,
        })
        AntiLagSection:Toggle({
            Title = "Simplify Meshes",
            Type = "Checkbox",
            Default = false,
            Callback = function(v)
                if v then
                    AntiLag.simplifyMeshes()
                end
            end,
        })
        local _lightingInit = false
        AntiLagSection:Toggle({
            Title = "Optimize Lighting",
            Type = "Checkbox",
            Default = false,
            Callback = function(v)
                if not _lightingInit then
                    _lightingInit = true
                    return
                end
                if v then
                    AntiLag.optimizeLighting()
                else
                    AntiLag.restoreLighting()
                end
            end,
        })
        AntiLagSection:Toggle({
            Title = "Remove Sounds",
            Type = "Checkbox",
            Default = false,
            Callback = function(v)
                if v then
                    AntiLag.removeAllSounds()
                end
            end,
        })

        MiscTab:Space({ Columns = 0.5 })
        local PingSection  = MiscTab:Section({
            Title  = "Ping Display",
            Icon   = "solar:chart-bold",
            Box    = true,
            Opened = false,
        })

        local _pingGui     = nil
        local _pingConn    = nil
        local _pingEnabled = false

        local function createPingGui()
            if _pingGui then
                pcall(function() _pingGui:Destroy() end)
            end
            local sg                                     = Instance.new("ScreenGui")
            sg.Name                                      = "KAL_PingDisplay"
            sg.ResetOnSpawn                              = false
            sg.DisplayOrder                              = 9998
            sg.ZIndexBehavior                            = Enum.ZIndexBehavior.Sibling
            sg.Parent                                    = PlayerGui

            local frame                                  = Instance.new("Frame")
            frame.Size                                   = UDim2.fromOffset(130, 54)
            frame.Position                               = UDim2.new(0, 12, 0, 12)
            frame.BackgroundColor3                       = Color3.fromRGB(15, 15, 18)
            frame.BackgroundTransparency                 = 0.25
            frame.BorderSizePixel                        = 0
            frame.ZIndex                                 = 9998
            frame.Parent                                 = sg
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
            local stroke                                 = Instance.new("UIStroke", frame)
            stroke.Color                                 = Color3.fromRGB(70, 70, 80)
            stroke.Thickness                             = 1

            local function makeRow(yOffset)
                local dot                                  = Instance.new("Frame")
                dot.Size                                   = UDim2.fromOffset(8, 8)
                dot.Position                               = UDim2.new(0, 10, 0, yOffset + 6)
                dot.BackgroundColor3                       = Color3.fromRGB(80, 220, 100)
                dot.BorderSizePixel                        = 0
                dot.ZIndex                                 = 9999
                dot.Parent                                 = frame
                Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

                local lbl                                  = Instance.new("TextLabel")
                lbl.Size                                   = UDim2.new(1, -28, 0, 20)
                lbl.Position                               = UDim2.new(0, 26, 0, yOffset + 2)
                lbl.BackgroundTransparency                 = 1
                lbl.Font                                   = Enum.Font.GothamBold
                lbl.TextSize                               = 12
                lbl.TextColor3                             = Color3.fromRGB(220, 220, 220)
                lbl.TextXAlignment                         = Enum.TextXAlignment.Left
                lbl.Text                                   = "--"
                lbl.ZIndex                                 = 9999
                lbl.Parent                                 = frame
                return dot, lbl
            end

            local divider            = Instance.new("Frame")
            divider.Size             = UDim2.new(1, -16, 0, 1)
            divider.Position         = UDim2.new(0, 8, 0, 27)
            divider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            divider.BorderSizePixel  = 0
            divider.ZIndex           = 9999
            divider.Parent           = frame

            local pingDot, pingLabel = makeRow(4)
            local fpsDot, fpsLabel   = makeRow(29)

            pingLabel.Text           = "-- ms"
            fpsLabel.Text            = "-- fps"

            _pingGui                 = sg

            local _fpsLastTime       = tick()
            local _fpsFrameCount     = 0
            local _fpsConn           = RunService.RenderStepped:Connect(function()
                _fpsFrameCount = _fpsFrameCount + 1
            end)

            _pingConn                = task.spawn(function()
                while _pingEnabled and sg and sg.Parent do
                    task.wait(1)

                    local ms = math.round(LocalPlayer:GetNetworkPing() * 1000)
                    local pingColor
                    if ms < 80 then
                        pingColor = Color3.fromRGB(80, 220, 100)
                    elseif ms < 150 then
                        pingColor = Color3.fromRGB(240, 200, 60)
                    else
                        pingColor = Color3.fromRGB(230, 80, 80)
                    end
                    pingDot.BackgroundColor3 = pingColor
                    pingLabel.TextColor3     = pingColor
                    pingLabel.Text           = ms .. " ms"

                    local now                = tick()
                    local elapsed            = now - _fpsLastTime
                    local fps                = elapsed > 0 and math.round(_fpsFrameCount / elapsed) or 0
                    _fpsLastTime             = now
                    _fpsFrameCount           = 0

                    local fpsColor
                    if fps >= 55 then
                        fpsColor = Color3.fromRGB(80, 220, 100)
                    elseif fps >= 30 then
                        fpsColor = Color3.fromRGB(240, 200, 60)
                    else
                        fpsColor = Color3.fromRGB(230, 80, 80)
                    end
                    fpsDot.BackgroundColor3 = fpsColor
                    fpsLabel.TextColor3     = fpsColor
                    fpsLabel.Text           = fps .. " fps"
                end
                _fpsConn:Disconnect()
            end)
        end

        local function destroyPingGui()
            _pingEnabled = false
            if _pingGui then
                pcall(function() _pingGui:Destroy() end)
                _pingGui = nil
            end
        end

        PingSection:Toggle({
            Title    = "Show Ping",
            Default  = false,
            Callback = function(v)
                _pingEnabled = v
                if v then
                    createPingGui()
                    WindUI:Notify({ Title = "Ping Display", Content = "Enabled", Duration = 2 })
                else
                    destroyPingGui()
                    WindUI:Notify({ Title = "Ping Display", Content = "Disabled", Duration = 2 })
                end
            end,
        })
    end

    do
        local StatsTab      = MainCore:Tab({
            Title     = "Analytics",
            Icon      = "solar:chart-2-bold-duotone",
            IconColor = Color3.fromHex("#7EB8A8"),

        })

        local TimerSec      = StatsTab:Section({
            Title  = "Session Timer",
            Icon   = "solar:clock-circle-bold",
            Box    = true,
            Opened = false,
        })

        local _sessionStart = tick()
        local _timerEnabled = false
        local _timerConn    = nil
        local _timerLabel   = nil

        local function formatTime(secs)
            local h = math.floor(secs / 3600)
            local m = math.floor((secs % 3600) / 60)
            local s = math.floor(secs % 60)
            return string.format("%02d:%02d:%02d", h, m, s)
        end

        local timerPara = TimerSec:Paragraph({
            Title = "Session Time",
            Desc  = "00:00:00",
        })

        TimerSec:Toggle({
            Title    = "Start Timer",
            Default  = false,
            Callback = function(v)
                _timerEnabled = v
                if v then
                    _sessionStart = tick()
                    _timerConn = task.spawn(function()
                        while _timerEnabled do
                            local elapsed = tick() - _sessionStart
                            if timerPara and timerPara.SetDesc then
                                timerPara:SetDesc(formatTime(elapsed))
                            end
                            task.wait(1)
                        end
                    end)
                    WindUI:Notify({ Title = "Session Timer", Content = "Started!", Duration = 2 })
                else
                    _timerEnabled = false
                    if timerPara and timerPara.SetDesc then
                        timerPara:SetDesc("Stopped at: " .. formatTime(tick() - _sessionStart))
                    end
                    WindUI:Notify({ Title = "Session Timer", Content = "Stopped", Duration = 2 })
                end
            end,
        })

        TimerSec:Button({
            Title    = "Reset Timer",
            Icon     = "solar:restart-bold",
            Callback = function()
                _sessionStart = tick()
                if timerPara and timerPara.SetDesc then
                    timerPara:SetDesc("00:00:00")
                end
                WindUI:Notify({ Title = "Session Timer", Content = "Reset!", Duration = 2 })
            end,
        })

        StatsTab:Space({ Columns = 0.5 })
        do -- BackpackSec scope
            local BackpackSec = StatsTab:Section({
                Title  = "Live Backpack",
                Icon   = "solar:bag-bold-duotone",
                Box    = true,
                Opened = false,
            })

            local _bpLookup = {}
            for _, entry in ipairs(ALL_BRAINROTS) do
                _bpLookup[entry.name] = entry.rarity
            end

            -- Persistent mutation cache, always running regardless of webhook monitor
            local _bpMutCache = {}
            Network.rev_KickEvent.OnClientEvent:Connect(function(_, brainrotData)
                if type(brainrotData) ~= "table" then return end
                local data = brainrotData[1] or brainrotData
                local name = data.Name
                local mut  = data.Mutation
                if name then
                    _bpMutCache[name] = mut
                end
            end)

            local _backpackEnabled = false
            local _backpackConn    = nil
            local _backpackPara    = nil

            local _rarityOrder     = {
                "Eternal", "Celestial", "OG", "Hacked", "Divine", "Secret",
                "Godly", "Exclusive", "Mythic", "Legendary", "Epic", "Rare", "Common"
            }
            local _rarityRank      = {}
            for i, r in ipairs(_rarityOrder) do _rarityRank[r] = i end

            local function getMutationFromTool(tool)
                -- Try reading from Handle attributes first
                local ok, mut = pcall(function()
                    local h = tool:FindFirstChild("Handle")
                    if h then return h:GetAttribute("Mutation") end
                    return nil
                end)
                if ok and mut and not NORMAL_MUTATION_VALUES[string.lower(tostring(mut))] then
                    return tostring(mut)
                end
                -- Also try directly on the tool itself
                local ok2, mut2 = pcall(function() return tool:GetAttribute("Mutation") end)
                if ok2 and mut2 and not NORMAL_MUTATION_VALUES[string.lower(tostring(mut2))] then
                    return tostring(mut2)
                end
                -- Fallback: use cached value from KickEvent
                local cached = _bpMutCache[tool.Name]
                if cached and not NORMAL_MUTATION_VALUES[string.lower(tostring(cached))] then
                    return tostring(cached)
                end
                return nil
            end

            local function buildBackpackText()
                local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                local char     = LocalPlayer.Character
                if not backpack then return "Backpack not found" end

                -- Track individual tools so same-name items with different mutations show correctly
                local items    = {}
                local equipped = {}
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        local mut = getMutationFromTool(tool)
                        local key = tool.Name .. "|" .. (mut or "")
                        if items[key] then
                            items[key].count = items[key].count + 1
                        else
                            items[key] = { name = tool.Name, rarity = _bpLookup[tool.Name] or "Other", mutation = mut, count = 1, equipped = false }
                        end
                    end
                end
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            local mut = getMutationFromTool(tool)
                            local key = tool.Name .. "|" .. (mut or "")
                            if items[key] then
                                items[key].count    = items[key].count + 1
                                items[key].equipped = true
                            else
                                items[key] = { name = tool.Name, rarity = _bpLookup[tool.Name] or "Other", mutation = mut, count = 1, equipped = true }
                            end
                        end
                    end
                end

                if next(items) == nil then return "Backpack is empty" end

                local list = {}
                for _, item in pairs(items) do
                    table.insert(list, item)
                end
                table.sort(list, function(a, b)
                    local ra = _rarityRank[a.rarity] or 99
                    local rb = _rarityRank[b.rarity] or 99
                    if ra ~= rb then return ra < rb end
                    return a.name < b.name
                end)

                local lines = {}
                local total = 0
                for _, item in ipairs(list) do
                    local line = item.name .. " [" .. item.rarity .. "]"
                    if item.mutation then line = line .. " {" .. item.mutation .. "}" end
                    if item.count > 1 then line = line .. " x" .. item.count end
                    if item.equipped then line = line .. " *" end
                    table.insert(lines, line)
                    total = total + item.count
                end

                table.insert(lines, 1, "Total: " .. total .. " item(s)")
                table.insert(lines, 2, "")

                return table.concat(lines, "\n")
            end

            _backpackPara = BackpackSec:Paragraph({
                Title = "Items",
                Desc  = "Press refresh or enable monitor",
            })

            BackpackSec:Button({
                Title    = "Refresh Now",
                Icon     = "solar:restart-bold",
                Callback = function()
                    if _backpackPara and _backpackPara.SetDesc then
                        _backpackPara:SetDesc(buildBackpackText())
                    end
                end,
            })

            BackpackSec:Toggle({
                Title    = "Live Monitor",
                Desc     = "Auto-refresh every 2s",
                Default  = false,
                Callback = function(v)
                    _backpackEnabled = v
                    if v then
                        _backpackConn = task.spawn(function()
                            while _backpackEnabled do
                                if _backpackPara and _backpackPara.SetDesc then
                                    _backpackPara:SetDesc(buildBackpackText())
                                end
                                task.wait(2)
                            end
                        end)
                        WindUI:Notify({ Title = "Backpack Monitor", Content = "Live monitor on", Duration = 2 })
                    else
                        _backpackEnabled = false
                        WindUI:Notify({ Title = "Backpack Monitor", Content = "Live monitor off", Duration = 2 })
                    end
                end,
            })
        end -- BackpackSec scope

        -- ══════════════════════════════════════════════
        -- AUTO FAV
        -- ══════════════════════════════════════════════
        StatsTab:Space({ Columns = 0.5 })

        -- Shared by FavSec and FavMutSec (kept in StatsTab scope)
        local _favEvent = ReplicatedStorage.Shared.Packages.Network:FindFirstChild("rev_ToggleFav")

        local ATTR_KEYS_FAV = {
            "GUID", "ItemId", "UUID", "Id", "ItemID", "uid", "Uuid",
            "item_id", "itemId", "ID", "ObjectId", "AssetId",
        }

        local function _tryGetFavId(obj)
            for _, key in ipairs(ATTR_KEYS_FAV) do
                local ok, v = pcall(function() return obj:GetAttribute(key) end)
                if ok and v and tostring(v) ~= "" then return tostring(v) end
            end
            local ok, attrs = pcall(function() return obj:GetAttributes() end)
            if ok then
                for _, v in pairs(attrs) do
                    local s = tostring(v)
                    if s:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") then
                        return s
                    end
                end
            end
            return nil
        end

        local function _isFaved(tool)
            local ok, v = pcall(function() return tool:GetAttribute("Favorite") end)
            return ok and v == true
        end

        do -- FavSec scope
            local FavSec       = StatsTab:Section({
                Title  = "Auto Favourite",
                Icon   = "solar:star-bold-duotone",
                Box    = true,
                Opened = false,
            })

            local _favItems    = {}
            local _favSelected = {}
            local _favDropdown = nil

            local function _getFavItems()
                local result = {}
                local bp     = LocalPlayer:FindFirstChildOfClass("Backpack")
                local char   = LocalPlayer.Character
                local function scan(container)
                    if not container then return end
                    for _, tool in ipairs(container:GetChildren()) do
                        if tool:IsA("Tool") and not _isFaved(tool) then
                            local id = _tryGetFavId(tool)
                            if not id then
                                local h = tool:FindFirstChild("Handle")
                                if h then id = _tryGetFavId(h) end
                            end
                            if id then
                                table.insert(result, { id = id, name = tool.Name })
                            end
                        end
                    end
                end
                scan(bp)
                if char then scan(char) end
                return result
            end

            local _favStatus = FavSec:Paragraph({
                Title = "Status",
                Desc  = "Idle",
            })

            local function _setFavStatus(msg)
                if _favStatus and _favStatus.SetDesc then
                    _favStatus:SetDesc(tostring(msg))
                end
            end

            local function _refreshFavList()
                _favItems        = _getFavItems()
                _favSelected     = {}
                local dropValues = {}
                if #_favItems == 0 then
                    table.insert(dropValues, { Title = "(No items with UUID found)" })
                else
                    for _, item in ipairs(_favItems) do
                        local shortId = item.id:sub(1, 8)
                        table.insert(dropValues, { Title = item.name .. " [" .. shortId .. "]" })
                    end
                end
                if _favDropdown then
                    pcall(function() _favDropdown:Set({}) end)
                    pcall(function() _favDropdown:Refresh(dropValues) end)
                end
                _setFavStatus("0 item(s) selected")
                WindUI:Notify({ Title = "Auto Fav", Content = #_favItems .. " item(s) loaded", Duration = 2 })
            end

            FavSec:Button({
                Title    = "Refresh Backpack",
                Icon     = "solar:restart-bold",
                Callback = _refreshFavList,
            })

            _favDropdown = FavSec:Dropdown({
                Title    = "Select Items",
                Values   = {},
                Multi    = true,
                Callback = function(selected)
                    _favSelected = {}
                    if not selected then return end
                    for key, v in pairs(selected) do
                        local title = type(v) == "table" and v.Title or key
                        for _, item in ipairs(_favItems) do
                            local shortId = item.id:sub(1, 8)
                            if title == item.name .. " [" .. shortId .. "]" then
                                table.insert(_favSelected, item)
                                break
                            end
                        end
                    end
                    _setFavStatus(#_favSelected .. " item(s) selected")
                end,
            })

            FavSec:Button({
                Title    = "Favourite Selected",
                Icon     = "solar:star-bold",
                Callback = function()
                    if not _favEvent then
                        WindUI:Notify({ Title = "Auto Fav", Content = "rev_ToggleFav not found!", Duration = 3 })
                        return
                    end
                    if #_favSelected == 0 then
                        WindUI:Notify({ Title = "Auto Fav", Content = "Select an item first!", Duration = 3 })
                        return
                    end
                    WindUI:Notify({ Title = "Auto Fav", Content = "Favouriting " .. #_favSelected .. " item(s)...", Duration = 3 })
                    task.spawn(function()
                        local done = 0
                        for _, item in ipairs(_favSelected) do
                            pcall(function()
                                _favEvent:FireServer(item.id)
                            end)
                            done = done + 1
                            _setFavStatus("Favourited " .. done .. "/" .. #_favSelected .. " — " .. item.name)
                            task.wait(0.5)
                        end
                        _setFavStatus("Done — " .. done .. " item(s) favourited.")
                        WindUI:Notify({ Title = "Auto Fav", Content = "Done! " .. done .. " item(s) favourited.", Duration = 3 })
                    end)
                end,
            })

            FavSec:Button({
                Title    = "Favourite All",
                Icon     = "solar:stars-bold",
                Callback = function()
                    if not _favEvent then
                        WindUI:Notify({ Title = "Auto Fav", Content = "rev_ToggleFav not found!", Duration = 3 })
                        return
                    end
                    local items = _getFavItems()
                    if #items == 0 then
                        WindUI:Notify({ Title = "Auto Fav", Content = "No items with UUID found in backpack.", Duration = 3 })
                        return
                    end
                    WindUI:Notify({ Title = "Auto Fav", Content = "Favouriting all " .. #items .. " item(s)...", Duration = 3 })
                    task.spawn(function()
                        local done = 0
                        for _, item in ipairs(items) do
                            pcall(function()
                                _favEvent:FireServer(item.id)
                            end)
                            done = done + 1
                            _setFavStatus("Favourited " .. done .. "/" .. #items .. " — " .. item.name)
                            task.wait(0.5)
                        end
                        _setFavStatus("Done — " .. done .. " item(s) favourited.")
                        WindUI:Notify({ Title = "Auto Fav", Content = "Done! " .. done .. " item(s) favourited.", Duration = 3 })
                    end)
                end,
            })

            -- auto-load on open
            task.defer(_refreshFavList)
        end -- FavSec scope

        -- ── Fav by Mutation ──────────────────────────
        StatsTab:Space({ Columns = 0.5 })

        local FavMutSec = StatsTab:Section({
            Title  = "Fav by Mutation",
            Icon   = "solar:atom-bold-duotone",
            Box    = true,
            Opened = false,
        })

        local _favMutationList = {
            "Normal",
            "Golden", "Diamond", "Plasma", "Molten", "Radioactive",
            "Shadow", "Electrified", "Rainbow", "Astral", "Volcanic",
            "Wet", "Alien", "Bacon", "Virus", "Void", "Enchanted", "Phantom",
        }

        local _favSelectedMutations = {}

        local _favMutDropValues = {}
        for _, m in ipairs(_favMutationList) do
            table.insert(_favMutDropValues, { Title = m })
        end

        local function _getToolMutationFav(tool)
            local ok, mut = pcall(function()
                local h = tool:FindFirstChild("Handle")
                if h then return h:GetAttribute("Mutation") end
                return nil
            end)
            if ok and mut and not NORMAL_MUTATION_VALUES[string.lower(tostring(mut))] then
                return tostring(mut)
            end
            local ok2, mut2 = pcall(function() return tool:GetAttribute("Mutation") end)
            if ok2 and mut2 and not NORMAL_MUTATION_VALUES[string.lower(tostring(mut2))] then
                return tostring(mut2)
            end
            return "Normal"
        end

        local _favMutStatus = FavMutSec:Paragraph({
            Title = "Status",
            Desc  = "Idle",
        })

        local function _setFavMutStatus(msg)
            if _favMutStatus and _favMutStatus.SetDesc then
                _favMutStatus:SetDesc(tostring(msg))
            end
        end

        local _favMutDropReady = false
        FavMutSec:Dropdown({
            Title    = "Select Mutation",
            Values   = _favMutDropValues,
            Multi    = true,
            Callback = function(selected)
                if not _favMutDropReady then
                    _favMutDropReady = true
                    return
                end
                _favSelectedMutations = {}
                for key, v in pairs(selected) do
                    local title = type(v) == "table" and v.Title or key
                    _favSelectedMutations[title] = true
                    _favSelectedMutations[string.lower(title)] = true
                end
                local cnt = 0
                for _, m in ipairs(_favMutationList) do
                    if _favSelectedMutations[m] then cnt = cnt + 1 end
                end
                _setFavMutStatus(cnt > 0 and (cnt .. " mutation(s) selected") or "No mutation selected")
                WindUI:Notify({
                    Title    = "Fav by Mutation",
                    Content  = cnt > 0 and (cnt .. " mutation(s) selected") or "No mutation selected",
                    Duration = 2,
                })
            end,
        })

        FavMutSec:Button({
            Title    = "Favourite by Mutation",
            Icon     = "solar:star-bold",
            Callback = function()
                if not _favEvent then
                    WindUI:Notify({ Title = "Fav by Mutation", Content = "rev_ToggleFav not found!", Duration = 3 })
                    return
                end
                if next(_favSelectedMutations) == nil then
                    WindUI:Notify({ Title = "Fav by Mutation", Content = "Select at least one mutation first!", Duration = 3 })
                    return
                end
                task.spawn(function()
                    local bp   = LocalPlayer:FindFirstChildOfClass("Backpack")
                    local char = LocalPlayer.Character
                    if not bp then
                        WindUI:Notify({ Title = "Fav by Mutation", Content = "Backpack not found!", Duration = 2 })
                        return
                    end

                    -- collect matching items from backpack + equipped
                    local toFav = {}
                    local function scanForMut(container)
                        if not container then return end
                        for _, tool in ipairs(container:GetChildren()) do
                            if tool:IsA("Tool") and not _isFaved(tool) then
                                local mut = _getToolMutationFav(tool)
                                if _favSelectedMutations[mut] or _favSelectedMutations[string.lower(mut)] then
                                    local id = _tryGetFavId(tool)
                                    if not id then
                                        local h = tool:FindFirstChild("Handle")
                                        if h then id = _tryGetFavId(h) end
                                    end
                                    if id then
                                        table.insert(toFav, { id = id, name = tool.Name, mutation = mut })
                                    end
                                end
                            end
                        end
                    end
                    scanForMut(bp)
                    if char then scanForMut(char) end

                    if #toFav == 0 then
                        WindUI:Notify({ Title = "Fav by Mutation", Content = "No matching items found!", Duration = 3 })
                        return
                    end

                    WindUI:Notify({ Title = "Fav by Mutation", Content = "Favouriting " .. #toFav .. " item(s)...", Duration = 3 })
                    local done = 0
                    for _, item in ipairs(toFav) do
                        pcall(function()
                            _favEvent:FireServer(item.id)
                        end)
                        done = done + 1
                        _setFavMutStatus("Favourited " ..
                            done .. "/" .. #toFav .. " — " .. item.name .. " [" .. item.mutation .. "]")
                        task.wait(0.5)
                    end
                    _setFavMutStatus("Done — " .. done .. " item(s) favourited.")
                    WindUI:Notify({ Title = "Fav by Mutation", Content = "Done! " .. done .. " item(s) favourited.", Duration = 3 })
                end)
            end,
        })
    end

    -- ══════════════════════════════════════════════
    -- TRADING TAB
    -- ══════════════════════════════════════════════
    ; (function(MainCore, WindUI, LocalPlayer, ReplicatedStorage, Players)
        local TradeNetwork        = ReplicatedStorage.Shared.Packages.Network
        local _tradeInviteEvt     = TradeNetwork.ref_trade_r
        local _tradeItemEvt       = TradeNetwork.rev_trade_i
        local _tradePlayMsg       = TradeNetwork.rev_PlayMessage

        local TradeTab            = MainCore:Tab({
            Title     = "Trading",
            Icon      = "solar:card-transfer-bold-duotone",
            IconColor = Color3.fromHex("#50E3C2"),
        })

        -- ─── State ────────────────────────────────────
        local _tradeTargetId      = nil
        local _tradeTargetName    = ""
        local _tradeItems         = {}
        local _tradeSelectedItems = {} -- multi-select
        local _autoTradeOn        = false
        local _autoTradeThread    = nil
        local _tradeStatus        = nil

        -- ─── Helpers ──────────────────────────────────
        local function _getBackpackItems()
            local result    = {}
            local bp        = LocalPlayer:FindFirstChildOfClass("Backpack")
            local char      = LocalPlayer.Character

            local ATTR_KEYS = {
                "GUID", "ItemId", "UUID", "Id", "ItemID", "uid", "Uuid",
                "item_id", "itemId", "ID", "ObjectId", "AssetId",
            }

            local function tryGetId(obj)
                for _, key in ipairs(ATTR_KEYS) do
                    local v = obj:GetAttribute(key)
                    if v and tostring(v) ~= "" then
                        return tostring(v)
                    end
                end
                local attrs = obj:GetAttributes()
                for k, v in pairs(attrs) do
                    local s = tostring(v)
                    if #s >= 8 then
                        return s
                    end
                end
                return nil
            end

            local function scanContainer(container)
                if not container then return end
                for _, tool in ipairs(container:GetChildren()) do
                    if tool:IsA("Tool") then
                        local itemId = nil
                        pcall(function() itemId = tryGetId(tool) end)
                        if not itemId then
                            pcall(function()
                                local h = tool:FindFirstChild("Handle")
                                if h then itemId = tryGetId(h) end
                            end)
                        end
                        if not itemId then
                            itemId = tool.Name
                        end
                        table.insert(result, { id = itemId, name = tool.Name })
                    end
                end
            end

            scanContainer(bp)
            if char then scanContainer(char) end
            return result
        end

        local function _setStatus(msg)
            if _tradeStatus and _tradeStatus.SetDesc then
                _tradeStatus:SetDesc(tostring(msg))
            end
        end

        local function _stopAutoTrade()
            _autoTradeOn = false
            _autoTradeThread = nil
            _setStatus("Idle")
            WindUI:Notify({ Title = "Auto Trade", Content = "Stopped", Duration = 2 })
        end

        -- ─── Listen trade complete ─────────────────────
        pcall(function()
            _tradePlayMsg.OnClientEvent:Connect(function(msg)
                if type(msg) == "string" and msg:lower():find("trade") then
                    WindUI:Notify({ Title = "Trade", Content = msg, Duration = 4 })
                    _setStatus("Last: " .. msg)
                end
            end)
        end)

        -- ─── Invite Section ────────────────────────────
        local InviteSec         = TradeTab:Section({
            Title  = "Invite to Trade",
            Icon   = "solar:users-group-rounded-bold-duotone",
            Box    = true,
            Opened = false,
        })

        _tradeStatus            = InviteSec:Paragraph({
            Title = "Status",
            Desc  = "Idle",
        })

        -- ─── Dropdown target dari player in-server ─────
        local _playerDropValues = {}
        local _playerDropdown   = nil

        local function _refreshPlayerList()
            _playerDropValues = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    table.insert(_playerDropValues, { Title = p.Name })
                end
            end
            if #_playerDropValues == 0 then
                table.insert(_playerDropValues, { Title = "(No other players)" })
            end
            if _playerDropdown and _playerDropdown.Refresh then
                pcall(function() _playerDropdown:Refresh(_playerDropValues) end)
            end
            WindUI:Notify({ Title = "Trading", Content = #_playerDropValues .. " player(s) found", Duration = 2 })
        end

        InviteSec:Button({
            Title    = "Refresh Player List",
            Icon     = "solar:restart-bold",
            Callback = _refreshPlayerList,
        })

        _playerDropdown = InviteSec:Dropdown({
            Title    = "Select Target Player",
            Values   = _playerDropValues,
            Callback = function(selected)
                if not selected then return end
                local name = type(selected) == "table" and selected.Title or tostring(selected)
                if name == "(No other players)" then return end
                _tradeTargetName = name
                _tradeTargetId   = nil
                task.spawn(function()
                    local ok, uid = pcall(function()
                        return Players:GetUserIdFromNameAsync(_tradeTargetName)
                    end)
                    if ok and uid then
                        _tradeTargetId = uid
                        _setStatus("Target: " .. _tradeTargetName .. " (" .. uid .. ")")
                        WindUI:Notify({ Title = "Trading", Content = "Target set: " .. _tradeTargetName, Duration = 2 })
                    else
                        _setStatus("Player not found: " .. _tradeTargetName)
                        WindUI:Notify({ Title = "Trading", Content = "User not found!", Duration = 3 })
                    end
                end)
            end,
        })

        -- auto-load player list saat pertama kali
        task.defer(_refreshPlayerList)

        InviteSec:Button({
            Title    = "Send Trade Invite",
            Icon     = "solar:plain-bold-duotone",
            Callback = function()
                if not _tradeTargetId then
                    WindUI:Notify({ Title = "Trading", Content = "Set target username first!", Duration = 3 })
                    return
                end
                local ok, err = pcall(function()
                    _tradeInviteEvt:InvokeServer(_tradeTargetId)
                end)
                if ok then
                    _setStatus("Invite sent to " .. _tradeTargetName)
                    WindUI:Notify({ Title = "Trading", Content = "Invite sent!", Duration = 2 })
                else
                    _setStatus("Invite failed: " .. tostring(err))
                    WindUI:Notify({ Title = "Trading", Content = "Failed: " .. tostring(err), Duration = 3 })
                end
            end,
        })

        TradeTab:Space({ Columns = 0.5 })

        -- ─── Item Selection ────────────────────────────
        local ItemSec         = TradeTab:Section({
            Title  = "Item to Trade",
            Icon   = "solar:bag-heart-bold-duotone",
            Box    = true,
            Opened = false,
        })

        local _itemDropdown   = nil
        local _itemDropValues = {}

        local function _refreshItemList()
            _tradeItems         = _getBackpackItems()
            _itemDropValues     = {}
            _tradeSelectedItems = {}
            if #_tradeItems == 0 then
                table.insert(_itemDropValues, { Title = "(No items with UUID found)" })
            else
                for _, item in ipairs(_tradeItems) do
                    local shortId = item.id:sub(1, 8)
                    table.insert(_itemDropValues, { Title = item.name .. " [" .. shortId .. "]" })
                end
            end
            if _itemDropdown then
                -- Reset selection dulu, baru refresh list-nya
                pcall(function() _itemDropdown:Set({}) end)
                pcall(function() _itemDropdown:Refresh(_itemDropValues) end)
            end
            _setStatus("0 item(s) selected")
            WindUI:Notify({ Title = "Items", Content = #_tradeItems .. " item(s) loaded", Duration = 2 })
        end

        ItemSec:Button({
            Title    = "Refresh Backpack",
            Icon     = "solar:restart-bold",
            Callback = _refreshItemList,
        })

        _itemDropdown = ItemSec:Dropdown({
            Title    = "Select Items",
            Values   = _itemDropValues,
            Multi    = true,
            Callback = function(selected)
                _tradeSelectedItems = {}
                if not selected then return end
                for key, v in pairs(selected) do
                    local title = type(v) == "table" and v.Title or key
                    for _, item in ipairs(_tradeItems) do
                        local shortId = item.id:sub(1, 8)
                        if title == item.name .. " [" .. shortId .. "]" then
                            table.insert(_tradeSelectedItems, item)
                            break
                        end
                    end
                end
                _setStatus(#_tradeSelectedItems .. " item(s) selected")
            end,
        })

        ItemSec:Button({
            Title    = "Add Selected Items to Trade",
            Icon     = "solar:add-circle-bold-duotone",
            Callback = function()
                if #_tradeSelectedItems == 0 then
                    WindUI:Notify({ Title = "Trading", Content = "Select an item first!", Duration = 3 })
                    return
                end
                local added = 0
                for _, item in ipairs(_tradeSelectedItems) do
                    local ok, err = pcall(function()
                        _tradeItemEvt:FireServer("AddItem", item.id)
                    end)
                    if ok then
                        added = added + 1
                    else
                        WindUI:Notify({ Title = "Trading", Content = "Failed: " .. item.name .. " - " .. tostring(err), Duration = 3 })
                    end
                    task.wait(0.1)
                end
                _setStatus("Added " .. added .. "/" .. #_tradeSelectedItems .. " item(s)")
                WindUI:Notify({ Title = "Trading", Content = "Added " .. added .. " item(s)", Duration = 2 })
            end,
        })

        TradeTab:Space({ Columns = 0.5 })

        -- ─── Confirm ───────────────────────────────────

        ItemSec:Button({
            Title    = "Confirm Trade",
            Color    = Color3.fromHex("#57F287"),
            Justify  = "Center",
            Icon     = "solar:verified-check-bold",
            Callback = function()
                local ok, err = pcall(function()
                    _tradeItemEvt:FireServer("Confirm")
                end)
                if ok then
                    _setStatus("Confirm sent, waiting...")
                    WindUI:Notify({ Title = "Trading", Content = "Confirmed!", Duration = 2 })
                else
                    WindUI:Notify({ Title = "Trading", Content = "Failed: " .. tostring(err), Duration = 3 })
                end
            end,
        })

        ItemSec:Button({
            Title    = "Cancel Trade",
            Color    = Color3.fromHex("#ED4245"),
            Justify  = "Center",
            Icon     = "solar:close-circle-bold",
            Callback = function()
                local CancelEvt = game:GetService("ReplicatedStorage").Shared.Packages.Network.rev_trade_i
                local ok, err = pcall(function()
                    CancelEvt:FireServer("Cancel")
                end)
                if ok then
                    _setStatus("Trade cancelled.")
                    WindUI:Notify({ Title = "Trading", Content = "Trade cancelled!", Duration = 2 })
                else
                    WindUI:Notify({ Title = "Trading", Content = "Failed: " .. tostring(err), Duration = 3 })
                end
            end,
        })

        TradeTab:Space({ Columns = 0.5 })

        -- ─── Auto Trade Loop ───────────────────────────
        local AutoSec = TradeTab:Section({
            Title  = "Auto Trade",
            Icon   = "solar:refresh-bold-duotone",
            Box    = true,
            Opened = false,
        })

        AutoSec:Paragraph({
            Title = "Info",
            Desc  =
            "Set target username & select items first. Auto Trade will invite, add items, then confirm automatically.",
        })

        local _autoTradeDelay = 3

        AutoSec:Slider({
            Title    = "Delay per step (seconds)",
            Step     = 0.5,
            Value    = { Min = 1, Max = 10, Default = _autoTradeDelay },
            Callback = function(v)
                _autoTradeDelay = v
            end,
        })

        AutoSec:Toggle({
            Title    = "Auto Trade Loop",
            Default  = false,
            Callback = function(v)
                _autoTradeOn = v
                if v then
                    if not _tradeTargetId then
                        WindUI:Notify({ Title = "Auto Trade", Content = "Set target username first!", Duration = 3 })
                        _autoTradeOn = false
                        return
                    end
                    if #_tradeSelectedItems == 0 then
                        WindUI:Notify({ Title = "Auto Trade", Content = "Select item first!", Duration = 3 })
                        _autoTradeOn = false
                        return
                    end
                    WindUI:Notify({ Title = "Auto Trade", Content = "Started!", Duration = 2 })
                    _autoTradeThread = task.spawn(function()
                        while _autoTradeOn do
                            if #_tradeSelectedItems == 0 then
                                _stopAutoTrade()
                                break
                            end

                            _setStatus("Inviting " .. _tradeTargetName .. "...")
                            pcall(function() _tradeInviteEvt:InvokeServer(_tradeTargetId) end)
                            task.wait(_autoTradeDelay)
                            if not _autoTradeOn then break end

                            for _, item in ipairs(_tradeSelectedItems) do
                                if not _autoTradeOn then break end
                                _setStatus("Adding item: " .. item.name)
                                pcall(function() _tradeItemEvt:FireServer("AddItem", item.id) end)
                                task.wait(0.15)
                            end
                            task.wait(_autoTradeDelay)
                            if not _autoTradeOn then break end

                            _setStatus("Confirming trade...")
                            pcall(function() _tradeItemEvt:FireServer("Confirm") end)
                            task.wait(_autoTradeDelay)
                        end
                    end)
                else
                    _stopAutoTrade()
                end
            end,
        })
    end)(MainCore, WindUI, LocalPlayer, ReplicatedStorage, Players)
    -- ══════════════════════════════════════════════
    -- END TRADING TAB
    -- ══════════════════════════════════════════════

    task.defer(function()
        if type(_cfg.keepRarities) == "table" then
            for _, r in ipairs(_cfg.keepRarities) do
                _selectedRarities[r] = true
                if _rarityToggles[r] and _rarityToggles[r].Set then
                    _rarityToggles[r]:Set(true)
                end
            end
        end

        if type(_cfg.keepIndividual) == "table" then
            for _, title in ipairs(_cfg.keepIndividual) do
                local brainrotName = title:match("^%[.+%] (.+)$") or title
                _selectedIndividual[brainrotName] = true
                if _brainrotToggles[brainrotName] and _brainrotToggles[brainrotName].Set then
                    _brainrotToggles[brainrotName]:Set(true)
                end
            end
        end

        if type(_cfg.keepMutations) == "table" then
            for _, m in ipairs(_cfg.keepMutations) do
                S.keepMutations[normalizeMutation(m)] = true
                if _mutationToggles[m] and _mutationToggles[m].Set then
                    _mutationToggles[m]:Set(true)
                end
            end
        end

        if type(_cfg.keepEventMutations) == "table" then
            for _, m in ipairs(_cfg.keepEventMutations) do
                S.keepEventMutations[normalizeMutation(m)] = true
                if _eventMutationToggles[m] and _eventMutationToggles[m].Set then
                    _eventMutationToggles[m]:Set(true)
                end
            end
        end

        rebuildKeepBrainrots()

        for name, t in pairs(_methodToggles) do
            if t and t.Set then
                t:Set(name == S.kickMode)
            end
        end

        if _cfg.showPanel and _toggleShowPanel then
            _toggleShowPanel:Set(true)
        end

        if _cfg.autoSkip and _toggleAutoSkip then
            _toggleAutoSkip:Set(true)
        end

        if _cfg.autoKick and _toggleAutoKick then
            _toggleAutoKick:Set(true)
        end

        if _cfg.antiAfk and _toggleAntiAFK then
            _toggleAntiAFK:Set(true)
            if antiAFK and not afkConn then
                local VI_User = game:GetService("VirtualUser")
                afkConn = LocalPlayer.Idled:Connect(function()
                    if antiAFK then
                        VI_User:CaptureController()
                        VI_User:ClickButton2(Vector2.new())
                    end
                end)
            end
        end

        if _cfg.autoReconnect and _toggleAutoReconnect then
            _toggleAutoReconnect:Set(true)
        end

        if _cfg.autoRejoinKick and _toggleAutoRejoinKick then
            _toggleAutoRejoinKick:Set(true)
        end

        _uiReady = true
    end)
end
