extends SceneTree
## Real framebuffer captures of the actual Game2 scene under X11/Mesa software rendering.
## No mockups, no generated artwork and no post-processing.
const OUT := "res://build/visual-captures"

func _initialize() -> void:
    call_deferred("_capture_all")

func _capture_all() -> void:
    var packed: PackedScene = load("res://scenes/main.tscn")
    if packed == null:
        _fail("Main scene could not load")
        return
    var game: Node3D = packed.instantiate()
    get_root().add_child(game)
    await process_frame
    var camera: Camera3D = game.get_node("Player/Camera3D") as Camera3D
    var player: CharacterBody3D = game.get_node("Player") as CharacterBody3D
    if camera == null or player == null:
        _fail("Missing scene camera or player")
        return
    var err: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
    if err != OK:
        _fail("Cannot create screenshot destination: " + str(err))
        return

    game.call("_close_modal")
    if not await _snap(game, player, camera, "01_street", "street",
        Vector3(0.0, 1.01, 17.0), Vector3(-1.0, 1.65, 2.0)):
        return
    if not await _snap(game, player, camera, "02_shop", "shop",
        Vector3(-0.5, 1.01, 3.0), Vector3(-3.6, 1.55, -0.8)):
        return

    game.call("_interview", "npc_shop")
    if not await _save("03_shop_dialogue"):
        return
    game.call("_close_modal")

    if not await _snap(game, player, camera, "04_radio", "radio",
        Vector3(0.5, 1.01, 3.0), Vector3(0.0, 1.5, -3.0)):
        return

    game.call("_investigate", "tape")
    game.call("_tape_start")
    game.call("_tape_next")
    game.call("_tape_next")
    if not await _save("05_tape_listening"):
        return
    game.call("_tape_complete")
    game.call("_close_modal")

    if not await _snap(game, player, camera, "06_shrine", "shrine",
        Vector3(0.0, 1.01, 2.8), Vector3(0.0, 2.1, -3.6)):
        return

    if not await _snap(game, player, camera, "07_haunted_street", "street",
        Vector3(0.0, 1.01, 17.0), Vector3(-1.0, 1.65, 2.0)):
        return
    print("VISUAL_CAPTURE_OK: 7 real Godot rendered frames")
    quit(0)

func _snap(game: Node3D, player: CharacterBody3D, camera: Camera3D,
    filename: String, zone: String, at: Vector3, target: Vector3) -> bool:
    game.call("_go_to", zone)
    game.call("_close_modal")
    player.global_position = at
    player.velocity = Vector3.ZERO
    camera.look_at(target, Vector3.UP)
    return await _save(filename)

func _save(filename: String) -> bool:
    # Several visible frames allow the renderer and physics scene to settle.
    for i in range(10):
        await process_frame
    await RenderingServer.frame_post_draw
    var img: Image = get_root().get_texture().get_image()
    if img == null or img.is_empty() or img.get_width() < 640:
        _fail("No valid rendered framebuffer for " + filename)
        return false
    var path: String = OUT + "/" + filename + ".png"
    var result: Error = img.save_png(path)
    if result != OK:
        _fail("Could not save " + path + ": " + str(result))
        return false
    print("VISUAL_CAPTURE: " + path + " " + str(img.get_width()) + "x" + str(img.get_height()))
    return true

func _fail(reason: String) -> void:
    push_error("VISUAL_CAPTURE_FAILED: " + reason)
    quit(1)
