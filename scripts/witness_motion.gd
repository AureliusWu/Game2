extends Node3D
## Lightweight procedural witness performance. No skeletal rig or recorded voice.
var speaking: bool = false
var elapsed: float = 0.0
var initial_rotation: float = 0.0

func _ready() -> void:
    initial_rotation = rotation.y

func _process(delta: float) -> void:
    elapsed += delta
    var head: Node3D = get_node_or_null("HeadPivot") as Node3D
    if head != null:
        head.rotation.y = sin(elapsed * (2.3 if speaking else 0.6)) * (0.10 if speaking else 0.025)
        head.rotation.x = sin(elapsed * (3.0 if speaking else 0.8)) * (0.045 if speaking else 0.012)
    var hands: Node3D = get_node_or_null("HandsPivot") as Node3D
    if hands != null:
        hands.position.y = sin(elapsed * (2.6 if speaking else 1.2)) * (0.028 if speaking else 0.008)
    rotation.y = initial_rotation + sin(elapsed * 0.4) * 0.012
