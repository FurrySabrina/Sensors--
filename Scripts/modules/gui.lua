gui = {}

local replacement_cache = {}

--- Attempts to get a replacement for a key.
--- @param key string The key to get the replacement for
function getReplacement(key)
    local language = sm.gui.getCurrentLanguage()
    if replacement_cache[language] and replacement_cache[language][key] then
        return replacement_cache[language][key]
    else
        if not replacement_cache["English"] then
            replacement_cache["English"] = safe_json_open(modDirectory .. "/Gui/Language/English/gui_replacements.json") or {}
        end
        return replacement_cache["English"][key] .. " [ENG]"
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

    interface:setText("SubTitle", "Level " .. self.data.level)
    interface:setText("Open_Settings", getReplacement("@{OPEN_SETTINGS}"))
    interface:setText("Range_Lower", "1")
    interface:setText("Range", "1")
    interface:setText("Range_Upper", tostring(self.data.max_distance))
end

--- Initializes or refreshes the GUI.
--- @param self ShapeClass The sensor class
--- @param is_open boolean Whether the GUI is open or not.
function gui.init(self, is_open)

    -- cache the replacement if not already cached
    if not replacement_cache[sm.gui.getCurrentLanguage()] then
        replacement_cache[sm.gui.getCurrentLanguage()] = safe_json_open(modDirectory .. "/Gui/Language/" .. sm.gui.getCurrentLanguage() .. "/gui_replacements.json") or {}
    end

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
    interface:setVisible("Setting_Color", self.data.detect_color or false)

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

    interface:createHorizontalSlider("Range_Slider", 20, self.cl.saved.distance-1 or 0, "client_onSliderChanged", true)

    if self.data.upgrade then
        interface:setVisible("NoUpgradeBackground", false)
        interface:setVisible("UpgradeBackground", true)
        interface:setVisible("UpgradeContainer", true)
        interface:setIconImage("UpgradeIcon", sm.uuid.new(self.data.upgrade_uuid))
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

    local interface = self.cl.gui.interface

    interface:setIconImage("Icon", sm.uuid.new(self.data.uuid))
    interface:setVisible("Setting_Color", self.data.detect_color)

    interface:setSliderPosition("Range_Slider", self.cl.saved.distance-1)

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

--- Opens the gui.
--- @param self ShapeClass The sensor classe
function gui.open(self)
    gui.init(self, true)
end

----------   Sensor Functions   ----------

--- Refreshes the GUI.
--- @param self ShapeClass The sensor class
function sensor:client_guiRefresh()
    gui.refresh(self, self.cl.gui.is_open)
end

--- Handles a button press.
--- @param self ShapeClass The sensor class
function sensor:client_onGuiButtonPress(button)
    if button == "Upgrade" then
        self.network:sendToServer("server_requestUpgrade")
        return
    end

    print("Unhandled button: " .. button)
end

--- Fires when the range slider is changed
--- @param self ShapeClass The sensor class
function sensor:client_onSliderChanged(value)
    local interface = self.cl.gui.interface
    value = value
    if value > self.data.max_distance-1 then
        interface:setSliderPosition("Range_Slider", self.data.max_distance-1)
        value = self.data.max_distance-1
    end
    self.cl.saved.distance = value+1 -- does get set by the server a few tick later, this is just for a filler for that little time
    self.network:sendToServer("client_setDistance", value+1)
end

--- Lets the client change the distance
--- @param self ShapeClass The sensor class
--- @param data table Data setting to set
function sensor:client_setDistance(data, player)
    if not data then return end
    if type(data) ~= "number" then return end
    self.sv.saved.distance = sm.util.clamp(data, 1, self.data.max_distance)
    self.storage:save(self.sv.saved)
    self.network:sendToClients("client_receiveClientSettings", self.sv.saved)
end
