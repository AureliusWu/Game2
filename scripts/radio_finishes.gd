extends RefCounted
## Focused, fully original, tileable CPU-painted prototype PBR materials.
## Albedo, roughness and tangent-space normal maps are generated once and cached.
## They are art-directed placeholders, not photographs or licensed texture scans.
static var cache: Dictionary = {}
static var texture_cache: Dictionary = {}

static func get_finish(kind: String, tint: Color) -> StandardMaterial3D:
    var key: String = kind + ":" + tint.to_html(false)
    if cache.has(key):
        return cache[key]
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    mat.metallic = 0.75 if kind == "steel" else (0.46 if kind == "brass" else 0.0)
    mat.roughness = _rough(kind)
    mat.uv1_triplanar = true
    mat.uv1_scale = Vector3(0.44, 0.44, 0.44)
    if kind == "glass":
        mat.albedo_color = tint
        mat.roughness = 0.19
        mat.metallic = 0.20
        mat.emission_enabled = true
        mat.emission = Color(0.09, 0.24, 0.21)
        mat.emission_energy_multiplier = 0.35
        cache[key] = mat
        return mat

    # Grain depends on the surface type, never on tint. Share the three GPU maps
    # across differently coloured materials instead of repainting/uploading them.
    var maps: Dictionary = _textures(kind)
    mat.albedo_texture = maps["albedo"]
    mat.roughness_texture = maps["roughness"]
    mat.normal_enabled = true
    mat.normal_scale = 0.45 if kind == "plaster" else 0.20
    mat.normal_texture = maps["normal"]
    mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    cache[key] = mat
    return mat

static func _textures(kind: String) -> Dictionary:
    if texture_cache.has(kind):
        return texture_cache[kind]

    const SIDE := 128
    var grain := Image.create(SIDE, SIDE, false, Image.FORMAT_RGBA8)
    var normals := Image.create(SIDE, SIDE, false, Image.FORMAT_RGBA8)
    var roughness := Image.create(SIDE, SIDE, false, Image.FORMAT_RGBA8)
    var values := PackedFloat32Array()
    values.resize(SIDE * SIDE)
    var rng := RandomNumberGenerator.new()
    rng.seed = 20030717 + int(abs(hash(kind)))
    for y in range(SIDE):
        for x in range(SIDE):
            var fx: float = float(x)
            var fy: float = float(y)
            var noise: float = rng.randf_range(-0.035, 0.035)
            var large: float = sin(fx * 0.075 + sin(fy * 0.036)) * 0.042
            var fine: float = sin(fx * 0.49 + fy * 0.23) * 0.019
            var shade: float = 0.89 + noise + large + fine
            match kind:
                "plaster":
                    shade -= 0.05 * maxf(0.0, sin(fx * 0.035 + fy * 0.047))
                "wood":
                    shade += sin(fy * 0.23 + 0.65 * sin(fx * 0.10)) * 0.065
                    shade += sin(fy * 0.60) * 0.018
                "steel":
                    shade += sin(fy * 0.28) * 0.018
                "paper":
                    shade += noise * 0.4
                "concrete":
                    shade -= 0.035 * maxf(0.0, sin(fx * 0.18 + fy * 0.16))
                "fabric":
                    shade += (0.012 if x % 4 == 0 else -0.008)
                    shade += (0.012 if y % 4 == 0 else -0.008)
                "bakelite":
                    shade += noise * 0.18
                "brass":
                    shade += sin(fx * 0.09) * 0.024
            shade = clampf(shade, 0.62, 0.99)
            values[y * SIDE + x] = shade
            grain.set_pixel(x, y, Color(shade, shade * 0.985, shade * 0.95, 1.0))
            var surface_rough: float = clampf(_rough(kind) + (shade - 0.84) * 0.20, 0.13, 1.0)
            roughness.set_pixel(x, y, Color(surface_rough, surface_rough, surface_rough, 1.0))
    for y in range(SIDE):
        for x in range(SIDE):
            var l: float = values[y * SIDE + ((x - 1 + SIDE) % SIDE)]
            var r: float = values[y * SIDE + ((x + 1) % SIDE)]
            var u: float = values[((y - 1 + SIDE) % SIDE) * SIDE + x]
            var d: float = values[((y + 1) % SIDE) * SIDE + x]
            var n := Vector3((l - r) * 1.65, (u - d) * 1.65, 1.0).normalized()
            normals.set_pixel(x, y, Color(n.x * 0.5 + 0.5, n.y * 0.5 + 0.5, n.z * 0.5 + 0.5, 1.0))
    grain.generate_mipmaps()
    normals.generate_mipmaps()
    roughness.generate_mipmaps()
    var maps := {
        "albedo": ImageTexture.create_from_image(grain),
        "roughness": ImageTexture.create_from_image(roughness),
        "normal": ImageTexture.create_from_image(normals)
    }
    texture_cache[kind] = maps
    return maps

static func _rough(kind: String) -> float:
    match kind:
        "steel":
            return 0.40
        "brass":
            return 0.29
        "bakelite":
            return 0.47
        "glass":
            return 0.19
        "wood":
            return 0.67
        "fabric":
            return 0.94
        "paper":
            return 0.92
        _:
            return 0.88
