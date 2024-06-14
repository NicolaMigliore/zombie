function log(_text)
    printh(_text, "zombie/log")
end

--- sort the elements
function sort(_list, _comparison_f)
    for i = 2, #_list do
        local j = i
        while j > 1 and _comparison_f(_list[j - 1], _list[j]) do
            _list[j], _list[j - 1] = _list[j - 1], _list[j]
            j -= 1
        end
    end
end

-- pad string with zeros
function pad(v,length)
	local s="0000000000"..v
	return sub(s,#s-length+1)
end

-- generate id
local random = rnd
function new_guid(_kind_code)
    local s = pad(flr(time()),5)
    local r = pad(flr(random()*100),5)
    _kind_code = _kind_code or "00000"
    return s.."-"..r.."-".._kind_code
end

-- get entity by id
function get_entity(_id)
    if (entities == nil or #entities == 0) return nil
    local i,ent = 1,nil
    while i < #entities and ent==nil do
        if(entities[i].id == _id) ent = entities[i]
        i += 1
    end
    return ent
end

-- converts anything to string, even nested tables
function tostring(any)
    if type(any) == "function" then
        return "function"
    end
    if any == nil then
        return "nil"
    end
    if type(any) == "string" then
        return any
    end
    if type(any) == "boolean" then
        if any then return "true" end
        return "false"
    end
    if type(any) == "table" then
        local str = "{ "
        for k, v in pairs(any) do
            str = str .. tostring(k) .. "->" .. tostring(v) .. " "
        end
        return str .. "}"
    end
    if type(any) == "number" then
        return "" .. any
    end
    return "unkown"
    -- should never show
end