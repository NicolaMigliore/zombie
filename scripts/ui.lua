function _ui_d()
    new_ui()
end

function new_ui()
    -- reset drawing offset
    camera()
    palt(0, false)
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
    sspr(96, 96, 16, 24, 0, 100, 16, 24, false)
    for i = 1, 8 do
        sspr(112, 96, 16, 24, i * 16, 100, 16, 24, false)
    end
    --sspr(112,96,16,16,64,100,16,16,false)
    sspr(96, 96, 16, 24, 112, 100, 16, 24, true)

    -- consume hp bar
    local missing_w = (1 - hp_perc) * 123
    rectfill(126 - missing_w, 116, 126, 118, 0)

    -- inventory
    if player.inventory and player.inventory.visible then
        --local inv_x, inv_y, inv_s = player.inventory.x, player.inventory.y, player.inventory.size
        local square_size =13--17--9
        local inv_x, inv_y, inv_s = 64-(square_size*player.inventory.size/2), 98, player.inventory.size
        rectfill(inv_x, inv_y, inv_x + square_size * inv_s, inv_y + square_size, 5)


        palt(14, true)
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
            --rect(inv_x + offset_x, inv_y, inv_x + square_size + offset_x, inv_y + square_size, 9)
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

function old_ui()
    -- background
    rect(0, 96, 127, 127, 5)
    rectfill(1, 97, 126, 126, 4)

    -- hp
    local bar_x, bar_y, bar_w = 13, 100,
        --62
        77
    rectfill(bar_x, bar_y, bar_x + bar_w, bar_y + 8, 6)
    bar_x += 1
    bar_y += 1
    rectfill(bar_x, bar_y, bar_x + 12, bar_y + 6, 5)
    bar_x += 1
    bar_y += 1
    print(player.battle.health, bar_x, bar_y, 6)

    local hp_perc = player.battle.health / player.battle.max_health
    local hp_w = hp_perc * bar_w -
        --46--48
        16
    local hp_c = ({ 8, 9, 10, 11, 11 })[flr(hp_perc * 4) + 1]
    bar_x += 13
    bar_y -= 1
    rectfill(bar_x, bar_y, bar_x + bar_w - 16, bar_y + 6, 5)
    rectfill(bar_x, bar_y, bar_x + hp_w, bar_y + 6, hp_c)

    -- inventory
    -- render inventory
    if player.inventory and player.inventory.visible then
        local inv_x, inv_y, inv_s = player.inventory.x, player.inventory.y, player.inventory.size
        rectfill(inv_x, inv_y, inv_x + 9, inv_y + 9 * inv_s, 5)
        palt(0, false)
        palt(14, true)
        for i = 1, inv_s do
            local offset_y = 9 * (i - 1)
            local c = i == player.inventory.active_i and 6 or 10
            rect(inv_x, inv_y + offset_y, inv_x + 9, inv_y + offset_y + 9, 6)
            -- render items
            local item = player.inventory.items[i]
            if item then
                sspr(item.sprite.sprite.x, item.sprite.sprite.y, 8, 8, inv_x + 1, inv_y + 1 + offset_y)
            end
        end
    end

    -- bullets
    local row = 0
    local nbr_bullets = min(50, 44)
    for i = 1, nbr_bullets do
        row = flr(i / 22)
        local x = (i - 1) % 22 * 5 + 13
        local y = flr(i / 23) * 7 + 110
        --sspr(8,8,8,8,7+i*5,113,8,8)
        sspr(8, 8, 8, 8, x, y, 8, 8)
    end
    palt()

    -- level
    bar_x = bar_x - 13 + bar_w
    bar_y -= 1
    rectfill(bar_x, bar_y, bar_x + 33, bar_y + 8, 6)
    bar_x += 1
    bar_y += 1
    rectfill(bar_x, bar_y, bar_x + 31, bar_y + 6, 5)
    print("level:"..level, bar_x+2, bar_y+1,6)
end