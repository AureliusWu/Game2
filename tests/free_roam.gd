extends SceneTree
## Adversarial viewpoints and actual collision checks beyond the authored happy path.
const Interaction = preload("res://scripts/interaction.gd")
var game: Node3D
var failed: bool = false
var checked: int = 0

func _initialize() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    failed = true
    push_error("FREE_ROAM_FAILED: " + reason)
    quit(1)

func _run() -> void:
    game = load("res://scenes/main.tscn").instantiate()
    game.persistence_enabled = false
    get_root().add_child(game)
    await process_frame
    var actor: CharacterBody3D = game.player
    var eye: Camera3D = game.eye
    actor.set_physics_process(false)
    for size in [Vector2i(1280, 720), Vector2i(2048, 1074), Vector2i(800, 600), Vector2i(640, 360)]:
        root.size = size
        for frame in range(3):
            await process_frame
        for person in ["npc_shop", "npc_radio"]:
            game._go_to("shop" if person == "npc_shop" else "radio")
            game._close_modal()
            await physics_frame
            await process_frame
            var witness: Node3D = game.world.get_node("Witness_" + person)
            for angle in [0.0, PI * 0.25, PI * 0.5, PI * 0.75, PI, PI * 1.25, PI * 1.5, PI * 1.75]:
                for distance in [0.82, 2.8]:
                    var at: Vector3 = witness.global_position + Vector3(sin(angle), 0, cos(angle)) * distance
                    at.y = 0.94
                    var check := PhysicsShapeQueryParameters3D.new()
                    check.shape = actor.get_node("CollisionShape3D").shape
                    check.transform = Transform3D(Basis.IDENTITY, at)
                    check.collision_mask = 1
                    if not game.get_world_3d().direct_space_state.intersect_shape(check, 1).is_empty():
                        continue
                    actor.global_position = at
                    eye.look_at(witness.global_position + Vector3(0, 1.45, 0))
                    eye.fov = 56.0 + float(checked % 3) * 15.0
                    var original: Transform3D = eye.transform
                    var original_fov: float = eye.fov
                    game._interview(person)
                    for frame in range(24):
                        await process_frame
                    var head: Rect2 = _head_rect(witness, eye)
                    var panel: Rect2 = game.modal.get_global_rect()
                    var view: Rect2 = Rect2(Vector2.ZERO, Vector2(size)).grow(-6)
                    if not view.encloses(head) or panel.intersects(head):
                        _fail("Head clipped/covered at " + str(size) + " " + person + " angle=" + str(angle) + " distance=" + str(distance) + " head=" + str(head) + " panel=" + str(panel))
                        return
                    if actor.global_position.distance_to(at) > 0.001:
                        _fail("Conversation moved the player body")
                        return
                    game._close_modal()
                    if eye.top_level or not eye.transform.is_equal_approx(original) or eye.fov != original_fov:
                        _fail("Camera did not restore position/orientation/FOV on exit")
                        return
                    checked += 1
    if checked < 48:
        _fail("Too few physically valid approach cases: " + str(checked))
        return
    # Actual character motion must stop at witnesses and at the tape rack.
    game._go_to("radio")
    game._close_modal()
    actor.global_position = Vector3(3.35, 0.94, 2.6)
    await physics_frame
    await process_frame
    for step in range(70):
        actor.move_and_collide(Vector3(0, 0, -0.07))
    if actor.global_position.z < 1.13:
        _fail("Player walked through the witness capsule")
        return
    actor.global_position = Vector3(4.52, 0.94, -1.4)
    for step in range(60):
        actor.move_and_collide(Vector3(0, 0, -0.07))
    if actor.global_position.z < -2.43:
        _fail("Player walked through the tape rack")
        return
    actor.global_position = Vector3(3.5, 0.94, -1.8)
    if actor.test_move(actor.global_transform, Vector3(0, 0, -2.5)):
        _fail("Tape-notice access aisle was blocked by new collisions")
        return
    # Adding an NPC body must not make that NPC impossible to speak to.
    actor.global_position = Vector3(3.35, 0.94, 2.6)
    eye.look_at(Vector3(3.35, 1.42, 0.5))
    var selected: Dictionary = Interaction.choose(eye, game.world.hotspots, game.get_world_3d().direct_space_state)
    if selected.get("id", "") != "npc_radio":
        _fail("NPC's own collider blocks interaction")
        return
    # Topic changes, mid-dialogue resize, close button and menu/zone transitions
    # all use the same reversible camera contract, including interrupted tweens.
    root.size = Vector2i(1280, 720)
    var before: Transform3D = eye.transform
    var before_fov: float = eye.fov
    game._interview("npc_radio")
    for button in game.modal.find_children("*", "Button", true, false):
        if button.text.contains("21:47"):
            _fail("Unseen tape timestamp leaked into the opening question")
            return
    game._interview_topic("npc_radio", "tape")
    root.size = Vector2i(640, 360)
    for frame in range(30):
        await process_frame
    var witness: Node3D = game.world.get_node("Witness_npc_radio")
    if game.modal.get_global_rect().intersects(_head_rect(witness, eye)):
        _fail("Resizing an open topic covers the speaker")
        return
    var close_found: bool = false
    for button in game.modal.find_children("*", "Button", true, false):
        if button.text == "×":
            close_found = true
            if not Rect2(Vector2.ZERO, Vector2(640, 360)).encloses(button.get_global_rect()):
                _fail("Fixed close button became unreachable")
                return
            button.pressed.emit()
            break
    if not close_found or game.modal.visible or not eye.transform.is_equal_approx(before):
        _fail("Closing a scrolled topic failed to restore the original view")
        return
    game._interview("npc_radio")
    game._menu()
    if game.conversation_stage.active or eye.top_level or witness.speaking:
        _fail("Opening the menu retained the conversation camera/performance")
        return
    game._interview("npc_radio")
    game._go_to("shop")
    game._close_modal()
    if game.conversation_stage.active or eye.top_level or eye.fov != before_fov:
        _fail("Zone change leaked an interrupted camera tween or FOV")
        return
    for zone in ["street", "shop", "radio", "shrine"]:
        game._go_to(zone)
        for label in game.world.find_children("*", "Label3D", true, false):
            if label.billboard != BaseMaterial3D.BILLBOARD_DISABLED:
                _fail("Mounted prop text still rotates into its backing in " + zone)
                return
    game._go_to("shop")
    var ledger: Node3D = game.world.get_node("ShopSet/OpenLedger")
    var paper_top: float = ledger.global_position.y
    for mesh in ledger.get_children():
        if mesh is MeshInstance3D and mesh.mesh is BoxMesh:
            paper_top = maxf(paper_top, mesh.global_position.y + mesh.mesh.size.y * 0.5)
    var caption_found: bool = false
    for label in game.world.find_children("*", "Label3D", true, false):
        if label.text.contains("赊账簿"):
            caption_found = true
            if label.global_position.y <= paper_top + 0.001:
                _fail("Ledger caption is buried in the paper or decorative lines")
                return
    if not caption_found:
        _fail("Ledger caption missing")
        return
    print("FREE_ROAM_OK: " + str(checked) + " approach/resize/FOV cases; lifecycle; collisions; open clue aisle; mounted prop text; ledger caption depth")
    game.queue_free()
    await process_frame
    quit(0)

func _head_rect(witness: Node3D, eye: Camera3D) -> Rect2:
    var head: Node3D = witness.get_node("HeadPivot")
    var lo := Vector2(INF, INF)
    var hi := Vector2(-INF, -INF)
    for x in [-0.23, 0.23]:
        for y in [-0.02, 0.49]:
            for z in [-0.34, 0.24]:
                var point: Vector2 = eye.unproject_position(head.global_transform * Vector3(x, y, z))
                lo = lo.min(point)
                hi = hi.max(point)
    return Rect2(lo, hi - lo)
