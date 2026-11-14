extends RefCounted
## Port of PR #7's classroom using the current shared physical-prop/finish contract.
## Original transitional geometry; not final photorealistic art.
const Geometry = preload("res://scripts/town_set.gd")
const Landmarks = preload("res://scripts/landmarks.gd")
const WOOD := Color(0.38, 0.29, 0.20)
const PAPER := Color(0.78, 0.71, 0.54)

static func build(scene: Node3D, haunted: bool) -> void:
    var root := Node3D.new()
    root.name = "SchoolSet"
    scene.add_child(root)
    Geometry._box(root, Vector3(0, -0.23, 0), Vector3(12, 0.46, 12), Color(0.46, 0.43, 0.35), "concrete", true)
    for side in [-1.0, 1.0]:
        Geometry._box(root, Vector3(0, 2.1, side * 6), Vector3(12, 4.2, 0.32), Color(0.64, 0.62, 0.50), "plaster", true)
        Geometry._box(root, Vector3(side * 6, 2.1, 0), Vector3(0.32, 4.2, 12), Color(0.64, 0.62, 0.50), "plaster", true)
    Geometry._box(root, Vector3(0, 4.25, 0), Vector3(12, 0.2, 12), Color(0.43, 0.43, 0.37), "plaster")
    Geometry._box(root, Vector3(0, 2.4, -5.76), Vector3(6.5, 1.8, 0.08), Color(0.16, 0.27, 0.23), "wood")
    Geometry._text(root, "怀声镇小学 / 暑期播音训练", Vector3(0, 3.65, -5.64), 28, PAPER, true)
    Geometry._text(root, "最后一节课 20:30", Vector3(0, 2.65, -5.69), 27, PAPER, true)
    if haunted:
        Geometry._text(root, "请 勿 跟 读", Vector3(0, 2.1, -5.68), 26, Color(0.77, 0.56, 0.45), true)
    # Leave the middle aisle and the teacher's roll-book approach unobstructed.
    for z in [-1.6, 0.8, 3.0]:
        for x in [-2.8, 2.8]:
            _desk(root, Vector3(x, 0, z))
    Geometry._box(root, Vector3(-3.5, 0.50, -3.85), Vector3(2.2, 1.0, 0.9), WOOD, "wood", true)
    _book(root, "RollBook", Landmarks.SCHOOL_REGISTER, "校务交接簿\n20:43 离校")
    _book(root, "PracticeBook", Landmarks.SCHOOL_NOTEBOOK, "林小禾的练声簿")
    Geometry._box(root, Vector3(0, 1.2, 5.75), Vector3(1.95, 2.4, 0.10), WOOD, "wood")
    Geometry._text(root, "返回街道", Vector3(0, 2.7, 5.65), 27, PAPER, true, PI)
    for z in [-3.0, 0.0, 3.0]:
        Geometry._box(root, Vector3(-5.78, 2.5, z), Vector3(0.08, 1.25, 1.5), Color(0.19, 0.30, 0.30), "glass")
        Geometry._box(root, Vector3(-5.70, 2.5, z), Vector3(0.07, 1.4, 0.06), WOOD, "wood")
    Geometry._light(root, Vector3(-4.8, 2.7, 0), Color(0.57, 0.67, 0.65), 1.1, 10, false)
    Geometry._light(root, Vector3(0, 3.9, -2.5), Color(0.95, 0.85, 0.65), 1.3, 9, false)

static func _desk(root: Node3D, at: Vector3) -> void:
    Geometry._box(root, at + Vector3(0, 0.78, 0), Vector3(1.35, 0.10, 0.85), WOOD, "wood", true)
    for dx in [-0.52, 0.52]:
        Geometry._box(root, at + Vector3(dx, 0.38, 0), Vector3(0.10, 0.76, 0.64), WOOD, "wood", true)
    Geometry._box(root, at + Vector3(0, 0.44, 0.9), Vector3(1.0, 0.10, 0.40), WOOD, "wood", true)

static func _book(root: Node3D, node_name: String, at: Vector3, title: String) -> void:
    var book := Node3D.new()
    book.name = node_name
    root.add_child(book)
    Geometry._box(book, at + Vector3(0, -0.03, -0.12), Vector3(0.70, 0.06, 0.50), PAPER, "paper")
    # Small upright title attached to a wooden reading stand, not a billboard.
    Geometry._box(book, at + Vector3(0, 0.20, -0.28), Vector3(0.85, 0.38, 0.06), WOOD, "wood")
    Geometry._text(book, title, at + Vector3(0, 0.20, -0.24), 18, PAPER, true)
