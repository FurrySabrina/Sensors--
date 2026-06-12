color = {}

--- Convets a color to a hex string
--- @param color Color
--- @return string hexString
function color.colorToHexString(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.r * 255), 
        math.floor(color.g * 255), 
        math.floor(color.b * 255))
end

--- @class ColorRGB
--- @field r number Red value
--- @field g number Green value
--- @field b number Blue value

--- @class ColorTable
--- @field color Color SM.Color representation
--- @field hex string Hex string representation

--- @class ColorRow
--- @field first ColorTable Lightest Shade / Primary Variant
--- @field second ColorTable Medium-Light Shade
--- @field third ColorTable Medium-Dark Shade
--- @field fourth ColorTable Darkest Shade

--- @class PaintToolColors  List of all colors used in the Paint Tool
--- @field white ColorRow
--- @field yellow ColorRow
--- @field lime ColorRow
--- @field green ColorRow
--- @field cyan ColorRow
--- @field blue ColorRow
--- @field purple ColorRow
--- @field pink ColorRow
--- @field red ColorRow
--- @field orange ColorRow
color.paintTool = {
    white = {
        first  = {color = sm.color.new("#eeeeee"), hex = "#eeeeee"},
        second = {color = sm.color.new("#7f7f7f"), hex = "#7f7f7f"},
        third  = {color = sm.color.new("#4a4a4a"), hex = "#4a4a4a"},
        fourth = {color = sm.color.new("#222222"), hex = "#222222"}
    },
    yellow = {
        first  = {color = sm.color.new("#f5f071"), hex = "#f5f071"},
        second = {color = sm.color.new("#e2db13"), hex = "#e2db13"},
        third  = {color = sm.color.new("#817c00"), hex = "#817c00"},
        fourth = {color = sm.color.new("#323000"), hex = "#323000"}
    },
    lime = {
        first  = {color = sm.color.new("#cbf66f"), hex = "#cbf66f"},
        second = {color = sm.color.new("#a0ea00"), hex = "#a0ea00"},
        third  = {color = sm.color.new("#577d07"), hex = "#577d07"},
        fourth = {color = sm.color.new("#375000"), hex = "#375000"}
    },
    green = {
        first  = {color = sm.color.new("#68ff88"), hex = "#68ff88"},
        second = {color = sm.color.new("#19e753"), hex = "#19e753"},
        third  = {color = sm.color.new("#0e8031"), hex = "#0e8031"},
        fourth = {color = sm.color.new("#064023"), hex = "#064023"}
    },
    cyan = {
        first  = {color = sm.color.new("#7eeded"), hex = "#7eeded"},
        second = {color = sm.color.new("#2ce6e6"), hex = "#2ce6e6"},
        third  = {color = sm.color.new("#118787"), hex = "#118787"},
        fourth = {color = sm.color.new("#0a4444"), hex = "#0a4444"}
    },
    blue = {
        first  = {color = sm.color.new("#4c6fe3"), hex = "#4c6fe3"},
        second = {color = sm.color.new("#0a3ee2"), hex = "#0a3ee2"},
        third  = {color = sm.color.new("#0f2e91"), hex = "#0f2e91"},
        fourth = {color = sm.color.new("#0a1d5a"), hex = "#0a1d5a"}
    },
    purple = {
        first = {color = sm.color.new("#ae79f0"),  hex = "#ae79f0"},
        second = {color = sm.color.new("#7514ed"), hex = "#7514ed"},
        third = {color = sm.color.new("#500aa6"),  hex = "#500aa6"},
        fourth = {color = sm.color.new("#35086c"), hex = "#35086c"}
    },
    pink = {
        first  = {color = sm.color.new("#ee7bf0"), hex = "#ee7bf0"},
        second = {color = sm.color.new("#cf11d2"), hex = "#cf11d2"},
        third  = {color = sm.color.new("#720a74"), hex = "#720a74"},
        fourth = {color = sm.color.new("#520653"), hex = "#520653"}
    },
    red = {
        first  = {color = sm.color.new("#f06767"), hex = "#f06767"},
        second = {color = sm.color.new("#d02525"), hex = "#d02525"},
        third  = {color = sm.color.new("#7c0000"), hex = "#7c0000"},
        fourth = {color = sm.color.new("#560202"), hex = "#560202"}
    },
    orange = {
        first  = {color = sm.color.new("#eeaf5c"), hex = "#eeaf5c"},
        second = {color = sm.color.new("#df7f00"), hex = "#df7f00"},
        third  = {color = sm.color.new("#673b00"), hex = "#673b00"},
        fourth = {color = sm.color.new("#472800"), hex = "#472800"}
    },
}

--- List of all Characters colors
--- @class CharacterColors                    List of all Characters colors
--- @field Green_Totebot ColorTable           Green_Totebot Color #49642d
--- @field Haybot ColorTable                  Haybot Color #e75b0f
--- @field Tapebot ColorTable                 Tapebot Color #035cff
--- @field Red_Tapebot ColorTable             Red_Tapebot Color #ec1919
--- @field Farmbot ColorTable                 Farmbot Color #c52c18
color.characters = {
    Green_Totebot = {color = sm.color.new("#49642d"), hex = "#49642d"},
    Haybot        = {color = sm.color.new("#e75b0f"), hex = "#e75b0f"},
    Tapebot       = {color = sm.color.new("#035cff"), hex = "#035cff"},
    Red_Tapebot   = {color = sm.color.new("#ec1919"), hex = "#ec1919"},
    Farmbot       = {color = sm.color.new("#c52c18"), hex = "#c52c18"}
}

--- @class InteractableColors              List of all Interactables colors
--- @field bearings table<Color>           Bearings (normal #007FFF, highlight #3094FF)
--- @field seats table<Color>              Seats (normal #00FF80, highlight #6AFFB6)
--- @field switches table<Color>           Switches (normal #EE2A7B, highlight #FF4394)
--- @field buttons table<Color>            Buttons (normal #EE4AB0, highlight #F672C2)
--- @field logic_gates table<Color>        Logic Gates (normal #1E68BB, highlight #3881D3)
--- @field timers table<Color>             Timers (normal #6B5AAA, highlight #7E6DBD)
--- @field robot_heads table<Color>        Robot Heads (normal #A2A2A2, highlight #BBBBBB)
--- @field decor table<Color>              Decor (normal #8C8C8C, highlight #A8A8A8)
--- @field guns_cannons table<Color>       Guns Cannons (normal #CB0A00, highlight #EE0A00)
--- @field lights table<Color>             Lights (normal #F6E46A, highlight #F7EB99)
--- @field pistons table<Color>            Pistons (normal #104CE4, highlight #235CEE)
--- @field sensors table<Color>            Sensors (normal #910640, highlight #B60E55)
--- @field controllers table<Color>        Controllers (normal #6800D0, highlight #6800D0)
--- @field thrusters table<Color>          Thrusters (normal #20C5C9, highlight #2CEBF3)
--- @field driver_seats table<Color>       Driver Seats (normal #80FF00, highlight #B4FF68)
--- @field engines table<Color>            Engines (normal #FF8000, highlight #FF9F3A)
--- @field cash_register table<Color>      Cash Register (normal #8C8C8C, highlight #A8A8A8)
--- @field radio table<Color>              Radio (normal #767676, highlight #979797)
--- @field other table<Color>              Other (normal #7F7F7F, highlight #FFFFFF)
color.interactables = {
    bearings          = {color = sm.color.new("#007FFF"), color_hex = "#007FFF", highlight = sm.color.new("#3094FF"), highlight_hex = "#3094FF"},
    seats             = {color = sm.color.new("#00FF80"), color_hex = "#00FF80", highlight = sm.color.new("#6AFFB6"), highlight_hex = "#6AFFB6"},
    switches          = {color = sm.color.new("#EE2A7B"), color_hex = "#EE2A7B", highlight = sm.color.new("#FF4394"), highlight_hex = "#FF4394"},
    buttons           = {color = sm.color.new("#EE4AB0"), color_hex = "#EE4AB0", highlight = sm.color.new("#F672C2"), highlight_hex = "#F672C2"},
    logic_gates       = {color = sm.color.new("#1E68BB"), color_hex = "#1E68BB", highlight = sm.color.new("#3881D3"), highlight_hex = "#3881D3"},
    timers            = {color = sm.color.new("#6B5AAA"), color_hex = "#6B5AAA", highlight = sm.color.new("#7E6DBD"), highlight_hex = "#7E6DBD"},
    robot_heads       = {color = sm.color.new("#A2A2A2"), color_hex = "#A2A2A2", highlight = sm.color.new("#BBBBBB"), highlight_hex = "#BBBBBB"},
    decor             = {color = sm.color.new("#8C8C8C"), color_hex = "#8C8C8C", highlight = sm.color.new("#A8A8A8"), highlight_hex = "#A8A8A8"},
    guns_cannons      = {color = sm.color.new("#CB0A00"), color_hex = "#CB0A00", highlight = sm.color.new("#EE0A00"), highlight_hex = "#EE0A00"},
    lights            = {color = sm.color.new("#F6E46A"), color_hex = "#F6E46A", highlight = sm.color.new("#F7EB99"), highlight_hex = "#F7EB99"},
    pistons           = {color = sm.color.new("#104CE4"), color_hex = "#104CE4", highlight = sm.color.new("#235CEE"), highlight_hex = "#235CEE"},
    sensors           = {color = sm.color.new("#910640"), color_hex = "#910640", highlight = sm.color.new("#B60E55"), highlight_hex = "#B60E55"},
    controllers       = {color = sm.color.new("#6800D0"), color_hex = "#6800D0", highlight = sm.color.new("#6800D0"), highlight_hex = "#6800D0"},
    thrusters         = {color = sm.color.new("#20C5C9"), color_hex = "#20C5C9", highlight = sm.color.new("#2CEBF3"), highlight_hex = "#2CEBF3"},
    driver_seats      = {color = sm.color.new("#80FF00"), color_hex = "#80FF00", highlight = sm.color.new("#B4FF68"), highlight_hex = "#B4FF68"},
    engines           = {color = sm.color.new("#FF8000"), color_hex = "#FF8000", highlight = sm.color.new("#FF9F3A"), highlight_hex = "#FF9F3A"},
    cash_register     = {color = sm.color.new("#8C8C8C"), color_hex = "#8C8C8C", highlight = sm.color.new("#A8A8A8"), highlight_hex = "#A8A8A8"},
    radio             = {color = sm.color.new("#767676"), color_hex = "#767676", highlight = sm.color.new("#979797"), highlight_hex = "#979797"},
    other             = {color = sm.color.new("#7F7F7F"), color_hex = "#7F7F7F", highlight = sm.color.new("#FFFFFF"), highlight_hex = "#FFFFFF"},
}

--- @class GameColors
--- @field paintTool PaintToolColors List of all colors used in the Paint Tool
--- @field characters CharacterColors List of all Characters colors
--- @field interactables InteractableColors List of all Interactables colors
--- @type GameColors Colors used in the game
color = color or {}
