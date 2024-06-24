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