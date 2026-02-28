local OpenButton = {}

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local DEFAULT_COLOR = Color3.fromHex("#16a34a")

local function darkenColor(color, amount)
    local factor = 1 - amount
    return Color3.new(
        math.clamp(color.R * factor, 0, 1),
        math.clamp(color.G * factor, 0, 1),
        math.clamp(color.B * factor, 0, 1)
    )
end

local function resolveButtonColor(openButtonConfig)
    local colorValue = openButtonConfig and (
        openButtonConfig.CircleColor
        or openButtonConfig.BackgroundColor
        or openButtonConfig.Color
    )

    if typeof(colorValue) == "Color3" then
        return colorValue
    end

    if typeof(colorValue) == "ColorSequence" then
        local firstKeypoint = colorValue.Keypoints[1]
        if firstKeypoint then
            return firstKeypoint.Value
        end
    end

    return DEFAULT_COLOR
end

function OpenButton.New(Window)
    local OpenButtonMain = {
        Button = nil
    }

    local Icon
    local currentColor = DEFAULT_COLOR
    local hoverColor = currentColor:Lerp(Color3.new(1, 1, 1), 0.15)

    local Container = New("Frame", {
        Size = UDim2.new(0, 52, 0, 52),
        Position = UDim2.new(0.5, 0, 0, 6 + 44 / 2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = Window.Parent,
        BackgroundTransparency = 1,
        Active = false,
        Visible = false,
    })

    local UIScale = New("UIScale", {
        Scale = 1,
    })

    local Button = New("Frame", {
        Size = UDim2.new(0, 52, 0, 52),
        AutomaticSize = "None",
        Parent = Container,
        Active = false,
        BackgroundTransparency = 0,
        ZIndex = 99,
        BackgroundColor3 = currentColor,
    }, {
        UIScale,
        New("UICorner", {
            CornerRadius = UDim.new(1, 0)
        }),
        New("UIGradient", {
            Rotation = 35,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, currentColor:Lerp(Color3.new(1, 1, 1), 0.08)),
                ColorSequenceKeypoint.new(0.4, currentColor),
                ColorSequenceKeypoint.new(1, darkenColor(currentColor, 0.12)),
            }),
        }),
        New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Thickness = 1.4,
            Transparency = 0,
            Color = darkenColor(currentColor, 0.28),
        }),
        New("ImageLabel", {
            Name = "TextureOverlay",
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0, 0),
            BackgroundTransparency = 1,
            Image = Creator.Shapes["Glass-1"],
            ImageColor3 = currentColor:Lerp(Color3.new(1, 1, 1), 0.12),
            ImageTransparency = 0.94,
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 100,
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(1, 0)
            }),
        }),
        New("TextButton", {
            AutomaticSize = "None",
            Active = true,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -8, 1, -8),
            Position = UDim2.new(0, 4, 0, 4),
            BackgroundColor3 = Color3.new(1,1,1),
            ZIndex = 101,
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(1, -4)
            }),
        })
    })

    OpenButtonMain.Button = Button

    function OpenButtonMain:SetIcon(newIcon)
        if Icon then
            Icon:Destroy()
            Icon = nil
        end

        if newIcon then
            Icon = Creator.Image(
                newIcon,
                Window.Title,
                0,
                Window.Folder,
                "OpenButton",
                true,
                Window.IconThemed
            )
            Icon.Size = UDim2.new(0, 22, 0, 22)
            Icon.AnchorPoint = Vector2.new(0.5, 0.5)
            Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
            Icon.BackgroundTransparency = 1
            Icon.ZIndex = 102
            Icon.Parent = OpenButtonMain.Button.TextButton
        end
    end

    if Window.Icon then
        OpenButtonMain:SetIcon(Window.Icon)
    end

    Creator.AddSignal(Button:GetPropertyChangedSignal("AbsoluteSize"), function()
        Container.Size = UDim2.new(
            0, Button.AbsoluteSize.X,
            0, Button.AbsoluteSize.Y
        )
    end)

    Creator.AddSignal(Button.TextButton.MouseEnter, function()
        Tween(Button, .1, {BackgroundColor3 = hoverColor}):Play()
        Tween(Button.UIStroke, .1, {Color = darkenColor(hoverColor, 0.28)}):Play()
    end)

    Creator.AddSignal(Button.TextButton.MouseLeave, function()
        Tween(Button, .1, {BackgroundColor3 = currentColor}):Play()
        Tween(Button.UIStroke, .1, {Color = darkenColor(currentColor, 0.28)}):Play()
    end)

    function OpenButtonMain:Visible(v)
        Container.Visible = v
    end

    function OpenButtonMain:SetScale(scale)
        UIScale.Scale = scale
    end

    function OpenButtonMain:Edit(OpenButtonConfig)
        OpenButtonConfig = OpenButtonConfig or {}
        local iconToUse = OpenButtonConfig.Icon

        if iconToUse == nil then
            iconToUse = Window.Icon
        end

        if OpenButtonConfig.Enabled ~= nil then
            Window.IsOpenButtonEnabled = OpenButtonConfig.Enabled ~= false
        end

        if OpenButtonConfig.Position and Container then
            Container.Position = OpenButtonConfig.Position
        end

        if iconToUse ~= nil then
            OpenButtonMain:SetIcon(iconToUse)
        end

        currentColor = resolveButtonColor(OpenButtonConfig)
        hoverColor = currentColor:Lerp(Color3.new(1, 1, 1), 0.15)

        Button.BackgroundColor3 = currentColor
        Button.UIStroke.Color = darkenColor(currentColor, 0.28)
        Button.UIGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, currentColor:Lerp(Color3.new(1, 1, 1), 0.08)),
            ColorSequenceKeypoint.new(0.4, currentColor),
            ColorSequenceKeypoint.new(1, darkenColor(currentColor, 0.12)),
        })
        Button.TextureOverlay.ImageColor3 = currentColor:Lerp(Color3.new(1, 1, 1), 0.12)

        OpenButtonMain:SetScale(OpenButtonConfig.Scale or 1)
    end

    return OpenButtonMain
end

return OpenButton
