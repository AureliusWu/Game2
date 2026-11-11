extends RefCounted
## Reversible, collision-checked conversation camera. The player body never moves.
var active: bool = false
var witness: Node3D
var camera: Camera3D
var saved_transform: Transform3D
var saved_top_level: bool
var saved_fov: float
var tween: Tween

func begin(actor: Node3D, eyes: Camera3D) -> void:
    if active and witness == actor:
        return
    finish()
    active = true
    witness = actor
    camera = eyes
    saved_transform = camera.transform
    saved_top_level = camera.top_level
    saved_fov = camera.fov
    var previous: Transform3D = camera.global_transform
    camera.top_level = true
    camera.global_transform = previous
    reframe()

func reframe() -> void:
    if not active or not is_instance_valid(witness) or not is_instance_valid(camera):
        return
    if tween != null and tween.is_valid():
        tween.kill()
    var space: PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state
    var ignored: Array[RID] = []
    var body: CollisionObject3D = witness.get_node_or_null("Body")
    if body != null:
        ignored.append(body.get_rid())
    var approach: Vector3 = camera.global_position - witness.global_position
    approach.y = 0
    if approach.length() < 0.05:
        approach = Vector3.BACK
    approach = approach.normalized()
    var at: Vector3 = camera.global_position
    var target: Vector3 = witness.global_position + Vector3(0, 1.2, 0)
    for angle in [0.0, 0.55, -0.55, 1.1, -1.1]:
        var candidate: Vector3 = witness.global_position + approach.rotated(Vector3.UP, angle) * 2.6 + Vector3(0, 1.60, 0)
        var path := PhysicsRayQueryParameters3D.create(camera.global_position, candidate, 1, ignored)
        var hit: Dictionary = space.intersect_ray(path)
        if not hit.is_empty():
            candidate = hit["position"] + hit["normal"] * 0.18
        if Vector2(candidate.x - target.x, candidate.z - target.z).length() < 1.65:
            continue
        var sphere := SphereShape3D.new()
        sphere.radius = 0.13
        var clearance := PhysicsShapeQueryParameters3D.new()
        clearance.shape = sphere
        clearance.transform = Transform3D(Basis.IDENTITY, candidate)
        clearance.collision_mask = 1
        clearance.exclude = ignored
        if not space.intersect_shape(clearance, 1).is_empty():
            continue
        var sight := PhysicsRayQueryParameters3D.create(candidate, target, 1, ignored)
        if not space.intersect_ray(sight).is_empty():
            continue
        at = candidate
        break
    var view: Vector2 = camera.get_viewport().get_visible_rect().size
    var compact: bool = view.x < 1100.0
    target = witness.global_position + Vector3(0, 1.70 if compact else 1.18, 0)
    var distance: float = at.distance_to(target)
    camera.fov = 72.0
    var forward: Vector3 = (target - at).normalized()
    var right: Vector3 = forward.cross(Vector3.UP).normalized()
    var tan_half: float = tan(deg_to_rad(camera.fov * 0.5))
    var screen_x: float = 0.5 if compact else (1.0 - minf(420.0, view.x * 0.36) / view.x - 22.0 / view.x) * 0.5
    var screen_y: float = 0.22 if compact else 0.52
    var look: Vector3 = target + right * distance * tan_half * view.x / view.y * (1.0 - screen_x * 2.0)
    look += Vector3.UP * distance * tan_half * (screen_y * 2.0 - 1.0)
    var framed := Transform3D(Basis.looking_at(look - at, Vector3.UP), at)
    tween = camera.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    tween.tween_property(camera, "global_transform", framed, 0.20)

func finish() -> void:
    if tween != null and tween.is_valid():
        tween.kill()
    if active and is_instance_valid(camera):
        camera.top_level = saved_top_level
        camera.transform = saved_transform
        camera.fov = saved_fov
    active = false
    witness = null
