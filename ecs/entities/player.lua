function _player_i()
    player_combo = false
    local pos = new_position(22,0,16,16,4)
    -- #region player animation
    local player_animation = {}
    local ac = new_animation(player_animation,"idle")
    ac.add_anim_new('idle',str2frames('16,0|32,0|32,0|48,0'),.2,true)
    ac.add_anim_new('run',str2frames('64,0|80,0|96,0|112,0'),.2,true)
    ac.add_anim_new('_damaged',str2frames('32,0|32,0|48,0'),.2,false)
    ac.add_anim_new('_death',{{32,8,16,8}},.5,false)
    local p1s,p2s,p3s = '0,16|0,16|0,16|0,16|16,16|32,16|48,16|48,16',
    '64,16|64,16|64,16|80,16|96,16|112,16|112,16',
    '0,32|0,32|0,32|0,32|16,32|32,32|48,32|48,32'
    local p1,p2,p3 = str2frames(p1s),str2frames(p2s),str2frames(p3s)
    ac.add_anim_new('punch_right_1',p1,.06,false)
    ac.add_anim_new('punch_right_2',p2,.06,false)
    ac.add_anim_new('punch_right_3',p3,.06,false)
    ac.add_anim_new('punch_left_1',p1,.06,false)
    ac.add_anim_new('punch_left_2',p2,.06,false)
    ac.add_anim_new('punch_left_3',p3,.06,false)
    ac.add_anim_new('shoot',str2frames('64,32|64,32|64,32|64,32|80,32|96,32|112,32|112,32'),.05,false)

    -- #region player state
    local player_states = {
        idle = function(_e)
            player_combo = false
            _e.state.can_attack = true
            if(_e.inte.left) _e.position.dx=-1 return 'run'
            if(_e.inte.right) _e.position.dx=1 return 'run'
            if _e.inte.x then 
                _e.inte.right=false
                _e.inte.left=false
                return get_player_attack_state(_e)
            end
            return "idle"
        end,
        _damaged = function(_e)
            if(_e.animation.prog()>.9) return "idle"
            return "_damaged"
        end,
        _death = function(_e)
            if _e.animation.prog()>.9 then
                del(entities,_e)
                load_scene_death()
            else
                -- spawn_shatter(_e.position.x,_e.position.y-8,{8,8,2},{})
                for i=1,5 do
                    add(particles,new_particle(
                        "pixel",
                        new_position(_e.position.x,_e.position.y-4,1,0),
                        rnd()-.5,
                        -1-rnd(3),
                        5+rnd(5),
                        {8,8,2},
                        1,
                        { has_gravity=true }
                    ))
                end
                return "_death"
            end
        end,
        run = function(_e)
            _e.state.can_attack = true
            _e.sprite.fx=_e.position.dx<=0
            if _e.inte.x then 
                _e.inte.right=false
                _e.inte.left=false
                return get_player_attack_state(_e)
            end
            if(_e.inte.right) _e.position.dx = 1 return "run"
            if(_e.inte.left) _e.position.dx = -1 return "run"
            return "idle"
        end,
        punch_right_1 = function(_e) return punch_state(_e, "punch_right_1", true) end,
        punch_right_2 = function(_e) return punch_state(_e, "punch_right_2", true) end,
        punch_right_3 = function(_e) return punch_state(_e, "punch_right_3", false) end,
        punch_left_1 = function(_e) return punch_state(_e, "punch_left_1", true) end,
        punch_left_2 = function(_e) return punch_state(_e, "punch_left_2", true) end,
        punch_left_3 = function(_e) return punch_state(_e, "punch_left_3", false) end,
        shoot = function(_e)
            local p=_e.animation.prog()
            if p>.8 and not player_combo then
                player_combo=true
                if _e.inventory.bullets>0 then
                    spawn_bullet(_e.position.x, _e.position.dx)
                    _e.inventory.bullets -= 1
                else
                    -- todo: fx for missing bullets
                end
            end
            return punch_state(_e, "shoot", false)
        end
    }
    -- #region player battle
    local p_hb = { ox=-4, oy=-12, w=7, h=12 }
    local player_hurtboxes = {
        idle = p_hb,
        run = p_hb,
        shoot = p_hb,
    }
    local player_hitboxes = {
        -- punch_right_1 = { ox=2, oy=-8, w=10, h=6, active_frames={5,6,7} },
        punch_right_1 = { ox=0, oy=-8, w=12, h=6, active_frames={5,6} },
        punch_right_2 = { ox=0, oy=-8, w=12, h=6, active_frames={5,6} },
        punch_right_3 = { ox=0, oy=-12, w=14, h=12, active_frames={5,6} },
        punch_left_1 = { ox=-14, oy=-8, w=12, h=6, active_frames={5,6} },
        punch_left_2 = { ox=-14, oy=-8, w=12, h=6, active_frames={5,6} },
        punch_left_3 = { ox=-16, oy=-12, w=14, h=12, active_frames={5,6} },
    }

    -- #region player entity
    player = new_entity({
        kind = "player",
        code = "playe",
        position = pos,
        sprite = new_sprite(),
        animation = ac,
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
        inte = new_inte(),
        collider = new_collider(-4,-12,7,12,{}),
        state = new_state(player_states,"idle"),
        battle = new_battle(player_hitboxes,player_hurtboxes,{health=100, damage=1, cd_time= 45}),
        inventory = new_inventory(2,true,50,96,{})
    })
    add(entities,player)
end

-- #region player control
function player_contol(_e)
    local attack_pressed = btnp(_e.control.x)

    local as = {punch_right_1=true, punch_right_2=true, punch_right_3=true, punch_left_1=true, punch_left_2=true, punch_left_3=true, swing_right=true, swing_left=true, shoot=true}
    local is_attacking = as[_e.state.curr] or false
    local is_dead = _e.state.curr=="_death"
    
    -- buffer input
    if attack_pressed then
        local anim_perc = _e.animation.prog()
        if  is_attacking and anim_perc > .5 then
            -- try to queue the attack
            _e.inte.queue_attack = true
        else
            -- begin attack
            _e.inte.x = (not is_attacking) and attack_pressed
        end
    end

    -- player movement
    _e.inte.left = not(is_dead or is_attacking) and btn(_e.control.left)
    _e.inte.right = not(is_dead or is_attacking) and btn(_e.control.right)
    _e.inte.is_moving = _e.inte.left or _e.inte.right

    -- check for interaction
    local cel_x = flr((_e.position.x)/8)
    if fget(mget(cel_x,8),0) then
        local is_interacting = btnp(_e.control.o)
        _e.inte.o = is_interacting
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
    if(btnp(_e.control.up) and btnp(_e.control.down)) debug_items()
end

function get_player_attack_state(_e)
    local eq=_e.inventory.items[_e.inventory.active_i]
    if not eq or eq.kind=="gloves" then
        _e.battle.damage=10
        _e.battle.knock=5
        sfx(14)
        -- next state table
        local nst={
            punch_right_1={s="punch_right_2",d=12,k=3},
            punch_right_2={s="punch_right_3",d=15,k=15},
            punch_left_1={s="punch_left_2",d=12,k=3},
            punch_left_2={s="punch_left_3",d=15,k=15}
        }
        ns = nst[_e.state.curr]
        if ns then
            _e.battle.damage=ns.d + ((eq and eq.kind=="gloves") and 10 or 0)
            _e.battle.knock=ns.k
            _skip_frames=5
            return ns.s
        end
        player_combo=true
        return _e.position.dx>0 and "punch_right_1" or "punch_left_1"
    end

    if(eq.kind == "gun") sfx(16) return "shoot"

    return "idle"
end

-- #region loot
function loot(_px,_py)
    local r = rnd()
    -- add loot particles 
    spawn_smoke(
        _px+2,
        _py,
        {6,7,7},
        { angle = 0.75, max_size = 1.5+rnd(2), max_age = 30 }
    )
    spawn_smoke(
        _px-2,
        _py,
        {6,7,7},
        { angle = 0.25, max_size = 1.5+rnd(2), max_age = 30 }
    )

    if(r > 0.1) sfx(12) return

    if r > 0.03 then
        player.battle.health = min(player.battle.health+10, 200)
        sfx(11)
        spawn_shatter(_px,_py,{3,11,11,7},{})
        return
    end

    local gloves = new_entity({
        kind = "gloves",
        sprite = new_sprite({{x=0,y=104,w=8,h=8}}),
    })
    local gun = new_entity({
        kind = "gun",
        sprite = new_sprite({{x=8,y=0,w=8,h=8}}),
    })

    local nbr_items = #player.inventory.items
    if(nbr_items==0) add(player.inventory.items,gloves) player.inventory.active_i = 1
    if(nbr_items==1) add(player.inventory.items,gun) player.inventory.active_i = 2
    if(nbr_items>1) player.inventory.bullets += flr(rnd()*5)

    -- add found particles
    sfx(13)
    spawn_shatter(_px,_py,{9,10,7},{})
end

function debug_items()
    local gloves = new_entity({
        kind = "gloves",
        sprite = new_sprite({{x=0,y=104,w=8,h=8}}),
    })
    local gun = new_entity({
        kind = "gun",
        sprite = new_sprite({{x=8,y=0,w=8,h=8}}),
    })

    add(player.inventory.items,gloves) player.inventory.active_i = 1
    add(player.inventory.items,gun) player.inventory.active_i = 3
    player.inventory.bullets += 50
end

function punch_state(_e, state_name, can_combo)
    _e.state.can_attack = false
    local anim_perc = _e.animation.prog()

    -- If animation ends, clear buffer flags
    if anim_perc >= 1 then
        _e.inte.x = false

        if _e.inte.queue_attack then
            _e.inte.queue_attack = false
            return get_player_attack_state(_e)
        else
            return "idle"
        end
    end

    return state_name
end