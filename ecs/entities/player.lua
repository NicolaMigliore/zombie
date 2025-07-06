function _player_i()
    player_combo = false
    -- #region player animation
    local player_animation = {}
    -- local p1 = "82,0,9,6,1,-5@26,0,9,8,0,-13|82,0,9,6,1,-5@26,0,9,8,0,-13|82,0,9,6,1,-5@26,0,9,8,0,-13|91,0,11,6,6,-5@26,8,9,8,8,-12@114,0,16,4,4,-5|91,0,11,6,6,-5@16,8,10,8,8,-12@118,4,12,3,8,-5^3:7,4:7,9:7,12:7,13:7,15:7|91,0,11,6,6,-5@16,8,10,8,8,-12@117,7,13,5,8,-6^3:6,4:6,9:6,12:6,13:6,15:6|91,0,11,6,6,-5@26,8,9,8,8,-12@117,7,13,5,9,-6^3:7,4:7,9:7,12:7,13:7,15:7|91,0,11,6,6,-5@26,8,9,8,8,-12@125,12,4,3,17,-5"
    -- local p2 = "26,8,9,8,10,-11@91,0,11,6,7,-5|26,8,9,8,10,-11@91,0,11,6,7,-5|102,0,9,7,8,-6@0,16,10,8,1,-11@109,15,8,6,10,-5|102,0,9,7,8,-6@0,16,10,8,1,-11@117,15,6,5,12,-5^3:7,4:7,9:7,12:7,13:7,15:7|102,0,9,7,8,-6@0,16,10,8,1,-11@123,16,5,5,14,-5^3:6,4:6,9:6,12:6,13:6,15:6|102,0,9,7,8,-6@0,16,10,8,1,-11@123,16,5,5,14,-5^3:7,4:7,9:7,12:7,13:7,15:7|96,7,7,7,5,-6@26,8,9,8,2,-11,true,false@126,16,2,3,17,-5|44,14,7,9,5,-8@16,0,10,8,1,-11"
    -- local p3 = "44,14,7,9,5,-8@16,0,10,8,1,-11|103,7,8,6,6,-5@26,8,9,8,5,-12|51,14,8,10,8,-9@16,0,10,8,6,-14@112,22,5,10,14,-11|51,14,8,10,8,-9@16,0,10,8,6,-14@117,22,3,10,15,-10|51,14,8,10,8,-9@26,0,9,8,6,-14@120,22,5,8,14,-11|44,0,8,6,6,-5@16,0,10,8,6,-13@125,22,3,4,14,-14"
    local p1 = "82,0,9,6,1,-5@26,0,9,8,0,-13|82,0,9,6,1,-5@26,0,9,8,0,-13|82,0,9,6,1,-5@26,0,9,8,0,-13|91,0,11,6,6,-5@26,8,9,8,8,-12@114,0,16,4,4,-5|91,0,11,6,6,-5@16,8,10,8,8,-12@118,4,12,3,8,-5|91,0,11,6,6,-5@16,8,10,8,8,-12@117,7,13,5,8,-6|91,0,11,6,6,-5@26,8,9,8,8,-12@117,7,13,5,9,-6|91,0,11,6,6,-5@26,8,9,8,8,-12@125,12,4,3,17,-5"
    local p2 = "26,8,9,8,10,-11@91,0,11,6,7,-5|26,8,9,8,10,-11@91,0,11,6,7,-5|102,0,9,7,8,-6@0,16,10,8,1,-11@109,15,8,6,10,-5|102,0,9,7,8,-6@0,16,10,8,1,-11@117,15,6,5,12,-5|102,0,9,7,8,-6@0,16,10,8,1,-11@123,16,5,5,14,-5|102,0,9,7,8,-6@0,16,10,8,1,-11@123,16,5,5,14,-5|96,7,7,7,5,-6@26,8,9,8,2,-11,true,false@126,16,2,3,17,-5|44,14,7,9,5,-8@16,0,10,8,1,-11"
    local p3 = "44,14,7,9,5,-8@16,0,10,8,1,-11|103,7,8,6,6,-5@26,8,9,8,5,-12|51,14,8,10,8,-9@16,0,10,8,6,-14@112,22,5,10,14,-11|51,14,8,10,8,-9@16,0,10,8,6,-14@117,22,3,10,15,-10|51,14,8,10,8,-9@26,0,9,8,6,-14@120,22,5,8,14,-11|44,0,8,6,6,-5@16,0,10,8,6,-13@125,22,3,4,14,-14"

    local ac = new_animation(player_animation,"idle")
    ac.add_animation("idle","44,0,8,6,0,-5@16,0,10,8,0,-13|44,0,8,6,0,-5@16,0,10,8,0,-13|44,0,8,6,0,-5@26,0,9,8,0,-13|44,0,8,6,0,-5@26,0,9,8,0,-13|52,0,8,5,0,-4@35,0,9,8,0,-12|52,0,8,5,0,-4@35,0,9,8,0,-12|52,0,8,5,0,-4@35,0,9,8,0,-12|52,0,8,5,0,-4@35,0,9,8,0,-12|44,0,8,6,0,-5@16,0,10,8,0,-13",0.2,true)
    ac.add_animation("_damaged","44,0,8,6,0,-5@26,0,9,8,0,-13^9:7,15:7,4:7,6:7,12:7|44,0,8,6,0,-5@26,0,9,8,0,-13|52,0,8,5,0,-4@35,0,9,8,0,-12^9:7,15:7,4:7,6:7,12:7|52,0,8,5,0,-4@35,0,9,8,0,-12|44,0,8,6,0,-5@16,0,10,8,0,-13^9:7,15:7,4:7,6:7,12:7|44,0,8,6,0,-5@16,0,10,8,0,-13",0.03,false)
    ac.add_animation("_death","59,14,8,7,0,-6|67,14,8,6,0,-5|75,15,8,5,0,-4|83,17,8,3,0,-2|83,17,8,3,0,-2|83,17,8,3,0,-2",.3,false)
    ac.add_animation("run","44,7,7,5,0,-5@26,0,9,8,0,-13|51,7,5,6,0,-5@26,0,9,8,0,-12|56,7,6,7,0,-6@16,0,10,8,0,-14|62,7,8,5,0,-7@16,0,10,8,0,-15|70,7,7,5,0,-5@26,0,9,8,0,-13|77,7,5,5,0,-4@26,0,9,8,0,-11|82,7,6,7,0,-6@16,0,10,8,0,-14|88,7,8,5,0,-7@16,0,10,8,0,-15",0.15,true)

    ac.add_animation("punch_right_1",p1,.05,false)
    ac.add_animation("punch_right_2",p2,.05,false)
    ac.add_animation("punch_right_3",p3,.05,false)
    ac.add_animation("punch_left_1",p1,.05,false)
    ac.add_animation("punch_left_2",p2,.05,false)
    ac.add_animation("punch_left_3",p3,.05,false)
    ac.add_animation("shoot","60,0,8,7,4,-5@26,0,9,8,4,-13|68,0,6,7,5,-5@26,0,9,8,3,-13|74,0,7,7,6,-5@26,0,9,8,3,-13|74,0,7,7,6,-5@35,8,9,8,3,-13@96,14,5,5,13,-7|74,0,7,7,6,-5@35,8,9,8,3,-13@102,14,6,3,13,-6|74,0,7,7,6,-5@26,0,9,8,3,-13@125,12,3,3,16,-6",.05,false)

    


    -- #region player state
    local player_states = {
        idle = function(_e)
            player_combo = false
            _e.state.can_attack = true
            if(_e.intention.left) _e.position.dx=-1 return 'run'
            if(_e.intention.right) _e.position.dx=1 return 'run'
            if _e.intention.x then 
                _e.intention.right=false
                _e.intention.left=false
                return get_player_attack_state(_e)
            end
            return "idle"
        end,
        _damaged = function(_e)
            local prog = _e.animation.progress_percentage()
            if(prog>1) return "idle"
            return "_damaged"
        end,
        _death = function(_e)
            if _e.animation.progress_percentage()>1 then
                del(entities,_e)
                load_scene_death()
            else
                spawn_shatter(_e.position.x,_e.position.y-8,{8,8,2},{})
                return "_death"
            end
        end,
        run = function(_e)
            _e.state.can_attack = true
            _e.sprite.flip_x=_e.position.dx<=0
            if _e.intention.x then 
                _e.intention.right=false
                _e.intention.left=false
                return get_player_attack_state(_e)
            end
            if(_e.intention.right) _e.position.dx = 1 return "run"
            if(_e.intention.left) _e.position.dx = -1 return "run"
            return "idle"
        end,
        punch_right_1 = function(_e) return punch_state(_e, "punch_right_1", true) end,
        punch_right_2 = function(_e) return punch_state(_e, "punch_right_2", true) end,
        punch_right_3 = function(_e) return punch_state(_e, "punch_right_3", false) end,
        punch_left_1 = function(_e) return punch_state(_e, "punch_left_1", true) end,
        punch_left_2 = function(_e) return punch_state(_e, "punch_left_2", true) end,
        punch_left_3 = function(_e) return punch_state(_e, "punch_left_3", false) end,
        shoot = function(_e)
            local p=_e.animation.progress_percentage()
            if p>1 then return "idle" end
            if p>.8 and not player_combo then
                player_combo=true
                if _e.inventory.bullets>0 then
                    spawn_bullet(_e.position.x, _e.position.dx)
                    _e.inventory.bullets -= 1
                else
                    -- todo: fx for missing bullets
                end
            end
            return "shoot"
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
        punch_right_1 = { ox=2, oy=-8, w=10, h=6 },
        punch_right_2 = { ox=2, oy=-8, w=10, h=6 },
        punch_right_3 = { ox=3, oy=-12, w=11, h=12 },
        punch_left_1 = { ox=-12, oy=-8, w=10, h=6 },
        punch_left_2 = { ox=-12, oy=-8, w=10, h=6 },
        punch_left_3 = { ox=-13, oy=-12, w=11, h=12 },
    }

    -- #region player entity
    player = new_entity({
        kind = "player",
        code = "playe",
        position = new_position(22,0,16,16,4),
        sprite = new_sprite({{x=16,y=0,w=16,h=16}}),
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
        intention = new_intention(),
        collider = new_collider(-4,-12,7,12,{}),
        state = new_state(player_states,"idle"),
        battle = new_battle(player_hitboxes,player_hurtboxes,{health=100, damage=1, cd_time= 45}),
        --inventory = new_inventory(3,true,2,98,{})
        inventory = new_inventory(2,true,50,96,{})
    })
    add(entities,player)
end

-- #region player control
function player_contol(_e)
    -- player attack
    _e.intention.x = btnp(_e.control.x)

    local as = {punch_right_1=true, punch_right_2=true, punch_right_3=true, punch_left_1=true, punch_left_2=true, punch_left_3=true, swing_right=true, swing_left=true, shoot=true}
    local is_attacking = as[_e.state.current] or false
    local is_dead = _e.state.current=="_death"

    -- player movement
    _e.intention.left = not(is_dead or is_attacking) and btn(_e.control.left)
    _e.intention.right = not(is_dead or is_attacking) and btn(_e.control.right)
    _e.intention.is_moving = _e.intention.left or _e.intention.right

    -- check for interaction
    local cel_x = flr((_e.position.x)/8)
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
    if(btnp(_e.control.up) and btnp(_e.control.down)) debug_items()
end

function get_player_attack_state(_e)
    local eq=_e.inventory.items[_e.inventory.active_i]
    if not eq or eq.kind=="gloves" then
        _e.battle.damage=10
        _e.battle.knock=false
        sfx(14)
        local ns={
            punch_right_1={s="punch_right_2",d=12},
            punch_right_2={s="punch_right_3",d=15,k=true},
            punch_left_1={s="punch_left_2",d=12},
            punch_left_2={s="punch_left_3",d=15,k=true}
        }
        ns = ns[_e.state.current]
        if ns then
            _e.battle.damage=ns.d + ((eq and eq.kind=="gloves") and 10 or 0)
            _e.battle.knock=ns.k
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
    player.inventory.bullets += 5
end

function punch_state(_e, state_name, can_combo)
    _e.state.can_attack = false
    local anim_perc = _e.animation.progress_percentage()
    if anim_perc > 1 then return "idle" end

    if can_combo and anim_perc == mid(.62, anim_perc, 1) then
        _e.state.can_attack = true
    end

    if _e.intention.x and player_combo then
        if _e.state.can_attack then 
            return get_player_attack_state(_e)
        else
            player_combo = false
        end
    end

    return state_name
end