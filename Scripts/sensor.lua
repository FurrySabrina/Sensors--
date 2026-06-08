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
    self.sv.saved = {
        distance = self.data.distance,
        is_switch = false,
        is_sound = false,
    }
end

function sensor:server_onRefresh()
    self.data = config_data[tostring(self.shape.uuid)] or {}
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

--- Toggles the state of the switch function
--- @param self ShapeClass The sensor class
function sensor:server_toggleSwitch(_, player)
    local is_switch = self.sv.saved.is_switch
    self.sv.saved.is_switch = not is_switch

    if is_switch then
        self.network:sendToClient(player, "client_switch", self.sv.saved.distance)
    else
        self.network:sendToClient(player, "client_switchOff")
    end
end

-------------   Client   -------------

function sensor:client_onCreate()
    self.cl = {}
    self.cl.saved = {} -- all saved data
    if sm.isHost then
        self.network:sendToServer("server_setHost")
    end
    indicator.init(self)
end

function sensor:client_onRefresh()
    gui.refresh(self)

    indicator.setColor(self, sm.color.new("#00CD22"))
end

function sensor:client_onInteract(character, state)
    if state then
        gui.open(self)
    end
end

function sensor:client_onUpgraded()
    gui.init(self, true)
end
