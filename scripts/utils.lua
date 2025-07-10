function log(_text, override)
    printh(_text, "log", override or false)
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

function shake()
    shake_x=rnd(intensity) - (intensity /2)
    shake_y=rnd(intensity) - (intensity /4)

    --ease shake and return to normal
    intensity *= .9
    if intensity < .3 then intensity = 0 end
end

-- pad string with zeros
function pad(v, length)
    local s = "0000000000" .. v
    return sub(s, #s - length + 1)
end

-- generate id
local random = rnd
function new_guid(_kind_code)
    local s = pad(flr(time()), 5)
    local r = pad(flr(random() * 100), 5)
    _kind_code = _kind_code or "00000"
    return s .. "-" .. r .. "-" .. _kind_code
end

-- get entity by id
function get_entity(_id)
    if (entities == nil or #entities == 0) return nil
    local i, ent = 1, nil
    while i <= #entities and ent == nil do
        if (entities[i].id == _id) ent = entities[i]
        i += 1
    end
    return ent
end

-- Your provided list2sprite function
function list2sprite(_list)
    local fx = _list[7] == "true"
    local fy = _list[8] == "true"
    return { x = _list[1], y = _list[2], w = _list[3], h = _list[4], ox = _list[5], oy = _list[6], fx = fx, fy = fy }
end

function str2frames(s)
    local frames = {}
    for fs in all(split(s,'|')) do
        local xy=split(fs)
        add(frames,pack(xy[1],xy[2],16,16))
    end
    return frames
end

function ssprc(sx,sy,sw,sh,dx,dy,dw,dh,fx,fy,a,oc)
    local dw=dw or sw
    local dh=dh or sh
    local a = a or 'cb' --alignment
    local x,y=dx,dy
    if a=='cb' then
        x=dx-flr(dw/2)
        y=dy-dh
    elseif a=='b' then
        y=dy-dh
    end
 
    if oc then
        for i=1,15 do
            pal(i,oc)
        end

        sspr(sx,sy,sw,sh,x-1,y,dw,dh,fx,fy)
        sspr(sx,sy,sw,sh,x+1,y,dw,dh,fx,fy)
        sspr(sx,sy,sw,sh,x,y-1,dw,dh,fx,fy)
        sspr(sx,sy,sw,sh,x,y+1,dw,dh,fx,fy)
        pal()
    end

    sspr(sx,sy,sw,sh,x,y,dw,dh,fx,fy)
end

function tableout(t,deep)
 deep=deep or 0
 local str=sub("    ",1,deep)
 log(str.."table size: "..#t) 
 for k,v in pairs(t) do
   if type(v)=="table" then
     log(str..tostr(k).."[]")
     tableout(v,deep+1)
   else
     log(str..tostr(k).." = "..tostr(v))
   end
 end
end