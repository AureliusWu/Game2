# Game2 · 旧梦乡（工作代号）

Chinese folk horror · millennium nostalgia · dreamcore · cosmic mystery

第一人称 3D 民俗志怪推理游戏。首个案件：**《广播里的人》**。当前是可交互的 **Godot 灰盒原型**；美术和音效尚未达到最终半写实品质，暂非 Steam Demo。

## 当前进度（v0.2.0-dev）

- **环境细节**：小镇增添电话亭、电线杆、广告牌与旧屋立面；小卖部增加 CRT 收款设备、饮料货架、挂历；广播站有磁带设备和停播通知；祠堂增加香火、牌位和封声禁忌。
- **环境声音**：运行时合成虫鸣、电器嗡鸣、收音机干扰和祠堂风声，无第三方音频版权依赖。
- **演出变化**：首次听到 21:47 录音后，雾气、光照与镇上文字出现轻微异常。
- **可选调查**：新增三条民俗/年代线索；推理依然围绕四条关键证据展开。
- **易读性**：长文本和推理面板支持滚动；CI 增加场景、音频、异常与逻辑检查。
- **下载**：在 GitHub Actions 对应成功运行的 Artifacts 中获取 Game2-Windows-x64，PR 可直接提供候选构建。

详细记录：[第二轮开发日志](docs/ITERATION-02.md)。

**说明：目前仍是程序化场景美术的游戏原型，尚未制作正式 PBR 写实模型、配音、动态角色或完整单元剧情。**

## 第一轮实现（v0.1.0-dev）

- 怀声镇 3D 主街道、旧小卖部、广播站、祠堂：使用引擎内程序化几何搭建，可探索与切换区域。
- 第一人称 WASD / Shift、鼠标观察、E/F 交互、J 调查笔记、Esc 鼠标与界面管理。
- 5 条剧情线索、4 条必要证据、一次以 21:47 / 22:16 时间矛盾为核心的推理。
- 错误推理反馈、尾声、存档到 user://case01-save.json。
- GitHub Actions：Godot 导入检查、场景 smoke、主分支 Windows x64 构建工件。

## 运行

1. 下载 [Godot 4.7.2 Standard](https://godotengine.org/download/)，无需 .NET 版。
2. 使用 Godot 项目管理器打开本仓库的 project.godot。
3. 点击右上角运行项目（F6/F5，推荐 F5）。
4. 进入小镇并依次调查：镇入口寻人启事、小卖部账本、广播站日志和录音。打开 J 笔记开始推理。

Godot 也支持在命令行运行：

    godot --path .

CI 冒烟测试：

    godot --headless --editor --path . --import
    godot --headless --path . --script res://tests/smoke.gd

## 目录

- scenes/main.tscn — 游戏入口和第一人称玩家
- scripts/player.gd — 移动与鼠标
- scripts/world.gd — 可替换的 3D 灰盒场景
- scripts/game.gd — 交互、证据、推理、存档、UI
- docs/CASE01.md — 剧情、设计边界、里程碑
- .github/workflows/godot.yml — 自动验证与 Windows 构建

## 下一步

将灰盒升级为写实比例的 2000 年代小镇：原创模块化建筑、PBR 材质、地方民俗资料考证、环境音、正式配音和完整案件叙事。**先验收玩法闭环，再扩大开发规模。**

> “封声”和“听山的”为虚构民俗设定，不应宣称是实际的地方传统。
