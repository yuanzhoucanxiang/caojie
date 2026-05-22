# 《草芥》开发日志

## 项目概述

《草芥》— 横板像素模拟经营+RPG，基于 Godot 4.6.2 开发。

玩家扮演县城出生的男孩（6岁），被送到乡下由外公外婆照顾。通过与NPC互动和事件选择增长属性，属性影响性格和命运。

## 开发进度

### Godot 框架状态

| Phase | 状态 | 说明 |
|-------|------|------|
| 1.1 | ✅ | DialogueManager autoload |
| 1.2 | ✅ | NPCBase 信号重构（interact_pressed 广播） |
| 1.3 | ✅ | SceneManager autoload |
| 2.1 | ✅ | 5个NPC子类+场景文件 |
| 2.2 | ✅ | 事件数据 expression 字段 |
| 3.1 | ✅ | DialogueBubble（说话气泡）|
| 3.2 | ✅ | ChoiceBubble（选项气泡）|
| 3.3 | ✅ | DialogueManager 完整对话流程 |
| 3.4 | ✅ | 表情占位色块 |
| 4.1 | ✅ | 5层视差背景+Camera2D |
| 4.2 | ✅ | 场景切换（院子↔一楼）|
| 4.3 | ✅ | 室内外镜头差异 |
| 4.4 | ✅ | 水彩过渡shader+褪色效果 |

## 待继续

- NPC 场景分配（不同NPC出现在不同区域）
- 保存/读档系统
- 事件系统、时间系统、模拟经营

## 相关链接

- [游戏策划案 Wiki](https://yuanzhoucanxiang.github.io/caojie/)
- [GitHub 仓库](https://github.com/yuanzhoucanxiang/caojie)
