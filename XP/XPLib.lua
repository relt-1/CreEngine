XP = {}
Im = require("../ImageLib/ImageLib")

function XP.Init(XP)
    XP.textfont = love.graphics.newImageFont("XP/Assets/text.png"," !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")
end

function XP.FillRect(XP,x,y,w,h)
    love.graphics.setColor(236/255,233/255,216/255,1)
    love.graphics.rectangle("fill",x,y,w,h)
end

function XP.GetButtonSize(XP,text)
	local w,h = Im:TextSize(XP.textfont,text)
	return w,h,math.max(w+16,75),math.max(h+10,23)
end

function XP.DrawButton(XP,text,x,y,ax,ay)
    if ax == nil then ax = 0 end
    if ay == nil then ay = 0 end
    love.graphics.setColor(1,1,1,1)
    local tw,th,bw,bh = XP:GetButtonSize(text)
    local mx,my = love.mouse.getPosition()
    local ret = false
    if Im:InsideBox(mx,my,x-ax/2*bw,y-ay/2*bh,bw,bh) then
        if love.mouse.isDown(1) then
            ret = true
            Im:NineSliceA(Im:Image("XP/Assets/XPPressedButton.png"),x-ax/2*bw,y-ay/2*bh,bw,bh,0,0,7,7,8,8)
        else
            Im:NineSliceA(Im:Image("XP/Assets/XPHighlightedButton.png"),x-ax/2*bw,y-ay/2*bh,bw,bh,0,0,7,7,8,8)
        end
    else
        Im:NineSliceA(Im:Image("XP/Assets/XPButton.png"),x-ax/2*bw,y-ay/2*bh,bw,bh,0,0,7,7,8,8)
    end
    
    love.graphics.setColor(0,0,0,1)
    Im:textput(XP.textfont,text,x-ax/2*bw+bw/2-tw/2,y-ay/2*bh+bh/2-th/2,0,0)

    return ret
end

function XP.DrawFrame(XP,orx,ory,w,h,ax,ay)
    if ax == nil then ax = 0 end
    if ay == nil then ay = 0 end
    local topleftframe = Im:Image("XP/Assets/XPFrameTopLeft"..(inactive and "Inactive" or "")..".png")
	local topmiddleframe = Im:Image("XP/Assets/XPFrameTopMiddle"..(inactive and "Inactive" or "")..".png")
	local toprightframe = Im:Image("XP/Assets/XPFrameTopRight"..(inactive and "Inactive" or "")..".png")
	local leftframe = Im:Image("XP/Assets/XPFrameLeft"..(inactive and "Inactive" or "")..".png")
	local rightframe = Im:Image("XP/Assets/XPFrameRight"..(inactive and "Inactive" or "")..".png")
	local bottomleftframe = Im:Image("XP/Assets/XPFrameBottomLeft"..(inactive and "Inactive" or "")..".png")
	local bottommiddleframe = Im:Image("XP/Assets/XPFrameBottomMiddle"..(inactive and "Inactive" or "")..".png")
	local bottomrightframe = Im:Image("XP/Assets/XPFrameBottomRight"..(inactive and "Inactive" or "")..".png")
    local x = orx-ax/2*w-Im:W(leftframe)
    local y = ory-ay/2*h-Im:H(topmiddleframe)
    local fw = w+Im:W(leftframe)+Im:W(rightframe)
	local fh = h+Im:H(topmiddleframe)+Im:H(bottommiddleframe)
	love.graphics.setColor(1,1,1,1)
	Im:jput(topleftframe,x,y)
	Im:rput(topmiddleframe,x+Im:W(topleftframe),y,fw-Im:W(topleftframe)-Im:W(toprightframe))
	Im:fput(toprightframe,x+fw,y,2)
	Im:rput(leftframe,x,y+Im:H(topleftframe),nil,h)
	Im:put(rightframe,x+fw,y+Im:H(toprightframe),nil,h,2)
	Im:jput(bottomleftframe,x,y+h+Im:H(topmiddleframe))
	Im:rput(bottommiddleframe,x+Im:W(bottomleftframe),y+h+Im:H(topmiddleframe),fw-Im:W(bottomleftframe)-Im:W(bottomrightframe))
	Im:fput(bottomrightframe,x+fw,y+h+Im:H(topmiddleframe),2)
    --[[
	if title then
		if inactive then
			DrawXPText(title,7,7,xpcaptionwhite,xpcaptionblack,{216,228,248,255})
		else
			DrawXPText(title,8,8,xpcaptionshadowwhite,xpcaptionshadowblack)
			DrawXPText(title,7,7,xpcaptionwhite,xpcaptionblack)
		end
	end]]
	--Im:fput(Im:Image("XP/Assets/XPCloseButton"..(inactive and "Inactive" or "")..".png"),x+fw-5,y+5,2)

end

Icons = {"XP/Assets/XPCriticalError.png","XP/Assets/XPExclamation.png","XP/Assets/XPInformation.png","XP/Assets/XPQuestion.png"}

function XP.GetIcon(XP, id)
    return Im:Image(Icons[id])
end

function XP.DrawMessageBox(XP, title, message, icon, buttons, x, y, ax, ay)
    local tw, th = Im:TextSize(XP.textfont,message)
    local tx = 15
    local ty = math.max(11,math.floor(24-th/2))
    local w = tw+tx+8
    local h = th+ty+25
    if icon then
        iw, ih = icon:getPixelDimensions()
        tx = tx+iw+15
        ty = math.max(ty,math.floor(ih/2-th/2)+11)
        h = math.max(h,ih+11+11+3)
        w = w+iw+14
    end
    local buttonwidth = -6
    local buttonheight = 0
    if buttons then
		for i=1,#buttons do
			local _, _, bw, bh = XP:GetButtonSize(buttons[i])
			buttonwidth = buttonwidth+bw+6
			buttonheight = math.max(buttonheight,bh+12)
		end
		w = math.max(w,buttonwidth+18)
		h = h + buttonheight
	end
    w = math.max(66,w)

    XP:FillRect(x,y,w,h)
    love.graphics.setColor(0,0,0,1)
    Im:textput(XP.textfont,message,x+tx,y+ty)
    love.graphics.setColor(1,1,1,1)
    if icon then
        Im:jput(icon,x+11,y+11)
    end

    if buttons then
        buttonoffset = 0
		for i=1,#buttons do
			local _, _, bw, bh = XP:GetButtonSize(buttons[i])
			XP:DrawButton(buttons[i],x+buttonoffset+math.floor(w/2-buttonwidth/2),y+h-buttonheight)
			buttonoffset = buttonoffset+bw+6
		end
    end

    XP:DrawFrame(x,y,w,h)

end

return XP