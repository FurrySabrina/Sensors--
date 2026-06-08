dofile"modules/utils.lua"

---@type ShapeClass
sensor = sensor or class()

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

if not config_data then
    error("Config file not found")
end

-------------   Modules   ------------

-- modules are loaded in the order they are listed here
local modules = {
    "dofile_fixer",
    "upgrade",
    "gui",
    "indicator",
}

for _, module in ipairs(modules) do
    dofile("modules/" .. module .. ".lua")
end

-------------   Server   -------------

function sensor:server_onCreate()
    self.sv = {}
    self.sv.host = nil -- always the host of the world

    self.data = config_data[tostring(self.shape.uuid)] or {}
end

function sensor:server_onRefresh()
    self.data = safe_json_open(modDirectory .. "/Scripts/config.json")[tostring(self.shape.uuid)] or {}
    if not self.data then
        error("Config file not found")
    end
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
end

-------------   Client   -------------

function sensor:client_onCreate()
    self.cl = {}

    indicator.init(self)
end

function sensor:client_onRefresh()
    gui.refresh(self)
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

function sensor:client_onUpgraded()
    gui.init(self, true)
end
