-- #region graphics system
-- handles game graphics
function create_graphics_system()
    return {
        update = function (options)
            if(log_systems)log(time().." - running graphics system")
            _bg_color = options.bg_color or 12
            cls(_bg_color)

            -- draw level
            if(options.draw_level) options.draw_level()
            
            -- draw entities
            sort(entities, z_comparison)
            for e in all(entities) do
                local cur_pos = e.position
                -- render entity
                if e.sprite and cur_pos then
                    local cur_sprite= e.sprite.sprite
                    local pal_rep = e.sprite.sprite.pal_rep
                    if pal_rep and #pal_rep > 0 then
                        for rep in all(pal_rep) do
                            pal(rep[1],rep[2])
                        end
                    end
                    sspr(
                        cur_sprite.x,
                        cur_sprite.y,
                        cur_sprite.w,
                        cur_sprite.h,
                        cur_pos.x,
                        cur_pos.y,
                        cur_pos.w,
                        cur_pos.h,
                        e.sprite.flip_x,
                        e.sprite.flip_y
                    )
                    pal()
                end

                -- render colliders
                if e.collider and (e.collider.show or show_colliders) then
                    local color = e.collider.has_collision and 8 or 7
                    rect(
                        e.position.x + e.collider.ox,
                        e.position.y + e.collider.oy,
                        e.position.x + e.collider.ox + e.collider.w,
                        e.position.y + e.collider.oy + e.collider.h,
                        color
                    )
                end

                -- render triggers
                if e.triggers and #e.triggers > 0 and show_colliders then
                    for trigger in all(e.triggers) do
                        local color = 10
                        rect(
                            e.position.x + trigger.ox,
                            e.position.y + trigger.oy,
                            e.position.x + trigger.ox + trigger.w,
                            e.position.y + trigger.oy + trigger.h,
                            color
                        )
                    end
                end

                -- render hitboxes and hutboxes
                if e.battle and e.position and e.state and show_hitboxes then
                    -- render hitboxes
                    if e.battle.hitboxes then
                        local hitbox = e.battle.hitboxes[e.state.current]
                        if hitbox then 
                            rect(
                                e.position.x + hitbox.ox,
                                e.position.y + hitbox.oy,
                                e.position.x + hitbox.ox + hitbox.w,
                                e.position.y + hitbox.oy + hitbox.h,
                                2
                            )
                        end
                    end

                    if e.battle.hurtboxes then
                        local hurtbox = e.battle.hurtboxes[e.state.current]
                        if hurtbox then
                            rect(
                                e.position.x + hurtbox.ox,
                                e.position.y + hurtbox.oy,
                                e.position.x + hurtbox.ox + hurtbox.w,
                                e.position.y + hurtbox.oy + hurtbox.h,
                                14
                            )
                        end
                    end
                end

                -- render interactions
                -- interactions
                if e.kind == "player" then
                    local cel_x = flr((e.position.x+8)/8)
                    if fget(mget(cel_x,8),0) then
                        -- spr(209,cel_x*8,56)
                        print("🅾️",cel_x*8,56,9)
                    end
                end
            end

            -- draw particles
            for p in all(particles) do
                if p.kind == "pixel" or p.kind == "gravity_pixel" or p.kid == "ash" then
                    pset(p.position.x,p.position.y,p.color)
                elseif p.kind == "smoke" then
                    circfill(p.position.x,p.position.y,p.position.w,p.color)
                elseif p.kind == "sprite" then
                    spr(p.sprite,p.position.x,p.position.y,p.position.w,p.position.h)
                end
            end
        end
    }
end

-- #region animation system
-- handles entity animations
function create_animation_system()
    return {
        update = function ()
            if(log_systems)log(time().." - running animation system")
            for e in all(entities) do
                local anim = e.animation
                if e.sprite and e.state and anim then
                    if anim.animations[e.state.current] then
                        -- if state has changed update current animation
                        if e.state.current != e.state.previous then
                            anim.active_anim = e.state.current
                            anim.anim_i = 1
                        end

                        -- progress animation
                        local cur_animation = anim.animations[anim.active_anim]
                        if anim.anim_i < #cur_animation.frames + 1 - cur_animation.speed then
                            anim.anim_i += cur_animation.speed
                        else
                            if cur_animation.loop then
                                anim.anim_i = 1
                            -- elseif cur_animation.turn_to_idle then
                            --     anim.active_anim = "idle"
                            --     anim.anim_i = 1
                            end
                        end
                        
                        -- set sprite
                        local new_frame = cur_animation.frames[flr(anim.anim_i)]
                        e.sprite.sprite = new_frame

                        -- override flip based on animation
                        if(cur_animation.flip_x) e.sprite.flip_x = cur_animation.flip_x
                    end
                end
            end
        end
    }
end

-- #region control system
-- handles entity controls
function create_control_system()
    return {
        update = function()
            if(log_systems)log(time().." - running constrol system")
            for e in all(entities) do
                -- update entity movement intention
                if e.control and e.control.control then
                    e.control.control(e)
                end
            end
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
        for e in all(entities) do
            -- apply gravity
            -- *does not apply...*

            -- update entity movement intention
            if e.position and e.intention then
                local spd_x = e.control and e.control.spd_x or 0.5
                local direction_x = 0
                local can_move_x = true
                local new_x = e.position.x

                -- left movement
                if e.intention.left then
                    -- new_x -= 1 * spd_x
                    direction_x = -1
                end
                -- right movement
                if e.intention.right then
                    -- new_x += 1 * spd_x
                    direction_x = 1
                end
                new_x += direction_x * spd_x

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
        end
    end
    return ps
end

-- #region trigger system
function create_trigger_system()
    return {
        update = function()
            if(log_systems)log(time().." - running trigger system")
            for e in all(entities) do
                if e.position and e.triggers and #e.triggers > 0 then
                    for trigger in all(e.triggers) do
                        -- check for collisions with other entities
                        local triggered = false
                        for o in all(entities) do
                            if e != o and o.position and o.collider then
                                local o_bb = o.collider.get_bounding_box(o.position)
                                local has_collision = colliding(
                                    e.position.x + trigger.ox, e.position.y + trigger.oy, trigger.w, trigger.h,
                                    o_bb.x, o_bb.y, o_bb.w, o_bb.h
                                )
                                if has_collision then
                                    triggered = true
                                    if trigger.kind == "once" then
                                        trigger.ontrigger(e,o)
                                        --trigger = nil
                                        del(e.triggers,trigger)
                                        break
                                    elseif trigger.kind == "always" then
                                        trigger.ontrigger(e,o)
                                    elseif trigger.kind == "wait"
                                    and trigger.active == false then
                                        trigger.ontrigger(e,o)
                                        trigger.active = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if (triggered == false) e.trigger.active = false
        end
    }
end

-- #region state system
function create_state_system()
    return {
        update = function()
            if(log_systems)log(time().." - running state system")
            for e in all(entities) do
                if e.state and e.state.rules then
                    -- if(e.state.previous!=e.state.current)log(e.kind..":"..e.state.previous.."->"..e.state.current)
                    e.state.previous = e.state.current
                    local state_rule = e.state.rules[e.state.current]
                    if state_rule then
                        e.state.current = state_rule(e)
                    end
                end
            end
        end
    }
end

-- #region battle system
function create_battle_system()
    return {
        update = function()
            if(log_systems)log(time().." - running battle system")
            -- check all entities with hitboxes
            for e in all(entities) do
                if e.battle and e.state and e.position then
                    -- advance attack cooldown
                    if(e.battle.cooldown > 0) e.battle.cooldown -= 1
                    
                    -- attack
                    local hitbox = e.battle.hitboxes[e.state.current]
                    if hitbox and e.state.current != e.state.previous then
                        e.battle.cooldown = e.battle.cd_time
                        -- check all entities with hurboxes
                        for o in all(entities) do
                            if o!=e and o.battle and o.state and o.position then
                                local hurtbox = o.battle.hurtboxes[o.state.current]
                                if hurtbox and box_collide(e.battle.get_box(e.position,hitbox),o.battle.get_box(o.position,hurtbox)) then
                                    o.battle.health -= e.battle.damage
                                    o.state.previous = o.state.current
                                    o.state.current = "_damaged"
                                    spawn_shatter(o.position.x+8,o.position.y+8,{8,8,2},{})
                                    if o.battle.health<1 then
                                        o.state.current = "_death"
                                    end
                                end
                            end
                        end
                    end
                end
            end
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
            if p.kind=="smoke" then
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
    return _a.position.z < _b.position.z
end

function box_collide(box1,box2)
    return colliding(box1.x,box1.y,box1.w,box1.h,box2.x,box2.y,box2.w,box2.h)
end

function colliding(x1,y1,w1,h1,x2,y2,w2,h2)
    return flr(x1+w1) > flr(x2) and flr(x1) < flr(x2+w2)
        and flr(y1+h1) > flr(y2) and flr(y1) < flr(y2+h2)
end