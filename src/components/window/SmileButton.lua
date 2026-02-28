local SmileButton = {}

local Creator = require("../../modules/Creator")
local New = Creator.New

function SmileButton.New(Window)
    local Container = New("Frame", {
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(0, 24, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Parent = Window.Parent,
        Active = true,
        Name = "SmileToggleButton",
    })

    local Main = Creator.NewRoundFrame(999, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        Parent = Container,
        ImageColor3 = Color3.fromHex("#0d0d0d"),
        ImageTransparency = 0.05,
    }, {
        Creator.NewRoundFrame(999, "SquircleOutline", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageColor3 = Color3.fromHex("#30ff6a"),
            ImageTransparency = 0.35,
        }),
        New("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "$",
            TextSize = 24,
            FontFace = Font.new(Creator.Font, Enum.FontWeight.Bold),
            TextColor3 = Color3.fromHex("#30ff6a"),
            AutoButtonColor = false,
        }),
    }, true)

    local Drag = Creator.Drag(Container)

    Creator.AddSignal(Main.TextButton.MouseButton1Click, function()
        Window:Toggle()
    end)

    return {
        Container = Container,
        Button = Main,
        Drag = Drag,
    }
end

return SmileButton
