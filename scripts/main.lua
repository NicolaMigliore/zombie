function _init()
    -- input management
    poke(0x5f5c,255)

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
    intensity = 0
    shake_ctrl = .5
    shake_x,shake_y=0,0
    _skip_frames=0

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
    -- if _skip_frames>0 then
    --     _skip_frames-=1
    -- else
    --     upd[mode]()
    -- end
    upd[mode]()
    _ui_u()
end

function _draw()
    drw[mode]()
end
