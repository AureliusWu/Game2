extends Node
## Real filesystem failures plus a deterministic commit/rollback fault.
const Store = preload("res://scripts/save_store.gd")
const Game = preload("res://scripts/game.gd")
const BASE := "user://qa/persistence-v014"
const SAVE := BASE + "/case.json"
const BEFORE := {"found": ["poster", "ledger"], "finished": false}
const AFTER := {"found": ["poster", "ledger", "log"], "finished": false}
var checks: int = 0
var failed: bool = false

class CommitFailure extends Store:
    var block_rollback: bool = false
    func _rename(source: String, target: String) -> Error:
        if target.ends_with("/case.json") and (source.ends_with(".pending") or (block_rollback and source.ends_with(".rollback"))):
            return ERR_CANT_CREATE
        return super._rename(source, target)

func _ready() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> void:
    checks += 1
    if not ok:
        failed = true
        push_error("PERSISTENCE_FAILED: " + reason)

func _write(path: String, text: String) -> void:
    var file := FileAccess.open(path, FileAccess.WRITE)
    file.store_string(text)
    file.close()

func _clean(path: String) -> void:
    var absolute: String = ProjectSettings.globalize_path(path)
    if DirAccess.dir_exists_absolute(absolute):
        var dir := DirAccess.open(absolute)
        for child in dir.get_files():
            DirAccess.remove_absolute(absolute.path_join(child))
        for child in dir.get_directories():
            _clean(path.path_join(child))
    DirAccess.remove_absolute(absolute)

func _seed(store: RefCounted) -> void:
    _clean(BASE)
    _check(store.write_record(SAVE, BEFORE), "Seed initial investigation")

func _run() -> void:
    if OS.get_cmdline_user_args().has("--expect-export"):
        _check(not OS.has_feature("editor"), "Run from exported template, not source editor")
        _check(ProjectSettings.get_setting("application/config/version") == "0.14.0-dev", "Exported version identity")
        print("EXPORTED_PACKAGE_OK: 0.14.0-dev")
    var store = Store.new(Game.EVIDENCE.keys(), Game.REQUIRED)
    _seed(store)
    var prior: String = FileAccess.get_file_as_string(SAVE)
    _check(store.write_record(SAVE, AFTER), "Commit next investigation")
    _check(FileAccess.get_file_as_string(SAVE + ".previous") == prior, "Exact valid previous bytes")
    _write(SAVE, "{truncated")
    var record: Dictionary = store.load_record(SAVE)
    _check(record.get("data") == BEFORE and store.recovered, "Recover corrupt primary from valid backup")
    _check(store.write_record(SAVE, AFTER), "Save after recovery")
    _check(FileAccess.get_file_as_string(SAVE + ".previous") == prior, "Corrupt primary never overwrites valid backup")
    _write(SAVE, "{}")
    _check(store.load_record(SAVE).get("data") == BEFORE, "Reject structurally invalid JSON primary")
    _write(SAVE, "broken")
    _write(SAVE + ".previous", "broken too")
    _check(store.load_record(SAVE).is_empty(), "No invented progress from two corrupt records")
    _seed(store)
    DirAccess.rename_absolute(ProjectSettings.globalize_path(SAVE), ProjectSettings.globalize_path(SAVE + ".rollback"))
    _write(SAVE + ".pending", JSON.stringify(AFTER))
    _check(store.load_record(SAVE).get("data") == BEFORE and store.recovered, "Interrupted rotation restores committed rollback, ignores staging")
    _check(store.write_record(SAVE, AFTER), "Resume writing after interrupted rotation")
    _check(store.load_record(SAVE).get("data") == AFTER, "New committed session wins over old copies")
    _seed(store)
    _write(SAVE, JSON.stringify({"found": ["poster", "unknown", 42, "poster"], "finished": "true"}))
    _check(store.load_record(SAVE).get("data") == {"found": ["poster"], "finished": false}, "Legacy evidence filtering and completion guard")
    for suffix in [".pending", ".previous", ".previous.pending", ".rollback"]:
        _seed(store)
        DirAccess.make_dir_absolute(ProjectSettings.globalize_path(SAVE + suffix))
        var before: String = FileAccess.get_file_as_string(SAVE)
        _check(not store.write_record(SAVE, AFTER), "Blocked " + suffix + " must fail")
        _check(FileAccess.get_file_as_string(SAVE) == before, "Blocked " + suffix + " preserves primary")
    _seed(store)
    _write(BASE + "/blocked-parent", "file")
    _check(not store.write_record(BASE + "/blocked-parent/case.json", AFTER), "Parent file blocks save safely")
    _seed(store)
    var fault = CommitFailure.new(Game.EVIDENCE.keys(), Game.REQUIRED)
    _check(not fault.write_record(SAVE, AFTER), "Injected promotion failure reported")
    _check(store.load_record(SAVE).get("data") == BEFORE, "Promotion failure rolls primary back")
    fault.block_rollback = true
    _check(not fault.write_record(SAVE, AFTER), "Injected rollback failure reported")
    _check(store.load_record(SAVE).get("data") == BEFORE and store.recovered, "Failed rollback remains recoverable")
    # Exercise real game restart, scene/modal state, failure feedback and retry.
    _seed(store)
    var game: Node3D = load("res://scenes/main.tscn").instantiate()
    game.save_path = SAVE
    get_tree().root.add_child(game)
    await get_tree().process_frame
    game._close_modal()
    game._go_to("shop")
    var position: Vector3 = game.player.global_position
    game.collected["log"] = true # an unsaved clue must enter the restart backup too
    DirAccess.make_dir_absolute(ProjectSettings.globalize_path(SAVE + ".pending"))
    game._restart_case()
    _check(game.collected.has("log") and game.current_zone == "shop" and game.player.global_position == position, "Failed restart preserves in-memory progress and location")
    _check(game.modal.visible and not game.player.can_move and game.save_error != "", "Failed restart keeps a usable paused modal")
    game._menu()
    var retry: Button
    for button in game.modal.find_children("*", "Button", true, false):
        if button.text == "重试保存当前调查":
            retry = button
    _check(retry != null, "Failure offers explicit retry")
    _clean(SAVE + ".pending")
    if retry != null:
        retry.pressed.emit()
    _check(game.save_error == "" and store.load_record(SAVE).get("data") == AFTER, "Menu retry persists unsaved clue")
    game._restart_case()
    _check(game.collected.is_empty() and not game.finished and game.current_zone == "street", "Successful restart resets only after commit")
    _check(store.load_record(SAVE).get("data") == {"found": [], "finished": false}, "Clean next session is committed")
    var backup: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SAVE + ".previous"))
    _check(backup == AFTER, "Restart backup includes current unsaved clues")
    game.queue_free()
    await get_tree().process_frame
    _write(SAVE, "broken")
    game = load("res://scenes/main.tscn").instantiate()
    game.save_path = SAVE
    get_tree().root.add_child(game)
    await get_tree().process_frame
    _check(game.save_recovered and game.collected.has("log") and game.photo_notice.visible, "Actual scene loads backup and shows recovery notice")
    if OS.get_cmdline_user_args().has("--expect-export"):
        await get_tree().process_frame
        await RenderingServer.frame_post_draw
        var image: Image = get_tree().root.get_texture().get_image()
        var capture: String = OS.get_executable_path().get_base_dir().path_join("../windows-qa/recovered-investigation.png")
        _check(image != null and not image.is_empty() and image.save_png(capture) == OK, "Rendered Windows EXE recovery screenshot")
    game.queue_free()
    await get_tree().process_frame
    _clean(BASE)
    if failed:
        get_tree().quit(1)
        return
    print("PERSISTENCE_OK: " + str(checks) + " filesystem, rollback, legacy, restart, retry and scene recovery checks")
    get_tree().quit(0)
