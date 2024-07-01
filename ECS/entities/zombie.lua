function spawn_zombie(_x)
    -- #region zombie aniamtion
    local zombie_animations = {
        _damaged = {
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
        },
    }
    local animation_comp = new_animation(zombie_animations,"idle")
    animation_comp.add_animation("idle","48,48,16,16|48,48,16,16|48,48,16,16|64,48,16,16|80,48,16,16|96,48,16,16|48,48,16,16",0.1,true)
    animation_comp.add_animation("_death","0,64,16,16|48,80,16,16|64,80,16,16|80,80,16,16|96,80,16,16|112,80,16,16|112,80,16,16|112,80,16,16|112,80,16,16|112,80,16,16|112,80,16,16",0.1)
    animation_comp.add_animation("run","112,48,16,16|0,64,16,16|16,64,16,16|32,64,16,16|48,64,16,16|64,64,16,16",0.1,true)
    animation_comp.add_animation("attack_right","48,48,16,16|80,64,16,16|80,64,16,16|96,64,16,16|96,64,16,16|112,64,16,16|0,80,16,16|16,80,16,16|32,80,16,16|32,80,16,16|32,80,16,16|32,80,16,16",0.5)
    animation_comp.add_animation("attack_left","48,48,16,16|80,64,16,16|80,64,16,16|96,64,16,16|96,64,16,16|112,64,16,16|0,80,16,16|16,80,16,16|32,80,16,16|32,80,16,16|32,80,16,16|32,80,16,16",0.5)

    -- #region zombie state
    local zombie_states = {
        idle = function(_e)
            -- move zombie
            if(_e.intention.left) _e.position.dx=-1 return "run"
            if(_e.intention.right) _e.position.dx=1 return "run"

            -- attack
            if(_e.intention.x) sfx(14) return _e.position.dx > 0 and "attack_right" or "attack_left"

            -- idle
            return "idle"
        end,
        _damaged = function(_e)
            -- idle
            local damage_ended = check_animation_ended(_e,"_damaged")
            if(damage_ended) return "idle"
            -- continue damaged state
            return "_damaged"
        end,
        _death = function(_e)
            -- remove collider, control and intentions
            _e.collider = nil
            _e.control.control = nil
            _e.intention.left,_e.intention.left = false,false

            local death_ended = check_animation_ended(_e,"_death")

            -- delete entity
            if death_ended then
                del(entities,_e)
            else
                return "_death"
            end
        end,
        run = function(_e)
            if _e.position.dx > 0 then
                -- looking right
                _e.sprite.flip_x = false 
            else
                -- looking left
                _e.sprite.flip_x = true
            end

            -- attack
            if(_e.intention.x) sfx(14) return _e.position.dx > 0 and "attack_right" or "attack_left"
            -- keep moving
            if(_e.intention.right) _e.position.dx = 1 return "run"
            if(_e.intention.left) _e.position.dx = -1 return "run"
            -- idle
            return "idle"
        end,
        attack_left = function(_e)
            local attack_ended = check_animation_ended(_e,"attack_left")
            -- idle
            if(attack_ended) return "idle"
            -- keep punching
            return "attack_left"
        end,
        attack_right = function(_e)
            local attack_ended = check_animation_ended(_e,"attack_right")
            -- idle
            if(attack_ended) return "idle"
            -- keep punching
            return "attack_right"
        end,  
    }
    -- #region zombie battle
    local zombie_hurtboxes = {
        idle = { ox=4, oy=3, w=7, h=12 },
        run = { ox=4, oy=3, w=7, h=12 },
        attack_right = { ox=4, oy=3, w=7, h=12 },
        attack_left = { ox=4, oy=3, w=7, h=12 },
    }
    local zombie_hitboxes = {
        attack_left = { ox=0, oy=8, w=3, h=4 },
        attack_right = { ox=12, oy=8, w=3, h=4 }
    }
    -- #region zombie entity
    local new_zombie = new_entity({
        kind = "zombie",
        code = "zombi",
        position = new_position(_x,60,16,16,2),
        sprite = new_sprite({x=48,y=48,w=16,h=16}),
        animation = animation_comp,
        state = new_state(zombie_states,"idle"),
        intention = new_intention(),
        control = new_control({spd_x = 0.2, control_func=zombie_control}),
        collider = new_collider(4,3,7,12,{is_solid=false}),
        battle = new_battle(zombie_hitboxes,zombie_hurtboxes,{health=100, damage=5}),
    })
    add(entities, new_zombie)
end

function zombie_control(_e)
    -- reset intentions
    _e.intention.right = false
    _e.intention.left = false
    _e.intention.x = false

    local is_attacking = _e.state.current == "attack_right" or _e.state.current == "attack_left"
    local is_damaged = _e.state.current == "_damaged" or _e.state.current == "_death"
    local distance = (_e.position.x+8) - (player.position.x+8)
    -- zombies always know where the player is

    if abs(distance) > 7 and not is_attacking and not is_damaged then
        -- walk
        local direction = sgn(distance)
        if(direction==-1) _e.intention.right = true
        if(direction==1)  _e.intention.left = true
    else
        -- attack
        _e.intention.x = true
    end
end