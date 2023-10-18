require("objectplayer")
require("objectasteroid")
require("objectbullet")
require("objectenemybullet")
require("objectexplosion")
require("objectenemy")

stategame = {}

function stategame:load()
end

function stategame:reset()
    lives = 3
    score = 0

    entities = {}

    --create the player
    local player = objectplayer:new("player", player, 20,  gameHeight / 2, 26, 21,
    0, 0, 1, 0, 20)
    table.insert(entities, player)
end

function stategame:keypressed(key)
    if key == 'space' and not entities[1].isDying then
        local bullet = objectbullet:new("bullet", shoot1, entities[1].posx, entities[1].posy,
        19, 6, 0, 0, 2, 0, 16)
        table.insert(entities, bullet)
        cl = laser1:clone()
        cl:play()
    end
end

function stategame:keyreleased(key)
end

function isCollide(a,b)
    if a.posx < b.posx + b.width and
        a.posx + a.width > b.posx and
        a.posy < b.posy + b.height and
        a.posy + a.height > b.posy then
            return true
        end

    return false
end

function isCollideRadius(a,b)
	return (b.posx - a.posx)*(b.posx - a.posx) +
		(b.posy - a.posy)*(b.posy - a.posy) <
		(a.radius + b.radius)*(a.radius + b.radius)
end

function stategame:update(dt)
    --create the asteroids
    if love.math.random(0,100) <= 1 and actualAsteroids < maxAsteroids then
        local ast
        if love.math.random(0,100) < 25 then
            ast = objectasteroid:new("asteroid", asteroidSmall, gameWidth + 1, love.math.random(0,gameHeight - 13), 14, 13,
        0,0,1, 0, 10)
        else
            ast = objectasteroid:new("asteroid", asteroid, gameWidth + 1, love.math.random(0,gameHeight - 37), 35, 37,
        0,0,1, 0, 25)
        end
        actualAsteroids = actualAsteroids + 1
        table.insert(entities, ast)
    end

    --create the enemy ships
    --if love.math.random(0,100) <= 1 and actualEnemies < maxEnemies then
    if love.math.random(0,100) <= 1 and actualEnemies < maxEnemies then
        local e = objectenemy:new("enemy", enemy1, gameWidth + 20, love.math.random(0,gameHeight - 29), 
        29, 29, 0,0, 1, 0, 0)
        actualEnemies = actualEnemies + 1
        table.insert(entities, e)
    end

    for i,v in ipairs(entities) do
        v:update(dt)
    end

    for i,v in ipairs(entities) do
        for j,w in ipairs(entities) do
            if v.name == "bullet" and v.destroy == false and w.name == "asteroid" and w.destroy == false then
                if(isCollide(v,w)) then
                    if w.health == 2 then
                        w.health = 1
                        local h = hitSound:clone()
                        h:play()
                        v.destroy = true

                        local hitexp = objectexplosion:new("explosion", hit, w.posx + 15, w.posy + 15,
                        16, 16, 0,0, 5, 0,0)
                        table.insert(entities, hitexp)
                    else
                        local e = explosionsound:clone()
                        e:play()

                        --mark them for being destroyed later
                        v.destroy = true
                        w.destroy = true

                        local exp = objectexplosion:new("explosion", explosion, w.posx + 10, w.posy + 10,
                        32, 32, 0,0, 6, 0,0)
                        table.insert(entities, exp)
                        
                        score = score + 10
                    end
                    break
                end
            end

            if v.name == "bullet" and v.destroy == false and w.name == "enemy" and w.destroy == false then
                if(isCollide(v,w)) then
                    local e = explosionsound:clone()
                    e:play()

                    --mark them for being destroyed later
                    v.destroy = true
                    w.destroy = true

                    local exp = objectexplosion:new("explosion", explosion, w.posx + 10, w.posy + 10,
                    32, 32, 0,0, 6, 0,0)
                    table.insert(entities, exp)
                    
                    score = score + 10
                    break
                end
            end

            if v.name == "player" and (w.name == "asteroid" or w.name == "enemy") and w.destroy == false then
                if(isCollide(v,w)) then
                    w.destroy = true

                    local shipexp = objectexplosion:new("shipexplosion", explosion, w.posx + 10, w.posy + 10,
                    32,32,0,0,6,0,0)
                    table.insert(entities, shipexp)

                    shipexp = explosionsound:clone()
                    shipexp:play()
                    entities[1].isDying = true
                    lives = lives - 1
                    if lives <= 0 then
                        entities[1].isDying = false
                        table.insert(hiscores, score)
                        writeHiScores()
                        state = "GAMEOVER"
                        love.audio.stop(mus)
                    end

                    entities[1].posx = 20
                    entities[1].posy = love.math.random(0,gameHeight)
                end
            end

            if v.name == "player" and w.name == "enemybullet" then
                if(isCollide(v,w)) then
                    w.destroy = true

                    local shipexp = objectexplosion:new("shipexplosion", explosion, w.posx + 10, w.posy + 10,
                    32,32,0,0,6,0,0)
                    table.insert(entities, shipexp)

                    shipexp = explosionsound:clone()
                    shipexp:play()
                    entities[1].isDying = true
                    lives = lives - 1
                    if lives <= 0 then
                        entities[1].isDying = false
                        table.insert(hiscores, score)
                        writeHiScores()
                        state = "GAMEOVER"
                        love.audio.stop(mus)
                    end

                    entities[1].posx = 20
                    entities[1].posy = love.math.random(0,gameHeight)
                end
            end
        end
    end

    --destroy marked elements
    for i=#entities, 1, -1 do
        if entities[i].destroy == true then
            if entities[i].name == "shipexplosion" then
                entities[1].isDying = false
            end
            if entities[i].name == "asteroid" then
                actualAsteroids = actualAsteroids - 1
            end
            if entities[i].name == "enemy" then
                actualEnemies = actualEnemies - 1
            end
            table.remove(entities,i)
        end
    end
end

function stategame:draw()
    love.graphics.setColor(1,1,1)
    for i,v in ipairs(entities) do
        v:draw()
    end

    --draw UI
    love.graphics.setColor(1,0,0)
    love.graphics.print("LIVES: " .. lives .. "   SCORE: " .. score, 5, 10)
end