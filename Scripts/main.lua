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
config_data = safe_json_open(modDirectory .. "/Scripts/config.json")

if not config_data then
    error("Config file not found")
end

stored_debugDraws = stored_debugDraws or {}

-------------   Modules   ------------

-- modules are loaded in the order they are listed here
local modules = {
    "dofile_fixer",
    "global settings",
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
    self.random = math.random()
    self.sv.host = nil -- always the host of the world
    self.data = config_data[tostring(self.shape.uuid)] or {}
    self.sv.saved = self.storage:load() or {
        distance = 1
    }
    self.network:sendToClients("client_receiveClientSettings", self.sv.saved)
    self.storage:save(self.sv.saved)

    stored_debugDraws[self.shape.id] = {}
end

function sensor:server_onRefresh()
    self.data = config_data[tostring(self.shape.uuid)] or {}
end

function sensor:server_onDestroy()
    for name in pairs(stored_debugDraws[self.shape.id]) do
        sm.debugDraw.clear(self.shape.id.."_"..name)
    end
end

--- Lets the client set a setting
--- @param self ShapeClass The sensor class
--- @param data table Data setting to set
function sensor:client_setSetting(data)
    if not data then return end
    if type(data) ~= "table" then return end
    if data.distance then
        self.data.max_distance = math.clamp(data.distance, 1, self.data.max_distance)
    end
end

--- Lets the server know who the host is.
--- @param self ShapeClass The sensor class
--- @param host Player The host of the world (hopefully)
function sensor:server_setHost(_, host)
    -- protection against the host changing
    if not self.sv then
        self.sv = {}
    end
    if not self.sv.host then
        self.sv.host = host
    end
end

-------------   Client   -------------

function sensor:client_onCreate()
    self.cl = {}
    self.cl.saved = {
        distance = 1
    } -- all saved data
    if sm.isHost then
        self.network:sendToServer("server_setHost")
    end
    indicator.init(self)
end

function sensor:client_onRefresh()
    gui.refresh(self)
end

function sensor:client_onInteract(character, state)
    if state then
        gui.open(self)
    end
end


--- Lets the server send settings to the client
--- @param self ShapeClass The sensor class
function sensor:client_receiveClientSettings(saved)
    self.cl.saved.distance = saved.distance
    gui.refresh(self)
end
