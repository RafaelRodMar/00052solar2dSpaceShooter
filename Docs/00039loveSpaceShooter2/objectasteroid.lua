objectasteroid = {}

objectasteroid_mt = { __index = objectasteroid }

function objectasteroid:new(name, tex, x, y, w, h, u, v, nFrames, ang, rad)
    local entity = {}
    setmetatable(entity, objectasteroid_mt)
    
    entity.name = name
    entity.texture = tex
    entity.posx = x
    entity.posy = y
    entity.width = w
    entity.height = h
    entity.velx = 0
    entity.vely = 0
    entity.angle = ang
    entity.radius = rad
    entity.alpha = 0
    entity.frames = {}
    entity.currentRow = 0
    entity.currentFrame = 1
    entity.numFrames = nFrames
    entity.thrust = 0
    entity.destroy = false
    entity.health = 0

    if w == 35 then
        entity.velx = love.math.random(20,85)
        entity.health = 2
    else
        entity.velx = love.math.random(85,150)
        entity.health = 1
    end

    return entity
end

function objectasteroid:update(dt)
    self.posx = self.posx - self.velx * dt
    
    if self.posx < 0 then
        self.destroy = true
    end

end

function objectasteroid:draw()
    love.graphics.draw(self.texture, self.posx,self.posy)
end
