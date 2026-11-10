extends RefCounted
## First proper exterior visual slice for Huai Sheng (fictional 2003 county town).
## Resource-free original geometry and code-painted surface materials. Transitional art.
const Finish = preload("res://scripts/radio_finishes.gd")
const GUTTER := Color(0.17, 0.23, 0.24)
const GREEN := Color(0.18, 0.31, 0.29)
const BROWN := Color(0.40, 0.30, 0.23)
const CREAM := Color(0.63, 0.61, 0.51)
const STEEL := Color(0.29, 0.34, 0.34)

static func build(scene: Node3D, haunted: bool) -> void:
    var root := Node3D.new()
    root.name = "TownSet"
    scene.add_child(root)
    _street(root, haunted)
    _houses(root)
    _storefronts(root)
    _notice(root)
    _phone(root)
    _utility(root)
    _shrine_gateway(root)
    _street_lighting(root, haunted)
    if haunted:
        # Sibling makes the one-shot apparition independently testable without
        # contaminating the previous era's facade meshes or hotspot positions.
        var anomaly := Node3D.new()
        anomaly.name = "TownAnomaly"
        scene.add_child(anomaly)
        _box(anomaly, Vector3(-5.20, 2.08, -12.3), Vector3(0.06, 0.86, 1.72),
            Color(0.29, 0.36, 0.32), "steel")
        _text(anomaly, "广播已经结束\n请不要回答", Vector3(-5.04, 2.12, -12.3),
            29, Color(0.96, 0.43, 0.31))
        _box(anomaly, Vector3(-3.9, 2.90, 2.9), Vector3(0.18, 0.12, 0.09),
            Color(0.81, 0.27, 0.15), "glass")
        _light(anomaly, Vector3(-4.23, 2.65, 2.6),
            Color(0.73, 0.16, 0.14), 1.0, 5.8, false)

static func _street(root: Node3D, haunted: bool) -> void:
    # Narrow 2003 county road, ditch, grey flagstone pavements and varied repair work.
    _box(root, Vector3(0, -0.25, -7), Vector3(90, 0.49, 105),
        Color(0.28, 0.32, 0.29), "concrete", true)
    _box(root, Vector3(0, 0.014, -6), Vector3(7.75, 0.044, 80.0),
        Color(0.28, 0.31, 0.31), "asphalt")
    for side in [-1, 1]:
        var s: float = float(side)
        # Raised stone pavement with narrow concrete drainage run below it.
        _box(root, Vector3(s * 4.38, 0.105, -6), Vector3(1.0, 0.22, 80),
            Color(0.46, 0.45, 0.39), "concrete")
        _box(root, Vector3(s * 3.86, 0.035, -6), Vector3(0.16, 0.028, 80),
            GUTTER, "steel")
        for i in range(42):
            var z: float = -43.0 + float(i) * 1.82
            var slab: Color = CREAM if i % 5 == 0 else Color(0.45, 0.46, 0.41)
            _box(root, Vector3(s * 4.40, 0.217, z),
                Vector3(0.86, 0.015, 1.60), slab, "concrete")
            _box(root, Vector3(s * 3.93, 0.175, z),
                Vector3(0.14, 0.07, 0.055), GUTTER, "concrete")
        # Uneven worn rain gutters and dark puddles avoid road-stripe look.
        for j in range(10):
            var z: float = -32.0 + float(j) * 6.4
            _box(root, Vector3(s * 3.54, 0.047, z),
                Vector3(0.38 + float(j % 3) * 0.13, 0.008, 1.15),
                Color(0.13, 0.23, 0.24), "glass")
    # Irregular patches have horizontal wear and no modern lane-centre markings.
    for i in range(17):
        var z: float = -37.0 + float(i) * 4.15
        var x: float = sin(float(i) * 1.7) * 1.42
        _box(root, Vector3(x, 0.041, z), Vector3(1.14 + float(i % 3) * 0.39, 0.008, 0.90),
            Color(0.26, 0.29, 0.28) if i % 2 == 0 else Color(0.33, 0.34, 0.32),
            "concrete")
    # Worn stormwater cover and small roadside concrete utilities.
    _box(root, Vector3(2.2, 0.056, 0), Vector3(0.8, 0.015, 0.52),
        Color(0.29, 0.34, 0.34), "steel")
    for i in range(5):
        _box(root, Vector3(2.2, 0.067, -0.19 + float(i) * 0.09),
            Vector3(0.67, 0.006, 0.018), GUTTER, "steel")

static func _houses(root: Node3D) -> void:
    _house(root, -1, 4.0, 12.0, 6.2, Color(0.56, 0.52, 0.43),
        Color(0.29, 0.32, 0.29), "shop")
    _house(root, 1, 15.4, 9.6, 6.6, Color(0.50, 0.56, 0.51),
        Color(0.27, 0.30, 0.30), "home")
    _house(root, 1, -8.4, 12.7, 7.2, Color(0.46, 0.52, 0.49),
        Color(0.26, 0.31, 0.30), "radio")
    _house(root, -1, -15.8, 11.4, 5.4, Color(0.53, 0.50, 0.43),
        Color(0.31, 0.30, 0.28), "home")
    _house(root, 1, -24.7, 13.7, 5.9, Color(0.47, 0.47, 0.41),
        Color(0.25, 0.29, 0.28), "home")
    _house(root, -1, 20.8, 9.1, 5.0, Color(0.48, 0.51, 0.44),
        Color(0.28, 0.31, 0.30), "home")

static func _house(root: Node3D, side: int, center_z: float, length: float,
    height: float, plaster: Color, roof: Color, role: String) -> void:
    var s: float = float(side)
    var front_x: float = s * 5.34
    # Deep building bodies, complete side returns, nonuniform roof heights.
    _box(root, Vector3(s * 8.56, height * 0.5, center_z),
        Vector3(6.43, height, length), plaster, "plaster", true)
    _box(root, Vector3(s * 8.58, height + 0.12, center_z),
        Vector3(7.20, 0.27, length + 0.52), roof, "concrete")
    _box(root, Vector3(front_x - s * 0.12, height - 0.28, center_z),
        Vector3(0.20, 0.25, length + 0.18), Color(0.36, 0.38, 0.33), "concrete")
    # Layered masonry courses and blue-green lower enamel bands.
    _box(root, Vector3(front_x - s * 0.10, 0.58, center_z),
        Vector3(0.10, 1.16, length - 0.18), GREEN, "plaster")
    for y in [0.62, 1.17, height - 0.43]:
        _box(root, Vector3(front_x - s * 0.19, y, center_z),
            Vector3(0.12, 0.065, length - 0.08),
            Color(0.41, 0.39, 0.32), "concrete")
    # Keep windows high enough not to conflict with the entrance interaction.
    for floor_index in range(1 if height < 5.6 else 2):
        var y: float = 2.20 + float(floor_index) * 2.52
        if y + 0.80 > height - 0.37:
            continue
        for i in range(3):
            var z: float = center_z + (-0.33 + float(i) * 0.33) * length
            if i == 1 and floor_index == 0:
                continue
            _window(root, front_x - s * 0.21, y, z, role, side)
    # Painted hairline cracks, vents and water damage, in depth instead of flat noise.
    for i in range(11):
        var z: float = center_z - length * 0.45 + float(i) * length / 10.0
        var y: float = 1.36 + float((i * 7) % 4) * 0.62
        _box(root, Vector3(front_x - s * 0.19, y, z),
            Vector3(0.024, 0.28 + float(i % 3) * 0.16, 0.028),
            Color(0.39, 0.43, 0.37), "plaster")
    # External service conduits and real dimension in the eaves.
    _box(root, Vector3(front_x - s * 0.22, height - 0.68, center_z),
        Vector3(0.055, 0.055, length - 0.2), STEEL, "steel")
    for z in [center_z - length * 0.38, center_z + length * 0.39]:
        _box(root, Vector3(front_x - s * 0.24, height * 0.48, z),
            Vector3(0.048, height * 0.73, 0.052), STEEL, "steel")
    # A smaller side plaque distinguishes buildings from repeated blocks.
    if role == "home":
        _box(root, Vector3(front_x - s * 0.29, 1.65, center_z),
            Vector3(0.07, 0.27, 0.52), Color(0.76, 0.68, 0.50), "paper")

static func _window(root: Node3D, x: float, y: float, z: float,
    role: String, side: int) -> void:
    var s: float = float(side)
    _box(root, Vector3(x, y, z), Vector3(0.17, 1.42, 1.18),
        Color(0.28, 0.35, 0.33), "wood")
    _box(root, Vector3(x - s * 0.085, y, z), Vector3(0.065, 1.18, 0.99),
        Color(0.12, 0.22, 0.23), "glass")
    _box(root, Vector3(x - s * 0.15, y, z), Vector3(0.065, 1.25, 0.05),
        Color(0.63, 0.56, 0.42), "wood")
    _box(root, Vector3(x - s * 0.15, y + 0.07, z), Vector3(0.065, 0.055, 1.06),
        Color(0.63, 0.56, 0.42), "wood")
    _box(root, Vector3(x - s * 0.20, y - 0.74, z),
        Vector3(0.34, 0.115, 1.47), Color(0.45, 0.42, 0.34), "concrete")
    # Curtain strips and old burgundy shutters: unevenly open, no neon.
    if role != "radio":
        _box(root, Vector3(x - s * 0.13, y, z - 0.34),
            Vector3(0.035, 1.10, 0.26),
            Color(0.51, 0.42, 0.34), "fabric")
    else:
        for j in range(4):
            _box(root, Vector3(x - s * 0.16, y - 0.42 + j * 0.28, z),
                Vector3(0.032, 0.04, 1.00), Color(0.42, 0.49, 0.46), "steel")

static func _storefronts(root: Node3D) -> void:
    # Shopfront: tapered awning, metal shutters, hand-painted signs and stacked crates.
    _entrance(root, -1, 4.0, GREEN, "吉祥小卖部\n副食·冷饮")
    _awning(root, -1, 4.0, 5.0, Color(0.25, 0.41, 0.36))
    for i in range(11):
        _box(root, Vector3(-5.10, 1.23, 0.52 + float(i) * 0.62),
            Vector3(0.045, 2.19, 0.018),
            Color(0.39, 0.45, 0.42), "steel")
    for i in range(5):
        _box(root, Vector3(-4.74, 0.37, 6.75 + float(i) * 0.38),
            Vector3(0.52, 0.72, 0.33),
            Color(0.49, 0.36, 0.24) if i % 2 == 0 else Color(0.56, 0.45, 0.31),
            "wood")
    _text(root, "汽水 / 糖果 / 日用百货", Vector3(-4.97, 2.18, 6.65),
        22, Color(0.84, 0.78, 0.61))
    # Public broadcast building: period-correct glazed doors and defunct speaker.
    _entrance(root, 1, -8.0, Color(0.23, 0.34, 0.33), "县有线广播站\n值班室")
    _awning(root, 1, -8.0, 5.0, Color(0.34, 0.42, 0.41))
    _box(root, Vector3(5.06, 3.60, -8.00), Vector3(0.16, 0.78, 3.48),
        Color(0.24, 0.32, 0.29), "wood")
    _text(root, "怀声镇广播站  2003", Vector3(4.81, 3.66, -8.0),
        25, Color(0.84, 0.73, 0.53))
    _box(root, Vector3(4.93, 4.36, -6.25), Vector3(0.20, 0.55, 0.46),
        Color(0.58, 0.59, 0.52), "steel")
    for i in range(5):
        _box(root, Vector3(4.81, 4.21 + float(i) * 0.07, -6.25),
            Vector3(0.02, 0.016, 0.35), GUTTER, "steel")

static func _entrance(root: Node3D, side: int, z: float,
    shade: Color, words: String) -> void:
    var s: float = float(side)
    _box(root, Vector3(s * 5.09, 1.18, z), Vector3(0.15, 2.33, 1.60),
        shade, "wood")
    _box(root, Vector3(s * 4.97, 1.18, z), Vector3(0.068, 2.10, 1.25),
        Color(0.18, 0.25, 0.25), "wood")
    _box(root, Vector3(s * 4.92, 1.90, z), Vector3(0.039, 0.53, 0.80),
        Color(0.18, 0.33, 0.35), "glass")
    _box(root, Vector3(s * 4.89, 1.16, z + 0.42), Vector3(0.08, 0.21, 0.042),
        Color(0.77, 0.67, 0.44), "brass")
    for dz in [-0.86, 0.86]:
        _box(root, Vector3(s * 4.90, 1.21, z + dz),
            Vector3(0.13, 2.48, 0.13), Color(0.57, 0.51, 0.38), "wood")
    _text(root, words, Vector3(s * 4.74, 2.81, z),
        29, Color(0.83, 0.72, 0.52))

static func _awning(root: Node3D, side: int, z: float, width: float, color: Color) -> void:
    var s: float = float(side)
    _box(root, Vector3(s * 4.70, 3.02, z), Vector3(1.30, 0.10, width), color, "fabric")
    _box(root, Vector3(s * 4.12, 2.85, z), Vector3(0.08, 0.29, width),
        Color(0.23, 0.30, 0.28), "wood")
    for dz in [-width * 0.41, width * 0.41]:
        _beam(root, Vector3(s * 5.23, 3.49, z + dz),
            Vector3(s * 4.08, 2.93, z + dz),
            0.038, STEEL, "steel")
    for i in range(7):
        var tz: float = z - width * 0.40 + float(i) * width * 0.133
        _box(root, Vector3(s * 4.10, 2.91, tz), Vector3(0.08, 0.06, 0.20),
            Color(0.64, 0.60, 0.48), "fabric")

static func _notice(root: Node3D) -> void:
    # Landmark replaces the former giant floating yellow sheet at the centre of the road.
    var x: float = -1.30
    var z: float = 12.00
    for dx in [-0.63, 0.63]:
        _box(root, Vector3(x + dx, 0.84, z - 0.08), Vector3(0.11, 1.66, 0.15),
            Color(0.38, 0.29, 0.21), "wood")
    _box(root, Vector3(x, 1.48, z), Vector3(1.44, 1.35, 0.16),
        Color(0.29, 0.25, 0.21), "wood")
    _box(root, Vector3(x, 1.50, z + 0.095), Vector3(1.18, 1.10, 0.025),
        Color(0.78, 0.70, 0.52), "paper")
    _box(root, Vector3(x, 2.20, z), Vector3(1.63, 0.11, 0.45),
        Color(0.30, 0.32, 0.28), "steel")
    _text(root, "寻 人 启 事\n2003.7.17\n林小禾 · 11岁",
        Vector3(x, 1.52, z + 0.13), 21, Color(0.30, 0.31, 0.29))
    for dx in [-0.49, 0.49]:
        _disk(root, Vector3(x + dx, 1.98, z + 0.15),
            0.028, 0.018, Color(0.62, 0.17, 0.15), "brass")

static func _phone(root: Node3D) -> void:
    # Faded public phone cabinet and scratched aluminium hood.
    _box(root, Vector3(4.98, 1.13, 16.4), Vector3(0.58, 2.19, 1.18),
        Color(0.21, 0.40, 0.36), "steel")
    _box(root, Vector3(4.55, 1.55, 16.4), Vector3(0.06, 0.89, 0.70),
        Color(0.38, 0.47, 0.42), "bakelite")
    _box(root, Vector3(4.49, 1.76, 16.4), Vector3(0.03, 0.29, 0.43),
        Color(0.17, 0.24, 0.25), "glass")
    _text(root, "公用电话", Vector3(4.49, 2.46, 16.4),
        23, Color(0.80, 0.77, 0.58))
    for i in range(9):
        _box(root, Vector3(4.48, 1.34 - float(i / 3) * 0.10,
            16.2 + float(i % 3) * 0.16),
            Vector3(0.018, 0.045, 0.068),
            Color(0.70, 0.67, 0.56), "bakelite")
    _box(root, Vector3(4.46, 1.98, 16.13), Vector3(0.06, 0.38, 0.12),
        Color(0.16, 0.22, 0.20), "bakelite")
    _box(root, Vector3(4.80, 2.27, 16.4), Vector3(0.97, 0.14, 1.41),
        Color(0.31, 0.33, 0.29), "steel")

static func _utility(root: Node3D) -> void:
    for z in [19.7, 1.0, -17.0, -30.0]:
        var at := Vector3(4.90, 0, z)
        _cylinder(root, at + Vector3(0, 3.7, 0), 0.11, 7.4,
            Color(0.27, 0.28, 0.25), "wood")
        _box(root, at + Vector3(0, 6.75, 0), Vector3(0.17, 0.20, 2.65),
            Color(0.45, 0.40, 0.32), "wood")
        for dz in [-1.04, -0.30, 0.42, 1.04]:
            _cylinder(root, at + Vector3(0, 6.90, dz), 0.075, 0.29,
                Color(0.70, 0.65, 0.51), "bakelite")
    # Sagging overhead lines run along the road. No more floating horizontal box strips.
    for z in [19.7, 1.0, -17.0]:
        for lane in [-1.02, -0.25, 0.45]:
            var p0 := Vector3(4.90, 6.93, z + lane)
            var p1 := Vector3(4.90, 6.93, z - 18.5 + lane)
            for segment in range(8):
                var t0: float = float(segment) / 8.0
                var t1: float = float(segment + 1) / 8.0
                var a: Vector3 = p0.lerp(p1, t0) + Vector3(0, -0.65 * sin(PI * t0), 0)
                var b: Vector3 = p0.lerp(p1, t1) + Vector3(0, -0.65 * sin(PI * t1), 0)
                _beam(root, a, b, 0.020, GUTTER, "steel")
    # A small telephone cable crossing creates a strong readable overhead silhouette.
    for i in range(9):
        var t0: float = float(i) / 9.0
        var t1: float = float(i + 1) / 9.0
        var a := Vector3(-4.95 + 9.9 * t0, 6.4 - 1.15 * sin(PI * t0), -4.2)
        var b := Vector3(-4.95 + 9.9 * t1, 6.4 - 1.15 * sin(PI * t1), -4.2)
        _beam(root, a, b, 0.022, GUTTER, "steel")

static func _shrine_gateway(root: Node3D) -> void:
    # Narrowing street perspective, old masonry entry and timber gate on axis.
    _box(root, Vector3(0, 2.90, -32.2), Vector3(10.8, 5.80, 1.28),
        Color(0.42, 0.41, 0.35), "plaster", true)
    _box(root, Vector3(0, 1.45, -31.46), Vector3(2.77, 2.89, 0.09),
        Color(0.22, 0.17, 0.15), "wood")
    for x in [-1.54, 1.54]:
        _box(root, Vector3(x, 1.44, -31.25), Vector3(0.22, 3.10, 0.18),
            Color(0.39, 0.29, 0.20), "wood")
    _box(root, Vector3(0, 3.07, -31.25), Vector3(3.34, 0.22, 0.21),
        Color(0.42, 0.29, 0.20), "wood")
    _box(root, Vector3(0, 5.86, -32.2), Vector3(11.9, 0.32, 1.66),
        Color(0.23, 0.26, 0.26), "concrete")
    _box(root, Vector3(0, 3.91, -31.28), Vector3(2.26, 0.58, 0.13),
        Color(0.30, 0.24, 0.20), "wood")
    _text(root, "怀 声 祠", Vector3(0, 3.91, -31.12), 35,
        Color(0.78, 0.64, 0.47))
    # Painted red door couplets, fictional folkloric prohibition.
    for x in [-1.90, 1.90]:
        _box(root, Vector3(x, 2.12, -31.38), Vector3(0.62, 2.51, 0.07),
            Color(0.46, 0.19, 0.16), "paper")
    _text(root, "勿 应 \n夜 名", Vector3(-1.90, 2.16, -31.22), 25,
        Color(0.83, 0.73, 0.51))
    _text(root, "封 声 \n静 听", Vector3(1.90, 2.16, -31.22), 25,
        Color(0.83, 0.73, 0.51))

static func _street_lighting(root: Node3D, haunted: bool) -> void:
    # Warm, shadow-casting sodium practicals. Blue hour retains the actual town.
    for i in range(4):
        var z: float = 15.8 - float(i) * 14.8
        var x: float = -4.38 if i % 2 == 0 else 4.38
        _cylinder(root, Vector3(x, 2.20, z), 0.075, 4.40,
            Color(0.27, 0.30, 0.29), "steel")
        _beam(root, Vector3(x, 4.30, z),
            Vector3(x + (-0.55 if x < 0.0 else 0.55), 4.40, z),
            0.06, STEEL, "steel")
        _box(root, Vector3(x, 4.40, z), Vector3(0.38, 0.12, 0.45),
            Color(0.36, 0.39, 0.36), "steel")
        _box(root, Vector3(x, 4.29, z), Vector3(0.28, 0.10, 0.32),
            Color(0.83, 0.68, 0.41), "glass")
        _light(root, Vector3(x, 4.12, z),
            Color(1.0, 0.67, 0.37) if not haunted else Color(0.83, 0.50, 0.37),
            2.2, 10.3, i < 2)
    _light(root, Vector3(-4.85, 2.80, 4.0),
        Color(0.47, 0.69, 0.63), 1.15, 5.5, false)
    _light(root, Vector3(4.85, 3.22, -8.0),
        Color(0.49, 0.69, 0.66), 0.93, 5.2, false)
    _light(root, Vector3(-0.10, 3.50, -30.2),
        Color(0.68, 0.42, 0.27), 0.70, 6.6, false)

static func _box(root: Node3D, pos: Vector3, size: Vector3,
    tint: Color, surface: String, solid: bool = false) -> void:
    var node := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.position = pos
    node.material_override = Finish.get_finish(surface, tint)
    root.add_child(node)
    if solid:
        var body := StaticBody3D.new()
        body.collision_layer = 1
        body.collision_mask = 0
        body.position = pos
        var shape := CollisionShape3D.new()
        var collision := BoxShape3D.new()
        collision.size = size
        shape.shape = collision
        body.add_child(shape)
        root.add_child(body)

static func _cylinder(root: Node3D, pos: Vector3, radius: float,
    height: float, tint: Color, surface: String) -> void:
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    var node := MeshInstance3D.new()
    node.position = pos
    node.mesh = mesh
    node.material_override = Finish.get_finish(surface, tint)
    root.add_child(node)

static func _disk(root: Node3D, pos: Vector3, radius: float,
    depth: float, tint: Color, surface: String) -> void:
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = depth
    var node := MeshInstance3D.new()
    node.rotation.x = PI * 0.5
    node.position = pos
    node.mesh = mesh
    node.material_override = Finish.get_finish(surface, tint)
    root.add_child(node)

static func _beam(root: Node3D, from_pos: Vector3, to_pos: Vector3,
    radius: float, tint: Color, surface: String) -> void:
    var delta: Vector3 = to_pos - from_pos
    var length: float = delta.length()
    if length < 0.001:
        return
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = length
    var node := MeshInstance3D.new()
    node.position = (from_pos + to_pos) * 0.5
    node.quaternion = Quaternion(Vector3.UP, delta.normalized())
    node.mesh = mesh
    node.material_override = Finish.get_finish(surface, tint)
    root.add_child(node)

static func _text(root: Node3D, content: String, pos: Vector3,
    font_size: int, tint: Color) -> void:
    var label := Label3D.new()
    label.text = content
    label.position = pos
    label.font_size = font_size
    label.pixel_size = 0.004
    label.modulate = tint
    label.outline_size = 2
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    root.add_child(label)

static func _light(root: Node3D, pos: Vector3, tint: Color,
    energy: float, reach: float, cast_shadows: bool) -> void:
    var lamp := OmniLight3D.new()
    lamp.position = pos
    lamp.light_color = tint
    lamp.light_energy = energy
    lamp.omni_range = reach
    lamp.shadow_enabled = cast_shadows
    root.add_child(lamp)
