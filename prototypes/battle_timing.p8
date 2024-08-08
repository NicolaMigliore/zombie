pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
    e = {
        position = { x=60, y=60 },
        -- #region sprites
        sprite = {
            sprites = {{x=0,y=0,w=8,h=8,fx=false,fy=false}}
        },
        -- #region animation
        animation = {
            active_anim = "idle",
            i = 1,
            anim_frame_time = 0,
            animations = {
                idle = {
                    frames = {
                        {{x=8,y=0,w=8,h=8,ox=0,oy=0,fx=false,fy=false}},
                        {{x=16,y=0,w=8,h=8,ox=0,oy=0,fx=false,fy=false}}
                    },
                    speed = 0.5, -- Adjusted for the desired speed
                    loop = true
                },
                punch_1 = {
                    frames = {
                        {{x=24,y=0,w=8,h=8,ox=0,oy=0,fx=false,fy=false}},
                        {{x=24,y=0,w=8,h=8,ox=0,oy=0,fx=false,fy=false}},
                        {{x=24,y=0,w=8,h=8,ox=0,oy=0,fx=false,fy=false}},
                        {{x=24,y=0,w=8,h=8,ox=0,oy=0,fx=false,fy=false}},
                        {{x=24,y=0,w=8,h=8,ox=0,oy=0,fx=false,fy=false}},
                        {{x=32,y=0,w=8,h=8,ox=0,oy=0,fx=false,fy=false}},
                    },
                    speed = 0.2, -- Adjusted for the desired speed
                    loop = false
                },
                punch_2 = {
                    frames = {
                        {{x=40,y=0,w=8,h=8,ox=0,oy=0,fx=false,fy=false}},
                        {{x=40,y=0,w=8,h=8,ox=0,oy=0,fx=false,fy=false}},
                        {{x=40,y=0,w=8,h=8,ox=0,oy=0,fx=false,fy=false}},
                        {{x=32,y=0,w=8,h=8,ox=0,oy=0,fx=false,fy=false}},
                    },
                    speed = 0.2, -- Adjusted for the desired speed
                    loop = false
                }
            }
        },
        state = {
            current = "idle",
            previous = "idle",
            rules = {
                idle = function(_e)
                    if btnp(5) then
                        return "punch_1"
                    end
                    return "idle"
                end,
                punch_1 = function(_e)
                    local anim_perc = animation_progress_percentage()
                    if anim_perc >= 1 then
                        return "idle"
                    end
                    if anim_perc > 0.75 and btnp(5) then
                        return "punch_2"
                    end
                    return "punch_1"
                end,
                punch_2 = function(_e)
                    if animation_progress_percentage() >= 1 then
                        return "idle"
                    end
                    return "punch_2"
                end
            }
        }
    }
end

function _update60()
    state_update()
    animation_update()
end

function _draw()
    cls()
    print("animation: " .. e.animation.active_anim, 0, 5, 7)
    print("state: " .. e.state.current, 0, 15, 7)
    if e.state.current == "punch_1" then
        print("progress: " .. animation_progress_percentage(), 0, 25, 7)
    end
    graphics_update()
end

function animation_update()
    local anim = e.animation
    -- if state has changed update current animation
    if e.state.current ~= e.state.previous then
        anim.active_anim = e.state.current
        anim.max_frame_width = calculate_max_frame_width(anim.animations[anim.active_anim].frames)
        anim.i = 1
        anim.anim_frame_time = 0
    end

    -- progress animation
    local cur_animation = anim.animations[anim.active_anim]
    anim.anim_frame_time += 1

    if anim.anim_frame_time >= cur_animation.speed * 60 then
        anim.i += 1
        anim.anim_frame_time = 0
    end

    if anim.i > #cur_animation.frames then
        if cur_animation.loop then
            anim.i = 1
        else
            anim.i = #cur_animation.frames + 1 -- Allow to exceed frame count for end check
        end
    end

    -- set sprite
    local frame_index = flr(anim.i)
    if frame_index > #cur_animation.frames then
        frame_index = #cur_animation.frames
    end

    local new_frame = cur_animation.frames[frame_index]
    e.sprite.sprites = new_frame
end

function animation_progress_percentage()
    local anim = e.animation
    local cur_animation = anim.animations[anim.active_anim]
    local total_frames = #cur_animation.frames
    local current_frame_progress = anim.anim_frame_time / (cur_animation.speed * 60)
    local total_progress = (anim.i - 1 + current_frame_progress) / total_frames
    return total_progress
end

function graphics_update()
    local frame = e.sprite.sprites
    local frame_width = calculate_frame_width(frame)
    local max_frame_width = (e.animation ~= nil) and e.animation.max_frame_width or calculate_max_frame_width({frame})
    draw_frame(frame, e.position, e.sprite.flip_x, max_frame_width)
end

function state_update()
    if e.state and e.state.rules then
        e.state.previous = e.state.current
        local state_rule = e.state.rules[e.state.current]
        if state_rule then
            e.state.current = state_rule(e)
        end
    end
end

-- Function to calculate the bounding box width of a single frame
function calculate_frame_width(frame)
    local min_x = 127
    local max_x = -127
    for _, sprite in ipairs(frame) do
        local sprite_left = sprite.ox
        local sprite_right = sprite.ox + sprite.w
        if sprite_left < min_x then
            min_x = sprite_left
        end
        if sprite_right > max_x then
            max_x = sprite_right
        end
    end
    return max_x - min_x
end

-- Function to calculate the maximum width among all frames
function calculate_max_frame_width(frames)
    local max_width = 0
    for _, frame in ipairs(frames) do
        local frame_width = calculate_frame_width(frame)
        if frame_width > max_width then
            max_width = frame_width
        end
    end
    return max_width
end

-- Function to draw a frame of sprites using sspr
function draw_frame(frame, position, flip_x, frame_width)
    for _, sprite in ipairs(frame) do
        -- Calculate the final position with offsets
        local base_x = position.x - frame_width / 2
        local x = base_x + sprite.ox
        local y = position.y + sprite.oy
        
        if flip_x then
            -- Mirror the sprite's x position around the center of the frame
            x = base_x + (frame_width - sprite.ox - sprite.w)
        end
        
        -- Determine the actual flip values
        local fx = flip_x and not sprite.fx or sprite.fx
        local fy = sprite.fy
        
        -- Draw the sprite with flipping
        sspr(sprite.x, sprite.y, sprite.w, sprite.h, x, y, sprite.w, sprite.h, fx, fy)
    end
end


-- log(flr(_e.animation.i)..">"..#cur_animation.frames.." - "..tostring(flr(_e.animation.i) > #cur_animation.frames))


function log(_text)
    printh(_text, "jack_vs_zombies/log")
end

__gfx__
000000000000000000000000ccccccccbbbbbbbb9999999988888888000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000ee000ccccccccbbbbbbbb9999999988888888000000000000000000000000000000000000000000000000000000000000000000000000
00700700000ee00000e00e00ccccccccbbbbbbbb9999999988888888000000000000000000000000000000000000000000000000000000000000000000000000
0007700000e00e000e0000e0ccccccccbbbbbbbb9999999988888888000000000000000000000000000000000000000000000000000000000000000000000000
0007700000e00e000e0000e0ccccccccbbbbbbbb9999999988888888000000000000000000000000000000000000000000000000000000000000000000000000
00700700000ee00000e00e00ccccccccbbbbbbbb9999999988888888000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000ee000ccccccccbbbbbbbb9999999988888888000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000ccccccccbbbbbbbb9999999988888888000000000000000000000000000000000000000000000000000000000000000000000000
