function spawn_zombie(_x)
    -- #region zombie aniamtion
    local zombie_animations = {}
    local animation_comp = new_animation(zombie_animations,"idle")
    animation_comp.add_anim("idle","0,32,10,10,0,-12@50,32,8,4,1,-3|0,32,10,10,0,-13@58,32,8,5,1,-4|0,32,10,10,0,-13@66,32,8,5,1,-4|40,32,10,10,0,-12@50,32,8,4,1,-3",.2,true)
    animation_comp.add_anim("_damaged","0,32,10,10,0,-13@66,32,8,5,1,-4^2:7,3:7,5:7,10:5,8:5|0,32,10,10,0,-13@66,32,8,5,1,-4|10,42,10,9,0,-13@88,32,7,5,3,-4^2:7,3:7,5:7,10:5,8:5|10,42,10,9,0,-13@88,32,7,5,3,-4|40,32,10,10,0,-12@50,32,8,4,1,-3^2:7,3:7,5:7,10:5,8:5|40,32,10,10,0,-12@50,32,8,4,1,-3",.1,true)
    animation_comp.add_anim("_death","0,32,10,10,3,-14@57,37,7,5,5,-4|0,32,10,10,3,-13@74,32,7,5,4,-4|30,42,10,10,3,-12@74,32,7,4,4,-3|49,42,12,11,5,-10|61,42,15,6,4,-4|61,42,15,5,4,-4|61,42,15,4,4,-3|61,42,15,3,4,-2",.15)
    animation_comp.add_anim("run","50,37,7,4,2,-3@0,32,10,10,0,-13|57,37,7,5,2,-4@0,32,10,10,0,-14|64,37,6,4,2,-3@30,32,10,10,0,-12|70,37,7,4,2,-3@0,32,10,10,0,-13|77,37,7,5,2,-4@20,32,10,10,0,-14|64,37,6,4,2,-3@10,32,10,10,0,-12",.25,true)

    animation_comp.add_anim("attack_right","81,32,7,5,5,-4@0,32,10,9,3,-13|88,32,7,5,5,-4@0,42,10,9,2,-13|95,32,8,4,4,-3@10,42,10,9,2,-12|84,37,10,6,7,-5@40,42,9,9,12,-12@103,33,13,12,13,-15|84,37,10,6,7,-5@40,42,9,9,12,-12@116,33,9,9,17,-14|84,37,10,6,7,-5@40,42,9,9,12,-12@103,23,5,9,22,-12",.1)
    animation_comp.add_anim("attack_left","81,32,7,5,5,-4@0,32,10,9,3,-13|88,32,7,5,5,-4@0,42,10,9,2,-13|95,32,8,4,4,-3@10,42,10,9,2,-12|84,37,10,6,7,-5@40,42,9,9,12,-12@103,33,13,12,13,-15|84,37,10,6,7,-5@40,42,9,9,12,-12@116,33,9,9,17,-14|84,37,10,6,7,-5@40,42,9,9,12,-12@103,23,5,9,22,-12",.1)

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
            if(_e.animation.progress_percentage()>.9) return "idle"
            -- continue damaged state
            return "_damaged"
        end,
        _death = function(_e)
            -- remove collider, control and intes
            _e.collider = nil
            -- _e.control.control = nil
            _e.inte.left,_e.inte.left = false,false

            -- delete entity
            if _e.animation.progress_percentage()>.9 then
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
            if(_e.inte.x) sfx(14) return _e.position.dx > 0 and "attack_right" or "attack_left"
            -- keep moving
            if(_e.inte.right) _e.position.dx = 1 return "run"
            if(_e.inte.left) _e.position.dx = -1 return "run"
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
        animation = animation_comp,
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

    local is_attacking = _e.state.current == "attack_right" or _e.state.current == "attack_left"
    local is_damaged = _e.state.current == "_damaged" or _e.state.current == "_death"
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