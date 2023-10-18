statemenu = {}

function statemenu:load()
end

function statemenu:keypressed(key)
end

function statemenu:keyreleased(key)
    if key == "space" then
        state = "GAME"
        stategame:reset()
        mus = music:clone()
        mus:play()
    end
end

function statemenu:update()
end

function statemenu:draw()
    fw = font:getWidth("SPACE SHOOTER")
    centerpos = gameWidth / 2 - fw / 2
    love.graphics.print("SPACE SHOOTER", centerpos, 20)
    fw = font:getWidth("PRESS FIRE TO PLAY")
    centerpos = gameWidth / 2 - fw / 2
    love.graphics.print("PRESS FIRE TO PLAY", centerpos, 40)
    fw = font:getWidth("HI SCORE")
    centerpos = gameWidth / 2 - fw / 2
    love.graphics.print("HI SCORE", centerpos, 60)
    row = 80
    for i=1,5 do
        love.graphics.print(hiscores[i],gameWidth / 2,row)
        row = row + 20
    end
end