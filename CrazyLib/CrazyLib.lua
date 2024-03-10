dofile("util.lua")

CrazyLib = {}
CrazyLib.variables = {}
CrazyLib.time = 0
CrazyLib.events = {}
CrazyLib.registered = {}

function CrazyLib.decodeError(self,str,decodedTime)
    local strpos = 1
    local state = "default"
    local strsplitted = string.split(str,",")
    if #strsplitted == 2 then
        self.events[#self.events+1] = {time = decodedTime, error = self.registered[strsplitted[1]],id=strsplitted[1],pos=shallowcopy(self.variables[strsplitted[2]])}
    else
        local equal = string.split(str,"=")
        if #equal == 2 then
            local variable = string.split(equal[1],",")[2]
            local numbers = string.split(equal[2],",")

            for i=1,#numbers do
                self.variables[variable][i] = tonumber(numbers[i])
            end
            self.events[#self.events+1] = {time = decodedTime, error = self.registered[strsplitted[1]],id=strsplitted[1],pos=shallowcopy(self.variables[variable])}
        else

            local plus = string.split(str,"+")
            local variable = string.split(plus[1],",")[2]
            local numbers = string.split(plus[2],",")
            for i=1,#numbers do
                self.variables[variable][i] = self.variables[variable][i] + tonumber(numbers[i])
            end
            self.events[#self.events+1] = {time = decodedTime, error = self.registered[strsplitted[1]],id=strsplitted[1],pos=shallowcopy(self.variables[variable])}
        end

       
    end

end

function CrazyLib.loadString(self,str)
    local variable = nil
    local errorDefine = {}
    local errorDefineVariable = 1
    local buffer = ""
    local encodedTime = ""
    local listBuffer = {}
    local listBufferIndex = 1
    local strpos = 1
    local state = "default"
    line = 0
    str = str.."\n"
    while strpos <= #str do
        local c = chr(str,strpos)
        if c ~= "\r" then
            if c == "\n" then
                line = line + 1
                print(line)
            end
            if state == "default" then
                if isalpha(c) then
                    buffer = buffer..c
                elseif c == "=" then
                    variable = buffer
                    buffer = ""
                    state = "setValue"
                elseif c == "+" then
                    variable = buffer
                    buffer = ""
                    state = "incrementValue"
                end
            elseif state == "setValue" then
                if c == "\n" then
                    self.variables[variable] = buffer
                    buffer = ""
                    state = "default"
                    variable = nil
                elseif c == "{" and buffer == "" then
                    state = "setValue.errorDefinition"
                    errorDefine = {}
                    errorDefineVariable = 1
                elseif c == ":" then
                    state = "setValue.error"
                    encodedTime = buffer
                    buffer = ""
                elseif c == "," then
                    state = "setValue.number"
                    self.variables[variable] = {tonumber(buffer)}
                    buffer = ""
                else
                    buffer = buffer..c
                end
            elseif state == "setValue.number" then
                if c == "\n" then
                    self.variables[variable][#self.variables[variable]+1] = tonumber(buffer)
                    buffer = ""
                    variable = ""
                    state = "default"
                elseif c == "," then
                    self.variables[variable][#self.variables[variable]+1] = tonumber(buffer)
                    buffer = ""
                else
                    buffer = buffer..c
                end
            elseif state == "setValue.error" then
                if c == "\n" then
                    local encTtable = string.split(encodedTime,".")
                    for i=1,#encTtable do
                        encTtable[i] = tonumber(encTtable[i])-1
                    end
                    encTtable[#encTtable] = tonumber(encTtable[#encTtable])-1
                    local decodedTime = (encTtable[1]*4 + encTtable[2] + encTtable[3]/4)/self.variables.BPM*60
                    if string.sub(buffer,1,1) == ">" then
                        self.events[#self.events+1] = {time = decodedTime, command = string.sub(buffer,2)}
                    else
                        self:decodeError(buffer,decodedTime)
                    end
                    --local buffersplitted = string.split(buffer,",")
                    --self.events[#self.events+1] = {time = decodedTime, error = self.registered[buffersplitted[1]],pos=shallowcopy(self.variables[buffersplitted[2]])}
                    self.variables[variable] = decodedTime
                    buffer = ""
                    state = "default"
                else
                    buffer = buffer..c
                end
            elseif state == "incrementValue" then
                if c == "\n" then
                    local numbers = string.split(buffer,",")
                    for i=1,#numbers do
                        self.variables[variable][i] = self.variables[variable][i] + tonumber(numbers[i])
                    end
                    state = "default"
                    buffer= ""
                elseif c == ":" then
                    state = "incrementValue.error"
                    encodedTime = buffer
                    buffer = ""
                else
                    buffer = buffer..c
                end 
            elseif state == "incrementValue.error" then
                if c == "\n" then
                    local encTtable = string.split(encodedTime,".")
                    for i=1,#encTtable do
                        encTtable[i] = tonumber(encTtable[i])
                    end
                    local decodedTime = (encTtable[1]*4 + encTtable[2] + encTtable[3]/4)/self.variables.BPM*60
                    if string.sub(buffer,1,1) == ">" then
                        self.events[#self.events+1] = {time = self.variables[variable] + decodedTime, command = string.sub(buffer,2)}
                    else
                        self:decodeError(buffer,self.variables[variable] +decodedTime)

                        --self.events[#self.events+1] = {time = self.variables[variable] + decodedTime, error = self.registered[buffersplitted[1]],pos=shallowcopy(self.variables[buffersplitted[2]])}
                    end
                    self.time = self.time + decodedTime
                    self.variables[variable] = self.variables[variable] + decodedTime
                    buffer = ""
                    state = "default"
                else
                    buffer = buffer..c
                end
            elseif state == "setValue.errorDefinition" then
                if c == "," then
                    errorDefine[errorDefineVariable] = buffer
                    buffer = ""
                    errorDefineVariable = errorDefineVariable + 1
                elseif c == "}" then
                    errorDefine[errorDefineVariable] = buffer
                    self.registered[variable] = errorDefine
                    buffer = ""
                    state = "default"
                    variable = nil
                elseif c == "[" then
                    state = "setValue.errorDefinition.list"
                    listBuffer = {}
                    listBufferIndex = 1
                else
                    buffer = buffer..c
                end
            
            elseif state == "setValue.errorDefinition.list" then
                if c == "]" then
                    listBuffer[listBufferIndex] = buffer
                    buffer = listBuffer
                    state = "setValue.errorDefinition"
                elseif c == "," then
                    listBuffer[listBufferIndex] = buffer
                    buffer = ""
                    listBufferIndex = listBufferIndex + 1
                else
                    buffer = buffer..c
                end
            end
        end
        strpos = strpos + 1
    end
    table.sort(self.events,function(a,b) return a.time < b.time end)
    --printTable(self.events)
end

function CrazyLib.load(self,file)
    self.loaded = love.filesystem.read(file)
    self:loadString(self.loaded)
end

function CrazyLib.tick(self,time)
    local returned = {}
    while self.events[1] do
        if self.events[1].time <= time then
            returned[#returned+1] = self.events[1]
            table.remove(self.events,1)
        else
            break
        end
    end
    return returned
end

return CrazyLib