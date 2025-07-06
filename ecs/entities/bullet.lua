function spawn_bullet(x,d)
    local spd=d*2
    x=d>0 and x+10 or x-2

    local bullet_states = {
        travel = function(e)
            local c = physics_system.collisions[e.id]
            if c then
                for i=1,#c do
                    local ent = get_entity(c[i])
                    if ent.kind=="zombie" then
                        return "hit"
                    end
                end
            end
            return "travel"
        end,
        hit = function(e)
            sfx(14)
            return "_death"
        end,
        _death = function(e)
            del(entities,e)
        end,
    }

    local bullet_hitboxes = {
        hit = {ox=0,oy=0,w=2,h=1}
    }

    add(entities,new_entity({
        kind="bullet",
        code="bulle",
        position=new_position(x,68,2,1),
        sprite=new_sprite({sprites={{x=8,y=96,w=2,h=1,ox=0,oy=0,fx=false,fy=false}},pal_rep={{10,6}}}),
        intention=new_intention(),
        control=new_control({spd_x=spd,control_func=bullet_control}),
        state=new_state(bullet_states,"travel"),
        battle=new_battle(bullet_hitboxes,{},{health=100,damage=70}),
        collider=new_collider(0,0,2,1,{is_solid=false}),
    }))
end

function bullet_control(e)
    e.position.x += e.control.spd_x
    if abs(e.position.x-player.position.x)>130 then
        e.state.previous=e.state.current
        e.state.current="_death"
    end
end
