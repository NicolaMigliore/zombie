function spawn_zombie(_x)
    -- #region zombie aniamtion
    local zombie_animations = {}
    local ac = new_animation(zombie_animations,"idle")
    ac.add_anim_new('idle',str2frames('16,48|32,48|32,48|48,48'),.2,true)
    ac.add_anim_new('run',str2frames('64,48|80,48|96,48|112,48'),.2,true)
    ac.add_anim_new('_damaged',str2frames('32,48|32,48|48,48'),.2,false)
    ac.add_anim_new('_death',{{0,0,8,8}},.5,false)
    local atk='0,64|0,64|0,64|0,64|16,64|32,64|48,64|48,64'
    ac.add_anim_new('attack_right',str2frames(atk),.06,false)
    ac.add_anim_new('attack_left',str2frames(atk),.06,false)

    -- #region zombie state
    local zombie_states = {
        idle = function(_e)
            -- move zombie
            if(_e.inte.left) _e.position.dx=-1 return "run"
            if(_e.inte.right) _e.position.dx=1 return "run"

            -- attack
            if(_e.inte.x) sfx(14) return _e.position.dx > 0 and "attack_right" or "attack_left"

            -- idle
            return "idle"
        end,
        _damaged = function(_e)
            -- idle
            if(_e.animation.prog()>.9) return "idle"
            -- continue damaged state
            return "_damaged"
        end,
        _death = function(_e)
            -- remove collider, control and intes
            _e.collider = nil
            _e.inte.left,_e.inte.left = false,false

            -- delete entity
            if _e.animation.prog()>.9 then
                del(entities,_e)
            else
                return "_death"
            end
        end,
        run = function(_e)
            if _e.position.dx > 0 then
                _e.sprite.fx = false 
            else
                _e.sprite.fx = true
            end

            if(_e.inte.x) sfx(14) return _e.position.dx > 0 and "attack_right" or "attack_left"
            if(_e.inte.right) _e.position.dx = 1 return "run"
            if(_e.inte.left) _e.position.dx = -1 return "run"
            return "idle"
        end,
        attack_left = function(_e)
            local attack_ended = _e.animation.prog()>=1
            if(attack_ended) return "idle"
            return "attack_left"
        end,
        attack_right = function(_e)
            local attack_ended = _e.animation.prog()>=1
            if(attack_ended) return "idle"
            return "attack_right"
        end,  
    }
    -- #region zombie battle
    local z_hb = { ox=-4, oy=-12, w=7, h=12 }
    local zombie_hurtboxes = {
        idle = z_hb,
        run = z_hb,
        attack_right = z_hb,
        attack_left = z_hb,
    }
    local zombie_hitboxes = {
        attack_left = { ox=-14, oy=-8, w=12, h=4 },
        attack_right = { ox=2, oy=-8, w=12, h=4 }
    }
    local oz = 2+rnd(5)
    -- #region zombie entity
    local new_zombie = new_entity({
        kind = "zombie",
        code = "zombi",
        position = new_position(_x,70+oz,16,16,oz),
        sprite = new_sprite({x=48,y=48,w=16,h=16}),
        animation = ac,
        state = new_state(zombie_states,"idle"),
        inte = new_inte(),
        control = new_control({spd_x = .2+rnd(.15), control_func=zombie_control}),
        collider = new_collider(-4,-12,7,12,{is_solid=false}),
        battle = new_battle(zombie_hitboxes,zombie_hurtboxes,{health=40, damage=5}),
    })
    add(entities, new_zombie)
end

function zombie_control(_e)
    -- reset intes
    _e.inte.right = false
    _e.inte.left = false
    _e.inte.x = false

    local is_attacking = _e.state.curr == "attack_right" or _e.state.curr == "attack_left"
    local is_damaged = _e.state.curr == "_damaged" or _e.state.curr == "_death"
    local distance = (_e.position.x) - (player.position.x)

    if abs(distance) > 7 and not is_attacking and not is_damaged then
        -- walk
        local direction = sgn(distance)
        if(direction==-1) _e.inte.right = true
        if(direction==1)  _e.inte.left = true
    else
        -- attack
        _e.inte.x = true
    end
end