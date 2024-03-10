local currentstate = nil

local MainInterface = {}

function love.load()
    ChangeState(require("menu"))
end

function love.update()
    currentstate:update()
end

function love.draw()
    currentstate:draw()
end

function ChangeState(state)
    currentstate = state
    currentstate:init()
end

function love.mousepressed(x,y,button)
    if button == 1 then
        currentstate:mouseDown(x,y)
    end
end


function love.mousemoved(x,y)
    currentstate:mouseMove(x,y)
end

function love.mousereleased(x,y,button)
    if button == 1 then
        currentstate:mouseUp(x,y)
    end
end

