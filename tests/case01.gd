extends SceneTree
const Interaction = preload("res://scripts/interaction.gd")
## Deterministic headless checks for the shipped case logic. Not a replacement for desktop play QA.

func _initialize() -> void:
    var scene: PackedScene = load("res://scenes/main.tscn")
    if scene == null:
        push_error("Cannot load main")
        quit(1)
        return
    var game: Node = scene.instantiate()
    get_root().add_child.call_deferred(game)
    call_deferred("_check", game)

func _fail(reason: String) -> void:
    push_error("CASE01_FAILED: " + reason)
    quit(1)

func _check(game: Node) -> void:
    var expected: Dictionary = {
        "street": ["poster", "public_phone", "enter_shop", "enter_radio", "enter_shrine", "enter_school"],
        "shop": ["ledger", "calendar", "npc_shop", "exit"],
        "radio": ["log", "tape", "broadcast_notice", "npc_radio", "exit"],
        "shrine": ["ritual", "tablet", "exit"],
        "school": ["school_register", "school_notebook", "exit"]
    }
    var world: Node = game.get("world")
    for zone in expected.keys():
        game.call("_go_to", zone)
        var found: Array[String] = []
        for entry in world.get("hotspots"):
            found.append(str(entry["id"]))
        for wanted in expected[zone]:
            if not found.has(wanted):
                _fail("Missing hotspot " + wanted + " in " + zone)
                return
    # Verify environment art nodes exist before and after the tape anomaly.
    game.call("_go_to", "shop")
    if world.get_child_count() < 35:
        _fail("Shop environment dressing unexpectedly missing")
        return
    game.call("_go_to", "street")
    var before_anomaly: int = world.get_child_count()
    world.set("haunted", true)
    world.call("build_zone", "street")
    var after_anomaly: int = world.get_child_count()
    if after_anomaly <= before_anomaly:
        _fail("Anomaly dressing did not add visual cues")
        return
    world.set("haunted", false)
    game.call("_go_to", "street")
    var ambience = game.get("ambience")
    if ambience == null:
        _fail("Ambient audio node missing")
        return
    if ambience.ambient_player.stream == null:
        _fail("No generated ambient waveform")
        return
    var sound: AudioStreamWAV = ambience.ambient_player.stream as AudioStreamWAV
    if sound == null or sound.data.size() == 0:
        _fail("Generated ambient waveform empty")
        return
    # Public phone should remain mundane until the tape unlocks the anomaly.
    game.set("collected", {})
    game.set("finished", false)
    game.call("_go_to", "street")
    game.call("_inspect_phone")
    if (game.get("collected") as Dictionary).has("phone_whisper"):
        _fail("Phone revealed late clue before tape")
        return
    # Centered aiming selects the intended object; looking away rejects it.
    var camera: Camera3D = game.get_node("Player/Camera3D") as Camera3D
    var actor: CharacterBody3D = game.get_node("Player") as CharacterBody3D
    actor.global_position = Vector3(-1.3, 1.01, 14.15)
    camera.look_at(Vector3(-1.3, 1.3, 12), Vector3.UP)
    var aimed: Dictionary = Interaction.choose(camera, world.get("hotspots"),
        game.get_world_3d().direct_space_state)
    if str(aimed.get("id", "")) != "poster":
        _fail("Center-gaze interaction did not select poster")
        return
    camera.rotation.y += PI
    var away: Dictionary = Interaction.choose(camera, world.get("hotspots"),
        game.get_world_3d().direct_space_state)
    if not away.is_empty():
        _fail("Interaction still focused on unseen marker")
        return
    game.call("_go_to", "radio")
    game.call("_investigate", "tape")
    if not world.get("haunted"):
        _fail("First listening to tape must trigger visual anomaly")
        return
    game.call("_go_to", "street")
    if not (game.get("collected") as Dictionary).has("town_echo"):
        _fail("First return after tape should record a town echo")
        return
    game.call("_inspect_phone")
    if not (game.get("collected") as Dictionary).has("phone_whisper"):
        _fail("Post-tape phone should record extra clue")
        return
    # Optional witness statements are persisted and do not bypass the four required clues.
    game.set("collected", {})
    game.call("_interview_topic", "npc_shop", "ledger")
    game.call("_interview_topic", "npc_radio", "tape")
    var witness_clues: Dictionary = game.get("collected")
    if not witness_clues.has("shop_testimony") or not witness_clues.has("radio_testimony"):
        _fail("Witness questioning did not record both testimonies")
        return
    if game.call("_ready_to_deduce"):
        _fail("Witness statements alone cannot unlock timeline deduction")
        return
    # School records and testimony make a second, optional but playable inference.
    if game.call("_can_corroborate"):
        _fail("Missing school record should keep corroboration locked")
        return
    game.call("_go_to", "school")
    game.call("_investigate", "school_register")
    game.call("_investigate", "school_notebook")
    if game.call("_can_corroborate"):
        _fail("No shop ledger: cannot infer identity from the school record alone")
        return
    game.call("_investigate", "ledger")
    if not game.call("_can_corroborate"):
        _fail("Ledger + shop testimony + school register should unlock corroboration")
        return
    game.call("_corroboration_answer", "A")
    if (game.get("collected") as Dictionary).has("identity_check"):
        _fail("Wrong optional inference should not unlock the finding")
        return
    game.call("_corroboration_answer", "B")
    if not (game.get("collected") as Dictionary).has("identity_check"):
        _fail("Correct optional inference did not create the reasoning record")
        return
    if game.call("_ready_to_deduce"):
        _fail("Optional corroboration must not bypass the four central records")
        return
    game.call("_save")
    var save_data: Variant = JSON.parse_string(FileAccess.get_file_as_string("user://case01-save.json"))
    if not (save_data is Dictionary):
        _fail("Save data malformed")
        return
    var saved_clues: Array = save_data.get("found", [])
    if not saved_clues.has("shop_testimony") or not saved_clues.has("radio_testimony") or not saved_clues.has("identity_check"):
        _fail("Witness statements missing from persistent save")
        return
    game.set("collected", {})
    game.set("finished", false)
    if game.call("_ready_to_deduce"):
        _fail("Deduction unlocked before evidence")
        return
    var proof: Dictionary = {}
    for clue in ["poster", "ledger", "log", "tape"]:
        proof[clue] = true
    game.set("collected", proof)
    if not game.call("_ready_to_deduce"):
        _fail("Four required clues should unlock deduction")
        return
    game.call("_answer", "A")
    if game.get("finished"):
        _fail("Incorrect answer completed case")
        return
    game.call("_answer", "B")
    if not game.get("finished"):
        _fail("Correct answer failed to complete case")
        return
    if not FileAccess.file_exists("user://case01-save.json"):
        _fail("Completion did not save")
        return
    print("CASE01_OK: areas, school, optional testimony crosscheck, gaze, case logic, persistence")
    quit(0)
