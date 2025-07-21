-- #region position
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
        dx = 1,
        dy = 0,
    }
    return p
end

-- #region sprite
-- @param _sprite | sprites object in the form {{ x = <x coord>, y = <y coord> ,w = <sprite width in pixels>,h = <sprite height in pixels>,pal_rep = <palette replacent list {{c1,c2}}> }}
-- @param _flip_x | boolean to describe if the sprite should be flipped on the x axis
-- @param _flip_y | boolean to describe if the sprite should be flipped on the y axis
-- @param _palette_replace | list of couples of colors to replace in the form {{c1,c2}}
function new_sprite(_sprites,_flip_x,_flip_y)
    local s = {
        sprites = _sprites,
        fx = _flip_x or false,
        fy = _flip_y or false,
    }
    return s
end

-- #region animation
-- @param _animations | table of animations in the form { <anim_name> = { frames = <list of sprite object>, speed = <animation speed>, loop = <define if animation should be looped> }  }
-- @param _active_anim | name of currently active animation
function new_animation(_animations,_active_anim)
    local a = {
        animations = _animations,
        active_anim = _active_anim,
        frame_t = 0,
        i = 1,
    }
    a.add_anim_new = function (name,frames,speed,loop)
        a.animations[name] = {
            frames = frames,
            speed = speed,
            loop = loop or false
        }
    end
    a.prog = function ()
        local cur = a.animations[a.active_anim]
        return (a.i - 1 + (a.frame_t / (cur.speed * 60))) / #cur.frames
    end

    return a
end

-- #region state
-- @param initial_state | initial state of the entity
-- @param state_controllers | table of function to call to check state rules and assign the state.
--  In the form { <state_name> = <rule function> }
--  Rule function should return true or false
function new_state(_rules,_initial_state)
    local s = {
        curr = _initial_state,
        prev = _initial_state,
        rules = _rules,
        can_attack = false,
    }
    return s
end

-- #region control
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
        fn = _opts.control_func
    }
    return c
end

-- #region intention
-- describes the entity's inte to move in a direction
function new_inte()
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

        -- input buffering
        queue_attack = false,
    }
    return i
end

-- #region battle
function new_battle(_hitboxes,_hurtboxes,_opts)
    local health = _opts.health or 100
    local b ={
        hitboxes = _hitboxes,
        hurtboxes = _hurtboxes,
        health =  health,
        max_health = health,
        cd_time = _opts.cd_time or 180,
        hit_timer = 0,
        damage = _opts.damage or 20,
        knock = 0,
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

-- #region collider box
-- @param _ox | x offset relative to the entity position
-- @param _oy | y offset relative to the entity position
-- @param _w | width of the collider box
-- @param _h | height of the collider box
-- @param _opts | options of the collider, including
--  - is_solid: if the entity is solid and should collide
--  - gravity: if the entity is effected by gravity
function new_collider(_ox,_oy,_w,_h,_opts)
    local is_solid,gravity,can_collide = true, true, true
    if (_opts.is_solid != nil) is_solid = _opts.is_solid
    if (_opts.gravity != nil) gravity = _opts.gravity
    if (_opts.can_collide != nil) can_collide = _opts.can_collide

    local c = {
        ox = _ox,
        oy = _oy,
        w = _w,
        h = _h,
        gravity = gravity,
        show = false,
        has_collision = false,
        is_solid = is_solid,
        can_collide = can_collide,
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

-- #region trigger box
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

-- #region inventory
function new_inventory(_size,_visible,_x,_y,_items)
    local items = _items or {}
    local i = {
        size = _size,
        visible = _visible,
        x = _x,
        y = _y,
        items = items,
        active_i = 1,
        bullets = 0
    }
    return i
end

-- #region create entity
function new_entity(_opts)
    local e = {
        id = new_guid(_opts.code),
        kind = _opts.kind,
        position = _opts.position,
        sprite = _opts.sprite,
        control = _opts.control,
        inte = _opts.inte,
        collider = _opts.collider,
        animation = _opts.animation,
        triggers = _opts.triggers,
        state = _opts.state or new_state({},"idle"),
        battle = _opts.battle,
        inventory = _opts.inventory,
    }
    return e
end

-- #region create particle
function new_particle(_kind,_pos,_dx,_dy,_max_age,_colors,_max_size,_opts)
    local p = {
        position = _pos,
        dx=_dx,
        dy=_dy,
        kind=_kind,
        age=0,
        max_age=_max_age,
        colors=_colors,
        color=_colors[1],
        max_size=_max_size,
        has_gravity=_opts.has_gravity or false,
        has_rotation=_opts.has_rotation or false,
        sprite=_opts.sprite or 0,
        opts=_opts
    }
    return p
end