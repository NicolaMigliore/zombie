-- create new bullet
function spawn_bullet(_x,_dir)
    -- set bullet position and speed
    local bullet_speed = _dir > 0 and 2 or -2
    _x = _dir > 0 and _x+10 or _x-2

    local bullet_states = {
        travel = function(_e)
            -- check for collision with zombie
            local bullet_collisions = physics_system.collisions[_e.id]
            if bullet_collisions != nil then
                local oi = 1
                local collided_with_zombie = false
                while oi <= #bullet_collisions and collided_with_zombie == false do
                    local ent = get_entity(bullet_collisions[oi])
                    if(ent.kind=="zombie") collided_with_zombie = true return "hit"
                    oi += 1
                end
            end
            -- keep traveling
            return "travel"
        end,
        hit = function(_e)
            sfx(14)
            return "_death"
        end,
        _death = function(_e)
            del(entities,_e)
        end,
    }

    local bullet_hitboxes = {
        hit = { ox=0, oy=0, w=2, h=1 }
    }

    -- #region bullet entity
    local new_bullet = new_entity({
        kind = "bullet",
        code = "bulle",
        position = new_position(_x,70,2,1),
        sprite = new_sprite({x=8,y=96,w=2,h=1,pal_rep={{10,6}},}),
        intention = new_intention(),
        control = new_control({spd_x = bullet_speed, control_func = bullet_control}),
        state = new_state(bullet_states, "travel"),
        battle = new_battle(bullet_hitboxes,{},{health=100, damage=70}),
        collider = new_collider(0,0,2,1,{is_solid=false}),
    })
    add(entities, new_bullet)
end

-- control bullet movement
function bullet_control(_e)
    -- move bullet
    _e.position.x += _e.control.spd_x

    -- delete bullet after a certain distance
    if(abs(_e.position.x - player.position.x)>130) _e.state.previous = _e.state.current _e.state.current = "_death"
end