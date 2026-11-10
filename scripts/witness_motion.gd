extends Node
## Authored procedural idle and conversational micro-performance for static low-poly witnesses.
## No mocap or lip-sync; subtle head/shoulder response only.
var elapsed: float = 0.0
var speaking_time: float = 0.0
var baseline_y: float = 0.0

func _ready() -> void:
    var actor := get_parent() as Node3D
    if actor != null:
        baseline_y = actor.position.y

func speak(seconds: float = 2.0) -> void:
    speaking_time = maxf(speaking_time, maxf(0.0, seconds))

func advance(delta: float) -> void:
    if delta <= 0.0:
        return
    elapsed += delta
    speaking_time = maxf(0.0, speaking_time - delta)
    var actor := get_parent() as Node3D
    if actor == null:
        return
    actor.position.y = baseline_y + sin(elapsed * 1.45) * 0.012
    actor.rotation.z = sin(elapsed * 0.73) * 0.013
    var head := actor.get_node_or_null("HeadPivot") as Node3D
    if head != null:
        var talking: float = 1.0 if speaking_time > 0.0 else 0.0
        head.rotation.x = sin(elapsed * 1.2) * 0.025 + talking * (0.06 + sin(elapsed * 7.5) * 0.055)
        head.rotation.y = sin(elapsed * 0.6) * 0.028
    var right_arm := actor.get_node_or_null("RightArm") as Node3D
    if right_arm != null:
        right_arm.rotation.x = (0.16 + sin(elapsed * 5.2) * 0.10) if speaking_time > 0.0 else sin(elapsed * 0.9) * 0.012

func _process(delta: float) -> void:
    advance(delta)
