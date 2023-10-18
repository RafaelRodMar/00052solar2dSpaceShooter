objectplayer = {}

objectplayer_mt = { __index = objectplayer }

function objectplayer:new(name, tex, x, y, w, h, u, v, nFrames, ang, rad)
    local entity = {}
    setmetatable(entity, objectplayer_mt)
    
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
    entity.isDying = false

    return entity
end

function objectplayer:update(dt)
    if self.isDying then return end
    self.frames[1] = player

    if love.keyboard.isDown( 'left' ) and (self.posx - 300 * dt) >= 0 then
        self.posx = self.posx - 300 * dt
    end
    if love.keyboard.isDown( 'right' ) and (self.posx + 300 * dt) <= (gameWidth - self.width) then
        self.posx = self.posx + 300 * dt
    end
    if love.keyboard.isDown( 'up' ) and (self.posy - 300 * dt) >= 0 then
        self.posy = self.posy - 300 * dt
        self.frames[1] = playerUp
    end
    if love.keyboard.isDown( 'down' ) and (self.posy + 300 * dt) <= (gameHeight - self.height) then
        self.posy = self.posy + 300 * dt
        self.frames[1] = playerDown
    end
end

function objectplayer:draw()
    if not self.isDying then
        love.graphics.draw(self.texture,self.posx,self.posy)
    end
end