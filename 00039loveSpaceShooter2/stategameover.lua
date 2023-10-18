stategameover = {}

function stategameover:load()
end

function stategameover:keypressed(key)
end

function stategameover:keyreleased(key)
    if key == 'space' then
        state = "MENU"
        return
    end
end

function stategameover:update()
end

function stategameover:draw()
    fw = font:getWidth("GAME OVER")
    centerpos = gameWidth / 2 - fw / 2
    love.graphics.print("GAME OVER", centerpos, gameHeight / 2 - 20)
    fw = font:getWidth("PRESS FIRE TO MENU")
    centerpos = gameWidth / 2 - fw / 2
    love.graphics.print("PRESS FIRE TO MENU", centerpos, gameHeight / 2 + 20)
end