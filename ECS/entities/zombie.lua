function spawn_zombie()
    local zombie_animations = {
        idle = {
            frames = {
                {x=48,y=48,w=16,h=16},
                {x=48,y=48,w=16,h=16},
                {x=48,y=48,w=16,h=16},
                {x=64,y=48,w=16,h=16},
                {x=80,y=48,w=16,h=16},
                {x=96,y=48,w=16,h=16},
                {x=48,y=48,w=16,h=16},
            },
            speed = 0.1,
            loop = true,
            flip = false,
        },
        idle_left = {
            frames = {
                {x=48,y=48,w=16,h=16},
                {x=48,y=48,w=16,h=16},
                {x=48,y=48,w=16,h=16},
                {x=64,y=48,w=16,h=16},
                {x=80,y=48,w=16,h=16},
                {x=96,y=48,w=16,h=16},
                {x=48,y=48,w=16,h=16},
            },
            speed = 0.1,
            loop = true,
            flip = false,
        },
        damaged = {
            frames = {
                {x=80,y=48,w=16,h=16,pal_rep={{3,7},{2,7},{5,7},{10,5},{8,5}}},
                {x=80,y=48,w=16,h=16,pal_rep={{3,8},{2,8},{5,8},{10,5},{8,5}}},
                {x=80,y=48,w=16,h=16,pal_rep={{3,7},{2,7},{5,7},{10,5},{8,5}}},
                {x=80,y=48,w=16,h=16,pal_rep={{3,8},{2,8},{5,8},{10,5},{8,5}}},
                {x=96,y=48,w=16,h=16,pal_rep={{3,7},{2,7},{5,7},{10,5},{8,5}}},
                {x=96,y=48,w=16,h=16,pal_rep={{3,8},{2,8},{5,8},{10,5},{8,5}}},
                {x=96,y=48,w=16,h=16,pal_rep={{3,7},{2,7},{5,7},{10,5},{8,5}}},
                {x=96,y=48,w=16,h=16,pal_rep={{3,8},{2,8},{5,8},{10,5},{8,5}}},
            },
            speed = 0.3,
            loop = true,
            flip = false,
        },
        _death = {
            frames = {
                {x=0,y=64,w=16,h=16},
                {x=48,y=80,w=16,h=16},
                {x=64,y=80,w=16,h=16},
                {x=80,y=80,w=16,h=16},
                {x=96,y=80,w=16,h=16},
                {x=112,y=80,w=16,h=16},
                {x=112,y=80,w=16,h=16},
                {x=112,y=80,w=16,h=16},
                {x=112,y=80,w=16,h=16},
                {x=112,y=80,w=16,h=16},
                {x=112,y=80,w=16,h=16},
            },
            speed = 0.1,
            loop = false,
            flip = false,
        },
        run_right = {
            frames = {
                {x=112,y=48,w=16,h=16},
                {x=0,y=64,w=16,h=16},
                {x=16,y=64,w=16,h=16},
                {x=32,y=64,w=16,h=16},
                {x=48,y=64,w=16,h=16},
                {x=64,y=64,w=16,h=16},
            },
            speed = 0.1,
            loop = true,
            flip = false,
        },
        run_left = {
            frames = {
                {x=112,y=48,w=16,h=16},
                {x=0,y=64,w=16,h=16},
                {x=16,y=64,w=16,h=16},
                {x=32,y=64,w=16,h=16},
                {x=48,y=64,w=16,h=16},
                {x=64,y=64,w=16,h=16},
            },
            speed = 0.05,
            loop = true,
            flip = true,
        },
        attack_right = {
            frames = {
                {x=48,y=48,w=16,h=16},
                {x=80,y=64,w=16,h=16},
                {x=96,y=64,w=16,h=16},
                {x=112,y=64,w=16,h=16},
                {x=0,y=80,w=16,h=16},
                {x=16,y=80,w=16,h=16},
                {x=32,y=80,w=16,h=16},
                {x=32,y=80,w=16,h=16},
            },
            speed = 0.1,
            loop = false,
            flip = false,
        },
        attack_left = {
            frames = {
                {x=48,y=48,w=16,h=16},
                {x=80,y=64,w=16,h=16},
                {x=96,y=64,w=16,h=16},
                {x=112,y=64,w=16,h=16},
                {x=0,y=80,w=16,h=16},
                {x=16,y=80,w=16,h=16},
                {x=32,y=80,w=16,h=16},
                {x=32,y=80,w=16,h=16},
            },
            speed = 0.07,
            loop = false,
            flip = true,
        },
    }
    local zombie_states = {
        idle = function(_e)
            -- move zombie
            if(_e.intention.left) return "run_left"
            if(_e.intention.right) return "run_right"

            -- attack
            if(_e.intention.x) return "attack_right"

            -- idle
            return "idle"
        end,
        idle_left = function(_e)
            -- move zombie
            if(_e.intention.left) return "run_left"
            if(_e.intention.right) return "run_right"

            -- attack
            if(_e.intention.x) return "attack_left"

            -- idle
            return "idle_left"
        end,
        damaged = function(_e)
            -- idle
            local damage_ended = _e.animation.anim_i > #_e.animation.animations["damaged"].frames
            if(damage_ended) return "idle"
            -- continue damaged state
            return "damaged"
        end,
        _death = function(_e)
            local death_ended = _e.animation.anim_i > #_e.animation.animations["_death"].frames
            -- delete entity
            if death_ended then
                del(entities,_e)
            else
                return "_death"
            end
        end,
        run_left = function(_e)
            -- attack
            if(_e.intention.x) return "attack_left"
            -- keep moving
            if(_e.intention.right) return "run_right"
            if(_e.intention.left) return "run_left"
            -- idle
            return "idle"
        end,
        run_right = function(_e)
            -- attack
            if(_e.intention.x) return "attack_right"
            -- keep moving
            if(_e.intention.right) return "run_right"
            if(_e.intention.left) return "run_left"
            -- idle
            return "idle"
        end,
        attack_left = function(_e)
            local attack_ended = _e.animation.anim_i > #_e.animation.animations["attack_left"].frames
            -- idle
            if(attack_ended) return "idle_left"
            -- keep punching
            return "attack_left"
        end,
        attack_right = function(_e)
            local attack_ended = _e.animation.anim_i > #_e.animation.animations["attack_right"].frames
            -- idle
            if(attack_ended) return "idle"
            -- keep punching
            return "attack_right"
        end,  
    }
    local zombie_hurtboxes = {
        idle = { ox=4, oy=3, w=7, h=12 },
        run_right = { ox=4, oy=3, w=7, h=12 },
        run_left = { ox=4, oy=3, w=7, h=12 },
        attack_right = { ox=4, oy=3, w=7, h=12 },
        attack_left = { ox=4, oy=3, w=7, h=12 },
    }
    local zombie_hitboxes = {
        attack_left = { ox=0, oy=8, w=3, h=4 },
        attack_left = { ox=12, oy=8, w=3, h=4 }
    }
    local new_zombie = new_entity({
        kind = "zombie",
        position = new_position(102,60,16,16,2),
        sprite = new_sprite({x=48,y=48,w=16,h=16}),
        animation = new_animation(zombie_animations,"idle"),
        state = new_state(zombie_states,"idle"),
        intention = new_intention(),
        control = new_control({spd_x = 0.2}),
        -- collider = new_collider(5,3,5,12,{spd_x=0.5}),
        battle = new_battle({},zombie_hurtboxes,{health=100}),
        triggers = {new_trigger(-68,0,140,10, zombie_onplayerspot, 'once')}
    })
    add(entities, new_zombie)
end

function zombie_control(_e)
    -- reset intentions
    _e.intention.right = false
    _e.intention.left = false
    _e.intention.x = false

    local is_attacking = _e.state.current == "attack_right" or _e.state.current == "attack_left"
    local distance = (_e.position.x+8) - (player.position.x+8)
    -- zombies always know where the player is

    if abs(distance) > 7 and not is_attacking then
        -- walk
        local direction = sgn(distance)
        if(direction==-1) _e.intention.right = true
        if(direction==1)  _e.intention.left = true
    else
        -- attack
        _e.intention.x = true
    end
end

-- add controll to zombie when it spots the player
function zombie_onplayerspot(_e,_o)
    if _o.kind=="player" then
        _e.control.control = zombie_control
    end
end