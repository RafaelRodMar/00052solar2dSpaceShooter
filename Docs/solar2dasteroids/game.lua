
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 ) --in space gravity is 0

-- Configure image sheet
local sheetOptions =
{
    frames =
    {
        {   -- 1) asteroid 1
            x = 0,
            y = 0,
            width = 102,
            height = 85
        },
        {   -- 2) asteroid 2
            x = 0,
            y = 85,
            width = 90,
            height = 83
        },
        {   -- 3) asteroid 3
            x = 0,
            y = 168,
            width = 100,
            height = 97
        },
        {   -- 4) ship
            x = 0,
            y = 265,
            width = 98,
            height = 79
        },
        {   -- 5) laser
            x = 98,
            y = 265,
            width = 14,
            height = 40
        },
    },
}

-- load a collection of static images
local objectSheet = graphics.newImageSheet( "gameObjects.png", sheetOptions )

-- Initialize variables
local lives = 3
local score = 0
local died = false
 
local asteroidsTable = {}
 
local ship
local gameLoopTimer
local livesText
local scoreText

local backGroup
local mainGroup
local uiGroup

local explosionSound
local fireSound
local musicTrack

-- function for updating the lives and score in the text variable of the strings.
local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

-- function for creating asteroids
local function createAsteroid()
 
    local newAsteroid = display.newImageRect( mainGroup, objectSheet, 1, 102, 85 )
    table.insert( asteroidsTable, newAsteroid )
    physics.addBody( newAsteroid, "dynamic", { radius=40, bounce=0.8 } )
    newAsteroid.myName = "asteroid"

    -- set where the asteroid appear
    local whereFrom = math.random( 3 )

    if ( whereFrom == 1 ) then
        -- From the left
        newAsteroid.x = -60
        newAsteroid.y = math.random( 500 )
        newAsteroid:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
    elseif ( whereFrom == 2 ) then
        -- From the top
        newAsteroid.x = math.random( display.contentWidth )
        newAsteroid.y = -60
        newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    elseif ( whereFrom == 3 ) then
        -- From the right
        newAsteroid.x = display.contentWidth + 60
        newAsteroid.y = math.random( 500 )
        newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    end

    -- set rotation
    newAsteroid:applyTorque( math.random( -6,6 ) )

end

-- function for creating a laser objects
local function fireLaser()
 
    -- play fire sound
    audio.play( fireSound )

    local newLaser = display.newImageRect( mainGroup, objectSheet, 5, 14, 40 )
    physics.addBody( newLaser, "dynamic", { isSensor=true } )
    newLaser.isBullet = true
    newLaser.myName = "laser"

    newLaser.x = ship.x
    newLaser.y = ship.y
    -- send laser to the back of it's display group.
    newLaser:toBack()

    transition.to( newLaser, { y=-40, time=500, onComplete = function() display.remove( newLaser ) end} )

end

-- Function to handle key events
local function onKeyEvent(event)
    if event.keyName == "space" and event.phase == "down" then
        -- Code to execute when the "space" key is pressed
        fireLaser()
        return true -- Return true to indicate that we handled the event
    end
    
    return false  
end

-- Set initial variables for object movement.
local speed = 5  -- Adjust the speed as needed
local isMovingLeft = false
local isMovingRight = false

-- Function to handle keyboard events
local function onKeyPress(event)
    if event.phase == "down" then
        if event.keyName == "left" then
            isMovingLeft = true
            isMovingRight = false
        elseif event.keyName == "right" then
            isMovingRight = true
            isMovingLeft = false
        end
    elseif event.phase == "up" then
        if event.keyName == "left" then
            isMovingLeft = false
        elseif event.keyName == "right" then
            isMovingRight = false
        end
    end
end

-- Function to update the object's position
local function updateObjectPosition()
    if lives == 0 then return end
    if isMovingLeft then
        ship.x = ship.x - speed
        if ship.x < display.screenOriginX then ship.x = display.screenOriginX end
    elseif isMovingRight then
        ship.x = ship.x + speed
        if ship.x > display.contentWidth then ship.x = display.contentWidth end
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
 
    ship.isBodyActive = false --remove ship from physics simulation.
    ship.x = display.contentCenterX
    ship.y = display.contentHeight - 100
 
    -- Fade in the ship
    transition.to( ship, { alpha=1, time=4000,
        onComplete = function()
            ship.isBodyActive = true
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

        --ship and asteroid
        elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
        ( obj1.myName == "asteroid" and obj2.myName == "ship" ) )
        then
            if ( died == false ) then
                died = true

                -- play explosion sound
                audio.play( explosionSound )

                -- Update lives
                lives = lives - 1
                livesText.text = "Lives: " .. lives

                if ( lives == 0 ) then
                    display.remove( ship )
					timer.performWithDelay( 2000, endGame )
                else
                    ship.alpha = 0
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

	-- Load the background
    local background = display.newImageRect( backGroup, "background.png", 800, 1400 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY

	ship = display.newImageRect( mainGroup, objectSheet, 4, 98, 79 )
    ship.x = display.contentCenterX
    ship.y = display.contentHeight - 100
    physics.addBody( ship, { radius=30, isSensor=true } )
    ship.myName = "ship"
 
    -- Display lives and score
    livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36 )
    scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 )

	-- Add the keyboard event listener
	Runtime:addEventListener("key", onKeyEvent) -- laser
	Runtime:addEventListener("key", onKeyPress) -- move right and left

    explosionSound = audio.loadSound( "audio/explosion.wav" )
    fireSound = audio.loadSound( "audio/fire.wav" )
    musicTrack = audio.loadStream( "audio/80s-Space-Game_Looping.wav" )
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
    audio.dispose( fireSound )
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
