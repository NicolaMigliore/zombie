--- create position component ---
-- @param _x | x coordinate
-- @param _y | y coordinate
-- @param _z | z coordinate
-- @param _w | width of the entitie, used for drawing. defaults to 16
-- @param _h | height of the entitie, used for drawing. defaults to 16
function new_position(_x,_y,_w,_h,_z)
    local p = {
        x = _x,
        y = _y,
        z = _z or 1,
        w = _w or 16,
        h = _h or 16,
        dx = 0,
        dy = 0,
    }
    return p
end

--- create sprite component ---
-- @param _sprite | sprites object in the form { x = <x coord>, y = <y coord> ,w = <sprite width in pixels>,h = <sprite height in pixels>,pal_rep = <palette replacent list {{c1,c2}}> }
-- @param _flip_x | boolean to describe if the sprite should be flipped on the x axis
-- @param _flip_y | boolean to describe if the sprite should be flipped on the y axis
-- @param _palette_replace | list of couples of colors to replace in the form {{c1,c2}}
function new_sprite(_sprite,_flip_x,_flip_y,_palette_replace)
    local s = {
        sprite = _sprite,
        flip_x = _flip_x or false,
        flip_y = _flip_y or false,
        -- palette_replace = _palette_replace
    }
    return s
end

--- create animation component ---
-- @param _animations | table of animations in the form { <anim_name> = { frames = <list of sprite object>, speed = <animation speed>, loop = <define if animation should be looped> }  }
-- @param _active_anim | name of currently active animation
-- @param _set_anim | function to control currently active animation
function new_animation(_animations,_active_anim,_set_anim,_timer)
    local a = {
        animations = _animations,
        active_anim = _active_anim,
        anim_i = 1,
    }
    a.set_animation = _set_anim
    return a
end

--- create state component ---
-- @param initial_state | initial state of the entity
-- @param state_controllers | table of function to call to check state rules and assign the state.
--  In the form { <state_name> = <rule function> }
--  Rule function should return true or false
function new_state(_rules,_initial_state)
    local s = {
        current = _initial_state,
        previous = _initial_state,
        rules = _rules,
    }
    return s
end

--- create new control component
-- @param _left | reference to left button
-- @param _right | reference to right button
-- @param _up | reference to up button
-- @param _down | reference to down button
-- @param _spd_x | horixzontal speed
-- @param _spd_y | vertical speed
-- @param _control_func | function to control the enetity. For player handles inputs, for nos handles ai
function new_control(_opts)
    local c = {
        left = _opts.left,
        right = _opts.right,
        up = _opts.up,
        down = _opts.down,
        o = _opts.o,
        x = _opts.x,
        spd_x = _opts.spd_x,
        spd_y = _opts.spd_y,
        control = _opts.control_func
    }
    return c
end

--- create new intention component
-- describes the entity's intention to move in a direction
function new_intention()
    local i = {
        left = false,
        right = false,
        up = false,
        down = false,
        x = false,
        o = false,
        -- attack_1 = false,
        -- attack_2 = false,
        is_moving = false,
        is_jumping = false,
        is_falling = false
    }
    return i
end

function new_battle(_hitboxes,_hurtboxes,_opts)
    local b ={
        hitboxes = _hitboxes,
        hurtboxes = _hurtboxes,
        health =  _opts.health or 100,
        cd_time = _opts.cd_time or 180,
        cooldown = _opts.cd_time or 180,
        damage = _opts.damage or 20,
        get_box = function(_pos,_box)
            --- @param _pos: poistion component
            --- @param _box: hitbox or hurtbox item
            return {
                x = _pos.x + _box.ox,
                y = _pos.y + _box.oy,
                w = _box.w,
                h = _box.h
            }
        end
    }
    return b
end

--- create a collider box component
-- @param _ox | x offset relative to the entity position
-- @param _oy | y offset relative to the entity position
-- @param _w | width of the collider box
-- @param _h | height of the collider box
-- @param _opts | options of the collider, including
--  - is_solid: if the entity is solid and should collide
--  - gravity: if the entity is effected by gravity
--  - mass: the mass of the entity
function new_collider(_ox,_oy,_w,_h,_opts)
    -- calculate defaults
    local is_solid,gravity,mass = true, true, 1
    if (_opts.is_solid != nil) is_solid = _opts.is_solid
    if (_opts.gravity != nil) gravity = _opts.gravity
    if (_opts.mass != nil) mass = _opts.mass

    local c = {
        ox = _ox,
        oy = _oy,
        w = _w,
        h = _h,
        collide_r = false,
        collide_l = false,
        collide_t = false,
        collide_b = false,
        gravity = gravity,
        show = false,
        has_collision = false,
        is_falling = gravity,
        mass = mass,
        is_solid = is_solid,
    }
    c.get_bounding_box = function(_pos)
        --- @param _pos: poistion component
        return {
            x = _pos.x + c.ox,
            y = _pos.y + c.oy,
            w = c.w,
            h = c.h
        }
    end
    return c
end

--- create a trigger box component
-- @param _ox | x offset relative to the entity position
-- @param _oy | y offset relative to the entity position
-- @param _w | width of the collider box
-- @param _h | height of the collider box
-- @param _ontrigger | function to call when trigger is activated
-- @param _kind | the type of trigger. Possible options:
--  - once: calls function once then delets the trigger
--  - always: calls function every frame that it is triggered
--  - wait: waits for trigger to no longer be activated then calls function
function new_trigger(_ox,_oy,_w,_h,_ontrigger,_kind)
    local t = {
        ox = _ox,
        oy = _oy,
        w = _w,
        h = _h,
        ontrigger = _ontrigger,
        kind = _kind,
        is_active = false
    }
    return t
end

--- create entity ---
function new_entity(_opts)
    local e = {
        kind = _opts.kind,
        position = _opts.position,
        sprite = _opts.sprite,
        control = _opts.control,
        intention = _opts.intention,
        collider = _opts.collider,
        animation = _opts.animation,
        triggers = _opts.triggers,
        state = _opts.state or new_state({},"idle"),
        battle = _opts.battle
    }
    return e
end