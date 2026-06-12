-- Global GUI Functions
gui = {}

--===============   Constants   ================--

local replacement_cache  = {}


--============   Helper Functions   ============--

--- Attempts to get a replacement for a key.
--- @param key string The key to get the replacement for
local function getReplacement(key)
    local language = sm.gui.getCurrentLanguage()

    if not replacement_cache[language] then
        replacement_cache[language] = safe_json_open(modDirectory ..
            "/Gui/Language/" .. language .. "/gui_replacements.json") or {}
    end

    if replacement_cache[language] then
        if replacement_cache[language][key] then
            return replacement_cache[language][key]
        else
            return key
        end
    else
        if not replacement_cache["English"] then
            replacement_cache["English"] = safe_json_open(modDirectory .. "/Gui/Language/English/gui_replacements.json") or
                {}
        end

        if not replacement_cache["English"][key] then
            return key
        else
            return replacement_cache["English"][key] .. " [ENG]" or key
        end
    end
end

--- Searches a string for replacements and returns the result
--- @param str string The string to search
local function replace(str)
    local text = string.gsub(str, "@{(.-)}", function(key)
        return getReplacement("@{" .. key .. "}")
    end)
    return text
end

fprint({ type = "gui", func = "replace" }, replace("@{OPEN_SETTINGS}"))

--- @class DropdownSettings Settings for a single dropdown
--- @field name string The name of the dropdown
--- @field options table The options to display in the dropdown

--- @class SliderSettings Settings for a single slider
--- @field name string The name of the slider
--- @field range number The range of the slider
--- @field value? number The value of the slider (default: middle of the range)
--- @field horizontal? boolean Whether the slider is horizontal or vertical
--- @field enableNumbers? boolean Whether the slider should show numbers (only applies to horizontal sliders)

--- @class ButtonSettings Settings for a single button
--- @field name string The name of the button
--- @field type? string The type of button to create (normal or grid)

--- @class IconSettings Settings for a single icon
--- @field name string The name of the icon
--- @field type? string The type of icon to create (IconImage or ItemIcon type)
--- @field uuid? Uuid The UUID of the icon to create (only applies to IconImage type)
--- @field itemResource? string The item resource of the icon to create (only applies to ItemIcon type)
--- @field itemGroup? string The item group of the icon to create (only applies to ItemIcon type)
--- @field itemName? string The item name of the icon to create (only applies to ItemIcon type)
--- @field path? string The path of the icon to create (only applies to Image type)

--- @class TextSettings Settings for a single text
--- @field name string The name of the text
--- @field text string The text to display in the text

--- @class EditBoxSettings Settings for a single edit box
--- @field name string The name of the edit text
--- @field text string The text to display in the edit text

--- @class WidgetData Widget data for a GUI
--- @field dropdowns? DropdownSettings[] The dropdowns to create
--- @field sliders? SliderSettings[] The sliders to create
--- @field buttons? ButtonSettings[] The buttons to create
--- @field icons? IconSettings[] The icons to create
--- @field texts? TextSettings[] The texts to create
--- @field editBoxes? EditBoxSettings[] The edit texts to create
--- @field visible? table<string, boolean> Widgets to make visible or invisible

-- dropdowns, sliders, buttons, icons, texts, editTexts, visible

--- Creates a GUI from a layout with the given data
--- @param layout string The layout to create the GUI from
--- @param layout_data? GuiSettings The data to send to the layout
--- @param widget_data? WidgetData The data to send to the widgets
local function getGui(layout, layout_data, widget_data)
    fprint({ type = "gui", func = "getGui" }, "Creating GUI from layout: Sensors++/Gui/Layouts/" .. layout .. ".layout")
    if type(layout) ~= "string" then
        ferror({ type = "gui", func = "getGui" }, "layout is not a string or is nil")
        return
    end
    local gui = sm.gui.createGuiFromLayout(
        "$CONTENT_DATA/Gui/Layouts/" .. layout .. ".layout",
        false,
        layout_data or {
            isHud = false,
            isInteractive = true,
            needsCursor = true,
            hidesHotbar = false,
            isOverlapped = true,
            backgroundAlpha = 0,
        }
    )

    if not sensor[layout .. "_closed"] then
        sensor[layout .. "_closed"] = function(self)
            gui_closed(self, layout)
        end
    end

    if type(widget_data) ~= "table" then
        widget_data = {}
    end

    -- Dropdowns
    if type(widget_data.dropdowns) == "table" then
        for _, dropdown in ipairs(widget_data.dropdowns) do
            fprint({ type = "gui", func = "getGui / Dropdown" }, "Creating dropdown: " .. dropdown.name)
            local name = dropdown.name
            sensor[name] = function(self, value)
                dropdown_selected(self, gui, name, value)
            end
            for index, option in ipairs(dropdown.options) do
                dropdown.options[index] = replace(option)
            end
            fprint({ type = "gui", func = "getGui / Dropdown" }, "Dropdown options: " .. tableConcat(dropdown.options, ", "))
            gui:createDropDown(name, name, dropdown.options)
        end
    end

    -- Sliders
    if type(widget_data.sliders) == "table" then
        for _, slider in ipairs(widget_data.sliders) do
            fprint({ type = "gui", func = "getGui / Slider" }, "Creating slider: " .. slider.name)
            sensor[slider.name] = function(self, value)
                slider_changed(self, gui, slider.name, value)
            end

            slider.range = math.max(slider.range, 1)
            if not slider.value then slider.value = math.floor((slider.range / 2) + 0.5) end -- the math.floor + 0.5 is to round fix no math.rounding

            if slider.horizontal then
                gui:createHorizontalSlider(slider.name, slider.range, slider.value, slider.name, slider.enableNumbers)
            else
                gui:createVerticalSlider(slider.name, slider.range, slider.value, slider.name)
            end
        end
    end

    -- Buttons
    if type(widget_data.buttons) == "table" then
        for _, button in ipairs(widget_data.buttons) do
            fprint({ type = "gui", func = "getGui / Button" }, "Creating button: " .. button.name)
            local name = button.name
            sensor[name] = function(self)
                button_pressed(self, gui, name)
            end
            if button.type == "grid" then
                gui:setGridButtonCallback(name, name)
            else
                gui:setButtonCallback(name, name)
            end
            if button.text then
                local replacement = replace(button.text)
                if replacement then
                    button.text = replacement
                end
                gui:setText(name, button.text)
            end
            if button.state then
                gui:setButtonState(name, button.state)
            end
        end
    end

    -- Icons
    if type(widget_data.icons) == "table" then
        for _, icon in ipairs(widget_data.icons) do
            fprint({ type = "gui", func = "getGui / Icon" }, "Creating icon: " .. icon.name)
            if icon.type == "IconImage" then
                if type(icon.uuid) == "string" then
                    success, icon.uuid = pcall(sm.uuid.new, icon.uuid)
                    if not success then
                        ferror({ type = "gui", func = "getGui" }, "Icon image is not a UUID")
                        goto continue
                    end
                end
                if type(icon.uuid) ~= "Uuid" then
                    ferror({ type = "gui", func = "getGui" }, "Icon image is not a UUID")
                    goto continue
                end
                gui:setIconImage(icon.name, icon.uuid)
                ::continue::
            elseif icon.type == "ItemIcon" then
                gui:setItemIcon(icon.name, icon.itemResource, icon.itemGroup, icon.itemName)
            else
                local success = pcall(gui.setImage, gui, icon.name, icon.path)
                if not success then
                    ferror({ type = "gui", func = "getGui" }, "Failed to set image: " .. tostring(icon.path))
                end
            end
        end
    end

    -- Texts
    if type(widget_data.texts) == "table" then
        for _, text in ipairs(widget_data.texts) do
            fprint({ type = "gui", func = "getGui / Text" }, "Setting text: " .. text.name)
            gui:setText(text.name, replace(text.text))
        end
    end

    -- EditTexts
    if type(widget_data.editBoxes) == "table" then
        for _, editBox in ipairs(widget_data.editBoxes) do
            fprint({ type = "gui", func = "getGui / EditText" }, "Creating edit text: " .. editBox.name)
            local name = editBox.name
            sensor[name .. "_accepted"] = function(self, _, value)
                edit_text_accepted(self, gui, name, value)
            end
            sensor[name .. "_changed"] = function(self, _, value)
                edit_text_changed(self, gui, name, value)
            end
            gui:setText(name, replace(editBox.text))
            gui:setTextAcceptedCallback(name, name .. "_accepted")
            gui:setTextChangedCallback(name, name .. "_changed")
        end
    end

    -- Visible
    if type(widget_data.visible) == "table" then
        for name, visible in pairs(widget_data.visible) do
            fprint({ type = "gui", func = "getGui / Visible" },
                "Setting: " .. name .. " " .. (visible and "visible" or "invisible"))
            gui:setVisible(name, visible)
        end
    end

    sensor[layout] = function(self)
        gui_closed(self, layout)
    end
    gui:setOnCloseCallback(layout)

    return gui
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
        fprint({ type = "gui", func = "gui.refresh" }, "Refreshing GUI with data: " .. tableConcat(data, ", "))
    else
        fprint({ type = "gui", func = "gui.refresh" }, "Refreshing GUI")
    end

    if not data then data = {} end

    -- intialize the self.cl.gui
    if not self.cl.gui then
        self.cl.gui = {}
        self.cl.gui.is_loaded = false
        self.cl.gui.is_open = data.is_open or false
        self.cl.gui.page = data.page or "sensor"
        self.cl.gui.interfaces = {}
    end

    local is_open = data.is_open or self.cl.gui.is_open
    local is_refresh = data.is_refresh or false
    local no_load = data.no_load or false
    local page = data.page or "sensor"
    local is_upgrade = self.data.upgrade or false

    if not self.cl.gui.is_loaded and not no_load then
        self.cl.gui.is_loaded = true
        fprint({ type = "gui", func = "gui.refresh" }, "Loading GUI")

        self.cl.gui.interfaces.sensor = getGui("sensor",nil,
            {
                sliders = {
                    { 
                        name = "RangeSlider",
                        range = 20,
                        horizontal = true,
                        value = self.cl.saved.distance-1,
                        enableNumbers = true 
                    }
                },
                buttons = {
                    { name = "Open_Settings", text = "#{CONTROLLER_UPGRADE_Settings}" },
                    { name = "Upgrade" }
                },
                icons = {
                    { name = "Icon", type = "IconImage", uuid = self.data.uuid },
                    { name = "UpgradeIcon", type = "IconImage", uuid = self.data.upgrade_uuid }
                },
                texts = {
                    { name = "SubTitle", text = "#{LEVEL} " .. self.data.level },
                    { name = "UpgradeInfo", text = self.data.upgrade_info or "" },
                },
                visible = {
                    UpgradeBackground = self.data.upgrade or false
                }
            }
        )
    end

    if page == "sensor" and is_open then
        local gui = self.cl.gui.interfaces.sensor
        if not gui then return end

        gui:setText("SubTitle", "#{LEVEL} " .. self.data.level)
        gui:setIconImage( "Icon", sm.uuid.new(self.data.uuid) )
        if self.data.upgrade then
            gui:setText("UpgradeCost", upgrade.getUpgradeCost(self))
            gui:setText("UpgradeInfo", self.data.upgrade_info or "")
            gui:setIconImage( "UpgradeIcon", sm.uuid.new(self.data.upgrade_uuid) )
        end
        gui:setVisible("UpgradeBackground", self.data.upgrade)

        gui:open()
    end
end

-----------   GUI Callbacks   ------------

--- Fires when a GUI is closed
--- @param self ShapeClass The sensor class
--- @param gui string The GUI name that was closed
function gui_closed(self, gui)
    fprint({ type = "gui", func = "gui_closed" }, "GUI " .. gui .. " closed")
end

--- Fires when a dropdown selection is made
--- @param self ShapeClass The sensor class
--- @param gui GuiInterface The GUI that the dropdown is on
--- @param dropdown string The dropdown that was changed
--- @param selection string The selection that was made
function dropdown_selected(self, gui, dropdown, selection)
    fprint({ type = "gui", func = "dropdown_selected" }, "Dropdown " .. dropdown .. " changed to: " .. selection)
end

--- Fires when a slider is changed
--- @param self ShapeClass The sensor class
--- @param gui GuiInterface The GUI that the slider is on
--- @param slider string The slider that was changed
--- @param value number The value that was changed
function slider_changed(self, gui, slider, value)
    fprint({ type = "gui", func = "slider_changed" }, "Slider " .. slider .. " changed to: " .. value)

    -- Range Slider for sensor page
    if slider == "RangeSlider" then
        value = value + 1

        if value > self.data.max_distance then
            value = self.data.max_distance
            gui:setSliderPosition(slider, self.data.max_distance-1)
        end

        if value ~= self.cl.saved.distance then
            self.cl.saved.distance = value 
            self.network:sendToServer("server_setDistance", self.cl.saved.distance)
        end
    end
end

--- Fires when a button is pressed
--- @param self ShapeClass The sensor class
--- @param gui GuiInterface The GUI that the button is on
--- @param button string The button that was pressed
function button_pressed(self, gui, button)
    fprint({ type = "gui", func = "button_pressed" }, "Button " .. button .. " pressed")

    if button == "Upgrade" then
        if not upgrade.isPossible(self) then return end
        self.network:sendToServer("server_requestUpgrade")
        return
    end
    fwarn({ type = "gui", func = "button_pressed" }, "Unhandled button: " .. button)
end

--- Fires when an edit text is accepted
--- @param self ShapeClass The sensor class
--- @param gui GuiInterface The GUI that the edit text is on
--- @param edit_text string The edit text that was accepted
--- @param value string The value that was accepted
function edit_text_accepted(self, gui, edit_text, value)
    fprint({ type = "gui", func = "edit_text_accepted" }, "Edit text " .. edit_text .. " accepted: " .. value)
end

--- Fires when an edit text is changed
--- @param self ShapeClass The sensor class
--- @param gui GuiInterface The GUI that the edit text is on
--- @param edit_text string The edit text that was changed
--- @param value string The value that was changed
function edit_text_changed(self, gui, edit_text, value)
    fprint({ type = "gui", func = "edit_text_changed" }, "Edit text " .. edit_text .. " changed: " .. value)
end

----------   Sensor Functions   ----------

function sensor:client_guiRefresh()
    gui.refresh(self, {is_refresh = true, no_load = true})
end

function sensor:client_onInteract(character, state)
    if state then
        fprint({ type = "interaction", func = "client_onInteract" }, "Interacted with sensor")
        gui.refresh(self, { is_open = true, is_refresh = true })
    end
end

--- Lets the client change the distance
--- @param self ShapeClass The sensor class
--- @param range number The range to set the distance to
function sensor:server_setDistance(range, player)
    fprint({ type = "network", func = "server_setDistance" },
        "Received range: " .. tostring(range) .. " from " .. player.name)
    if not range then return end
    if type(range) ~= "number" then return end
    self.sv.saved.distance = sm.util.clamp(range, 1, self.data.max_distance)
    self.storage:save(self.sv.saved)
    fprint({ type = "network" }, "Sent range: " .. tostring(range) .. " to clients")
    self.network:sendToClients("client_receiveClientSettings", self.sv.saved)
end
