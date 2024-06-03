function _player_i()
    -- #region player entity
    local player_animation = {
        idle = {
            frames = {
                {x=32,y=0,w=16,h=16},
                {x=32,y=0,w=16,h=16},
                {x=32,y=0,w=16,h=16},
                {x=48,y=0,w=16,h=16},
                {x=16,y=0,w=16,h=16},
                {x=32,y=0,w=16,h=16},
            },
            speed = 0.05,
            loop = true,
        },
        _damaged = {
            frames = {
                {x=32,y=0,w=16,h=16,pal_rep={{9,6},{15,6},{4,6},{7,6},{12,6}}},
                {x=32,y=0,w=16,h=16,pal_rep={{9,8},{15,8},{4,8},{7,8},{12,8}}},
                {x=48,y=0,w=16,h=16,pal_rep={{9,6},{15,6},{4,6},{7,6},{12,6}}},
                {x=48,y=0,w=16,h=16,pal_rep={{9,8},{15,8},{4,8},{7,8},{12,8}}},
                {x=16,y=0,w=16,h=16,pal_rep={{9,6},{15,6},{4,6},{7,6},{12,6}}},
                {x=16,y=0,w=16,h=16,pal_rep={{9,8},{15,8},{4,8},{7,8},{12,8}}},
            },
            speed = 0.5,
            loop = false,
        },
        _death = {
            frames = {
                {x=48,y=112,w=8,h=8},
                {x=56,y=112,w=8,h=8},
                {x=48,y=120,w=8,h=8},
                {x=56,y=120,w=8,h=8},
            },
            speed = 0.1,
            loop = false,
        },
        run = {
            frames = {
                {x=0,y=16,w=16,h=16},
                {x=16,y=16,w=16,h=16},
                {x=32,y=16,w=16,h=16},
                {x=48,y=16,w=16,h=16},
                {x=64,y=16,w=16,h=16},
                {x=80,y=16,w=16,h=16},
                {x=96,y=16,w=16,h=16},
                {x=112,y=16,w=16,h=16},
            },
            speed = 0.15,
            loop = true,
        },
        punch_right = {
            frames = {
                {x=16,y=0,w=16,h=16},
                {x=0,y=32,w=16,h=16},
                {x=16,y=32,w=16,h=16},
                {x=32,y=32,w=16,h=16},
                {x=48,y=32,w=16,h=16},
            },
            speed = 0.2,
            loop = false,
        },
        punch_left = {
            frames = {
                {x=16,y=0,w=16,h=16},
                {x=0,y=32,w=16,h=16},
                {x=16,y=32,w=16,h=16},
                {x=32,y=32,w=16,h=16},
                {x=48,y=32,w=16,h=16},
            },
            speed = 0.2,
            loop = false,
        }
    }
    local player_states = {
        idle = function(_e)
            -- move player
            if(_e.intention.left) _e.position.dx=-1 return 'run'
            if(_e.intention.right) _e.position.dx=1 return 'run'

            -- attack
            if _e.intention.x then 
                _e.intention.right=false
                _e.intention.left=false
                return _e.position.dx > 0 and "punch_right" or "punch_left"
            end

            -- return current state
            return "idle"
        end,
        _damaged = function(_e)
            -- idle
            local damage_ended = _e.animation.anim_i > #_e.animation.animations["_damaged"].frames
            if(damage_ended) return "idle"
            -- continue damaged state
            return "_damaged"
        end,
        _death = function(_e)
            local death_ended = _e.animation.anim_i > #_e.animation.animations["_death"].frames
            -- delete entity
            if death_ended then
                del(entities,_e)
                load_scene_death()
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
            if _e.intention.x then 
                _e.intention.right=false
                _e.intention.left=false
                return _e.position.dx > 0 and "punch_right" or "punch_left"
            end
            -- keep moving
            if(_e.intention.right) _e.position.dx = 1 return "run"
            if(_e.intention.left) _e.position.dx = -1 return "run"

            -- idle
            return "idle"
        end,
        punch_right = function(_e)
            local attack_ended = _e.animation.anim_i > #_e.animation.animations["punch_right"].frames

            -- idle
            if(attack_ended) return "idle"

            -- keep punching
            return "punch_right"
        end,
        punch_left = function(_e)
            local attack_ended = _e.animation.anim_i > #_e.animation.animations["punch_left"].frames

            -- idle
            if(attack_ended) return "idle"

            -- keep punching
            return "punch_left"
        end,
    }
    local player_hurtboxes = {
        idle = { ox=5, oy=3, w=5, h=12 },
        run = { ox=5, oy=3, w=5, h=12 },
        punch_right = { ox=5, oy=3, w=5, h=12 },
        punch_left = { ox=5, oy=3, w=5, h=12 },
    }
    local player_hitboxes = {
        punch_left = { ox=0, oy=8, w=3, h=4 },
        punch_right = { ox=12, oy=8, w=3, h=4 }
    }

    player = new_entity({
        kind = "player",
        position = new_position(22,60,16,16,2),
        sprite = new_sprite({x=16,y=0,w=16,h=16}),
        animation = new_animation(player_animation,"idle"),
        -- control = new_control(⬅️,➡️,nil,nil,0.7,0,🅾️,❎,player_contol),
        control = new_control({
            left = ⬅️,
            right = ➡️,
            up = ⬆️,
            down = ⬇️,
            spd_x = 0.7,
            o = 🅾️,
            x = ❎,
            control_func = player_contol
        }),
        intention = new_intention(),
        collider = new_collider(5,3,5,12,{}),
        state = new_state(player_states,"idle"),
        battle = new_battle(player_hitboxes,player_hurtboxes,{health=200, damage=20, cd_time= 45}),
        --inventory = new_inventory(3,true,2,98,{})
        inventory = new_inventory(3,true,50,96,{})
    })
    add(entities,player)
end

function player_contol(_e)
    -- player attack
    _e.intention.x = btnp(_e.control.x)

    local is_attacking = _e.state.current == "punch_right" or _e.state.current == "punch_left"

    -- player movement
    _e.intention.left = not is_attacking and btn(_e.control.left)
    _e.intention.right = not is_attacking and btn(_e.control.right)
    _e.intention.is_moving = _e.intention.left or _e.intention.right

    -- check for interaction
    local cel_x = flr((_e.position.x+8)/8)
    if fget(mget(cel_x,8),0) then
        local is_interacting = btnp(_e.control.o)
        _e.intention.o = is_interacting
        if is_interacting then
            loot()
            mset(cel_x,8,200)
            -- todo: add particles
        end
    end

    -- manage inventory
    if btnp(_e.control.up) then
        _e.inventory.active_i += 1
        if(_e.inventory.active_i>#_e.inventory.items) _e.inventory.active_i = 1
    elseif btnp(_e.control.down) then
        _e.inventory.active_i -= 1
        if(_e.inventory.active_i<1) _e.inventory.active_i = #_e.inventory.items
    end
end

function loot()
    local r = rnd()
    if(r > 0.1) return

    if(r > 0.03) player.battle.health = min(player.battle.health+10, 200) return
    
    local gloves = new_entity({
        sprite = new_sprite({x=0,y=104,w=8,h=8}),
    })
    local crowbar = new_entity({
        sprite = new_sprite({x=0,y=8,w=8,h=8}),
    })
    local gun = new_entity({
        sprite = new_sprite({x=8,y=0,w=8,h=8}),
    })

    local nbr_items = #player.inventory.items
    if(nbr_items==0) add(player.inventory.items,gloves) player.inventory.active_i = 1
    if(nbr_items==1) add(player.inventory.items,crowbar) player.inventory.active_i = 2
    if(nbr_items==2) add(player.inventory.items,gun) player.inventory.active_i = 3
    if(nbr_items>2) player.inventory.bullets += flr(rnd()*5)
    
end