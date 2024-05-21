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
    }
    local zombie_states = {
        idle = function(_e)
            local stopped_moving = (not _e.intention.right and _e.state.current == 'run_right') or (not _e.intention.left and _e.state.current == 'run_left')
            local damage_ended = _e.state.current == "damaged" and _e.animation.anim_i > #_e.animation.animations[_e.animation.active_anim].frames
            return stopped_moving or damage_ended
        end,
        deletion = function(_e)
            local death_ended = _e.state.current == "_death" and _e.animation.anim_i > #_e.animation.animations[_e.animation.active_anim].frames
            if(death_ended) del(entities,_e)
        end,
        run_left = function(_e)
            local entry_states_conditions = {
                idle = true,
                damaged = _e.animation.anim_i > #_e.animation.animations[_e.animation.active_anim].frames,
                attack_left = _e.animation.anim_i > #_e.animation.animations[_e.animation.active_anim].frames,
            }
            return _e.intention.left and entry_states_conditions[_e.state.current]
        end,
        run_right = function(_e)
            -- todo: copy from run_left
            -- local entry_states_conditions = {
            --     idle = true,
            --     damaged = _e.animation.anim_i > #_e.animation.animations[_e.animation.active_anim].frames,
            --     attack_left = _e.animation.anim_i > #_e.animation.animations[_e.animation.active_anim].frames,
            -- }
            -- return _e.intention.left and entry_states_conditions[_e.state.current]
        end,
    }
    local zombie_hurtboxes = {
        idle = { ox=4, oy=3, w=7, h=12 },
        run_right = { ox=4, oy=3, w=7, h=12 },
        run_left = { ox=4, oy=3, w=7, h=12 },
        attack_right = { ox=4, oy=3, w=7, h=12 },
        attack_left = { ox=4, oy=3, w=7, h=12 },
    }
    local new_zombie = new_entity({
        kind = "zombie",
        position = new_position(102,60,16,16,2),
        sprite = new_sprite({x=48,y=48,w=16,h=16}),
        animation = new_animation(zombie_animations,"idle"),
        state = new_state(zombie_states,"idle"),
        intention = new_intention(),
        control = new_control({spd_x = 0.2}),
        collider = new_collider(5,3,5,12,{spd_x=0.5}),
        battle = new_battle({},zombie_hurtboxes,{health=100}),
        triggers = {new_trigger(-68,0,140,10, zombie_ontrigger, 'always')}
    })
    add(entities, new_zombie)
end

function zombie_ontrigger(_e,_o)
    if _o.kind=="player" then
        local distance = _e.position.x - _o.position.x
        if abs(distance) > 2 then
            -- _e.position.x -= distance / 500
            -- local new_val = distance>0 and "run_left" or "run_right"
            local direction = sgn(distance)
            if(direction==-1) _e.intention.right = true _e.intention.left = false
            if(direction==1) _e.intention.right = false _e.intention.left = true
            -- log(new_val)
            -- _e.state.current = new_val
        else
            -- attack
        end
    end
end