is_global = true
dofile"modules/utils.lua"

---@type ShapeClass
sensor = sensor or class()

sensor.colorNormal = sm.color.new( "#910640" )
sensor.colorHighlight = sm.color.new( "#B60E55" )
sensor.connectionInput = sm.interactable.connectionType.logic
sensor.connectionOutput = sm.interactable.connectionType.logic
sensor.maxParentCount = 255
sensor.maxChildCount = 255
sensor.poseWeightCount = 0

is_debug = true -- ! DISABLE FOR RELEASE VERSION !

modDirectory = "$CONTENT_f0b6b45d-fa50-4ede-b919-7e27d9f339c2"
config_data = safe_json_open(modDirectory .. "/Scripts/config.json") or {}
if not config_data then
    error("Config file not found")
end

local use = sm.gui.getKeyBinding("Use", true)
local tinker = sm.gui.getKeyBinding("Tinker", true)

local useStr = "<p textShadow='true' bg='gui_keybinds_bg' color='#ffffff' spacing='5'>"..use.."Use</p>"
local tinkerStr = "<p textShadow='true' bg='gui_keybinds_bg' color='#ffffff' spacing='5'>"..tinker.."Sensors++ Settings</p>"

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
    fprint({type = "init"}, "Creating sensor")
    self.sv = {}
    self.random = math.random()
    self.sv.host = nil -- always the host of the world
    self.data = config_data[tostring(self.shape.uuid)] or {}
    local storage_data = self.storage:load()
    if storage_data then
        fprint({type = "network"}, "Sending saved data to clients")
        self.network:sendToClients("client_receiveClientSettings", storage_data)
    end
    self.sv.saved = storage_data or {
        distance = 1,
    }
end

function sensor:server_onRefresh()
    fprint({type = "init"}, "Refreshing sensor")
    self.data = config_data[tostring(self.shape.uuid)] or {}
end

-------------   Client   -------------

function sensor:client_onCreate()
    fprint({type = "init"}, "Creating sensor")
    self.cl = {}
    self.cl.saved = {
        distance = 1
    } -- all saved data
    indicator.init(self)
end

function sensor:client_canInteract( character )
    --fprint({type = "interaction"}, "client_canInteract")
    sm.gui.setInteractionText( useStr )
    sm.gui.setInteractionText( tinkerStr )
    return true
end

function sensor:client_onRefresh()
    fprint({type = "init"}, "Refreshing sensor")
    -- Ensure data is passed as a table.
    if self.cl.gui and self.cl.gui.interface then
        gui.refresh(self, {is_open = self.cl.gui.is_open, is_refresh = true})
    end
end

--- Lets the server send settings to the client
--- @param self ShapeClass The sensor class
function sensor:client_receiveClientSettings(saved)
    fprint({type = "network"}, "Received server settings: " .. tableConcat(saved, ", "))
    self.cl.saved.distance = saved.distance
    gui.refresh(self, {is_refresh = true, no_load = true})
end

-- DONT REMOVE THIS
is_global = false
