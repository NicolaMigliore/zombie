function _scene_level_u()
    if _skip_frames>0 then
        _skip_frames-=1
    else
        animation_system.update()
        control_system.update()
        physics_system.update()
        battle_system.update()
        state_system.update()
    end

    trigger_system.update()
    particle_system.update()

    -- move camera
    gamecamera.position.x = min(896,max(1,player.position.x - 30))

    camera(gamecamera.position.x+flr(shake_x),flr(shake_y))

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
    graphics_system.update({bg_color=13,draw_level=draw_level})
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

    -- b-black|w-window|d-door|r-road line|s-sidewalk|t-trash|f-fence|v-vertical road|x-nothing
    cells = {b=192,w=193,d=194,r=195,s=196,t=197,f=198,v=199,x=0}
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
    player.position.y = 74
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
    spawn_zombie(130)
end