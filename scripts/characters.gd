extends RefCounted
const WitnessMotion = preload("res://scripts/witness_motion.gd")
## Original low-poly witness characters. Procedural meshes, no third-party art.
## The deliberately simplified figures are placeholders for authored character assets.

static func build(scene: Node3D, person: String, origin: Vector3) -> Node3D:
    var root := Node3D.new()
    root.name = "Witness_" + person
    root.position = origin
    scene.add_child(root)
    var shopkeeper: bool = person == "npc_shop"
    var coat := Color(0.27, 0.36, 0.31) if shopkeeper else Color(0.27, 0.33, 0.43)
    var trim := Color(0.65, 0.58, 0.42) if shopkeeper else Color(0.70, 0.72, 0.67)
    var pants := Color(0.24, 0.23, 0.23)
    var skin := Color(0.68, 0.52, 0.39)
    # Facing toward the center of the room (+Z). Distinct silhouettes and proportions.
    _capsule(root, Vector3(0, 1.14, 0), Vector3(0.52, 0.82, 0.34), coat)
    _box(root, Vector3(0, 0.83, 0.02), Vector3(0.52, 0.18, 0.35), trim)
    for side in [-1.0, 1.0]:
        var arm := Node3D.new()
        arm.name = "RightArm" if side > 0.0 else "LeftArm"
        arm.position = Vector3(side * 0.37, 1.48, 0.0)
        root.add_child(arm)
        _capsule(arm, Vector3(0, -0.37, 0), Vector3(0.20, 0.76, 0.22), coat)
        _sphere(arm, Vector3(0, -0.78, 0.04), Vector3(0.11, 0.14, 0.10), skin)
        _capsule(root, Vector3(side * 0.14, 0.37, 0.0), Vector3(0.20, 0.67, 0.23), pants)
        _box(root, Vector3(side * 0.14, 0.08, 0.13), Vector3(0.26, 0.16, 0.42), Color(0.13, 0.13, 0.12))
    var head := Node3D.new()
    head.name = "HeadPivot"
    head.position = Vector3(0, 1.78, 0)
    root.add_child(head)
    _capsule(head, Vector3.ZERO, Vector3(0.38, 0.45, 0.35), skin)
    _sphere(head, Vector3(0, 0.19, -0.06), Vector3(0.42, 0.18, 0.38), Color(0.16, 0.16, 0.14))
    if shopkeeper:
        # 2003 small-town shopkeeper: tied-back hair, apron and cardigan.
        _sphere(head, Vector3(0, 0.08, -0.24), Vector3(0.22, 0.22, 0.20), Color(0.15, 0.14, 0.13))
        _box(root, Vector3(0, 1.10, 0.19), Vector3(0.42, 0.62, 0.05), Color(0.65, 0.59, 0.47))
        _box(root, Vector3(0, 1.34, 0.23), Vector3(0.19, 0.12, 0.035), Color(0.40, 0.37, 0.32))
        _box(root, Vector3(0, 0.95, 0.23), Vector3(0.30, 0.16, 0.04), Color(0.55, 0.49, 0.39))
    else:
        # Former broadcast employee: square shoulders, collar, badge and thick glasses.
        _box(root, Vector3(0, 1.48, 0.17), Vector3(0.33, 0.16, 0.06), Color(0.73, 0.70, 0.61))
        _box(root, Vector3(0, 1.28, 0.19), Vector3(0.09, 0.31, 0.05), Color(0.40, 0.27, 0.24))
        _box(root, Vector3(-0.16, 1.25, 0.19), Vector3(0.13, 0.08, 0.03), trim)
        for side in [-1.0, 1.0]:
            _box(head, Vector3(side * 0.12, 0.02, 0.185), Vector3(0.18, 0.10, 0.04), Color(0.16, 0.16, 0.15))
        _box(head, Vector3(0, 0.02, 0.20), Vector3(0.12, 0.03, 0.03), Color(0.16, 0.16, 0.15))
    # A grounded name tag avoids treating the figures as featureless cylinder props.
    var tag := Label3D.new()
    tag.text = "吴婶" if shopkeeper else "陈站长"
    tag.font_size = 27
    tag.pixel_size = 0.005
    tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    tag.position = Vector3(0, 2.37, 0)
    tag.modulate = Color(0.93, 0.84, 0.63)
    root.add_child(tag)
    var motion := WitnessMotion.new()
    motion.name = "Motion"
    root.add_child(motion)
    return root

static func _material(color: Color) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.93
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
