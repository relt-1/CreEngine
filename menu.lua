menu = {}
Im = require("ImageLib/ImageLib")
XP = require("XP/XPLib2")
Windows = require("WindowLib/WindowLib2")
CrazyLib = require("CrazyLib/CrazyLib")

function menu.init(menu)
    XP:Init()
    menu.timer = 0
    --[[
    local messagebox = Windows:createWindow(XPWindow,XP:CreateMessageBox("Test","55555555555555555555555555555555555555553534525456254654656536",XP:GetIcon(1),{"OK"}))
    messagebox.x = 200
    messagebox.y = 150
    messagebox = Windows:createWindow(XPWindow,XP:CreateMessageBox("Test","55555555555555555555555555555555555555553534525456254654656536",XP:GetIcon(1),{"OK"}))
    messagebox.x = 220
    messagebox.y = 180
    ]]
    love.audio.play(love.audio.newSource("freeman.mp3","stream"))
    CrazyLib:load("freeman.cre")
end

function menu.update(menu)
    
    local errors = CrazyLib:tick(menu.timer)
    for i=1,#errors do
        local err = errors[i].error
        local msg = Windows:createWindow(XPWindow,XP:CreateMessageBox(err[2],err[3],Im:Image(err[4]),err[5]))
        msg.x = errors[i].pos[1]
        msg.y = errors[i].pos[2]
    end
    menu.timer = menu.timer + love.timer.getDelta()
    Windows:update()
end

function menu.mouseDown(menu,x,y)
    Windows:mouseDown(x,y)
end

function menu.mouseMove(menu,x,y)
    Windows:mouseMove(x,y)
end

function menu.mouseUp(meny,x,y)
    Windows:mouseUp(x,y)
end

function menu.draw(menu)
    w,h = love.graphics.getDimensions()
    Windows:draw()
    
    --XP:FillRect(100,100,w-200,h-200)
    --XP:DrawFrame(100,100,w-200,h-200)
    --XP:DrawButton("Play",w/2,h/2,1,1)
    --XP:DrawMessageBox("Test","L",XP:GetIcon(1),{"OK"},200,150)
end

return menu