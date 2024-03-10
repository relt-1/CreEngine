Im = {}

Im.openedimages = {}
Im.canvasstack = {}

function Im.PushCanvas(Im,w,h)
	local newcanvas = love.graphics.newCanvas(w,h)
	love.graphics.setCanvas(newcanvas)
	Im.canvasstack[#Im.canvasstack+1] = newcanvas
	return newcanvas
end

function Im.PopCanvas(Im)
	Im.canvasstack[#Im.canvasstack] = nil
	love.graphics.setCanvas(Im.canvasstack[#Im.canvasstack])
end

function Im.Image(Im,name)
	if Im.openedimages[name] == nil then
		Im.openedimages[name] = love.graphics.newImage(name)
	end
	return Im.openedimages[name]
end

function get_line_count(str)
    local lines = 1
    for i = 1, #str do
        local c = str:sub(i, i)
        if c == '\n' then lines = lines + 1 end
    end

    return lines
end

function Im.InsideBox(Im,x,y,bx,by,bw,bh)
	return x >= bx and x <= bx+bw and y >= by and y <= by+bh
end

function Im.W(Im,img)
	return img:getPixelWidth()
end

function Im.H(Im,img)
	return img:getPixelHeight()
end

function Im.WH(Im,img)
	return img:getPixelDimensions()
end

function Im.NineSlice(Im,img,x,y,w,h,left,right,top,bottom)
	x = math.floor(x)
	y = math.floor(y)
	local Q = love.graphics.newQuad
	local iw,ih = Im:WH(img)
	love.graphics.draw(img,Q(0,0,left,top,img),x,y)
	love.graphics.draw(img,Q(iw-right,0,right,top,img),x+w-right,y)
	love.graphics.draw(img,Q(0,ih-bottom,left,bottom,img),x,y+h-bottom)
	love.graphics.draw(img,Q(iw-right,ih-bottom,right,bottom,img),x+w-right,y+h-bottom)
	love.graphics.draw(img,Q(left,0,iw-left-right,top,img),x+left,y,nil,(w-left-right)/(iw-left-right),1)
	love.graphics.draw(img,Q(0,top,left,ih-top-bottom,img),x,y+top,nil,1,(h-top-bottom)/(ih-top-bottom))
	love.graphics.draw(img,Q(iw-right,top,right,ih-top-bottom,img),x+w-right,y+top,nil,1,(h-top-bottom)/(ih-top-bottom))
	love.graphics.draw(img,Q(left,ih-bottom,iw-left-right,bottom,img),x+left,y+h-bottom,nil,(w-left-right)/(iw-left-right),1)
	love.graphics.draw(img,Q(left,top,iw-left-right,ih-top-bottom,img),x+left,y+top,nil,(w-left-right)/(iw-left-right),(h-top-bottom)/(ih-top-bottom))
end

function Im.NineSliceA(Im,img,x,y,w,h,ax,ay,left,right,top,bottom)
	Im:NineSlice(img,x-w*ax/2,y-h*ay/2,w,h,left,right,top,bottom)
end

function Im.TextHeight(Im,font,text)
	return font:getHeight()*get_line_count(text)
end

function Im.TextSize(Im,font,text)
	return font:getWidth(text),Im:TextHeight(font,text)
end

function Im.InsideBox(Im,x,y,bx,by,bw,bh)
	return x >= bx and x <= bx+bw and y >= by and y <= by+bh
end

function Im.put(Im,img,x,y,w,h,ax,ay)
	if ax == nil then
		ax = 0
	end
	if ay == nil then
		ay = 0
	end
	local pw,ph = Im:WH(img)
	if w == nil then
		w = pw
	end
	if h == nil then
		h = ph
	end
	love.graphics.draw(img,x,y,0,w/pw,h/ph,ax/2*w,ay/2*h)
end

function Im.fput(Im,img,x,y,ax,ay)
	if ax == nil then
		ax = 0
	end
	if ay == nil then
		ay = 0
	end
	local pw,ph = Im:WH(img)
	love.graphics.draw(img,x,y,0,1,1,ax/2*pw,ay/2*ph)
end

function Im.rput(Im,img,x,y,w,h)
	local pw,ph = Im:WH(img)
	if w == nil then
		w = pw
	end
	if h == nil then
		h = ph
	end
	love.graphics.draw(img,x,y,0,w/pw,h/ph)
end

function Im.jput(Im,img,x,y)
	love.graphics.draw(img,x,y)
end

function Im.textput(Im,font,text,x,y,ax,ay)
	if ax == nil then
		ax = 0
	end
	if ay == nil then
		ay = 0
	end
	local pw,ph = Im:TextSize(font,text)
	love.graphics.setFont(font)
	love.graphics.print(text,math.floor(x-ax/2*pw),math.floor(y-ay/2*ph))
end

function Im.PlaceSliced(Im,name,x,y,w,h,nocenter)
	local topleft = Im:Image(name.."TopLeft.png")
	local topmiddle = Im:Image(name.."TopMiddle.png")
	local topright = Im:Image(name.."TopRight.png")
	local bottomleft = Im:Image(name.."BottomLeft.png")
	local bottommiddle = Im:Image(name.."BottomMiddle.png")
	local bottomright = Im:Image(name.."BottomRight.png")
	local left = Im:Image(name.."Left.png")
	local right = Im:Image(name.."Right.png")
	Im:jput(topleft,x,y)
	Im:rput(topmiddle,Im:W(topleft)+x,y,w-Im:W(topleft)-Im:W(topright))
	Im:fput(topright,x+w,y,2)
	Im:rput(left,x,Im:H(topleft)+y,nil,h-Im:H(topleft)-Im:H(bottomleft))
	Im:put(right,x+w,Im:H(topleft)+y,nil,h-Im:H(topright)-Im:H(bottomright),2)
	Im:fput(bottomleft,x,h+y,0,2)
	Im:put(bottommiddle,Im:W(bottomleft)+x,y+h,w-Im:W(bottomleft)-Im:W(bottomright),nil,0,2)
	Im:fput(bottomright,x+w,y+h,2,2)
	if nocenter == nil then
		Im:rput(Im:Image(name.."Center.png"),x+Im:W(left),y+Im:H(topmiddle),w-Im:W(left)-Im:W(right),h-Im:H(topmiddle)-Im:H(bottommiddle))
	end
end

return Im