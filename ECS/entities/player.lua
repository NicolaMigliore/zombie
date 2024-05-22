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
        idle = function(_e)
            -- move player
            if(_e.intention.left) return 'run_left'
            if(_e.intention.right) return 'run_right'

            -- attack
            if(_e.intention.x) return "punch_right"

            -- return current state
            return "idle"
        end,
        idle_left = function(_e)
            -- move player
            if(_e.intention.left) return 'run_left'
            if(_e.intention.right) return 'run_right'

            -- attack
            if(_e.intention.x) return "punch_left"

            -- return current state
            return "idle_left"
        end,
        run_right = function(_e)
            -- attack
            if(_e.intention.x) _e.intention.right=false return "punch_right"

            -- keep moving
            if(_e.intention.right) return "run_right"
            if(_e.intention.left) return "run_left"

            -- stop
            return "idle"
        end,
        run_left = function(_e)
            -- attack
            if(_e.intention.x) _e.intention.left=false return "punch_left"

            -- keep moving
            if(_e.intention.right) return "run_right"
            if(_e.intention.left) return "run_left"

            -- stop
            return "idle_left"
        end,
        punch_right = function(_e)
            local attack_ended = _e.animation.anim_i > #_e.animation.animations["punch_right"].frames

            -- idle
            if(attack_ended) return "idle"

            -- keep punching
            return "punch_right"
        end,
        punch_left = function(_e)
            local attack_ended = _e.animation.anim_i > #_e.animation.animations["punch_left"].frames

            -- idle
            if(attack_ended) return "idle_left"

            -- keep punching
            return "punch_left"
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
    -- player attack
    _e.intention.x = btnp(_e.control.x)

    local is_attacking = _e.state.current == "punch_right" or _e.state.current == "punch_left"

    -- player movement
    _e.intention.left = not is_attacking and btn(_e.control.left)
    _e.intention.right = not is_attacking and btn(_e.control.right)
    _e.intention.is_moving = _e.intention.left or _e.intention.right

    _e.intention.o = btnp(_e.control.o)
    
    
    -- if btnp(❎) then
    --     _e.intention.x = true
    -- end

end