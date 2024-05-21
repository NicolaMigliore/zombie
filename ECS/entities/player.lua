function _player_i()
    local player_animation = {
        idle = {
            frames = {
                {x=32,y=0,w=16,h=16},
                {x=32,y=0,w=16,h=16},
                {x=32,y=0,w=16,h=16},
                {x=48,y=0,w=16,h=16},
                {x=16,y=0,w=16,h=16},
                {x=32,y=0,w=16,h=16},
            },
            speed = 0.05,
            loop = true,
        },
        idle_left = {
            frames = {
                {x=32,y=0,w=16,h=16},
                {x=32,y=0,w=16,h=16},
                {x=32,y=0,w=16,h=16},
                {x=48,y=0,w=16,h=16},
                {x=16,y=0,w=16,h=16},
                {x=32,y=0,w=16,h=16},
            },
            speed = 0.05,
            loop = true,
            flip = true,
        },
        run_right = {
            frames = {
                {x=0,y=16,w=16,h=16},
                {x=16,y=16,w=16,h=16},
                {x=32,y=16,w=16,h=16},
                {x=48,y=16,w=16,h=16},
                {x=64,y=16,w=16,h=16},
                {x=80,y=16,w=16,h=16},
                {x=96,y=16,w=16,h=16},
                {x=112,y=16,w=16,h=16},
            },
            speed = 0.15,
            loop = true,
            flip = false,
        },
        run_left = {
            frames = {
                {x=0,y=16,w=16,h=16},
                {x=16,y=16,w=16,h=16},
                {x=32,y=16,w=16,h=16},
                {x=48,y=16,w=16,h=16},
                {x=64,y=16,w=16,h=16},
                {x=80,y=16,w=16,h=16},
                {x=96,y=16,w=16,h=16},
                {x=112,y=16,w=16,h=16},
            },
            speed = 0.15,
            loop = true,
            flip = true,
        },
        punch_right = {
            frames = {
                {x=16,y=0,w=16,h=16},
                {x=0,y=32,w=16,h=16},
                {x=16,y=32,w=16,h=16},
                {x=32,y=32,w=16,h=16},
                {x=48,y=32,w=16,h=16},
            },
            speed = 0.2,
            loop = false,
            flip = false,
        },
        punch_left = {
            frames = {
                {x=16,y=0,w=16,h=16},
                {x=0,y=32,w=16,h=16},
                {x=16,y=32,w=16,h=16},
                {x=32,y=32,w=16,h=16},
                {x=48,y=32,w=16,h=16},
            },
            speed = 0.2,
            loop = false,
            flip = true,
        }
    }
    local player_states = {
        idle_left = function(_e) return (not _e.intention.left and _e.state.current == 'run_left') or (_e.state.current == "punch_left" and _e.animation.anim_i > 5) end,
        idle = function(_e)
            local stopped_moving = not _e.intention.right and _e.state.current == 'run_right'
            local animation_frame = _e.animation.anim_i
            local attack_ended = _e.state.current == "punch_right" and animation_frame > 5
            return stopped_moving or attack_ended

        end,
        run_left = function(_e) return _e.intention.left end,
        run_right = function(_e) return _e.intention.right or (_e.state.current == "punch_right" and _e.animation.anim_i > 5) end,
        punch_right = function(_e) 
            local looking_right = _e.state.current=="run_right" or _e.state.current=="idle"
            if looking_right then
                --local can_attack = _e.battle.cooldown==0
                local attacking = _e.intention.x
                if attacking then
                    -- local not_moving = not _e.intention.right
                    return true
                    -- return looking_right and can_attack and attacking --and not_moving
                end
            end
            return false
        end,
        punch_left = function(_e) 
            return (_e.state.current=="run_left" or _e.state.current=="idle_left") and (_e.intention.x) and not _e.intention.left
        end,
    }
    local player_hitboxes = {
        punch_left = { ox=0, oy=8, w=3, h=4 },
        punch_right = { ox=12, oy=8, w=3, h=4 }
    }

    player = new_entity({
        kind = "player",
        position = new_position(22,60,16,16,2),
        sprite = new_sprite({x=16,y=0,w=16,h=16}),
        animation = new_animation(player_animation,"idle",player_animation_handler),
        -- control = new_control(⬅️,➡️,nil,nil,0.7,0,🅾️,❎,player_contol),
        control = new_control({
            left = ⬅️,
            right = ➡️,
            spd_x = 0.7,
            o = 🅾️,
            x = ❎,
            control_func = player_contol
        }),
        intention = new_intention(),
        collider = new_collider(5,3,5,12,{}),
        state = new_state(player_states,"idle"),
        battle = new_battle(player_hitboxes,{},{health=200, damage=20, cd_time= 45}),
    })
    add(entities,player)
end

function player_animation_handler(_e)
    -- local new_anim = "idle"
    -- if (_e.intention.is_moving) new_anim = "run"
    -- if (_e.intention.attack_1) new_anim = "punch"

    -- if _e.animation.active_anim != new_anim then
    --     _e.animation.active_anim = new_anim
    -- end
end

function player_contol(_e)
    -- player movement
    _e.intention.left = btn(_e.control.left)
    _e.intention.right = btn(_e.control.right)
    _e.intention.is_moving = _e.intention.left or _e.intention.right

    _e.intention.o = btnp(_e.control.o)
    
    -- player attack
    _e.intention.x = btnp(_e.control.x)
    -- if btnp(❎) then
    --     _e.intention.x = true
    -- end

end