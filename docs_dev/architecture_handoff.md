# 架构交接说明

更新时间：2026-05-28

本文给后续使用 Codex 或 Claude Code 继续开发《草芥》时阅读。它记录当前游戏代码的分层方式、这次架构调整做了什么，以及新增内容时应该沿用的模式。

## 本次调整摘要

- 新增 `scripts/scenes/area_controller_base.gd`，统一处理区域场景的通用流程：
  - 查找并注册 `Player`
  - 添加暂停菜单
  - 应用出生点
  - 添加后处理遮罩
  - 自动绑定 `dialogue_request` 到 `DialogueManager`
  - 对话开始/结束时暂停或恢复玩家
- `scripts/main.gd`、`scripts/scenes/house_floor1.gd`、`scripts/scenes/house_floor2.gd`、`scripts/scenes/house_floor3.gd` 改为继承 `res://scripts/scenes/area_controller_base.gd`。
- `NPCBase._get_available_event()` 默认跳过已经完成的非重复事件；需要重复触发的事件显式写 `"repeatable": true`。
- `Player` 不再硬编码区域名判断缩放/深度缩放，改由 `SceneManager.CAMERA_CONFIGS` 提供 `allow_zoom` 和 `depth_scale`。
- `AreaControllerBase` 在找不到 `spawn_id` 时会输出 warning，避免场景切换出生点静默失败。
- 新增 GdUnit 回归测试 `tests/unit/npc_event_selection_test.gd`，覆盖“完成第一条 NPC 事件后应进入下一条事件”。
- 新增 `scripts/scenes/interior_stage_builder.gd`，用纯文字坐标表生成室内“横向舞台盒子”视觉层，避免非多模态模型只能凭参考图猜布局。

## 室内场景方法论入口

室内视觉当前采用“横向舞台盒子 v2”。后续 Claude Code 或 DeepSeek 接手时，先读 `WORLD.md` 的“室内场景构图方法论——横向舞台盒子 v2”，再改场景脚本。

核心规则：

- 室内不是斜俯视地图，而是正面剖开的横向房间。
- 场景脚本调用 `InteriorStageBuilderScript.rebuild(self, spec)` 生成墙、地板、家具、光带、前景遮罩。
- spec 必须包含 `width`、`height`、`ceiling_h`、`floor_y`、`wall`、`palette`、`lights`、`items`、`foreground`。
- `items` 默认生成矩形；墙缝、地板缝、门缝光、床单褶皱等用 `{"kind": "line", "from": Vector2(...), "to": Vector2(...), "width": 2.0}`。
- 碗口、杯口、门把手、玩具轮子、小光斑等用 `{"kind": "ellipse", "pos": Vector2(...), "size": Vector2(...), "color": Color(...), "z": ...}`。
- 所有物件必须有明确坐标、尺寸、颜色和 z_index；不要写“像参考图一样”这种需要看图才能执行的指令。
- 每个室内房间至少放 2~4 个 `InteractableObject`，互动描述必须体现生活痕迹或人物关系。
- 放在玩家行走带里的调查点必须设置 `blocks_player = false`；只有真正应该挡路的家具或墙体才保持默认阻挡。
- 窗格光不要用贯穿全屏的高对比黄线；优先用低 alpha 矩形光斑，线条只做很短的结构暗示。
- 室内天花板只保留薄顶带，`ceiling_h` 建议 44~56；除非故意表现压抑空间，不要超过 64。
- 家具必须保持正面剖面语言：床要有正面床沿，桌子要有前挡板和桌腿，不要只画一块像俯视桌面的矩形。

三层大屋当前视觉定位：

| 场景 | 视觉方向 | 主要物件 |
|---|---|---|
| `house_floor1` | 暗暖、烟火气、公共生活空间 | 灶台、碗柜、挂历、圆桌、水缸 |
| `house_floor2` | 窄走廊、门代表家庭成员 | 三个房门、奖状、歪画、狗垫、楼梯阴影 |
| `house_floor3` | 蓝灰明亮、主角的小空间 | 窗光、床、书桌、行李箱、玩具、贴纸 |

## 新增区域场景时

1. 在 `scenes/areas/` 创建场景，在 `scripts/scenes/` 创建同名脚本。
2. 场景脚本继承基类路径，不依赖 Godot 全局类缓存：

```gdscript
extends "res://scripts/scenes/area_controller_base.gd"
```

3. 场景脚本至少实现：

```gdscript
const SPAWN_POINTS := {
	"from_somewhere": Vector2(100, 380),
}


func _ready() -> void:
	_add_wall_collisions()
	setup_area_common()


func get_spawn_points() -> Dictionary:
	return SPAWN_POINTS


func get_post_process_config() -> Dictionary:
	return {
		"vignette_intensity": 0.2,
		"tint_color": Color(1.0, 0.9, 0.75, 0.12),
		"size": Vector2(854, 480),
	}
```

4. 在 `SceneManager.CAMERA_CONFIGS` 添加同名 `area_id`：

```gdscript
"new_area_id": {
	"zoom": 1.8,
	"offset": Vector2(0, 0),
	"allow_zoom": false,
	"depth_scale": {"min": 0.9, "max": 1.05},
	"limits": {"left": 0, "right": 854, "top": 0, "bottom": 480},
	"player_bounds": {"left": 30, "right": 820, "top": 340, "bottom": 420},
},
```

5. 过渡触发器的 `target_area_id` 必须等于 `CAMERA_CONFIGS` 里的 key；`spawn_id` 必须存在于目标场景的 `SPAWN_POINTS`。

## 新增 NPC 事件时

NPC 子类继续只写事件数据。事件默认是一次性的：

```gdscript
{
	"id": "gm_event_4",
	"conditions": ["event_completed:gm_event_3"],
	"text": "新的剧情文本",
	"expression": "normal",
	"choices": [
		{"text": "选项", "effects": {"懂事": 1}},
	],
}
```

如果一个事件要作为日常闲聊反复出现，显式加：

```gdscript
"repeatable": true
```

不要把已完成事件的跳过逻辑写进每个 NPC 子类；统一由 `NPCBase` 处理。

## 新增可互动物品时

短期仍可在场景控制器中创建 `InteractableObject`，但更推荐后续逐步改成在 `.tscn` 中摆放 `scenes/triggers/interactable_object.tscn`，然后通过 Inspector 填 `object_name`、`description`、`collision_w`、`collision_h`。

`InteractableObject.dialogue_request` 的信号签名已经统一为：

```gdscript
signal dialogue_request(source_node: Node, event_data: Dictionary)
```

## 测试与验证

当前已新增测试：

```text
tests/unit/npc_event_selection_test.gd
```

推荐命令：

```powershell
addons\gdUnit4\runtest.cmd --godot_binary C:\path\to\godot.exe --add res://tests/unit/npc_event_selection_test.gd
```

或设置环境变量：

```powershell
$env:GODOT_BIN = "C:\path\to\godot.exe"
addons\gdUnit4\runtest.cmd --add res://tests/unit/npc_event_selection_test.gd
```

本次 Codex 环境里 shell 没有 `godot` / `GODOT_BIN`，因此 GdUnit 测试文件已写入，但未能在 shell 中执行。已通过 Godot MCP 启动以下场景检查解析与运行时错误：

- `res://scenes/main.tscn`
- `res://scenes/areas/house_floor1.tscn`
- `res://scenes/areas/house_floor2.tscn`
- `res://scenes/areas/house_floor3.tscn`

## Claude Code 补充改动（2026-05-27）

- `InteractableObject` 改用 `@export` 变量（object_name / description / collision_w / collision_h / prompt），去掉 `setup()` 依赖。创建了 `scenes/triggers/interactable_object.tscn` 场景文件。
- `TransitionTrigger` 去掉 `_draw()` 里的门矩形绘制和 `show_door_visual` 开关，只保留提示文字。门的视觉完全由 InteriorStageBuilder 的 spec 负责。
- 三个场景的 tscn 文件中所有旧的 Polygon2D/ColorRect 节点已删除，只保留 Player、触发器和 NPC。
- 墙壁碰撞体拆成上下两段（WallLeftTop/WallLeftBot、WallRightTop/WallRightBot），中间留出门洞。
- 安装了 `openai/codex-plugin-cc` 插件，Codex CLI 0.134.0。可用 `/codex:review` 和 `/codex:rescue`。
- 创建了 `AGENTS.md`（Codex 项目规范，内容和 CLAUDE.md 基本一致）。

## 后续建议

- 把互动点从代码创建逐步迁回 `.tscn`，让非程序开发流程更可视化。
- 把 NPC 事件数据从脚本逐步迁到资源或数据文件，方便批量写剧情。
- 给场景切换做一个开发期校验工具，扫描所有 `TransitionTrigger.spawn_id` 是否存在于目标场景。
- 为 `SceneManager` 的区域配置和存档读档补 GdUnit 测试。
- 室内场景定稿后可烘焙成 tscn（运行时在远程场景树里另存为场景）。
- spec 数据行超长（gdlint max-line-length），可考虑拆行或调整 lint 规则。
