local composer = require( "composer" )
 
-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )
 
-- Seed the random number generator
math.randomseed( os.time() )

-- Reserve channel 1 for background music
audio.reserveChannels( 1 )
-- reduce the overall volume of the channel
audio.setVolume( 0.5, { channel = 1 })
-- set the volume for all
audio.setVolume( 0.2 )
 
-- Go to the menu screen
composer.gotoScene( "menu" )