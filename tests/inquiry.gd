extends SceneTree
## Deterministic state/GUI harness. Seeded evidence is explicit, not a walking playthrough.
const Inquiry = preload("res://scripts/inquiry.gd")
const OUT := "res://build/inquiry-captures"
const SAVE := "user://qa/inquiry-v20.json"
var game: Node3D
var checks: int = 0
var captures: int = 0
var failed: bool = false
var rendered: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
    checks += 1
    if not ok:
        failed = true
        push_error("INQUIRY_FAILED: " + reason)
        quit(1)
    return ok

func _run() -> void:
    rendered = DisplayServer.get_name() != "headless"
    if rendered:
        RenderingServer.set_render_loop_enabled(false)
        DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
    game = load("res://scenes/main.tscn").instantiate()
    game.persistence_enabled = false
    root.add_child(game)
    await process_frame
    game.player.set_physics_process(false)
    game._close_modal()
    game._answer("B")
    if not _check(not game.finished, "Direct correct answer bypassed main evidence gate"):
        return
    var unseen: String = Inquiry.leads({}) + Inquiry.dossier({}, false)
    if not _check(not unseen.contains("21:47") and not unseen.contains("22:16") and not unseen.contains("20:43") and not unseen.contains("有人报了名字"), "Undiscovered facts leaked"):
        return
    game._journal()
    await _click("证据关联板")
    await _snap("01_empty_board")
    await _click("练声与回声")
    if not _check(game.inquiry_pair.is_empty(), "Empty board preselected evidence"):
        return
    await _snap("02_empty_materials")
    # Exhaust every candidate pair and answer, including duplicate and unknown IDs.
    var sources: Array = ["poster", "ledger", "log", "tape", "ritual", "calendar", "broadcast_notice", "tablet", "shop_testimony", "radio_testimony", "town_echo", "phone_whisper", "school_register", "school_notebook", "unknown"]
    var full: Dictionary = {}
    for id in sources:
        if id != "unknown":
            full[id] = true
    for key in Inquiry.THREADS:
        var thread: Dictionary = Inquiry.THREADS[key]
        var required: Array = thread["requires"]
        for a in sources:
            for b in sources:
                for answer in range(-1, 4):
                    var expected: bool = a != b and required.has(a) and required.has(b) and answer == thread["correct"]
                    if not _check((Inquiry.resolve(key, [a, b], answer, full) != "") == expected, "Invalid pair/answer admitted: " + key):
                        return
        for absent in required:
            var missing: Dictionary = full.duplicate()
            missing.erase(absent)
            if not _check(Inquiry.resolve(key, required, int(thread["correct"]), missing) == "", "Missing evidence passed: " + key):
                return
    if not _check(not Inquiry.valid_pair("unknown", [], full), "Unknown thread admitted"):
        return
    game.collected = full.duplicate()
    game._inquiry_select("broadcast")
    await _click("＋ 寻人启事")
    await _click("＋ 小卖部账本")
    await _click("核对这两份材料")
    if not _check(not game.collected.has("broadcast_crosscheck") and game.inquiry_pair.size() == 2, "Wrong pairing granted result or lost selection"):
        return
    await _snap("03_wrong_pair")
    await _click("✓ 寻人启事")
    await _click("✓ 小卖部账本")
    await _click("＋ 广播站值班日志")
    await _click("＋ 21:47 的录音")
    await _click("核对这两份材料")
    await _click("A. 公开广播")
    if not _check(not game.collected.has("broadcast_crosscheck"), "Wrong inference archived"):
        return
    await _snap("04_wrong_inference")
    await _click("B. 内线声音")
    if not _check(game.collected.has("broadcast_crosscheck") and not game.finished, "Association bypassed final conclusion"):
        return
    await _snap("05_archived_association")
    game._close_modal()
    if not _check(game.inquiry_thread == "" and game.inquiry_pair.is_empty(), "Close leaked draft selection"):
        return
    # All remaining questions through the shipped GUI; seeded facts remain explicit.
    for key in ["identity", "origin", "notice", "folklore"]:
        game._inquiry_select(key)
        var thread: Dictionary = Inquiry.THREADS[key]
        for id in thread["requires"]:
            await _click("＋ " + str(game.EVIDENCE[id]["name"]))
        await _click("核对这两份材料")
        await _click(str(thread["choices"][thread["correct"]]))
        if not _check(game.collected.has(thread["result"]), "GUI did not archive " + key):
            return
    game._inquiry_select("origin")
    game._inquiry_toggle("school_notebook")
    game._go_to("shop")
    if not _check(game.inquiry_pair.is_empty(), "Scene transition retained draft pair"):
        return
    # Prerequisites + wrong witness + repeated entries; no remote witness evidence.
    for person in Inquiry.FOLLOWUPS:
        for item in Inquiry.FOLLOWUPS[person]:
            var prerequisite: String = str(item["requires"][0])
            var missing: Dictionary = full.duplicate()
            missing.erase(prerequisite)
            if not _check(Inquiry.followup(person, item["id"], missing).is_empty(), "Incomplete followup unlocked"):
                return
    game._present_evidence("npc_radio", "broadcast_notice")
    if not _check(not game.collected.has("notice_testimony"), "Remote witness awarded evidence"):
        return
    for person in ["npc_shop", "npc_radio"]:
        game._go_to("shop" if person == "npc_shop" else "radio")
        game._interview(person)
        for item in Inquiry.FOLLOWUPS[person]:
            await _click(str(item["label"]))
            if not _check(game.collected.has(item["result"]) and game.active_witness == person and game.witness_panel_mode, "Followup did not preserve witness and archive"):
                return
            if item["id"] == "calendar" or item["id"] == "broadcast_notice":
                await _snap("06_" + str(item["result"]))
            await _click("继续问话")
        await _click("结束问话")
        if not _check(game.active_witness == "" and not game.conversation_stage.active, "Witness lifecycle did not end"):
            return
    # Restore a four-clue legacy save, then persist all new stable IDs.
    for suffix in ["", ".previous", ".rollback", ".pending", ".previous.rollback"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE + suffix))
    game.save_path = SAVE
    game.persistence_enabled = true
    var progress: Dictionary = game.collected.duplicate()
    var legacy := FileAccess.open(SAVE, FileAccess.WRITE)
    legacy.store_string(JSON.stringify({"found": ["poster", "ledger", "log", "tape"], "finished": true}))
    legacy.close()
    game._load_save()
    if not _check(game.finished and game.collected.size() == 4, "Legacy complete save incompatible"):
        return
    game.collected = progress
    if not _check(game._save(), "New conclusions failed safe persistence"):
        return
    game.collected.clear()
    game._load_save()
    if not _check(game.collected == progress and game.finished, "New stable IDs lost on reload"):
        return
    game._dossier()
    await _snap("07_completed_dossier")
    await _click("查看尚可追查的线索")
    await _snap("08_followed_leads")
    # Minimum supported window + actual focus-follow scroll and Enter.
    root.size = Vector2i(640, 360)
    await process_frame
    game._inquiry_select("origin")
    await _click("＋ 林小禾的练声簿")
    await _click("＋ 21:47 的录音")
    await _click("核对这两份材料")
    await _snap("09_compact_compare")
    await _click("C. 可以追查")
    await _click("回看调查卷宗")
    await _snap("10_compact_dossier")
    await _click("返回调查")
    if not _check(game.player.can_move and not game.modal.visible, "Closing dossier did not release player"):
        return
    # Returning to the main four-clue route must not require the new systems.
    game.collected = {"poster": true, "ledger": true, "log": true, "tape": true}
    game.finished = false
    game._answer("B")
    if not _check(game.finished, "Optional systems became mandatory"):
        return
    game.queue_free()
    for i in range(4):
        await process_frame
    for suffix in ["", ".previous", ".rollback", ".pending", ".previous.rollback"]:
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE + suffix))
    if not failed:
        print("INQUIRY_OK: %d checks; five pair/inference branches; four followups; legacy/new save; keyboard; compact UI; %d actual captures" % [checks, captures])
        quit(0)

func _key(code: Key) -> void:
    var event := InputEventKey.new()
    event.keycode = code
    event.pressed = true
    Input.parse_input_event(event)
    await process_frame
    event = event.duplicate()
    event.pressed = false
    Input.parse_input_event(event)
    await process_frame

func _click(prefix: String) -> void:
    if failed:
        return
    await process_frame
    await process_frame
    var target: Button
    for child in game.modal.find_children("*", "Button", true, false):
        if child.text.begins_with(prefix):
            target = child
            break
    if not _check(target != null, "Missing GUI choice: " + prefix):
        return
    for i in range(40):
        if root.gui_get_focus_owner() == target:
            break
        await _key(KEY_TAB)
    if not _check(root.gui_get_focus_owner() == target, "Keyboard cannot reach: " + prefix):
        return
    await process_frame
    var area: Rect2 = game.modal_stack.get_parent().get_global_rect().grow(1.0)
    if not _check(area.encloses(target.get_global_rect()), "Focus did not scroll into view: " + prefix):
        return
    await _key(KEY_ENTER)
    await process_frame

func _snap(name: String) -> void:
    if not rendered or failed:
        return
    RenderingServer.set_render_loop_enabled(true)
    for i in range(4):
        await process_frame
    await RenderingServer.frame_post_draw
    var frame: Image = root.get_texture().get_image()
    if _check(frame != null and not frame.is_empty() and frame.save_png(OUT + "/" + name + ".png") == OK, "Actual capture failed: " + name):
        captures += 1
    RenderingServer.set_render_loop_enabled(false)
