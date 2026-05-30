# 架构交接说明

更新时间：2026-05-30

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
- 2026-05-30 新增对话/互动输入锁：对话或调查开始后，玩家不能移动、不能滚轮缩放、不能再次触发 NPC/调查物/门；输入焦点交给 `DialogueManager`。

## 对话与互动输入锁

当前交互规则采用“完全锁定”模式：任何 NPC 对话、物品调查、门口对话式交互开始后，在 `DialogueManager.current_state` 回到 `IDLE` 前，玩家只能推进当前对话或选择选项。

实现边界：
- `Player` 提供 `set_input_locked(locked: bool)` 和 `is_input_locked()`。
- 锁定时 `Player._physics_process()` 不读取移动轴、不发出 `interact_pressed`，并把 `velocity` 和脚步计时清零。
- 锁定时 `Player._unhandled_input()` 直接返回，因此对话期间不能用滚轮缩放镜头。
- `Player` 自身也必须把 `DialogueManager.is_dialogue_active()` 当成全局输入闸门，不能只依赖场景控制器外部上锁。
- `AreaControllerBase` 监听 `DialogueManager.dialogue_started/dialogue_finished`，只负责调用 `player.set_input_locked(true/false)`。
- 对话结束时必须等到下一次 `physics_frame` 再解锁玩家，避免“按 E 结束对话”的同一帧又被 Player 当成新互动，造成对话循环打开。
- `NPCBase`、`InteractableObject`、`TransitionTrigger` 的 `_on_player_interact()` 开头必须检查 `DialogueManager.is_dialogue_active()`，对话中直接返回。
- `PauseMenu` 在对话活跃且菜单未打开时必须吞掉 `ui_cancel`，不能让玩家在物品调查/对话过程中打开保存、设置或退出菜单。
- 多个触发区重叠时使用 `scripts/triggers/interaction_focus.gd` 做唯一聚焦选择。所有交互源注册到 `interaction_candidates` 组，按 `interaction_priority`、距离玩家远近、y 轴前后关系选出一个响应者。
- 默认优先级：`NPCBase = 20`、`TransitionTrigger = 10`、`InteractableObject = 0`。如果一个物品必须压过附近对象，可在实例上调整 `interaction_priority`，不要靠扩大触发区抢响应。
- 提示文字也只显示当前聚焦对象，避免多个“按 E 查看/对话/进入”挤在一起。
- 热区布局要和视觉物件“错开但对应”：大家具用较低、较窄的主热区，小物件热区放在物件视觉中心附近但不要压在大家具热区中心。当前守护样例：一楼圆桌/餐具、二楼三扇门、三楼书桌/作业本/玩具/窗光。
- 院落 NPC 也按生活锚点分散，避免三个人和井口/大屋入口挤成一个交互团。当前守护站位：舅舅 `Vector2(300, 430)` 在左侧院落，二表哥 `Vector2(690, 410)` 在中段井口/老屋过道，小明 `Vector2(1040, 420)` 在右侧生活区。
- 不使用 `get_tree().paused` 作为对话暂停手段，因为对话 UI、输入冷却、气泡动画仍需要继续运行。

后续 Claude Code / DeepSeek 接手时注意：
- 不要再用 `player.set_physics_process(false)` 作为主要方案，否则玩家的深度缩放、排序等非输入逻辑会一起停掉。
- 新增任何可交互系统时，都要在触发入口检查 `DialogueManager.is_dialogue_active()`。
- 对话中允许的输入只应该由 `DialogueManager` 消费：`interact` 推进/确认，`move_left/move_right` 切选项。
- 相关回归测试在 `tests/unit/dialogue_interaction_lock_test.gd`。

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
- 室内门框按儿童角色比例控制：普通房门 `140~170px` 高、`50~90px` 宽；二楼三扇门不能成为画面主角，门板比门框内缩 8~12px，门把手放在 `y=255~270` 附近。
- 家具比例按“儿童角色约 `50~60px` 高”估算：床宽约 `100~130px`，桌宽约 `80~110px`，行李箱/玩具约 `30~45px` 宽。需要更大物件时，用前景遮挡或分层表达，不要单纯放大矩形。
- 2026-05-30 起，主角游戏内精灵 `assets/sprites/Characters/player/player_idle_front.png` 作为统一比例尺：画布 `48x72`，角色实际约 `60px` 高，脚底点对齐角色节点原点。室内外 NPC、家具、门和建筑都先按这个尺度校准。
- 院落建筑当前尺度：主屋 `322x280`，老屋 `270x184`，两者视觉底边都约为 `y=353`，通过 `ContactShadow` 和 `GroundLip` 压到远景墙脚基线 `y=348`。后续不要只按 PNG 画布中心摆放建筑，要按真实墙脚/台阶底边接地。

三层大屋当前视觉定位：

| 场景 | 视觉方向 | 主要物件 |
|---|---|---|
| `house_floor1` | 暗暖、烟火气、公共生活空间 | 灶台、碗柜、挂历、圆桌、水缸 |
| `house_floor2` | 窄走廊、门代表家庭成员 | 三个房门、奖状、歪画、狗垫、楼梯阴影 |
| `house_floor3` | 蓝灰明亮、主角的小空间 | 窗光、床、书桌、行李箱、玩具、贴纸 |

2026-05-28 比例校准：

- `house_floor1` 的 `ceiling_h` 从 76 降到 52，避免室内天花过高。
- `house_floor2` 的三个门框从 214~220px 降到 164~166px，交互碰撞区同步缩小。
- `house_floor3` 的天台门降到 156px，床、书桌、行李箱、玩具机器人整体缩小，地面窗光调查点设为 `blocks_player=false`。
- 新增 `tests/unit/interior_stage_builder_test.gd` 的比例守卫：检查室内 `ceiling_h`、门框高度和 `WindowGrid/LightGrid` 命名残留。

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
tests/unit/dialogue_interaction_lock_test.gd
```

推荐命令：

```powershell
addons\gdUnit4\runtest.cmd --godot_binary C:\path\to\godot.exe --add tests\unit
```

或设置环境变量：

```powershell
$env:GODOT_BIN = ".\.local_tools\Godot\Godot_console.exe"
addons\gdUnit4\runtest.cmd --godot_binary $env:GODOT_BIN --ignoreHeadlessMode --add tests\unit
```

2026-05-30 当前 Codex 环境已可使用 `.local_tools\Godot\Godot_console.exe` 跑 GdUnit。最近一次回归：
- `tests/unit`：23/23 通过。
- `.local_tools\Godot\Godot_console.exe --headless --path . --quit`：项目加载通过。

早期曾通过 Godot MCP 启动以下场景检查解析与运行时错误：

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
