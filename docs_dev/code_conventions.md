# 代码规范

## 目录结构

```
scripts/
├── autoload/              # 全局单例（任何脚本都能直接调用）
│   ├── game_state.gd      # 属性、事件标记
│   ├── dialogue_manager.gd # 对话调度、气泡管理
│   └── scene_manager.gd   # 场景切换、镜头
│
├── player/
│   └── player.gd          # 玩家移动、交互信号
│
├── npcs/                  # 所有 NPC 脚本
│   ├── npc_base.gd        # 基类
│   └── npc_xxx.gd         # 子类（只写事件数据）
│
├── ui/                    # UI 组件
│   ├── dialogue_bubble.gd # 说话气泡
│   └── choice_bubble.gd   # 选项气泡
│
├── triggers/              # 触发器（门、机关、区域触发）
│   └── transition_trigger.gd
│
├── scenes/                # 场景控制器（每个区域场景一个）
│   ├── courtyard.gd       # 院子（暂用 main.gd）
│   └── house_floor1.gd    # 一楼室内
│
└── main.gd                # 主入口控制器

scenes/                    # 场景文件（.tscn）
├── main.tscn              # 主场景入口
├── player.tscn
├── npcs/                  # NPC 场景
└── areas/                 # 区域场景
    └── house_floor1.tscn
```

**找文件的原则：**
- 出了问题先看 `autoload/`（全局状态）→ 再看对应系统目录
- 对话问题 → `autoload/dialogue_manager.gd` + `ui/`
- NPC 问题 → `npcs/npc_xxx.gd`
- 场景切换 → `autoload/scene_manager.gd` + `triggers/`
- 移动/交互 → `player/player.gd`

## 文件命名

| 类型 | 格式 | 示例 |
|------|------|------|
| 脚本文件 | `snake_case.gd` | `npc_grandmother.gd` |
| 场景文件 | `snake_case.tscn` | `npc_grandmother.tscn` |
| 素材文件 | `snake_case.png` | `smile.png` |
| Shader | `snake_case.gdshader` | `watercolor_transition.gdshader` |

- 场景和脚本同名：`npc_grandmother.gd` 驱动 `npc_grandmother.tscn`

## GDScript 命名

| 类型 | 格式 | 示例 |
|------|------|------|
| 变量 | `snake_case` | `change_attribute` |
| 常量 | `UPPER_SNAKE_CASE` | `DEPTH_MIN_Y` |
| 信号 | `snake_case` 过去式 | `dialogue_finished` |
| 类名 | `PascalCase` | `NPCBase` |
| 私有变量/函数 | `_` 开头 | `_in_range`, `_show_prompt` |

## 节点树命名

- 节点名：`PascalCase`（如 `InteractionZone`, `DialogueBox`）
- 组名：`snake_case`（如 `"player"`）

## 注释规范

每个脚本文件顶部写三行说明：
```gdscript
## 职责：这个文件做什么
## 谁使用它：哪些文件/系统调用它
## 它使用谁：它依赖哪些其他文件/系统
```

复杂逻辑加注释说明 **为什么**，不说明 **做什么**。注释用中文。

## 信号规范

- 信号命名描述"发生了什么"：`dialogue_finished` 而非 `on_dialogue_end`
- 连接信号用代码 `signal.connect()` 而非编辑器面板
- 一个文件发出信号，另一个文件监听——画清"谁发谁收"

## 信号通信一览

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

## 文件职责速查

| 目录 | 文件 | 职责 |
|------|------|------|
| autoload | `game_state.gd` | 全局属性、事件完成标记 |
| autoload | `dialogue_manager.gd` | 对话调度、气泡UI管理 |
| autoload | `scene_manager.gd` | 场景切换、镜头缩放 |
| player | `player.gd` | 玩家移动、广播 interact_pressed |
| npcs | `npc_base.gd` | NPC 基类（交互、条件、对话请求） |
| npcs | `npc_xxx.gd` | NPC 子类（只写事件数据） |
| ui | `dialogue_bubble.gd` | 说话气泡显示 |
| ui | `choice_bubble.gd` | 选项气泡显示 |
| triggers | `transition_trigger.gd` | 门/场景触发器 |
| scenes | `house_floor1.gd` | 一楼场景控制器 |

## Godot 关键概念

- **Autoload**：全局单例，project.godot 中注册，任何脚本直接用名字调用
- **Signal**：A 发出，B 监听，A 不需要知道 B 是谁
- **Scene**：一个 .tscn 文件，可复用的节点树
- **@export**：编辑器中可修改的变量
- **@onready**：场景加载后才获取的节点引用
