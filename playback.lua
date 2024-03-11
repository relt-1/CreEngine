playback = {}

CrazyLib = require("CrazyLib/CrazyLib")

function playback.init(self)
    self.timer = 0
    love.audio.play(love.audio.newSource(self.filename..".mp3","stream"))
    CrazyLib:load(self.filename..".cre")
end
function playback.executeCommand(self,err)
    local cmd = err.command
    if string.startswith(cmd,"clear") then
        local splitted = string.split(cmd,",")
        if #splitted == 2 then
            local i = 1
            while i < #Windows.objects do
                if Windows.objects[i].id == splitted[2] then
                    table.remove(Windows.objects,i)
                else
                    i = i + 1
                end
            end
        else
            Windows.objects = {}
        end
    end
end


function playback.update(self)
    if #CrazyLib.events == 0 then
        Windows.objects = {}
        ChangeState(require("menu"))
        love.audio.stop()
        return
    end
    local errors = CrazyLib:tick(self.timer)
    for i=1,#errors do
        if errors[i].command ~= nil then
            self:executeCommand(errors[i])
        else
            local err = errors[i].error
            local msg = Windows:createWindow(XPWindow,XP:CreateMessageBox(err[2],err[3],Im:Image(err[4]),err[5]),{
                x = errors[i].pos[1],
                y = errors[i].pos[2],
                originx = errors[i].pos[3] or 0,
                originy = errors[i].pos[4] or 0
            })
            msg.id = errors[i].id
        end
    end
    self.timer = self.timer + love.timer.getDelta()
    Windows:update()
end

function playback.mouseDown(self,x,y)
    Windows:mouseDown(x,y)
end

function playback.mouseMove(self,x,y)
    Windows:mouseMove(x,y)
end

function playback.mouseUp(self,x,y)
    Windows:mouseUp(x,y)
end

function playback.draw(self)
    Windows:draw()
end

return playback