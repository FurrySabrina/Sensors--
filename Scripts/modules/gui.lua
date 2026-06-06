gui = {}

local replacements = {}
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
    local config = self.cl.config

    if config.upgrade then
        local is_survival = sm.game.getLimitedInventory()
        local count_str

        if is_survival then
            local inventory = sm.localPlayer.getPlayer():getInventory()
            local component_uuid = sm.uuid.new("5530e6a0-4748-4926-b134-50ca9ecb9dcf")
            local total_components = sm.container.totalQuantity(inventory, component_uuid)
            
            local can_upgrade = total_components >= config.upgrade_cost
            local total_color = can_upgrade and "#cff42b" or "#ff2b4a"
            count_str = total_color .. total_components
        else
            count_str = "#cff42b*"
        end

        interface:setText("UpgradeCost", string.format("%s #9f9e9e/ %d", count_str, config.upgrade_cost))
        interface:setText("UpgradeInfo", config.upgrade_info or "")
    end

    interface:setText("Open_Settings", getReplacement("@{OPEN_SENSORS_PLUSPLUS_SETTINGS}"))
    interface:setText("Range_Lower", "1")
    interface:setText("Range", "1")
    interface:setText("Range_Upper", tostring(config.distance))
end

--- Initializes or refreshes the GUI.
--- @param self ShapeClass The sensor class
function gui.init(self)
    replacements = safe_json_open(modDirectory ..
        "/Gui/Language/" .. sm.gui.getCurrentLanguage() .. "/gui_replacements.json") or {}
    if next(replacements) == nil then
        sm.log.warning("No replacements found for language: " ..
            sm.gui.getCurrentLanguage() .. ". Using English fallback.")
    end

    if self.cl.gui then
        self.cl.gui.interface:close()
        self.cl.gui.interface:destroy()
    end

    self.cl.gui = {}
    self.cl.gui.language = sm.gui.getCurrentLanguage()
    self.cl.gui.is_survival = sm.game.getLimitedInventory()
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
    self.cl.gui.interface:setOnCloseCallback( "client_onClosed" )

    local interface = self.cl.gui.interface
    local upgrade = self.cl.config.upgrade

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
        interface:setButtonCallback(button, "client_onButtonPress")
    end

    if upgrade then
        interface:setVisible("NoUpgradeBackground", false)
        interface:setVisible("UpgradeBackground", true)
        interface:setVisible("UpgradeContainer", true)
        interface:setIconImage("UpgradeIcon", sm.uuid.new(upgrade))
    end

    gui.loadText(self)
end

--- Handles a button press.
--- @param self ShapeClass The sensor class
function sensor:client_onButtonPress(button)
    print(button)
end

--- Opens the gui.
--- @param self ShapeClass The sensor class
function gui.open(self)
    gui.init(self)
    self.cl.gui.interface:open()
end

--- Runs when the gui is force closed.
--- @param self ShapeClass The sensor class
function sensor:client_onClosed()
end
