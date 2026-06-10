gui = {}

local replacement_cache = {}

-- Constants for readability
local COMPONENT_KIT_UUID = sm.uuid.new("5530e6a0-4748-4926-b134-50ca9ecb9dcf")
local COLOR_GREEN = "#cff42b"
local COLOR_RED   = "#ff2b4a"
local buttons = {
    "Open_Settings",
    "Setting_Switch",
    "Setting_Sound",
    "Setting_Color",
    "Upgrade"
}

--- Attempts to get a replacement for a key.
--- @param key string The key to get the replacement for
function getReplacement(key)
    fprint({type = "gui"}, "Getting replacement for: " .. key)
    local language = sm.gui.getCurrentLanguage()
    if not replacement_cache[language] then
        replacement_cache[language] = safe_json_open(modDirectory .. "/Gui/Language/" .. language .. "/gui_replacements.json") or {}
    end
    if replacement_cache[language] and replacement_cache[language][key] then
        fprint({type = "gui"}, "Found replacement for: " .. key)
        return replacement_cache[language][key]
    else
        if not replacement_cache["English"] then
            replacement_cache["English"] = safe_json_open(modDirectory .. "/Gui/Language/English/gui_replacements.json") or {}
        end
        fprint({type = "fallback"}, "No replacement found for: " .. key .. ", using fallback")
        return replacement_cache["English"][key] .. " [ENG]"
    end
end

--- @class GuiData Data that can be sent to the GUI.
--- @field is_open? boolean Whether the GUI is open or not. [default: false]
--- @field is_refresh? boolean Whether the GUI is refreshing or not. [default: false]
--- @field no_load? boolean Whether the GUI should not load or not. [default: false]
--- @field page? string The page to open the GUI on. [default: main]

--- Initializes or refreshes the GUI.
--- @param self ShapeClass The sensor class
--- @param data? GuiData Data to send to the GUI
function gui.refresh(self, data)
    if data then
        fprint({type = "gui"}, "Refreshing GUI with data: " .. tableConcat(data, ", "))
    else
        fprint({type = "gui"}, "Refreshing GUI")
    end

    if not data then data = {} end

    -- intialize the self.cl.gui
    if not self.cl.gui then
        self.cl.gui = {}
        self.cl.gui.cache = {}
        self.cl.gui.is_open = data.is_open or false
        self.cl.gui.interface = nil
    end

    local is_open = data.is_open or self.cl.gui.is_open
    local is_refresh = data.is_refresh or false
    local no_load = data.no_load or false
    local page = data.page or "main"
    local first_open = self.cl.gui.interface == nil
    local is_upgrade = self.data.upgrade or false

    local interface = nil
    if first_open and not no_load then

        fprint({type = "gui"}, "Loading GUI")

        interface = sm.gui.createGuiFromLayout(
            "$CONTENT_DATA/Gui/Layouts/Sensor.layout",
            false,
            {
                isHud = false,
                isInteractive = true,
                needsCursor = true,
                hidesHotbar = false,
                isOverlapped = true,
                backgroundAlpha = 0,
            }
        )

        for _, button in ipairs(buttons) do
            interface:setButtonCallback(button, "client_onGuiButtonPress")
        end

        interface:createHorizontalSlider("RangeSlider", config_data.range_max, self.cl.saved.distance-1, "client_onRangeChanged", true)

        self.cl.gui.interface = interface
    else
        if not self.cl.gui.interface then
            return
        end
        interface = self.cl.gui.interface
    end

    if page == "main" then
        -- main sensor page

        if is_refresh or first_open then
            interface:setText("SubTitle", "#{LEVEL} " .. self.data.level)
            interface:setIconImage("Icon", sm.uuid.new(self.data.uuid))
            interface:setSliderPosition("RangeSlider", self.cl.saved.distance-1)
            interface:setText("Open_Settings", getReplacement("@{OPEN_SETTINGS}"))

            interface:setVisible("UpgradeContainer", is_upgrade)
            interface:setVisible("NoUpgradeBackground", not is_upgrade)
            interface:setVisible("UpgradeBackground", is_upgrade)

            if is_upgrade then
                local is_survival = sm.game.getLimitedInventory()
                local count_str

                if is_survival then
                    local inventory = sm.localPlayer.getPlayer():getInventory()
                    local total_components = sm.container.totalQuantity(inventory, COMPONENT_KIT_UUID)

                    local can_upgrade = total_components >= self.data.upgrade_cost
                    local total_color = can_upgrade and COLOR_GREEN or COLOR_RED
                    count_str = total_color .. total_components
                else
                    count_str = COLOR_GREEN .. "*"
                end

                interface:setText("UpgradeCost", string.format("%s #9f9e9e/ %d", count_str, self.data.upgrade_cost))
                interface:setText("UpgradeInfo", self.data.upgrade_info or "")
            end
        end

        if is_open then
            interface:open()
        end

    elseif page == "sensor++_settings" then

        

    end

end

----------   Sensor Functions   ----------

--- Refreshes the GUI.
--- @param self ShapeClass The sensor class
function sensor:client_guiRefresh()
    fprint({type = "gui"}, "Refreshing GUI (through server)")
    gui.refresh(self, {is_refresh = true})
end

--- Handles a button press.
--- @param self ShapeClass The sensor class
function sensor:client_onGuiButtonPress(button)
    if button == "Upgrade" then
        self.network:sendToServer("server_requestUpgrade")
        return
    end

    fwarn({type = "gui"}, "Unhandled button: " .. button)
end

--- Fires when the range slider is changed
--- @param self ShapeClass The sensor class
function sensor:client_onRangeChanged(value)
    local interface = self.cl.gui.interface
    value = value + 1 -- convert to 1-max
    fprint({type = "gui"}, "Range changed to: " .. value)
    if value > self.data.max_distance then
        interface:setSliderPosition("RangeSlider", self.data.max_distance-1)
        value = self.data.max_distance
    end
    if self.cl.gui.cache.range ~= value then
        self.cl.gui.cache.range = value
        self.cl.saved.distance = value
        self.network:sendToServer("server_setDistance", value)
        fprint({type = "network"}, "Sent range: " .. tostring(value) .. " to server")
    end
end

function sensor:client_onInteract(character, state)
    if state then
        fprint({type = "interaction"}, "Interacted with sensor")
        gui.refresh(self, {is_open = true, is_refresh = true})
    end
end

--- Lets the client change the distance
--- @param self ShapeClass The sensor class
--- @param range number The range to set the distance to
function sensor:server_setDistance(range, player)
    fprint({type = "network"}, "Received range: " .. tostring(range) .. " from " .. player.name)
    if not range then return end
    if type(range) ~= "number" then return end
    self.sv.saved.distance = sm.util.clamp(range, 1, self.data.max_distance)
    self.storage:save(self.sv.saved)
    fprint({type = "network"}, "Sent range: " .. tostring(range) .. " to clients")
    self.network:sendToClients("client_receiveClientSettings", self.sv.saved)
end
