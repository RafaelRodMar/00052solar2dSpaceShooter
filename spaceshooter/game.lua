
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 ) --in space gravity is 0

local pressedKeys = {}

-- Initialize variables
local lives = 3
local score = 0
local died = false
 
local asteroidsTable = {}
local enemiesTable = {}
 
-- images
local playerNormal
local playerDown
local playerUp
local shoot1
local shoot2
local enemy1
local enemy2
local enemy3
local enemy4
local enemy5
local flash
local hit
local asteroid
local asteroidSmall
local explosion

-- sheetOptions for the explosions
local explosionSheetOptions = 
{
    width = 32,
    height = 32,
    numFrames = 6
}

-- sequences table for explosions
local explosionSequences = 
{
    name = "explosion",
    start = 1,
    count = 6,
    time = 800,
    loopCount = 1,
    loopDirection = "forward"
}

-- create a display group for the ship
local player = display.newGroup()

local gameLoopTimer
local livesText
local scoreText

local backGroup
local mainGroup
local uiGroup

-- sounds
local explosionSound
local fireSound1
local fireSound2
local hitSound
local musicTrack

-- function for updating the lives and score in the text variable of the strings.
local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

-- function for creating asteroids
local function createAsteroid()
    if #asteroidsTable > 15 then return end

    local newAsteroid = display.newImage( mainGroup, "assets/img/asteroid.png" )

    table.insert( asteroidsTable, newAsteroid )
    physics.addBody( newAsteroid, "dynamic", { radius=17, bounce=0.8 } )
    newAsteroid.myName = "asteroid"

    -- From the right
    newAsteroid.x = display.contentWidth + 60
    newAsteroid.y = math.random( 480 )
    newAsteroid:setLinearVelocity( math.random(-40,-30), 0 )

    -- set rotation
    --newAsteroid:applyTorque( math.random( -6, 6 ) )
    newAsteroid.angularVelocity = math.random(-50,50)

end

-- function for creating enemies
local function createEnemy()
    if #enemiesTable > 2 then return end

    local newEnemy = display.newImage( mainGroup, "assets/img/enemy1.png")

    table.insert(enemiesTable, newEnemy)
    physics.addBody(newEnemy, "dynamic", { radius=14, bounce = 0.8})
    newEnemy.myName = "enemy"

    -- from the right
    newEnemy.x = display.contentWidth + 60
    newEnemy.y = math.random(480)
    newEnemy:setLinearVelocity(math.random(-50,-40),0)
end

-- function for creating a laser objects
local function fireLaser()
 
    -- play fire sound
    audio.play( fireSound1 )

    local newLaser = display.newImage( mainGroup, "assets/img/shoot1.png" )
    physics.addBody( newLaser, "dynamic", { isSensor=true } )
    newLaser.isBullet = true
    newLaser.myName = "laser"

    newLaser.x = player.x
    newLaser.y = player.y
    -- send laser to the back of it's display group.
    newLaser:toBack()

    transition.to( newLaser, { x = 1000, time=500, onComplete = function() display.remove( newLaser ) end} )

end

-- Function to handle key events
local function onKeyEvent(event)
    if event.phase == "down" then
        pressedKeys[event.keyName] = true
    else
        pressedKeys[event.keyName] = false
    end

    if event.keyName == "space" and event.phase == "down" then
        -- Code to execute when the "space" key is pressed
        fireLaser()
        pressedKeys["space"] = false
        return true -- Return true to indicate that we handled the event
    end
    
    return false  
end

-- Set initial variables for object movement.
local speed = 5  -- Adjust the speed as needed
local isMovingLeft = false
local isMovingRight = false
local isMovingUp = false
local isMovingDown = false

-- function to switch ship image when the up button is pressed
local function switchPlayerUp()
    playerNormal.isVisible = false
    playerUp.isVisible = true
    playerDown.isVisible = false
end

-- function to switch ship image when the down button is pressed
local function switchPlayerDown()
    playerNormal.isVisible = false
    playerUp.isVisible = false
    playerDown.isVisible = true
end

-- function to reset the player image when buttons are released
local function resetPlayerImage()
    playerNormal.isVisible = true
    playerUp.isVisible = false
    playerDown.isVisible = false
end

local function onEnterFrame(event)
    if pressedKeys["space"] then
        -- Code to execute when the "space" key is pressed
        fireLaser()
    end

    resetPlayerImage()
    isMovingUp = false
    isMovingDown = false
    isMovingLeft = false
    isMovingRight = false
    if pressedKeys["up"] then 
        isMovingUp = true 
        switchPlayerUp()
    end
    if pressedKeys["down"] then 
        isMovingDown = true 
        switchPlayerDown()
    end
    if pressedKeys["left"] then isMovingLeft = true end
    if pressedKeys["right"] then isMovingRight = true end
end

-- Function to update the object's position
local function updateObjectPosition()
    if lives == 0 then return end
    if isMovingLeft then
        player.x = player.x - speed
        if player.x < display.screenOriginX then player.x = display.screenOriginX end
    elseif isMovingRight then
        player.x = player.x + speed
        if player.x > display.contentWidth then player.x = display.contentWidth end
	end

    if isMovingUp then
		player.y = player.y - speed
		if player.y < display.screenOriginY then player.y = display.screenOriginY end
	elseif isMovingDown then
		player.y = player.y + speed
		if player.y > display.contentHeight then player.y = display.contentHeight end
    end
end

local function gameLoop()
    -- Create new asteroid
    createAsteroid()

    -- Remove asteroids which have drifted off screen
    for i = #asteroidsTable, 1, -1 do
        local thisAsteroid = asteroidsTable[i]
 
        if ( thisAsteroid.x < -100 or
             thisAsteroid.x > display.contentWidth + 100 or
             thisAsteroid.y < -100 or
             thisAsteroid.y > display.contentHeight + 100 )
        then
            display.remove( thisAsteroid )
            table.remove( asteroidsTable, i )
        end
    end

    -- Create new enemy
    createEnemy()

    -- Remove enemies which have drifted off screen
    for i = #enemiesTable, 1, -1 do
        local thisEnemy = enemiesTable[i]
 
        if ( thisEnemy.x < -100 or
             thisEnemy.x > display.contentWidth + 100 or
             thisEnemy.y < -100 or
             thisEnemy.y > display.contentHeight + 100 )
        then
            display.remove( thisEnemy )
            table.remove( enemiesTable, i )
        end
    end
end

--when the ship is hit it will be restored to the initial position.
--the function make the ship invincible for a period of time.
local function restoreShip()
 
    player.isBodyActive = false --remove ship from physics simulation.
    player.x = display.screenOriginX + 20
    player.y = display.contentHeight / 2
 
    -- Fade in the ship
    transition.to( player, { alpha=1, time=4000,
        onComplete = function()
            player.isBodyActive = true
            died = false
        end
    } )
end

local function endGame()
    composer.setVariable("finalScore", score)
	composer.gotoScene("highscores", {time=800, effect="crossFade"})
end

local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2

        -- asteroids and lasers
        if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
             ( obj1.myName == "asteroid" and obj2.myName == "laser" ) )
        then
            -- Remove both the laser and asteroid
            display.remove( obj1 )
            display.remove( obj2 )

            -- play explosion sound
            audio.play( explosionSound )
            -- show explosion
            local exp = display.newSprite(mainGroup, explosion, explosionSequences)
            exp.x = obj1.x
            exp.y = obj1.y
            exp:play()

            --search the asteroid in the table and remove it.
            for i = #asteroidsTable, 1, -1 do
                if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
                    table.remove( asteroidsTable, i )
                    break
                end
            end

            -- Increase score
            score = score + 100
            scoreText.text = "Score: " .. score

        --player and asteroid
        elseif ( ( obj1.myName == "player" and obj2.myName == "asteroid" ) or
        ( obj1.myName == "asteroid" and obj2.myName == "player" ) )
        then
            if ( died == false ) then
                died = true

                -- play explosion sound
                audio.play( explosionSound )
                -- show explosion
                local exp = display.newSprite(mainGroup, explosion, explosionSequences)
                exp.x = obj1.x
                exp.y = obj1.y
                exp:play()

                -- Update lives
                lives = lives - 1
                livesText.text = "Lives: " .. lives

                if ( lives == 0 ) then
                    display.remove( player )
					timer.performWithDelay( 2000, endGame )
                else
                    player.alpha = 0
                    timer.performWithDelay( 1000, restoreShip )
                end
            end

        --player and enemy
        elseif ( ( obj1.myName == "player" and obj2.myName == "enemy" ) or
        ( obj1.myName == "enemy" and obj2.myName == "player" ) )
        then
            if ( died == false ) then
                died = true

                -- play explosion sound
                audio.play( explosionSound )
                -- show explosion
                local exp = display.newSprite(mainGroup, explosion, explosionSequences)
                exp.x = obj1.x
                exp.y = obj1.y
                exp:play()

                -- Update lives
                lives = lives - 1
                livesText.text = "Lives: " .. lives

                if ( lives == 0 ) then
                    display.remove( player )
					timer.performWithDelay( 2000, endGame )
                else
                    player.alpha = 0
                    timer.performWithDelay( 1000, restoreShip )
                end
            end
        
        -- enemies and lasers
        elseif ( ( obj1.myName == "laser" and obj2.myName == "enemy" ) or
             ( obj1.myName == "enemy" and obj2.myName == "laser" ) )
        then
            -- Remove both the laser and asteroid
            display.remove( obj1 )
            display.remove( obj2 )

            -- play explosion sound
            audio.play( explosionSound )
            -- show explosion
            local exp = display.newSprite(mainGroup, explosion, explosionSequences)
            exp.x = obj1.x
            exp.y = obj1.y
            exp:play()

            --search the asteroid in the table and remove it.
            for i = #enemiesTable, 1, -1 do
                if ( enemiesTable[i] == obj1 or enemiesTable[i] == obj2 ) then
                    table.remove( enemiesTable, i )
                    break
                end
            end

            -- Increase score
            score = score + 100
            scoreText.text = "Score: " .. score
        end
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause() -- temporarily pause the physics engine.

	-- Set up display groups
    backGroup = display.newGroup()  -- Display group for the background image
    sceneGroup:insert( backGroup )  -- Insert into the scene's view group
 
    mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
    sceneGroup:insert( mainGroup )  -- Insert into the scene's view group
 
    uiGroup = display.newGroup()    -- Display group for UI objects like the score
    sceneGroup:insert( uiGroup )    -- Insert into the scene's view group

	--load images
    local background = display.newImage(backGroup, "assets/img/bg-preview-big.png")
	background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- create the animation for the explosion
    explosion = graphics.newImageSheet("assets/img/explosion.png", explosionSheetOptions)

    -- load the three images of the ship
    playerNormal = display.newImage("assets/img/player1.png")
    playerDown = display.newImage("assets/img/player2.png")
    playerUp = display.newImage("assets/img/player3.png")

    -- only the normal player is visible.
    player:insert(playerNormal)
    player:insert(playerUp)
    player:insert(playerDown)
    playerNormal.isVisible = true
    playerUp.isVisible = false
    playerDown.isVisible = false

    physics.addBody( player, { radius= 10, isSensor = true})
    player.x = display.screenOriginX + 20
    player.y = display.contentHeight / 2
    player.myName = "player"

	-- Display lives and score
    livesText = display.newText( uiGroup, "Lives: " .. lives, 100, 50, native.systemFont, 25 )
    scoreText = display.newText( uiGroup, "Score: " .. score, 250, 50, native.systemFont, 25 )

	-- Add the keyboard event listener
	Runtime:addEventListener("key", onKeyEvent) -- laser
	--Runtime:addEventListener("key", onKeyPress) -- move the player
    Runtime:addEventListener("enterFrame", onEnterFrame)

	-- load sounds and music
    explosionSound = audio.loadSound("assets/snd/explosion.wav")
    fireSound1 = audio.loadSound("assets/snd/shot1.wav")
    fireSound2 = audio.loadSound("assets/snd/shot2.wav")
    hitSound = audio.loadSound("assets/snd/hit.wav")
    musicTrack = audio.loadStream("assets/mus/space-asteroids.ogg")
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
        Runtime:addEventListener( "collision", onCollision )
		-- Enter frame listener to continuously update the object's position
		Runtime:addEventListener("enterFrame", updateObjectPosition)
        gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
        -- start the music
        audio.play(musicTrack, { channel = 1, loops = -1})
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel(gameLoopTimer)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener("collision", onCollision)
		Runtime:removeEventListener("enterFrame", updateObjectPosition)
		physics.pause()
        -- stop the music
        audio.stop(1)
		composer.removeScene("game") -- destroy and restart the scene
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

	-- Dispose audio!
    audio.dispose( explosionSound )
    audio.dispose( fireSound1 )
    audio.dispose( musicTrack )
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
