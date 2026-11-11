extends RefCounted
## Original low-poly witness characters. Procedural meshes, no third-party art.
## The deliberately simplified figures are placeholders for authored character assets.
static var materials: Dictionary = {}

static func build(scene: Node3D, person: String, origin: Vector3) -> Node3D:
    var root := Node3D.new()
    root.name = "Witness_" + person
    root.set_script(preload("res://scripts/witness_motion.gd"))
    root.position = origin
    scene.add_child(root)
    var shopkeeper: bool = person == "npc_shop"
    var coat := Color(0.27, 0.36, 0.31) if shopkeeper else Color(0.27, 0.33, 0.43)
    var trim := Color(0.65, 0.58, 0.42) if shopkeeper else Color(0.70, 0.72, 0.67)
    var pants := Color(0.24, 0.23, 0.23)
    var skin := Color(0.68, 0.52, 0.39)
    # Facing toward the center of the room (+Z). Distinct silhouettes and proportions.
    _capsule(root, Vector3(0, 1.14, 0), Vector3(0.50, 0.68, 0.32), coat)
    _box(root, Vector3(0, 0.83, 0.02), Vector3(0.49, 0.12, 0.32), coat.darkened(0.18))
    _capsule(root, Vector3(0, 1.47, 0), Vector3(0.13, 0.16, 0.13), skin)
    var hands_pivot := Node3D.new()
    hands_pivot.name = "HandsPivot"
    root.add_child(hands_pivot)
    for side in [-1.0, 1.0]:
        _capsule(root, Vector3(side * 0.32, 1.12, 0.0), Vector3(0.17, 0.65, 0.19), coat)
        _capsule(root, Vector3(side * 0.13, 0.42, 0.0), Vector3(0.20, 0.72, 0.23), pants)
        _box(root, Vector3(side * 0.13, 0.065, 0.075), Vector3(0.23, 0.13, 0.30), Color(0.13, 0.13, 0.12))
        _sphere(hands_pivot, Vector3(side * 0.32, 0.77, 0.04), Vector3(0.10, 0.13, 0.09), skin)
    var head_pivot := Node3D.new()
    head_pivot.name = "HeadPivot"
    head_pivot.position = Vector3(0, 1.46, 0)
    head_pivot.scale = Vector3.ONE * 0.72
    root.add_child(head_pivot)
    _capsule(head_pivot, Vector3(0, 0.21, 0), Vector3(0.38, 0.45, 0.35), skin)
    _sphere(head_pivot, Vector3(0, 0.40, -0.06), Vector3(0.42, 0.18, 0.38), Color(0.16, 0.16, 0.14))
    # Restrained facial landmarks, still intentionally low-poly transitional faces.
    _sphere(head_pivot, Vector3(0, 0.20, 0.18), Vector3(0.07, 0.10, 0.08), skin)
    for side in [-1.0, 1.0]:
        _sphere(head_pivot, Vector3(side * 0.19, 0.21, 0), Vector3(0.07, 0.12, 0.06), skin)
        _sphere(head_pivot, Vector3(side * 0.08, 0.25, 0.167), Vector3(0.043, 0.023, 0.022),
            Color(0.20, 0.17, 0.14))
        _box(head_pivot, Vector3(side * 0.08, 0.29, 0.163), Vector3(0.075, 0.012, 0.014),
            Color(0.21, 0.19, 0.15))
    _box(head_pivot, Vector3(0, 0.12, 0.16), Vector3(0.078, 0.009, 0.014),
        Color(0.42, 0.27, 0.21))
    if shopkeeper:
        # 2003 small-town shopkeeper: tied-back hair, apron and cardigan.
        _sphere(head_pivot, Vector3(0, 0.29, -0.24), Vector3(0.22, 0.22, 0.20), Color(0.15, 0.14, 0.13))
        _box(root, Vector3(0, 1.10, 0.19), Vector3(0.42, 0.62, 0.05), Color(0.65, 0.59, 0.47))
        _box(root, Vector3(0, 1.34, 0.23), Vector3(0.19, 0.12, 0.035), Color(0.40, 0.37, 0.32))
        _box(root, Vector3(0, 0.95, 0.23), Vector3(0.30, 0.16, 0.04), Color(0.55, 0.49, 0.39))
    else:
        # Former broadcast employee: square shoulders, collar, badge and thick glasses.
        _box(root, Vector3(0, 1.43, 0.17), Vector3(0.28, 0.10, 0.035), Color(0.73, 0.70, 0.61))
        _box(root, Vector3(0, 1.28, 0.19), Vector3(0.09, 0.31, 0.05), Color(0.40, 0.27, 0.24))
        _box(root, Vector3(-0.16, 1.25, 0.19), Vector3(0.13, 0.08, 0.03), trim)
        for side in [-1.0, 1.0]:
            for y in [0.20, 0.29]:
                _box(head_pivot, Vector3(side * 0.10, y, 0.185), Vector3(0.15, 0.012, 0.025), Color(0.16, 0.16, 0.15))
            for dx in [-0.075, 0.075]:
                _box(head_pivot, Vector3(side * 0.10 + dx, 0.245, 0.185), Vector3(0.012, 0.09, 0.025), Color(0.16, 0.16, 0.15))
        _box(head_pivot, Vector3(0, 0.23, 0.20), Vector3(0.12, 0.03, 0.03), Color(0.16, 0.16, 0.15))
    # Physical personal space. Names belong in the interaction/dialogue UI.
    var body := StaticBody3D.new()
    body.name = "Body"
    body.collision_layer = 1
    body.collision_mask = 0
    var collider := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.36
    capsule.height = 1.82
    collider.shape = capsule
    collider.position = Vector3(0, 0.92, 0)
    body.add_child(collider)
    root.add_child(body)
    return root

static func _material(color: Color) -> StandardMaterial3D:
    var key: String = color.to_html()
    if materials.has(key):
        return materials[key]
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.93
    materials[key] = mat
    return mat

static func _box(root: Node3D, at: Vector3, dimensions: Vector3, color: Color) -> void:
    var node := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    node.mesh = mesh
    node.position = at
    node.material_override = _material(color)
    root.add_child(node)

static func _capsule(root: Node3D, at: Vector3, dimensions: Vector3, color: Color) -> void:
    var node := MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = minf(dimensions.x, dimensions.z) * 0.5
    mesh.height = maxf(dimensions.y, mesh.radius * 2.01)
    node.mesh = mesh
    node.position = at
    node.scale = Vector3(dimensions.x / (mesh.radius * 2.0), 1.0, dimensions.z / (mesh.radius * 2.0))
    node.material_override = _material(color)
    root.add_child(node)

static func _sphere(root: Node3D, at: Vector3, dimensions: Vector3, color: Color) -> void:
    var node := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    node.mesh = mesh
    node.position = at
    node.scale = dimensions
    node.material_override = _material(color)
    root.add_child(node)
