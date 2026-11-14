extends SceneTree
## Real physics-space interaction and recovery checks, isolated from player progress.
const Interaction = preload("res://scripts/interaction.gd")
const Finish = preload("res://scripts/radio_finishes.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error("EXPLORATION_FAILED: " + reason)
    quit(1)

func _run() -> void:
    var game: Node3D = load("res://scenes/main.tscn").instantiate()
    game.set("persistence_enabled", false)
    get_root().add_child(game)
    await process_frame
    var actor: CharacterBody3D = game.get_node("Player")
    var eye: Camera3D = game.get_node("Player/Camera3D")
    actor.set_physics_process(false)
    # Deliberately use independent authored coordinates, not the anchor constants.
    # A correct ID at an obsolete location must fail these tests.
    var approaches: Array[Dictionary] = [
        {"zone": "street", "id": "poster", "at": Vector3(-4.55, 1.01, 14.0),
            "target": Vector3(-4.55, 1.5, 12.13)},
        {"zone": "street", "id": "public_phone", "at": Vector3(2.0, 1.01, 16.4),
            "target": Vector3(4.42, 1.5, 16.4)},
        {"zone": "street", "id": "enter_shop", "at": Vector3(-2.6, 1.01, 4.0),
            "target": Vector3(-4.85, 1.2, 4.0)},
        {"zone": "street", "id": "enter_radio", "at": Vector3(2.6, 1.01, -8.0),
            "target": Vector3(4.85, 1.2, -8.0)},
        {"zone": "street", "id": "enter_shrine", "at": Vector3(0, 1.01, -28.8),
            "target": Vector3(0, 1.45, -31.35)},
        {"zone": "shop", "id": "ledger", "at": Vector3(-1.8, 1.01, 0.4),
            "target": Vector3(-1.8, 1.18, -1.6)},
        {"zone": "shop", "id": "calendar", "at": Vector3(-4.4, 1.01, -3.4),
            "target": Vector3(-4.4, 2.35, -5.6)},
        {"zone": "shop", "id": "npc_shop", "at": Vector3(-3.6, 1.01, 2.2)},
        {"zone": "shop", "id": "exit", "at": Vector3(0, 1.01, 3.5),
            "target": Vector3(0, 1.25, 5.6)},
        {"zone": "radio", "id": "log", "at": Vector3(-0.52, 1.01, 0.5),
            "target": Vector3(-0.52, 1.48, -1.67)},
        {"zone": "radio", "id": "tape", "at": Vector3(1.86, 1.01, 0.1),
            "target": Vector3(1.86, 1.65, -2.10)},
        {"zone": "radio", "id": "broadcast_notice", "at": Vector3(4.7, 1.01, -4.4),
            "target": Vector3(4.7, 2.48, -5.51)},
        {"zone": "radio", "id": "exit", "at": Vector3(-2.8, 1.01, 3.7),
            "target": Vector3(-2.8, 1.25, 5.6)},
        {"zone": "radio", "id": "npc_radio", "at": Vector3(3.35, 1.01, 2.6)},
        {"zone": "shrine", "id": "ritual", "at": Vector3(-2.3, 1.01, 0.1),
            "target": Vector3(-2.3, 1.25, -2.1)},
        {"zone": "shrine", "id": "tablet", "at": Vector3(0, 1.01, -1.0),
            "target": Vector3(0, 1.9, -3.85)},
        {"zone": "shrine", "id": "exit", "at": Vector3(0, 1.01, 3.5),
            "target": Vector3(0, 1.25, 5.6)}
    ]
    for entry in approaches:
        game.call("_go_to", entry["zone"])
        game.call("_close_modal")
        actor.global_position = entry["at"]
        actor.velocity = Vector3.ZERO
        var target := Vector3.ZERO
        for spot in game.world.hotspots:
            if spot["id"] == entry["id"]:
                target = spot["position"]
        if entry.has("target") and target.distance_to(entry["target"]) > 0.03:
            _fail("Hotspot detached from visible object: " + str(entry["id"]))
            return
        eye.look_at(target, Vector3.UP)
        await physics_frame
        await process_frame
        var result: Dictionary = Interaction.choose(eye, game.world.hotspots,
            game.get_world_3d().direct_space_state)
        if result.get("id", "") != entry["id"]:
            _fail("Cannot investigate from visible approach: " + str(entry))
            return
    # Solid walls must actually occlude; close distance alone is insufficient.
    game.call("_go_to", "shop")
    actor.global_position = Vector3(-1.8, 1.01, -7.0)
    eye.look_at(Vector3(-1.8, 1.18, -5.0), Vector3.UP)
    await physics_frame
    await process_frame
    var hidden: Array[Dictionary] = [{"id": "behind_wall", "position": Vector3(-1.8, 1.18, -5.0)}]
    if not Interaction.choose(eye, hidden, game.get_world_3d().direct_space_state).is_empty():
        _fail("Solid shop wall no longer blocks investigation")
        return
    # Recovery uses the current zone's entry point and removes falling velocity.
    var entry_point: Vector3 = actor.safe_position
    actor.global_position = Vector3(60, -10, 60)
    actor.velocity = Vector3(0, -70, 0)
    actor.call("_physics_process", 0.0)
    if actor.global_position.distance_to(entry_point) > 0.05 or actor.velocity.length() > 0.1:
        _fail("Out-of-bounds recovery did not restore a safe zone entry")
        return
    # Test the visible perimeter through physics rays, including behind buildings.
    game.call("_go_to", "street")
    await physics_frame
    await process_frame
    for endpoint in [Vector3(-20, 1.2, -7), Vector3(20, 1.2, -7),
            Vector3(0, 0.6, 35), Vector3(12.5, 1.2, -45)]:
        var start := Vector3(0, 1.2, -7) if endpoint.z > -40 else Vector3(12.5, 1.2, -35)
        if endpoint.z > 30:
            start = Vector3(0, 0.6, 22)
        var ray := PhysicsRayQueryParameters3D.create(start, endpoint, 1)
        if game.get_world_3d().direct_space_state.intersect_ray(ray).is_empty():
            _fail("Missing street boundary toward " + str(endpoint))
            return
    # Escape releases the pointer, and must also stop walking.
    actor.global_position = Vector3(0, 1.01, 18)
    actor.velocity = Vector3.ZERO
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    var key := InputEventKey.new()
    key.keycode = KEY_W
    key.physical_keycode = KEY_W
    key.pressed = true
    Input.parse_input_event(key)
    await process_frame
    actor.call("_physics_process", 0.016)
    key.pressed = false
    Input.parse_input_event(key)
    if absf(actor.velocity.x) + absf(actor.velocity.z) > 0.001:
        _fail("Player can walk while pointer is released")
        return
    # Different colours share the original surface maps, while retaining unique tint.
    var a: StandardMaterial3D = Finish.get_finish("wood", Color(0.4, 0.3, 0.2))
    var b: StandardMaterial3D = Finish.get_finish("wood", Color(0.6, 0.4, 0.3))
    if a == b or a.albedo_texture != b.albedo_texture or a.normal_texture != b.normal_texture \
            or a.roughness_texture != b.roughness_texture:
        _fail("Tint variants duplicate surface maps or lose their distinct colours")
        return
    # Resizing an already open modal must reflow its text and keyboard controls.
    game.call("_go_to", "shop")
    game.call("_interview", "npc_shop")
    get_root().content_scale_size = Vector2i.ZERO
    get_root().size = Vector2i(800, 600)
    for i in range(4):
        await process_frame
    var panel: Control = game.modal
    var stack: Control = game.modal_stack
    if panel.get_global_rect().end.x > 800.0 or stack.size.x > panel.size.x - 40.0:
        _fail("Resized dialogue overflows its panel")
        return
    if get_root().gui_get_focus_owner() == null or game.crosshair.visible:
        _fail("Modal lost initial keyboard focus or still displays the aiming reticle")
        return
    game.call("_close_modal")
    if not game.crosshair.visible:
        _fail("Aiming reticle did not return after dialogue")
        return
    print("EXPLORATION_OK: 17 visible approaches, wall occlusion, perimeter, recovery, cursor, shared textures, compact UI")
    game.queue_free()
    await process_frame
    quit(0)
