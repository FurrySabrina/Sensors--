indicator = {}

--- Initializes or refreshes the GUI.
--- @param self ShapeClass The sensor class
function indicator.init(self)
    if self.cl.indicator then
        return
    end

    self.cl.indicator = {}
    self.cl.indicator.effect = sm.effect.createEffect(
        "ShapeRenderable",
        self.shape.interactable
    )
    self.cl.indicator.color = sm.color.new("#000000") -- for caching
    local indicator = self.cl.indicator.effect
    indicator:setParameter("uuid", sm.uuid.new("4e795e15-c066-4043-9b83-e2087e345854"))
    indicator:setParameter("color", sm.color.new("#000000"))
    indicator:setScale( sm.vec3.new(0.25, 0.25, 0.25) )
    indicator:start()
end

-- Runs when the shape is destroyed.
function indicator.onDestroy(self)
    if self.cl.indicator then
        self.cl.indicator.effect:destroy()
        self.cl.indicator = nil
    end
end

-- Changes the color of the indicator.
function indicator.setColor(self, color)
    local indicator = self.cl.indicator
    if indicator and indicator.color ~= color then
        indicator.color = color
        indicator.effect:setParameter("color", color)
    end
end
