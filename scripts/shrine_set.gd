extends RefCounted
## Physical investigation props replace the legacy floating labels and glowing cubes.
## Original modular transitional geometry; shared finishes, no external assets.
const Geometry = preload("res://scripts/town_set.gd")
const Landmarks = preload("res://scripts/landmarks.gd")
const WOOD := Color(0.30, 0.21, 0.16)
const PAPER := Color(0.72, 0.64, 0.46)

static func build(scene: Node3D, haunted: bool) -> void:
    var root := Node3D.new()
    root.name = "ShrineSet"
    scene.add_child(root)
    _box(root, Vector3(0, -0.23, 0), Vector3(12, 0.46, 12), Color(0.33, 0.34, 0.30), "concrete", true)
    for row in range(12):
        for col in range(12):
            _box(root, Vector3(-5.5 + col, 0.012, -5.5 + row), Vector3(0.97, 0.02, 0.97),
                Color(0.37, 0.38, 0.32) if (row + col) % 3 == 0 else Color(0.29, 0.31, 0.28), "concrete")
    for side in [-1.0, 1.0]:
        _box(root, Vector3(0, 1.9, side * 6), Vector3(12, 3.8, 0.32), Color(0.46, 0.44, 0.36), "plaster", true)
        _box(root, Vector3(side * 6, 1.9, 0), Vector3(0.32, 3.8, 12), Color(0.46, 0.44, 0.36), "plaster", true)
        _box(root, Vector3(0, 0.3, side * 5.8), Vector3(11.7, 0.6, 0.10), WOOD, "wood")
        _box(root, Vector3(side * 5.8, 0.3, 0), Vector3(0.1, 0.6, 11.7), WOOD, "wood")
        for z in [-2.5, 2.5]:
            _box(root, Vector3(side * 4.4, 1.8, z), Vector3(0.34, 3.6, 0.34), WOOD, "wood", true)
        _box(root, Vector3(side * 5.1, 0.45, -0.4), Vector3(0.55, 0.9, 2.8), WOOD, "wood", true)
    _box(root, Vector3(0, 3.8, 0), Vector3(12, 0.18, 12), Color(0.24, 0.22, 0.18), "wood")
    for z in [-4.7, -2.5, 0, 2.5, 4.7]:
        _box(root, Vector3(0, 3.58, z), Vector3(11.7, 0.26, 0.22), WOOD, "wood")
    _door(root)
    _altar(root)
    _reading_desk(root)
    # High lattice window; the cool spill and warm candle light stay local.
    _box(root, Vector3(-5.78, 2.55, -0.3), Vector3(0.06, 1.4, 2.2), Color(0.12, 0.23, 0.25), "glass")
    for z in [-1.3, -0.8, -0.3, 0.2, 0.7]:
        _box(root, Vector3(-5.70, 2.55, z), Vector3(0.07, 1.5, 0.05), WOOD, "wood")
    for y in [1.82, 2.3, 2.78, 3.28]:
        _box(root, Vector3(-5.69, y, -0.3), Vector3(0.07, 0.05, 2.16), WOOD, "wood")
    Geometry._light(root, Vector3(-5.0, 2.55, -0.3), Color(0.42, 0.59, 0.65), 1.2, 7.0, false)
    Geometry._light(root, Vector3(0, 2.9, -3.5), Color(1.0, 0.66, 0.35), 1.15 if haunted else 1.4, 8.0, true)
    Geometry._light(root, Vector3(0, 2.9, 3.4), Color(0.59, 0.64, 0.62), 0.55, 7.0, false)

static func _door(root: Node3D) -> void:
    _box(root, Vector3(0, 1.2, 5.74), Vector3(2.0, 2.4, 0.12), WOOD, "wood")
    for x in [-1.08, 0, 1.08]:
        _box(root, Vector3(x, 1.25, 5.63), Vector3(0.09, 2.5, 0.14), Color(0.46, 0.33, 0.22), "wood")
    _box(root, Vector3(0, 2.53, 5.63), Vector3(2.3, 0.13, 0.14), WOOD, "wood")
    for x in [-0.15, 0.15]:
        _box(root, Vector3(x, 1.12, 5.56), Vector3(0.055, 0.16, 0.055), PAPER, "brass")
    _box(root, Vector3(0, 2.9, 5.72), Vector3(1.85, 0.38, 0.08), WOOD, "wood")
    _text(root, "返 回 街 道", Vector3(0, 2.9, 5.65), 26, PAPER, Vector3(0, PI, 0))

static func _altar(root: Node3D) -> void:
    _box(root, Vector3(0, 0.63, -4.35), Vector3(4.5, 1.26, 1.2), WOOD, "wood", true)
    _box(root, Vector3(0, 1.25, -4.35), Vector3(4.65, 0.12, 1.35), Color(0.39, 0.26, 0.17), "wood")
    for x in [-1.1, 0, 1.1]:
        _box(root, Vector3(x, 1.32, -4.1), Vector3(0.63, 0.12, 0.39), Color(0.19, 0.16, 0.13), "wood")
        _box(root, Vector3(x, 1.88, -4.02), Vector3(0.47, 1.05, 0.19), Color(0.19, 0.15, 0.12), "wood")
        _box(root, Vector3(x, 2.43, -4.02), Vector3(0.52, 0.09, 0.22), Color(0.33, 0.26, 0.17), "wood")
        # The middle tablet is deliberately blank, matching the evidence text.
        if x != 0:
            _text(root, "先\n祖", Vector3(x, 1.9, -3.91), 32, PAPER)
    for x in [-1.85, 1.85]:
        Geometry._cylinder(root, Vector3(x, 1.32, -3.92), 0.12, 0.07, PAPER, "brass")
        Geometry._cylinder(root, Vector3(x, 1.53, -3.92), 0.045, 0.38, Color(0.65, 0.23, 0.14), "paper")
        Geometry._cylinder(root, Vector3(x, 1.74, -3.92), 0.016, 0.06, Color(1.0, 0.72, 0.25), "glass")
    Geometry._cylinder(root, Vector3(0, 1.39, -3.84), 0.24, 0.18, Color(0.35, 0.29, 0.19), "brass")
    for x in [-0.08, 0, 0.08]:
        Geometry._cylinder(root, Vector3(x, 1.67, -3.84), 0.008, 0.4, Color(0.54, 0.36, 0.21), "wood")
    _box(root, Vector3(0, 3.0, -5.7), Vector3(3.0, 0.55, 0.12), WOOD, "wood")
    _text(root, "慎 终 追 远", Vector3(0, 3.0, -5.62), 36, PAPER)

static func _reading_desk(root: Node3D) -> void:
    var paper: Vector3 = Landmarks.SHRINE_RITUAL
    _box(root, Vector3(paper.x, 1.17, -2.45), Vector3(1.5, 0.12, 0.95), WOOD, "wood", true)
    for x in [-0.58, 0.58]:
        for z in [-2.79, -2.11]:
            _box(root, Vector3(paper.x + x, 0.55, z), Vector3(0.10, 1.1, 0.10), WOOD, "wood", true)
    _box(root, paper + Vector3(0, -0.012, -0.10), Vector3(0.66, 0.014, 0.49), PAPER, "paper")
    _text(root, "封 声\n残 页", paper + Vector3(0, 0.002, -0.10), 20,
        Color(0.25, 0.26, 0.22), Vector3(-PI * 0.5, 0, 0))

static func _box(root: Node3D, at: Vector3, size: Vector3, tint: Color, finish: String, solid: bool = false) -> void:
    Geometry._box(root, at, size, tint, finish, solid)

static func _text(root: Node3D, content: String, at: Vector3, font_size: int, tint: Color, rotation: Vector3 = Vector3.ZERO) -> void:
    var label := Label3D.new()
    label.text = content
    label.position = at
    label.rotation = rotation
    label.font_size = font_size
    label.pixel_size = 0.004
    label.modulate = tint
    label.outline_size = 0
    root.add_child(label)
