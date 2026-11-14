extends Node3D
## Case 01: 广播里的人 — investigation, dialogue, deduction. No combat.
const WorldBuilder = preload("res://scripts/world.gd")
const Ambience = preload("res://scripts/ambience.gd")
const Interviews = preload("res://scripts/interviews.gd")
const Interaction = preload("res://scripts/interaction.gd")
const Screenshots = preload("res://scripts/screenshots.gd")
const TapeSequence = preload("res://scripts/tape_sequence.gd")
const Landmarks = preload("res://scripts/landmarks.gd")
const CaseBoard = preload("res://scripts/case_board.gd")
const ConversationStage = preload("res://scripts/conversation_stage.gd")
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
    },
    "phone_whisper": {
        "name": "无人的公用电话",
        "text": "广播站的录音之后，公用电话竟然自己响了三声。听筒里没有语言，只有与林小禾录音同样的断续节拍。电话线已被剪断，柜体上仍贴着『九月起撤机』的旧告示。"
    },
    "school_register": {
        "name": "小学夜间交接簿",
        "text": "2003 年 7 月 17 日，暑期播音训练晚课于 20:30 结束。20:43，老师在交接簿上登记林小禾独自离校。21:10 发布寻人启事。交接簿能证明离校时间，无法说明之后谁跟她说过话。"
    },
    "school_notebook": {
        "name": "林小禾的练声簿",
        "text": "林小禾在广播练习本边缘写着：『我念完一句，机器里总有个声音比我慢一点；我停下，它还在接着念。』这只是孩子的记录，尚不能证实声音来自何处。"
    },
    "identity_check": {
        "name": "证据互证：名字与目击",
        "text": "学校交接簿记录她 7 月 17 日 20:43 离校，7 月 20 日小卖部账本却出现她的名字。吴婶指出记账来自隔门传来的自报姓名，没有任何人确认报名字的是林小禾本人。账本不能证明失踪者返回。"
    },
    "ledger_crosscheck": {
        "name": "账本与证词的互证",
        "text": "7 月 20 日账本确实记下了“林小禾”，但吴婶没有目击本人；写下名字的人只听见卷帘门外有人自报姓名。记录证明有人报出了名字，不能证明失踪者已回来。声音、名字与本人，必须分别核对。"
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
var save_path: String = "user://case01-save.json"
var persistence_enabled: bool = true
var focus_id: String = ""
var active_witness: String = ""

var layer: CanvasLayer
var hud: Control
var title_label: Label
var help_label: Label
var objective_label: Label
var prompt_label: Label
var crosshair: Label
var photo_notice: Label
var photo_busy: bool = false
var photo_notice_end: int = 0
var witness_panel_mode: bool = false
var tape_active: bool = false
var tape_step: int = -1
var modal: PanelContainer
var modal_stack: VBoxContainer
var navigation_label: Label
var guidance_enabled: bool = false
var conversation_stage = ConversationStage.new()

func _ready() -> void:
    # Layout follows the actual window, rather than a fixed 1280px canvas that
    # kept the wide conversation panel even in a physically narrow window.
    get_window().content_scale_size = Vector2i.ZERO
    get_window().min_size = Vector2i(640, 360)
    get_window().title = str(ProjectSettings.get_setting("application/config/name")) + " · v" + str(ProjectSettings.get_setting("application/config/version"))
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
    get_viewport().size_changed.connect(_resize_ui)
    tree_exiting.connect(conversation_stage.finish)
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
    help_label.text = "WASD 移动 · E/F 调查 · J 笔记 · H 方位提示 · F12 截图 · Esc 菜单"
    help_label.add_theme_font_size_override("font_size", 16)
    help_label.add_theme_color_override("font_color", Color(0.82, 0.82, 0.77))
    hud.add_child(help_label)
    photo_notice = Label.new()
    photo_notice.anchor_top = 1.0
    photo_notice.anchor_bottom = 1.0
    photo_notice.offset_left = 24.0
    photo_notice.offset_right = 940.0
    photo_notice.offset_top = -64.0
    photo_notice.offset_bottom = -22.0
    photo_notice.add_theme_font_size_override("font_size", 16)
    photo_notice.add_theme_color_override("font_color", Color(0.94, 0.86, 0.67))
    photo_notice.visible = false
    hud.add_child(photo_notice)
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
    navigation_label = Label.new()
    navigation_label.position = Vector2(24, 100)
    navigation_label.add_theme_font_size_override("font_size", 17)
    navigation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    navigation_label.add_theme_color_override("font_color", Color(0.81, 0.85, 0.75))
    navigation_label.visible = false
    hud.add_child(navigation_label)
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
    var half_height: float = minf(280.0, maxf(130.0, (view.y - 36.0) * 0.5))
    modal.anchor_left = 0.5
    modal.anchor_right = 0.5
    modal.offset_left = -half_width
    modal.offset_right = half_width
    if witness_panel_mode and view.x >= 1100.0:
        modal.anchor_left = 1.0
        modal.anchor_right = 1.0
        modal.offset_left = -minf(420.0, view.x * 0.36) - 22.0
        modal.offset_right = -22.0
    modal.offset_top = -half_height
    modal.offset_bottom = half_height
    modal.anchor_top = 0.5
    modal.anchor_bottom = 0.5
    if witness_panel_mode and view.x < 1100.0:
        modal.anchor_left = 0.0
        modal.anchor_right = 1.0
        modal.anchor_top = 1.0
        modal.anchor_bottom = 1.0
        modal.offset_left = 18.0
        modal.offset_right = -18.0
        modal.offset_top = -minf(350.0, view.y * 0.56)
        modal.offset_bottom = -18.0
    if modal_stack != null:
        modal_stack.custom_minimum_size.x = 0
    # Keep the objective away from the controls and title in smaller windows.
    help_label.offset_right = view.x - 24.0
    help_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    objective_label.offset_left = -minf(360.0, view.x - 48.0)
    objective_label.offset_top = 100.0 if view.x < 1100.0 else 20.0
    objective_label.offset_bottom = objective_label.offset_top + 64.0
    photo_notice.offset_right = view.x - 24.0
    photo_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    navigation_label.position.y = 158.0 if view.x < 1100.0 else 100.0
    navigation_label.size.x = view.x - 48.0
    title_label.visible = not modal.visible or view.x >= 1100.0

func _resize_ui() -> void:
    _layout_modal()
    conversation_stage.reframe()

func _begin_modal(heading: String, witness_panel: bool = false) -> VBoxContainer:
    if not witness_panel:
        conversation_stage.finish()
        _set_witness_speaking("")
    witness_panel_mode = witness_panel
    _layout_modal()
    for old in modal.get_children():
        modal.remove_child(old)
        old.queue_free()
    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 20)
    margin.add_theme_constant_override("margin_right", 20)
    margin.add_theme_constant_override("margin_top", 16)
    margin.add_theme_constant_override("margin_bottom", 16)
    modal.add_child(margin)
    var frame := VBoxContainer.new()
    frame.add_theme_constant_override("separation", 12)
    margin.add_child(frame)
    var header := HBoxContainer.new()
    frame.add_child(header)
    var title := Label.new()
    title.text = heading
    title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title.add_theme_font_size_override("font_size", 24 if witness_panel else 26)
    title.add_theme_color_override("font_color", Color(0.98, 0.83, 0.58))
    header.add_child(title)
    var close := Button.new()
    close.text = "×"
    close.tooltip_text = "关闭 · Esc"
    close.custom_minimum_size = Vector2(36, 36)
    close.focus_mode = Control.FOCUS_NONE
    close.add_theme_font_size_override("font_size", 26)
    close.pressed.connect(_close_modal)
    header.add_child(close)
    var stack := VBoxContainer.new()
    modal_stack = stack
    stack.add_theme_constant_override("separation", 14)
    stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var scroller := ScrollContainer.new()
    scroller.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroller.follow_focus = true
    scroller.size_flags_vertical = Control.SIZE_EXPAND_FILL
    frame.add_child(scroller)
    scroller.add_child(stack)
    modal.visible = true
    title_label.visible = get_viewport().get_visible_rect().size.x >= 1100.0
    help_label.visible = false
    objective_label.visible = false
    navigation_label.visible = false
    prompt_label.text = ""
    crosshair.visible = false
    player.can_move = false
    player.velocity = Vector3.ZERO
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
    button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    button.custom_minimum_size = Vector2(0, 42)
    button.add_theme_font_size_override("font_size", 18)
    parent.add_child(button)
    button.pressed.connect(callback)
    # Only the first button owns initial focus; arrows/Tab navigate the rest.
    var first_button: bool = true
    for sibling in parent.get_children():
        if sibling is Button and sibling != button:
            first_button = false
            break
    if first_button:
        button.grab_focus()
    return button

func _message(title: String, content: String) -> void:
    var stack := _begin_modal(title)
    _add_text(stack, content, 270)
    _add_button(stack, "继续", Callable(self, "_close_modal"))

func _close_modal() -> void:
    conversation_stage.finish()
    if tape_active:
        tape_active = false
        tape_step = -1
        ambience.stop_tape()
        _set_mood(collected.has("tape"))
    _set_witness_speaking("")
    modal.visible = false
    title_label.visible = true
    help_label.visible = true
    objective_label.visible = true
    crosshair.visible = true
    player.can_move = true
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _menu() -> void:
    var stack := _begin_modal("调查菜单")
    _add_button(stack, "继续调查", Callable(self, "_close_modal"))
    _add_button(stack, "调查笔记", Callable(self, "_journal"))
    _add_button(stack, "操作与方位提示", Callable(self, "_controls"))
    _add_button(stack, "重新开始调查", Callable(self, "_confirm_restart"))
    _add_button(stack, "退出游戏", func(): get_tree().quit())

func _controls() -> void:
    var stack := _begin_modal("操作与方位提示")
    _add_text(stack, "WASD 移动 · 鼠标观察 · Shift 快走\nE / F 调查准星前的物件 · J 调查笔记\nH 开关方位提示 · F12 截图 · Esc 关闭面板 / 调查菜单\n\n对话和笔记可以用鼠标滚轮翻页，也可以用 Tab / 方向键选择，Enter 确认。\n\n方位提示按当前调查进度显示方向与距离，可随时关闭。", 240)
    _add_button(stack, "关闭方位提示" if guidance_enabled else "开启方位提示", Callable(self, "_toggle_guidance"))
    _add_button(stack, "返回菜单", Callable(self, "_menu"))

func _toggle_guidance() -> void:
    guidance_enabled = not guidance_enabled
    _controls()

func _confirm_restart() -> void:
    var stack := _begin_modal("重新开始调查？")
    _add_text(stack, "本次线索与时间线会从镇口重新开始。上一份调查记录将保留为备份。", 130)
    _add_button(stack, "保留当前调查 · 返回菜单", Callable(self, "_menu"))
    _add_button(stack, "确认重新开始", Callable(self, "_restart_case"))

func _restart_case() -> void:
    if persistence_enabled and FileAccess.file_exists(save_path):
        var result: Error = DirAccess.copy_absolute(ProjectSettings.globalize_path(save_path), ProjectSettings.globalize_path(save_path + ".previous"))
        if result != OK:
            _message("暂时无法重新开始", "上一份记录未能备份，当前调查进度已保留。请稍后再试。")
            return
    collected.clear()
    finished = false
    _close_modal()
    _go_to("street", true)
    _save()
    _message("重新抵达 · 怀声镇", "你又站在镇口。左侧木告示栏上，寻人启事的印章仍然异常鲜红。\n\nWASD 移动，E 调查。需要方向时可以按 H，按 J 整理笔记。")

func _go_to(zone: String, initial: bool = false) -> void:
    conversation_stage.finish()
    if ambience != null:
        ambience.stop_tape()
    active_witness = ""
    focus_id = ""
    prompt_label.text = ""
    tape_active = false
    tape_step = -1
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
                    "shrine": spawn = Landmarks.SHRINE_RETURN
                    "school": spawn = Landmarks.SCHOOL_RETURN
            player.global_position = spawn
        _:
            player.global_position = Vector3(0, 1.01, 3.1)
    player.velocity = Vector3.ZERO
    player.safe_position = player.global_position
    player.rotation.y = 0
    if zone == "street" and previous == "shrine" and not initial:
        player.rotation.y = PI
    elif zone == "street" and previous in ["shop", "radio", "school"] and not initial:
        player.rotation.y = -PI * 0.5 if previous == "shop" else PI * 0.5
    eye.rotation = Vector3.ZERO
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
        if current_zone == "street":
            # Overcast blue hour, not a brightly sunlit procedural playground.
            atmosphere.environment.background_color = Color(0.16, 0.22, 0.25) if unstable else Color(0.23, 0.29, 0.30)
            atmosphere.environment.fog_light_color = Color(0.18, 0.24, 0.28) if unstable else Color(0.29, 0.34, 0.34)
            atmosphere.environment.fog_density = 0.018 if unstable else 0.009
            atmosphere.environment.ambient_light_energy = 0.34 if unstable else 0.43
        else:
            atmosphere.environment.background_color = Color(0.31, 0.37, 0.43) if unstable else Color(0.36, 0.43, 0.46)
            atmosphere.environment.fog_light_color = Color(0.37, 0.40, 0.45) if unstable else Color(0.46, 0.45, 0.42)
            atmosphere.environment.fog_density = 0.003
            atmosphere.environment.ambient_light_energy = 0.38
    if sunlight != null:
        if current_zone == "street":
            sunlight.light_energy = 0.24 if unstable else 0.43
            sunlight.light_color = Color(0.69, 0.80, 0.84)
        else:
            sunlight.light_energy = 0.12
            sunlight.light_color = Color(1.0, 0.78, 0.56)

func _update_objective() -> void:
    if objective_label == null:
        return
    if finished:
        objective_label.text = "时间线已确认 · 按 J 回看笔记"
        return
    if _ready_to_deduce():
        objective_label.text = "线索已齐 · 按 J 整理时间线并推理"
        return
    var count: int = _required_found()
    if current_zone == "shop" and not collected.has("ledger"):
        objective_label.text = "当前目标 · 柜台近侧，翻阅摊开的赊账簿"
    elif current_zone == "radio" and not collected.has("log"):
        objective_label.text = "当前目标 · 控制台左侧，阅读值班记录"
    elif current_zone == "radio" and not collected.has("tape"):
        objective_label.text = "当前目标 · 控制台右侧，监听旧录音"
    elif not collected.has("poster"):
        objective_label.text = "当前目标 · 镇口左侧，查看木告示栏"
    elif not collected.has("ledger"):
        objective_label.text = "当前目标 · 街道左侧，前往吉祥小卖部"
    elif not collected.has("log") or not collected.has("tape"):
        objective_label.text = "当前目标 · 街道右侧，前往旧广播站"
    else:
        objective_label.text = "关键线索 " + str(count) + " / 4"

func _update_location_label() -> void:
    var names := {"street": "怀声镇 · 镇中心", "shop": "吉祥小卖部", "radio": "旧广播站", "shrine": "怀声祠", "school": "怀声镇小学"}
    title_label.text = "旧梦乡 / " + names.get(current_zone, current_zone)
    if finished:
        title_label.text += "  ·  时间线已确认"

func _update_navigation() -> void:
    navigation_label.visible = guidance_enabled and not modal.visible
    if not navigation_label.visible:
        return
    var next: Dictionary = CaseBoard.guidance(current_zone, collected)
    if next.is_empty():
        navigation_label.text = "方位提示 · 按 J 整理时间线与证词 · H 关闭"
        return
    var delta: Vector3 = next["at"] - player.global_position
    var bearing: float = angle_difference(player.rotation.y, atan2(-delta.x, -delta.z))
    var direction: String = "前方"
    if absf(bearing) > PI * 0.72:
        direction = "身后"
    elif absf(bearing) > 0.40:
        direction = "左侧" if bearing > 0 else "右侧"
    var metres: int = int(ceil(Vector2(delta.x, delta.z).length()))
    navigation_label.text = str(next["name"]) + " · " + direction + "约 " + str(metres) + " 米 · H 关闭"

func _process(_delta: float) -> void:
    _update_navigation()
    if photo_notice != null and photo_notice.visible and Time.get_ticks_msec() >= photo_notice_end:
        photo_notice.visible = false
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
        if collected.has(focus_id):
            prompt_label.text += "  ·  已记录"

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_F12:
            _capture_photo()
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_ESCAPE:
            if modal.visible:
                _close_modal()
            else:
                _menu()
            get_viewport().set_input_as_handled()
        elif not modal.visible and event.keycode == KEY_J:
            _journal()
            get_viewport().set_input_as_handled()
        elif not modal.visible and event.keycode == KEY_H:
            guidance_enabled = not guidance_enabled
            get_viewport().set_input_as_handled()
        elif not modal.visible and event.keycode in [KEY_E, KEY_F] and focus_id != "":
            _interact(focus_id)
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseButton and event.pressed and not modal.visible:
        if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _capture_photo() -> void:
    if photo_busy:
        return
    photo_busy = true
    await RenderingServer.frame_post_draw
    var frame: Image = get_viewport().get_texture().get_image()
    var path: String = Screenshots.store(frame, current_zone,
        Time.get_datetime_string_from_system(), Time.get_ticks_msec())
    photo_busy = false
    photo_notice.visible = true
    photo_notice_end = Time.get_ticks_msec() + 4500
    if path == "":
        photo_notice.text = "截图保存失败：请检查用户目录写入权限"
    else:
        photo_notice.text = "截图已保存：" + path

func _interact(id: String) -> void:
    match id:
        "enter_shop": _go_to("shop")
        "enter_radio": _go_to("radio")
        "enter_shrine": _go_to("shrine")
        "enter_school": _go_to("school")
        "exit": _go_to("street")
        "npc_shop", "npc_radio": _interview(id)
        "public_phone": _inspect_phone()
        _: _investigate(id)

func _tape_intro() -> void:
    tape_active = false
    tape_step = -1
    var stack := _begin_modal("21:47 · 内线监听磁带")
    var opening: String = "桌上躺着一盘褪色的录音带。你摸到一行日期：2003.7.17。\n\n" + \
        "陈站长说：『只有值班室听得到。全镇喇叭是后来才开的。』\n\n" + \
        "磁带分为四段，你可逐段监听，或跳过演出直接记下时间线。"
    _add_text(stack, opening, 215.0)
    _add_button(stack, "按下播放键", Callable(self, "_tape_start"))
    _add_button(stack, "跳过演出 · 记录内容", Callable(self, "_tape_complete"))
    _add_button(stack, "暂不播放", Callable(self, "_close_modal"))

func _tape_start() -> void:
    tape_active = true
    tape_step = 0
    _show_tape_beat()

func _show_tape_beat() -> void:
    if not tape_active:
        return
    var beat: Dictionary = TapeSequence.beat(tape_step)
    if beat.is_empty():
        return
    var stack := _begin_modal("监听录音 · " + str(beat["clock"]))
    stack.add_theme_constant_override("separation", 10)
    _add_text(stack, str(beat["marker"]) + "\n\n" + str(beat["scene"]) + \
        "\n\n" + str(beat["caption"]), 165.0)
    var wave := HBoxContainer.new()
    wave.add_theme_constant_override("separation", 3)
    stack.add_child(wave)
    for i in range(30):
        var bar := ColorRect.new()
        bar.color = Color(0.73, 0.65, 0.45) if tape_step < 2 else Color(0.49, 0.73, 0.69)
        bar.custom_minimum_size = Vector2(5.0, 6.0 + float((i * 17 + tape_step * 11) % 14) * 2.0)
        bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        wave.add_child(bar)
    var stage_label: String = "监听进度  " + str(tape_step + 1) + " / " + str(TapeSequence.count())
    _add_text(stack, stage_label, 24.0)
    _add_button(stack, "记录线索并结束" if tape_step == TapeSequence.count() - 1 \
        else "继续监听", Callable(self, "_tape_next"))
    _add_button(stack, "停止播放 · 暂不记录", Callable(self, "_close_modal"))
    if tape_step >= 2:
        _set_mood(true)
    ambience.play_tape_stage(TapeSequence.cue(tape_step))

func _tape_next() -> void:
    if not tape_active:
        return
    if tape_step < TapeSequence.count() - 1:
        tape_step += 1
        _show_tape_beat()
    else:
        _tape_complete()

func _tape_complete() -> void:
    var was_new: bool = not collected.has("tape")
    _close_modal()
    if was_new:
        collected["tape"] = true
        _save()
        _update_objective()
        world.haunted = true
        world.build_zone(current_zone)
        _set_mood(true)
        ambience.play_radio_anomaly()
    var message: String = str(EVIDENCE["tape"]["text"])
    message += "\n\n21:47 是广播站的内线监听，不是对全镇的公开播报。"
    if not was_new:
        message += "\n\n（已收录至调查笔记 · 允许复听）"
    elif _ready_to_deduce():
        message += "\n\n四条关键线索已齐，按 J 打开笔记进行推理。"
    _message("磁带归档 · 21:47", message)

func _inspect_phone() -> void:
    if not collected.has("tape"):
        _message("镇中心 · 公用电话", "电话听筒冰凉，没有拨号音。机身上写着：『九月起撤机』。")
        return
    if not collected.has("phone_whisper"):
        collected["phone_whisper"] = true
        _save()
        ambience.play_radio_anomaly()
    _message("异常记录 · 没有接线的电话", str(EVIDENCE["phone_whisper"]["text"]))

func _set_witness_speaking(person: String) -> void:
    if world != null and active_witness != "":
        var old: Node = world.get_node_or_null("Witness_" + active_witness)
        if old != null:
            old.set("speaking", false)
    active_witness = person
    if world != null and person != "":
        var actor: Node = world.get_node_or_null("Witness_" + person)
        if actor != null:
            actor.set("speaking", true)

func _interview(person: String) -> void:
    if not Interviews.PEOPLE.has(person):
        return
    _set_witness_speaking(person)
    var actor: Node3D = world.get_node_or_null("Witness_" + person)
    if actor != null:
        conversation_stage.begin(actor, eye)
    var witness: Dictionary = Interviews.PEOPLE[person]
    var stack := _begin_modal(str(witness.get("short_name", witness["name"])), true)
    _add_text(stack, str(witness["intro"]), 80.0)
    for topic in witness["topics"]:
        var id: String = str(topic["id"])
        var question: String = str(topic["label"])
        if person == "npc_shop" and id == "ledger" and not collected.has("ledger"):
            question = "问：失踪以后，还有人来赊账吗？"
        elif person == "npc_radio" and id == "tape" and not collected.has("tape"):
            question = "问：那晚最早的声音从哪里来？"
        _add_button(stack, question, Callable(self, "_interview_topic").bind(person, id))
    _add_button(stack, "结束问话", Callable(self, "_close_modal"))

func _interview_topic(person: String, topic_id: String) -> void:
    if not Interviews.PEOPLE.has(person):
        return
    _set_witness_speaking(person)
    var witness: Dictionary = Interviews.PEOPLE[person]
    for topic in witness["topics"]:
        if str(topic["id"]) != topic_id:
            continue
        var clue: String = str(topic.get("evidence", ""))
        if clue != "" and EVIDENCE.has(clue) and not collected.has(clue):
            collected[clue] = true
            _save()
        var suffix: String = "\n\n（证词已收入调查笔记）" if clue != "" else ""
        var stack := _begin_modal(str(witness.get("short_name", witness["name"])), true)
        _add_text(stack, str(topic["text"]) + suffix, 120.0)
        _add_button(stack, "继续问话", Callable(self, "_interview").bind(person))
        _add_button(stack, "结束问话", Callable(self, "_close_modal"))
        return

func _investigate(id: String) -> void:
    if id == "tape":
        _tape_intro()
        return
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
    var stack := _begin_modal("调查笔记 · 时间线")
    _add_text(stack, "关键证据 " + str(_required_found()) + " / 4  ·  已记录 " + str(collected.size()) + " 条线索", 30)
    if _ready_to_deduce():
        _add_button(stack, "整理时间线 · 开始推理", Callable(self, "_deduction"))
    else:
        _add_text(stack, "还需调查：" + CaseBoard.missing(collected), 58)
    _add_button(stack, "查看证据摘录", Callable(self, "_journal_evidence"))
    if CaseBoard.can_crosscheck(collected):
        _add_button(stack, "回看账本互证" if collected.has("ledger_crosscheck") else "核对账本与证词", Callable(self, "_crosscheck"))
    elif collected.has("ledger"):
        _add_text(stack, "可选调查 · 账本的署名仍有疑点，向吴婶询问 7 月 20 日。", 58)
    if _can_corroborate():
        _add_button(stack, "回看小学互证" if collected.has("identity_check") else "对照小学交接簿与人证", Callable(self, "_corroboration"))
    _add_text(stack, CaseBoard.timeline(collected), 180)
    _add_button(stack, "返回调查", Callable(self, "_close_modal"))

func _journal_evidence() -> void:
    var stack := _begin_modal("调查笔记 · 证据摘录")
    _add_button(stack, "返回时间线", Callable(self, "_journal"))
    var evidence_list := VBoxContainer.new()
    evidence_list.add_theme_constant_override("separation", 10)
    evidence_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    stack.add_child(evidence_list)
    var discovered_count: int = 0
    for id in EVIDENCE.keys():
        if not collected.has(id):
            continue
        discovered_count += 1
        var item: Dictionary = EVIDENCE[id]
        _add_text(evidence_list, "【" + item["name"] + "】\n" + item["text"], 82)
    if discovered_count == 0:
        _add_text(evidence_list, "还没有收集任何线索。先调查街道上的寻人启事。", 100)
    _add_button(stack, "返回调查", Callable(self, "_close_modal"))

func _crosscheck(feedback: String = "") -> void:
    if not CaseBoard.can_crosscheck(collected):
        return
    var stack := _begin_modal("证词核对 · 姓名与本人")
    if feedback != "":
        _add_text(stack, feedback, 62)
    _add_text(stack, "账本上写着：7 月 20 日，林小禾赊购汽水。\n吴婶说：没有看见本人，是丈夫隔着卷帘门听人报了名字。\n\n这两条记录能够共同证明什么？", 150)
    _add_button(stack, "A. 林小禾本人在失踪三天后回来了", func(): _crosscheck_answer("A"))
    _add_button(stack, "B. 有人报出了她的名字，身份仍未确认", func(): _crosscheck_answer("B"))
    _add_button(stack, "C. 账本的日期一定写错了", func(): _crosscheck_answer("C"))
    _add_button(stack, "返回时间线", Callable(self, "_journal"))

func _crosscheck_answer(selection: String) -> void:
    if not CaseBoard.can_crosscheck(collected):
        return
    if selection != "B":
        _crosscheck("核对尚未成立 · 报出名字不等于本人在场；现有记录也不足以断言日期写错。")
        return
    var fresh: bool = not collected.has("ledger_crosscheck")
    collected["ledger_crosscheck"] = true
    if fresh:
        _save()
    var stack := _begin_modal("互证完成 · 名字不能证明身份")
    _add_text(stack, str(EVIDENCE["ledger_crosscheck"]["text"]), 200)
    _add_button(stack, "返回时间线", Callable(self, "_journal"))
    _add_button(stack, "返回调查", Callable(self, "_close_modal"))

func _can_corroborate() -> bool:
    return collected.has("school_register") and collected.has("ledger") and collected.has("shop_testimony")

func _corroboration() -> void:
    if not _can_corroborate():
        return
    var stack := _begin_modal("证词互证 · 7 月 20 日的小卖部")
    _add_text(stack,
        "20:43，林小禾被登记离开学校。\n21:10，寻人启事发布。\n7 月 20 日，账本出现她的名字。\n\n吴婶说，丈夫只隔着卷帘门听到对方自报姓名。\n\n这几份材料能够证明什么？", 185)
    _add_button(stack, "A. 账本证明林小禾三天后回过小卖部", func(): _corroboration_answer("A"))
    _add_button(stack, "B. 只有姓名记录，无法确认喊话者身份", func(): _corroboration_answer("B"))
    _add_button(stack, "返回调查笔记", Callable(self, "_journal"))

func _corroboration_answer(choice: String) -> void:
    if not _can_corroborate():
        return
    if choice != "B":
        _message("互证不成立",
            "账本是记账的证明，未必是目击的证明。吴婶甚至没有看到喊话的人。再核对一次“是谁记下名字”和“谁真正出现”。")
        return
    var first: bool = not collected.has("identity_check")
    collected["identity_check"] = true
    if first:
        _save()
    _update_objective()
    _message("证据互证完成", str(EVIDENCE["identity_check"]["text"]) +
        "\n\n结论已收入笔记。这一层疑点得到合理解释，但无法确认林小禾真正去了哪里。")

func _required_found() -> int:
    var n: int = 0
    for id in REQUIRED:
        if collected.has(id):
            n += 1
    return n

func _deduction(feedback: String = "") -> void:
    if not _ready_to_deduce():
        return
    var stack := _begin_modal("推理 · 时间不可能倒流")
    stack.add_theme_constant_override("separation", 10)
    if feedback != "":
        _add_text(stack, feedback, 58)
    _add_text(stack,
        "7 月 17 日的记录：\n21:10 报失踪 → 21:47 内线录音 → 22:16 全镇播报\n\n广播究竟扮演了什么角色？", 120)
    _add_button(stack, "A. 广播首次制造了模仿林小禾的声音", func(): _answer("A"))
    _add_button(stack, "B. 声音早已出现，广播只是将它传到了镇上", func(): _answer("B"))
    _add_button(stack, "C. 一切都是小卖部店主的恶作剧", func(): _answer("C"))
    _add_button(stack, "返回笔记", Callable(self, "_journal"))

func _answer(selection: String) -> void:
    if selection != "B":
        _deduction("推理尚未成立 · 21:47 的录音早于 22:16 的公开播报。请分清记录声音和传播声音，再试一次。")
        return
    finished = true
    ambience.play_last_call()
    _save()
    _update_location_label()
    _update_objective()
    var witness_note: String = ""
    if collected.has("shop_testimony") and collected.has("radio_testimony"):
        witness_note = "\n\n你还确认了两条容易被误读的证词：账本只能证明有人叫了小禾的名字，内线录音不等于全镇广播。"
    if collected.has("identity_check"):
        witness_note += "\n\n你核对了暑期播音训练的交接簿：20:30 下课、20:43 离校。那张三天后的赊账单，仍不是小禾回来的目击证明。"
    if collected.has("ledger_crosscheck"):
        witness_note += "\n\n你在账本署名旁画了一道铅笔线。门外的人会说她的名字，却始终没有人看见她的脸。"
    _message("尾声 · 广播之后",
        "你终于确定：广播并不是那段声音的起点。\n\n21:47，与小禾一样的声音已经出现在内线录音中。\n22:16，那段声音经广播传遍了怀声镇。\n\n" + _epilogue_setting() + "\n\n『调查结束了。可以回家了。』\n\n你没有回答。小禾去了哪里，门外又是谁，仍然没有答案。" + witness_note)

func _epilogue_setting() -> String:
    match current_zone:
        "radio": return "控制台的指示灯暗了一瞬。身后停播多年的喇叭里，传来与你一模一样的声音："
        "shop": return "柜台上的旧收音机忽然响了。没有人碰过旋钮，里面却传来与你一模一样的声音："
        "school": return "黑板前的旧喇叭忽然响了。空荡的教室里，传来与你一模一样的声音："
        "shrine": return "祠堂门外的喇叭忽然响了。隔着那道木门，你听见与你一模一样的声音："
        _: return "镇上的喇叭忽然响了。空荡的街道上，回荡着与你一模一样的声音："

func _save() -> void:
    if not persistence_enabled:
        return
    var save_data := {"found": collected.keys(), "finished": finished}
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(save_path.get_base_dir()))
    var file := FileAccess.open(save_path, FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify(save_data))
        file.close()

func _load_save() -> void:
    if not persistence_enabled or not FileAccess.file_exists(save_path):
        return
    var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(save_path))
    if not (data is Dictionary):
        return
    var saved: Variant = data.get("found", [])
    if saved is Array:
        for id in saved:
            if id is String and EVIDENCE.has(id):
                collected[id] = true
    # A truncated or hand-edited save cannot complete a case without its evidence.
    var completion: Variant = data.get("finished", false)
    finished = completion is bool and completion == true and _ready_to_deduce()
