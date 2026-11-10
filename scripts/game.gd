extends Node3D
## Case 01: 广播里的人 — investigation, dialogue, deduction. No combat.
const WorldBuilder = preload("res://scripts/world.gd")
const Ambience = preload("res://scripts/ambience.gd")
const Interviews = preload("res://scripts/interviews.gd")
const Interaction = preload("res://scripts/interaction.gd")
const EVIDENCE := {
    "poster": {
        "name": "寻人启事",
        "text": "2003 年 7 月 17 日，21:10。林小禾，女，11 岁，于镇小学放学后失踪。告示右下角的印章颜色异常新。"
    },
    "ledger": {
        "name": "小卖部账本",
        "text": "7 月 20 日，林小禾赊购汽水一瓶。日期比寻人启事晚三天。字迹与其他记录相同。"
    },
    "log": {
        "name": "广播站值班日志",
        "text": "2003 年 7 月 17 日，22:16。临时播报寻人启事。值班员写着：播完以后，镇上有人敲门。"
    },
    "tape": {
        "name": "21:47 的录音",
        "text": "一盘标注 21:47 的旧磁带上，清晰地录着林小禾的声音：『有人替我回家了。』录音比 22:16 的寻人广播更早。"
    },
    "ritual": {
        "name": "封声残页",
        "text": "地方仪式的残本记载：夏夜封声，不呼全名，不以铜喉代人传名。后有批注：『它记下声，却不识人。』"
    },
    "calendar": {
        "name": "小卖部旧日历",
        "text": "撕到 2003 年七月的挂历还在墙上，背面写着：『小禾说她已经回家了，不要再找她。』墨迹看起来不像二十多年前留下的。"
    },
    "broadcast_notice": {
        "name": "广播站停播通知",
        "text": "镇广播站在 2003 年 7 月 18 日接到停播通知：『午夜起禁止寻人广播，禁止连续三次宣读同一姓名。』通知上的签字无法辨认。"
    },
    "tablet": {
        "name": "无名牌位",
        "text": "祠堂正中的牌位没有姓氏，只有两个深浅不同的刻痕。香灰沿桌边排成整齐的线，像有人在数经过这里的声音。"
    },
    "shop_testimony": {
        "name": "吴婶的证词",
        "text": "7 月 20 日小卖部账本上的林小禾，是吴婶丈夫隔着卷帘门听人报出的名字。吴婶没有看见小禾本人。姓名记录不等于在场证明。"
    },
    "radio_testimony": {
        "name": "陈站长的证词",
        "text": "21:47 听到的是广播站内线监听设备的声音，当时没有对全镇播放。22:16 才正式播报寻人启事；这两个时间对应不同事件。"
    },
    "town_echo": {
        "name": "镇中心的回声",
        "text": "从广播站回到街上时，原本空荡的巷口响起三次敲门声。广播喇叭没有接电，却传来一句：『怀声镇的乡亲，请不要回答。』声音与录音内的异常节奏一致。"
    ,
    "phone_whisper": {
        "name": "无人的公用电话",
        "text": "广播站的录音之后，公用电话竟然自己响了三声。听筒里没有语言，只有与林小禾录音同样的断续节拍。电话线已被剪断，柜体上仍贴着『九月起撤机』的旧告示。"
    }
}
const REQUIRED := ["poster", "ledger", "log", "tape"]

@onready var player: CharacterBody3D = $Player
@onready var eye: Camera3D = $Player/Camera3D

var world
var ambience
var current_zone: String = "street"
var collected: Dictionary = {}
var finished: bool = false
var focus_id: String = ""

var layer: CanvasLayer
var hud: Control
var title_label: Label
var help_label: Label
var objective_label: Label
var prompt_label: Label
var crosshair: Label
var modal: PanelContainer

func _ready() -> void:
    _load_save()
    _setup_lighting()
    world = WorldBuilder.new()
    world.name = "World"
    add_child(world)
    ambience = Ambience.new()
    ambience.name = "Ambience"
    add_child(ambience)
    _create_ui()
    _go_to("street", true)
    get_viewport().size_changed.connect(_layout_modal)
    if finished:
        _message("《旧梦乡》· 广播里的人",
            "你已经揭开了这起案件的第一层矛盾。\n\n档案与线索仍然保留。按 J 可以重新阅读调查笔记。")
    else:
        _message("《旧梦乡》· 广播里的人",
            "2026 年夏，你收到一盘写有『2003.7.17』的磁带。\n\n磁带中播放着一则寻人启事。录音结束前，有人用你的声音说：『回来看看。』\n\n你来到怀声镇。街道与二十三年前一模一样。\n\n调查那则寻人广播，弄清当年究竟发生了什么。")

func _setup_lighting() -> void:
    var environment := WorldEnvironment.new()
    environment.name = "WorldEnvironment"
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.36, 0.43, 0.46)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.75, 0.74, 0.66)
    env.ambient_light_energy = 0.55
    env.fog_enabled = true
    env.fog_light_color = Color(0.46, 0.45, 0.42)
    env.fog_density = 0.009
    environment.environment = env
    add_child(environment)
    var sunlight := DirectionalLight3D.new()
    sunlight.name = "Sunlight"
    sunlight.rotation_degrees = Vector3(-45.0, -24.0, 0.0)
    sunlight.light_color = Color(1.0, 0.78, 0.56)
    sunlight.light_energy = 0.9
    sunlight.shadow_enabled = true
    add_child(sunlight)

func _create_ui() -> void:
    layer = CanvasLayer.new()
    add_child(layer)
    hud = Control.new()
    hud.set_anchors_preset(Control.PRESET_FULL_RECT)
    hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(hud)
    title_label = Label.new()
    title_label.position = Vector2(22, 18)
    title_label.add_theme_font_size_override("font_size", 24)
    title_label.add_theme_color_override("font_color", Color(0.98, 0.88, 0.67))
    hud.add_child(title_label)
    help_label = Label.new()
    help_label.position = Vector2(24, 58)
    help_label.text = "WASD 移动 · 鼠标观察 · Shift 快走 · E/F 调查 · J 笔记 · Esc 退出界面"
    help_label.add_theme_font_size_override("font_size", 16)
    help_label.add_theme_color_override("font_color", Color(0.82, 0.82, 0.77))
    hud.add_child(help_label)
    objective_label = Label.new()
    objective_label.anchor_left = 1.0
    objective_label.anchor_right = 1.0
    objective_label.offset_left = -380.0
    objective_label.offset_right = -25.0
    objective_label.offset_top = 20.0
    objective_label.offset_bottom = 84.0
    objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    objective_label.add_theme_font_size_override("font_size", 17)
    objective_label.add_theme_color_override("font_color", Color(0.96, 0.82, 0.60))
    hud.add_child(objective_label)
    crosshair = Label.new()
    crosshair.text = "·"
    crosshair.set_anchors_preset(Control.PRESET_CENTER)
    crosshair.offset_left = -6
    crosshair.offset_top = -14
    crosshair.add_theme_font_size_override("font_size", 30)
    crosshair.add_theme_color_override("font_color", Color(0.96, 0.82, 0.51))
    hud.add_child(crosshair)
    prompt_label = Label.new()
    prompt_label.anchor_left = 0.2
    prompt_label.anchor_right = 0.8
    prompt_label.anchor_top = 0.85
    prompt_label.anchor_bottom = 0.95
    prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    prompt_label.add_theme_font_size_override("font_size", 24)
    prompt_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.71))
    hud.add_child(prompt_label)
    modal = PanelContainer.new()
    modal.anchor_left = 0.5
    modal.anchor_top = 0.5
    modal.anchor_right = 0.5
    modal.anchor_bottom = 0.5
    modal.offset_left = -350
    modal.offset_top = -240
    modal.offset_right = 350
    modal.offset_bottom = 240
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.085, 0.11, 0.13, 0.97)
    style.border_color = Color(0.55, 0.49, 0.35, 0.85)
    style.set_border_width_all(2)
    style.set_corner_radius_all(7)
    modal.add_theme_stylebox_override("panel", style)
    modal.visible = false
    layer.add_child(modal)
    _layout_modal()

func _layout_modal() -> void:
    if modal == null:
        return
    var view: Vector2 = get_viewport().get_visible_rect().size
    var half_width: float = minf(350.0, maxf(160.0, (view.x - 36.0) * 0.5))
    var half_height: float = minf(240.0, maxf(130.0, (view.y - 36.0) * 0.5))
    modal.offset_left = -half_width
    modal.offset_right = half_width
    modal.offset_top = -half_height
    modal.offset_bottom = half_height

func _begin_modal(heading: String) -> VBoxContainer:
    for old in modal.get_children():
        old.queue_free()
    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 24)
    margin.add_theme_constant_override("margin_right", 24)
    margin.add_theme_constant_override("margin_top", 22)
    margin.add_theme_constant_override("margin_bottom", 20)
    modal.add_child(margin)
    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 14)
    var scroller := ScrollContainer.new()
    scroller.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroller.size_flags_vertical = Control.SIZE_EXPAND_FILL
    margin.add_child(scroller)
    stack.custom_minimum_size = Vector2(maxf(240.0, modal.offset_right - modal.offset_left - 85.0), 0)
    scroller.add_child(stack)
    var title := Label.new()
    title.text = heading
    title.add_theme_font_size_override("font_size", 28)
    title.add_theme_color_override("font_color", Color(0.98, 0.83, 0.58))
    stack.add_child(title)
    modal.visible = true
    player.can_move = false
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    return stack

func _add_text(parent: Node, value: String, minimum_height: float = 140.0) -> Label:
    var label := Label.new()
    label.text = value
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
    label.custom_minimum_size = Vector2(0, minimum_height)
    label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    label.add_theme_font_size_override("font_size", 19)
    label.add_theme_color_override("font_color", Color(0.85, 0.87, 0.83))
    parent.add_child(label)
    return label

func _add_button(parent: Node, name: String, callback: Callable) -> Button:
    var button := Button.new()
    button.text = name
    button.custom_minimum_size = Vector2(0, 42)
    button.add_theme_font_size_override("font_size", 18)
    parent.add_child(button)
    button.pressed.connect(callback)
    return button

func _message(title: String, content: String) -> void:
    var stack := _begin_modal(title)
    _add_text(stack, content, 270)
    _add_button(stack, "继续", Callable(self, "_close_modal"))

func _close_modal() -> void:
    modal.visible = false
    player.can_move = true
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _go_to(zone: String, initial: bool = false) -> void:
    var previous: String = current_zone
    current_zone = zone
    world.haunted = collected.has("tape")
    world.build_zone(zone)
    _set_mood(world.haunted)
    ambience.play_zone(zone)
    match zone:
        "street":
            var spawn := Vector3(0, 1.01, 18)
            if not initial:
                match previous:
                    "shop": spawn = Vector3(-3.4, 1.01, 4)
                    "radio": spawn = Vector3(3.4, 1.01, -8)
                    "shrine": spawn = Vector3(0, 1.01, -24)
            player.global_position = spawn
        _:
            player.global_position = Vector3(0, 1.01, 3.1)
    player.velocity = Vector3.ZERO
    player.rotation.y = 0
    eye.rotation.x = 0
    _update_location_label()
    _update_objective()
    # The first return to town after hearing the private recording is a quiet, one-shot anomaly.
    if not initial and zone == "street" and collected.has("tape") and not collected.has("town_echo"):
        collected["town_echo"] = true
        _save()
        ambience.play_radio_anomaly()
        _message("异常记录 · 失声的广播", str(EVIDENCE["town_echo"]["text"]))

func _set_mood(unstable: bool) -> void:
    var atmosphere := get_node_or_null("WorldEnvironment") as WorldEnvironment
    var sunlight := get_node_or_null("Sunlight") as DirectionalLight3D
    if atmosphere != null and atmosphere.environment != null:
        atmosphere.environment.background_color = Color(0.31, 0.37, 0.43) if unstable else Color(0.36, 0.43, 0.46)
        atmosphere.environment.fog_light_color = Color(0.37, 0.40, 0.45) if unstable else Color(0.46, 0.45, 0.42)
        atmosphere.environment.fog_density = 0.016 if unstable else 0.009
    if sunlight != null:
        sunlight.light_energy = 0.49 if unstable else 0.9

func _update_objective() -> void:
    if objective_label == null:
        return
    if finished:
        objective_label.text = "第一案已结 · 按 J 回看笔记"
        return
    if _ready_to_deduce():
        objective_label.text = "线索已齐 · 按 J 整理时间线并推理"
        return
    var count: int = _required_found()
    if not collected.has("poster"):
        objective_label.text = "当前目标 · 寻找镇口的寻人启事"
    elif not collected.has("ledger"):
        objective_label.text = "当前目标 · 查看小卖部账本"
    elif not collected.has("log") or not collected.has("tape"):
        objective_label.text = "当前目标 · 调查旧广播站"
    else:
        objective_label.text = "关键线索 " + str(count) + " / 4"

func _update_location_label() -> void:
    var names := {"street": "怀声镇 · 镇中心", "shop": "吉祥小卖部", "radio": "旧广播站", "shrine": "怀声祠"}
    title_label.text = "旧梦乡 / " + names.get(current_zone, current_zone)
    if finished:
        title_label.text += "  ·  第一案已结"

func _process(_delta: float) -> void:
    if modal.visible:
        prompt_label.text = ""
        focus_id = ""
        return
    focus_id = ""
    prompt_label.text = ""
    if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
        return
    var selected: Dictionary = Interaction.choose(eye, world.hotspots, get_world_3d().direct_space_state)
    if not selected.is_empty():
        focus_id = str(selected["id"])
        prompt_label.text = "[ E ]  " + str(selected["name"])

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE:
            if modal.visible:
                _close_modal()
            elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
                Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
            else:
                Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
            get_viewport().set_input_as_handled()
        elif not modal.visible and event.keycode == KEY_J:
            _journal()
            get_viewport().set_input_as_handled()
        elif not modal.visible and event.keycode in [KEY_E, KEY_F] and focus_id != "":
            _interact(focus_id)
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseButton and event.pressed and not modal.visible:
        if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _interact(id: String) -> void:
    match id:
        "enter_shop": _go_to("shop")
        "enter_radio": _go_to("radio")
        "enter_shrine": _go_to("shrine")
        "exit": _go_to("street")
        "npc_shop", "npc_radio": _interview(id)
        "public_phone": _inspect_phone()
        _: _investigate(id)

func _inspect_phone() -> void:
    if not collected.has("tape"):
        _message("镇中心 · 公用电话", "电话听筒冰凉，没有拨号音。机身上写着：『九月起撤机』。")
        return
    if not collected.has("phone_whisper"):
        collected["phone_whisper"] = true
        _save()
        ambience.play_radio_anomaly()
    _message("异常记录 · 没有接线的电话", str(EVIDENCE["phone_whisper"]["text"]))

func _interview(person: String) -> void:
    if not Interviews.PEOPLE.has(person):
        return
    var witness: Dictionary = Interviews.PEOPLE[person]
    var stack := _begin_modal("问话 · " + str(witness["name"]))
    _add_text(stack, str(witness["intro"]), 155.0)
    for topic in witness["topics"]:
        var id: String = str(topic["id"])
        _add_button(stack, str(topic["label"]), Callable(self, "_interview_topic").bind(person, id))
    _add_button(stack, "结束问话", Callable(self, "_close_modal"))

func _interview_topic(person: String, topic_id: String) -> void:
    if not Interviews.PEOPLE.has(person):
        return
    var witness: Dictionary = Interviews.PEOPLE[person]
    for topic in witness["topics"]:
        if str(topic["id"]) != topic_id:
            continue
        var clue: String = str(topic.get("evidence", ""))
        if clue != "" and EVIDENCE.has(clue) and not collected.has(clue):
            collected[clue] = true
            _save()
        var suffix: String = "\n\n（新证词已收入调查笔记）" if clue != "" else ""
        var stack := _begin_modal(str(witness["name"]))
        _add_text(stack, str(topic["text"]) + suffix, 240.0)
        _add_button(stack, "继续问话", Callable(self, "_interview").bind(person))
        _add_button(stack, "结束问话", Callable(self, "_close_modal"))
        return

func _investigate(id: String) -> void:
    if not EVIDENCE.has(id):
        return
    var first_time: bool = not collected.has(id)
    collected[id] = true
    if first_time:
        _save()
    _update_objective()
    if first_time and id == "tape":
        world.haunted = true
        world.build_zone(current_zone)
        _set_mood(true)
        ambience.play_radio_anomaly()
    var data: Dictionary = EVIDENCE[id]
    var message: String = data["text"]
    if not first_time:
        message += "\n\n（已收录至调查笔记）"
    elif _ready_to_deduce():
        message += "\n\n关键时间线已齐全。按 J 打开笔记，可以开始第一次推理。"
    _message(str(data["name"]), message)

func _ready_to_deduce() -> bool:
    for id in REQUIRED:
        if not collected.has(id):
            return false
    return true

func _journal() -> void:
    var stack := _begin_modal("调查笔记 · 广播里的人")
    var scroller := ScrollContainer.new()
    scroller.custom_minimum_size = Vector2(0, 295)
    scroller.size_flags_vertical = Control.SIZE_EXPAND_FILL
    stack.add_child(scroller)
    var evidence_list := VBoxContainer.new()
    evidence_list.add_theme_constant_override("separation", 10)
    evidence_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroller.add_child(evidence_list)
    var discovered_count: int = 0
    for id in EVIDENCE.keys():
        if not collected.has(id):
            continue
        discovered_count += 1
        var item: Dictionary = EVIDENCE[id]
        _add_text(evidence_list, "【" + item["name"] + "】\n" + item["text"], 82)
    if discovered_count == 0:
        _add_text(evidence_list, "还没有收集任何线索。先调查街道上的寻人启事。", 100)
    if _ready_to_deduce():
        _add_button(stack, "整理时间线 · 开始推理", Callable(self, "_deduction"))
    else:
        _add_text(stack, "关键证据：" + str(_required_found()) + " / 4  ·  继续调查小卖部和广播站", 30)
    _add_button(stack, "返回调查", Callable(self, "_close_modal"))

func _required_found() -> int:
    var n: int = 0
    for id in REQUIRED:
        if collected.has(id):
            n += 1
    return n

func _deduction() -> void:
    if not _ready_to_deduce():
        return
    var stack := _begin_modal("推理 · 时间不可能倒流")
    _add_text(stack,
        "已确认：\n· 林小禾于 7 月 17 日 21:10 被报失踪。\n· 磁带在 21:47 录到了她的声音。\n· 寻人广播直到 22:16 才播出。\n\n问题：广播究竟扮演了什么角色？", 200)
    _add_button(stack, "A. 广播首次制造了模仿林小禾的声音", func(): _answer("A"))
    _add_button(stack, "B. 声音早已出现，广播只是将它传到了镇上", func(): _answer("B"))
    _add_button(stack, "C. 一切都是小卖部店主的恶作剧", func(): _answer("C"))
    _add_button(stack, "返回笔记", Callable(self, "_journal"))

func _answer(selection: String) -> void:
    if selection != "B":
        _message("推理尚未成立",
            "请重新比对录音时间与广播时间。要分清『第一次记录到声音』和『把声音传播给其他人』。")
        return
    finished = true
    ambience.play_last_call()
    _save()
    _update_location_label()
    _update_objective()
    var witness_note: String = ""
    if collected.has("shop_testimony") and collected.has("radio_testimony"):
        witness_note = "\n\n你还确认了两条容易被误读的证词：账本只能证明有人叫了小禾的名字，内线录音不等于全镇广播。"
    _message("第一案 · 尾声",
        "你终于确定：广播并不是模仿者诞生的起点。\n\n21:47，有人已经在模仿林小禾。\n22:16，那段声音经广播传遍了怀声镇。\n\n广播站的电源突然熄灭。\n你从身后的喇叭听见自己的声音：\n\n『调查结束了。可以回家了。』\n\n—— 第一案原型完成。真正的失踪之谜仍未揭开。" + witness_note)

func _save() -> void:
    var save_data := {"found": collected.keys(), "finished": finished}
    var file := FileAccess.open("user://case01-save.json", FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify(save_data))
        file.close()

func _load_save() -> void:
    if not FileAccess.file_exists("user://case01-save.json"):
        return
    var data: Variant = JSON.parse_string(FileAccess.get_file_as_string("user://case01-save.json"))
    if not (data is Dictionary):
        return
    var saved: Variant = data.get("found", [])
    if saved is Array:
        for id in saved:
            if EVIDENCE.has(id):
                collected[id] = true
    finished = bool(data.get("finished", false))
