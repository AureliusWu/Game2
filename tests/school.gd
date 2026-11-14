extends SceneTree
const Landmarks = preload("res://scripts/landmarks.gd")
const Interaction = preload("res://scripts/interaction.gd")
const CaseBoard = preload("res://scripts/case_board.gd")
const SAVE := "user://qa/school-regression.json"
var game: Node3D

func _initialize() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error("SCHOOL_FAILED: " + reason)
    quit(1)

func _run() -> void:
    game = load("res://scenes/main.tscn").instantiate()
    game.save_path = SAVE
    DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))
    root.add_child(game)
    await process_frame
    game.player.set_physics_process(false)
    if CaseBoard.timeline({}).contains("20:43"):
        _fail("Unseen school record leaked into notebook")
        return
    game._close_modal()
    await _aim("street", Vector3(2.8, 1.01, 15.4), Landmarks.SCHOOL_DOOR, "enter_school")
    game._interact("enter_school")
    await process_frame
    if game.current_zone != "school" or game.world.get_node_or_null("SchoolSet/RollBook") == null:
        _fail("School entrance or physical roll book missing")
        return
    if game.ambience.zone != "school" or game.ambience.ambient_player.stream == null:
        _fail("Classroom ambience did not start")
        return
    await _aim("school", Vector3(-3.5, 1.01, -1.9), Landmarks.SCHOOL_REGISTER, "school_register")
    game._interact("school_register")
    if game._can_corroborate() or game._ready_to_deduce():
        _fail("A school record alone bypassed evidence gates")
        return
    game._close_modal()
    if not CaseBoard.timeline(game.collected).contains("20:43"):
        _fail("Discovered departure time missing from notebook")
        return
    await _aim("school", Vector3(2.8, 1.01, 0.25), Landmarks.SCHOOL_NOTEBOOK, "school_notebook")
    game._interact("school_notebook")
    game.collected["ledger"] = true
    if game._can_corroborate():
        _fail("Missing witness testimony should block school corroboration")
        return
    game.collected["shop_testimony"] = true
    game._corroboration_answer("A")
    if game.collected.has("identity_check"):
        _fail("Wrong conclusion recorded as fact")
        return
    game._corroboration_answer("B")
    if not game.collected.has("identity_check") or game._ready_to_deduce():
        _fail("Correct optional inference missing or bypassed four main clues")
        return
    game.collected["ledger_crosscheck"] = true
    game._save()
    game.collected.clear()
    game._load_save()
    if not game.collected.has("identity_check") or not game.collected.has("ledger_crosscheck") or not game.collected.has("school_notebook"):
        _fail("Old school IDs or current main crosscheck did not survive save/load")
        return
    game._close_modal()
    await _aim("school", Vector3(0, 1.01, 3.8), Landmarks.SCHOOL_EXIT, "exit")
    game._interact("exit")
    if game.current_zone != "street" or not game.player.global_position.is_equal_approx(Landmarks.SCHOOL_RETURN):
        _fail("School return spawn drifted")
        return
    var query := PhysicsShapeQueryParameters3D.new()
    query.shape = game.player.get_node("CollisionShape3D").shape
    query.transform = game.player.global_transform
    query.collision_mask = 1
    await physics_frame
    if not game.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty():
        _fail("School return spawned inside a solid")
        return
    game.collected["tape"] = true
    game._go_to("school")
    if game.world.get_node_or_null("SchoolSet") == null:
        _fail("Haunted classroom failed to rebuild")
        return
    # Existing main saves need no school items to complete the main deduction.
    game.collected = {"poster": true, "ledger": true, "log": true, "tape": true}
    if not game._ready_to_deduce():
        _fail("School became a mandatory mainline gate")
        return
    game._answer("B")
    if not game.finished:
        _fail("Original four-clue conclusion stopped working")
        return
    DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))
    print("SCHOOL_OK: physical entry/props/exit, discovered timeline, optional gates, old/new save IDs, original mainline")
    game.queue_free()
    await process_frame
    quit(0)

func _aim(zone: String, at: Vector3, target: Vector3, expected: String) -> void:
    if game.current_zone != zone:
        game._go_to(zone)
    game._close_modal()
    game.player.global_position = at
    game.eye.look_at(target)
    await physics_frame
    await process_frame
    var selected: Dictionary = Interaction.choose(game.eye, game.world.hotspots, game.get_world_3d().direct_space_state)
    if selected.get("id", "") != expected:
        _fail("Physical interaction blocked/misaligned: " + expected + " got " + str(selected.get("id", "")))
