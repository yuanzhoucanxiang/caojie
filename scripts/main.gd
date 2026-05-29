## 职责：主场景控制器——绑定NPC、监听对话信号暂停/恢复玩家
## 谁使用它：Godot 引擎（自动加载此场景）
## 它使用谁：DialogueManager、Player、所有 NPC

extends "res://scripts/scenes/area_controller_base.gd"

const CourtyardStageBuilderScript := preload("res://scripts/scenes/courtyard_stage_builder.gd")

const SPAWN_POINTS := {
	"from_house": Vector2(575, 385),
	"from_3f_rooftop": Vector2(575, 385),
}

const COLLISION_THRESHOLD: float = 25.0

var _collision_bodies: Array[Dictionary] = []

func _ready() -> void:
	_rebuild_courtyard_stage()
	_apply_textures()
	_add_depth_collisions()
	_add_courtyard_interactable_objects()
	setup_area_common()


func get_spawn_points() -> Dictionary:
	return SPAWN_POINTS


func get_post_process_config() -> Dictionary:
	return {
		"vignette_intensity": 0.32,
		"tint_color": Color(1.0, 0.88, 0.72, 0.12),
		"size": Vector2(1710, 900),
	}


func _rebuild_courtyard_stage() -> void:
	_align_legacy_gameplay_anchors()
	CourtyardStageBuilderScript.rebuild(self, {
		"items": [
			{"name": "CourtyardSky", "pos": Vector2(0, -260), "size": Vector2(1710, 520), "color": Color(0.7, 0.67, 0.54, 1), "z": -340},
			{"name": "CourtyardCloudBand", "pos": Vector2(560, 36), "size": Vector2(720, 72), "color": Color(0.86, 0.78, 0.58, 0.28), "z": -332},
			{"kind": "poly", "name": "CourtyardFarHills", "points": [Vector2(0, 244), Vector2(260, 206), Vector2(560, 240), Vector2(860, 198), Vector2(1210, 232), Vector2(1710, 202), Vector2(1710, 326), Vector2(0, 326)], "color": Color(0.45, 0.5, 0.38, 1), "z": -320},
			{"name": "CourtyardFarVillageA", "pos": Vector2(1020, 220), "size": Vector2(58, 52), "color": Color(0.66, 0.59, 0.46, 0.86), "z": -310},
			{"name": "CourtyardFarVillageB", "pos": Vector2(1100, 204), "size": Vector2(72, 68), "color": Color(0.72, 0.64, 0.48, 0.8), "z": -310},
			{"name": "CourtyardFarVillageC", "pos": Vector2(1206, 226), "size": Vector2(64, 46), "color": Color(0.62, 0.56, 0.44, 0.76), "z": -310},
			{"name": "CourtyardMidTrees", "pos": Vector2(0, 252), "size": Vector2(1710, 116), "color": Color(0.34, 0.43, 0.28, 0.92), "z": -300},
			{"name": "CourtyardYardGround", "pos": Vector2(0, 360), "size": Vector2(1710, 540), "color": Color(0.5, 0.43, 0.31, 1), "z": -90},
			{"kind": "poly", "name": "CourtyardPathWash", "points": [Vector2(220, 360), Vector2(880, 360), Vector2(1140, 900), Vector2(80, 900)], "color": Color(0.58, 0.5, 0.36, 0.7), "z": -82},
			{"name": "CourtyardMainHouse", "pos": Vector2(388, 104), "size": Vector2(248, 256), "color": Color(0.62, 0.48, 0.36, 1), "z": 328},
			{"name": "CourtyardMainHouseSide", "pos": Vector2(636, 132), "size": Vector2(58, 228), "color": Color(0.48, 0.38, 0.3, 1), "z": 326},
			{"name": "CourtyardMainRoof", "pos": Vector2(366, 72), "size": Vector2(292, 36), "color": Color(0.42, 0.19, 0.16, 1), "z": 329},
			{"name": "CourtyardBalcony1", "pos": Vector2(372, 174), "size": Vector2(286, 28), "color": Color(0.72, 0.64, 0.48, 0.86), "z": 331},
			{"name": "CourtyardBalcony2", "pos": Vector2(372, 270), "size": Vector2(286, 28), "color": Color(0.72, 0.64, 0.48, 0.78), "z": 331},
			{"name": "CourtyardShopSign", "pos": Vector2(416, 282), "size": Vector2(110, 28), "color": Color(0.32, 0.45, 0.28, 1), "z": 333},
			{"name": "CourtyardDoor", "pos": Vector2(548, 302), "size": Vector2(56, 58), "color": Color(0.36, 0.22, 0.16, 1), "z": 334},
			{"name": "CourtyardWindowA", "pos": Vector2(426, 126), "size": Vector2(46, 38), "color": Color(0.68, 0.66, 0.5, 1), "z": 334},
			{"name": "CourtyardWindowB", "pos": Vector2(548, 126), "size": Vector2(46, 38), "color": Color(0.68, 0.66, 0.5, 1), "z": 334},
			{"name": "CourtyardWindowC", "pos": Vector2(428, 220), "size": Vector2(44, 34), "color": Color(0.72, 0.66, 0.48, 1), "z": 334},
			{"name": "CourtyardWindowD", "pos": Vector2(548, 220), "size": Vector2(44, 34), "color": Color(0.72, 0.66, 0.48, 1), "z": 334},
			{"kind": "line", "name": "CourtyardTileLineA", "from": Vector2(396, 142), "to": Vector2(628, 142), "width": 1.0, "color": Color(0.34, 0.24, 0.18, 0.28), "z": 335},
			{"kind": "line", "name": "CourtyardTileLineB", "from": Vector2(396, 238), "to": Vector2(628, 238), "width": 1.0, "color": Color(0.34, 0.24, 0.18, 0.24), "z": 335},
			{"name": "CourtyardOldHouse", "pos": Vector2(682, 246), "size": Vector2(202, 114), "color": Color(0.66, 0.51, 0.34, 1), "z": 332},
			{"kind": "poly", "name": "CourtyardOldHouseRoof", "points": [Vector2(662, 226), Vector2(904, 226), Vector2(884, 252), Vector2(682, 252)], "color": Color(0.28, 0.22, 0.18, 1), "z": 333},
			{"name": "CourtyardOldHouseDoor", "pos": Vector2(748, 306), "size": Vector2(42, 54), "color": Color(0.36, 0.24, 0.16, 1), "z": 334},
			{"name": "CourtyardOldHouseWindow", "pos": Vector2(812, 286), "size": Vector2(38, 28), "color": Color(0.7, 0.62, 0.42, 1), "z": 334},
			{"kind": "ellipse", "name": "CourtyardWell", "pos": Vector2(470, 374), "size": Vector2(92, 28), "color": Color(0.48, 0.44, 0.34, 1), "z": 398},
			{"name": "CourtyardWellBase", "pos": Vector2(486, 348), "size": Vector2(60, 38), "color": Color(0.42, 0.39, 0.32, 1), "z": 382},
			{"kind": "ellipse", "name": "CourtyardStoneTable", "pos": Vector2(296, 388), "size": Vector2(112, 28), "color": Color(0.54, 0.5, 0.4, 1), "z": 416},
			{"name": "CourtyardStoneTableLeg", "pos": Vector2(342, 410), "size": Vector2(18, 42), "color": Color(0.4, 0.36, 0.28, 1), "z": 452},
			{"name": "CourtyardScooterBody", "pos": Vector2(230, 386), "size": Vector2(72, 28), "color": Color(0.16, 0.13, 0.12, 1), "z": 418},
			{"kind": "ellipse", "name": "CourtyardScooterWheelA", "pos": Vector2(230, 410), "size": Vector2(18, 18), "color": Color(0.08, 0.07, 0.06, 1), "z": 430},
			{"kind": "ellipse", "name": "CourtyardScooterWheelB", "pos": Vector2(282, 410), "size": Vector2(18, 18), "color": Color(0.08, 0.07, 0.06, 1), "z": 430},
			{"kind": "line", "name": "CourtyardClothesline", "from": Vector2(944, 286), "to": Vector2(1240, 270), "width": 3.0, "color": Color(0.18, 0.14, 0.1, 0.72), "z": 345},
			{"name": "CourtyardClothesPoleA", "pos": Vector2(942, 264), "size": Vector2(7, 122), "color": Color(0.28, 0.2, 0.13, 1), "z": 386},
			{"name": "CourtyardClothesPoleB", "pos": Vector2(1238, 250), "size": Vector2(7, 128), "color": Color(0.28, 0.2, 0.13, 1), "z": 386},
			{"name": "CourtyardClothA", "pos": Vector2(980, 288), "size": Vector2(32, 58), "color": Color(0.78, 0.72, 0.58, 1), "z": 346},
			{"name": "CourtyardClothB", "pos": Vector2(1032, 284), "size": Vector2(36, 64), "color": Color(0.42, 0.56, 0.62, 1), "z": 346},
			{"name": "CourtyardClothC", "pos": Vector2(1092, 282), "size": Vector2(30, 52), "color": Color(0.72, 0.5, 0.44, 1), "z": 346},
			{"name": "CourtyardVegetableBed", "pos": Vector2(960, 398), "size": Vector2(276, 42), "color": Color(0.34, 0.42, 0.24, 1), "z": 442},
			{"name": "CourtyardForegroundShade", "pos": Vector2(0, 0), "size": Vector2(190, 480), "color": Color(0.05, 0.07, 0.045, 0.58), "z": 860},
			{"name": "CourtyardForegroundFence", "pos": Vector2(0, 444), "size": Vector2(360, 34), "color": Color(0.18, 0.12, 0.08, 0.86), "z": 862},
			{"kind": "line", "name": "CourtyardForegroundBranch", "from": Vector2(0, 86), "to": Vector2(286, 20), "width": 18.0, "color": Color(0.06, 0.075, 0.05, 0.9), "z": 864},
			{"name": "CourtyardWarmLight", "pos": Vector2(0, 0), "size": Vector2(1710, 480), "color": Color(0.94, 0.76, 0.46, 0.1), "z": 850},
		],
	})


func _align_legacy_gameplay_anchors() -> void:
	var house := get_node_or_null("House") as Node2D
	if house:
		house.position = Vector2(468, 120)
	var old_house := get_node_or_null("OldHouse") as Node2D
	if old_house:
		old_house.position = Vector2(682, 267)
	var yard_tree := get_node_or_null("YardTree") as Node2D
	if yard_tree:
		yard_tree.position = Vector2(120, 360)
	var tree1 := get_node_or_null("Tree1") as Node2D
	if tree1:
		tree1.position = Vector2(918, 404)
	var tree2 := get_node_or_null("Tree2") as Node2D
	if tree2:
		tree2.position = Vector2(1260, 420)


func _add_courtyard_interactable_objects() -> void:
	var well := InteractableObject.new()
	well.position = Vector2(486, 386)
	well.object_name = "CourtyardWellObject"
	well.description = "井沿被摸得发亮，井口旁边还放着一个旧水桶。外婆总说打水时要小心脚下。"
	well.collision_w = 60
	well.collision_h = 24
	add_child(well)

	var stone_table := InteractableObject.new()
	stone_table.position = Vector2(296, 404)
	stone_table.object_name = "CourtyardStoneTableObject"
	stone_table.description = "圆石桌被太阳晒得温热，桌边的矮凳像是一直在等人坐下来吃饭。"
	stone_table.collision_w = 112
	stone_table.collision_h = 22
	stone_table.blocks_player = false
	add_child(stone_table)

	var clothesline := InteractableObject.new()
	clothesline.position = Vector2(980, 336)
	clothesline.object_name = "CourtyardClotheslineObject"
	clothesline.description = "衣服挂在绳上慢慢晃，洗衣粉的味道混着院子里的泥土味。"
	clothesline.collision_w = 150
	clothesline.collision_h = 28
	clothesline.blocks_player = false
	add_child(clothesline)

	var scooter := InteractableObject.new()
	scooter.position = Vector2(230, 416)
	scooter.object_name = "CourtyardScooterObject"
	scooter.description = "一辆旧摩托停在院角，车牌沾着灰，像是刚从镇上回来不久。"
	scooter.collision_w = 72
	scooter.collision_h = 22
	add_child(scooter)

	var shop_counter := InteractableObject.new()
	shop_counter.position = Vector2(416, 316)
	shop_counter.object_name = "CourtyardShopCounterObject"
	shop_counter.description = "小卖部门口摆着零食和汽水，柜台后面的阴影里透出一点凉意。"
	shop_counter.collision_w = 110
	shop_counter.collision_h = 28
	shop_counter.blocks_player = false
	add_child(shop_counter)


func _apply_textures() -> void:
	var rules := {
		"CourtyardSky": [TextureSetup.Pattern.NOISE, 220.0, 0.025],
		"CourtyardFarHills": [TextureSetup.Pattern.NOISE, 160.0, 0.04],
		"CourtyardMidTrees": [TextureSetup.Pattern.GRASS, 80.0, 0.08],
		"CourtyardYardGround": [TextureSetup.Pattern.DIRT, 70.0, 0.1],
		"CourtyardPathWash": [TextureSetup.Pattern.DIRT, 90.0, 0.08],
		"CourtyardMainHouse": [TextureSetup.Pattern.BRICK, 38.0, 0.08],
		"CourtyardOldHouse": [TextureSetup.Pattern.DIRT, 54.0, 0.08],
		"CourtyardOldHouseRoof": [TextureSetup.Pattern.NOISE, 42.0, 0.08],
		"CourtyardWellBase": [TextureSetup.Pattern.NOISE, 36.0, 0.08],
		"CourtyardClothesPole": [TextureSetup.Pattern.WOOD_V, 28.0, 0.1],
		"CourtyardForegroundFence": [TextureSetup.Pattern.WOOD_H, 34.0, 0.1],
		"GrassBack": [TextureSetup.Pattern.GRASS, 80.0, 0.08],
		"GrassMid": [TextureSetup.Pattern.GRASS, 80.0, 0.09],
		"GrassFront": [TextureSetup.Pattern.GRASS, 80.0, 0.1],
		"PathBack": [TextureSetup.Pattern.DIRT, 80.0, 0.08],
		"PathMid": [TextureSetup.Pattern.DIRT, 80.0, 0.1],
		"PathFront": [TextureSetup.Pattern.DIRT, 80.0, 0.1],
		"TreeFar": [TextureSetup.Pattern.GRASS, 50.0, 0.06],
		"TreeNear": [TextureSetup.Pattern.GRASS, 50.0, 0.07],
		"TreeTrunk": [TextureSetup.Pattern.WOOD_V, 40.0, 0.12],
		"TreeCrown": [TextureSetup.Pattern.GRASS, 50.0, 0.1],
		"OldHouseRoof": [TextureSetup.Pattern.NOISE, 50.0, 0.06],
		"OldHouseWall": [TextureSetup.Pattern.DIRT, 60.0, 0.08],
		"HouseRoof": [TextureSetup.Pattern.NOISE, 60.0, 0.08],
		"HouseBody": [TextureSetup.Pattern.BRICK, 80.0, 0.1],
		"WellBody": [TextureSetup.Pattern.NOISE, 60.0, 0.1],
		"ChickenCoop": [TextureSetup.Pattern.WOOD_H, 40.0, 0.12],
		"Pole": [TextureSetup.Pattern.WOOD_V, 30.0, 0.1],
		"FencePost": [TextureSetup.Pattern.WOOD_V, 30.0, 0.12],
		"FenceRail": [TextureSetup.Pattern.WOOD_H, 40.0, 0.12],
		"Blade": [TextureSetup.Pattern.GRASS, 40.0, 0.08],
		"ForegroundBush": [TextureSetup.Pattern.GRASS, 60.0, 0.08],
		"FarHills": [TextureSetup.Pattern.NOISE, 150.0, 0.04],
		"MidHills": [TextureSetup.Pattern.NOISE, 120.0, 0.05],
		"Sky": [TextureSetup.Pattern.NOISE, 200.0, 0.03],
		"YardGround": [TextureSetup.Pattern.DIRT, 80.0, 0.1],
	}
	TextureSetup.apply_by_name(self, rules)


func _add_depth_collisions() -> void:
	# 院落主屋和老屋只挡住贴近墙脚的一小段，避免把前院行走带堵死。
	_add_body("House", 226, 240, 360)
	_add_body("House", 226, 240, 360)
	_add_body("OldHouse", 202, 93, 360)
	_add_body("YardTree", 18, 0, 360)
	_add_body("Tree1", 12, 0, 404)
	_add_body("Tree2", 16, 0, 420)


func _add_body(node_path: String, w: float, h: float, ground_y: float) -> void:
	var parent := get_node_or_null(node_path)
	if not parent:
		return
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, 20)
	shape.shape = rect
	shape.position = Vector2(w / 2.0, h)
	body.add_child(shape)
	parent.add_child(body)
	_collision_bodies.append({"body": body, "ground_y": ground_y})


func _physics_process(_delta: float) -> void:
	if not player:
		return
	for data in _collision_bodies:
		var body: StaticBody2D = data["body"]
		var dist := absf(player.position.y - data["ground_y"])
		body.set_collision_layer_value(1, dist < COLLISION_THRESHOLD)
