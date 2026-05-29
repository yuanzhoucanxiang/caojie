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
			{"name": "CourtyardRearGroundApron", "pos": Vector2(0, 348), "size": Vector2(1710, 54), "color": Color(0.51, 0.44, 0.31, 1), "z": -91},
			{"name": "CourtyardYardGround", "pos": Vector2(0, 368), "size": Vector2(1710, 532), "color": Color(0.5, 0.43, 0.31, 1), "z": -90},
			{"kind": "poly", "name": "CourtyardYardPerspectiveFar", "points": [Vector2(322, 364), Vector2(968, 364), Vector2(1190, 900), Vector2(72, 900)], "color": Color(0.56, 0.49, 0.36, 0.58), "z": -86},
			{"kind": "poly", "name": "CourtyardPathWash", "points": [Vector2(390, 374), Vector2(850, 374), Vector2(1128, 900), Vector2(180, 900)], "color": Color(0.61, 0.53, 0.38, 0.52), "z": -84},
			{"kind": "poly", "name": "CourtyardYardPerspectiveNear", "points": [Vector2(0, 458), Vector2(1710, 432), Vector2(1710, 900), Vector2(0, 900)], "color": Color(0.45, 0.38, 0.27, 0.36), "z": -80},
			{"kind": "poly", "name": "CourtyardOpenPlayBand", "points": [Vector2(116, 386), Vector2(1480, 374), Vector2(1610, 528), Vector2(32, 536)], "color": Color(0.67, 0.58, 0.4, 0.18), "z": -76},
			{"kind": "line", "name": "CourtyardGroundPerspectiveLineA", "from": Vector2(360, 374), "to": Vector2(112, 900), "width": 1.4, "color": Color(0.3, 0.24, 0.16, 0.22), "z": -74},
			{"kind": "line", "name": "CourtyardGroundPerspectiveLineB", "from": Vector2(538, 374), "to": Vector2(444, 900), "width": 1.2, "color": Color(0.3, 0.24, 0.16, 0.2), "z": -74},
			{"kind": "line", "name": "CourtyardGroundPerspectiveLineC", "from": Vector2(738, 374), "to": Vector2(876, 900), "width": 1.2, "color": Color(0.3, 0.24, 0.16, 0.2), "z": -74},
			{"kind": "line", "name": "CourtyardGroundPerspectiveLineD", "from": Vector2(916, 374), "to": Vector2(1350, 900), "width": 1.4, "color": Color(0.3, 0.24, 0.16, 0.22), "z": -74},
			{"kind": "line", "name": "CourtyardGroundCrossLineA", "from": Vector2(128, 460), "to": Vector2(1540, 438), "width": 1.0, "color": Color(0.3, 0.24, 0.16, 0.18), "z": -73},
			{"kind": "line", "name": "CourtyardGroundCrossLineB", "from": Vector2(72, 512), "to": Vector2(1618, 492), "width": 1.0, "color": Color(0.3, 0.24, 0.16, 0.16), "z": -73},
			{"kind": "ellipse", "name": "CourtyardMainHouseContactShadow", "pos": Vector2(336, 340), "size": Vector2(354, 28), "color": Color(0.18, 0.13, 0.09, 0.18), "z": 320},
			{"kind": "ellipse", "name": "CourtyardOldHouseContactShadow", "pos": Vector2(700, 340), "size": Vector2(306, 26), "color": Color(0.18, 0.13, 0.09, 0.2), "z": 320},
			{"kind": "sprite", "name": "CourtyardMainHouse", "texture": "res://assets/sprites/Scenes/courtyard/main_house.png", "pos": Vector2(337, 81), "size": Vector2(313, 272), "z": 328},
			{"name": "CourtyardMainHouseGroundLip", "pos": Vector2(350, 348), "size": Vector2(286, 9), "color": Color(0.2, 0.14, 0.09, 0.24), "z": 329},
			{"kind": "sprite", "name": "CourtyardOldHouse", "texture": "res://assets/sprites/Scenes/courtyard/old_house.png", "pos": Vector2(690, 138), "size": Vector2(326, 215), "z": 332},
			{"name": "CourtyardOldHouseGroundLip", "pos": Vector2(712, 348), "size": Vector2(284, 9), "color": Color(0.2, 0.14, 0.09, 0.22), "z": 333},
			{"name": "CourtyardPottedPlantA", "pos": Vector2(682, 330), "size": Vector2(17, 22), "color": Color(0.28, 0.38, 0.2, 1), "z": 354},
			{"name": "CourtyardPottedPlantPotA", "pos": Vector2(680, 348), "size": Vector2(21, 11), "color": Color(0.48, 0.28, 0.18, 1), "z": 360},
			{"kind": "ellipse", "name": "CourtyardWell", "pos": Vector2(560, 370), "size": Vector2(92, 28), "color": Color(0.48, 0.44, 0.34, 1), "z": 398},
			{"name": "CourtyardWellBase", "pos": Vector2(576, 344), "size": Vector2(60, 38), "color": Color(0.42, 0.39, 0.32, 1), "z": 382},
			{"kind": "ellipse", "name": "CourtyardStoneTable", "pos": Vector2(392, 396), "size": Vector2(112, 28), "color": Color(0.54, 0.5, 0.4, 1), "z": 416},
			{"name": "CourtyardStoneTableLeg", "pos": Vector2(438, 418), "size": Vector2(18, 42), "color": Color(0.4, 0.36, 0.28, 1), "z": 452},
			{"name": "CourtyardScooterBody", "pos": Vector2(220, 402), "size": Vector2(72, 28), "color": Color(0.16, 0.13, 0.12, 1), "z": 418},
			{"kind": "ellipse", "name": "CourtyardScooterWheelA", "pos": Vector2(220, 426), "size": Vector2(18, 18), "color": Color(0.08, 0.07, 0.06, 1), "z": 430},
			{"kind": "ellipse", "name": "CourtyardScooterWheelB", "pos": Vector2(272, 426), "size": Vector2(18, 18), "color": Color(0.08, 0.07, 0.06, 1), "z": 430},
			{"kind": "line", "name": "CourtyardClothesline", "from": Vector2(966, 292), "to": Vector2(1288, 272), "width": 3.0, "color": Color(0.18, 0.14, 0.1, 0.72), "z": 345},
			{"kind": "line", "name": "CourtyardPowerLineA", "from": Vector2(1010, 190), "to": Vector2(1478, 146), "width": 2.0, "color": Color(0.12, 0.09, 0.07, 0.62), "z": 338},
			{"kind": "line", "name": "CourtyardPowerLineB", "from": Vector2(1014, 210), "to": Vector2(1482, 168), "width": 1.6, "color": Color(0.12, 0.09, 0.07, 0.5), "z": 338},
			{"name": "CourtyardClothesPoleA", "pos": Vector2(964, 270), "size": Vector2(7, 122), "color": Color(0.28, 0.2, 0.13, 1), "z": 386},
			{"name": "CourtyardClothesPoleB", "pos": Vector2(1286, 252), "size": Vector2(7, 128), "color": Color(0.28, 0.2, 0.13, 1), "z": 386},
			{"name": "CourtyardClothA", "pos": Vector2(1002, 294), "size": Vector2(32, 58), "color": Color(0.78, 0.72, 0.58, 1), "z": 346},
			{"name": "CourtyardClothB", "pos": Vector2(1054, 290), "size": Vector2(36, 64), "color": Color(0.42, 0.56, 0.62, 1), "z": 346},
			{"name": "CourtyardClothC", "pos": Vector2(1114, 288), "size": Vector2(30, 52), "color": Color(0.72, 0.5, 0.44, 1), "z": 346},
			{"name": "CourtyardVegetableBed", "pos": Vector2(990, 404), "size": Vector2(286, 42), "color": Color(0.34, 0.42, 0.24, 1), "z": 442},
			{"name": "CourtyardForegroundFence", "pos": Vector2(0, 450), "size": Vector2(356, 30), "color": Color(0.18, 0.12, 0.08, 0.86), "z": 862},
			{"name": "CourtyardWarmLight", "pos": Vector2(0, 0), "size": Vector2(1710, 480), "color": Color(0.94, 0.76, 0.46, 0.1), "z": 850},
		],
	})


func _align_legacy_gameplay_anchors() -> void:
	var house := get_node_or_null("House") as Node2D
	if house:
		house.position = Vector2(430, 104)
	var old_house := get_node_or_null("OldHouse") as Node2D
	if old_house:
		old_house.position = Vector2(720, 262)
	var yard_tree := get_node_or_null("YardTree") as Node2D
	if yard_tree:
		yard_tree.position = Vector2(120, 360)
	var tree1 := get_node_or_null("Tree1") as Node2D
	if tree1:
		tree1.position = Vector2(946, 404)
	var tree2 := get_node_or_null("Tree2") as Node2D
	if tree2:
		tree2.position = Vector2(1290, 420)


func _add_courtyard_interactable_objects() -> void:
	var well := InteractableObject.new()
	well.position = Vector2(576, 382)
	well.object_name = "CourtyardWellObject"
	well.description = "井沿被摸得发亮，井口旁边还放着一个旧水桶。外婆总说打水时要小心脚下。"
	well.collision_w = 60
	well.collision_h = 24
	add_child(well)

	var stone_table := InteractableObject.new()
	stone_table.position = Vector2(392, 412)
	stone_table.object_name = "CourtyardStoneTableObject"
	stone_table.description = "圆石桌被太阳晒得温热，桌边的矮凳像是一直在等人坐下来吃饭。"
	stone_table.collision_w = 112
	stone_table.collision_h = 22
	stone_table.blocks_player = false
	add_child(stone_table)

	var clothesline := InteractableObject.new()
	clothesline.position = Vector2(1002, 342)
	clothesline.object_name = "CourtyardClotheslineObject"
	clothesline.description = "衣服挂在绳上慢慢晃，洗衣粉的味道混着院子里的泥土味。"
	clothesline.collision_w = 150
	clothesline.collision_h = 28
	clothesline.blocks_player = false
	add_child(clothesline)

	var scooter := InteractableObject.new()
	scooter.position = Vector2(220, 432)
	scooter.object_name = "CourtyardScooterObject"
	scooter.description = "一辆旧摩托停在院角，车牌沾着灰，像是刚从镇上回来不久。"
	scooter.collision_w = 72
	scooter.collision_h = 22
	add_child(scooter)

	var shop_counter := InteractableObject.new()
	shop_counter.position = Vector2(384, 306)
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
		"CourtyardRearGroundApron": [TextureSetup.Pattern.DIRT, 78.0, 0.09],
		"CourtyardYardGround": [TextureSetup.Pattern.DIRT, 70.0, 0.1],
		"CourtyardYardPerspective": [TextureSetup.Pattern.DIRT, 92.0, 0.07],
		"CourtyardPathWash": [TextureSetup.Pattern.DIRT, 90.0, 0.08],
		"CourtyardOldHouse": [TextureSetup.Pattern.DIRT, 54.0, 0.08],
		"CourtyardOldHouseSideWall": [TextureSetup.Pattern.DIRT, 48.0, 0.08],
		"CourtyardOldHouseRoof": [TextureSetup.Pattern.NOISE, 42.0, 0.08],
		"CourtyardOldHouseSideRoof": [TextureSetup.Pattern.NOISE, 36.0, 0.08],
		"CourtyardWellBase": [TextureSetup.Pattern.NOISE, 36.0, 0.08],
		"CourtyardPottedPlant": [TextureSetup.Pattern.GRASS, 28.0, 0.1],
		"CourtyardPottedPlantPot": [TextureSetup.Pattern.DIRT, 24.0, 0.08],
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
	_add_body("House", 232, 244, 348)
	_add_body("OldHouse", 214, 86, 348)
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
