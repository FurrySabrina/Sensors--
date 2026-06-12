local do_ansi = true -- ! DISABLE IF ANSI CONSOLE IS NOT AVAILABLE !

local clear_line = do_ansi and "\27[2K\r" or ""
local sensor_start = do_ansi and "\27[0;97m[Sensors++] " or "[Sensors++] "
local func_color = do_ansi and "\27[38;5;135m" or ""

local side_colors = {
    server = do_ansi and "\27[38;5;46m(Server) " or "(Server) ",
    client = do_ansi and "\27[38;5;69m(Client) " or "(Client) ",
    global = do_ansi and "\27[38;5;51m(Global) " or "(Global) "
}

local type_colors = {
    init = do_ansi and "\27[38;5;50m(Initialization) " or "(Initialization) ",
    io = do_ansi and "\27[38;5;37m(IO) " or "(IO) ",
    network = do_ansi and "\27[38;5;39m(Network) " or "(Network) ",
    gui = do_ansi and "\27[38;5;211m(GUI) " or "(GUI) ",
    interaction = do_ansi and "\27[38;5;220m(Interaction) " or "(Interaction) ",
    update = do_ansi and "\27[38;5;147m(Update) " or "(Update) ",
    tick = do_ansi and "\27[38;5;107m(Tick) " or "(Tick) ",
    fallback = do_ansi and "\27[38;5;208m(Fallback) " or "(Fallback) ",
    config = do_ansi and "\27[38;5;111m(Config) " or "(Config) ",
    format = do_ansi and "\27[38;5;251m(Format) " or "(Format) ",
    debug = do_ansi and "\27[38;5;198m(Debug) " or "(Debug) "
}

local print_colors = {
    print = do_ansi and "\27[0;92m" or "",
    info = do_ansi and "\27[1;97m" or "",
    warning = do_ansi and "\27[0;33m" or "",
    error = do_ansi and "\27[1;91m" or ""
}

--- Gets the color for a side.
--- @return string The color for the side.
local function getSide()
    local side = is_global and "global" or (sm.isServerMode() and "server" or "client")
    return side_colors[side]
end

--- Gets the color for a type.
--- @param type string The type of print
--- @return string The color for the type. (empty string if not found)
local function getType(type)
    local color = type_colors[type]
    if not color then
        color = ""
    end
    return color
end

--- Gets the color for a print type.
--- @param PType string The type of print
--- @return string The color for the print type.
local function getPrint(PType)
    local color = print_colors[PType]
    if not color then
        color = print_colors.print
    end
    return color
end

--- Gets a formated time from ms (usually from os.clock)
--- @param ms number The time in ms
--- @return string The formatted time
local function getTime(ms)
    ms = ms * 1000 -- convert to ms
    local seconds = math.floor(ms / 1000)
    local minutes = math.floor(seconds / 60)
    local hours = math.floor(minutes / 60)

    if hours > 0 then
        return string.format("%dh %dm %02ds %03dms", hours, minutes % 60, seconds % 60, ms % 999)
    elseif minutes > 0 then
        return string.format("%dm %02ds %03dms", minutes % 60, seconds % 60, ms % 999)
    elseif seconds > 0 then
        return string.format("%02ds %03dms", seconds % 60, ms % 999)
    else
        return string.format("%03dms", ms % 999)
    end
end

--- Gets a compiled print string.
local function getPrintString(PType, data, ...)
    local args = {}
    local n = select("#", ...)
    for i = 1, n do
        local arg = select(i, ...)
        args[i] = tostring(arg)
    end

    local startMS = do_ansi and "\27[90m(" .. getTime(os.clock()) .. ") " or ""
    local func = data.func and func_color .. data.func .. " » " or ""

    return clear_line .. startMS .. sensor_start .. getSide() .. getType(data.type) .. func .. getPrint(PType) .. table.concat(args, " ")
end

--- Fixes the print function to be more readable.
--- @param data table Extra data that can be assigned to the print
--- @param ... any The string to print.
function fprint(data, ...)
    if not is_debug then return end
    print(getPrintString("print", data, ...))
end

--- Fixes the sm.log.info function to be more readable.
--- @param data table Extra data that can be assigned to the info
--- @param ... any The string to log.
function finfo(data, ...)
    if not is_debug then return end
    print(getPrintString("info", data, ...))
end

--- Fixes the sm.log.warning function to be more readable.
--- @param data table Extra data that can be assigned to the warning
--- @param ... any The string to log.
function fwarn(data, ...)
    if not is_debug then return end
    print(getPrintString("warning", data, ...))
end

--- Fixes the sm.log.error function to be more readable.
--- @param data table Extra data that can be assigned to the error
--- @param ... any The string to log.
function ferror(data, ...)
    if not is_debug then return end
    print(getPrintString("error", data, ...))
end

--- Opens a json file and returns the data. (safely)
--- @param file string File to open
--- @return table? Data The data (if successful)
function safe_json_open(file)
    local display_path = file
    local modDirectory = modDirectory .. "/"
    if file:sub(1, #modDirectory) == modDirectory then
        display_path = "Sensors++/" .. file:sub(#modDirectory + 1)
    end
    fprint({type = "io", func = "safe_json_open"}, "Opening json file: " .. display_path)

    local success, data = pcall(sm.json.open, file)
    if not success then
        ferror({type = "io"}, "Error loading json file: " .. file)
        return
    end
    if not data then
        ferror({type = "io"}, "No data found in json file: " .. file)
        return
    end
    return data
end

--- Converts any value into a string.
--- @param data any The value to be converted into a string.
--- @return string The string representation of the value.
function getString(data)
    local dataType = type(data)
    if dataType == "string" then return data end
    if dataType == "table" then return formatTableToString(data, nil, 4) end
    if dataType == "number" then return tostring(data) end
    if dataType == "boolean" then return tostring(data) end
    if dataType == "function" then return "{function}" end
    if data == nil then return "nil" end
    return dataType
end

--- Formats a table into a viewable string
--- @param tbl table The table to format into a string.
--- @param label? string Label to be displayed at the top of the table.
--- @param spaceCount? number The amount of spaces to use for indentation.
function formatTableToString(tbl, label, spaceCount)
    local lines = {}
    label = label or ""
    spaceCount = spaceCount or 4

    -- Internal helper to handle the "level" math automatically
    local function format(t, name, currentLevel)
        local indent = string.rep(" ", currentLevel * spaceCount)
        
        if name ~= "" then 
            table.insert(lines, indent .. name .. " = {") 
        else 
            table.insert(lines, indent .. "{") 
        end

        -- Single table for sorting all keys together
        local keys = {}
        for k in pairs(t) do
            table.insert(keys, k)
        end

        -- Smart sorting using a single table: numbers first, then strings
        table.sort(keys, function(a, b)
            local typeA = type(a)
            local typeB = type(b)

            if typeA ~= typeB then
                -- If one is a number and the other isn't, the number comes first
                if typeA == "number" then return true end
                if typeB == "number" then return false end
                -- Fallback for other mixed types (booleans, etc.)
                return tostring(a) < tostring(b)
            else
                -- If types match, sort normally
                return a < b
            end
        end)

        local childIndent = string.rep(" ", (currentLevel + 1) * spaceCount)

        -- Iterate and process values
        for i = 1, #keys do
            local k = keys[i]
            local v = t[k]
            local vType = type(v)
            
            -- Format the key consistently
            local keyStr = type(k) == "string" and '["' .. k .. '"]' or "[" .. tostring(k) .. "]"

            if vType == "table" then
                format(v, keyStr, currentLevel + 1)
            else
                local value = getString(v)
                table.insert(lines, childIndent .. keyStr .. " = " .. value .. ",")
            end
        end

        table.insert(lines, indent .. "}")
    end

    format(tbl, label, 0)
    return table.concat(lines, "\n")
end

--- Formats a table into a consistant string
--- @param t table The table to serialize
--- @return string? The serialized table
local function serializeTable(t)
    if type(t) ~= "table" then return end

    -- 1. Gather all keys
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    
    -- 2. Sort keys so the order is always deterministic
    table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
    end)
    
    -- 3. Build a standardized string representation
    local parts = {}
    for _, k in ipairs(keys) do
        local v = t[k]
        -- Handle nested tables if necessary by recursing, otherwise convert to string
        local vStr = type(v) == "table" and serializeTable(v) or tostring(v)
        table.insert(parts, tostring(k) .. ":" .. vStr)
    end
    
    return "{" .. table.concat(parts, ",") .. "}"
end

--- Calculates the fletcher32 hash of a string
--- @param str string The string to hash
--- @return string The hash
local function fletcher32Hex(str)
    local s1, s2 = 0xffff, 0xffff
    for i = 1, #str do
        s1 = (s1 + string.byte(str, i)) % 0xffff
        s2 = (s2 + s1) % 0xffff
    end
    -- Combine into a 32-bit integer using Lua 5.1 math instead of bitwise shifts
    local num = (s2 * 65536) + s1
    -- Format as an 8-character hex string
    return string.format("%08x", num)
end

--- Calculates the hash of a table
--- @param t table The table to hash
--- @return string? The hash
function tableHash(t)
    local serialized = serializeTable(t)
    if not serialized then
        return
    end
    return fletcher32Hex(serialized)
end

debugDraw = {
    --- Draws a single debug line for a single frame.
    --- 
    --- **Warning:** *To keep the line visible, this function must be called every frame.*
    --- @param from Vec3 The start position of the line.
    --- @param to Vec3 The end position of the line.
    --- @param color Color The color of the line.
    line = function(from, to, color)
        fprint({type = "debug", func = "debugDraw.line"}, "Drawing line from: " .. from .. " to: " .. to)
        sm.debugDraw.drawLine(from, to, color)
    end,
    --- Adds a named arrow debug draw.
    --- @param name string The debug arrow name.
    --- @param from Vec3 The from position.
    --- @param to? Vec3 The to position. Defaults to the from position plus one along the z axis. (World up vector)
    arrow = function(id, name, from, to, color)
        fprint({type = "debug", func = "debugDraw.arrow"}, "Drawing arrow from: " .. from .. " to: " .. to)
        sm.debugDraw.addArrow(id.."_"..name, from, to, color)
    end,
    --- Adds a named sphere debug draw.
    --- @param name string The debug sphere name.
    --- @param center Vec3 The sphere center.
    --- @param radius? number The sphere radius. Defaults to 0.125.
    sphere = function(id, name, center, radius, color)
        fprint({type = "debug", func = "debugDraw.sphere"}, "Drawing sphere from: " .. center .. " with radius: " .. radius)
        sm.debugDraw.addSphere(id.."_"..name, center, radius, color)
    end,
    --- Adds a named transform debug draw.
    --- @param name string The debug transform name.
    --- @param origin Vec3 The transform origin.
    --- @param rotation Quat The transform rotation.
    transform = function(id, name, origin, rotation, scale)
        fprint({type = "debug", func = "debugDraw.transform"}, "Drawing transform from: " .. origin .. " with rotation: " .. rotation .. " and scale: " .. scale)
        sm.debugDraw.addTransform(id.."_"..name, origin, rotation, scale)
    end
}

--- Fixes the table.concat to work with any type of table values, including keys.
--- @param tbl table The table to concatenate.
--- @param sep string The separator to use.
--- @param i? number The index to start at.
--- @param j? number The index to end at.
--- @return string The concatenated string.
function tableConcat(tbl, sep, i, j)
    local function serialize(t)
        local segments = {}
        
        for k, v in pairs(t) do
            local valueStr
            if type(v) == "table" then
                valueStr = serialize(v)
            else
                valueStr = tostring(v)
            end
            
            table.insert(segments, tostring(k) .. ": " .. valueStr)
        end
        
        return "{" .. table.concat(segments, sep) .. "}"
    end

    -- If i and j are provided, we isolate that range from the top-level table first
    if i or j then
        local slicedTbl = {}
        local startIdx = i or 1
        local endIdx = j or #tbl
        
        for idx = startIdx, endIdx do
            slicedTbl[idx] = tbl[idx]
        end
        return serialize(slicedTbl)
    end

    return serialize(tbl)
end
