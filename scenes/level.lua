function _scene_level_u()
    animation_system.update()
    control_system.update()
    physics_system.update()
    trigger_system.update()
    state_system.update()
    battle_system.update()

    -- move camera
    if player and player.intention.is_moving then
        gamecamera.position.x = min(896,max(0,player.position.x - 30))
        camera(gamecamera.position.x)
    end
end

function _scene_level_d()
    graphics_system.update({bg_color=1,draw_level=draw_level})
end

-- draw level background
function draw_level()
    -- rectfill(0,60,1024,60,5)
    -- rectfill(0,61,1024,128,0)
    
    palt(0,false)
    palt(14,true)
    map()
    palt()

    
end

--- generate level entities
function create_level()
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

    -- for each screen
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
end


function load_scene_level()
    entitie = {}
    level = 0
    mode = "level"

    -- create level
    create_level()
    
    -- setup other entities
    _camera_i()
    _player_i()

    -- spawn test zombie
    spawn_zombie()
end