extends Node3D
const Characters = preload("res://scripts/characters.gd")
const RadioSet = preload("res://scripts/radio_set.gd")
const ShopSet = preload("res://scripts/shop_set.gd")
const ShrineSet = preload("res://scripts/shrine_set.gd")
const TownSet = preload("res://scripts/town_set.gd")
const Landmarks = preload("res://scripts/landmarks.gd")
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

func _spot(id: String, name: String, pos: Vector3, body: CollisionObject3D = null) -> void:
    var entry := {"id": id, "name": name, "position": pos}
    if body != null:
        entry["target_rid"] = body.get_rid()
    hotspots.append(entry)

func _building(pos: Vector3, size: Vector3, wall: Color, roof: Color) -> void:
    _box(pos, size, wall, true, false, "plaster")
    _box(pos + Vector3(0, size.y * 0.5 + 0.15, 0), Vector3(size.x + 0.7, 0.30, size.z + 0.7), roof, false, false, "tile")
    # Modular street-facing windows. Old code placed these inside building solids.
    var near_street_x: float = pos.x + (size.x * 0.5 + 0.07) * (1.0 if pos.x < 0.0 else -1.0)
    var levels: int = maxi(1, int(size.y / 3.1))
    for floor_index in range(levels):
        var y: float = 1.75 + float(floor_index) * 2.65
        if y + 0.8 > size.y:
            continue
        for i in range(2):
            var offset: float = -size.z * 0.24 + float(i) * size.z * 0.48
            var z: float = pos.z + offset
            _box(Vector3(near_street_x, y, z), Vector3(0.08, 1.3, 1.25),
                Color(0.23, 0.31, 0.33), false, false, "metal")
            _box(Vector3(near_street_x + 0.02, y, z), Vector3(0.10, 1.36, 0.075),
                Color(0.69, 0.64, 0.50), false, false, "wood")
            _box(Vector3(near_street_x + 0.02, y, z - 0.64), Vector3(0.10, 1.36, 0.075),
                Color(0.69, 0.64, 0.50), false, false, "wood")
            _box(Vector3(near_street_x + 0.09, y - 0.73, z),
                Vector3(0.32, 0.10, 1.50), Color(0.55, 0.51, 0.42), false, false, "concrete")
            if floor_index > 0:
                _box(Vector3(near_street_x + 0.12, y - 0.85, z),
                    Vector3(0.25, 0.12, 1.85), Color(0.50, 0.46, 0.38), false, false, "concrete")
    # A few restrained facade bands break up single-block silhouettes.
    if absf(pos.x) > 1.0:
        _box(Vector3(near_street_x, size.y * 0.5, pos.z),
            Vector3(0.12, 0.10, size.z * 0.92), Color(0.55, 0.48, 0.40), false, false, "concrete")

func _lamp_post(pos: Vector3) -> void:
    _cylinder(pos + Vector3(0, 2.05, 0), 0.065, 4.1, Color(0.22, 0.25, 0.23))
    _box(pos + Vector3(0.0, 4.1, 0), Vector3(0.5, 0.13, 0.5), Color(0.68, 0.62, 0.48))
    _box(pos + Vector3(0.0, 3.93, 0), Vector3(0.28, 0.24, 0.28), Color(1.0, 0.74, 0.37), false, true)
    _light(pos + Vector3(0, 3.8, 0), Color(1.0, 0.72, 0.43), 1.5, 11.0)

func _build_street() -> void:
    # Main street now has an independently art-directed world-space set.
    TownSet.build(self, haunted)
    # Saves use IDs, not positions. Keep targets on their visible object surfaces.
    _spot("poster", "查看寻人启事", Landmarks.STREET_POSTER)
    _spot("public_phone", "查看公用电话", Landmarks.PUBLIC_PHONE)
    _spot("enter_shop", "进入小卖部", Landmarks.SHOP_DOOR)
    _spot("enter_radio", "进入广播站", Landmarks.RADIO_DOOR)
    _spot("enter_shrine", "进入祠堂", Landmarks.SHRINE_DOOR)

func _build_shop() -> void:
    ShopSet.build(self, haunted)
    _spot("exit", "返回街道", Landmarks.SHOP_EXIT)
    _spot("ledger", "翻阅旧账本", Landmarks.SHOP_LEDGER)
    _spot("calendar", "查看墙上旧日历", Landmarks.SHOP_CALENDAR)
    var witness: Node3D = Characters.build(self, "npc_shop", Landmarks.SHOP_WITNESS)
    _spot("npc_shop", "询问吴婶", Landmarks.SHOP_WITNESS + Vector3(0, 1.42, 0), witness.get_node("Body"))

func _build_radio() -> void:
    # One complete art-directed slice; no legacy greybox boxes underneath it.
    RadioSet.build(self, haunted)
    # Stable hotspot IDs preserve quest logic, dialogue and existing save files.
    _spot("exit", "返回街道", Landmarks.RADIO_EXIT)
    _spot("log", "阅读值班日志", Landmarks.RADIO_LOG)
    _spot("tape", "播放旧录音", Landmarks.RADIO_TAPE)
    _spot("broadcast_notice", "查看停播通知", Landmarks.RADIO_NOTICE)
    var witness: Node3D = Characters.build(self, "npc_radio", Vector3(3.35, 0.0, 0.5))
    _spot("npc_radio", "询问陈站长", Vector3(3.35, 1.42, 0.5), witness.get_node("Body"))

func _build_shrine() -> void:
    ShrineSet.build(self, haunted)
    _spot("exit", "返回街道", Landmarks.SHRINE_EXIT)
    _spot("ritual", "阅读封声残页", Landmarks.SHRINE_RITUAL)
    _spot("tablet", "查看无名牌位", Landmarks.SHRINE_TABLET)

