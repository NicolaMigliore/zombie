function _camera_i()
    gamecamera = new_entity({
        kind = "gamecamera",
        position = new_position(0,0,128,128),
    })
    add(entities,gamecamera)
end