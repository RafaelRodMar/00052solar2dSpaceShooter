objectexplosion = {}

objectexplosion_mt = { __index = objectexplosion }

function objectexplosion:new(name, tex, x, y, w, h, u, v, nFrames, ang, rad)
    local entity = {}
    setmetatable(entity, objectexplosion_mt)
    
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

    for i=0, entity.numFrames do
        table.insert(entity.frames, love.graphics.newQuad(u,v,w,h,tex:getWidth(), tex:getHeight()))
        u = u + entity.width
    end

    return entity
end

function objectexplosion:update(dt)
    self.currentFrame = self.currentFrame + dt * 15 --number is speed
    if self.currentFrame >= self.numFrames then
        if self.alpha > 10 then
            self.destroy = true
        else
            self.alpha = self.alpha + 1
        end
    end
end

function objectexplosion:draw()
    local cFrame = math.floor(self.currentFrame / self.numFrames * #self.frames)
    if cFrame < 1 then 
        cFrame = 1
    elseif cFrame > self.numFrames then
        cFrame = self.numFrames
    end
    love.graphics.draw(self.texture, self.frames[cFrame],self.posx,self.posy, math.rad(self.angle), 1, 1, 20, 20, 0, 0)
end