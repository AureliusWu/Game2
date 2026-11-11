extends SceneTree
## Run: godot --headless --path . --script res://tests/smoke.gd
func _initialize() -> void:
    var packed: PackedScene = load("res://scenes/main.tscn")
    if packed == null:
        push_error("Main scene failed to load")
        quit(1)
        return
    var root: Node = packed.instantiate()
    root.set("persistence_enabled", false)
    if root == null:
        push_error("Main scene failed to instantiate")
        quit(1)
        return
    get_root().add_child.call_deferred(root)
    call_deferred("_inspect", root)

func _inspect(root: Node) -> void:
    if not is_instance_valid(root):
        push_error("Game root disappeared")
        quit(1)
        return
    if root.get_node_or_null("Player/Camera3D") == null:
        push_error("Camera missing")
        quit(1)
        return
    print("SMOKE_OK: main scene + player + game startup")
    quit(0)
