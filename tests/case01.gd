extends SceneTree
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
        "street": ["poster", "enter_shop", "enter_radio", "enter_shrine"],
        "shop": ["ledger", "exit"],
        "radio": ["log", "tape", "exit"],
        "shrine": ["ritual", "exit"]
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
    print("CASE01_OK: all zones, clues, deduction gate, correct/incorrect answers and save")
    quit(0)
