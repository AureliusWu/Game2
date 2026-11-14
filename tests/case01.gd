extends SceneTree
const Interaction = preload("res://scripts/interaction.gd")
const Screenshots = preload("res://scripts/screenshots.gd")
const RadioFinishes = preload("res://scripts/radio_finishes.gd")
const TapeSequence = preload("res://scripts/tape_sequence.gd")
const TEST_SAVE := "user://qa/case01-test-save.json"
## Deterministic headless checks for the shipped case logic. Not a replacement for desktop play QA.

func _initialize() -> void:
    var scene: PackedScene = load("res://scenes/main.tscn")
    if scene == null:
        push_error("Cannot load main")
        quit(1)
        return
    var game: Node = scene.instantiate()
    game.set("save_path", TEST_SAVE)
    DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
    get_root().add_child.call_deferred(game)
    call_deferred("_check", game)

func _fail(reason: String) -> void:
    push_error("CASE01_FAILED: " + reason)
    quit(1)

func _check(game: Node) -> void:
    var expected: Dictionary = {
        "street": ["poster", "public_phone", "enter_shop", "enter_radio", "enter_shrine"],
        "shop": ["ledger", "calendar", "npc_shop", "exit"],
        "radio": ["log", "tape", "broadcast_notice", "npc_radio", "exit"],
        "shrine": ["ritual", "tablet", "exit"]
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
    # Characters are distinct named scene nodes, not generic cylinders.
    game.call("_go_to", "shop")
    var shop_character: Node = world.get_node_or_null("Witness_npc_shop")
    if shop_character == null or shop_character.get_child_count() < 12:
        _fail("Shopkeeper character mesh missing or incomplete")
        return
    game.call("_go_to", "radio")
    var radio_character: Node = world.get_node_or_null("Witness_npc_radio")
    if radio_character == null or radio_character.get_child_count() < 12:
        _fail("Station chief character mesh missing or incomplete")
        return
    var station_set: Node = world.get_node_or_null("RadioSet")
    if station_set == null or station_set.get_child_count() < 140:
        _fail("Authored broadcast-room furnishings did not build")
        return
    var sample_finish: StandardMaterial3D = RadioFinishes.get_finish("wood", Color(0.45, 0.32, 0.21))
    if sample_finish.normal_texture == null or sample_finish.roughness_texture == null:
        _fail("Radio studio finishes missing generated PBR channels")
        return
    var interior: WorldEnvironment = game.get_node("WorldEnvironment") as WorldEnvironment
    var direct_sun: DirectionalLight3D = game.get_node("Sunlight") as DirectionalLight3D
    if interior.environment.ambient_light_energy > 0.45 or direct_sun.light_energy > 0.2:
        _fail("Indoor radio lighting is still using outdoor light exposure")
        return
    # Character acting must follow dialogue state, and clear on modal exit.
    if shop_character.get_node_or_null("HeadPivot") == null or shop_character.get_node_or_null("HandsPivot") == null:
        _fail("Shopkeeper lacks independent animation pivots")
        return
    if radio_character.get_node_or_null("HeadPivot") == null or radio_character.get_node_or_null("HandsPivot") == null:
        _fail("Station chief lacks independent animation pivots")
        return
    game.call("_interview", "npc_radio")
    if not bool(game.get("witness_panel_mode")):
        _fail("Witness conversation panel did not activate side framing")
        return
    var modal: PanelContainer = game.get("modal") as PanelContainer
    if game.get_viewport().get_visible_rect().size.x >= 1100.0 and modal.anchor_left != 1.0:
        _fail("Wide screen witness panel should leave character visible")
        return
    if not bool(radio_character.get("speaking")):
        _fail("Dialogue did not activate witness performance")
        return
    game.call("_close_modal")
    if bool(radio_character.get("speaking")):
        _fail("Witness performance continued after dialogue")
        return
    if Screenshots.filename("radio", "2026-11-10T17:14:00", 42) != "radio_2026-11-10_17-14-00_42.png":
        _fail("Screenshot filename format changed")
        return
    # Verify environment art nodes exist before and after the tape anomaly.
    game.call("_go_to", "shop")
    var shop_set: Node = world.get_node_or_null("ShopSet")
    if shop_set == null or shop_set.get_node_or_null("OpenLedger") == null:
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
    if world.get_node_or_null("TownAnomaly") == null:
        _fail("Haunted street lacks distinct broadcast apparition")
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
    # Standalone exterior art: no legacy greybox underneath it.
    var town_set: Node = world.get_node_or_null("TownSet")
    if town_set == null or town_set.get_child_count() < 350:
        _fail("Main street authored set is missing or unusually empty")
        return
    if world.get_node_or_null("TownAnomaly") != null:
        _fail("Town anomaly appeared before hearing the tape")
        return
    var town_material: StandardMaterial3D = RadioFinishes.get_finish("concrete",
        Color(0.46, 0.45, 0.39))
    if town_material.roughness_texture == null or town_material.normal_texture == null:
        _fail("Exterior finish lost roughness/normal channels")
        return
    var street_sun: DirectionalLight3D = game.get_node("Sunlight") as DirectionalLight3D
    if street_sun.light_energy > 0.55:
        _fail("Outdoor exposure not switched to overcast art pass")
        return
    # Centered aiming selects the intended object; looking away rejects it.
    var camera: Camera3D = game.get_node("Player/Camera3D") as Camera3D
    var actor: CharacterBody3D = game.get_node("Player") as CharacterBody3D
    actor.global_position = Vector3(-4.55, 1.01, 14.15)
    camera.look_at(Vector3(-4.55, 1.3, 12), Vector3.UP)
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
    # Tape clue requires playback completion; cancelling must be safe.
    game.call("_go_to", "radio")
    game.call("_investigate", "tape")
    if (game.get("collected") as Dictionary).has("tape") or bool(world.get("haunted")):
        _fail("Inspecting cassette prematurely granted evidence")
        return
    if TapeSequence.count() != 4 or not TapeSequence.beat(-1).is_empty():
        _fail("Tape script beat count malformed")
        return
    game.call("_tape_start")
    if not bool(game.get("tape_active")) or int(game.get("tape_step")) != 0:
        _fail("Tape playback did not start")
        return
    var tape_sound: AudioStreamWAV = ambience.event_player.stream as AudioStreamWAV
    if tape_sound == null or tape_sound.data.is_empty():
        _fail("No generated tape audio")
        return
    game.call("_tape_next")
    game.call("_close_modal")
    if (game.get("collected") as Dictionary).has("tape") or bool(world.get("haunted")):
        _fail("Cancelled tape must not award evidence")
        return
    game.call("_investigate", "tape")
    game.call("_tape_start")
    for step in range(TapeSequence.count()):
        if int(game.get("tape_step")) != step:
            _fail("Unexpected tape beat order")
            return
        game.call("_tape_next")
    if bool(game.get("tape_active")) or not (game.get("collected") as Dictionary).has("tape"):
        _fail("Complete tape playback did not archive evidence")
        return
    if not bool(world.get("haunted")):
        _fail("Finished tape did not trigger environmental anomaly")
        return
    game.call("_investigate", "tape")
    game.call("_tape_complete")
    if not (game.get("collected") as Dictionary).has("tape"):
        _fail("Replaying tape lost recorded evidence")
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
    game.call("_save")
    var save_data: Variant = JSON.parse_string(FileAccess.get_file_as_string(TEST_SAVE))
    if not (save_data is Dictionary):
        _fail("Save data malformed")
        return
    var saved_clues: Array = save_data.get("found", [])
    if not saved_clues.has("shop_testimony") or not saved_clues.has("radio_testimony"):
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
    if not FileAccess.file_exists(TEST_SAVE):
        _fail("Completion did not save")
        return
    game.set("collected", {})
    game.set("finished", false)
    game.call("_load_save")
    if not bool(game.get("finished")) or not game.call("_ready_to_deduce"):
        _fail("Existing evidence-ID saves no longer resume correctly")
        return
    var invalid_save := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
    invalid_save.store_string(JSON.stringify({"found": ["poster", "unknown", 42], "finished": "true"}))
    invalid_save.close()
    game.set("collected", {})
    game.set("finished", false)
    game.call("_load_save")
    if bool(game.get("finished")) or (game.get("collected") as Dictionary).size() != 1:
        _fail("Malformed progress falsely completed the case")
        return
    print("CASE01_OK: radio slice materials/lighting,  gated tape playback/cancel/replay/audio, witness, clues, deduction, save")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
    quit(0)
