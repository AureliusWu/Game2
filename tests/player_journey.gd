extends SceneTree
## AI simulated first-time player: real movement physics and public input/GUI paths.
## Never teleports the player, grants clues, or calls investigation/deduction handlers.
const OUT := "res://build/player-journey"
var game: Node3D
var actor: CharacterBody3D
var eye: Camera3D
var stages: Array[Dictionary] = []
var travelled: float = 0.0
var walking_ticks: int = 0
var failed: bool = false
var rendered: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    rendered = DisplayServer.get_name() != "headless"
    if not rendered:
        _fail("This input-driven playthrough requires an X11 display (use Xvfb in CI)")
        return
    game = load("res://scenes/main.tscn").instantiate()
    game.set("persistence_enabled", false)
    get_root().add_child(game)
    actor = game.get_node("Player")
    eye = game.get_node("Player/Camera3D")
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
    if rendered:
        RenderingServer.set_render_loop_enabled(false)
    await _snap("01_arrival")
    await _click("继续", true)
    await _walk(Vector3(0, 0, 14))
    await _walk(Vector3(-3.9, 0, 14))
    await _inspect(Vector3(-4.55, 1.3, 12), "poster")
    await _snap("02_missing_poster")
    await _click("继续", true)
    await _key(KEY_H)
    await _snap("02a_optional_guidance")
    await _key(KEY_H)
    await _walk(Vector3(-2.7, 0, 4))
    await _inspect(Vector3(-4.85, 1.2, 4), "enter_shop")
    await _snap("03_shop_arrival")
    await _walk(Vector3(-1.8, 0, 0.4))
    await _inspect(Vector3(-1.8, 1.18, -1.6), "ledger")
    await _click("继续", true)
    await _walk(Vector3(-2.6, 0, 1.9))
    await _inspect(Vector3(-3.6, 1.42, 0.1), "npc_shop")
    await _click("问：7 月 20")
    await _snap("04_shop_testimony")
    await _click("继续问话", true)
    await _click("问：为什么")
    await _click("结束问话", true)
    await _walk(Vector3(-4.5, 0, 1.5))
    await _walk(Vector3(-4.5, 0, -3.4))
    await _inspect(Vector3(-4.4, 2.35, -5.6), "calendar")
    await _click("继续", true)
    await _key(KEY_J)
    await _click("核对账本与证词", true)
    await _click("A. 林小禾本人")
    await _click("B. 有人报出")
    await _snap("04a_ledger_crosscheck")
    await _click("返回调查", true)
    await _walk(Vector3(-4.5, 0, 2.9))
    await _walk(Vector3(0, 0, 3.5))
    await _inspect(Vector3(0, 1.25, 5.6), "exit")
    await _walk(Vector3(0, 0, 2))
    await _walk(Vector3(2.65, 0, -8))
    await _inspect(Vector3(4.85, 1.2, -8), "enter_radio")
    await _snap("05_radio_arrival")
    await _walk(Vector3(-0.52, 0, 0.5))
    await _inspect(Vector3(-0.52, 1.48, -1.67), "log")
    await _click("继续", true)
    await _walk(Vector3(1.86, 0, 0.1))
    await _inspect(Vector3(1.86, 1.65, -2.10), "tape")
    await _click("按下播放键", true)
    for i in range(3):
        await _click("继续监听", true)
    await _snap("06_tape_listening")
    await _click("记录线索并结束", true)
    await _click("继续", true)
    await _walk(Vector3(3.35, 0, 2.6))
    await _inspect(Vector3(3.35, 1.42, 0.5), "npc_radio")
    await _click("问：21:47")
    await _click("继续问话", true)
    await _click("问：停播通知")
    await _snap("07_radio_testimony")
    await _click("结束问话", true)
    await _walk(Vector3(3.5, 0, -0.3))
    await _walk(Vector3(3.5, 0, -4.4))
    await _walk(Vector3(4.7, 0, -4.4))
    await _inspect(Vector3(4.7, 2.48, -5.51), "broadcast_notice")
    await _click("继续", true)
    await _walk(Vector3(3.5, 0, -0.3))
    await _walk(Vector3(0, 0, 1.5))
    await _walk(Vector3(-2.8, 0, 3.7))
    await _inspect(Vector3(-2.8, 1.25, 5.6), "exit")
    await _snap("08_street_echo")
    await _click("继续", true)
    await _walk(Vector3(2, 0, 16.4))
    await _inspect(Vector3(4.42, 1.5, 16.4), "public_phone")
    await _click("继续", true)
    await _walk(Vector3(0, 0, -28.8))
    await _inspect(Vector3(0, 1.45, -31.35), "enter_shrine")
    await _snap("09_shrine_arrival")
    await _walk(Vector3(-2.3, 0, 0.1))
    await _inspect(Vector3(-2.3, 1.4, -2.1), "ritual")
    await _click("继续", true)
    await _walk(Vector3(0, 0, -1))
    await _inspect(Vector3(0, 2.3, -3.55), "tablet")
    await _click("继续", true)
    await _walk(Vector3(0, 0, 2.5))
    await _inspect(Vector3(0, 1.25, 4.4), "exit")
    await _key(KEY_J)
    await _snap("10_full_journal")
    await _click("整理时间线 · 开始推理", true)
    await _click("A. 广播")
    await _snap("11_wrong_deduction")
    await _click("B. 声音")
    await _snap("12_epilogue")
    if failed:
        return
    if not game.finished or game.collected.size() != 13:
        _fail("Route did not archive all thirteen clues and complete the timeline")
        return
    await _click("继续", true)
    await _key(KEY_ESCAPE)
    await _snap("13_investigation_menu")
    await _click("重新开始调查", true)
    await _click("保留当前调查 · 返回菜单", true)
    if not game.finished:
        _fail("Cancelling restart lost completed progress")
        return
    await _click("重新开始调查", true)
    await _click("确认重新开始", true)
    await _snap("14_restarted_case")
    if game.finished or not game.collected.is_empty() or game.current_zone != "street":
        _fail("Confirmed restart did not return to a clean case at town entrance")
        return
    var report := FileAccess.open(OUT + "/journey.json", FileAccess.WRITE)
    report.store_string(JSON.stringify({"method": "continuous WASD/mouse/key/GUI input; no teleports or evidence injection",
        "metres_walked": travelled, "walking_ticks": walking_ticks, "stages": stages}, "  "))
    print("PLAYER_JOURNEY_OK: " + str(stages.size()) + " stages; " + str(snappedf(travelled, 0.1)) + " metres; all thirteen clues; wrong/correct deduction; menu and restart")
    game.queue_free()
    await process_frame
    quit(0)

func _key(code: Key, pressed: bool = true) -> void:
    if failed:
        return
    var event := InputEventKey.new()
    event.keycode = code
    event.physical_keycode = code
    event.pressed = pressed
    Input.parse_input_event(event)
    await process_frame
    if pressed:
        event = event.duplicate()
        event.pressed = false
        Input.parse_input_event(event)
        await process_frame

func _look(at: Vector3) -> void:
    if failed:
        return
    var delta: Vector3 = at - eye.global_position
    var yaw: float = atan2(-delta.x, -delta.z)
    var pitch: float = atan2(delta.y, Vector2(delta.x, delta.z).length())
    var motion := InputEventMouseMotion.new()
    motion.relative = Vector2(-angle_difference(actor.rotation.y, yaw), -(pitch - eye.rotation.x)) / actor.look_sensitivity
    Input.parse_input_event(motion)
    await process_frame
    await process_frame

func _walk(at: Vector3) -> void:
    if failed:
        return
    at.y = eye.global_position.y
    await _look(at)
    var event := InputEventKey.new()
    event.keycode = KEY_W
    event.physical_keycode = KEY_W
    event.pressed = true
    Input.parse_input_event(event)
    var reached: bool = false
    for i in range(1100):
        var previous: Vector3 = actor.global_position
        await physics_frame
        walking_ticks += 1
        travelled += Vector2(actor.global_position.x - previous.x, actor.global_position.z - previous.z).length()
        if Vector2(actor.global_position.x - at.x, actor.global_position.z - at.z).length() < 0.28:
            reached = true
            break
    event = event.duplicate()
    event.pressed = false
    Input.parse_input_event(event)
    await process_frame
    if not reached:
        await _snap("blocked_walk")
        _fail("Could not walk to " + str(at) + "; stopped at " + str(actor.global_position))

func _inspect(at: Vector3, expected: String) -> void:
    if failed:
        return
    await _look(at)
    if game.focus_id != expected:
        await _snap("missing_focus")
        _fail("Expected visible target " + expected + ", got " + str(game.focus_id))
        return
    await _key(KEY_E)

func _click(label: String, exact: bool = false) -> void:
    if failed:
        return
    if rendered:
        RenderingServer.set_render_loop_enabled(true)
    await process_frame
    await process_frame
    var button: Button
    for child in game.modal.find_children("*", "Button", true, false):
        if child.text == label or (not exact and child.text.begins_with(label)):
            button = child
            break
    if button == null:
        _fail("Cannot find visible choice: " + label)
        return
    # Scroll with actual wheel events until the button fits the visible viewport.
    var visible_area: Rect2 = game.modal_stack.get_parent().get_global_rect().grow(1.0)
    for i in range(70):
        if visible_area.encloses(button.get_global_rect()):
            break
        var wheel := InputEventMouseButton.new()
        wheel.position = game.modal.get_global_rect().get_center()
        wheel.global_position = wheel.position
        wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
        wheel.pressed = true
        Input.parse_input_event(wheel)
        await process_frame
    if not visible_area.encloses(button.get_global_rect()):
        _fail("Cannot scroll choice into view: " + label)
        return
    # Use the same Tab/Enter path available to a player. This also verifies that
    # rebuilding a modal preserves meaningful keyboard navigation.
    for i in range(12):
        if get_root().gui_get_focus_owner() == button:
            break
        await _key(KEY_TAB)
    if get_root().gui_get_focus_owner() != button:
        _fail("Cannot reach choice with Tab: " + label)
        return
    await _key(KEY_ENTER)
    await process_frame
    if rendered:
        await RenderingServer.frame_post_draw
        RenderingServer.set_render_loop_enabled(false)
    print("PLAYER_CHOICE: " + label + "; modal=" + str(game.modal.visible) + "; tape=" + str(game.tape_step) + "; active=" + str(game.tape_active))

func _snap(name: String) -> void:
    if failed:
        return
    await process_frame
    await process_frame
    if rendered:
        RenderingServer.set_render_loop_enabled(true)
        for i in range(3):
            await process_frame
        await RenderingServer.frame_post_draw
        var frame: Image = get_root().get_texture().get_image()
        frame.save_png(OUT + "/" + name + ".png")
        RenderingServer.set_render_loop_enabled(false)
    var summary := {"stage": name, "zone": game.current_zone, "position": str(actor.global_position),
        "clues": game.collected.keys(), "objective": game.objective_label.text}
    stages.append(summary)
    print("PLAYER_STAGE: " + JSON.stringify(summary))

func _fail(reason: String) -> void:
    failed = true
    push_error("PLAYER_JOURNEY_FAILED: " + reason)
    quit(1)
