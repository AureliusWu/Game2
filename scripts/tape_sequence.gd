extends RefCounted
## Scripted four-beat recording sequence. Text is original fiction; audio is generated at runtime.
## The 21:47 source is a private monitor, not the 22:16 public broadcast.
const BEATS := [
    {
        "clock": "21:47:00",
        "marker": "磁带起转",
        "scene": "按钮按下。电机缓慢咬住磁带，塑料外壳轻轻振动。\n监听机的红灯没有亮，墙上却有一块暗影移开了。",
        "caption": "【旧磁带 · 内线监听】",
        "sound": "tape_leader"
    },
    {
        "clock": "21:47:08",
        "marker": "无主来电",
        "scene": "背景传来细小的断续电流声。值班日志没有记录呼叫者。\n这段声音只进入了广播站的监听线路。",
        "caption": "【沙沙……滋……线路接通】",
        "sound": "tape_line"
    },
    {
        "clock": "21:47:19",
        "marker": "借来的声音",
        "scene": "磁带里的声音清澈、稚嫩，像极了寻人启事里的林小禾。\n但没有人能证明说话者就是她。",
        "caption": "【文字转录】\n『有人替我回家了。』",
        "sound": "tape_echo"
    },
    {
        "clock": "21:47:26",
        "marker": "留白",
        "scene": "话音停下。磁带还在转。\n窗外原本亮着的日光灯暗了片刻，电流却还在嘶响。\n你注意到：22:16 的全镇寻人广播尚未发生。",
        "caption": "【记录完毕：21:47 先于 22:16】",
        "sound": "tape_stop"
    }
]

static func count() -> int:
    return BEATS.size()

static func beat(index: int) -> Dictionary:
    if index < 0 or index >= BEATS.size():
        return {}
    return BEATS[index]

static func cue(index: int) -> String:
    return str(beat(index).get("sound", ""))
