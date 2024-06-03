function spawn_bullet(_x,_dir)
    local bullet_speed = _dir > 0 and 2 or -2
    _x = _dir > 0 and _x+10 or _x-2
    local bullet_hitbox = {
        travel = { ox=0, oy=0, w=2, h=1 },
        hit = { ox=0, oy=0, w=2, h=1 },
    }

    local bullet_states = {
        travel = function(_e)
            return "hit"
        end,
        hit = function(_e)
            return "travel"
            --del(entities,_e)
        end,
    }

    local bullet = new_entity({
        kind="bullet",
        position = new_position(_x,70,2,1),
        sprite = new_sprite({
            x = 8,
            y = 96,
            w = 2,
            h = 1,
            pal_rep = {{10,6}},
        }),
        intention = new_intention(),
        control = new_control({spd_x = bullet_speed, control_func = bullet_control}),
        triggers = {
            new_trigger(0,0,2,1,onbullethit,'once')
        },
        state = new_state(bullet_states,"travel"),
        battle = new_battle(bullet_hitbox,{},{damage=100}),
    })
    add(entities,bullet)
end

function bullet_control(_e)
    _e.position.x += _e.control.spd_x

    -- delete bullet after a certain distance
    if(abs(_e.position.x - player.position.x)>130) del(entities,_e)

end

function onbullethit(_e,_o)
    if _o.kind == "zombie" then
        _e.state.previous = _e.state.current
        _e.state.current = "hit"
        -- del(entities,_e)
    end
end