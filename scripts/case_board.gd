extends RefCounted
## Present only discovered facts. The notebook never invents a timestamp or eyewitness.
const Landmarks = preload("res://scripts/landmarks.gd")
const REQUIRED_NAMES := {
    "poster": "镇口的寻人启事", "ledger": "小卖部赊账簿",
    "log": "广播站值班记录", "tape": "广播站旧录音"
}

static func missing(found: Dictionary) -> String:
    var names: Array[String] = []
    for id in REQUIRED_NAMES:
        if not found.has(id):
            names.append(REQUIRED_NAMES[id])
    return "、".join(names)

static func timeline(found: Dictionary) -> String:
    var lines: Array[String] = ["2003 年 7 月 17 日"]
    lines.append("21:10 · 林小禾被报失踪【寻人启事】" if found.has("poster") else "待调查 · 镇口的失踪记录")
    lines.append("21:47 · 内线录到与小禾一样的声音【磁带】" if found.has("tape") else "待调查 · 广播站的内线录音")
    lines.append("22:16 · 寻人启事向全镇播出【值班记录】" if found.has("log") else "待调查 · 全镇播报的时间")
    if found.has("ledger"):
        lines.append("\n2003 年 7 月 20 日")
        lines.append("有人报出小禾的名字赊账；没有目击本人【已互证】" if found.has("ledger_crosscheck") else "账本出现小禾的名字；是否本人到店，仍需核对")
    return "\n".join(lines)

static func can_crosscheck(found: Dictionary) -> bool:
    return found.has("ledger") and found.has("shop_testimony")

static func guidance(zone: String, found: Dictionary) -> Dictionary:
    if missing(found).is_empty():
        return {}
    match zone:
        "shop":
            return {"at": Landmarks.SHOP_LEDGER, "name": "柜台近侧的赊账簿"} if not found.has("ledger") else {"at": Landmarks.SHOP_EXIT, "name": "返回街道的门"}
        "radio":
            if not found.has("log"):
                return {"at": Landmarks.RADIO_LOG, "name": "控制台左侧的值班记录"}
            return {"at": Landmarks.RADIO_TAPE, "name": "控制台右侧的播放键"} if not found.has("tape") else {"at": Landmarks.RADIO_EXIT, "name": "返回街道的门"}
        "shrine":
            return {"at": Vector3(0, 1.25, 4.4), "name": "返回街道的门"}
        _:
            if not found.has("poster"):
                return {"at": Vector3(-4.55, 1.3, 12), "name": "镇口左侧木告示栏"}
            if not found.has("ledger"):
                return {"at": Landmarks.SHOP_DOOR, "name": "街道左侧的吉祥小卖部"}
            return {"at": Landmarks.RADIO_DOOR, "name": "街道右侧的旧广播站"}
