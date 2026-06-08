gui = {}

local replacements = safe_json_open(modDirectory .. "/Gui/Language/" .. sm.gui.getCurrentLanguage() .. "/gui_replacements.json") or {}
local current_language = sm.gui.getCurrentLanguage()
local english_data = safe_json_open(modDirectory .. "/Gui/Language/English/gui_replacements.json") or {}

--- Attempts to get a replacement for a key.
--- @param key string The key to get the replacement for
function getReplacement(key)
    if replacements[key] then
        return replacements[key]
    else
        if english_data[key] then
            return english_data[key] .. " [ENG]"
        else
            return key
        end
    end
end

function gui.loadText(self)

    local interface = self.cl.gui.interface

    if self.data.upgrade then
        local is_survival = sm.game.getLimitedInventory()
        local count_str

        if is_survival then
            local inventory = sm.localPlayer.getPlayer():getInventory()
            local component_uuid = sm.uuid.new("5530e6a0-4748-4926-b134-50ca9ecb9dcf")
            local total_components = sm.container.totalQuantity(inventory, component_uuid)

            local can_upgrade = total_components >= self.data.upgrade_cost
            local total_color = can_upgrade and "#cff42b" or "#ff2b4a"
            count_str = total_color .. total_components
        else
            count_str = "#cff42b*"
        end

        interface:setText("UpgradeCost", string.format("%s #9f9e9e/ %d", count_str, self.data.upgrade_cost))
        interface:setText("UpgradeInfo", self.data.upgrade_info or "")
    end

    interface:setText("Open_Settings", getReplacement("@{OPEN_SENSORS_PLUSPLUS_SETTINGS}"))
    interface:setText("Range_Lower", "1")
    interface:setText("Range", "1")
    interface:setText("Range_Upper", tostring(self.data.distance))
end

--- Initializes or refreshes the GUI.
--- @param self ShapeClass The sensor class
--- @param is_open boolean Whether the GUI is open or not.
function gui.init(self, is_open)
    if self.cl.gui and sm.exists(self.cl.gui.interface) then
        gui.refresh(self, is_open) -- pass it off to the refresh function instead of doing it here
        return
    end

    self.cl.gui = {}
    self.cl.gui.is_open = is_open
    self.cl.gui.interface = sm.gui.createGuiFromLayout(
        "$CONTENT_DATA/Gui/Layouts/Sensor.layout",
        false,
        {
            isHud = false,        --Whether the GUI is a HUD GUI or not.
            isInteractive = true, --Whether the GUI can be interacted with or not.
            needsCursor = true,   --Whether the GUI "captures" the mouse or not.
            hidesHotbar = false,  --Whether the hotbar is hidden when the GUI is open or not.
            isOverlapped = true,  --?
            backgroundAlpha = 0,  --The transparency of the GUI background. 1 = opaque, 0 = transparent
        }
    )

    local interface = self.cl.gui.interface

    interface:setIconImage("Icon", self.shape.uuid)

    -- hook buttons
    local buttons = {
        "Open_Settings",
        "Setting_Switch",
        "Setting_Sound",
        "Setting_Color",
        "Upgrade"
    }

    for _, button in ipairs(buttons) do
        interface:setButtonCallback(button, "client_onGuiButtonPress")
    end

    if self.data.upgrade then
        interface:setVisible("NoUpgradeBackground", false)
        interface:setVisible("UpgradeBackground", true)
        interface:setVisible("UpgradeContainer", true)
        interface:setIconImage("UpgradeIcon", sm.uuid.new(self.data.upgrade_uuid))
    end

    if not self.data.detect_color then
        interface:setVisible("Setting_Color", false)
    end

    gui.loadText(self)

    if is_open then
        interface:open()
    end
end

--- Refreshes the GUI.
--- @param self ShapeClass The sensor class
function gui.refresh(self, is_open)

    if is_open then
        goto open
    end

    if not self.cl.gui then
        return
    end

    if not self.cl.gui.is_open then
        return
    end

    ::open::

    if current_language ~= sm.gui.getCurrentLanguage() then
        replacements = safe_json_open(modDirectory .. "/Gui/Language/" .. sm.gui.getCurrentLanguage() .. "/gui_replacements.json") or {}
        current_language = sm.gui.getCurrentLanguage()
    end

    local interface = self.cl.gui.interface

    interface:setIconImage("Icon", sm.uuid.new(self.data.uuid))

    if self.data.upgrade then
        interface:setVisible("NoUpgradeBackground", false)
        interface:setVisible("UpgradeBackground", true)
        interface:setVisible("UpgradeContainer", true)
        interface:setIconImage("UpgradeIcon", sm.uuid.new(self.data.upgrade_uuid))
    else
        interface:setVisible("NoUpgradeBackground", true)
        interface:setVisible("UpgradeBackground", false)
        interface:setVisible("UpgradeContainer", false)
    end

    gui.loadText(self)

    if is_open then
        interface:open()
    end
end

--- Refreshes the GUI.
--- @param self ShapeClass The sensor class
function sensor:client_guiRefresh()
    gui.refresh(self, self.cl.gui.is_open)
end

--- Handles a button press.
--- @param self ShapeClass The sensor class
function sensor:client_onGuiButtonPress(button)
    local interface = self.cl.gui.interface

    if button == "Upgrade" then
        self.network:sendToServer("server_requestUpgrade")
    end
end

--- Opens the gui.
--- @param self ShapeClass The sensor classe
function gui.open(self)
    gui.init(self, true)
end
