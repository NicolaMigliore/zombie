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