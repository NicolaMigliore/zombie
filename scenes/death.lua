function _scene_death_u()
    if(btnp(❎)) load_scene_level()
    -- todo: save score
end

function _scene_death_d()
    camera()

    draw_window_frame(10,7,107,90)

    local text_x = 35
    print("you are",text_x,15,7)
    print("dead!",text_x+32,15,8)

    print("level:"..level,46,25,6)
    print("score:"..score,46,33,6)

    print("press❎ to restart",25,60,blink_color1.color) --blink_color1
    --print("press🅾️ to return to title" ,20,80,7)
end

function load_scene_death()
    mode = "death"
end