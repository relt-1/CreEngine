Windows = {}
Windows.objects = {}

function Windows.createObject(Windows,parent,base,override)
    local window = {children = {},parent=parent,x=0,y=0,originx = 0, originy = 0, Windows=Windows}
    if parent == nil then
        Windows.objects[#Windows.objects+1] = window
        window.window = window
    else
        parent.children[#parent.children+1] = window
        local function getHighestParent(child)
            if child.parent == nil then
                return child
            else
                return getHighestParent(child.parent)
            end
        end
        window.window = getHighestParent(window)
    end
    for k,v in pairs(base) do
        window[k] = v
    end
    for k,v in pairs(override) do
        window[k] = v
    end
    if window.onCreate then
        window:onCreate(Windows)
    end
    if window.size then
        local w,h = window:size()
        window.x = math.floor(window.x-window.originx/2*w)
        window.y = math.floor(window.y-window.originy/2*h)
    end
    return window
end

function Windows.createWindow(Windows,frame,content,contentData)
    local contentObj = Windows:createObject(nil,content,contentData or {})
    local frameObj = Windows:createObject(contentObj,frame,
        {
            content = contentObj,
            onCreate = function(self) 
                self.parent.children[#self.parent.children] = nil
                table.insert(self.parent.children,1,self)
                if frame.onCreate then
                    frame.onCreate(self)
                end
            end
        }
    )
    
    return contentObj
end

function Windows.drawObject(Windows,obj)
    if obj.drawFunction ~= nil then
        --local width, height = obj:size()
        obj:drawFunction(Windows)
    end
    for i=1,#obj.children do
        local child = obj.children[i]
        love.graphics.push()
        love.graphics.translate(child.x,child.y)
        Windows:drawObject(child)
        love.graphics.pop()
    end
end

function Windows.draw(Windows)
    for i=1,#Windows.objects do
        local obj = Windows.objects[i]
        love.graphics.push()
        love.graphics.translate(obj.x,obj.y)
        Windows:drawObject(obj)
        love.graphics.pop()
    end
end

function Windows.mouseDownIter(Windows,x,y,tx,ty,children)
    for i=#children,1,-1 do
        local obj = children[i]
        if obj.size then
            local w,h = obj:size()
            if Im:InsideBox(x,y,obj.x+tx,obj.y+ty,w,h) then
                if Windows:mouseDownIter(x,y,tx + obj.x,ty + obj.y,obj.children) then
                    return true
                else
                    if obj.mouseDown then
                        obj:mouseDown(x-tx-obj.x,y-ty-obj.y)
                        Windows.pressedObj = obj
                    end
                end
                return true
            else
                if Windows:mouseDownIter(x,y,tx + obj.x,ty + obj.y,obj.children) then
                    return true
                end
            end
        else
            if Windows:mouseDownIter(x,y,tx + obj.x,ty + obj.y,obj.children) then
                return true
            end
        end
    end
    return false
end

function Windows.mouseDown(Windows,x,y)
    Windows:mouseDownIter(x,y,0,0,Windows.objects)
end

function Windows.mouseHover(Windows,x,y,tx,ty,children)
    for i=#children,1,-1 do
        local obj = children[i]
        if obj.size then
            local w,h = obj:size()
            if Im:InsideBox(x,y,obj.x+tx,obj.y+ty,w,h) then
                local hoveredObj = Windows:mouseHover(x,y,tx + obj.x,ty + obj.y,obj.children)
                if hoveredObj then
                    return hoveredObj
                else
                    if obj.mouseHover then
                        obj:mouseHover(x-tx-obj.x,y-ty-obj.y)
                    end
                    return obj
                end
            else
                local hoveredObj = Windows:mouseHover(x,y,tx + obj.x,ty + obj.y,obj.children)
                if hoveredObj then
                    return hoveredObj
                end
            end
        else
            local hoveredObj = Windows:mouseHover(x,y,tx + obj.x,ty + obj.y,obj.children)
            if hoveredObj then
                return hoveredObj
            end
        end
    end
    return false
end


function Windows.GetTransform(Windows,obj)
    if obj.parent then
        local px,py = Windows:GetTransform(obj.parent)
        return px+obj.x,py+obj.y
    end
    return obj.x,obj.y
end

function Windows.mouseMove(Windows,x,y)
    if Windows.pressedObj then
        if Windows.pressedObj.mouseMove then
            Windows.pressedObj:mouseMove(x,y)
        end
    elseif Windows.hoveredObj then
        local newHovered = Windows:mouseHover(x,y,0,0,Windows.objects)
        if newHovered ~= Windows.hoveredObj then
            if Windows.hoveredObj.mouseUnhover then
                Windows.hoveredObj:mouseUnhover()
            end
            Windows.hoveredObj = newHovered
        end
    else
        Windows.hoveredObj = Windows:mouseHover(x,y,0,0,Windows.objects)
    end
end

function Windows.mouseUp(Windows,x,y)
    if Windows.pressedObj and Windows.pressedObj.mouseUp then
        Windows.pressedObj:mouseUp(x,y)
    end
    Windows.pressedObj = nil
end

function Windows.updateIter(Windows,children)
    for i = 1,#children do
        local child = children[i]
        if child.update then
            child:update(Windows)
        end
        Windows:updateIter(child.children)
    end
end

function Windows.update(Windows)
    Windows:updateIter(Windows.objects)
end

function Windows.closeWindow(Windows,toClose)
    for i=1,#Windows.objects do
        if Windows.objects[i] == toClose then
            table.remove(Windows.objects,i)
            return
        end
    end
end

return Windows