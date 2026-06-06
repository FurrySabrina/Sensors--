indicator = {}

--- Initializes or refreshes the GUI.
--- @param self ShapeClass The sensor class
function indicator.init(self)

    if self.cl.indicator then
        self.cl.indicator.effect:destroy()
    end

    self.cl.indicator = {}
    self.cl.indicator.effect = sm.effect.createEffect(
        "ShapeRenderable",
        self.shape.interactable
    )
    self.cl.indicator.effect:setParameter("uuid", sm.uuid.new("4e795e15-c066-4043-9b83-e2087e345854"))
    self.cl.indicator.effect:setParameter("color", sm.color.new("#000000"))
    self.cl.indicator.effect:setScale( sm.vec3.new(0.25, 0.25, 0.25) )
    self.cl.indicator.effect:start()

    local indicator = self.cl.indicator.effect

    print(indicator)
end

-- Runs when the shape is destroyed.
function indicator.onDestroy(self)
    if self.cl.indicator then
        self.cl.indicator.effect:destroy()
        self.cl.indicator = nil
    end
end
