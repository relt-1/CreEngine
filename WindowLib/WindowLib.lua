Windows = {}
Windows.objects = {}
Windows.canvases = {}

log2 = function (x)
    return math.log(x) / math.log(2)
end

function Windows.createCanvas(Windows,width,height)
    width = math.pow(2,math.ceil(log2(width)))
    height = math.pow(2,math.ceil(log2(height)))
    local res = tostring(width).."x"..tostring(height)
    local index = nil
    local canvases = Windows.canvases
    if canvases[res] ~= nil then
        index = nil
        for i=1,#canvases[res] do
            if not canvases[res][i].inUse then
                index = i
                break
            end
        end
    else
        canvases[res] = {}
    end
    if index == nil then
        canvases[res][#canvases[res] + 1] = {
            theCanvas = love.graphics.newCanvas(width,height),
            inUse = true
        }
        index = #canvases[res]
    end
    return {
        res = res,
        index = index,
        c = canvases[res][#canvases[res]].theCanvas
    }
end

function Windows.freeCanvas(Windows,canvas)
    Windows.canvases[canvas.res][canvas.index].inUse = false
end

function Windows.createObject(Windows,parent)
    local window = {children = {},parent=parent}
    Windows:initializeObject(window)
    if parent == nil then
        Windows.objects[#Windows.objects+1] = window
    else
        parent.children[#parent.children+1] = window
        window.width = math.min(parent.width-parent.x,width)
        window.height = math.min(parent.height-parent.y,height)
    end
    return window
end

function Windows.initializeObject(Windows,window)
    window.x = 0
    window.y = 0
    window.width = 1
    window.height = 1
end

function Windows.attachDrawFunction(Windows,obj,drawFunction)
    obj.draw = drawFunction
    return obj
end

function Windows.drawObject(Windows,obj)
    local canvas = Windows:createCanvas(obj.width,obj.height)
    if obj.drawFunction ~= nil then
        love.graphics.setCanvas(canvas.c)
        obj:draw(canvas.c)
    end
    for i=1,#obj.children do
        local child = obj.children[i]
        local childCanvas = Windows:drawObject(child)
        love.graphics.setCanvas(canvas.c)
        love.graphics.draw(childCanvas.c,child.x,child.y)
        Windows:freeCanvas(childCanvas)
    end
    
    return canvas
end

function Windows.draw(Windows)
    for i=1,#Windows.objects do
        local objCanvas = Windows:drawObject(Windows.objects[i])
        love.graphics.setCanvas()
        love.graphics.draw(objCanvas.c,Windows.objects[i].x,Windows.objects[i].y)
        Windows:freeCanvas(objCanvas)
    end
end

function Windows.createWindow(Windows,frame,content)
    
end

return Windows
