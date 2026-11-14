extends RefCounted
## Original 2003 corner shop. Modular transitional geometry, no borrowed brands/assets.
const Finish = preload("res://scripts/radio_finishes.gd")
const Landmarks = preload("res://scripts/landmarks.gd")
const Geometry = preload("res://scripts/town_set.gd")
const GREEN := Color(0.28, 0.40, 0.35)
const WOOD := Color(0.44, 0.32, 0.23)
const PAPER := Color(0.79, 0.72, 0.55)

static func build(scene: Node3D, haunted: bool) -> void:
    var root := Node3D.new()
    root.name = "ShopSet"
    scene.add_child(root)
    _room(root)
    _counter(root)
    _stock(root)
    _wall_story(root)
    _lighting(root, haunted)

static func _room(root: Node3D) -> void:
    _box(root, Vector3(0, -0.23, 0), Vector3(12, 0.46, 12),
        Color(0.40, 0.41, 0.34), "concrete", true)
    # Modest, worn cream/green floor, with the clear central aisle left open.
    for row in range(12):
        for col in range(12):
            var shade: Color = Color(0.54, 0.52, 0.41) if (row + col) % 2 == 0 else Color(0.38, 0.43, 0.36)
            _box(root, Vector3(-5.5 + col, 0.012, -5.5 + row),
                Vector3(0.97, 0.024, 0.97), shade, "concrete")
    for z in [-6.0, 6.0]:
        _box(root, Vector3(0, 1.7, z), Vector3(12, 3.4, 0.32),
            Color(0.64, 0.61, 0.48), "plaster", true)
        _box(root, Vector3(0, 0.58, z * 0.963), Vector3(11.7, 1.16, 0.08), GREEN, "plaster")
        _box(root, Vector3(0, 1.19, z * 0.96), Vector3(11.7, 0.06, 0.12), WOOD, "wood")
    for x in [-6.0, 6.0]:
        _box(root, Vector3(x, 1.7, 0), Vector3(0.32, 3.4, 12),
            Color(0.64, 0.61, 0.48), "plaster", true)
        _box(root, Vector3(x * 0.963, 0.58, 0), Vector3(0.08, 1.16, 11.7), GREEN, "plaster")
        _box(root, Vector3(x * 0.96, 1.19, 0), Vector3(0.12, 0.06, 11.7), WOOD, "wood")
    _box(root, Vector3(0, 3.43, 0), Vector3(12, 0.20, 12),
        Color(0.47, 0.48, 0.39), "plaster")
    for z in [-3.5, 0.0, 3.5]:
        _box(root, Vector3(0, 3.28, z), Vector3(11.6, 0.13, 0.17), WOOD, "wood")
    # Door slab, frame and a readable interior exit sign share the real hotspot.
    var door: Vector3 = Landmarks.SHOP_EXIT
    _box(root, Vector3(door.x, 1.12, 5.72), Vector3(1.70, 2.24, 0.10), GREEN, "wood")
    for x in [-0.91, 0.91]:
        _box(root, Vector3(x, 1.18, 5.62), Vector3(0.12, 2.38, 0.16), WOOD, "wood")
    _box(root, Vector3(0, 2.37, 5.62), Vector3(1.94, 0.13, 0.16), WOOD, "wood")
    _box(root, Vector3(0.58, 1.08, 5.59), Vector3(0.08, 0.19, 0.045), PAPER, "brass")
    _text(root, "返 回 街 道", Vector3(0, 2.65, 5.57), 23, PAPER, PI)
    # Two street windows with metal framing and blue dusk spill.
    for z in [-0.6, 2.0]:
        _box(root, Vector3(-5.74, 2.10, z), Vector3(0.09, 1.47, 1.90),
            Color(0.17, 0.31, 0.32), "glass")
        for dz in [-0.97, 0.0, 0.97]:
            _box(root, Vector3(-5.64, 2.10, z + dz), Vector3(0.10, 1.58, 0.065), WOOD, "wood")
        for y in [1.31, 2.10, 2.89]:
            _box(root, Vector3(-5.64, y, z), Vector3(0.12, 0.065, 2.0), WOOD, "wood")

static func _counter(root: Node3D) -> void:
    _box(root, Vector3(-1.9, 0.54, -2.36), Vector3(3.40, 1.08, 1.30), WOOD, "wood", true)
    _box(root, Vector3(-1.9, 1.10, -2.30), Vector3(3.52, 0.10, 1.52),
        Color(0.59, 0.55, 0.40), "wood")
    # Glazed display front, inset mullions, drawers and a scuffed brass footrail.
    for x in [-3.0, -1.9, -0.8]:
        _box(root, Vector3(x, 0.65, -1.69), Vector3(0.96, 0.56, 0.025),
            Color(0.19, 0.28, 0.26), "glass")
        _box(root, Vector3(x, 0.29, -1.66), Vector3(1.0, 0.055, 0.05), PAPER, "wood")
    _box(root, Vector3(-1.9, 0.16, -1.44), Vector3(3.1, 0.055, 0.055), PAPER, "brass")
    # The actual open ledger is at the investigation point, on the near countertop.
    var ledger := Node3D.new()
    ledger.name = "OpenLedger"
    ledger.position = Landmarks.SHOP_LEDGER
    root.add_child(ledger)
    _box(ledger, Vector3(0, -0.015, 0), Vector3(0.61, 0.045, 0.40),
        Color(0.31, 0.25, 0.18), "wood")
    _box(ledger, Vector3(0, 0.014, 0), Vector3(0.56, 0.014, 0.36), PAPER, "paper")
    _box(ledger, Vector3(0, 0.027, 0), Vector3(0.012, 0.006, 0.35), WOOD, "paper")
    for row in range(6):
        _box(ledger, Vector3(0.03, 0.027, -0.13 + row * 0.048),
            Vector3(0.46, 0.005, 0.006), Color(0.39, 0.43, 0.37), "paper")
    _text(root, "七 月\n赊账簿", Landmarks.SHOP_LEDGER + Vector3(0, 0.002, 0), 16,
        Color(0.29, 0.27, 0.22), 0.0, -PI * 0.5)
    # Mechanical scale, enamel cup, cash drawer and a modest tabletop radio.
    _box(root, Vector3(-2.95, 1.28, -2.42), Vector3(0.52, 0.27, 0.46), GREEN, "steel")
    Geometry._cylinder(root, Vector3(-2.95, 1.45, -2.42), 0.30, 0.055, PAPER, "steel")
    Geometry._cylinder(root, Vector3(-0.67, 1.31, -2.44), 0.12, 0.30, PAPER, "steel")
    _box(root, Vector3(-1.55, 1.36, -2.73), Vector3(0.64, 0.40, 0.21),
        Color(0.38, 0.28, 0.20), "wood")
    for i in range(6):
        _box(root, Vector3(-1.76 + i * 0.065, 1.35, -2.61), Vector3(0.025, 0.25, 0.012),
            Color(0.18, 0.20, 0.17), "steel")

static func _stock(root: Node3D) -> void:
    # Low back-wall shelving; bins and products have distinct recognisable silhouettes.
    for section in range(3):
        var cx: float = -1.75 + section * 2.12
        for side in [-0.94, 0.94]:
            _box(root, Vector3(cx + side, 1.27, -5.10), Vector3(0.065, 2.54, 0.72),
                GREEN, "steel")
        _box(root, Vector3(cx, 1.25, -5.46), Vector3(1.95, 2.45, 0.065), WOOD, "wood")
        var shelf := StaticBody3D.new()
        shelf.collision_layer = 1
        shelf.collision_mask = 0
        var collision := CollisionShape3D.new()
        var volume := BoxShape3D.new()
        volume.size = Vector3(1.95, 2.45, 0.77)
        collision.shape = volume
        shelf.position = Vector3(cx, 1.25, -5.10)
        shelf.add_child(collision)
        root.add_child(shelf)
        for row in range(3):
            var y: float = 0.36 + row * 0.72
            _box(root, Vector3(cx, y, -5.10), Vector3(1.95, 0.065, 0.77), PAPER, "wood")
            for i in range(5):
                var x: float = cx - 0.72 + i * 0.36
                if row == 0:
                    _bottle(root, Vector3(x, y + 0.19, -4.98), i + section)
                else:
                    var tint: Color = Color(0.57, 0.32, 0.22) if (i + row + section) % 2 == 0 else Color(0.62, 0.57, 0.36)
                    _box(root, Vector3(x, y + 0.24, -4.98), Vector3(0.25, 0.40, 0.20), tint, "paper")
                    _box(root, Vector3(x, y + 0.23, -4.87), Vector3(0.18, 0.11, 0.012), PAPER, "paper")
            _text(root, "汽水 五角" if row == 0 else ("饼干 / 糖果" if row == 1 else "日用百货"),
                Vector3(cx, y - 0.07, -4.69), 15, PAPER)
    # Short side rack, fridge, crates: no central aisle obstruction.
    _box(root, Vector3(4.80, 1.05, -1.80), Vector3(1.20, 2.10, 0.95),
        Color(0.53, 0.61, 0.53), "steel", true)
    _box(root, Vector3(4.80, 1.18, -1.30), Vector3(1.02, 1.58, 0.035),
        Color(0.17, 0.30, 0.28), "glass")
    for y in [0.55, 1.05, 1.55]:
        _box(root, Vector3(4.80, y, -1.26), Vector3(1.0, 0.04, 0.025), PAPER, "steel")
        for i in range(3):
            _bottle(root, Vector3(4.48 + i * 0.30, y + 0.16, -1.20), i)
    _text(root, "冰 汽 水", Vector3(4.80, 2.34, -1.18), 23, PAPER)
    for i in range(3):
        _box(root, Vector3(4.7, 0.29 + i * 0.56, 1.50), Vector3(1.02, 0.53, 0.83), WOOD, "wood", true)
        for j in range(4):
            _box(root, Vector3(4.30 + j * 0.26, 0.30 + i * 0.56, 1.94),
                Vector3(0.17, 0.36, 0.025), PAPER, "wood")
    # Cardboard cartons are placed along the wall, away from entry and witness.
    for i in range(3):
        _box(root, Vector3(2.6 + i * 0.75, 0.35, 4.7), Vector3(0.67, 0.70, 0.63),
            Color(0.58, 0.47, 0.31), "paper", true)

static func _bottle(root: Node3D, at: Vector3, variant: int) -> void:
    var shade: Color = Color(0.24, 0.43, 0.30) if variant % 2 == 0 else Color(0.55, 0.37, 0.20)
    Geometry._cylinder(root, at, 0.085, 0.27, shade, "glass")
    Geometry._cylinder(root, at + Vector3(0, 0.18, 0), 0.038, 0.12, shade, "glass")
    Geometry._cylinder(root, at + Vector3(0, 0.25, 0), 0.044, 0.035, PAPER, "steel")

static func _wall_story(root: Node3D) -> void:
    var at: Vector3 = Landmarks.SHOP_CALENDAR
    _box(root, at + Vector3(0, 0, -0.09), Vector3(0.92, 1.20, 0.09), WOOD, "wood")
    _box(root, at + Vector3(0, 0, -0.025), Vector3(0.81, 1.08, 0.025), PAPER, "paper")
    _text(root, "2003 年\n七 月\n17", at + Vector3(0, 0.04, 0.01), 24,
        Color(0.46, 0.25, 0.18))
    _box(root, Vector3(-1.7, 2.79, -5.61), Vector3(4.5, 0.58, 0.07), GREEN, "wood")
    _text(root, "吉 祥 小 卖 部", Vector3(-1.7, 2.79, -5.54), 32, PAPER)
    _box(root, Vector3(-0.4, 0.74, -1.63), Vector3(0.38, 0.48, 0.025), PAPER, "paper")
    _text(root, "请 勿\n赊 账", Vector3(-0.4, 0.74, -1.60), 16, WOOD)
    # A circular clock faces the aisle, hands frozen at 21:47, no floating time label.
    Geometry._disk(root, Vector3(1.4, 2.80, -5.60), 0.26, 0.08, WOOD, "wood")
    Geometry._disk(root, Vector3(1.4, 2.80, -5.54), 0.22, 0.025, PAPER, "paper")
    Geometry._beam(root, Vector3(1.4, 2.80, -5.51), Vector3(1.22, 2.84, -5.51), 0.012, WOOD, "steel")
    Geometry._beam(root, Vector3(1.4, 2.80, -5.51), Vector3(1.30, 2.844, -5.51), 0.016, WOOD, "steel")

static func _lighting(root: Node3D, haunted: bool) -> void:
    # Fluorescent fill, warm counter practical, and the cool street stay distinct.
    for x in [-1.8, 2.4]:
        _box(root, Vector3(x, 3.24, -1.3), Vector3(0.22, 0.07, 1.65), PAPER, "steel")
        _light(root, Vector3(x, 2.98, -1.3), Color(0.82, 0.91, 0.77),
            1.15 if not haunted else 0.92, 7.2)
    _light(root, Vector3(-2.4, 2.6, -0.5), Color(1.0, 0.78, 0.48), 1.25, 5.5)
    _light(root, Vector3(-5.0, 2.2, 1.0), Color(0.45, 0.66, 0.72), 0.90, 5.3)

static func _box(root: Node3D, at: Vector3, size: Vector3, tint: Color,
    surface: String, solid: bool = false) -> void:
    Geometry._box(root, at, size, tint, surface, solid)

static func _text(root: Node3D, text: String, at: Vector3, size: int, tint: Color,
    yaw: float = 0.0, pitch: float = 0.0) -> void:
    var label := Label3D.new()
    label.text = text
    label.position = at
    label.rotation.y = yaw
    label.rotation.x = pitch
    label.font_size = size
    label.pixel_size = 0.005
    label.modulate = tint
    label.outline_size = 1
    root.add_child(label)

static func _light(root: Node3D, at: Vector3, color: Color, energy: float, reach: float) -> void:
    Geometry._light(root, at, color, energy, reach, false)
