function log(_text, override)
    printh(_text, "jack_vs_zombies/log", override or false)
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

function str2frames(_str)
    local frames = {}
    for str_f in all(split(_str, "|")) do
        local frame = { sprites = {}, pal_rep = {} }
        local parts = split(str_f, "^")

        -- Handle sprites part
        for str_s in all(split(parts[1], "@")) do
            local params = split(str_s, ",")
            local sprite = list2sprite(params)
            add(frame.sprites, sprite)
        end

        -- Handle palette replacements if they exist
        if #parts > 1 then
            for str_p in all(split(parts[2], ",")) do
                local pal_pair = split(str_p, ":")
                add(frame.pal_rep, { pal_pair[1], pal_pair[2] })
            end
        end

        add(frames, frame)
    end
    return frames
end
function frames2str(_frames)
    local ret = ""
    for i, frame in pairs(_frames) do
        -- Convert sprites part to string
        local frame_str = ""
        for j, sprite in pairs(frame.sprites) do
            frame_str = frame_str .. sprite.x .. "," .. sprite.y .. "," .. sprite.w .. "," .. sprite.h .. "," .. sprite.ox .. "," .. sprite.oy .. "," .. tostring(sprite.fx) .. "," .. tostring(sprite.fy)
            if j < #frame.sprites then
                frame_str = frame_str .. "@"
            end
        end

        -- Convert palette replacements to string
        local pal_str = ""
        if #frame.pal_rep > 0 then
            pal_str = "^"
            for k, pal in pairs(frame.pal_rep) do
                pal_str = pal_str .. pal[1] .. ":" .. pal[2]
                if k < #frame.pal_rep then
                    pal_str = pal_str .. ","
                end
            end
        end

        -- Combine frame_str and pal_str
        ret = ret .. frame_str .. pal_str
        if i < #_frames then
            ret = ret .. "|"
        end
    end
    return ret
end
-- Your provided list2sprite function
function list2sprite(_list)
    local fx = _list[7] == "true"
    local fy = _list[8] == "true"
    return { x = _list[1], y = _list[2], w = _list[3], h = _list[4], ox = _list[5], oy = _list[6], fx = fx, fy = fy }
end