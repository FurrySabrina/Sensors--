indicator = {}

indicator.colors = {
    off = sm.color.new("#000000"),
    default_on = sm.color.new("#00FF3C"),
}

--- Initializes or refreshes the GUI.
--- @param self ShapeClass The sensor class
function indicator.init(self)
    fprint({ type = "init", func = "indicator.init" }, "Initializing indicator")
    if self.cl.indicator then
        -- trying to init the indicator again after it's already been initalized
        return
    end

    self.cl.indicator = {
        enabled = true,
        effect = nil,
        color = indicator.colors.off -- for caching
    }
    local effect = sm.effect.createEffect(
        "ShapeRenderable",
        self.shape.interactable
    )
    effect:setParameter("uuid", sm.uuid.new("4e795e15-c066-4043-9b83-e2087e345854"))
    effect:setParameter("color", indicator.colors.off)
    effect:setScale(sm.vec3.new(0.25, 0.25, 0.25))
    effect:start()

    self.cl.indicator.effect = effect
end

-- Changes the color of the indicator.
function indicator.setColor(self, color)
    local indicator = self.cl.indicator
    if indicator and indicator.color ~= color then
        fprint({ func = "indicator.setColor" }, string.format("Changing indicator color to: %d %d %d",
            math.floor(color.r * 255), math.floor(color.g * 255), math.floor(color.b * 255)))
        indicator.color = color
        indicator.effect:setParameter("color", color)
    end
end

--- Allows the server to set client side colors.
--- @param self ShapeClass The sensor class
--- @param color Color The color to set
function sensor:client_setIndicatorColor(color)
    fprint({ type = "network", func = "client_setIndicatorColor" }, "Received indicator color: " .. color)
    indicator.setColor(self, color)
end
