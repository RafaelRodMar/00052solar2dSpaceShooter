require("statemenu")
require("stategame")
require("stategameover")

function love.load()
    --variables
    state = "MENU"
    gameWidth = 816
    gameHeight = 480
    lives = 0
    score = 0
    saveFile = "hiscores.txt"
    hiscores = {}

    entities = {} --collection of entities

    love.window.setMode(gameWidth, gameHeight, {resizable=false, vsync=false})
    love.graphics.setBackgroundColor(1,1,1) --white
    --load font
    font = love.graphics.newFont("assets/fnt/hour5.ttf",25)
    love.graphics.setFont(font)
    --load images
    background = love.graphics.newImage("assets/img/bg-preview-big.png")
    asteroid = love.graphics.newImage("assets/img/asteroid.png")
    asteroidSmall = love.graphics.newImage("assets/img/asteroid-small.png")
    explosion = love.graphics.newImage("assets/img/explosion.png")
    player = love.graphics.newImage("assets/img/player1.png")
    playerDown = love.graphics.newImage("assets/img/player2.png")
    playerUp = love.graphics.newImage("assets/img/player3.png")
    shoot1 = love.graphics.newImage("assets/img/shoot1.png")
    shoot2 = love.graphics.newImage("assets/img/shoot2.png")
    enemy1 = love.graphics.newImage("assets/img/enemy1.png")
    enemy2 = love.graphics.newImage("assets/img/enemy2.png")
    enemy3 = love.graphics.newImage("assets/img/enemy3.png")
    enemy4 = love.graphics.newImage("assets/img/enemy4.png")
    enemy5 = love.graphics.newImage("assets/img/enemy5.png")
    flash = love.graphics.newImage("assets/img/flash.png")
    hit = love.graphics.newImage("assets/img/hit.png")
    --load sounds
    explosionsound = love.audio.newSource("assets/snd/explosion.wav","static")
    laser1 = love.audio.newSource("assets/snd/shot1.wav","static")
    laser2 = love.audio.newSource("assets/snd/shot2.wav","static")
    hitSound = love.audio.newSource("assets/snd/hit.wav","static")
    music = love.audio.newSource("assets/mus/space-asteroids.ogg","stream")
    laser1:setVolume(0.2)
    laser2:setVolume(0.2)
    hitSound:setVolume(0.2)
    explosionsound:setVolume(0.5)
    music:setVolume(0.2)
    music:setLooping(true)

    info = love.filesystem.getInfo( saveFile, nil )
    if info == nil then
        --create file
        for i=5,1,-1 do
            data = string.format("%05d", i)
            success, errormsg = love.filesystem.append( saveFile, data, 5 )
            hiscores[i] = i
        end
    else
        --read file
        contents, size = love.filesystem.read( saveFile, info.size )
        hiscores[1] = tonumber(string.sub(contents,0,5))
        hiscores[2] = tonumber(string.sub(contents,6,10))
        hiscores[3] = tonumber(string.sub(contents,11,15))
        hiscores[4] = tonumber(string.sub(contents,16,20))
        hiscores[5] = tonumber(string.sub(contents,21,25))
    end
    
    maxAsteroids = 6
    maxEnemies = 1
    actualAsteroids = 0
    actualEnemies = 0
end

function writeHiScores()
    
    table.sort(hiscores, function(a,b) return a > b end)

    --remove file
    love.filesystem.remove( saveFile )
    --write the 5 first elements
    for i=1,5 do
        data = string.format("%05d", hiscores[i])
        success, errormsg = love.filesystem.append( saveFile, data, 5 )
    end
end

function love.keypressed(key)
    if state == "MENU" then statemenu:keypressed(key) end
    if state == "GAME" then stategame:keypressed(key) end
    if state == "GAMEOVER" then stategameover:keypressed(key) end
end

function love.keyreleased(key)
    if state == "MENU" then statemenu:keyreleased(key) end
    if state == "GAME" then stategame:keyreleased(key) end
    if state == "GAMEOVER" then stategameover:keyreleased(key) end
end

function love.update(dt)
    if state == "MENU" then statemenu:update(dt) end
    if state == "GAME" then stategame:update(dt) end
    if state == "GAMEOVER" then stategameover:update(dt) end
end

function love.draw()
    love.graphics.setBackgroundColor(1,1,1)
    love.graphics.setColor(1,1,1)
    love.graphics.draw(background, 0, 0)

    --the states system
    if state == "MENU" then statemenu:draw() end
    if state == "GAME" then stategame.draw() end
    if state == "GAMEOVER" then stategameover:draw() end
end
