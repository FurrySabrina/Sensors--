upgrade = {}

--- Requests to upgrade the sensor.
--- @param self ShapeClass The sensor class
--- @param player Player The player that is requesting to upgrade the sensor
function sensor:server_requestUpgrade(_, player)
    local component_uuid = sm.uuid.new("5530e6a0-4748-4926-b134-50ca9ecb9dcf")
    local total_components = sm.container.totalQuantity(player:getInventory(), component_uuid)
    
    if not self.data.upgrade then
        self.network:sendToClient(player, "client_guiRefresh")
        return
    end

    local can_upgrade = total_components >= self.data.upgrade_cost

    if can_upgrade then

        local shape = self.shape
        shape:replaceShape(sm.uuid.new(self.data.upgrade_uuid))

        self.data = safe_json_open(modDirectory .. "/Scripts/config.json")[tostring(self.data.upgrade_uuid)]

        self.network:sendToClient(player, "client_upgraded")
    end

    return can_upgrade
end

--- Sucessfually upgrades the sensor (client side).
--- @param self ShapeClass The sensor class
function sensor:client_upgraded()
    
    local interface = self.cl.gui.interface
    interface:playEffect("Icon", "Gui - UpgradeIcon", true)
    interface:playEffect("Upgrade", "Gui - Upgrade", true)

    local interactable = self.shape.interactable
    sm.effect.playHostedEffect( "Part - Upgrade", interactable )
    gui.refresh(self, true)
end
