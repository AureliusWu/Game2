# v0.20「证据之间」实施与验证

日期：2026-11-17。源基线：18e052b1f806a03440ea75d7b601bc3ba02f2710；候选以本文件所在提交及 Actions 的 head SHA 为准。

## 已实施

独立 `scripts/inquiry.gd` 管理五条关联规则、四条追问、线索提示和卷宗。`game.gd` 接入实际笔记/人物菜单；只允许选择已发现的原始材料。先选两份不同材料，再核对推断；错配、错答、取消与换区不写入结论。两份材料的选择草稿不入档，关闭后清空。重复查看不重复计数。停播关联仅谈通知日期，不提前透露尚未向陈站长追问的手写提醒。

新稳定 ID：`broadcast_crosscheck`、`voice_boundary`、`notice_crosscheck`、`ritual_boundary`、`shop_door_account`、`calendar_testimony`、`practice_testimony`、`notice_testimony`。身份关联复用已有 `ledger_crosscheck`。所有记录通过既有 SaveStore 写入，不更换主档路径或结构；未修改旧存档中的完成条件。

证据追问检查材料和当前证人，使用原问话镜头与角色演出，关闭后恢复走动。长证据正文下首个按钮在布局完成后进入可见滚动区域；选材后保留对应按钮焦点。终局处理增加四证据检查，避免直接调用正确答案跳过条件。

## 本地实际验证

引擎：下载并实际运行官方 Godot **4.7.2.stable.official.ed1daf0bf**。Linux；实际画面使用 Xorg dummy / Mesa llvmpipe，1280×720，另测 640×360。

| 检查 | 结果与实际覆盖 |
| --- | --- |
| 导入 | 官方 4.7.2 editor import，无脚本/解析错误 |
| 原七组回归 | smoke、case01、exploration、player_ux、free_roam、school、persistence 通过；100 组构图、17 处物理交互、43 项存档故障检查仍保留 |
| inquiry 新回归 | 5800 项断言（包含所有候选材料对与错误答案组合），五条 GUI 关联、四条追问、缺材料、远程证人拒绝、旧完成档/新 ID 往返、取消清理、Tab/Enter、640×360 |
| inquiry 实渲染 | 5811 项断言，11 张真实 PNG；包含错配、错答、归档、两名证人的追问、卷宗和最小窗口 |
| 连续输入试玩 | WASD/鼠标/E/J/H/Tab/Enter 原完整路线通过，159.0 米，16 阶段；不瞬移、不注入线索，含错误/正确主线推理与取消/确认重开 |
| 原画面回归 | 原场景 13 张、自由走位 11 张、学校 4 张，均实际渲染完成 |
| 重复执行 | 发现学校/主线测试只移除主档、备份会污染下一次启动；改为仅清理各自 QA 路径的全套恢复文件，学校复跑通过 |

新增 GUI 测试为**明确预置证据的场景测试**，不是新手无提示探索；原连续输入路线仍是独立证据。画面观察确认关联板、选材、追问构图与小窗口滚动可用；人物和环境依旧是已有原创低模过渡美术。本轮共 55 张实际画面，输出到 `build/`，由 CI 作为 artifacts 另行生成。

本地非阻断警告：软件渲染驱动不支持切换 V-Sync；部分现有测试结束时存在 ObjectDB 清理警告。检查未将其隐藏或改报为错误；不据此宣称性能或零泄漏验收。

## CI 与交付

首个云端候选 4e1a0f6 的 Windows 导出成功、编辑器存档回归通过，但导出 EXE 检查仍写死 0.14.0-dev，因此版本身份检查失败。保留失败记录（Actions 44008810617）；改为由 PowerShell 从当前检出的 project.godot 读取期望版本并通过命令行传入 EXE，与包内版本独立比较，只有匹配时才打印成功身份。这样后续升级无需改写死字符串，也不会因“自行读取自身版本”而放过旧 PCK。

CI 保留原 Linux 逻辑、Windows x64 导出、Windows 编辑器和实际导出 EXE 的存档回归，新增 inquiry headless 与实渲染检查。具体候选、成功状态及包 SHA256 必须查看该提交的 Actions，不能用本地 Linux 结果替代 Windows 结果。

仍未执行实体 Windows 设备的人类试玩、真实显卡性能测试或正式美术验收；当前版本为 v0.20.0-dev，不是完整失踪案结局或 Steam Demo。下一步是基于实际 Windows 包开展实体设备体验与正式资产替换。

## 本地新增画面 SHA256

```text
4ebeedc778556a71a24230d8a95a0102097103ecbd313b274fd68477aa9c90e5  01_empty_board.png
323725198ea26450f852e926533884d8efb5eeda7d063a28b80b5208e0917c0f  02_empty_materials.png
840cf2e7eeadccd5f04c668974bf27dfaa57f8336c978bcc1912765f81840ded  03_wrong_pair.png
c135bda634ea69e99b18edbfa96ef554522f859494e6017a3a9facdd75c4d748  04_wrong_inference.png
917733875a2b5197fdd2b482798fb0d8e9289870609793d3d76485b8a849ba5c  05_archived_association.png
2e2d79d28d5cb7300ed68bd76af0899e40d78269b83c5924ca76e2ecd494c846  06_calendar_testimony.png
9d4e7590bf35625d4c3a9d19c577e106a277fea6c7e96dfe814f77d693e2211a  06_notice_testimony.png
11e0d68e000ffb88c2d11e17ddf138fe91e916ef54d649390db6e9b6ed12fad9  07_completed_dossier.png
26548de71d446a6456f808b3d64335ee374ecedb9e1f3061009b6b5b354724c7  08_followed_leads.png
1f76b764d263127b3f62b1c23e4bfb8bba9b1aa17b2902d5c6099320f8ff39b2  09_compact_compare.png
092a88185e94f539ebfa0c020e173bf6b423e54ceede62c805339cdab187db26  10_compact_dossier.png
```
