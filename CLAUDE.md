# caojie — 横板像素模拟经营+RPG

## 引擎与版本

- **引擎**：Godot 4.6.2
- **脚本**：GDScript（Godot 4 语法，不用 Godot 3 兼容写法）
- **渲染**：gl_compatibility（像素美术，`default_texture_filter=0` 禁过滤）
- **视口**：854×480，`canvas_items` 拉伸模式

## 项目概述

玩家扮演茂名县城出生的男孩（6岁），被送到乡下由外公外婆照顾。通过与NPC互动和事件选择增长属性，属性影响性格和命运。时间跨度：童年(6-12) → 少年(12-16) → 青年(16-18)。

核心循环：触发事件 → 做出选择 → 属性变化 → 解锁不同后续事件/NPC反应

横版自由探索，核心是对话+选择，非动作游戏。

## 目录结构（严格遵守）

```
caojie/
├── project.godot                    # 项目配置（autoload、输入映射）
├── CLAUDE.md                        # 本文件，AI 开发规范
├── WORLD.md                         # 策划案源文件
├── 《草芥》游戏策划案.docx            # 策划案汇总（pandoc 从 WORLD.md 生成）
│
├── scripts/                         # 所有 GDScript 脚本
│   ├── autoload/                    # 全局单例（project.godot 注册）
│   │   ├── game_state.gd            # 全局属性、事件标记
│   │   ├── dialogue_manager.gd      # 对话调度、气泡UI管理
│   │   ├── scene_manager.gd         # 场景切换、镜头缩放、水彩过渡
│   │   └── save_manager.gd          # 存档/读档、JSON 序列化
│   ├── player/
│   │   └── player.gd                # 玩家移动、depth缩放、广播 interact_pressed
│   ├── npcs/                        # 所有 NPC 脚本
│   │   ├── npc_base.gd              # NPC 基类（交互、条件、对话请求）
│   │   └── npc_xxx.gd               # NPC 子类（只写事件数据）
│   ├── ui/                          # UI 组件
│   │   ├── dialogue_bubble.gd       # 说话气泡
│   │   └── choice_bubble.gd         # 选项气泡
│   ├── triggers/                    # 触发器（门、机关、区域触发）
│   │   └── transition_trigger.gd    # 场景切换触发器
│   ├── scenes/                      # 场景控制器（和 scenes/areas/*.tscn 一一对应）
│   │   └── house_floor1.gd          # 一楼场景控制器
│   └── main.gd                      # 主入口控制器
│
├── scenes/                          # 场景文件（.tscn）
│   ├── main.tscn                    # 主场景入口（视差背景+玩家+NPC）
│   ├── player.tscn                  # 玩家场景（Camera2D+InteractionDetector）
│   ├── npcs/                        # NPC 场景文件
│   │   ├── npc_grandmother.tscn     # 外婆
│   │   ├── npc_uncle.tscn           # 舅舅
│   │   ├── npc_aunt.tscn            # 舅妈
│   │   ├── npc_cousin2.tscn         # 二表哥
│   │   └── npc_xiaoming.tscn        # 小明
│   ├── areas/                       # 区域场景
│   │   └── house_floor1.tscn        # 一楼室内
│   └── ui/                          # UI 场景（预留）
│
├── shaders/                         # 着色器文件
│   └── watercolor_transition.gdshader
│
├── assets/                          # 素材资源
│   ├── sprites/
│   │   ├── Characters/              # NPC/玩家角色立绘和精灵图
│   │   ├── Scenes/                  # 场景背景/建筑/装饰素材
│   │   ├── UI/                      # UI 素材（按钮、边框、图标）
│   │   ├── Items/                   # 物品道具图标
│   │   └── Expressions/             # NPC 表情差分
│   ├── sounds/
│   │   ├── SFX/                     # 音效（脚步声、开门声、对话音）
│   │   └── BGM/                     # 背景音乐
│   ├── Fonts/                       # 字体文件
│   └── Materials/                   # 材质纹理（shader 用的噪声图等）
│
├── docs/                            # 策划案 Docsify wiki（GitHub Pages 部署）
│   ├── characters/                  # NPC 人物档案（16个）
│   ├── logs/                        # 开发日志 wiki
│   ├── Design/                      # 设计文档（预留）
│   └── GDD/                         # 游戏设计文档（预留）
│
├── docs_dev/                        # 开发内部文档（不部署）
│   └── code_conventions.md          # 代码规范详细文档
│
├── logs/                            # 工作日志（原始 markdown）
│
└── addons/                          # Godot 插件
    └── gdUnit4/                     # GDUnit4 测试框架（预留）
```

**新文件必须放到对应目录，不允许在根目录或 scripts/ 下随意创建文件。**

## 命名规范

### 文件命名

| 类型 | 格式 | 示例 |
|------|------|------|
| 脚本文件 | `snake_case.gd` | `npc_grandmother.gd` |
| 场景文件 | `snake_case.tscn` | `npc_grandmother.tscn` |
| 素材文件 | `snake_case.png` | `smile.png` |
| Shader | `snake_case.gdshader` | `watercolor_transition.gdshader` |
| 资源文件 | `snake_case.tres` | `tile_data.tres` |

**规则：场景和脚本同名**——`npc_grandmother.gd` 驱动 `npc_grandmother.tscn`

### GDScript 命名

| 类型 | 格式 | 示例 |
|------|------|------|
| 变量 | `snake_case` | `change_attribute` |
| 常量 | `UPPER_SNAKE_CASE` | `DEPTH_MIN_Y` |
| 信号 | `snake_case` 过去式 | `dialogue_finished` |
| 类名 | `PascalCase` | `NPCBase` |
| 私有变量/函数 | `_` 开头 | `_in_range`, `_show_prompt` |
| 节点名 | `PascalCase` | `InteractionZone`, `DialogueBox` |
| 组名 | `snake_case` | `"player"` |

### 注释规范

每个脚本文件顶部写三行说明：
```gdscript
## 职责：这个文件做什么
## 谁使用它：哪些文件/系统调用它
## 它使用谁：它依赖哪些其他文件/系统
```

复杂逻辑加注释说明 **为什么**，不说明 **做什么**。注释用中文。

## Autoload 规则（重要！）

**当前 autoload 列表：** `GameState`, `DialogueManager`, `SceneManager`, `SaveManager`（在 `scripts/autoload/` 下）

- Autoload 脚本**不要加 `class_name`**，Autoload 注册名已经是全局引用
- 写新脚本前先检查 `project.godot` 的 autoload 列表，避免冲突
- 非 autoload 脚本可以正常使用 `class_name`

## 信号通信流程

```
Player.interact_pressed ──→ NPCBase._on_player_interact() / TransitionTrigger._on_player_interact()
                              │                                      │
NPCBase.dialogue_request ──→ DialogueManager.start_dialogue()       │
                              │                                      │
DialogueManager.dialogue_started ──→ Main 暂停玩家                  │
DialogueManager.dialogue_finished ──→ Main 恢复玩家                 │
                                                                     │
TransitionTrigger ──→ SceneManager.change_to_packed()               │
                              │                                      │
SceneManager.transition_completed ──→ 新场景的 _ready() 自动执行绑定
```

## 场景切换出生点规则

每个场景定义 `const SPAWN_POINTS`（`signal → const → @export → var → @onready`）：
```gdscript
const SPAWN_POINTS := {
    "from_<来源>": Vector2(x, y),
}
```
- 过渡触发器（TransitionTrigger）加 `@export var spawn_id: String`，指向目标场景的出生点
- 场景 `_ready()` 调 `_apply_spawn()`：`SceneManager.get_pending_spawn()` → 查找 SPAWN_POINTS → 放置玩家
- 新增场景切换一律遵循此模式

## 找 Bug 的顺序

1. 先看 `scripts/autoload/`（全局状态可能被改了）
2. 再看出问题的系统目录（对话→`ui/`，NPC→`npcs/`，切换→`triggers/`）
3. 最后看 `player/player.gd` 或 `main.gd`

## 美术方向与规则

**参考游戏：**
- Ori 系列（多层视差滚动、精致自然场景）
- 歧路旅人 HD-2D（像素角色+3D景深、光影氛围）
- REPLACED（电影感光影、像素精度）
- 直到那时 Until Then（日常生活温暖质感、2.5D像素叙事）
- 爱氏物语 Eastward（像素表情差分、对话演出）

**绝对规则：**
- **不出现纯白(1,1,1)和纯黑(0,0,0)**，所有颜色用暖色调、中性色
- 最亮用米白/暖白，最暗用深棕/暖黑
- 遮罩/过渡层用场景主色调
- UI 元素用深棕替代纯黑、用米白替代纯白

## 开发禁区（禁止擅自修改）

| 文件/目录 | 原因 |
|-----------|------|
| `project.godot` | autoload 列表、输入映射、渲染设置——修改前必须确认 |
| `scripts/autoload/*.gd` | 全局单例，影响所有系统 |
| `scenes/main.tscn` | 主入口场景，节点树结构复杂 |
| `.github/workflows/pages.yml` | GitHub Pages 部署配置 |
| `WORLD.md` | 策划案源文件，修改需先讨论 |

**修改以上文件前必须先和用户确认。**

## 常犯错误备忘

- `get_viewport_rect()` 只能在 Viewport 上调用，Node 要用 `get_viewport().get_visible_rect().size`
- `create_tween()` 必须在节点加入场景树后调用（在 `_ready()` 中）
- .tscn 的 Color 必须有4个分量：`Color(r, g, b, a)`
- CanvasLayer 下的节点不参与 ParallaxBackground
- 信号连接前检查是否已连接，避免重复
- 状态切换后加输入冷却（0.1s），防止按键延续
- Shader `step(a, b)`：a<=b 返回 1，注意中间变量可能为负值
- Shader dissolve 遮罩：确保 dissolve=0 时输出 alpha 完全为 0
- 褪色遮罩不用纯白/纯黑，用场景主色调
- 过渡 easing 用 `TRANS_SINE` + `EASE_IN_OUT`
- Autoload 脚本不加 `class_name`

## Git 提交规范

格式：`<type>: <简短中文描述>` + 改动点列表

| 前缀 | 用途 |
|------|------|
| `feat:` | 新功能/新系统 |
| `fix:` | 修 bug |
| `docs:` | 文档/策划案/wiki |
| `refactor:` | 重写已有代码，不改功能 |
| `style:` | 格式/命名调整（gdlint、代码规范） |

提交时机：每完成一个可独立运行的小里程碑就提交。出问题时可以精准回退。

## 策划案同步规则

- 修改策划案内容时，先修订 `WORLD.md`（源文件）
- 再用 pandoc 转换：`pandoc WORLD.md -o 《草芥》游戏策划案.docx`
- `WORLD.md` 是源文件，《草芥》游戏策划案.docx` 是供用户查看的汇总文档

## 内容模糊化规则

- 游戏中与现实历史事件强挂钩的内容，一律**模糊化处理**
- 例如：不写"对越自卫反击战"，而用"南边的仗""那场战争"
- 目的：保持故事的真实感底色，不被具体历史事件绑定

## 用户档案

- **编程经验**：零编程经验，独立游戏开发者
- **沟通语言**：中文
- **教学方式**：修改代码时同步解释 Godot 编辑器操作步骤，帮助用户理解"在编辑器里怎么操作"
- **回答风格**：用游戏设计术语回应设计想法，附带相关游戏参考

## 快速参考

| 信息 | 值 |
|------|------|
| Godot 版本 | 4.6.2 |
| 视口 | 854×480 |
| 渲染 | gl_compatibility |
| 主场景 | `res://scenes/ui/title_screen.tscn` |
| Autoload | GameState, DialogueManager, SceneManager, SaveManager |
| 策划案 wiki | yuanzhoucanxiang.github.io/caojie/ |
| 开发日志 wiki | yuanzhoucanxiang.github.io/caojie/logs/ |
| 仓库 | git@github.com:yuanzhoucanxiang/caojie.git |
