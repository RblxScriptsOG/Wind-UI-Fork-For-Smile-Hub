local OpenButton = {}

local Creator = require("../../modules/Creator")
local New = Creator.New

local DEFAULT_COLOR = Color3.fromHex("#001400")

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
        Button = nil,
        Drag = nil,
    }

    local Icon
    local currentColor = Color3.fromHex("#001400")

    local Container = New("Frame", {
        Size = UDim2.new(0, 56, 0, 56),
        Position = UDim2.new(0.5, 0, 0, 6 + 44 / 2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = Window.Parent,
        BackgroundTransparency = 1,
        Active = true,
        Visible = false,
    })

    local UIScale = New("UIScale", {
        Scale = 1,
    })

    local Button = New("Frame", {
        Size = UDim2.new(0, 56, 0, 56),
        AutomaticSize = "None",
        Parent = Container,
        Active = true,
        BackgroundTransparency = 0,
        ZIndex = 99,
        BackgroundColor3 = currentColor,
    }, {
        UIScale,
        New("UICorner", {
            CornerRadius = UDim.new(1, 0)
        }),
        New("TextButton", {
            AutomaticSize = "None",
            Active = true,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Color3.new(1,1,1),
            AutoButtonColor = false,
            Text = "$",
            TextColor3 = Color3.fromHex("#00FF00"),
            Font = Enum.Font.Arcade,
            TextSize = 36,
            ZIndex = 101,
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(1, 0)
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

    Creator.AddSignal(Button:GetPropertyChangedSignal("AbsoluteSize"), function()
        Container.Size = UDim2.new(
            0, Button.AbsoluteSize.X,
            0, Button.AbsoluteSize.Y
        )
    end)

    OpenButtonMain.Drag = Creator.Drag(Container, { Button.TextButton })

    function OpenButtonMain:Visible(v)
        Container.Visible = v
    end

    function OpenButtonMain:SetScale(scale)
        UIScale.Scale = scale
    end

    function OpenButtonMain:Edit(OpenButtonConfig)
        OpenButtonConfig = OpenButtonConfig or {}
        local iconToUse = OpenButtonConfig.Icon

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
        Button.BackgroundColor3 = currentColor
        Button.TextButton.TextColor3 = Color3.fromHex("#00FF00")

        OpenButtonMain:SetScale(OpenButtonConfig.Scale or 1)
    end

    return OpenButtonMain
end

return OpenButton
