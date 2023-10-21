
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
 
-- images
local player
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
 
    local newAsteroid = display.newImage( mainGroup, "assets/img/asteroid.png" )
    table.insert( asteroidsTable, newAsteroid )
    physics.addBody( newAsteroid, "dynamic", { radius=17, bounce=0.8 } )
    newAsteroid.myName = "asteroid"

    -- From the right
    newAsteroid.x = display.contentWidth + 60
    newAsteroid.y = math.random( 480 )
    newAsteroid:setLinearVelocity( -40,0 )

    -- set rotation
    --newAsteroid:applyTorque( math.random( -6, 6 ) )
    newAsteroid.angularVelocity = math.random(-50,50)

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

-- Function to handle keyboard events
-- local function onKeyPress(event)
--     if event.phase == "down" then
--         if event.keyName == "left" then
--             isMovingLeft = true
--             isMovingRight = false
--         elseif event.keyName == "right" then
--             isMovingRight = true
--             isMovingLeft = false
--         end

-- 		if event.keyName == "up" then
-- 			isMovingUp = true
-- 			isMovingDown = false
-- 		elseif event.keyName == "down" then
-- 			isMovingDown = true
-- 			isMovingUp = false
-- 		end
--     elseif event.phase == "up" then
--         if event.keyName == "left" then
--             isMovingLeft = false
--         elseif event.keyName == "right" then
--             isMovingRight = false
-- 		elseif event.keyName == "up" then
-- 			isMovingUp = false
-- 		elseif event.keyName == "down" then
-- 			isMovingDown = false
--         end
--     end
-- end

local function onEnterFrame(event)
    if pressedKeys["space"] then
        -- Code to execute when the "space" key is pressed
        fireLaser()
    end

    isMovingUp = false
    isMovingDown = false
    isMovingLeft = false
    isMovingRight = false
    if pressedKeys["up"] then isMovingUp = true end
    if pressedKeys["down"] then isMovingDown = true end
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

    --asteroid = display.newImage("assets/img/asteroid.png")
    --asteroidSmall = display.newImage("assets/img/asteroid-small.png")
    --explosion = display.newImage("assets/img/explosion.png")
    player = display.newImage("assets/img/player1.png")
	player.x = display.screenOriginX + 20
    player.y = display.contentHeight / 2

    physics.addBody( player, { radius=10, isSensor=true } )
    player.myName = "player"

    --playerDown = display.newImage("assets/img/player2.png")
    -- playerUp = display.newImage("assets/img/player3.png")
    -- shoot1 = display.newImage("assets/img/shoot1.png")
    -- shoot2 = display.newImage("assets/img/shoot2.png")
    -- enemy1 = display.newImage("assets/img/enemy1.png")
    -- enemy2 = display.newImage("assets/img/enemy2.png")
    -- enemy3 = display.newImage("assets/img/enemy3.png")
    -- enemy4 = display.newImage("assets/img/enemy4.png")
    -- enemy5 = display.newImage("assets/img/enemy5.png")
    -- flash = display.newImage("assets/img/flash.png")
    -- hit = display.newImage("assets/img/hit.png")

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
