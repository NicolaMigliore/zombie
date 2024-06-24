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
    load_scene_level()

    -- debugging
    show_colliders = false
    show_hitboxes = false
    log_systems = false

    cam_x = 0

    _ui_i()
    _highscore_i()
end

function _update60()
    if mode == "title" then
    elseif mode == "level" then 
        _scene_level_u()
    elseif mode == "death" then
        _scene_death_u()
    elseif mode == "highscore" then
        _highscore_u()
    end
    _ui_u()
end

function _draw()
    if mode == "title" then
    elseif mode == "level" then 
        _scene_level_d()
    elseif mode == "death" then
        _scene_death_d()
    elseif mode == "highscore" then
        _highscore_d()
    end
end
