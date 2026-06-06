dofile"modules/utils.lua"

---@type ShapeClass
sensor = class()

sensor.colorNormal = sm.color.new( "#910640" )
sensor.colorHighlight = sm.color.new( "#B60E55" )
sensor.connectionInput = sm.interactable.connectionType.logic
sensor.connectionOutput = sm.interactable.connectionType.logic
sensor.maxParentCount = 255
sensor.maxChildCount = 255
sensor.poseWeightCount = 1

-- self.interactable:setPoseWeight( 0, weight(0-1) ) this is how you set the active pose

modDirectory = "$CONTENT_f0b6b45d-fa50-4ede-b919-7e27d9f339c2"

local config_data = safe_json_open(modDirectory .. "/Scripts/config.json")

-------------   Modules   ------------

-- modules are loaded in the order they are listed here
local modules = {
    "dofile_fixer",
    "gui",
    "indicator",
}

for _, module in ipairs(modules) do
    dofile("modules/" .. module .. ".lua")
end

-------------   Server   -------------

function sensor:server_onCreate()
    print("sensor created")
    self.sv = {}
    self.sv.config = {}
    self.sv.host = nil -- always the host of the world

    -- load config
    self.sv.config = config_data and (config_data[tostring(self.data.level)] or {}) or {}
end

---Called every frame.  
---During a frame update, graphics, animations and effects are updated.  
---**Warning:**
---*Because of how frequent this event is called, the game's frame rate is greatly affected by the amount of code executed here.*
---*For any non-graphics related code, consider using [GameClass.server_onFixedUpdate, server_onFixedUpdate] instead.*
---*If the event is not in use, consider removing it from the script. (Event callbacks that are not implemented will not be called.)*
---@param deltaTime number Delta time since the last frame.
function sensor:server_onUpdate(deltaTime, player)
    if not self.sv.host then
        self.sv.host = player
    end
    if player ~= self.sv.host then
        print("Player is not the host")
        return -- halt here.
    end
end

-------------   Client   -------------

function sensor:client_onCreate()
    print("sensor created")
    self.cl = {}

    -- load config
    local configFile = safe_json_open(modDirectory .. "/Scripts/config.json")
    if configFile then
        if not configFile[tostring(self.data.level)] then
            error("Config file not found")
        end
        self.cl.config = configFile[tostring(self.data.level)]
    end

    gui.init(self)
    indicator.init(self)
end

function sensor:client_onRefresh()
    gui.init(self)
    indicator.init(self)
end

function sensor:client_onDestroy()
    indicator.onDestroy(self)
end

function sensor:client_onFixedUpdate(deltaTime)
end

function sensor:client_onUpdate(deltaTime)
    -- only sends when the host frame is updated to the server (never any clients)
    if sm.isHost then
        self.network:sendToServer("server_onUpdate", deltaTime)
    end
end

function sensor:client_onInteract(character, state)
    if state then
        gui.open(self)
    end
end
