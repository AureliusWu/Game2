extends RefCounted
## Save an actual rendered viewport frame, not a mocked or generated concept image.
## Runtime only; headless CI cannot validate screenshot pixels.

static func filename(zone: String, datetime: String, sequence: int) -> String:
    var safe_zone := zone.to_lower()
    for symbol in ["/", "\\", ":", " ", ".", ".."]:
        safe_zone = safe_zone.replace(symbol, "_")
    var safe_time := datetime.replace(":", "-").replace("T", "_").replace(" ", "_")
    return safe_zone + "_" + safe_time + "_" + str(sequence) + ".png"

static func store(frame: Image, zone: String, datetime: String, sequence: int) -> String:
    if frame == null or frame.is_empty():
        return ""
    var path := "user://screenshots/"
    var result := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
    if result != OK:
        return ""
    var name := filename(zone, datetime, sequence)
    var full_path: String = path + name
    if frame.save_png(full_path) != OK:
        return ""
    return ProjectSettings.globalize_path(full_path)
