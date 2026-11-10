extends Node3D
const Dressing = preload("res://scripts/dressing.gd")
const Materials = preload("res://scripts/materials.gd")
## Procedural 3D graybox for Case 01. Replace meshes/materials with licensed PBR assets later.
## Coordinates are in meters; interactable nodes are represented by stable hotspot IDs.
var hotspots: Array[Dictionary] = []
var current_zone: String = "street"
var haunted: bool = false

func build_zone(zone: String) -> void:
    current_zone = zone
    for child in get_children():
        remove_child(child)
        child.queue_free()
    hotspots.clear()
    match zone:
        "street":
            _build_street()
        "shop":
            _build_shop()
        "radio":
            _build_radio()
        "shrine":
            _build_shrine()
        _:
            push_error("Unknown zone: " + zone)
    Dressing.decorate(self, zone, haunted)
    _light(Vector3(0, 7, 0), Color(0.83, 0.87, 1.0), 0.3, 23.0)

func _material(color: Color, emissive: bool = false, surface: String = "") -> StandardMaterial3D:
    if surface != "" and not emissive:
        return Materials.get_surface(surface, color)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.88
    if emissive:
        mat.emission_enabled = true
        mat.emission = color
        mat.emission_energy_multiplier = 1.4
    return mat

func _box(pos: Vector3, size: Vector3, color: Color, solid: bool = false, glow: bool = false, surface: String = "") -> void:
    var obj := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    obj.mesh = mesh
    obj.material_override = _material(color, glow, surface)
    obj.position = pos
    add_child(obj)
    if solid:
        var body := StaticBody3D.new()
        body.collision_layer = 1
        body.collision_mask = 0
        body.position = pos
        var collision := CollisionShape3D.new()
        var box_shape := BoxShape3D.new()
        box_shape.size = size
        collision.shape = box_shape
        body.add_child(collision)
        add_child(body)

func _cylinder(pos: Vector3, radius: float, height: float, color: Color, surface: String = "") -> void:
    var obj := MeshInstance3D.new()
    var shape := CylinderMesh.new()
    shape.top_radius = radius
    shape.bottom_radius = radius
    shape.height = height
    obj.mesh = shape
    obj.material_override = _material(color, false, surface)
    obj.position = pos
    add_child(obj)

func _label(text: String, pos: Vector3, size: int = 34) -> void:
    var node := Label3D.new()
    node.text = text
    node.position = pos
    node.font_size = size
    node.pixel_size = 0.005
    node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    node.modulate = Color(0.96, 0.88, 0.70)
    node.outline_size = 5
    add_child(node)

func _light(pos: Vector3, color: Color, power: float, reach: float) -> void:
    var light := OmniLight3D.new()
    light.position = pos
    light.light_color = color
    light.light_energy = power
    light.omni_range = reach
    light.shadow_enabled = false
    add_child(light)

func _spot(id: String, name: String, pos: Vector3) -> void:
    hotspots.append({"id": id, "name": name, "position": pos})
    _box(pos + Vector3(0, -0.42, 0), Vector3(0.15, 0.15, 0.15), Color(0.93, 0.70, 0.31), false, true)

func _building(pos: Vector3, size: Vector3, wall: Color, roof: Color) -> void:
    _box(pos, size, wall, true, false, "plaster")
    _box(pos + Vector3(0, size.y * 0.5 + 0.15, 0), Vector3(size.x + 0.7, 0.30, size.z + 0.7), roof, false, false, "tile")
    for i in range(2):
        var offset: float = -size.z * 0.24 + float(i) * size.z * 0.48
        _box(pos + Vector3(0, 0.8, offset), Vector3(0.035, 1.15, 1.25), Color(0.22, 0.33, 0.34))
        _box(pos + Vector3(0.04, 0.8, offset), Vector3(0.05, 0.06, 1.30), Color(0.67, 0.65, 0.53))

func _lamp_post(pos: Vector3) -> void:
    _cylinder(pos + Vector3(0, 2.05, 0), 0.065, 4.1, Color(0.22, 0.25, 0.23))
    _box(pos + Vector3(0.0, 4.1, 0), Vector3(0.5, 0.13, 0.5), Color(0.68, 0.62, 0.48))
    _box(pos + Vector3(0.0, 3.93, 0), Vector3(0.28, 0.24, 0.28), Color(1.0, 0.74, 0.37), false, true)
    _light(pos + Vector3(0, 3.8, 0), Color(1.0, 0.72, 0.43), 1.5, 11.0)

func _build_street() -> void:
    var plaster := Color(0.57, 0.57, 0.49)
    var roof := Color(0.23, 0.28, 0.28)
    _box(Vector3(0, -0.24, -8), Vector3(120, 0.45, 115), Color(0.38, 0.42, 0.37), true, false, "concrete")
    _box(Vector3(0, -0.005, -3), Vector3(8.3, 0.04, 75), Color(0.28, 0.29, 0.27), false, false, "asphalt")
    _box(Vector3(-4.45, 0.05, -2), Vector3(0.65, 0.13, 77), Color(0.58, 0.53, 0.43))
    _box(Vector3(4.45, 0.05, -2), Vector3(0.65, 0.13, 77), Color(0.58, 0.53, 0.43))
    for i in range(9):
        _box(Vector3(0, 0.04, 22 - i * 7), Vector3(0.1, 0.018, 2.2), Color(0.65, 0.60, 0.43))
    _building(Vector3(-9, 3.15, 4), Vector3(7.5, 6.3, 11), Color(0.56, 0.52, 0.42), roof)
    _building(Vector3(9, 3.65, -8), Vector3(7.5, 7.3, 11), Color(0.48, 0.55, 0.50), roof)
    _building(Vector3(-11, 2.6, -16), Vector3(10.5, 5.2, 12), plaster, roof)
    _building(Vector3(11, 3.1, 14), Vector3(8.2, 6.2, 9.0), Color(0.54, 0.56, 0.52), roof)
    _building(Vector3(0, 3.3, -32), Vector3(15.0, 6.6, 8.3), Color(0.38, 0.36, 0.32), Color(0.19, 0.23, 0.23))
    # Doors, old advertisements, a weathered shrine gate, dim street lamps.
    _box(Vector3(-5.12, 1.3, 4), Vector3(0.09, 2.5, 1.45), Color(0.27, 0.43, 0.39))
    _box(Vector3(5.12, 1.45, -8), Vector3(0.09, 2.75, 1.50), Color(0.25, 0.35, 0.35))
    _box(Vector3(0, 1.6, -27.78), Vector3(2.5, 3.15, 0.1), Color(0.26, 0.20, 0.17))
    _box(Vector3(-1.2, 1.3, 12.0), Vector3(0.12, 1.7, 1.25), Color(0.92, 0.83, 0.56))
    _label("2003 · 寻人启事", Vector3(-1.2, 2.35, 12), 32)
    _label("吉祥小卖部", Vector3(-4.8, 3.1, 4), 36)
    _label("旧广播站", Vector3(4.85, 3.5, -8), 36)
    _label("怀声祠", Vector3(0, 4.1, -26.8), 40)
    for z in [13.0, -4.0, -20.0]:
        _lamp_post(Vector3(-4.0, 0.0, z))
    _lamp_post(Vector3(4.0, 0.0, -13))
    _spot("poster", "查看寻人启事", Vector3(-1.3, 1.3, 12.0))
    _spot("enter_shop", "进入小卖部", Vector3(-4.0, 1.2, 4.0))
    _spot("enter_radio", "进入广播站", Vector3(4.0, 1.2, -8.0))
    _spot("enter_shrine", "进入祠堂", Vector3(0, 1.2, -26.6))

func _room(floor: Color, wall: Color) -> void:
    _box(Vector3(0, -0.23, 0), Vector3(12, 0.45, 12), floor, true, false, "tile")
    _box(Vector3(0, 3.2, -6), Vector3(12, 6.4, 0.35), wall, true, false, "plaster")
    _box(Vector3(-6, 3.2, 0), Vector3(0.35, 6.4, 12), wall, true, false, "plaster")
    _box(Vector3(6, 3.2, 0), Vector3(0.35, 6.4, 12), wall, true, false, "plaster")
    _box(Vector3(0, 3.2, 6), Vector3(12, 6.4, 0.35), wall, true, false, "plaster")
    _box(Vector3(0, 6.45, 0), Vector3(12, 0.25, 12), Color(0.30, 0.31, 0.28), false, false, "concrete")
    _box(Vector3(0, 3.3, -5.75), Vector3(2.2, 1.4, 0.08), Color(0.23, 0.33, 0.36))
    _box(Vector3(0, 3.3, -5.68), Vector3(0.07, 1.5, 0.08), Color(0.50, 0.45, 0.33))
    _spot("exit", "返回街道", Vector3(0, 1.25, 4.4))
    _lamp_post(Vector3(-4.1, 0, 2.9))

func _build_shop() -> void:
    _room(Color(0.44, 0.39, 0.29), Color(0.65, 0.60, 0.49))
    _box(Vector3(-1.8, 0.55, -2.5), Vector3(2.4, 1.1, 1.0), Color(0.44, 0.30, 0.21), true)
    _box(Vector3(-1.8, 1.2, -2.5), Vector3(2.0, 0.12, 0.85), Color(0.72, 0.67, 0.50))
    for i in range(4):
        _box(Vector3(3.5, 0.9 + i * 0.70, -3.3), Vector3(1.65, 0.12, 2.2), Color(0.35, 0.31, 0.23))
    _box(Vector3(2, 1.0, -4.9), Vector3(0.8, 1.8, 0.6), Color(0.42, 0.57, 0.55))
    _label("旧账本 / 2003 年 7 月", Vector3(-1.8, 2.0, -2.5))
    _spot("ledger", "翻阅旧账本", Vector3(-1.8, 1.38, -1.6))
    _label("汽水  五角", Vector3(3.3, 3.9, -3.3), 30)
    _spot("calendar", "查看墙上旧日历", Vector3(-4.4, 3.3, -4.8))
    _placeholder_person(Vector3(-3.6, 0, 0.1), Color(0.33, 0.39, 0.33))
    _spot("npc_shop", "询问吴婶", Vector3(-3.6, 1.42, 0.1))

func _build_radio() -> void:
    _room(Color(0.34, 0.35, 0.34), Color(0.51, 0.56, 0.52))
    _box(Vector3(0, 0.55, -2.8), Vector3(5, 1.1, 1.3), Color(0.34, 0.29, 0.24), true)
    for x in [-1.6, 0.0, 1.6]:
        _box(Vector3(x, 1.25, -3), Vector3(1.1, 0.85, 0.5), Color(0.13, 0.20, 0.22))
        _box(Vector3(x, 1.25, -2.73), Vector3(0.78, 0.50, 0.07), Color(0.22, 0.48, 0.51), false, true)
    _cylinder(Vector3(2.7, 1.53, -2.3), 0.08, 0.55, Color(0.16, 0.17, 0.16))
    _label("值班日志", Vector3(-2.0, 2.55, -2.4))
    _label("磁带录音", Vector3(2.0, 2.55, -2.4))
    _spot("log", "阅读值班日志", Vector3(-2.0, 1.45, -1.9))
    _spot("tape", "播放旧录音", Vector3(2.0, 1.45, -1.9))
    _spot("broadcast_notice", "查看停播通知", Vector3(-4.1, 2.7, -4.7))
    _placeholder_person(Vector3(3.35, 0, 0.5), Color(0.30, 0.36, 0.47))
    _spot("npc_radio", "询问陈站长", Vector3(3.35, 1.42, 0.5))

func _build_shrine() -> void:
    _room(Color(0.28, 0.25, 0.22), Color(0.34, 0.32, 0.28))
    _box(Vector3(0, 0.85, -4.3), Vector3(4.1, 1.7, 1.3), Color(0.30, 0.16, 0.11), true)
    for x in [-1.0, 0.0, 1.0]:
        _box(Vector3(x, 2.2, -4.35), Vector3(0.55, 1.5, 0.14), Color(0.16, 0.10, 0.08))
    _box(Vector3(0, 1.8, -3.5), Vector3(0.30, 0.75, 0.3), Color(0.64, 0.44, 0.22), false, true)
    _box(Vector3(-3.3, 0.85, -2.4), Vector3(1.5, 1.7, 0.5), Color(0.34, 0.25, 0.19))
    _label("封声残页", Vector3(-2.3, 2.8, -2.2))
    _spot("ritual", "阅读封声残页", Vector3(-2.3, 1.4, -2.1))
    _spot("tablet", "查看无名牌位", Vector3(0.0, 2.3, -3.55))
    _light(Vector3(0, 3.4, -3), Color(0.99, 0.62, 0.32), 1.6, 10.0)

func _placeholder_person(pos: Vector3, coat: Color) -> void:
    # Explicit temporary witness mannequin, with human height and period clothing proportions.
    # No silhouette implies a final character asset or facial animation.
    _cylinder(pos + Vector3(0, 0.82, 0), 0.28, 1.03, coat, "wood")
    _cylinder(pos + Vector3(-0.37, 0.91, 0), 0.10, 0.83, coat)
    _cylinder(pos + Vector3(0.37, 0.91, 0), 0.10, 0.83, coat)
    _cylinder(pos + Vector3(-0.13, 0.22, 0), 0.10, 0.46, Color(0.24, 0.25, 0.23))
    _cylinder(pos + Vector3(0.13, 0.22, 0), 0.10, 0.46, Color(0.24, 0.25, 0.23))
    var head := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.23
    sphere.height = 0.46
    head.mesh = sphere
    head.position = pos + Vector3(0, 1.60, 0)
    head.material_override = _material(Color(0.67, 0.54, 0.40), false, "plaster")
    add_child(head)
