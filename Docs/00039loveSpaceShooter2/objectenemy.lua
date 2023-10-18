objectenemy = {}

objectenemy_mt = { __index = objectenemy }

function objectenemy:new(name, tex, x, y, w, h, u, v, nFrames, ang, rad)
    local entity = {}
    setmetatable(entity, objectenemy_mt)
    
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
    entity.numShoots = 1
    entity.shootPos = math.random(50,75)

    entity.velx = love.math.random(85,150)
    entity.vely = entity.velx

    return entity
end

function objectenemy:update(dt)
    self.posx = self.posx - self.velx * dt

    for i,w in ipairs(entities) do
        if w.name == "asteroid" and isCollide(self,w) then
            local goup = self.posy
            local godown = gameHeight - self.posy
            if goup >= godown then
                self.posy = self.posy - self.vely * dt
            else
                self.posy = self.posy + self.vely * dt
            end
        end
    end
    
    if self.posx < 0 then
        self.destroy = true
    end

    if self.numShoots > 0 and self.posx < gameWidth * self.shootPos / 100 then
        self.numShoots = self.numShoots - 1
        local bullet = objectenemybullet:new("enemybullet", shoot2, self.posx, self.posy + 6,
        19, 6, 0, 0, 2, 0, 16)
        table.insert(entities, bullet)
        cl2 = laser2:clone()
        cl2:play()
    end

end

function objectenemy:draw()
    love.graphics.draw(self.texture, self.posx,self.posy)
end
