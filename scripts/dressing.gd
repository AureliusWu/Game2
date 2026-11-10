extends RefCounted
## Milestone v0.2: a modular, resource-free environment art pass.
## Everything here is bespoke procedural blockout and can later be swapped for PBR meshes.

static func decorate(scene, zone: String, haunted: bool = false) -> void:
    match zone:
        "street":
            _street(scene, haunted)
        "shop":
            _shop(scene)
        "radio":
            _radio(scene, haunted)
        "shrine":
            _shrine(scene)
    _atmosphere(scene, zone)

static func _strip(scene, pos: Vector3, size: Vector3, color: Color) -> void:
    scene._box(pos, size, color)

static func _street(scene, haunted: bool) -> void:
    var brick := Color(0.46, 0.37, 0.29)
    var dark := Color(0.20, 0.24, 0.22)
    var faded := Color(0.72, 0.65, 0.49)
    # An uneven curb, seams, manhole and utility covers make the town legible.
    for i in range(18):
        var z: float = -28.0 + i * 3.0
        _strip(scene, Vector3(-4.55, 0.13, z), Vector3(0.42, 0.025, 0.045), dark)
        _strip(scene, Vector3(4.55, 0.13, z), Vector3(0.42, 0.025, 0.045), dark)
    scene._cylinder(Vector3(2.3, 0.03, 0), 0.52, 0.09, Color(0.26, 0.27, 0.25))
    for i in range(4):
        _strip(scene, Vector3(2.3, 0.09, -0.30 + i * 0.2),
            Vector3(0.44, 0.012, 0.035), Color(0.44, 0.45, 0.41))
    # Exterior shop awning and traditional signage (not copied from real brands).
    _strip(scene, Vector3(-5.1, 3.35, 4.0), Vector3(1.8, 0.10, 6.8), Color(0.30, 0.43, 0.38))
    for i in range(7):
        _strip(scene, Vector3(-4.22, 3.31, 1.1 + 0.9 * i),
            Vector3(0.07, 0.02, 0.4), faded)
    _strip(scene, Vector3(-5.08, 2.20, 7.4), Vector3(0.07, 1.5, 2.0), faded)
    _strip(scene, Vector3(-5.03, 1.82, 7.4), Vector3(0.08, 0.28, 1.82), brick)
    scene._label("冰汽水 · 两角五分", Vector3(-4.91, 2.45, 7.4), 27)
    _strip(scene, Vector3(-5.02, 0.60, 6.4), Vector3(0.14, 1.16, 0.9), dark)
    # Green door, weathered tiles and drain under the radio station.
    _strip(scene, Vector3(5.11, 2.9, -8.0), Vector3(0.10, 0.35, 2.8), faded)
    for i in range(7):
        _strip(scene, Vector3(5.09, 0.40 + i * 0.32, -11.0),
            Vector3(0.05, 0.035, 2.8), brick)
    _strip(scene, Vector3(5.13, 0.18, -8.0), Vector3(0.15, 0.18, 2.4), dark)
    scene._label("县有线广播站 · 2003", Vector3(4.85, 4.15, -8.0), 25)
    # Utility poles with crossbars, exposed cabling and ceramic insulators.
    for z in [17.0, -3.0, -23.0]:
        var base := Vector3(3.9, 0, z)
        scene._cylinder(base + Vector3(0, 3.8, 0), 0.10, 7.6, dark)
        _strip(scene, base + Vector3(0, 6.3, 0), Vector3(0.26, 0.19, 2.7), brick)
        for dz in [-0.9, 0.0, 0.9]:
            scene._cylinder(base + Vector3(0, 6.5, dz), 0.09, 0.28, faded)
    # Green street sign and a closed public phone booth.
    _strip(scene, Vector3(3.65, 2.5, 9.0), Vector3(0.10, 0.95, 2.2),
        Color(0.18, 0.34, 0.28))
    scene._label("怀声镇  /  HUAI SHENG", Vector3(3.42, 2.54, 9.0), 27)
    scene._box(Vector3(4.65, 1.12, 16), Vector3(0.6, 2.2, 1.3),
        Color(0.18, 0.39, 0.34))
    scene._box(Vector3(4.24, 1.45, 16), Vector3(0.12, 0.43, 0.48),
        Color(0.13, 0.19, 0.16))
    scene._label("公用电话", Vector3(4.13, 2.45, 16), 25)
    # Paint peel patches, shuttered windows and concrete balcony bands.
    for z in [-14.0, -11.0, -8.0, -5.0]:
        _strip(scene, Vector3(5.08, 5.5, z), Vector3(0.10, 0.10, 1.85), brick)
    for z in [2.0, 4.0, 6.0]:
        _strip(scene, Vector3(-5.12, 5.2, z), Vector3(0.14, 0.19, 1.7),
            Color(0.35, 0.36, 0.31))
    # The shrine uses signs and paper streamers. Preserve path to doorway.
    _strip(scene, Vector3(-1.9, 2.9, -27.72), Vector3(0.08, 2.3, 0.48),
        Color(0.48, 0.22, 0.18))
    _strip(scene, Vector3(1.9, 2.9, -27.72), Vector3(0.08, 2.3, 0.48),
        Color(0.48, 0.22, 0.18))
    scene._label("夜禁人声", Vector3(-1.73, 2.88, -27.60), 25)
    scene._label("禁呼姓名", Vector3(1.73, 2.88, -27.60), 25)
    for i in range(8):
        _strip(scene, Vector3(-2.5 + 0.7 * i, 4.25, -27.55),
            Vector3(0.16, 0.75 + 0.1 * (i % 3), 0.04),
            Color(0.76, 0.69, 0.49))
    # The anomaly alters a single familiar sign rather than turning the whole world surreal.
    if haunted:
        scene._label("广播已结束  请不要回答", Vector3(0.0, 2.3, -6.2), 29)
        _strip(scene, Vector3(-4.2, 1.2, -18.3),
            Vector3(0.22, 1.7, 1.2), Color(0.76, 0.72, 0.59))
        scene._label("你已经回来", Vector3(-3.95, 2.35, -18.3), 27)

static func _shop(scene) -> void:
    # Non-branded 2000s grocery: bottles, enamel basin, calendars, fluorescent tube.
    for j in range(3):
        for i in range(6):
            var z: float = -4.17 + i * 0.31
            var y: float = 1.23 + j * 0.67
            var palette := [
                Color(0.36, 0.55, 0.30),
                Color(0.68, 0.48, 0.24),
                Color(0.40, 0.51, 0.52),
                Color(0.65, 0.40, 0.31)
            ]
            scene._cylinder(Vector3(3.45, y, z), 0.075, 0.23, palette[(i + j) % 4])
            _strip(scene, Vector3(3.45, y + 0.15, z),
                Vector3(0.09, 0.04, 0.09), Color(0.84, 0.77, 0.59))
    # CRT cash terminal with faint cyan monochrome display.
    scene._box(Vector3(-0.85, 1.65, -2.45),
        Vector3(0.55, 0.66, 0.70), Color(0.64, 0.62, 0.51))
    _strip(scene, Vector3(-0.85, 1.67, -2.08),
        Vector3(0.44, 0.42, 0.04), Color(0.14, 0.33, 0.31))
    scene._label("￥ 0.25", Vector3(-0.85, 1.69, -2.02), 25)
    scene._box(Vector3(2.0, 0.34, 2.7), Vector3(1.2, 0.6, 0.8),
        Color(0.34, 0.40, 0.43))
    scene._cylinder(Vector3(2.0, 0.72, 2.7), 0.48, 0.20,
        Color(0.64, 0.67, 0.56))
    # Fan blades overhead; low ceiling with warm fixture.
    scene._cylinder(Vector3(0, 5.7, 0), 0.16, 0.45, Color(0.32, 0.32, 0.29))
    for i in range(4):
        var angle: float = TAU * i / 4.0
        scene._box(Vector3(cos(angle) * 0.63, 5.46, sin(angle) * 0.63),
            Vector3(1.28 if i % 2 == 0 else 0.17, 0.06,
            0.17 if i % 2 == 0 else 1.28), Color(0.36, 0.32, 0.26))
    scene._box(Vector3(-4.8, 3.5, -5.79), Vector3(0.8, 1.15, 0.12),
        Color(0.87, 0.81, 0.68))
    scene._label("二〇〇三年 七月", Vector3(-4.8, 3.68, -5.59), 24)
    scene._light(Vector3(0, 5.1, 0), Color(0.96, 0.77, 0.50), 1.05, 12.0)

static func _radio(scene, haunted: bool) -> void:
    var metal := Color(0.26, 0.31, 0.31)
    var amber := Color(0.76, 0.44, 0.23)
    # Consoles, rotary control knobs, tape reels and burnt-out indicator lamps.
    for i in range(12):
        scene._cylinder(Vector3(-2.5 + 0.43 * i, 1.18, -2.28),
            0.06, 0.10, Color(0.30, 0.34, 0.35))
    for i in range(2):
        scene._cylinder(Vector3(1.3 + 0.6 * i, 1.18, -2.68),
            0.25, 0.06, metal)
        scene._cylinder(Vector3(1.3 + 0.6 * i, 1.23, -2.68),
            0.13, 0.06, Color(0.58, 0.60, 0.56))
    scene._box(Vector3(3.2, 1.2, -2.5), Vector3(0.35, 0.29, 0.35),
        Color(0.40, 0.38, 0.31))
    scene._box(Vector3(3.18, 1.38, -2.29), Vector3(0.12, 0.08, 0.05),
        amber, false, true)
    scene._label("播出频率  75.4 MHz", Vector3(0, 3.4, -5.50), 28)
    # 2003 documents and radio station crest — no copyrighted trademarks.
    scene._box(Vector3(-4.75, 2.7, -5.79), Vector3(1.1, 1.6, 0.05),
        Color(0.78, 0.74, 0.59))
    scene._label("停播通知\n七月十七日", Vector3(-4.75, 2.67, -5.60), 26)
    for i in range(3):
        _strip(scene, Vector3(4.9, 3.2 + i * 0.4, -4.0),
            Vector3(0.09, 0.08, 1.4), metal)
    if haunted:
        scene._label("21:47 // 来电者：你", Vector3(0, 4.3, -5.5), 32)
        for i in range(4):
            scene._box(Vector3(-2.1 + i * 1.3, 1.75, -2.65),
                Vector3(0.20, 0.10, 0.09), Color(0.84, 0.21, 0.18), false, true)
        scene._light(Vector3(0, 3.3, -2.8), Color(0.9, 0.14, 0.12), 0.85, 7.2)

static func _shrine(scene) -> void:
    # Incense, ritual ledgers and handwritten-looking strips of paper.
    for i in range(7):
        var x: float = -1.75 + 0.55 * i
        scene._cylinder(Vector3(x, 2.06, -3.6), 0.028, 0.83,
            Color(0.46, 0.23, 0.14))
        scene._cylinder(Vector3(x, 2.48, -3.6), 0.035, 0.07,
            Color(0.79, 0.30, 0.16))
    scene._box(Vector3(1.6, 1.8, -4), Vector3(0.5, 0.6, 0.35),
        Color(0.75, 0.67, 0.46))
    scene._box(Vector3(-4.6, 4.4, -5.77), Vector3(0.9, 2.6, 0.08),
        Color(0.73, 0.63, 0.45))
    scene._label("慎言\n勿呼", Vector3(-4.6, 4.4, -5.6), 30)
    scene._label("无名无姓，不应不答", Vector3(0, 4.1, -5.58), 29)
    # An old enamel bowl and offerings.
    scene._cylinder(Vector3(-1.7, 1.78, -3.5), 0.34, 0.14,
        Color(0.68, 0.64, 0.50))
    scene._cylinder(Vector3(1.6, 1.77, -3.5), 0.34, 0.14,
        Color(0.68, 0.64, 0.50))
    scene._light(Vector3(-1.6, 2.5, -3.8), Color(1.0, 0.54, 0.30), 0.72, 6.0)

static func _atmosphere(scene, zone: String) -> void:
    # Slightly warmer key light and ground-level shadow accents.
    if zone == "street":
        scene._light(Vector3(-5.0, 2.0, 4.0), Color(0.96, 0.64, 0.42), 0.35, 5.0)
    elif zone == "radio":
        scene._light(Vector3(-3.0, 4.9, 2.0), Color(0.40, 0.66, 0.68), 0.45, 9.0)
    elif zone == "shrine":
        scene._light(Vector3(3.0, 5.1, 2.0), Color(0.69, 0.52, 0.31), 0.4, 9.0)
