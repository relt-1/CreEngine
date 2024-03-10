XP = {}
Im = require("../ImageLib/ImageLib")
dofile("util.lua")


function XP.Init(XP)
    XP.textfont = love.graphics.newImageFont("XP/Assets/text.png"," !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")
end


XPWindow = {x = -3, y= -29}
function XPWindow.drawFunction(self)
    local inactive = true
    if self.Windows.objects[#self.Windows.objects] == self.content then
        inactive = false
    end

    local w, h = self.content:size()
    local topleftframe = Im:Image("XP/Assets/XPFrameTopLeft"..(inactive and "Inactive" or "")..".png")
	local topmiddleframe = Im:Image("XP/Assets/XPFrameTopMiddle"..(inactive and "Inactive" or "")..".png")
	local toprightframe = Im:Image("XP/Assets/XPFrameTopRight"..(inactive and "Inactive" or "")..".png")
	local leftframe = Im:Image("XP/Assets/XPFrameLeft"..(inactive and "Inactive" or "")..".png")
	local rightframe = Im:Image("XP/Assets/XPFrameRight"..(inactive and "Inactive" or "")..".png")
	local bottomleftframe = Im:Image("XP/Assets/XPFrameBottomLeft"..(inactive and "Inactive" or "")..".png")
	local bottommiddleframe = Im:Image("XP/Assets/XPFrameBottomMiddle"..(inactive and "Inactive" or "")..".png")
	local bottomrightframe = Im:Image("XP/Assets/XPFrameBottomRight"..(inactive and "Inactive" or "")..".png")
    local fw = w+Im:W(leftframe)+Im:W(rightframe)
	local fh = h+Im:H(topmiddleframe)+Im:H(bottommiddleframe)
	love.graphics.setColor(1,1,1,1)
	Im:jput(topleftframe,0,0)
	Im:rput(topmiddleframe,0+Im:W(topleftframe),0,fw-Im:W(topleftframe)-Im:W(toprightframe))
	Im:fput(toprightframe,fw,0,2)
	Im:rput(leftframe,0,Im:H(topleftframe),nil,h)
	Im:put(rightframe,fw,Im:H(toprightframe),nil,h,2)
	Im:jput(bottomleftframe,0,h+Im:H(topmiddleframe))
	Im:rput(bottommiddleframe,Im:W(bottomleftframe),h+Im:H(topmiddleframe),fw-Im:W(bottomleftframe)-Im:W(bottomrightframe))
	Im:fput(bottomrightframe,fw,h+Im:H(topmiddleframe),2)
end

function XPWindow.mouseDown(self,x,y)
    local w, h = self.content:size()
    if Im:InsideBox(x,y,0,0,w,29) then
        self.isDragging = true
        self.dragPosX = x
        self.dragPosY = y
    end
    for i=1,#self.Windows.objects do
        if self.Windows.objects[i] == self.content then
            table.remove(self.Windows.objects,i)
            self.Windows.objects[#self.Windows.objects+1] = self.content
        end
    end
end


function XPWindow.mouseMove(self,sx,sy)
    if self.isDragging then
        self.parent.x = sx-self.x-self.dragPosX
        self.parent.y = sy-self.y-self.dragPosY
    end
end

function XPWindow.mouseUp(self,x,y)
    self.isDragging = false
end

function XPWindow.size(self)
    local w,h = self.content:size()
    w = w+6
    h = h+32
    return w,h
end

function XPWindow.onCreate(self)
    local w,h = self:size()
    self.Windows:createObject(self,XPCloseButton,{x=w-21-5,y=5,callback=function() self.Windows:closeWindow(self.window) end})
end

function XP.FillRect(XP,x,y,w,h)
    love.graphics.setColor(236/255,233/255,216/255,1)
    love.graphics.rectangle("fill",x,y,w,h)
end

function XP.GetButtonSize(self,text)
	local w,h = Im:TextSize(XP.textfont,text)
	return w,h,math.max(w+16,75),math.max(h+10,23)
end

ButtonStates = {"XP/Assets/XPButton.png","XP/Assets/XPHighlightedButton.png","XP/Assets/XPPressedButton.png"}

XPButton = {text = "", x = 0, y = 0}

function XPButton.drawFunction(self)
    love.graphics.setColor(1,1,1,1)
    local tw,th,bw,bh = XP:GetButtonSize(self.text)
    Im:NineSliceA(Im:Image(ButtonStates[self.buttonState]),0,0,bw,bh,0,0,7,7,8,8)
    love.graphics.setColor(0,0,0,1)
    Im:textput(XP.textfont,self.text,bw/2-tw/2,bh/2-th/2,0,0)
end

function XPButton.mouseUnhover(self)
    self.buttonState = 1
end

function XPButton.mouseDown(self)
    self.buttonState = 3
end

function XPButton.mouseMove(self)
    self.buttonState = 3
end

function XPButton.mouseHover(self)
    self.buttonState = 2
end

function XPButton.mouseUp(self)
    self.buttonState = 2
    if self.callback then
        self.callback(self.parent,self)
    end
end

function XPButton.onCreate(self)
    self.buttonState = 1
end

function XPButton.size(self)
    local _,_,w,h = XP:GetButtonSize(self.text)
    return w,h
end

XPCloseButton = shallowcopy(XPButton)

function XPCloseButton.size(self)
    return 21,21
end

function XPCloseButton.drawFunction(self)
    local inactive = true
    if self.Windows.objects[#self.Windows.objects] == self.window then
        inactive = false
    end
    love.graphics.setColor(1,1,1,1)
    if self.buttonState == 3 then
        love.graphics.draw(Im:Image("XP/Assets/XPCloseButtonPressed.png"))
    elseif self.buttonState == 2 then
        love.graphics.draw(Im:Image("XP/Assets/XPCloseButtonHighlighted.png"))
    else
        love.graphics.draw(Im:Image("XP/Assets/XPCloseButton"..(inactive and "Inactive" or "")..".png"))
    end
end

function XP.MessageBoxDraw(self)
    local width, height = self:size()
    XP:FillRect(0,0,width,height)
    love.graphics.setColor(0,0,0,1)
    Im:textput(XP.textfont,self.data.text,self.tx,self.ty,0,0)
    love.graphics.setColor(1,1,1,1)
    local icon = self.data.icon
    if icon then
        Im:jput(icon,11,11)
    end
end

function XP.MessageBoxClose(self)
    self.Windows:closeWindow(self)
end

function XP.MessageBoxCreate(self)
    local width, height = self:size()
    local buttons = self.data.buttons
    if buttons then
        buttonoffset = 0
		for i=1,#buttons do
			local _, _, bw, bh = XP:GetButtonSize(buttons[i])
            local button = self.Windows:createObject(self, 
                XPButton,
                {
                    x = buttonoffset+math.floor(self.w/2-self.buttonwidth/2),
                    y = self.h-self.buttonheight,
                    text = buttons[i],
                    callback = XP.MessageBoxClose
                })
			buttonoffset = buttonoffset+bw+6
		end
    end
end


function XP.MessageBoxSize(self)
    if self.w == nil then
        local tw, th = Im:TextSize(XP.textfont,self.data.text)
        local tx = 15
        local ty = math.max(11,math.floor(24-th/2))
        local w = tw+tx+8
        local h = th+ty+25
        local icon = self.data.icon
        if icon then
            iw, ih = icon:getPixelDimensions()
            tx = tx+iw+15
            ty = math.max(ty,math.floor(ih/2-th/2)+11)
            h = math.max(h,ih+11+11+3)
            w = w+iw+14
        end
        local buttonwidth = -6
        local buttonheight = 0
        local buttons = self.data.buttons
        if buttons then
            for i=1,#buttons do
                local _, _, bw, bh = XP:GetButtonSize(buttons[i])
                buttonwidth = buttonwidth+bw+6
                buttonheight = math.max(buttonheight,bh+12)
            end
            w = math.max(w,buttonwidth+18)
            h = h + buttonheight
        end
        self.w = math.max(66,w)
        self.h = h
        self.tx = tx
        self.ty = ty
        self.buttonwidth = buttonwidth
        self.buttonheight = buttonheight
    end
    return self.w,self.h
end

Icons = {"XP/Assets/XPCriticalError.png","XP/Assets/XPExclamation.png","XP/Assets/XPInformation.png","XP/Assets/XPQuestion.png"}

function XP.GetIcon(XP, id)
    return Im:Image(Icons[id])
end

function XP.CreateMessageBox(XP,title, text, icon, buttons)
    return {onCreate=XP.MessageBoxCreate,drawFunction=XP.MessageBoxDraw,data={text=text,icon=icon,buttons=buttons},size=XP.MessageBoxSize}
end



return XP