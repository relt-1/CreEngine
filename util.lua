function shallowcopy(t)
    local newt = {}
    for k,v in pairs(t) do
        newt[k] = v
    end
    return newt
end

function chr(str,i)
    return string.sub(str,i,i)
end

function isalpha(c)
    local cc = string.byte(c)
    return (cc >= string.byte("a") and cc <= string.byte("z")) or (cc >= string.byte("A") and cc <= string.byte("Z"))
end

function isdigit(c)
    local cc = string.byte(c)
    return (cc >= string.byte("0") and cc <= string.byte("9"))
end

function isnumber(str) --will i ever use this? IDK
    return tonumber(str) ~= nil
end

function printTable(tabl)
    print("{")
    for k,v in pairs(tabl) do
        if type(v) == "table" then
            print(k,"=")
            printTable(v)
        else
            print(k,"=",v)
        end
    end
    print("}")
end

function string.split(str,splitting)
    local encTpos = 1
    local encTtable = {""}
    while encTpos <= #str do
        local encTchr = chr(str,encTpos)
        if encTchr == splitting then
            encTtable[#encTtable+1] = ""
        else
            encTtable[#encTtable] = encTtable[#encTtable]..encTchr
        end
        encTpos = encTpos + 1
    end
    return encTtable
end

function string.startswith(str,starts)
    return string.sub(str,1,#starts) == starts
end