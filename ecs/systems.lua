-- #region graphics system
-- handles game graphics
function foreach_entity(_func)
    for e in all(entities) do
        _func(e)
    end
end
function create_graphics_system()
    return {
        update = function (options)
            if(log_systems)log(time().." - running graphics system")
            _bg_color = options.bg_color or 12
            cls(_bg_color)

            -- draw level
            if(options.draw_level) options.draw_level()
            
            --#region draw entities
            sort(entities, z_comparison)
            foreach_entity(function(e)
                local cur_pos = e.position
                if cur_pos != nil then
                    -- render entity
                    if e.draw then
                        e.draw(e)
                    elseif e.sprite then
                        local p = e.position
                        local f = e.sprite.sprites
                        if f then
                            local x,y=p.x,p.y
                            if e.battle and e.battle.hit_timer>0 then
                                for i=0,15 do
                                    pal(i, 7)
                                end
                                ssprc(f[1],f[2],f[3],f[4],x,y,p.w*.9,p.h*.7,e.sprite.fx,false,'cb')
                                pal()
                            else
                                ssprc(f[1],f[2],f[3],f[4],x,y,p.w,p.h,e.sprite.fx,false,'cb',1)
                            end
                        end
                    end

                    -- render colliders
                    if e.collider and (e.collider.show or show_colliders) then
                        local color = e.collider.has_collision and 8 or 7
                        rect(
                            cur_pos.x + e.collider.ox,
                            cur_pos.y + e.collider.oy,
                            cur_pos.x + e.collider.ox + e.collider.w,
                            cur_pos.y + e.collider.oy + e.collider.h,
                            color
                        )
                    end

                    -- render triggers
                    if e.triggers and #e.triggers > 0 and show_colliders then
                        for trigger in all(e.triggers) do
                            local color = 10
                            rect(
                                cur_pos.x + trigger.ox,
                                cur_pos.y + trigger.oy,
                                cur_pos.x + trigger.ox + trigger.w,
                                cur_pos.y + trigger.oy + trigger.h,
                                color
                            )
                        end
                    end

                    -- render hitboxes and hutboxes
                    if e.battle and e.state and show_hitboxes then
                        -- render hitboxes
                        if e.battle.hitboxes then
                            local hitbox = e.battle.hitboxes[e.state.curr]
                            if hitbox and e.battle.cd_time==0 then 
                                local hitbox_active = false
                                for f in all(hitbox.active_frames) do
                                    if(e.animation.i==f)hitbox_active=true
                                end
                                if hitbox_active then
                                    rect(
                                        cur_pos.x + hitbox.ox,
                                        cur_pos.y + hitbox.oy,
                                        cur_pos.x + hitbox.ox + hitbox.w,
                                        cur_pos.y + hitbox.oy + hitbox.h,
                                        2
                                    )
                                end
                            end
                        end

                        if e.battle.hurtboxes then
                            local hurtbox = e.battle.hurtboxes[e.state.curr]
                            if hurtbox then
                                rect(
                                    cur_pos.x + hurtbox.ox,
                                    cur_pos.y + hurtbox.oy,
                                    cur_pos.x + hurtbox.ox + hurtbox.w,
                                    cur_pos.y + hurtbox.oy + hurtbox.h,
                                    14
                                )
                            end
                        end
                    end

                    -- render interactions
                    -- interactions
                    if e.kind == "player" then
                        local cel_x = flr((cur_pos.x)/8)
                        if fget(mget(cel_x,8),0) then
                            -- spr(209,cel_x*8,56)
                            print("🅾️",cel_x*8,56,9)
                        end
                    end
                end
            end)

            --#region draw particles
            for p in all(particles) do
                if p.kind == "pixel" or p.kind == "gravity_pixel" or p.kid == "ash" then
                    pset(p.position.x,p.position.y,p.color)
                elseif p.kind == "smoke" then
                    circfill(p.position.x,p.position.y,p.position.w,p.color)
                elseif p.kind == "sprite" then
                    spr(p.sprite,p.position.x,p.position.y,p.position.w,p.position.h)
                elseif p.kind == "smear" then
                    local a,cx,cy=p.age/p.max_age,0,0
                    local px,py,w,h=p.position.x,p.position.y,p.position.w,p.position.h
                    local x1,x2=p.dx>=0 and px-w or px, p.dx>=0 and px or px+w
                    local cx1=(p.dx>=0 and x1+(x2-x1+5)/2 or px-5)-gamecamera.position.x-flr(shake_x)
                    local y1,y2=flr(py-h/2),flr(py+h/2)
                    clip(flr(cx1),flr(y1-1),flr(x2-x1)-1,20)
                    for i=0,3 do oval(flr(x1)+i,y1,flr(x2)+i,y2,p.color) end
                    clip()
                end
            end
            
            -- shake camera
            if(intensity>0) shake()
        end
    }
end

-- #region animation system
-- handles entity animations
function create_animation_system()
    return {
        update = function ()
            if(log_systems)log(time().." - running animation system")
            foreach_entity(function(e)
                local a = e.animation
                if e.sprite and e.state and a then
                    if a.animations[e.state.curr] then
                        -- if state has changed update current animation
                        if e.state.curr != e.state.prev then
                            a.active_anim = e.state.curr
                            a.i = 1
                            a.frame_t = 0
                        end

                        -- progress animation
                        local ca = a.animations[a.active_anim]
                        a.frame_t += 1
                        if a.frame_t >= ca.speed * 60 then
                            a.i += 1
                            a.frame_t = 0
                        end

                        if a.i > #ca.frames then
                            if ca.loop then
                                a.i = 1
                            else
                                a.i = #ca.frames + 1 -- Allow to exceed frame count for end check
                            end
                        end
                        
                        -- set sprite
                        local fi = flr(a.i)
                        if fi > #ca.frames then
                            fi = #ca.frames
                        end

                        e.sprite.sprites = ca.frames[fi]

                        -- override flip based on animation
                        if(ca.fx) e.sprite.fx = ca.fx
                    end
                end
            end)
        end
    }
end

-- #region control system
-- handles entity controls
function create_control_system()
    return {
        update = function()
            if(log_systems)log(time().." - running constrol system")
            foreach_entity(function(e)
                -- update entity movement inte
                if e.control and e.control.fn then
                    e.control.fn(e)
                end
            end)
        end
    }
end

-- #region physics system
-- handles entity movement
function create_physics_system()
    local ps = {
        collisions = {}
    }
    ps.update = function()
        if(log_systems)log(time().." - running physiscs system")
        --reset collisions
        ps.collisions = {}
        foreach_entity(function(e)
            -- apply gravity
            -- *does not apply...*

            -- update entity movement inte
            if e.position and e.inte then
                local spd_x = e.control and e.control.spd_x or 0.5
                local dx = 0
                local can_move_x = true
                local new_x = e.position.x

                -- left movement
                if e.inte.left then
                    dx = -1
                end
                -- right movement
                if e.inte.right then
                    dx = 1
                end
                new_x += dx * spd_x

                -- check for collisions with other entities
                if e.collider and e.collider.can_collide then
                    for o in all(entities) do
                        if o != e and o.collider and o.collider.can_collide == true then
                            local o_bb = o.collider.get_bounding_box(o.position)
                            local e_bb = e.collider.get_bounding_box(e.position)

                            e.collider.has_collision = false

                            -- check horizontal collision
                            if colliding(
                                new_x + e.collider.ox, e_bb.y, e_bb.w, e_bb.h,
                                o_bb.x, o_bb.y, o_bb.w, o_bb.h
                            ) then 
                                e.collider.has_collision = true

                                -- add entry to collisoin dictionary
                                if(ps.collisions[e.id] == nil) ps.collisions[e.id] = {}
                                add(ps.collisions[e.id], o.id)

                                -- if both colliders are solid don't move
                                if(e.collider.is_solid and o.collider.is_solid) can_move_x = false
                            end
                        end
                    end
                end
                -- update entity position
                if (can_move_x) e.position.x = new_x
            end
        end)
    end
    return ps
end

-- #region trigger system
function create_trigger_system()
    return {
        update = function()
            if(log_systems)log(time().." - running trigger system")
            foreach_entity(function(e)
                if e.position and e.triggers and #e.triggers > 0 then
                    for t in all(e.triggers) do
                        -- check for collisions with other entities
                        local triggered = false
                        for o in all(entities) do
                            if e != o and o.position and o.collider then
                                local o_bb = o.collider.get_bounding_box(o.position)
                                if colliding(
                                    e.position.x + t.ox, e.position.y + t.oy, t.w, t.h,
                                    o_bb.x, o_bb.y, o_bb.w, o_bb.h
                                ) then
                                    triggered = true
                                    if t.kind == "once" then
                                        t.ontrigger(e,o)
                                        --t = nil
                                        del(e.triggers,t)
                                        break
                                    elseif t.kind == "always" then
                                        t.ontrigger(e,o)
                                    elseif t.kind == "wait"
                                    and t.active == false then
                                        t.ontrigger(e,o)
                                        t.active = true
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            if (triggered == false) e.trigger.active = false
        end
    }
end

-- #region state system
function create_state_system()
    return {
        update = function()
            if(log_systems)log(time().." - running state system")
            foreach_entity(function(e)
                if e.state and e.state.rules then
                    e.state.prev = e.state.curr
                    local state_rule = e.state.rules[e.state.curr]
                    if state_rule then
                        e.state.curr = state_rule(e)
                    end
                end
            end)
        end
    }
end

-- #region battle system
function create_battle_system()
    return {
        update = function()
            if(log_systems)log(time().." - running battle system")
            -- check all entities with hitboxes
            foreach_entity(function(e)
                if e.battle and e.state and e.position then
                    -- advance attack hit_timer
                    if(e.battle.hit_timer > 0) e.battle.hit_timer -= 1
                    if(e.battle.cd_time > 0) e.battle.cd_time -= 1
                    
                    -- attack
                    local hitbox = e.battle.hitboxes[e.state.curr]
                    if hitbox and e.battle.cd_time==0 then
                        local hitbox_active = false
                        for f in all(hitbox.active_frames) do
                            if(e.animation.i==f)hitbox_active=true
                        end
                        if hitbox_active then
                            -- check all entities with hurboxes
                            for o in all(entities) do
                                if o!=e and o.battle and o.state and o.position then
                                    local hurtbox = o.battle.hurtboxes[o.state.curr]
                                    if hurtbox and box_collide(e.battle.get_box(e.position,hitbox),o.battle.get_box(o.position,hurtbox)) then
                                        o.battle.health -= e.battle.damage
                                        o.state.prev = o.state.curr
                                        o.state.curr = "_damaged"
                                        spawn_shatter(o.position.x,o.position.y-8,{8,8,2},{})

                                        local impact_x,impact_y=e.position.x+8*e.position.dx,e.position.y-8+rnd(3)
                                        add(particles,new_particle(
                                            "smear",
                                            new_position(impact_x,impact_y,10,5),
                                            e.position.dx,
                                            0,
                                            10+rnd(10),
                                            {7},
                                            10+rnd(10),
                                            {}
                                        ))
                                        for i=1,3+rnd(2)do
                                            add(particles,new_particle(
                                                "smoke",
                                                new_position(impact_x,impact_y,max_size,0),
                                                e.position.dx*(rnd(1)+1),
                                                rnd()-.5,
                                                rnd(10)+30,
                                                {7,7,6,5},
                                                0.5+rnd(2),
                                                {}
                                            ))                                         
                                        end

                                        o.position.x += (e.battle.knock+rnd(2)) * e.position.dx intensity+=shake_ctrl
                                        if o.battle.health<1 then
                                            o.state.curr = "_death"
                                            -- for d in all({{0,1,.1},{.5,1,.1},{.25,2,.3}}) do
                                            --     spawn_smoke(
                                            --         o.position.x,
                                            --         o.position.y-2,
                                            --         {5,7,7},
                                            --         { angle = d[1], max_size = d[2]+rnd(2), max_age = 90*rnd(), spd = d[3] }
                                            --     )
                                            -- end
                                        end
                                        o.battle.hit_timer = 15
                                        if(e.state.curr=='punch_right_3'or e.state.curr=='punch_left_3')_skip_frames=15
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    }
end

-- #region particle system
-- handles particle animations
function create_particle_system()
    local ps = {}
    ps.update = function()
        for p in all(particles) do
            p.age+=1
            if (p.age >= p.max_age) del(particles,p)

            -- age of particle from 0 to 1
            local age_perc = p.age/p.max_age

            -- change color
            if #p.colors > 1 then
                -- color index based on age
                local color_i = flr(age_perc * #p.colors)+1
                p.color=p.colors[color_i]
            end

            -- apply gravity
            if p.has_gravity then
                p.dy+=0.05
            end

            --shrink (based on position.w)
            if p.kind=="smoke" or p.kind=='smear' then
                p.position.w=(1-age_perc)*p.max_size
                p.position.h=(1-age_perc)*p.max_size
            end

            if p.kind=='smear' then
                p.position.w=(1-age_perc)*p.max_size
            end

            --move particle
            p.position.x+=p.dx
            p.position.y+=p.dy
        end
    end
    return ps
end

function z_comparison(_a,_b)
    return _a.position.z > _b.position.z
end

function box_collide(b1,b2)
    return colliding(b1.x,b1.y,b1.w,b1.h,b2.x,b2.y,b2.w,b2.h)
end

function colliding(x1,y1,w1,h1,x2,y2,w2,h2)
    return flr(x1+w1) > flr(x2) and flr(x1) < flr(x2+w2)
        and flr(y1+h1) > flr(y2) and flr(y1) < flr(y2+h2)
end