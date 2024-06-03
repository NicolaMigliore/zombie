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

    -- old --

    -- local middle_h_tiles = (_w/8)-1
    -- local middle_v_tiles = (_h/8)-1
    -- local i,j = 1,1
    
    -- -- top-left
    -- sspr(112,96,8,8,_x,_y)
    -- -- top-middle
    -- while i<middle_h_tiles do
    --     sspr(120,96,8,8,_x+i*8,_y)
    --     i += 1
    -- end 
    -- -- top-right
    -- sspr(112,96,8,8,_x+i*8,_y,8,8,true)

    -- -- middle-sides
    -- while j<middle_v_tiles do
    --     sspr(104,96,8,8,_x,_y+j*8,8,8)
    --     sspr(104,96,8,8,_x+i*8,_y+j*8,8,8,true)
    --     j += 1
    -- end 

    -- -- bottom-left
    -- sspr(112,104,8,8,_x,_y+j*8,8,8)
    -- -- bottom-middle
    -- i=1
    -- while i<middle_h_tiles do
    --     sspr(120,104,8,8,_x+i*8,_y+j*8,8,8)
    --     i += 1
    -- end 
    -- -- bottom-right
    -- sspr(112,104,8,8,_x+i*8,_y+j*8,8,8,true)

end