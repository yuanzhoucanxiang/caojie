# 代码规范

## 文件命名

| 类型 | 格式 | 示例 |
|------|------|------|
| 脚本文件 | `snake_case.gd` | `npc_grandmother.gd` |
| 场景文件 | `snake_case.tscn` | `npc_grandmother.tscn` |
| 素材文件 | `snake_case.png` | `smile.png` |
| Shader | `snake_case.gdshader` | `watercolor_transition.gdshader` |

- **场景和脚本同名**：`npc_grandmother.gd` 驱动 `npc_grandmother.tscn`

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

复杂逻辑加注释说明 **为什么**，不说明 **做什么**。

注释用中文。

## 信号规范

- 信号命名描述"发生了什么"：`dialogue_finished` 而非 `on_dialogue_end`
- 连接信号用代码 `signal.connect()` 而非编辑器面板（便于追踪）
- 一个文件发出信号，另一个文件监听信号——画清"谁发谁收"

## 信号通信一览

```
Player.interact_pressed ──→ NPCBase._on_player_interact()
                              │
NPCBase.dialogue_request ──→ DialogueManager.start_dialogue()
                              │
DialogueManager.dialogue_started ──→ Main 暂停玩家
DialogueManager.dialogue_finished ──→ Main 恢复玩家
```

## 文件职责速查

| 文件 | 职责 |
|------|------|
| `game_state.gd` | 全局属性、事件完成标记（最底层，谁都能用） |
| `dialogue_manager.gd` | 全局对话调度（Autoload，NPC 和 UI 的桥梁） |
| `scene_manager.gd` | 场景切换管理（Autoload） |
| `player.gd` | 玩家移动、广播交互信号 |
| `npc_base.gd` | NPC 基类（交互检测、条件检查、发出对话请求） |
| `npc_xxx.gd` | NPC 子类（只写事件数据） |
| `dialogue_panel.gd` | 对话 UI（显示对话、生成选项按钮） |
| `main.gd` | 主控制器（绑定 NPC、暂停/恢复玩家） |

## Godot 关键概念

- **Autoload**：全局单例，在 `project.godot` 中注册，任何脚本都能直接用名字调用（如 `GameState`、`DialogueManager`）
- **信号（Signal）**：A 发出信号，B 监听信号。A 不需要知道 B 是谁
- **场景（Scene）**：一个 `.tscn` 文件，是一个可复用的节点树
- **节点树**：场景中的所有节点按父子关系组织成树状结构
- **@export**：在编辑器中可修改的变量
- **@onready**：场景加载完成后才获取的节点引用
