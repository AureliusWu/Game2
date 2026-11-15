extends RefCounted
## Validated staging with rollback and a last-known-good investigation backup.
## The .pending file is never considered committed when loading.
var evidence_ids: Array
var required_ids: Array
var last_error: String = ""
var recovered: bool = false
var recovery_source: String = ""

func _init(known: Array = [], required: Array = []) -> void:
    evidence_ids = known
    required_ids = required

func _normalize(value: Variant) -> Dictionary:
    if not value is Dictionary or not value.get("found") is Array:
        return {}
    var found: Array = []
    for id in value["found"]:
        if id is String and evidence_ids.has(id) and not found.has(id):
            found.append(id)
    var complete: bool = value.get("finished", false) is bool and value.get("finished", false) == true
    for id in required_ids:
        complete = complete and found.has(id)
    return {"found": found, "finished": complete}

func _read(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}
    var bytes: String = file.get_as_text()
    file.close()
    var parser := JSON.new()
    if parser.parse(bytes) != OK:
        return {}
    var data: Dictionary = _normalize(parser.data)
    if data.is_empty():
        return {}
    return {"data": data, "bytes": bytes, "path": path}

func load_record(path: String) -> Dictionary:
    recovered = false
    recovery_source = ""
    for candidate in [path, path + ".rollback", path + ".previous", path + ".previous.rollback"]:
        var record: Dictionary = _read(candidate)
        if not record.is_empty():
            recovered = candidate != path
            recovery_source = candidate if recovered else ""
            return record
    return {}

func _stage(path: String, bytes: String, expected: Dictionary) -> bool:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        last_error = "无法写入暂存记录（" + str(FileAccess.get_open_error()) + "）"
        return false
    file.store_string(bytes)
    file.flush()
    var result: Error = file.get_error()
    file.close()
    var checked: Dictionary = _read(path)
    if result != OK or checked.is_empty() or checked["bytes"] != bytes or checked["data"] != expected:
        last_error = "暂存记录未通过写入校验"
        return false
    return true

func _rename(source: String, target: String) -> Error:
    return DirAccess.rename_absolute(ProjectSettings.globalize_path(source), ProjectSettings.globalize_path(target))

func _remove(path: String) -> Error:
    return DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _promote(stage: String, target: String) -> bool:
    var rollback: String = target + ".rollback"
    if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(target)) or DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(rollback)):
        last_error = "存档位置被文件夹占用"
        return false
    # Caller has already retained a validated backup before rotating the main file.
    if FileAccess.file_exists(rollback):
        if _read(target).is_empty() and not _read(rollback).is_empty():
            # An interrupted earlier rotation may leave the only good copy here.
            if FileAccess.file_exists(target) and _remove(target) != OK:
                last_error = "无法移开损坏记录"
                return false
            if _rename(rollback, target) != OK:
                last_error = "无法恢复上一份回滚记录"
                return false
        elif _remove(rollback) != OK:
            last_error = "无法整理上一份回滚记录"
            return false
    var existed: bool = FileAccess.file_exists(target)
    if existed and _rename(target, rollback) != OK:
        last_error = "原记录无法移入回滚位置"
        return false
    if _rename(stage, target) != OK:
        last_error = "无法提交暂存记录"
        if existed and _rename(rollback, target) != OK:
            last_error += "；原进度仍保留在回滚记录中"
        return false
    if existed:
        _remove(rollback)
    return true

func write_record(path: String, value: Dictionary) -> bool:
    last_error = ""
    var expected: Dictionary = _normalize(value)
    if expected.is_empty():
        last_error = "调查记录格式不完整"
        return false
    var directory: String = ProjectSettings.globalize_path(path.get_base_dir())
    if DirAccess.make_dir_recursive_absolute(directory) != OK:
        last_error = "无法创建存档目录"
        return false
    var stage: String = path + ".pending"
    if not _stage(stage, JSON.stringify(expected), expected):
        return false
    var prior: Dictionary = load_record(path)
    if not prior.is_empty() and prior["path"] != path + ".previous":
        var backup: String = path + ".previous"
        if not _stage(backup + ".pending", prior["bytes"], prior["data"]) or not _promote(backup + ".pending", backup):
            _remove(stage)
            return false
    if not _promote(stage, path):
        _remove(stage)
        return false
    return true
