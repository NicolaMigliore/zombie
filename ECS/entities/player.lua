function _player_i()
    -- #region player animation
    local player_animation = {
        _damaged = {
            frames = {
                {x=32,y=0,w=16,h=16,pal_rep={{9,6},{15,6},{4,6},{7,6},{12,6}}},
                {x=32,y=0,w=16,h=16,pal_rep={{9,8},{15,8},{4,8},{7,8},{12,8}}},
                {x=48,y=0,w=16,h=16,pal_rep={{9,6},{15,6},{4,6},{7,6},{12,6}}},
                {x=48,y=0,w=16,h=16,pal_rep={{9,8},{15,8},{4,8},{7,8},{12,8}}},
                {x=16,y=0,w=16,h=16,pal_rep={{9,6},{15,6},{4,6},{7,6},{12,6}}},
                {x=16,y=0,w=16,h=16,pal_rep={{9,8},{15,8},{4,8},{7,8},{12,8}}},
            },
            speed = 0.5
        },
    }
    local animation_comp = new_animation(player_animation,"idle")
    animation_comp.add_animation("idle","32,0,16,16|32,0,16,16|32,0,16,16|48,0,16,16|16,0,16,16|32,0,16,16",0.05,true)
    animation_comp.add_animation("_death","48,112,8,8|56,112,8,8|48,120,8,8|56,120,8,8",0.1)
    animation_comp.add_animation("run","0,16,16,16|16,16,16,16|32,16,16,16|48,16,16,16|64,16,16,16|80,16,16,16|96,16,16,16|112,16,16,16",0.15,true)
    animation_comp.add_animation("punch_right","16,0,16,16|0,32,16,16|16,32,16,16|32,32,16,16|48,32,16,16",0.2)
    animation_comp.add_animation("punch_left","16,0,16,16|0,32,16,16|16,32,16,16|32,32,16,16|48,32,16,16",0.2)
    animation_comp.add_animation("swing_right","16,0,16,16|80,32,16,16|96,32,16,16|112,32,16,16|0,48,16,16|16,48,16,16|32,48,16,16|32,48,16,16",0.2)
    animation_comp.add_animation("swing_left","16,0,16,16|80,32,16,16|96,32,16,16|112,32,16,16|0,48,16,16|16,48,16,16|32,48,16,16|32,48,16,16",0.2)
    animation_comp.add_animation("shoot","16,0,16,16|64,0,16,16|80,0,16,16|96,0,16,16|112,0,16,16",0.2)


    -- #region player state
    local player_states = {
        idle = function(_e)
            -- move player
            if(_e.intention.left) _e.position.dx=-1 return 'run'
            if(_e.intention.right) _e.position.dx=1 return 'run'

            -- attack
            if _e.intention.x then 
                _e.intention.right=false
                _e.intention.left=false
                return get_player_attack_state(_e)
            end

            -- return current state
            return "idle"
        end,
        _damaged = function(_e)
            spawn_shatter(_e.position.x+8,_e.position.y+8,{8,8,2},{})
            -- idle
            local damage_ended = check_animation_ended(_e,"_damaged")
            if(damage_ended) return "idle"
            -- continue damaged state
            return "_damaged"
        end,
        _death = function(_e)
            spawn_shatter(_e.position.x+8,_e.position.y+8,{8,8,2},{})
            local death_ended = check_animation_ended(_e,"_death")
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
                return get_player_attack_state(_e)
            end
            -- keep moving
            if(_e.intention.right) _e.position.dx = 1 return "run"
            if(_e.intention.left) _e.position.dx = -1 return "run"

            -- idle
            return "idle"
        end,
        punch_right = function(_e)
            local attack_ended = check_animation_ended(_e,"punch_right")

            -- idle
            if(attack_ended) return "idle"

            -- keep punching
            return "punch_right"
        end,
        punch_left = function(_e)
            local attack_ended = check_animation_ended(_e,"punch_left")

            -- idle
            if(attack_ended) return "idle"

            -- keep punching
            return "punch_left"
        end,
        swing_right = function(_e)
            local attack_ended = check_animation_ended(_e,"swing_right")

            -- idle
            if(attack_ended) return "idle"

            -- keep swinging
            return "swing_right"
        end,
        swing_left = function(_e)
            local attack_ended = check_animation_ended(_e,"swing_left")

            -- idle
            if(attack_ended) return "idle"

            -- keep swinging
            return "swing_left"
        end,
        shoot = function(_e)
            local attack_ended = check_animation_ended(_e,"shoot")
            
            -- idle
            if(attack_ended) return "idle"
            
            local anim_perch = _e.animation.anim_i/#_e.animation.animations["shoot"].frames
            -- shoot the buller
            if anim_perch == 0.8 then
                if _e.inventory.bullets > 0 then
                    spawn_bullet(_e.position.x, _e.position.dx)
                    _e.inventory.bullets -= 1
                else
                    -- todo: fx for missing bullets
                end
            end
            -- keep punching
            return "shoot"
        end,
    }
    -- #region player battle
    local player_hurtboxes = {
        idle = { ox=5, oy=3, w=5, h=12 },
        run = { ox=5, oy=3, w=5, h=12 },
        punch_right = { ox=5, oy=3, w=5, h=12 },
        punch_left = { ox=5, oy=3, w=5, h=12 },
        swing_left = { ox=5, oy=3, w=5, h=12 },
        swing_left = { ox=5, oy=3, w=5, h=12 },
        shoot = { ox=5, oy=3, w=5, h=12 },
    }
    local player_hitboxes = {
        punch_left = { ox=0, oy=8, w=3, h=4 },
        punch_right = { ox=12, oy=4, w=8, h=8 },--{ ox=12, oy=8, w=3, h=4 },
        swing_left = { ox=-4, oy=8, w=7, h=4 },
        swing_right = { ox=14, oy=8, w=7, h=4 },
    }

    -- #region player entity
    player = new_entity({
        kind = "player",
        code = "playe",
        position = new_position(22,60,16,16,2),
        sprite = new_sprite({x=16,y=0,w=16,h=16}),
        animation = animation_comp,
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

-- #region player control
function player_contol(_e)
    -- player attack
    _e.intention.x = btnp(_e.control.x)

    local is_attacking = 
        _e.state.current == "punch_right" or
        _e.state.current == "punch_left" or
        _e.state.current == "swing_right" or
        _e.state.current == "swing_left" or
        _e.state.current == "shoot"

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
            loot((cel_x*8)+4, 64)
            mset(cel_x,8,200)
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

    -- debug inventory
    -- if(btn(_e.control.up) and btn(_e.control.down)) debug_items()
end

function get_player_attack_state(_e)
    local equipped_item = _e.inventory.items[_e.inventory.active_i]
    -- hand
    if(equipped_item == nil) sfx(14) return _e.position.dx > 0 and "punch_right" or "punch_left"
    if(equipped_item.kind == "gloves")_e.battle.damage = 40 sfx(14) return _e.position.dx > 0 and "punch_right" or "punch_left"

    -- crowbar
    if(equipped_item.kind == "crowbar")_e.battle.damage = 70 sfx(15) return _e.position.dx > 0 and "swing_right" or "swing_left"

    -- gun
    if(equipped_item.kind == "gun") sfx(16) return "shoot"
end

-- #region loot
function loot(_particle_x,_particle_y)
    local r = rnd()
    -- add loot particles 
    spawn_smoke(
        _particle_x+2,
        _particle_y,
        {6,7,7},
        { angle = 0.75, max_size = 1.5+rnd(2), max_age = 30 }
    )
    spawn_smoke(
        _particle_x-2,
        _particle_y,
        {6,7,7},
        { angle = 0.25, max_size = 1.5+rnd(2), max_age = 30 }
    )

    if(r > 0.1) sfx(12) return

    if r > 0.03 then
        player.battle.health = min(player.battle.health+10, 200)
        sfx(11)
        spawn_shatter(_particle_x,_particle_y,{3,11,11,7},{})
        return
    end

    local gloves = new_entity({
        kind = "gloves",
        sprite = new_sprite({x=0,y=104,w=8,h=8}),
    })
    local crowbar = new_entity({
        kind = "crowbar",
        sprite = new_sprite({x=0,y=8,w=8,h=8}),
    })
    local gun = new_entity({
        kind = "gun",
        sprite = new_sprite({x=8,y=0,w=8,h=8}),
    })

    local nbr_items = #player.inventory.items
    if(nbr_items==0) add(player.inventory.items,gloves) player.inventory.active_i = 1
    if(nbr_items==1) add(player.inventory.items,crowbar) player.inventory.active_i = 2
    if(nbr_items==2) add(player.inventory.items,gun) player.inventory.active_i = 3
    if(nbr_items>2) player.inventory.bullets += flr(rnd()*5)

    -- add found particles
    sfx(13)
    spawn_shatter(_particle_x,_particle_y,{9,10,7},{})
end

function debug_items()
    local gloves = new_entity({
        kind = "gloves",
        sprite = new_sprite({x=0,y=104,w=8,h=8}),
    })
    local crowbar = new_entity({
        kind = "crowbar",
        sprite = new_sprite({x=0,y=8,w=8,h=8}),
    })
    local gun = new_entity({
        kind = "gun",
        sprite = new_sprite({x=8,y=0,w=8,h=8}),
    })

    add(player.inventory.items,gloves) player.inventory.active_i = 1
    add(player.inventory.items,crowbar) player.inventory.active_i = 2
    add(player.inventory.items,gun) player.inventory.active_i = 3
    player.inventory.bullets += 5
end