extends SceneTree
## Progression and durable restart contracts; input-driven journey lives in player_journey.gd.
const CaseBoard = preload("res://scripts/case_board.gd")
const SAVE := "user://qa/player-ux-v011.json"

func _initialize() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error("PLAYER_UX_FAILED: " + reason)
    quit(1)

func _buttons(root: Node) -> Array[String]:
    var labels: Array[String] = []
    for node in root.find_children("*", "Button", true, false):
        if node.focus_mode != Control.FOCUS_NONE:
            labels.append(node.text)
    return labels

func _run() -> void:
    for path in [SAVE, SAVE + ".previous"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    var game: Node3D = load("res://scenes/main.tscn").instantiate()
    game.set("save_path", SAVE)
    get_root().add_child(game)
    await process_frame
    if CaseBoard.timeline({}).contains("21:47") or CaseBoard.timeline({}).contains("22:16"):
        _fail("Undiscovered evidence timestamps leaked into notebook")
        return
    game.call("_crosscheck_answer", "B")
    if game.collected.has("ledger_crosscheck"):
        _fail("Crosscheck bypassed evidence/witness gate")
        return
    game.collected = {"ledger": true, "shop_testimony": true}
    game.call("_crosscheck_answer", "A")
    if game.collected.has("ledger_crosscheck") or not game.modal.visible:
        _fail("Incorrect witness conclusion was accepted or feedback disappeared")
        return
    game.call("_crosscheck_answer", "B")
    if not game.collected.has("ledger_crosscheck") or game.call("_ready_to_deduce"):
        _fail("Optional crosscheck failed or bypassed the four main clues")
        return
    game.collected = {}
    game.call("_load_save")
    if not game.collected.has("ledger_crosscheck"):
        _fail("Completed witness crosscheck was not persisted")
        return
    game.collected = {"poster": true, "ledger": true, "log": true, "tape": true, "ledger_crosscheck": true}
    game.call("_journal")
    var actions: Array[String] = _buttons(game.modal)
    if actions.is_empty() or actions[0] != "整理时间线 · 开始推理":
        _fail("Deduction action is still buried after evidence archive")
        return
    game.call("_answer", "A")
    if game.finished or not _buttons(game.modal).has("B. 声音早已出现，广播只是将它传到了镇上"):
        _fail("Wrong deduction did not retain actionable answer choices")
        return
    for zone in ["street", "shop", "radio", "shrine"]:
        game.call("_go_to", zone)
        var wording: String = game.call("_epilogue_setting")
        if zone == "shop" and not wording.contains("收音机"):
            _fail("Shop ending uses a spatially impossible narration")
            return
        if zone == "shrine" and not wording.contains("祠堂门外"):
            _fail("Shrine ending uses a spatially impossible narration")
            return
    game.call("_answer", "B")
    if not game.finished:
        _fail("Timeline completion regressed")
        return
    var prior: String = FileAccess.get_file_as_string(SAVE)
    game.call("_confirm_restart")
    game.call("_menu")
    if FileAccess.get_file_as_string(SAVE) != prior or not game.finished:
        _fail("Cancelling restart altered existing progress")
        return
    game.call("_restart_case")
    if game.finished or not game.collected.is_empty() or game.current_zone != "street":
        _fail("Confirmed restart failed to reset case")
        return
    if FileAccess.get_file_as_string(SAVE + ".previous") != prior:
        _fail("Restart did not preserve the prior save exactly")
        return
    var fresh: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
    if not fresh is Dictionary or not fresh.get("found", []).is_empty() or fresh.get("finished", true):
        _fail("Restart did not persist a clean next session")
        return
    game.call("_close_modal")
    var event := InputEventKey.new()
    event.pressed = true
    event.keycode = KEY_ESCAPE
    game.call("_input", event)
    if not _buttons(game.modal).has("操作与方位提示") or game.player.can_move:
        _fail("Escape did not open a usable investigation menu")
        return
    game.call("_close_modal")
    event.keycode = KEY_H
    game.call("_input", event)
    game.call("_process", 0.0)
    if not game.guidance_enabled or not game.navigation_label.visible or not game.navigation_label.text.contains("木告示栏"):
        _fail("Optional navigation guidance did not activate from current progress")
        return
    for path in [SAVE, SAVE + ".previous"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    print("PLAYER_UX_OK: discovered-only timeline, optional crosscheck, retry, spatial ending, restart backup/cancel, menu and guidance")
    game.queue_free()
    await process_frame
    quit(0)
