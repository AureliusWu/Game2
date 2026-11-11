extends RefCounted
## Camera-centered interaction with range, alignment, and solid-world occlusion.
## Unlike a pure distance/cone search, this cannot inspect behind opaque walls.

const MAX_DISTANCE: float = 3.3
const MIN_ALIGNMENT: float = 0.88

static func choose(
    camera: Camera3D,
    hotspots: Array[Dictionary],
    space: PhysicsDirectSpaceState3D
) -> Dictionary:
    if camera == null or space == null:
        return {}
    var origin: Vector3 = camera.global_position
    var forward: Vector3 = -camera.global_transform.basis.z
    var best: Dictionary = {}
    var best_score: float = -1000.0
    for entry in hotspots:
        var target: Vector3 = entry["position"]
        var delta: Vector3 = target - origin
        var distance: float = delta.length()
        if distance < 0.01 or distance > MAX_DISTANCE:
            continue
        var alignment: float = forward.dot(delta / distance)
        if alignment < MIN_ALIGNMENT:
            continue
        var query := PhysicsRayQueryParameters3D.create(origin, target, 1)
        query.collide_with_areas = false
        var hit: Dictionary = space.intersect_ray(query)
        if not hit.is_empty():
            var hit_distance: float = origin.distance_to(hit["position"])
            var own_target: bool = entry.has("target_rid") and hit.get("rid") == entry["target_rid"]
            if not own_target and hit_distance < distance - 0.12:
                continue
        var score: float = alignment * 6.0 - distance * 0.40
        if score > best_score:
            best_score = score
            best = entry
    return best
