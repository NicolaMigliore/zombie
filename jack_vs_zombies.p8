pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- jack vs zombies
-- by elfamir
function _init()
    -- set global lists
    entities = {}
    particles = {}

    -- load systems
    graphics_system = create_graphics_system()
    control_system = create_control_system()
    physics_system = create_physics_system()
    animation_system = create_animation_system()
    trigger_system = create_trigger_system()
    state_system = create_state_system()
    battle_system = create_battle_system()
    particle_system = create_particle_system()

    -- setup scene
    load_scene_title()

    -- debugging
    show_colliders = false
    show_hitboxes = false
    log_systems = false

    cam_x = 0

    _ui_i()
    _scene_highscore_i()

    -- update functions
    upd = {
        title = _scene_title_u,
        level = _scene_level_u,
        death = _scene_death_u,
        highscore = _scene_highscore_u
    }
    -- draw functions
    drw = {
        title = _scene_title_d,
        level = _scene_level_d,
        death = _scene_death_d,
        highscore = _scene_highscore_d
    }
end

function _update60()
    upd[mode]()
    _ui_u()
end

function _draw()
    drw[mode]()
end



function log(_text)
    printh(_text, "zombie/log")
end

--- sort the elements
function sort(_list, _comparison_f)
    for i = 2, #_list do
        local j = i
        while j > 1 and _comparison_f(_list[j - 1], _list[j]) do
            _list[j], _list[j - 1] = _list[j - 1], _list[j]
            j -= 1
        end
    end
end

-- pad string with zeros
function pad(v,length)
	local s="0000000000"..v
	return sub(s,#s-length+1)
end

-- generate id
local random = rnd
function new_guid(_kind_code)
    local s = pad(flr(time()),5)
    local r = pad(flr(random()*100),5)
    _kind_code = _kind_code or "00000"
    return s.."-"..r.."-".._kind_code
end

-- get entity by id
function get_entity(_id)
    if (entities == nil or #entities == 0) return nil
    local i,ent = 1,nil
    while i < #entities and ent==nil do
        if(entities[i].id == _id) ent = entities[i]
        i += 1
    end
    return ent
end

-- converts anything to string, even nested tables
function tostring(any)
    if type(any) == "function" then
        return "function"
    end
    if any == nil then
        return "nil"
    end
    if type(any) == "string" then
        return any
    end
    if type(any) == "boolean" then
        if any then return "true" end
        return "false"
    end
    if type(any) == "table" then
        local str = "{ "
        for k, v in pairs(any) do
            str = str .. tostring(k) .. "->" .. tostring(v) .. " "
        end
        return str .. "}"
    end
    if type(any) == "number" then
        return "" .. any
    end
    return "unkown"
    -- should never show
end

function str2frames(_s)
    local frames = {}
    for fs in all(split(_s,"|")) do
        -- get sprite parts
        local sp = split(fs,",")
        add(frames,{x=sp[1],y=sp[2],w=sp[3],h=sp[4]})
    end
    return frames
end


function _ui_i()
    blink_color1 = {
        colors={7,6,7},
        ci=1,
        color=7
    }
end

function _ui_u()
    -- update blick colors
    blink_color1.ci+=1/30
    if(blink_color1.ci>#blink_color1.colors+1) blink_color1.ci=1
    blink_color1.color=blink_color1.colors[flr(blink_color1.ci)]
end

function _ui_d()
    -- reset drawing offset
    camera()
    rectfill(0, 96, 127, 127, 0)

    -- hp bar color
    local hp_perc = player.battle.health / player.battle.max_health
    local hp_pals = {
        { 8, 2 },
        { 10, 9 },
        { 11, 3 },
        { 11, 3 },
    }
    local hp_pal_index = min(flr(hp_perc * #hp_pals) + 1, #hp_pals)
    pal(11, hp_pals[hp_pal_index][1])
    pal(3, hp_pals[hp_pal_index][2])

    -- ui background
    draw_window_frame(0,100,128,24)
    palt(0, false)
    palt(14, true)
    sspr(112,112,8,8,0,115)
    for i = 1, 14 do
        sspr(120, 112,8,8,i*8,115)
    end
    sspr(112,112,8,8,120,115,8,8,true)

    -- consume hp bar
    local missing_w = (1 - hp_perc) * 123
    rectfill(126 - missing_w, 118, 126, 120, 0)

    -- inventory
    if player.inventory and player.inventory.visible then
        --local inv_x, inv_y, inv_s = player.inventory.x, player.inventory.y, player.inventory.size
        local square_size =13--17--9
        local inv_x, inv_y, inv_s = 64-(square_size*player.inventory.size/2), 98, player.inventory.size
        rectfill(inv_x, inv_y, inv_x + square_size * inv_s, inv_y + square_size, 5)

        for i = 1, inv_s do
            local offset_x = square_size * (i - 1)
            local c = i == player.inventory.active_i and 10 or 7
            rect(inv_x + offset_x, inv_y, inv_x + square_size + offset_x, inv_y + square_size, 7)
            -- render items
            local item = player.inventory.items[i]
            if item then
                sspr(item.sprite.sprite.x, item.sprite.sprite.y, 8, 8, inv_x + (square_size/2-4) + offset_x, inv_y + (square_size/2-3))
            end
        end
        if #player.inventory.items > 0 then
            local offset_x = square_size * (player.inventory.active_i-1)
            rect(inv_x + offset_x + 1, inv_y + 1, inv_x + square_size + offset_x - 1, inv_y + square_size - 1, 9)
        end
    end

    -- bullets count
    sspr(8,8,8,8,100,103,8,8)
    print(player.inventory.bullets,108,105,6)

    -- level indicator
    print("level:"..level,7,105,6)

    palt()
end

function draw_window_frame(_x,_y,_w,_h)
    palt(0,false)
    palt(14,true)
    local rows, cols = flr(_h/8)-1, flr(_w/8)-1
    for i=0,rows do
        for j=0,cols do
            if i==0 then -- top
                -- first
                if(j==0) sspr(112,96,8,8,_x,_y)
                -- middle
                if(j>0 and j<cols) sspr(120,96,8,8,_x+j*8,_y)
                -- last
                if(j==cols) sspr(112,96,8,8,_x+j*8,_y,8,8,true)
            
            elseif i<rows then -- middle
                -- first
                if(j==0) sspr(104,96,8,8,_x,_y+i*8,8,8)
                -- middle
                if(j>0 and j<cols) sspr(0,96,8,8,_x+j*8,_y+i*8)
                -- last
                if(j==cols) sspr(104,96,8,8,_x+j*8,_y+i*8,8,8,true)
            else -- bottom
                -- first
                if(j==0) sspr(112,104,8,8,_x,_y+i*8,8,8)
                -- middle
                if(j>0 and j<cols) sspr(120,104,8,8,_x+j*8,_y+i*8,8,8)
                -- last
                if(j==cols) sspr(112,104,8,8,_x+j*8,_y+i*8,8,8,true)
            end
        end
    end
    palt()
end


--spawn smoke
function spawn_smoke(_x,_y,_colors,_opts)
	for i=0, 2+rnd(4) do
		local angle = _opts.angle or rnd()
		local max_size = _opts.max_size or 0.5+rnd(2)
        local max_age = _opts.max_age or 30
		local dx = sin(angle)*0.05
		local dy = cos(angle)*0.05

		if (_opts.dx) dx = _opts.dx
		if (_opts.dy) dx = _opts.dy 

		local p = new_particle(
			"smoke",
			new_position(_x,_y,max_size,0),
			dx,
			dy,
			max_age,
			_colors,
			max_size,
			{}
		)
		add(particles, p)
	end
end

function spawn_shatter(_x,_y,_colors,_opts)
	local tmp_dx, tmp_dy = _opts.dx or 0, _opts.dy or -1

	for i=1,rnd(10,15) do
		local angle = rnd()
		local dx = sin(angle)*rnd(1.5)+(tmp_dx/2)
		local dy = cos(angle)*rnd(1.5)+(tmp_dy/2)

		local p = new_particle(
			"pixel",
			new_position(_x,_y,1,0),
			dx,
			dy,
			30,
			_colors,
			1,
			{ has_gravity=true }
		)
		add(particles, p)
	end
end



--scenes
function _scene_title_u()
    if(btnp(❎)) load_scene_level()
    if(btnp(🅾️)) load_scene_highscore()

    -- advance flicker timer
    flicker_cnt -= 1
    if flicker_cnt < 0 then
        flicker_i += 1
        if(flicker_i > #flicker_times) flicker_i = 1
        flicker_cnt = flicker_times[flicker_i]
        flicker_off = not flicker_off
    end
end

function _scene_title_d()
    cls()
    pal()
    if(flicker_off) pal(13,0)
    sspr(72,96,32,16,32,32,64,32)
    -- propts
    print("❎ to start",32,74,blink_color1.color)
    print("🅾️ for highscores",32,80,blink_color1.color)
end

function load_scene_title()
    mode = "title"
    score = 0

    -- flicker
    flicker_times = {32,8,8}
    flicker_cnt = 32
    flicker_i = 1
    flicker_off = false
end


function _scene_level_u()
    animation_system.update()
    control_system.update()
    physics_system.update()
    trigger_system.update()
    state_system.update()
    battle_system.update()
    particle_system.update()

    -- move camera
    gamecamera.position.x = min(896,max(0,player.position.x - 30))
    camera(gamecamera.position.x)

    spawn_timer += 1
    if spawn_timer == 180 then
        -- span zombies
        local nz = min(flr(2 + level*0.5),5)
        local spawn = rnd(nz)/nz > 0.8 - (level / 50)
        if(spawn and #entities < 15) spawn_pack(nz)

        -- reset timer
        spawn_timer = 0
    end
end

function _scene_level_d()
    graphics_system.update({bg_color=1,draw_level=draw_level})
    _ui_d()
end

-- draw level background
function draw_level()
    palt(0,false)
    palt(14,true)
    map()
    palt()
end

function spawn_pack(_pack_size)
    for i=1,_pack_size do
        local placement_offset = (rnd(50)-25)
        local zombie_x = player.position.x + placement_offset + sgn(placement_offset)*110
        spawn_zombie(zombie_x)
    end
end

--- generate level entities
function create_level()
    level += 1
    score += 10
    particles = {}

    -- b - black
    -- w - window
    -- d - door
    -- r - road line
    -- s - sidewalk
    -- t - trash
    -- f - fence
    -- v - vertical road
    -- x - nothing
    cells = {
        b = 192,
        w = 193,
        d = 194,
        r = 195,
        s = 196,
        t = 197,
        f = 198,
        v = 199,
        x = 0
    }
    available_chunks = {
        "xxxxxxxxxxbwbwbx|bbbbbxxxxxbwbwbx|bbbbbxxxxxbbbbbx|bwbwbxxxxxbwbwbx|bwbwbxxxxxbwbwbx|bbbbbbbbbbbbbbbx|bwbbbbwbwbbwbwbx|bwbdbbwbwbbwbwbx|bbbdbbbbbbbbbbbx|ssssssssssssssss|bbbbbbbbbbbbbbbb|rrrrrrrrrrrrrrrr",
        "xxxxxxxxxxxbwbwb|xxxxxxxxxxxbwbwb|xxxxbbbbxxxbbbbb|xxxxbwbbxxxbwbwb|xxxxbwbbxxxbwbwb|xxxxbbbbxxxbbbbb|xxxxbwbbfffbwbbb|xxxxbwbbfffbwbdb|txxtbbbbfffbbbdb|ssssssssssssssss|bbbbbbbbbbbbbbbb|rrrrrrrrrrrrrrrr",
        "xbwbxxxxxxxbwbwb|xbwbxxxxxxxbwbwb|xbbbbbbxxxxbbbbb|xbbbbwbxxxxbwbwb|xbbbbwbxfffbwbwb|xbbbbbbxbbbbbbbb|xbwbbwbxbbbbwbbb|xbwbbwbxbdbbwbdb|tbbbbbbxbdbbbbdb|ssssssssssssssss|bbbbbbbbbbbbbbbb|rrrrrrrrrrrrrrrr",
        "xxxxxxxxxxxxxxxx|xxxxxxxxxxxxxxxx|xxxxxxxxxxxbbbbb|xxxxxxxxxxxbwbwb|xxxxxxxxxxxbwbwb|bbbbbbbxxxxbbbbb|bwbwbwbxxxxbwbwb|bwbwbwbxxxxbwbwb|bbbbbbbffffbbbbb|ssssssssssssssss|bbbbbbbbbbbbbbbb|rrrrrrrrrrrrrrrr",
        "xxxxxxxxxxxxxxxx|xxxxxxxxxxxxxxxx|bbbxxxxxxxbbbbbx|bwbxxxxxxxbwbwbx|bwbxxxxxxxbwbwbx|bbbxxxxxxxbbbbbx|bwbxxxxxxxbwbwbx|bwbxxxxxxxbwbwbx|bbbxxxxxxxbbbbbx|ssssbbvbbsssssss|bbbbbbbbbbbbbbbb|rrrrrrrrrrrrrrrr",
        "xxxxxxxbbbxxxxxx|xxxxxxxbwbxxxxxx|xxxxxxxbwbxxxxxx|xxxxxxxbbbxxxxxx|xxxxxxxbwbxxxxxx|bbbbbxxbwbxxxxxx|bwbwbxxbbbxxxxxx|bwbwbxxbdbxxxxxx|bbbbbffbdbtxxxxx|sssssssssssbbvbb|bbbbbbbbbbbbbbbb|rrrrrrrrrrrrrrrr",
        "bwbwbwbwbxxxxxxx|bwbwbwbwbxxxxxxx|bbbbbbbbbxxxxxxx|bwbwbwbwbxxxxxxx|bwbwbwbwbxxxffff|bbbbbbbbbxxxbbbb|bwbwbbbbbfffbwbw|bwbwbbdbbfffbwbw|bbbbbbdbbfffbbbb|ssssssssssssssss|bbbbbbbbbbbbbbbb|rrrrrrrrrrrrrrrr",
        "xxxxxxxxxxxxxxxx|xxxxxxxxxxxxxxxx|xxxxxxxxxxxxxxxx|xxxxxxxxxxxxxxxx|fffffxxxxxxxxxxx|bbbbbxxxxxxxxxxx|bwbbbxxxxxxxxxxx|bwbdbxxxxxxxxxxx|bbbdbffftxxxxxxx|ssssssssssssssss|bbbbbbbbbbbbbbbb|rrrrrrrrrrrrrrrr",
        "bwbxxxxxxxxxxbwb|bwbxxxxxxxxxxbwb|bbbxxxxxbbbbbbbb|bwbxxxxxbwbwbbwb|bwbxxxxxbwbwbbwb|bbbxxxxxbbbbbbbb|bwbxxtxxbwbbbbwb|bwbxtttxbwbdbbwb|bbbtttttbbbdbbbb|ssssssssssssssss|bbbbbbbbbbbbbbbb|rrrrrrrrrrrrrrrr",
        "xxxxxxxxxxxxxbwb|xxxxxxxxxxxxxbwb|bbbxxxxxbbbxxbbb|bwbxxxxxbwbxxbwb|bwbxxfffbwbxxbwb|bbbxxbbbbbbxxbbb|bwbxxbbwbwbffbwb|bwbttbbwbwbffbwb|bbbttbbbbbbffbbb|ssssssssssssssss|bbbbbbbbbbbbbbbb|rrrrrrrrrrrrrrrr",
        "xxxxxxxxxxxxxxxx|xxxxxxxxxxxxxxxx|xbbbxxxxbbbxxxxx|xbbdxxxxbwbxxxxx|xbbdffffbwbxxxxx|xbbbbbbbbbbxxxxx|xbwbwbbwbwbxxxxx|xbwbwbbwbwbxxxxx|tbbbbbbbbbbtxxxx|ssssssssssssssss|bbbbbbbbbbbbbbbb|rrrrrrrrrrrrrrrr",
        "xxxxxxxxxxxxxxxx|xxxxxxxxxxxxxxxx|xxxxbbbxxxbbbbbx|xxxxbwbxxxbwbwbx|xxxxbwbxxxbwbwbx|bbbbbbbxxxbbbbbx|bwbwbwbfffbwbwbx|bwbwbwbfffbwbwbx|bbbbbbbfffbbbbbx|ssssssssssssssss|bbbbbbbbbbbbbbbb|rrrrrrrrrrrrrrrr",
        "xxxbwbxxxxxxxxxx|xxxbwbxxxxxxxxxx|bbbbbbxxxxxxxxxx|bwbbwbxxxxxxxxxx|bwbbwbxxxxxxxxxx|bbbbbbxxxbbbbbbb|bbbbwbxxxbwbwbwb|bdbbwbxxxbwbwbwb|bdbbbbfffbbbbbbb|ssssssssssssssss|bbbbbbbbbbbbbbbb|rrrrrrrrrrrrrrrr"
    }

    -- draw chuncks
    for chunk_i=0,63 do
        local chunk = rnd(available_chunks)
        local rows = split(chunk,"|")
        for r=0,11 do
            row = rows[r+1]
            for c=0,15 do
                mset(c+chunk_i*16,r,cells[row[c+1]])
            end
        end
    end

    -- level-end trigger
    add(entities,new_entity({
        kind="level_trigger",
        position = new_position(1016,64,1024,80),
        triggers = {new_trigger(1,1,8,16,function(_e,_o) if(_o.kind == "player") create_level() end,"always")}
    }))

    -- set player position
    player.position.x = 22
    player.position.y = 60
end

function load_scene_level()
    entities = {}
    level = 0
    score = 0
    spawn_timer = 0
    mode = "level"
    
    -- setup entities
    _camera_i()
    _player_i()

    -- create level
    create_level()
end


function _scene_death_u()
    if(btnp(❎)) load_scene_highscore()
end

function _scene_death_d()
    camera()

    draw_window_frame(10,7,107,90)

    print("you are",35,15,7)
    print("dead!",67,15,8)

    print("level:"..level,35,25,6)
    print("score:"..score,35,33,6)

    print("❎ to continue",32,74,blink_color1.color)
end

function load_scene_death()
    mode = "death"
end


function _scene_highscore_i()
	cartdata("jack_vs_zombies_1")
	hscores = {}
	load_hs()
	sort_hs()
	hs_chars = split("a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z")
	initials = { 1, 1, 1 }
	initials_i = 1
end
function _scene_highscore_u()
	if score > 0 then 
		-- input initials
		if btnp(➡️) then
			initials_i+=1
			if initials_i>3 then
				initials_i=1
			end
			sfx(17)
		end
		if btnp(⬅️) then
			initials_i-=1
			if initials_i<1 then
				initials_i=3
			end
			sfx(17)
		end
		if btnp(⬆️) then
			initials[initials_i]+=1
			if initials[initials_i]>#hs_chars then
				initials[initials_i]=1
			end
			sfx(18)
		end
		if btnp(⬇️) then
			initials[initials_i]-=1
			if initials[initials_i]<1 then
				initials[initials_i]=#hs_chars
			end
			sfx(18)
		end


		-- save score
		if (btnp(❎)) add_hs(initials[1],initials[2],initials[3],score) sfx(17) load_scene_level()
		if (btnp(🅾️)) add_hs(initials[1],initials[2],initials[3],score) sfx(17) load_scene_title()
	else
		-- go to title
		if (btnp(🅾️)) load_scene_title()
	end
end
function _scene_highscore_d()
	camera()
	draw_window_frame(10, 7, 107, 90)

	print("high scores",40,14,7)
	-- print scores
	for i=1,5 do
		local hs = hscores[i]
		local y=20+(i*6)
		local s=" "..hs[4]
		--rank
		print(i.." - ",30,y,7)
		--name
		local p_name=hs_chars[hs[1]]
		p_name=p_name..hs_chars[hs[2]]
		p_name=p_name..hs_chars[hs[3]]
		print(p_name,45,y,7)
		--score
		print(s,100-#s*4,y,7)
	end

	if score > 0 then
		--initials input 
		for i=1,#initials do
			local ini_c=7
			if(i==initials_i) ini_c = 8
			print(hs_chars[initials[i]],42+(i*4),66,ini_c)
			print(score,60,66,7)
		end

		print("❎ to restart",36,74,blink_color1.color)
	end
	print("🅾️ to title",36,80,blink_color1.color)
end

function reset_hs()
	hscores = {
		{ 1, 1, 1, 0 },
		{ 1, 1, 1, 0 },
		{ 1, 1, 1, 0 },
		{ 1, 1, 1, 0 },
		{ 1, 1, 1, 0 }
	}
end

-- load high scores
function load_hs()
	--create default values if missing
	if dget(0) != 1 then
		reset_hs()
		save_hs()
	end

	local j = 1
	for i = 1, 5 do
		hscores[i] = {}
		hscores[i][1] = dget(j)
		hscores[i][2] = dget(j + 1)
		hscores[i][3] = dget(j + 2)
		hscores[i][4] = dget(j + 3)
		j += 4
	end
	sort_hs()
end

-- Saves all high scores
function save_hs()
	--indicate there is a saved data
	dset(0, 1)
	--store highscores
	local j = 1
	for i = 1, 5 do
		dset(j, hscores[i][1])
		dset(j + 1, hscores[i][2])
		dset(j + 2, hscores[i][3])
		dset(j + 3, hscores[i][4])
		j += 4
	end
end

function add_hs(c1, c2, c3, score)
	add(hscores, { c1, c2, c3, score })
	sort_hs()
	save_hs()
end

function sort_hs()
	for i = 1, #hscores do
		local j = i
		while j > 1 and hscores[j - 1][4] < hscores[j][4] do
			hscores[j], hscores[j - 1] = hscores[j - 1], hscores[j]
			j = j - 1
		end
	end
end

function load_scene_highscore()
	mode = "highscore"
end


function _scene_title_u()
    if(btnp(❎)) load_scene_level()
    if(btnp(🅾️)) load_scene_highscore()

    -- advance flicker timer
    flicker_cnt -= 1
    if flicker_cnt < 0 then
        flicker_i += 1
        if(flicker_i > #flicker_times) flicker_i = 1
        flicker_cnt = flicker_times[flicker_i]
        flicker_off = not flicker_off
    end
end

function _scene_title_d()
    cls()
    pal()
    if(flicker_off) pal(13,0)
    sspr(72,96,32,16,32,32,64,32)
    -- propts
    print("❎ to start",32,74,blink_color1.color)
    print("🅾️ for highscores",32,80,blink_color1.color)
end

function load_scene_title()
    mode = "title"
    score = 0

    -- flicker
    flicker_times = {32,8,8}
    flicker_cnt = 32
    flicker_i = 1
    flicker_off = false
end



--ecs
-- #region position component ---
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

-- #region sprite component ---
-- @param _sprite | sprites object in the form { x = <x coord>, y = <y coord> ,w = <sprite width in pixels>,h = <sprite height in pixels>,pal_rep = <palette replacent list {{c1,c2}}> }
-- @param _flip_x | boolean to describe if the sprite should be flipped on the x axis
-- @param _flip_y | boolean to describe if the sprite should be flipped on the y axis
-- @param _palette_replace | list of couples of colors to replace in the form {{c1,c2}}
function new_sprite(_sprite,_flip_x,_flip_y)
    local s = {
        sprite = _sprite,
        flip_x = _flip_x or false,
        flip_y = _flip_y or false,
    }
    return s
end

-- #region animation component ---
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

-- #region state component ---
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

-- #region control component
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

-- #region intention component
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

-- #region battle component
function new_battle(_hitboxes,_hurtboxes,_opts)
    local health = _opts.health or 100
    local b ={
        hitboxes = _hitboxes,
        hurtboxes = _hurtboxes,
        health =  health,
        max_health = health,
        cd_time = _opts.cd_time or 180,
        cooldown = _opts.cd_time or 0,
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

-- #region collider box component
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
    local is_solid,gravity,mass,can_collide = true, true, 1, true
    if (_opts.is_solid != nil) is_solid = _opts.is_solid
    if (_opts.gravity != nil) gravity = _opts.gravity
    if (_opts.mass != nil) mass = _opts.mass
    if (_opts.can_collide != nil) can_collide = _opts.can_collide

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

-- #region trigger box component
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

-- #region inventory component
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

-- #region create entity ---
function new_entity(_opts)
    local e = {
        id = new_guid(_opts.code),
        kind = _opts.kind,
        position = _opts.position,
        sprite = _opts.sprite,
        control = _opts.control,
        intention = _opts.intention,
        collider = _opts.collider,
        animation = _opts.animation,
        triggers = _opts.triggers,
        state = _opts.state or new_state({},"idle"),
        battle = _opts.battle,
        inventory = _opts.inventory,
    }
    return e
end

-- #region create particle --
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
    }
    return p
end


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


function _camera_i()
    gamecamera = new_entity({
        kind = "gamecamera",
        position = new_position(0,0,128,128),
    })
    add(entities,gamecamera)
end


function _player_i()
    -- #region player animation
    local player_animation = {
        idle = {
            frames = str2frames("32,0,16,16|32,0,16,16|32,0,16,16|48,0,16,16|16,0,16,16|32,0,16,16"),
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
            speed = 0.5
        },
        _death = {
            frames = str2frames("48,112,8,8|56,112,8,8|48,120,8,8|56,120,8,8"),
            speed = 0.1
        },
        run = {
            frames = str2frames("0,16,16,16|16,16,16,16|32,16,16,16|48,16,16,16|64,16,16,16|80,16,16,16|96,16,16,16|112,16,16,16"),
            speed = 0.15,
            loop = true,
        },
        punch_right = {
            frames = str2frames("16,0,16,16|0,32,16,16|16,32,16,16|32,32,16,16|48,32,16,16"),
            speed = 0.2
        },
        punch_left = {
            frames = str2frames("16,0,16,16|0,32,16,16|16,32,16,16|32,32,16,16|48,32,16,16"),
            speed = 0.2
        },
        swing_right = {
            frames = str2frames("16,0,16,16|80,32,16,16|96,32,16,16|112,32,16,16|0,48,16,16|16,48,16,16|32,48,16,16|32,48,16,16"),
            speed = 0.2
        },
        swing_left = {
            frames = str2frames("16,0,16,16|80,32,16,16|96,32,16,16|112,32,16,16|0,48,16,16|16,48,16,16|32,48,16,16|32,48,16,16"),
            speed = 0.2
        },
        shoot = {
            frames = str2frames("16,0,16,16|64,0,16,16|80,0,16,16|96,0,16,16|112,0,16,16"),
            speed = 0.2
        },
    }

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
            local damage_ended = _e.animation.anim_i > #_e.animation.animations["_damaged"].frames
            if(damage_ended) return "idle"
            -- continue damaged state
            return "_damaged"
        end,
        _death = function(_e)
            spawn_shatter(_e.position.x+8,_e.position.y+8,{8,8,2},{})
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
                return get_player_attack_state(_e)
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
        swing_right = function(_e)
            local attack_ended = _e.animation.anim_i > #_e.animation.animations["swing_right"].frames

            -- idle
            if(attack_ended) return "idle"

            -- keep swinging
            return "swing_right"
        end,
        swing_left = function(_e)
            local attack_ended = _e.animation.anim_i > #_e.animation.animations["swing_left"].frames

            -- idle
            if(attack_ended) return "idle"

            -- keep swinging
            return "swing_left"
        end,
        shoot = function(_e)
            local attack_ended = _e.animation.anim_i > #_e.animation.animations["shoot"].frames
            
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
        punch_right = { ox=12, oy=8, w=3, h=4 },
        swing_left = { ox=-4, oy=8, w=7, h=4 },
        swing_right = { ox=14, oy=8, w=7, h=4 },
    }

    -- #region player entity
    player = new_entity({
        kind = "player",
        code = "playe",
        position = new_position(22,60,16,16,2),
        sprite = new_sprite({x=16,y=0,w=16,h=16}),
        animation = new_animation(player_animation,"idle"),
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


function spawn_zombie(_x)
    local zombie_animations = {
        idle = {
            frames = str2frames("48,48,16,16|48,48,16,16|48,48,16,16|64,48,16,16|80,48,16,16|96,48,16,16|48,48,16,16"),
            speed = 0.1,
            loop = true,
        },
        _damaged = {
            frames = {
                {x=80,y=48,w=16,h=16,pal_rep={{3,7},{2,7},{5,7},{10,5},{8,5}}},
                {x=80,y=48,w=16,h=16,pal_rep={{3,8},{2,8},{5,8},{10,5},{8,5}}},
                {x=80,y=48,w=16,h=16,pal_rep={{3,7},{2,7},{5,7},{10,5},{8,5}}},
                {x=80,y=48,w=16,h=16,pal_rep={{3,8},{2,8},{5,8},{10,5},{8,5}}},
                {x=96,y=48,w=16,h=16,pal_rep={{3,7},{2,7},{5,7},{10,5},{8,5}}},
                {x=96,y=48,w=16,h=16,pal_rep={{3,8},{2,8},{5,8},{10,5},{8,5}}},
                {x=96,y=48,w=16,h=16,pal_rep={{3,7},{2,7},{5,7},{10,5},{8,5}}},
                {x=96,y=48,w=16,h=16,pal_rep={{3,8},{2,8},{5,8},{10,5},{8,5}}},
            },
            speed = 0.3,
            loop = true,
        },
        _death = {
            frames = str2frames("0,64,16,16|48,80,16,16|64,80,16,16|80,80,16,16|96,80,16,16|112,80,16,16|112,80,16,16|112,80,16,16|112,80,16,16|112,80,16,16|112,80,16,16"),
            speed = 0.1,
            loop = false,
        },
        run = {
            frames = str2frames("112,48,16,16|0,64,16,16|16,64,16,16|32,64,16,16|48,64,16,16|64,64,16,16"),
            speed = 0.1,
            loop = true,
        },
        attack_right = {
            frames = str2frames("48,48,16,16|80,64,16,16|96,64,16,16|112,64,16,16|0,80,16,16|16,80,16,16|32,80,16,16|32,80,16,16"),
            speed = 0.5,
            loop = false,
        },
        attack_left = {
            frames = str2frames("48,48,16,16|80,64,16,16|96,64,16,16|112,64,16,16|0,80,16,16|16,80,16,16|32,80,16,16|32,80,16,16|96,64,16,16|96,64,16,16|96,64,16,16|80,64,16,16|80,64,16,16|80,64,16,16"),
            speed = 0.5,
            loop = false,
        },
    }
    local zombie_states = {
        idle = function(_e)
            -- move zombie
            if(_e.intention.left) _e.position.dx=-1 return "run"
            if(_e.intention.right) _e.position.dx=1 return "run"

            -- attack
            if(_e.intention.x) sfx(14) return _e.position.dx > 0 and "attack_right" or "attack_left"

            -- idle
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
            -- remove collider, control and intentions
            _e.collider = nil
            _e.control.control = nil
            _e.intention.left,_e.intention.left = false,false

            local death_ended = _e.animation.anim_i > #_e.animation.animations["_death"].frames

            -- delete entity
            if death_ended then
                del(entities,_e)
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
            if(_e.intention.x) sfx(14) return _e.position.dx > 0 and "attack_right" or "attack_left"
            -- keep moving
            if(_e.intention.right) _e.position.dx = 1 return "run"
            if(_e.intention.left) _e.position.dx = -1 return "run"
            -- idle
            return "idle"
        end,
        attack_left = function(_e)
            local attack_ended = _e.animation.anim_i > #_e.animation.animations["attack_left"].frames
            -- idle
            if(attack_ended) return "idle"
            -- keep punching
            return "attack_left"
        end,
        attack_right = function(_e)
            local attack_ended = _e.animation.anim_i > #_e.animation.animations["attack_right"].frames
            -- idle
            if(attack_ended) return "idle"
            -- keep punching
            return "attack_right"
        end,  
    }
    local zombie_hurtboxes = {
        idle = { ox=4, oy=3, w=7, h=12 },
        run = { ox=4, oy=3, w=7, h=12 },
        attack_right = { ox=4, oy=3, w=7, h=12 },
        attack_left = { ox=4, oy=3, w=7, h=12 },
    }
    local zombie_hitboxes = {
        attack_left = { ox=0, oy=8, w=3, h=4 },
        attack_right = { ox=12, oy=8, w=3, h=4 }
    }
    local new_zombie = new_entity({
        kind = "zombie",
        code = "zombi",
        position = new_position(_x,60,16,16,2),
        sprite = new_sprite({x=48,y=48,w=16,h=16}),
        animation = new_animation(zombie_animations,"idle"),
        state = new_state(zombie_states,"idle"),
        intention = new_intention(),
        control = new_control({spd_x = 0.2, control_func=zombie_control}),
        collider = new_collider(4,3,7,12,{is_solid=false}),
        battle = new_battle(zombie_hitboxes,zombie_hurtboxes,{health=100, damage=5}),
    })
    add(entities, new_zombie)
end

function zombie_control(_e)
    -- reset intentions
    _e.intention.right = false
    _e.intention.left = false
    _e.intention.x = false

    local is_attacking = _e.state.current == "attack_right" or _e.state.current == "attack_left"
    local is_damaged = _e.state.current == "_damaged" or _e.state.current == "_death"
    local distance = (_e.position.x+8) - (player.position.x+8)
    -- zombies always know where the player is

    if abs(distance) > 7 and not is_attacking and not is_damaged then
        -- walk
        local direction = sgn(distance)
        if(direction==-1) _e.intention.right = true
        if(direction==1)  _e.intention.left = true
    else
        -- attack
        _e.intention.x = true
    end
end


-- create new bullet
function spawn_bullet(_x,_dir)
    -- set bullet position and speed
    local bullet_speed = _dir > 0 and 2 or -2
    _x = _dir > 0 and _x+10 or _x-2

    local bullet_states = {
        travel = function(_e)
            -- check for collision with zombie
            local bullet_collisions = physics_system.collisions[_e.id]
            if bullet_collisions != nil then
                local oi = 1
                local collided_with_zombie = false
                while oi <= #bullet_collisions and collided_with_zombie == false do
                    local ent = get_entity(bullet_collisions[oi])
                    if(ent.kind=="zombie") collided_with_zombie = true return "hit"
                    oi += 1
                end
            end
            -- keep traveling
            return "travel"
        end,
        hit = function(_e)
            sfx(14)
            return "_death"
        end,
        _death = function(_e)
            del(entities,_e)
        end,
    }

    local bullet_hitboxes = {
        hit = { ox=0, oy=0, w=2, h=1 }
    }

    -- #region bullet entity
    local new_bullet = new_entity({
        kind = "bullet",
        code = "bulle",
        position = new_position(_x,70,2,1),
        sprite = new_sprite({x=8,y=96,w=2,h=1,pal_rep={{10,6}},}),
        intention = new_intention(),
        control = new_control({spd_x = bullet_speed, control_func = bullet_control}),
        state = new_state(bullet_states, "travel"),
        battle = new_battle(bullet_hitboxes,{},{health=100, damage=70}),
        collider = new_collider(0,0,2,1,{is_solid=false}),
    })
    add(entities, new_bullet)
end

-- control bullet movement
function bullet_control(_e)
    -- move bullet
    _e.position.x += _e.control.spd_x

    -- delete bullet after a certain distance
    if(abs(_e.position.x - player.position.x)>130) _e.state.previous = _e.state.current _e.state.current = "_death"
end



__gfx__
00000000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700e000000e0000099999900000000009999990900000000000000000000000099999909000000099999909000000009999990900000000999999090000
00077000e000000e0000099999990900000009999999900000000999999090000000099999999000000099999999000000009999999900000000999999990000
00077000ee0deeee0000999ffff990000000999ffff9000000000999999990000000999ffff90000000999ffff900000000999ffff900000000999ffff900000
00700700ee00eeee000099ffffff0000000099ffffff00000000999ffff90000000099ffffff000000099ffffff0000000099ffffff0000000099ffffff00000
00000000eeeeeeee0000f9f7cf7cf0000000f9f7cf7cf000000099ffffff00000000f9f7cf7cf000000f9f7cf7cf0000000f9f7cf7cf0000000f9fffffff0000
00000000eeeeeeee0000fffffffff0000000fffffffff0000000f9f7cf7cf0000000fffffffff000000fffffffff0000000fffffffff0000000fffffffff0000
eeeeeeeeeeeeeeee00000fff77ff000000000fff77ff00000000fffffffff00000000fff77ff00000000fff77ff000000000fff77ff000000000fff77ff00000
eeeeee8eeee99eee000000fffff00000000000fffff0000000000ffff7ff0000000000fffff0000000000fffff00000000000fffff00000000000fffff006000
eeeee0e8ee9799ee00000447744000000000044774400000000000fffff000000000044774400000000004474400000000000044705550000000004470555600
eeee0ee8ee9999ee000040477404000000004047740400000000044774400000000040477404000000000447404000000000004444f000000000004444f06000
eee0eeeeee9799ee0000f047740f00000000f047740f0000000040477404000000005047740f00000000004f50f0000000000044700000000000004470000000
8e0eeeeeee9799ee000000cccc000000000000cccc0000000000f0cccc0f0000000050cccc000000000000cc50000000000000cccf000000000000cccf000000
e0eeeeeeee9999ee000000c00c000000000000c00c000000000000c00c000000000050c00c000000000000c0c0000000000000c0c0000000000000c0c0000000
eeeeeeeeeeeeeeee0000004004000000000000400400000000000040040000000000004004000000000000404000000000000040400000000000004040000000
00000000000000000000000000000000000000000000000000000999999000000000000000000000000000000000000000000000000000000000099999900000
00000000000000000000000000000000000000999999000000000999999909000000000000000000000000000000000000000099999900000000099999990900
0000009999990900000000000000000000000099999990900000999ffff990000000009999990900000000000000000000000099999990900000999ffff99000
0000009999999900000000099999909000000999ffff9900000099ffffff00000000009999999900000000000000000000000999ffff9900000099ffffff0000
00000999ffff900000000009999999900000099ffffff0000000f9f7cf7cf00000000999ffff900000000009999990900000099ffffff0000000f9f7cf7cf000
0000099ffffff000000000999ffff90000000f9f7cf7cf000000fffffffff0000000099ffffff000000000099999999000000f9f7cf7cf000000fffffffff000
00000f9f7cf7cf0000000099ffffff0000000fffffffff0000000fff77ff000000000f9f7cf7cf00000000999ffff90000000fffffffff0000000fff77ff0000
00000fffffffff00000000f9f7cf7cf0000000fff77ff000000000fffff0000000000fffffffff0000000099ffffff00000000fff77ff000000000fffff00000
000000fff77ff000000000fffffffff00000000fffff00000000004440000000000000fff77ff000000000f9f7cf7cf00000000fffff00000000004470000000
0000000fffff00000000000fff77ff00000000044700000000000d4474f000000000000fffff0000000000fffffffff00000000447000000000004447dd00000
000000444700000000000004fffff000000000d4470000000000d04470000000000000d4440000000000000fff77ff0000000044470000000000f04470000000
0000040447000000000000444700000000000d0447000000000000c4cdd0000000000d0444000000000000d4fffff00000000f0447000000000000d4ccc00000
00000f0447d00000000000f44700000000000004fd00000000004c00000d000000000d0444f00000000000d447000000000000044c0000000000dd0000040000
00000004ccc00000000000044c0000000000000c00d00000000000000000000000000004cdd0000000000000fc0000000000000d00c000000000000000000000
000000dd000400000000000dd0c000000000000c0d00000000000000000000000000004c000d000000000004c0d000000000000d040000000000000000000000
000000000000000000000000004000000000004000000000000000000000000000000000000000000000000000d00000000000d0000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00099999909000000000000000000000000000000000000000000000000000000000000000000000000009999990900000099999909000000000000000000000
00099999999000000099999909000000000000009999990900000000999999090000000099999909000009999999900000099999999000000099999909000000
00999ffff900000000999999990000000000000099999999000000009999999900000000999999990000999ffff9000000999ffff90000000099999999000000
0099ffffff0000000999ffff900000000000000999ffff900000000999ffff900000000999ffff90000099ffffff00000099ffffff0000000999ffff90000000
00f9f7cf7cf00000099ffffff0000000000000099ffffff0000000099ffffff0000000099ffffff00000f9f7cf7cf00000f9f7cf7cf00000099ffffff0000000
00fffffffff000000f9f7cf7cf0000000000000f9f7cf7cf0000000f9fffffff0000000f9f7cf7cf0000fffffffff00000fffffffff000000f9f7cf7cf000000
000fff77ff0000000fffffffff0000000000000fffffffff0000000fffffffff0000000fffffffff00000fff77ff0000000fff77ff0000000fffffffff000000
0000fffff000000000fff77ff000000000000000fff77ff000000000fff77ff000000000fff77ff0000000fffff000000000fffff000000000fff77ff0000000
0000047744400000000fffff00000000000000004fffff00000000044fffff00000000044fffff0000000447744000000000047744400000000fffff00000000
00004447700f0000000047744f0000000000000447400000000000f0444444f0000000f0444444f0000040477404000000004447700f0000500047744f000000
00004044770000000000447740000000000000044f400000000000044440070000000004444007000000f547740f000000004044770000000500447740000000
000f00cccc00000000f4004cc0000000000070ccc904f000000000ccc4007000000000ccc4000000000050cccc000000000f00cccc00000000f4044cc0000000
000000c00c000000000000cc0c00000000000c077c00000000000c000770000000000c000c070000000500c00c000000005000c00c000000000500cc0c000000
00000400040000000000040000400000000040004000000000004000400000000000400040000000005000400400000005000400040000000000040000400000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000660000000000000000000000000000000000000000000000000000000000033333300000000003333330000000000000000000000000033333300000
00000009996990900000009999990900000000999999090000000333333000000000333333330000000033333333000000000333333000000000333333330000
00000009999599900000009999999900000000999999990000003333333300000003333333333000000333333333300000003333333300000003333333333000
000000999f5ff90000000999ffff600000000999ffff6000000333333333300000033aa33333300000033aa333333000000333333333300000033aa333333000
00000099f5ffff000000099ffffff6000000099ffffff00000033aa33333300000033aa33aa3300000033aa33aa33000000333333333300000033aa33aa33000
000000f957cf7cf000000f9fffffff0000000f9f7cf7cf6000033aa33aa330000003333333333000000333333333300000033333333330000003333333333000
000000fffffffff000000fffffffff0000000fffffffff6000033333333330000003333333333000000333333333300000033aa33aa330000003333333333000
00000054ff77ff00000000fff77ff005000000fff77ff00500033333333330000000338883330000000033888333000000033333333330000000338883330000
00000004fffff0000000044fffff00500000044fffff005000003388833300000000033333300000000003333330000000003388833300000000033333300000
00000004700000000000f044440005000000f0444400050000000333333000000000023333200000000022333322000000000333333000000000003333000000
00000047744000000000044440405000000004444040500000000233332000000000202222020000000030222203000000000233332000000000022322000000
00000cccc04f00000000ccc4000f00000000ccc4000f000000002022220200000000302222030000000000222200000000002022220200000000002220230000
0000c000c0000000000c000c00500000000c000c0050000000003022220300000000002222000000000000222200000000003022220300000000002520000000
00040004000000000040004000000000004000400000000000000050050000000000005005000000000000500500000000000050050000000000000050000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000333333000000000000000000000000000000000000000000333333000000000000000000000000000000000000000000000000000000000000000000000
00003333333300000000000000000000000003333330000000003333333300000000000000000000000033333300000000333300000000000000000000000000
00033333333330000000033333300000000033333333000000033333333330000000033333300000000333333330000003333333000000000033330000000000
00033aa3333330000000333333330000000333333333300000033333333330000000333333330000003333333333000033333a33300000000333333300000000
00033aa33aa33000000333333333300000033aa33333300000033aa33aa3300000033aa3333330000033aa33333300003333a33330000000333a333330000000
000333333333300000033aa33aa3300000033aa33aa33000000333333333300000033aa33aa330000033aa33aa3300003333333333000000333a333330000000
00033333333330000003333333333000000333333333300000033333333330000003333333333000003333333333000033aa3333830000003333333833000000
00003388833300000003333333333000000333333333300000003388833300000003333333333000003333333333000033aa33383300000033aa338833000000
000003333330000000033333333330000000338883330000000003333330000000033333333330000003388833300000333333833300000033aa338833000000
00000033330000000000338883330000000003333330000000000033330000000000338883330000000033333300000003333333300000003333338333000000
00000223220000000000033333300000000000333300000000000222222300000000033333300000000022222200000000022222000000000333333330000000
00000022202300000000023333000000000002222223000000000023200000000000023333000000000020222200000000020222000000000002222200000000
00000022200000000000002322300000000000232000000000000022200000000000002320230000000003222230000000003222230000000020022220000000
00000022200000000000002220000000000000222500000000000022200000000000002220000000000000222200000000000022050000000003002235000000
00000005500000000000005050000000000000500000000000000050050000000000005050000000000000500500000000000500000000000000050000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006600333333000000000033333300000000003333330000000333333000000000000000000000000000000000000000000000000000000000000000000000
00060003333333300000000333333330000000033333333000003333333300000000033333300000000000000000000000000000000000000000000000000000
00600033333333330000003333333333000000333333333300033333333330000000333333330000000000000000000000000000000000000000000000000000
06000633333333330000003333333333000000333333333300033aa3333330000003333333333000000000003333330000000000000000000000000000000000
06006033aa33aa33000000333aa33aa3000000333aa33aa300033aa33aa33000000333aa33333000000000033333333000000000000000000000000000000000
0600003333333333000000333333333300000033363333330003333333333000000333aa33a33000000000333333333000000000000000000000000000000000
00000033388833330000003663888333000000333368833300033333333330000003333333333000000000333333333000000000000000000000000000000000
000003033888833000000063338888300000000333868830000033888333000000033333333330000000003333aa333000000000000000000000000000000000
000000203333330000000000233333000000000033363360000003333330000000003338883300000000003333aa333000000000000000000000000000000000
00000002233330000000000223333000000000022233300600003033333000000000033333300000000000338333330000000000033333000000000003333300
00000002222200000000000222220000000000022222000000000222220000000000303333300000000000233833300000000000333633300000000033333330
00000022222000000000002222200000000000222220000000000022200000000000022222000000000002223383000000000003363336330000000333333333
00000022250000000000002222000000000000222200000000000022200000000000002220000000000002322000000000003003336363330000300333333333
000005000000000000000500050000000000050005000000000000505000000000000022200000000005222200000000050000033836a33305222223383aa333
00000000aaaaa5a0155555510000000066666666e555555ee5e5e5e500070000eeeeeeee0ccccc00c000cccc0c000c000000000067000000ee67777777777777
00000000aaaa5a5a55555555000000006666666655555555e5e5e5e50000000055555555c11111c0c00c1111c1c0c1c00000000067000000e666666666666666
00000000aaaaaaa0555555550000000066666666e565665ee5e5e5e500000000e565665e0c111c0c1c0c11ccc1cc11c000000dd0670000006700000000000000
00000000aaaa5a5a555555557770000766666666e565665e5e5e5e5e00000000e565665e00c1c0cc1ccc1c00c1c11c00d0d0d22d670000006700000000000000
00000000aaaaa5a0555555550000000066666666e565665e5e5e5e5e00000000e565665e0cc1c0c1c1cc1c00c111c00d2d2d2dd0670000006700000000000000
00000000aaaa5a5a555555550000000066666666e565665e5e5e5e5e00070000e565665ec1c1c0c111cc1c00c1c11c0d2d2d222d670000006700000000000000
00000000aaaaaaa0555555550000000077777777e565665e5e5e5e5e00070000e565665ec111c0c1c1cc11ccc1cc11cd222ddd2d670000006700000000000000
00000000aaaa5a5a155555510000000055555555ee5555eee5e5e5e500070000ee5555ee0c11cc11c11c1111c1c0c1c0d2d222d0670000006700000000000000
eeeeeeee009999000555555000000000000000000000000000000000000000000000000000cc00cc0cc0cccc0c000c000d0ddd00000000006700000000000000
ee8888ee09999990566bb66500000000000000000000000000000000000000000000000000888088808888088088808880088800000000006700000000000000
e88888ee99999999566bb66500000000000000000000000000000000000000000000000008222822282222822822282228822280000000006700000000000000
e888828e999999995bbbbbb500000000000000000000000000000000000000000000000000882828282222828282882888288800000000006700000000000000
e888888e099999905bbbbbb500000000000000000000000000000000000000000000000000828828282882822882882280822800000000006700000000000000
e88888ee00999900566bb66500000000000000000000000000000000000000000000000008288828282882828282882880888280000000006600000000000000
ee888eee00099000566bb6650000000000000000000000000000000000000000000000000822282228288282282228222822280000000000e667777777777777
ee222eee00090000055555500000000000000000000000000000000000000000000000000088808880800808808880888088800000000000ee66666666666666
0000000000000000000000000000000000000000000000000800000000000080000000000000000000000000000000000000000000000000ee77777777777777
0000000000000000000000000000000000000000000000000008080f00800808000000000000000000000000000000000000000000000000e666666666666666
00000000000000000000000000000000000000000000000000078840080700000000000000000000000000000000000000000000000000006600000000000000
000000000000000000000000000000000000000000000000404070000048700f000000000000000000000000000000000000000000000000600bbbbbbbbbbbbb
00000000000000000000000000000000000000000000000040477400004774040000000000000000000000000000000000000000000000006011333333333333
000000000000000000000000000000000000000000000000f0cccc0040cccc400000000000000000000000000000000000000000000000006001111111111111
00000000000000000000000000000000000000000000000000c00c0004c00c000000000000000000000000000000000000000000000000006600000000000000
00000000000000000000000000000000000000000000000000400400f0400400000000000000000000000000000000000000000000000000e667777777777777
00000800000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000008080f00000000008008080000000000080800000000080800000000000000000000000000000000000000000000000000000000000000000000000000
00000007884000000000080700000000000000800080000000800080000000800000000000000000000000000000000000000000000000000000000000000000
000040407000000000000048700f0000000000070800000000070800000800000000000000000000000000000000000000000000000000000000000000000000
00004047740000000000004774040000000080407000000080407000080008800000000000000000000000000000000000000000000000000000000000000000
0000f0cccc000000000040cccc400000000000477480000000477480080708000000000000000000000000000000000000000000000000000000000000000000
000000c00c000000000004c00c000000000000cccc04000000cccc04004870040000000000000000000000000000000000000000000000000000000000000000
00000040040000000000f040040000000000f4c00c400000f4c00c40f48774480000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000cccccccccc0000cc000000cccccccc00cc000000cc0000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000cccccccccc0000cc000000cccccccc00cc000000cc0000000000000000000000000000000000000000000000000000
00000000000000000000000000000000cc1111111111cc00cc0000cc11111111cc11cc00cc11cc00000000000000000000000000000000000000000000000000
00000000000000000000000000000000cc1111111111cc00cc0000cc11111111cc11cc00cc11cc00000000000000000000000000000000000000000000000000
0000000000000000000000000000000000cc111111cc00cc11cc00cc1111cccccc11cccc1111cc00000000000000000000000000000000000000000000000000
0000000000000000000000000000000000cc111111cc00cc11cc00cc1111cccccc11cccc1111cc00000000000000000000000000000000000000000000000000
000000000000000000000000000000000000cc11cc00cccc11cccccc11cc0000cc11cc1111cc0000000000000022220000000000000000000000000000000000
000000000000000000000000000000000000cc11cc00cccc11cccccc11cc0000cc11cc1111cc0000000000000022220000000000000000000000000000000000
0000000000000000000000000000000000cccc11cc00cc11cc11cccc11cc0000cc111111cc000000220022002200000000000000000000000000000000000000
0000000000000000000000000000000000cccc11cc00cc11cc11cccc11cc0000cc111111cc000000220022002200000000000000000000000000000000000000
00000000000000000000000000000000cc11cc11cc00cc111111cccc11cc0000cc11cc1111cc0000220022002222220000000000000000000000000000000000
00000000000000000000000000000000cc11cc11cc00cc111111cccc11cc0000cc11cc1111cc0000220022002222220000000000000000000000000000000000
00000000000000000000000000000000cc111111cc00cc11cc11cccc1111cccccc11cccc1111cc00222222000000220000000000000000000000000000000000
00000000000000000000000000000000cc111111cc00cc11cc11cccc1111cccccc11cccc1111cc00222222000000220000000000000000000000000000000000
0000000000000000000000000000000000cc1111cccc1111cc1111cc11111111cc11cc00cc11cc00002200222222000000000000000000000000000000000000
0000000000000000000000000000000000cc1111cccc1111cc1111cc11111111cc11cc00cc11cc00002200222222000000000000000000000000000000000000
000000000000000000000000000000000000cccc0000cccc00cccc00cccccccc00cc000000cc0000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000cccc0000cccc00cccc00cccccccc00cc000000cc0000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000088888800888888008888888800888800888888008888880000888888000000000000000000000000000000000000
00000000000000000000000000000000000088888800888888008888888800888800888888008888880000888888000000000000000000000000000000000000
00000000000000000000000000000000008822222288222222882222222288222288222222882222228888222222880000000000000000000000000000000000
00000000000000000000000000000000008822222288222222882222222288222288222222882222228888222222880000000000000000000000000000000000
00000000000000000000000000000000000088882288228822882222222288228822882288882288888822888888000000000000000000000000000000000000
00000000000000000000000000000000000088882288228822882222222288228822882288882288888822888888000000000000000000000000000000000000
00000000000000000000000000000000000088228888228822882288882288222288882288882222880088222288000000000000000000000000000000000000
00000000000000000000000000000000000088228888228822882288882288222288882288882222880088222288000000000000000000000000000000000000
00000000000000000000000000000000008822888888228822882288882288228822882288882288880088888822880000000000000000000000000000000000
00000000000000000000000000000000008822888888228822882288882288228822882288882288880088888822880000000000000000000000000000000000
00000000000000000000000000000000008822222288222222882288882288222288222222882222228822222288000000000000000000000000000000000000
00000000000000000000000000000000008822222288222222882288882288222288222222882222228822222288000000000000000000000000000000000000
00000000000000000000000000000000000088888800888888008800008800888800888888008888880088888800000000000000000000000000000000000000
00000000000000000000000000000000000088888800888888008800008800888800888888008888880088888800000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000c0c1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000c0c1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c0c0c0c0c0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c0c1c0c0c1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c0c1c0c0c1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c0c0c0c0c0c0000000c0c0c0c0c0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c0c0c0c0c1c0000000c0c1c0c1c0c1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c0c2c0c0c1c0000000c0c1c0c1c0c1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000c50000000000000000000000c0c2c0c0c0c0c6c6c6c0c0c0c0c0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00100010117501175011750117501175011750137501375016750167500c7500c7500c75027000270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010001029104291003510029104291001f1001f1001f10429104291003510029104291001f1001f1001f10400000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600002205122051220542705627056270541f0002b0512b0512e0542e055290002700027000290002900024000250002500027000290002a00000000000000000000000000003000031000320003400035000
000400003a6253a62535634356343a6353a63535624356243a6253a63500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001f0552205522054350543a0552905529054290543005530055030050a0050a005330053a0053a005000051f0051d0051d005240051d0051d0051d0051d0051b0051b0050000500005000050000500005
010200000f6530f6530f6430f6450f6350f6350763507625006250061524600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000500001b6041b6041b6111b6211b6211f6311f6311f6211f6230f6531f6001e600006000060000600006001d6001d6001d6001d6001d6001d60000600006000060000600006000060000600006000060000600
000200003f6533f6533f6321963519600186001860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000023150261501b1002b1501b1001f1011f1011f1011f1030f10300100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
01030000171501a1501b1001f15500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 40414344

