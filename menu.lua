menu = {}
Im = require("ImageLib/ImageLib")
XP = require("XP/XPLib2")
Windows = require("WindowLib/WindowLib2")

MainMenu = {}

function MainMenu.onCreate(self)
    local files = love.filesystem.getDirectoryItems("")
    y = 16
    for i=1,#files do
        if string.sub(files[i],-4) == ".cre" then
            self.Windows:createObject(self,XPButton,{x=16,y=y,text=files[i],callback=function() self:selectPlayback(files[i]) end})
            y = y + 32
        end
    end
end

function MainMenu.drawFunction(self)
    local width, height = self:size()
    XP:FillRect(0,0,width,height)
end

function MainMenu.size(self)
    return 400,400
end

function MainMenu.selectPlayback(self,file)
    local playback = require("playback")
    playback.filename = string.sub(file,1,-5)
    self.Windows:closeWindow(self.window)
    ChangeState(playback)
end

function menu.init(menu)
    XP:Init()
    local mainmenu = Windows:createWindow(XPWindow,MainMenu)
    mainmenu.x = 200
    mainmenu.y = 100
end

function menu.update(menu)
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
    Windows:draw()
end

return menu