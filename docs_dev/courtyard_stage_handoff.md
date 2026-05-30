# 院落场景交接说明

更新时间：2026-05-30

本文记录外婆家院落从测试占位画面改成“横版叙事舞台 v3”的实现方式，给后续 Codex / Claude Code / DeepSeek 接手时使用。

## 入口文件

- `scripts/main.gd`
- `scripts/scenes/courtyard_stage_builder.gd`
- `tests/unit/courtyard_stage_builder_test.gd`

## 构图目标

院落不再按简单正面几何块摆放，而是参考用户给出的乡村院落图，拆成可玩的横版层次：

- 左侧：暂时只保留低位栅栏，不再使用程序化树影；等真实前景素材到位后再补遮挡层。
- 左中：三层外婆家素材、小卖部门口、阳台、瓷砖墙和入口。
- 中央：宽阔前院、水井、圆石桌，保留儿童视角的开阔感。
- 右侧：老瓦房、晾衣绳、菜畦，承担生活痕迹和探索点。
- 远景：低饱和山体、村镇房屋和树带，给空间增加纵深。

## 镜头与空间规则

- 院落默认镜头缩放保留 `SceneManager.CAMERA_CONFIGS["courtyard"].zoom = 1.25`，这是横版叙事和人物可读性的基准。
- 院落相机偏移使用 `Vector2(0, -150)`，让镜头像“孩子站在院子里仰视外婆家”，角色落在画面更偏下，楼体和天空占据更多视野。
- 不要用降低 zoom 的方式制造开阔感；开阔感应来自地面透视、建筑左右错位、中央留空和远景层次。
- 近地低机位阶段不要把地面铺满屏幕。`CourtyardYardGround` 从 `y=368` 开始，玩家行走带后沿当前从 `y=350` 开始，让玩家可以更靠近主屋墙脚，同时仍保留前院可读性。
- 建筑墙脚不能露出远景绿色带。`CourtyardRearGroundApron` 必须从 `y=348` 铺到主地面前方，用来承接主屋和老屋墙脚。
- 院落深度缩放使用 `{"min": 0.78, "max": 1.08}`。远处角色明显小一些，前景角色略大一些，用角色尺度差代替过多地面面积来表达空间。
- 程序化占位阶段用 `CourtyardYardPerspectiveFar`、`CourtyardPathWash`、`CourtyardYardPerspectiveNear`、`CourtyardOpenPlayBand` 表达轻微 2.5D 地面。真实素材阶段也要保持前宽后窄的院落方向。
- 玩家主行走带仍在画面下半部，当前约 `y=350~520`。水井、圆石桌、晾衣绳等生活物件可以贴近行走带，但不能堵死从左到右的主路径。
- 建筑远置时统一使用 `y=348` 作为远景墙脚基线：主屋、老屋正面、老屋侧墙、门脚和碰撞 `ground_y` 都要落在这条线上。
- 建筑基线位于主地面起点 `y=368` 之前，但不能悬空；必须由 `CourtyardRearGroundApron` 和 `Courtyard*ContactShadow` 承接。不要只移动屋顶或墙面，所有门、窗、阳台、侧墙、调查点和碰撞要跟着同一基线调整。

## v3 美术内容规则

- 地面透视由 `CourtyardGroundPerspectiveLine*` 和 `CourtyardGroundCrossLine*` 表达。线条必须顺着院落消失方向走，用低透明深棕，不要画成顶视角网格。
- 正屋已经进入素材替换阶段：`CourtyardMainHouse` 使用 `assets/sprites/Scenes/courtyard/main_house.png`，由 builder 生成 `Sprite2D`，不再叠加程序化瓷砖线、阳台栏杆和小卖部色块。
- `main_house.png` 来自用户提供的大屋素材。当前试用版来自 `大屋参考素材1.png`，原图棋盘格是烘进图片里的不透明背景，导入前用“高亮中性色识别”清掉棋盘格并裁剪透明留白。素材节点使用左上角 `pos` 和 `size` 缩放，当前为 `pos = Vector2(333, 73)`、`size = Vector2(322, 280)`，视觉底边会向下咬进地面约 5px，形成更稳的接地感。
- `CourtyardMainHouseGroundLip` 是主楼墙脚压地层，位于 `y=348~357`，用于把素材底部、接触阴影和院落地面粘合起来。调整主楼素材时要同步检查这条压地层是否仍然贴在台阶/地基下沿。
- 如果后续替换主楼素材，不要只看 PNG 画布底边；要先检查不透明像素边界，确认真正的墙脚、台阶或地基贴到 `y=348`。否则会出现“数据上接地、画面上浮空”的问题。
- 门口生活痕迹后续优先使用真实拆层素材表现，例如货架、盆栽、扫帚、海报；程序化阶段不要写真实文字，避免低清晰度下变成噪点。
- 右侧老屋已经进入素材替换试用阶段：`CourtyardOldHouse` 使用 `assets/sprites/Scenes/courtyard/old_house.png`，由 builder 生成 `Sprite2D`，暂时不再叠加程序化正面、侧墙、屋顶、门窗色块。
- `old_house.png` 来自用户提供的 `老屋参考素材像素.png`。原图棋盘格同样是烘进图片里的不透明背景，本轮用“边缘连通灰度棋盘格泛洪”去背景并裁剪透明留白，尽量避免误伤瓦片暗部。
- 当前老屋舞台数据为 `pos = Vector2(718, 169)`、`size = Vector2(270, 184)`、`z = 332`，视觉底边落到 `y=353`，向地面承接层咬入约 5px。老屋已按主角 `60px` 儿童比例尺缩小，作为侧翼旧屋，不再接近大屋的视觉权重。
- `CourtyardOldHouseContactShadow` 当前为 `pos = Vector2(726, 340)`、`size = Vector2(262, 32)`、`Color(0.18, 0.13, 0.09, 0.3)`，比第一次更暗更厚，用于加强老屋重量。
- `CourtyardOldHouseGroundLip` 是老屋墙脚压地层，当前为 `pos = Vector2(736, 347)`、`size = Vector2(232, 12)`、`Color(0.2, 0.14, 0.09, 0.32)`。它和主屋压地层一样只负责视觉接地，不参与碰撞。
- `CourtyardPowerLine*` 是远中景空间线索，应该位于建筑和远景之间，不参与碰撞，也不要压到玩家头顶。
- `CourtyardPottedPlant*` 这类生活道具用于增加家庭气息，底部要贴地并按 y 轴层级排序，不要随意漂在墙面或地面上。

## 2026-05-29 本轮工作总结

- 主屋已经从程序化色块替换为真实 PNG 素材：`assets/sprites/Scenes/courtyard/main_house.png`。`CourtyardStageBuilder` 已支持 `kind = "sprite"`，用 `Sprite2D` 生成素材节点。
- 当前主屋素材来自用户提供的 `大屋参考素材1.png`。原图棋盘格不是透明通道，而是烘进图片的不透明背景；本轮通过“高亮中性色识别”去掉棋盘格，并重新导入 Godot。
- 当前主屋舞台数据在 `scripts/main.gd`：`pos = Vector2(337, 81)`、`size = Vector2(313, 272)`、`z = 328`。这版让素材底边向地面承接层咬入约 5px，优先解决“像贴纸浮在地上”的问题。
- 新增 `CourtyardMainHouseGroundLip`：`pos = Vector2(350, 348)`、`size = Vector2(286, 9)`、`Color(0.2, 0.14, 0.09, 0.24)`、`z = 329`。它是视觉压地层，不参与碰撞，用于把主屋台阶、接触阴影和院落地面粘合起来。
- 院落玩家 Y 轴移动上边界从 `382` 调到 `350`，配置在 `SceneManager.CAMERA_CONFIGS["courtyard"].player_bounds`。这样玩家能更靠近主屋、水井和后院墙脚，便于观察接地效果。
- 当前仍保留低机位叙事镜头：`zoom = 1.25`、`offset = Vector2(0, -150)`、`depth_scale = {"min": 0.78, "max": 1.08}`。不要为了看全景随意降低默认 zoom，开阔感继续靠构图和深度缩放解决。
- 右侧老瓦房、地面、远景、道具仍主要是程序化占位。后续替换时优先按“老屋正面/侧墙/屋顶/侧屋顶”拆层，并继续检查墙脚是否压在 `CourtyardRearGroundApron` 和接触阴影上。
- 本轮验证通过：Godot headless 加载通过；院落专项 GdUnit `8/8` 通过；全部 unit `12/12` 通过。

## 2026-05-29 老屋素材试替换

- 新增 `assets/sprites/Scenes/courtyard/old_house.png`，由 `C:/workspace/草芥/老屋参考素材像素.png` 处理而来。
- 原图尺寸为 `1252x939`，没有透明通道；处理后有效裁剪约为 `1206x824`。
- `scripts/main.gd` 中已移除程序化老屋墙面、侧墙、屋顶、瓦线、门窗块面，改为单个 `Sprite2D` 条目；当前微调后为 `{"kind": "sprite", "name": "CourtyardOldHouse", "texture": "res://assets/sprites/Scenes/courtyard/old_house.png", "pos": Vector2(718, 169), "size": Vector2(270, 184), "z": 332}`。
- 新增并强化 `CourtyardOldHouseGroundLip`；当前微调后为 `pos = Vector2(736, 347)`、`size = Vector2(232, 12)`、`Color(0.2, 0.14, 0.09, 0.32)`、`z = 333`，用于老屋压地。
- 删除了程序化 `CourtyardPottedPlantB` / `CourtyardPottedPlantPotB`，因为老屋素材本身已经带有盆栽和墙脚杂物，避免重复堆叠。
- 老屋碰撞随视觉缩小同步微调为 `_add_body("OldHouse", 198, 82, 348)`；主屋碰撞同步为 `_add_body("House", 240, 246, 348)`。两者仍共用远景墙脚基线 `ground_y = 348`。

## 2026-05-30 主角比例尺与建筑微调

- 新增主角游戏内精灵：`assets/sprites/Characters/player/player_idle_front.png`，当前画布 `48x72`，实际角色约 `60px` 高，脚底对齐角色节点原点。
- 后续所有院落尺度都先用这张 `60px` 儿童角色做比例尺：儿童 NPC `56~64px`，成人 NPC `76~88px`，建筑和门窗按人物关系校准。
- 主屋作为家庭中心，微调为 `pos = Vector2(333, 73)`、`size = Vector2(322, 280)`；主屋压地层为 `pos = Vector2(346, 348)`、`size = Vector2(298, 10)`、`Color(0.2, 0.14, 0.09, 0.26)`。
- 老屋作为右侧旧屋，微调为 `pos = Vector2(718, 169)`、`size = Vector2(270, 184)`；不要再把老屋放到接近大屋宽度或高度，否则会削弱“大屋是家庭中心、老屋是时间阴影”的叙事层级。
- 两栋建筑的视觉底边都落到约 `y=353`，比远景墙脚基线 `y=348` 多咬进 5px。接地检查时看“不透明像素真实墙脚”，不要只看 PNG 画布底边。
- 院落专项测试 `tests/unit/courtyard_stage_builder_test.gd` 已守护这些数值，修改建筑比例时要同步更新测试和本文档。

## 实现规则

- 暂不直接修改 `scenes/main.tscn` 的复杂节点树。
- `CourtyardStageBuilder.rebuild()` 在运行时隐藏旧 `ColorRect` 占位视觉，再生成新的院落视觉层。
- Builder 只负责视觉节点，当前支持 `ColorRect`、`Polygon2D`、`Line2D` 和 `Sprite2D`，所有生成节点加入 `generated_courtyard_stage` 组。
- `kind = "sprite"` 的条目必须提供 `texture`、`pos`、`size` 和 `z`；builder 会把 `Sprite2D.centered` 设为 `false`，因此 `pos` 表示素材左上角，方便按建筑墙脚线对齐。
- 玩法节点继续保留在主场景里：`Player`、NPC、`HouseDoor` 触发器不由 builder 创建。
- `main.gd` 的 `_align_legacy_gameplay_anchors()` 会移动旧的 `House`、`OldHouse`、树节点，让原有入口触发器和碰撞跟新构图对齐。
- 可调查物继续使用 `InteractableObject`，当前包括水井、圆石桌、晾衣绳、摩托、小卖部门口。
- 放在玩家行走带里的调查点必须设置 `blocks_player = false`，避免再次出现家具或道具挡路。

## 后续替换真实美术时

不要把整张参考图直接塞进游戏。应按以下层级逐步替换：

1. `CourtyardSky` / `CourtyardFarHills` / `CourtyardFarVillage*`
2. `CourtyardMidTrees`
3. `CourtyardYardPerspective*` / `CourtyardOpenPlayBand` / `CourtyardGroundPerspectiveLine*`
4. `CourtyardMainHouse`：已替换为 `assets/sprites/Scenes/courtyard/main_house.png`；后续只调整素材、位置和缩放，不再恢复程序化立面细节。
5. `CourtyardOldHouse*`，注意正面、侧墙、正屋顶、侧屋顶必须拆层。
6. `CourtyardWell*` / `CourtyardStoneTable*` / 晾衣、盆栽、菜畦、电线等生活物件。
7. `CourtyardForegroundFence`。前景树影不要用程序化色块占位，等真实 PNG 素材到位后再新增。
8. `CourtyardWarmLight`

真实 PNG 素材建议放在 `assets/sprites/Scenes/courtyard/`，并继续保持“背景、中景、前景、光效、道具”的拆分。
