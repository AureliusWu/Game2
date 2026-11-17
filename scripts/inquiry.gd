extends RefCounted
## Optional inference rules. Only discovered evidence can enter a pair.
const THREADS := {
    "broadcast": {
        "title": "声音出现与全镇传播", "requires": ["tape", "log"],
        "result": "broadcast_crosscheck",
        "question": "两份记录中的设备与时间，能够说明什么？",
        "choices": ["A. 公开广播制造了最初的声音", "B. 内线声音在前，全镇传播在后", "C. 两份记录足以确认说话者身份"],
        "correct": 1,
        "feedback": "比较记录时间与传播范围。录到声音，并不能确认声音属于谁。",
        "text": "21:47 的内线监听早于 22:16 的全镇播报。广播传播了声音，不能作为声音最初出现的起点；声音的主人仍未被确认。"
    },
    "identity": {
        "title": "名字与本人", "requires": ["ledger", "shop_testimony"],
        "result": "ledger_crosscheck",
        "question": "署名记录与守店人的证词，能够共同确认什么？",
        "choices": ["A. 林小禾在失踪后亲自到过店里", "B. 有人报了名字，没有人确认本人", "C. 日期写错是唯一解释"],
        "correct": 1, "feedback": "记账依据是隔门听见的姓名，缺少目击。不要把可能解释写成事实。",
        "text": "账本记录了姓名；吴婶的证词说明无人确认本人。姓名记录不能作为失踪者返回的证明。"
    },
    "origin": {
        "title": "练声与回声", "requires": ["school_notebook", "tape"],
        "result": "voice_boundary",
        "question": "练声簿与内线录音中的相似描述，能让调查前进到哪一步？",
        "choices": ["A. 已经证明机器里住着另一个人", "B. 已经证明小禾故意伪造录音", "C. 可以追查延迟复述，尚不能确认来源"],
        "correct": 2, "feedback": "相似现象构成继续追查的方向；孩子的文字和声音都没有提供来源鉴定。",
        "text": "练声簿描述停下后仍继续的复述，磁带记录了相似声音。两份材料提供了核查延迟复述的方向，尚不能证明来源、意图或说话者身份。"
    },
    "notice": {
        "title": "提醒与停播通知", "requires": ["broadcast_notice", "radio_testimony"],
        "result": "notice_crosscheck",
        "question": "书面停播通知与值班证词应如何使用？",
        "choices": ["A. 7 月 18 日正式停播，不能倒推当夜已收到正式禁令", "B. 7 月 17 日就有这张正式停播通知", "C. 停播通知证明异常声音来自祠堂"],
        "correct": 0, "feedback": "注意通知的日期和材料范围。手写提醒与正式停播通知需要分别核实。",
        "text": "正式停播通知标注 7 月 18 日。陈站长的内线证词对应 17 日夜的监听与公开播报，不能据此把正式禁令提前。手写提醒的来历仍需另行核查。"
    },
    "folklore": {
        "title": "禁忌与电话", "requires": ["ritual", "phone_whisper"],
        "result": "ritual_boundary",
        "question": "民俗残页与断线电话的异常节拍，能够支持哪种记录？",
        "choices": ["A. 念出全名必然招来某种东西", "B. 残页提供相关线索，尚不能证明异常的因果", "C. 祠堂里所有记载都已被电话证实"],
        "correct": 1, "feedback": "对应关系可以保留，但不能把禁忌当作已验证的因果规律。",
        "text": "封声残页提示名字、声音与身份的关系；断线电话出现相似节拍。两者值得并置调查，但没有证据证明禁忌能够造成、阻止或解释异常。"
    }
}

const FOLLOWUPS := {
    "npc_shop": [
        {"id": "ledger", "requires": ["ledger"], "result": "shop_door_account",
         "label": "出示账本 · 谁把名字记了下来？",
         "text": "吴婶把账本翻到折角。『是我丈夫写的。我只听他第二天说起，没有隔着门跟那孩子说过话。』\n\n她用指甲压住名字：『字是他的，来的人是谁，我不能替他作证。』"},
        {"id": "calendar", "requires": ["calendar", "shop_testimony"], "result": "calendar_testimony",
         "label": "出示日历 · 背面的留言是谁写的？",
         "text": "『这句话我认得，字却不敢认。』吴婶没有接过挂历。『我没见她写，也没见有人把它挂回去。别替我说是小禾留的。』\n\n留言的作者、写下日期与“回家”的含义，仍无法确认。"}
    ],
    "npc_radio": [
        {"id": "school_notebook", "requires": ["school_notebook", "tape"], "result": "practice_testimony",
         "label": "出示练声簿 · 机器会慢半句吗？",
         "text": "陈站长反复看着边角的铅笔字。『训练时会回放，让孩子听自己的咬字。可停下来以后还在念……我没在教室亲耳听过。』\n\n他能说明训练方式，不能验证小禾记下的那一次现象。"},
        {"id": "broadcast_notice", "requires": ["broadcast_notice", "radio_testimony"], "result": "notice_testimony",
         "label": "出示停播通知 · 当夜提醒和次日通知？",
         "text": "『别混成一张。十七日夜里是没盖章的手写提醒，十八日才送来墙上这张正式通知。』\n\n『手写纸后来不见了。我说有过它，只是我的证词；你手里能核对日期的是这张通知。』"}
    ]
}

static func has_all(found: Dictionary, ids: Array) -> bool:
    for id in ids:
        if not found.has(id):
            return false
    return true

static func valid_pair(thread: String, pair: Array, found: Dictionary) -> bool:
    if not THREADS.has(thread) or pair.size() != 2 or pair[0] == pair[1]:
        return false
    var needed: Array = THREADS[thread]["requires"]
    return has_all(found, pair) and needed.has(pair[0]) and needed.has(pair[1])

static func resolve(thread: String, pair: Array, choice: int, found: Dictionary) -> String:
    if not valid_pair(thread, pair, found) or choice != THREADS[thread]["correct"]:
        return ""
    return str(THREADS[thread]["result"])

static func followup(person: String, id: String, found: Dictionary) -> Dictionary:
    for item in FOLLOWUPS.get(person, []):
        if item["id"] == id and has_all(found, item["requires"]):
            return item
    return {}

static func is_material(id: String) -> bool:
    return id in ["poster", "ledger", "log", "tape", "ritual", "calendar", "broadcast_notice",
        "tablet", "shop_testimony", "radio_testimony", "town_echo", "phone_whisper",
        "school_register", "school_notebook"]

static func leads(found: Dictionary) -> String:
    var lines: Array[String] = []
    if not found.has("poster"):
        lines.append("镇口 · 木告示栏上留有一份寻人记录。")
    if not found.has("ledger") or not found.has("calendar"):
        lines.append("小卖部 · 柜台账本与墙上日历可分别检查。")
    if not found.has("shop_testimony"):
        lines.append("小卖部 · 问吴婶失踪之后是否有人来赊账。")
    if not found.has("log") or not found.has("tape") or not found.has("broadcast_notice"):
        lines.append("广播站 · 检查控制台记录、磁带与墙上通知。")
    if not found.has("radio_testimony"):
        lines.append("广播站 · 请陈站长说明内线设备和公开播报。")
    if not found.has("school_register") or not found.has("school_notebook"):
        lines.append("镇小学 · 教室的交接簿与练习本仍可调查。")
    if not found.has("ritual"):
        lines.append("祠堂 · 桌上的残页可帮助理解当地的说法。")
    if found.has("tape") and not found.has("phone_whisper"):
        lines.append("镇中心 · 回到公用电话旁，核查听到的动静。")
    for person in FOLLOWUPS:
        for item in FOLLOWUPS[person]:
            if has_all(found, item["requires"]) and not found.has(item["result"]):
                lines.append(("吴婶 · " if person == "npc_shop" else "陈站长 · ") + item["label"])
    if lines.is_empty():
        return "可发现材料与追问均已记录。回到关联板核查结论；失踪者去向仍待后续调查。"
    return "\n\n".join(lines)

static func dossier(found: Dictionary, finished: bool) -> String:
    var lines: Array[String] = ["【已确认】"]
    lines.append("广播传播了此前已出现的声音。" if finished else "主线时间关系仍待整理。")
    for thread in THREADS.values():
        if found.has(thread["result"]):
            lines.append(thread["text"])
    lines.append("\n【材料与证词】")
    lines.append("已记录 %d / 4 条出示材料后的补充证词。" % followup_count(found))
    lines.append("\n【仍待核查】\n林小禾的去向、异常声音的来源，以及相似声音背后是否是同一个人，仍未得到证明。" if finished else "从镇口记录开始，分别检查实物与证词，再建立关联。")
    return "\n\n".join(lines)

static func followup_count(found: Dictionary) -> int:
    var count: int = 0
    for items in FOLLOWUPS.values():
        for item in items:
            if found.has(item["result"]):
                count += 1
    return count
