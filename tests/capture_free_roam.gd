extends SceneTree
## Screenshot regressions for the reported Windows composition and off-route views.
const OUT := "res://build/free-roam-captures"
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
    await _shot("01_reported_radio_close", Vector2i(2048, 1074), "radio", Vector3(3.35, 0.94, 1.35), "npc_radio")
    await _shot("02_radio_side", Vector2i(1280, 720), "radio", Vector3(4.25, 0.94, 0.65), "npc_radio")
    await _shot("03_radio_rear", Vector2i(1280, 720), "radio", Vector3(3.35, 0.94, -0.4), "npc_radio")
    await _shot("04_shop_close", Vector2i(1280, 720), "shop", Vector3(-3.6, 0.94, 0.95), "npc_shop")
    await _shot("05_shop_compact", Vector2i(800, 600), "shop", Vector3(-3.6, 0.94, 1.2), "npc_shop")
    await _shot("06_radio_compact", Vector2i(640, 360), "radio", Vector3(3.35, 0.94, 1.45), "npc_radio")
    await _shot("07_resized_topic", Vector2i(1280, 720), "radio", Vector3(3.35, 0.94, 2.0), "npc_radio", true)
    game._go_to("radio")
    game._close_modal()
    root.size = Vector2i(1280, 720)
    game.player.global_position = Vector3(1.7, 0.94, 0.7)
    game.eye.look_at(Vector3(0, 3.4, -5.35))
    await _save("08_mounted_radio_sign")
    game._go_to("shrine")
    game._close_modal()
    game.player.global_position = Vector3(-2.3, 0.94, -0.45)
    game.eye.look_at(Vector3(-2.3, 1.25, -2.2))
    await _save("09_shrine_paper")
    game.player.global_position = Vector3(0, 0.94, 3.5)
    game.eye.look_at(Vector3(0, 1.7, 5.6))
    await _save("10_shrine_exit")
    game._go_to("shop")
    game._close_modal()
    game.player.global_position = Vector3(-1.8, 1.01, 0)
    game.eye.look_at(Vector3(-1.8, 1.18, -1.60))
    await _save("11_ledger_caption_depth")
    print("FREE_ROAM_CAPTURE_OK: 11 actual renderer views")
    game.queue_free()
    await process_frame
    quit(0)

func _shot(name: String, size: Vector2i, zone: String, at: Vector3, person: String, resize: bool = false) -> void:
    game._close_modal()
    root.size = size
    game._go_to(zone)
    game._close_modal()
    game.player.global_position = at
    var witness: Node3D = game.world.get_node("Witness_" + person)
    game.eye.look_at(witness.global_position + Vector3(0, 1.65, 0))
    await physics_frame
    await process_frame
    game._interview(person)
    if resize:
        game._interview_topic(person, "tape")
        root.size = Vector2i(800, 600)
    for frame in range(40):
        await process_frame
    await _save(name)

func _save(name: String) -> void:
    RenderingServer.set_render_loop_enabled(true)
    for frame in range(3):
        await process_frame
    await RenderingServer.frame_post_draw
    var frame: Image = root.get_texture().get_image()
    if frame == null or frame.is_empty() or frame.save_png(OUT + "/" + name + ".png") != OK:
        push_error("FREE_ROAM_CAPTURE_FAILED: " + name)
        quit(1)
        return
    print("FREE_ROAM_CAPTURE: " + name + " " + str(frame.get_width()) + "x" + str(frame.get_height()))
    RenderingServer.set_render_loop_enabled(false)
