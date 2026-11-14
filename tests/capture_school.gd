extends SceneTree
const OUT := "res://build/school-captures"
var game: Node3D

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    game = load("res://scenes/main.tscn").instantiate()
    game.persistence_enabled = false
    root.add_child(game)
    game.player.set_physics_process(false)
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
    RenderingServer.set_render_loop_enabled(false)
    await _shot("01_school_entrance", "street", Vector3(1.8, 1.01, 18.5), Vector3(4.85, 1.8, 15.4))
    await _shot("02_classroom", "school", Vector3(0, 1.01, 3.7), Vector3(0, 2.0, -5.7))
    await _shot("03_roll_book", "school", Vector3(-3.5, 1.01, -1.9), Vector3(-3.5, 1.2, -3.5))
    game.collected["tape"] = true
    game._go_to("street")
    await _shot("04_classroom_after_tape", "school", Vector3(0, 1.01, 2.5), Vector3(0, 2.1, -5.7))
    print("SCHOOL_CAPTURE_OK: 4 actual renderer views")
    game.queue_free()
    await process_frame
    quit(0)

func _shot(name: String, zone: String, at: Vector3, target: Vector3) -> void:
    game._go_to(zone)
    game._close_modal()
    game.player.global_position = at
    game.eye.look_at(target)
    RenderingServer.set_render_loop_enabled(true)
    for frame in range(4):
        await process_frame
    await RenderingServer.frame_post_draw
    var frame: Image = root.get_texture().get_image()
    if frame == null or frame.is_empty() or frame.save_png(OUT + "/" + name + ".png") != OK:
        push_error("SCHOOL_CAPTURE_FAILED: " + name)
        quit(1)
        return
    RenderingServer.set_render_loop_enabled(false)
