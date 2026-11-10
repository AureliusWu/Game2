extends RefCounted
## Original procedural environmental storytelling set-dressing, no third-party assets.
## This is an interim composition pass; it is not a photorealistic asset pack.

static func decorate(scene, zone: String, haunted: bool) -> void:
    match zone:
        "street":
            _street(scene, haunted)
        "shop":
            _shop(scene)
        "radio":
            _radio(scene, haunted)
        "shrine":
            _shrine(scene, haunted)

static func _street(scene, haunted: bool) -> void:
    # Shop frontage: blue-green ceramic skirting, aged shutters, rain streaks.
    for i in range(11):
        var z: float = -0.2 + float(i) * 0.85
        scene._box(Vector3(-5.13, 0.31, z), Vector3(0.075, 0.48, 0.78), Color(0.27, 0.45, 0.42), false, false, "tile")
    for i in range(7):
        var z: float = -11.5 + float(i) * 1.0
        scene._box(Vector3(5.12, 1.4, z), Vector3(0.05, 2.3, 0.025), Color(0.32, 0.39, 0.35), false, false, "metal")
    # Hand-painted rainwater trails on an old exterior wall.
    for i in range(14):
        var z: float = -20.0 + float(i) * 0.78
        var h: float = 0.55 + float(i % 4) * 0.35
        scene._box(Vector3(-5.13, 4.9 - h * 0.5, z), Vector3(0.028, h, 0.055), Color(0.34, 0.34, 0.29))
    # Power cables and paper notices; no real-world copyrighted signage.
    for i in range(6):
        scene._box(Vector3(3.93, 5.1 - i * 0.13, -2.0 - i * 3.5),
            Vector3(0.045, 0.035, 3.4), Color(0.15, 0.18, 0.18), false, false, "metal")
    scene._box(Vector3(-5.15, 1.75, 5.2), Vector3(0.045, 0.65, 0.48),
        Color(0.77, 0.68, 0.48), false, false, "paper")
    scene._label("停电通知\n七月十七日", Vector3(-5.08, 1.8, 5.2), 19)
    if haunted:
        scene._label("这里一直有人在听", Vector3(-4.92, 4.6, -12.0), 23)
        scene._light(Vector3(-4.5, 3.3, -12.0), Color(0.38, 0.55, 0.53), 0.3, 5.0)

static func _shop(scene) -> void:
    # A second-hand wall clock with hands fixed at 21:47.
    scene._cylinder(Vector3(-4.85, 3.2, 1.6), 0.42, 0.12, Color(0.66, 0.58, 0.42), "wood")
    scene._box(Vector3(-4.75, 3.22, 1.6), Vector3(0.045, 0.53, 0.04), Color(0.17, 0.17, 0.16))
    scene._label("21:47", Vector3(-4.64, 3.65, 1.6), 20)
    # Old enamel kettle, cardboard cartons, worn counter.
    scene._cylinder(Vector3(-1.5, 1.42, -2.5), 0.18, 0.32, Color(0.61, 0.70, 0.62), "metal")
    for i in range(3):
        scene._box(Vector3(1.0 + i * 0.6, 0.35, 3.7), Vector3(0.53, 0.70, 0.68),
            Color(0.48, 0.40, 0.27), false, false, "paper")
    scene._label("请勿赊账", Vector3(-1.6, 2.3, -2.1), 23)

static func _radio(scene, haunted: bool) -> void:
    # Acoustic wall panels and an analogue wall clock.
    for i in range(7):
        scene._box(Vector3(-4.9 + float(i) * 1.6, 3.4, -5.77),
            Vector3(1.25, 2.1, 0.09), Color(0.34, 0.39, 0.36), false, false, "wood")
    scene._box(Vector3(4.2, 3.0, -5.64), Vector3(0.95, 0.65, 0.07),
        Color(0.74, 0.67, 0.49), false, false, "paper")
    scene._label("录音室守则\n不得复播未知来源的录音", Vector3(4.2, 3.0, -5.47), 18)
    for i in range(4):
        scene._box(Vector3(-1.6 + float(i) * 1.05, 0.17, 0.5),
            Vector3(0.78, 0.08, 0.85), Color(0.38, 0.40, 0.37), false, false, "tile")
    if haunted:
        scene._label("21:47  监听线路仍在占用", Vector3(0.0, 4.9, -5.50), 23)

static func _shrine(scene, haunted: bool) -> void:
    # Ritual objects are fictional; this is not a documentary reconstruction.
    for i in range(5):
        var x: float = -2.2 + float(i) * 1.1
        scene._box(Vector3(x, 0.06, -3.2), Vector3(0.75, 0.07, 1.2),
            Color(0.40, 0.30, 0.22), false, false, "wood")
    for i in range(9):
        scene._box(Vector3(-4.7 + float(i) * 1.1, 5.3, -5.65),
            Vector3(0.08, 1.4, 0.08), Color(0.27, 0.18, 0.13), false, false, "wood")
    scene._label("封声是为了记住\n还是为了让人遗忘", Vector3(0.0, 3.2, -5.54), 24)
    if haunted:
        scene._light(Vector3(0, 2.9, -3.0), Color(0.62, 0.25, 0.16), 0.65, 5.0)
