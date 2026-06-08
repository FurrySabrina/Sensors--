
--- Opens a json file and returns the data. (safely)
--- @param file string File to open
--- @return table? Data The data (if successful)
function safe_json_open(file)
    local success, data = pcall(sm.json.open, file)
    if not success then
        print("Error loading file: " .. file)
        return
    end
    if not data then
        print("No data found in file: " .. file)
        return
    end
    return data
end

--- Formats a table into a consistant string
--- @param t table The table to serialize
--- @return string? The serialized table
local function serializeTable(t)
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



debugDraws = {
    --- Draws a single debug line for a single frame.
    --- 
    --- **Warning:** *To keep the line visible, this function must be called every frame.*
    --- @param from Vec3 The start position of the line.
    --- @param to Vec3 The end position of the line.
    --- @param color Color The color of the line.
    line = function(from, to, color)
        sm.debugDraw.drawLine(from, to, color)
    end,
    --- Adds a named arrow debug draw.
    --- @param name string The debug arrow name.
    --- @param from Vec3 The from position.
    --- @param to? Vec3 The to position. Defaults to the from position plus one along the z axis. (World up vector)
    arrow = function(id, name, from, to, color)
        stored_debugDraws[id][name] = 0
        sm.debugDraw.addArrow(id.."_"..name, from, to, color)
    end,
    --- Adds a named sphere debug draw.
    --- @param name string The debug sphere name.
    --- @param center Vec3 The sphere center.
    --- @param radius? number The sphere radius. Defaults to 0.125.
    sphere = function(id, name, center, radius, color)
        stored_debugDraws[id][name] = 0
        stored_debugDraws[name] = 0
        sm.debugDraw.addSphere(id.."_"..name, center, radius, color)
    end,
    --- Adds a named transform debug draw.
    --- @param name string The debug transform name.
    --- @param origin Vec3 The transform origin.
    --- @param rotation Quat The transform rotation.
    transform = function(id, name, origin, rotation, scale)
        stored_debugDraws[id][name] = 0
        stored_debugDraws[name] = 0
        sm.debugDraw.addTransform(id.."_"..name, origin, rotation, scale)
    end
}
