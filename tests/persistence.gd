extends SceneTree
## Editor CLI adapter. Export templates enter the same runner via --qa-persistence.
const Runner = preload("res://tests/persistence_runner.gd")

func _initialize() -> void:
    root.add_child.call_deferred(Runner.new())
