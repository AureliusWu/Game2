extends RefCounted
## Temporary, deterministic authored-by-code material library. No external textures.
## Replacing these materials with licensed PBR scans/painted textures is a later art milestone.
static var cache: Dictionary = {}

static func get_surface(surface: String, tint: Color) -> StandardMaterial3D:
    var key: String = surface + ":" + tint.to_html(false)
    if cache.has(key):
        return cache[key]
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.roughness = _roughness(surface)
    material.metallic = 0.58 if surface == "metal" else 0.0
    material.uv1_triplanar = true
    material.uv1_scale = Vector3(0.62, 0.62, 0.62)
    material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    var img := Image.create(48, 48, false, Image.FORMAT_RGBA8)
    var rng := RandomNumberGenerator.new()
    rng.seed = int(abs(hash(key))) + 20030717
    for y in range(48):
        for x in range(48):
            var grain: float = rng.randf_range(-0.12, 0.12)
            var brightness: float = 0.90 + grain
            match surface:
                "plaster":
                    brightness -= 0.10 if x % 21 == 0 or y % 23 == 0 else 0.0
                    brightness += 0.08 * sin(float(x * 3 + y * 7) * 0.17)
                "wood":
                    brightness += 0.12 * sin(float(x) * 0.75 + sin(float(y) * 0.13))
                "tile":
                    brightness -= 0.25 if x % 12 < 2 or y % 12 < 2 else 0.0
                    brightness += 0.04 * sin(float(x + y) * 0.7)
                "asphalt":
                    brightness += 0.16 * sin(float(x * 11 + y * 19) * 0.35)
                "concrete":
                    brightness += 0.08 * sin(float(x * 7 - y * 3) * 0.17)
                "metal":
                    brightness += 0.08 * sin(float(y) * 0.7)
                "paper":
                    brightness += 0.03 * sin(float(x + y) * 0.3)
            brightness = clampf(brightness, 0.42, 1.0)
            img.set_pixel(x, y, Color(brightness, brightness, brightness, 1.0))
    img.generate_mipmaps()
    material.albedo_texture = ImageTexture.create_from_image(img)
    cache[key] = material
    return material

static func _roughness(surface: String) -> float:
    match surface:
        "metal":
            return 0.40
        "tile":
            return 0.72
        "wood":
            return 0.79
        "paper":
            return 0.96
        "asphalt":
            return 0.94
        _:
            return 0.88
