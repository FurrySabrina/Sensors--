upgrade                  = {}

local COMPONENT_KIT_UUID = sm.uuid.new("5530e6a0-4748-4926-b134-50ca9ecb9dcf")
local COLOR_GREEN        = "#cff42b"
local COLOR_RED          = "#ff2b4a"

--- Requests to upgrade the sensor.
--- @param self ShapeClass The sensor class
--- @param player Player The player that is requesting to upgrade the sensor
function sensor:server_requestUpgrade(_, player)
    fprint({ type = "interaction" }, player.name .. " requested to upgrade sensor")
    local inventory = player:getInventory()
    local total_components = sm.container.totalQuantity(inventory, COMPONENT_KIT_UUID)

    if not self.data.upgrade then
        fwarn({ type = "interaction" }, "Sensor is not upgradable")
        fprint({ type = "network" }, "Refreshed client GUI because sensor is not upgradable")
        self.network:sendToClient(player, "client_guiRefresh") -- somehow the player pressed the upgrade button but the sensor is not upgradable
        return
    end

    local can_upgrade = total_components >= self.data.upgrade_cost

    if can_upgrade then
        fprint({ type = "interaction" }, "Sensor Upgraded")

        -- take the used components
        sm.container.beginTransaction()
        sm.container.spend(inventory, COMPONENT_KIT_UUID, self.data.upgrade_cost)
        sm.container.endTransaction()

        local shape = self.shape
        shape:replaceShape(sm.uuid.new(self.data.upgrade_uuid))

        self.data = config_data[self.data.upgrade_uuid] or {}

        self.network:sendToClient(player, "client_upgraded")
    else
        fwarn({ type = "interaction" }, "Sensor is not upgradable")
    end

    return can_upgrade
end

--- Sucessfually upgrades the sensor (client side).
--- @param self ShapeClass The sensor class
function sensor:client_upgraded()
    fprint({ type = "network" }, "Successfully upgraded sensor")

    local sensorGui = self.cl.gui.interfaces.sensor
    sensorGui:playEffect("Icon", "Gui - UpgradeIcon", true)
    sensorGui:playEffect("Upgrade", "Gui - Upgrade", true)

    local interactable = self.shape.interactable
    sm.effect.playHostedEffect("Part - Upgrade", interactable)
    gui.refresh(self, { is_refresh = true })
end

--- Gets the upgrade total/cost for the sensor gui.
--- @param self ShapeClass The sensor class
function upgrade.getUpgradeCost(self)
    local survival = sm.game.getLimitedInventory()
    local inventory = sm.localPlayer.getPlayer():getInventory()
    local total_components = sm.container.totalQuantity(inventory, COMPONENT_KIT_UUID)

    local can_upgrade = total_components >= self.data.upgrade_cost

    local total = survival and (can_upgrade and COLOR_GREEN .. total_components or COLOR_RED .. total_components) or
    COLOR_GREEN .. "*"

    return total .. "#FFFFFF/" .. self.data.upgrade_cost
end

--- Checks if a upgrade is possible.
--- @param self ShapeClass The sensor class
function upgrade.isPossible(self)
    local inventory = sm.localPlayer.getPlayer():getInventory()
    local total_components = sm.container.totalQuantity(inventory, COMPONENT_KIT_UUID)

    return total_components >= self.data.upgrade_cost
end
