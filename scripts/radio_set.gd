extends RefCounted
## A deliberately art-directed 2003 county broadcast room, built from original geometry.
## Independent production slice: replace modular procedural meshes with authored GLB/PBR assets later.
const Finish = preload("res://scripts/radio_finishes.gd")

static func build(scene: Node3D, haunted: bool) -> void:
    var root := Node3D.new()
    root.name = "RadioSet"
    scene.add_child(root)
    _architecture(root)
    _wall_story(root, haunted)
    _control_desk(root, haunted)
    _equipment(root)
    _filing_corner(root)
    _lighting(root, haunted)

static func _architecture(root: Node3D) -> void:
    # 12-metre interior but a lower, credible ceiling; nothing behind the player is a void.
    var paint := Color(0.46, 0.51, 0.48)
    var dark := Color(0.20, 0.27, 0.27)
    _box(root, Vector3(0.0, -0.23, 0.0), Vector3(12.0, 0.46, 12.0),
        Color(0.28, 0.29, 0.27), "concrete", true)
    # Old dark parquet, individually varied boards (less obviously repeating than grey tiles).
    for i in range(19):
        var x: float = -5.73 + float(i) * 0.635
        var tint := Color(0.33, 0.28, 0.22).lerp(Color(0.44, 0.36, 0.27), float(i % 5) / 7.0)
        _box(root, Vector3(x, 0.008, 0), Vector3(0.606, 0.022, 11.8), tint, "wood")
    # Dark worn runner leads the camera toward the main recording console.
    _box(root, Vector3(0.0, 0.028, 0.92), Vector3(2.0, 0.02, 6.7),
        Color(0.20, 0.29, 0.29), "fabric")
    for z in range(-2, 5):
        _box(root, Vector3(0, 0.039, float(z) + 0.44), Vector3(1.97, 0.004, 0.008),
            Color(0.27, 0.35, 0.34), "fabric")
    # Structural plaster. Black baseboards and paint band break up the empty box.
    _box(root, Vector3(0, 2.0, -6.0), Vector3(12.0, 4.0, 0.32), paint, "plaster", true)
    _box(root, Vector3(-6, 2.0, 0), Vector3(0.32, 4.0, 12.0), paint, "plaster", true)
    _box(root, Vector3(6, 2.0, 0), Vector3(0.32, 4.0, 12.0), paint, "plaster", true)
    _box(root, Vector3(0, 2.0, 6), Vector3(12.0, 4.0, 0.32), paint, "plaster", true)
    _box(root, Vector3(0, 4.02, 0), Vector3(12.0, 0.24, 12.0),
        Color(0.25, 0.30, 0.28), "concrete")
    # Enamel green 1.12m wainscot and timber skirting; scale matters enormously.
    for z in [-5.78, 5.78]:
        _box(root, Vector3(0, 0.60, z), Vector3(11.7, 1.18, 0.08), dark, "plaster")
        _box(root, Vector3(0, 1.20, z), Vector3(11.7, 0.055, 0.1),
            Color(0.50, 0.43, 0.31), "wood")
        _box(root, Vector3(0, 0.065, z), Vector3(11.7, 0.13, 0.12),
            Color(0.16, 0.20, 0.19), "wood")
    for x in [-5.78, 5.78]:
        _box(root, Vector3(x, 0.6, 0), Vector3(0.08, 1.18, 11.7), dark, "plaster")
        _box(root, Vector3(x, 1.2, 0), Vector3(0.11, 0.055, 11.7),
            Color(0.48, 0.42, 0.32), "wood")
        _box(root, Vector3(x, 0.07, 0), Vector3(0.13, 0.14, 11.7),
            Color(0.15, 0.19, 0.18), "wood")
    # Ceiling steel joists, pipes and long enclosed fluorescent fixtures.
    for z in [-4.5, -1.5, 1.5, 4.5]:
        _box(root, Vector3(0, 3.81, z), Vector3(11.7, 0.10, 0.12),
            Color(0.20, 0.24, 0.23), "steel")
    _box(root, Vector3(3.8, 3.80, 0), Vector3(0.09, 0.11, 11.7),
        Color(0.28, 0.33, 0.32), "steel")
    _box(root, Vector3(-3.95, 3.80, 0), Vector3(0.09, 0.11, 11.7),
        Color(0.28, 0.33, 0.32), "steel")
    # Doors are actually shaped as doors, with frames, latch, and radiator.
    _box(root, Vector3(-2.8, 1.13, 5.77), Vector3(1.6, 2.27, 0.12),
        Color(0.28, 0.36, 0.31), "wood")
    _box(root, Vector3(-2.8, 2.34, 5.76), Vector3(1.85, 0.13, 0.20),
        Color(0.53, 0.45, 0.32), "wood")
    for x in [-3.66, -1.94]:
        _box(root, Vector3(x, 1.19, 5.71), Vector3(0.10, 2.42, 0.17),
            Color(0.53, 0.45, 0.32), "wood")
    _sphere(root, Vector3(-2.12, 1.04, 5.62), 0.07, Color(0.79, 0.67, 0.37), "brass")
    # Old wall radiator left of the window.
    for i in range(12):
        _box(root, Vector3(-5.57, 0.55, -2.9 + float(i) * 0.22),
            Vector3(0.17, 0.75, 0.14), Color(0.42, 0.48, 0.44), "steel")

static func _wall_story(root: Node3D, haunted: bool) -> void:
    # Strong back-wall composition: deep absorbing acoustic fabric, spaced ribs, identity plate.
    _box(root, Vector3(0, 2.52, -5.79), Vector3(8.3, 2.2, 0.13),
        Color(0.18, 0.27, 0.26), "fabric")
    for i in range(15):
        var x: float = -3.92 + float(i) * 0.56
        _box(root, Vector3(x, 2.4, -5.66), Vector3(0.09, 1.93, 0.16),
            Color(0.31, 0.37, 0.34), "wood")
    _box(root, Vector3(0, 3.41, -5.46), Vector3(3.2, 0.59, 0.12),
        Color(0.20, 0.24, 0.22), "wood")
    _text(root, "怀 声 镇 广 播 站", Vector3(0, 3.40, -5.35), 40, Color(0.87, 0.77, 0.55))
    _text(root, "HUAI SHENG / 2003", Vector3(0, 3.12, -5.34), 18, Color(0.55, 0.70, 0.67))
    # A clock, pinned notices and a literal paper trail are stronger than floating 3D labels.
    _box(root, Vector3(-4.90, 2.40, -5.76), Vector3(1.20, 1.20, 0.12),
        Color(0.19, 0.26, 0.25), "wood")
    for i in range(4):
        var y: float = 2.03 + float(i) * 0.24
        _box(root, Vector3(-4.92, y, -5.65), Vector3(0.92, 0.16, 0.012),
            Color(0.77, 0.69, 0.52), "paper")
    _text(root, "内线 21:47", Vector3(-4.90, 2.74, -5.52), 21, Color(0.87, 0.72, 0.48))
    _box(root, Vector3(4.70, 2.43, -5.73), Vector3(1.35, 1.56, 0.10),
        Color(0.25, 0.30, 0.26), "wood")
    _box(root, Vector3(4.70, 2.48, -5.61), Vector3(1.07, 1.32, 0.035),
        Color(0.72, 0.67, 0.51), "paper")
    _text(root, "停 播 通 知\n2003.7.18", Vector3(4.70, 2.48, -5.51), 23,
        Color(0.28, 0.31, 0.29))
    # Physical clock with a face and brass hands, not a large billboard.
    _disk(root, Vector3(3.92, 3.28, -5.60), 0.29, 0.07, Color(0.28, 0.29, 0.26), "wood")
    _disk(root, Vector3(3.92, 3.28, -5.52), 0.23, 0.025, Color(0.83, 0.77, 0.60), "paper")
    _box(root, Vector3(3.95, 3.37, -5.48), Vector3(0.035, 0.17, 0.02),
        Color(0.27, 0.28, 0.25), "steel")
    _box(root, Vector3(3.85, 3.30, -5.47), Vector3(0.13, 0.028, 0.02),
        Color(0.27, 0.28, 0.25), "steel")
    # Window cross-frame and blue night bounce, with blinds casting a plausible pattern.
    _box(root, Vector3(-5.67, 2.48, 1.32), Vector3(0.12, 1.62, 2.60),
        Color(0.19, 0.31, 0.34), "glass")
    for z in [0.15, 1.32, 2.49]:
        _box(root, Vector3(-5.55, 2.48, z), Vector3(0.10, 1.75, 0.07),
            Color(0.35, 0.37, 0.34), "steel")
    for i in range(10):
        _box(root, Vector3(-5.51, 1.78 + float(i) * 0.16, 1.32),
            Vector3(0.09, 0.047, 2.51), Color(0.43, 0.46, 0.42), "steel")
    # Frayed cable trunking and switch plate.
    _box(root, Vector3(5.70, 1.67, -1.3), Vector3(0.12, 0.09, 5.0),
        Color(0.25, 0.30, 0.27), "steel")
    _box(root, Vector3(5.55, 1.5, 2.0), Vector3(0.13, 0.32, 0.27),
        Color(0.58, 0.55, 0.45), "bakelite")
    if haunted:
        _text(root, "21:47 线路仍在占用", Vector3(0, 2.68, -5.48), 27,
            Color(0.89, 0.32, 0.26))
        for i in range(4):
            _box(root, Vector3(-1.7 + i * 1.07, 1.79, -1.88),
                Vector3(0.07, 0.04, 0.025), Color(0.84, 0.22, 0.14), "glass")

static func _control_desk(root: Node3D, haunted: bool) -> void:
    var mahogany := Color(0.40, 0.28, 0.20)
    # Desk front is broken into framed panels, with leg room and glossy worn edges.
    _box(root, Vector3(0, 0.70, -2.76), Vector3(5.45, 1.32, 0.32),
        mahogany, "wood", true)
    _box(root, Vector3(0, 1.36, -2.49), Vector3(5.85, 0.12, 1.47),
        Color(0.52, 0.36, 0.23), "wood", true)
    for x in [-2.18, -0.73, 0.73, 2.18]:
        _box(root, Vector3(x, 0.68, -2.55), Vector3(1.23, 1.0, 0.045),
            Color(0.33, 0.23, 0.17), "wood")
        _box(root, Vector3(x, 0.67, -2.50), Vector3(1.09, 0.88, 0.01),
            Color(0.39, 0.27, 0.19), "wood")
    _box(root, Vector3(0, 1.44, -1.76), Vector3(5.85, 0.055, 0.075),
        Color(0.66, 0.49, 0.31), "wood")
    # An oilcloth blotter, handwritten schedule and paper clips at player-facing edge.
    _box(root, Vector3(-0.40, 1.437, -1.98), Vector3(2.23, 0.009, 0.56),
        Color(0.26, 0.36, 0.32), "fabric")
    for i in range(5):
        _box(root, Vector3(-1.10 + float(i) * 0.29, 1.453, -1.89),
            Vector3(0.20, 0.01, 0.032), Color(0.61, 0.65, 0.58), "steel")
    _box(root, Vector3(-0.52, 1.458, -1.67), Vector3(0.98, 0.015, 0.38),
        Color(0.84, 0.75, 0.56), "paper")
    _text(root, "值班记录", Vector3(-0.51, 1.55, -1.45), 19,
        Color(0.32, 0.35, 0.31))
    # Realistic scale radio mixer with several strips, rails, knobs and faders.
    _box(root, Vector3(0.0, 1.61, -2.55), Vector3(1.85, 0.32, 0.70),
        Color(0.23, 0.26, 0.25), "bakelite")
    _box(root, Vector3(0.0, 1.80, -2.48), Vector3(1.79, 0.018, 0.58),
        Color(0.36, 0.39, 0.37), "steel")
    for i in range(11):
        var x: float = -0.77 + float(i) * 0.154
        _box(root, Vector3(x, 1.82, -2.49), Vector3(0.018, 0.015, 0.40),
            Color(0.18, 0.23, 0.23), "bakelite")
        _box(root, Vector3(x, 1.85, -2.48 + float(i % 4) * 0.055),
            Vector3(0.10, 0.045, 0.065),
            Color(0.77, 0.69, 0.47) if i % 3 == 0 else Color(0.60, 0.66, 0.64), "bakelite")
    # Two amber VU windows along the console.
    for x in [-0.41, 0.41]:
        _box(root, Vector3(x, 1.89, -2.78), Vector3(0.56, 0.055, 0.20),
            Color(0.82, 0.54, 0.27), "glass")
        _box(root, Vector3(x, 1.93, -2.75), Vector3(0.027, 0.008, 0.12),
            Color(0.18, 0.20, 0.18), "steel")
    # Equipment has visible legs and an analogue power board.
    for x in [-2.67, 2.67]:
        _box(root, Vector3(x, 0.44, -2.1), Vector3(0.18, 0.76, 0.62),
            Color(0.24, 0.22, 0.19), "wood")
    for i in range(6):
        _box(root, Vector3(-2.48 + i * 0.16, 1.32, -1.70),
            Vector3(0.075, 0.019, 0.055),
            Color(0.79, 0.42, 0.24) if haunted and i > 3 else Color(0.60, 0.63, 0.53),
            "glass")

static func _equipment(root: Node3D) -> void:
    # Proper CRT silhouette: tapered body, bevel rim, inset cyan monochrome display.
    _box(root, Vector3(-1.92, 1.95, -2.65), Vector3(1.34, 0.94, 0.68),
        Color(0.61, 0.56, 0.43), "bakelite")
    _box(root, Vector3(-1.92, 2.02, -2.28), Vector3(1.14, 0.72, 0.055),
        Color(0.17, 0.21, 0.19), "bakelite")
    _box(root, Vector3(-1.92, 2.02, -2.235), Vector3(1.02, 0.57, 0.016),
        Color(0.07, 0.25, 0.24), "glass")
    for i in range(11):
        _box(root, Vector3(-1.92, 1.77 + float(i) * 0.046, -2.219),
            Vector3(0.94, 0.005, 0.003), Color(0.11, 0.29, 0.27), "glass")
    _text(root, "CH 01\n21:47", Vector3(-1.92, 2.09, -2.185), 21,
        Color(0.51, 0.85, 0.67))
    _box(root, Vector3(-1.92, 1.48, -2.57), Vector3(0.75, 0.12, 0.54),
        Color(0.46, 0.41, 0.34), "bakelite")
    _cylinder(root, Vector3(-1.43, 1.65, -2.23), 0.028, 0.035,
        Color(0.85, 0.52, 0.29), "brass")
    # Reel-to-reel deck with two FACE-ON reels, spindle caps and vertical magnetic tape.
    _box(root, Vector3(1.86, 1.89, -2.70), Vector3(1.46, 1.05, 0.72),
        Color(0.54, 0.54, 0.49), "bakelite")
    _box(root, Vector3(1.86, 1.90, -2.31), Vector3(1.32, 0.86, 0.04),
        Color(0.25, 0.32, 0.30), "steel")
    for x in [1.48, 2.23]:
        _disk(root, Vector3(x, 2.02, -2.255), 0.31, 0.04,
            Color(0.59, 0.62, 0.58), "steel")
        _disk(root, Vector3(x, 2.02, -2.226), 0.23, 0.018,
            Color(0.14, 0.20, 0.20), "bakelite")
        _disk(root, Vector3(x, 2.02, -2.193), 0.071, 0.025,
            Color(0.77, 0.68, 0.46), "brass")
        for i in range(5):
            var angle: float = TAU * float(i) / 5.0
            _disk(root, Vector3(x + cos(angle) * 0.17, 2.02 + sin(angle) * 0.17, -2.194),
                0.029, 0.013, Color(0.24, 0.28, 0.27), "steel")
    _box(root, Vector3(1.86, 1.63, -2.18), Vector3(0.72, 0.15, 0.07),
        Color(0.21, 0.23, 0.22), "bakelite")
    for i in range(5):
        _box(root, Vector3(1.57 + float(i) * 0.145, 1.61, -2.12),
            Vector3(0.09, 0.065, 0.025),
            Color(0.77, 0.59, 0.37) if i == 2 else Color(0.70, 0.72, 0.67), "bakelite")
    # Full-height side rack: cassette binders, analogue meters, original paper labels.
    _box(root, Vector3(4.52, 1.23, -3.25), Vector3(1.28, 2.46, 1.07),
        Color(0.33, 0.34, 0.31), "steel")
    for i in range(4):
        var y: float = 0.45 + float(i) * 0.49
        _box(root, Vector3(4.52, y, -2.69), Vector3(1.10, 0.05, 0.08),
            Color(0.71, 0.66, 0.50), "steel")
        for k in range(6):
            var x: float = 4.07 + float(k) * 0.17
            _box(root, Vector3(x, y + 0.21, -2.72), Vector3(0.13, 0.38, 0.11),
                Color(0.49 + 0.025 * float((i + k) % 4), 0.42, 0.32), "bakelite")
    _text(root, "原始磁带 / 2003", Vector3(4.51, 2.67, -2.61), 19,
        Color(0.78, 0.70, 0.53))

static func _filing_corner(root: Node3D) -> void:
    # Desk fan, phone handset and file stacks create life beyond the hero console.
    _box(root, Vector3(-4.48, 0.92, -3.16), Vector3(1.45, 1.84, 0.90),
        Color(0.43, 0.46, 0.42), "steel")
    for i in range(3):
        var y: float = 0.40 + float(i) * 0.56
        _box(root, Vector3(-4.46, y, -2.67), Vector3(1.24, 0.46, 0.03),
            Color(0.49, 0.52, 0.48), "steel")
        _box(root, Vector3(-4.46, y + 0.04, -2.62), Vector3(0.36, 0.045, 0.03),
            Color(0.78, 0.70, 0.54), "steel")
    # Standing lamp, newspaper and cigarette tin near the window, not in walking path.
    _box(root, Vector3(-4.55, 0.78, 1.65), Vector3(1.60, 1.52, 0.84),
        Color(0.36, 0.27, 0.20), "wood")
    _box(root, Vector3(-4.55, 1.60, 1.65), Vector3(1.80, 0.075, 0.92),
        Color(0.53, 0.37, 0.23), "wood")
    for i in range(4):
        _box(root, Vector3(-5.12 + float(i) * 0.33, 1.66, 1.53),
            Vector3(0.27, 0.045, 0.52),
            Color(0.76 - i * 0.04, 0.69 - i * 0.03, 0.53 - i * 0.02), "paper")
    _box(root, Vector3(-4.25, 1.68, 1.95), Vector3(0.37, 0.13, 0.24),
        Color(0.38, 0.43, 0.40), "steel")
    # Operator chair behind console; player cannot walk into it.
    _box(root, Vector3(2.60, 0.80, -4.02), Vector3(0.67, 0.17, 0.69),
        Color(0.26, 0.30, 0.29), "fabric")
    _box(root, Vector3(2.60, 1.27, -4.38), Vector3(0.70, 1.1, 0.14),
        Color(0.25, 0.29, 0.28), "fabric")
    _cylinder(root, Vector3(2.60, 0.37, -4.02), 0.08, 0.73,
        Color(0.30, 0.34, 0.32), "steel")

static func _lighting(root: Node3D, haunted: bool) -> void:
    # Cool broken fluorescent tube in front, warm practical lamp above the tape.
    for x in [-2.0, 2.2]:
        _box(root, Vector3(x, 3.66, -0.82), Vector3(2.20, 0.14, 0.34),
            Color(0.33, 0.37, 0.35), "steel")
        _box(root, Vector3(x, 3.56, -0.82), Vector3(1.92, 0.053, 0.21),
            Color(0.80, 0.88, 0.76), "glass")
    _light(root, Vector3(-1.8, 3.48, -0.98),
        Color(0.72, 0.88, 0.85), 1.9, 8.2, true)
    _light(root, Vector3(2.3, 2.98, -2.24),
        Color(0.96, 0.64, 0.39) if not haunted else Color(0.86, 0.26, 0.23),
        1.85, 6.7, true)
    _box(root, Vector3(2.40, 3.50, -2.38), Vector3(0.53, 0.15, 0.52),
        Color(0.36, 0.29, 0.23), "brass")
    _box(root, Vector3(2.40, 3.40, -2.38), Vector3(0.39, 0.09, 0.37),
        Color(0.88, 0.67, 0.40), "glass")
    _light(root, Vector3(-4.42, 2.52, 1.38),
        Color(0.37, 0.61, 0.69), 0.93, 7.2, false)
    if haunted:
        _light(root, Vector3(0.0, 2.27, -3.1), Color(0.76, 0.15, 0.14), 0.85, 4.6, false)

static func _box(root: Node3D, at: Vector3, dimensions: Vector3,
    tint: Color, finish: String, solid: bool = false) -> void:
    var node := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    node.mesh = mesh
    node.material_override = Finish.get_finish(finish, tint)
    node.position = at
    root.add_child(node)
    if solid:
        var body := StaticBody3D.new()
        body.collision_layer = 1
        body.collision_mask = 0
        body.position = at
        var shape := CollisionShape3D.new()
        var box := BoxShape3D.new()
        box.size = dimensions
        shape.shape = box
        body.add_child(shape)
        root.add_child(body)

static func _cylinder(root: Node3D, at: Vector3, radius: float,
    height: float, tint: Color, finish: String) -> void:
    var node := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    node.mesh = mesh
    node.material_override = Finish.get_finish(finish, tint)
    node.position = at
    root.add_child(node)

static func _disk(root: Node3D, at: Vector3, radius: float,
    thickness: float, tint: Color, finish: String) -> void:
    var node := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = thickness
    node.mesh = mesh
    node.rotation.x = PI * 0.5
    node.position = at
    node.material_override = Finish.get_finish(finish, tint)
    root.add_child(node)

static func _sphere(root: Node3D, at: Vector3, radius: float,
    tint: Color, finish: String) -> void:
    var node := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 2.0
    node.mesh = mesh
    node.position = at
    node.material_override = Finish.get_finish(finish, tint)
    root.add_child(node)

static func _text(root: Node3D, content: String, at: Vector3,
    font_size: int, color: Color) -> void:
    var text_node := Label3D.new()
    text_node.text = content
    text_node.position = at
    text_node.font_size = font_size
    text_node.pixel_size = 0.004
    text_node.modulate = color
    text_node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    text_node.outline_size = 2
    root.add_child(text_node)

static func _light(root: Node3D, at: Vector3, tint: Color,
    energy: float, reach: float, cast_shadows: bool) -> void:
    var lamp := OmniLight3D.new()
    lamp.position = at
    lamp.light_color = tint
    lamp.light_energy = energy
    lamp.omni_range = reach
    lamp.shadow_enabled = cast_shadows
    root.add_child(lamp)
