## 职责：三楼场景控制器——主角房间（房间结构在tscn中，代码管理家具和互动）
extends "res://scripts/scenes/area_controller_base.gd"

const InteriorStageBuilderScript := preload("res://scripts/scenes/interior_stage_builder.gd")

const SPAWN_POINTS := {
	"from_2f_up": Vector2(90, 390),
}

func _ready() -> void:
	_rebuild_visual_stage()
	_add_wall_collisions()
	_add_interactable_objects()
	setup_area_common()


func get_spawn_points() -> Dictionary:
	return SPAWN_POINTS


func get_post_process_config() -> Dictionary:
	return {
		"vignette_intensity": 0.3,
		"tint_color": Color(1.0, 0.88, 0.72, 0.14),
		"size": Vector2(510, 480),
	}


# ============================================================
# 室内舞台视觉
# ============================================================

func _rebuild_visual_stage() -> void:
	InteriorStageBuilderScript.rebuild(self, {
		"width": 510.0,
		"height": 480.0,
		"ceiling_h": 48.0,
		"floor_y": 340.0,
		"wall": 25.0,
		"side_bottom": 5.0,
		"palette": {
			"ceiling": Color(0.35, 0.43, 0.48, 1),
			"back_wall": Color(0.62, 0.72, 0.78, 1),
			"side_wall": Color(0.43, 0.5, 0.55, 1),
			"floor": Color(0.64, 0.62, 0.55, 1),
		},
		"lights": [
			{"name": "BlueMorningWash", "pos": Vector2(0, 56), "size": Vector2(510, 238), "color": Color(0.62, 0.77, 0.9, 0.16), "z": 55},
			{"name": "WindowLightBand", "pos": Vector2(92, 224), "size": Vector2(260, 48), "color": Color(0.9, 0.84, 0.64, 0.13), "z": 57},
			{"name": "FloorMist", "pos": Vector2(0, 398), "size": Vector2(510, 82), "color": Color(0.76, 0.78, 0.72, 0.24), "z": 93},
			{"name": "BottomSoftVignette", "pos": Vector2(0, 426), "size": Vector2(510, 54), "color": Color(0.12, 0.14, 0.14, 0.3), "z": 96},
		],
		"items": [
			{"name": "LeftStairDoorFrame", "pos": Vector2(10, 190), "size": Vector2(58, 150), "color": Color(0.28, 0.24, 0.28, 1), "z": -62},
			{"name": "LeftStairDoorPanel", "pos": Vector2(20, 204), "size": Vector2(38, 134), "color": Color(0.56, 0.46, 0.5, 1), "z": -61},
			{"name": "RooftopDoorFrame", "pos": Vector2(432, 168), "size": Vector2(54, 172), "color": Color(0.24, 0.22, 0.24, 1), "z": -62},
			{"name": "RooftopDoorPanel", "pos": Vector2(440, 184), "size": Vector2(38, 154), "color": Color(0.28, 0.24, 0.26, 1), "z": -61},
			{"name": "MainWindowFrame", "pos": Vector2(132, 126), "size": Vector2(198, 112), "color": Color(0.45, 0.39, 0.32, 1), "z": -50},
			{"name": "MainWindowPane", "pos": Vector2(140, 134), "size": Vector2(182, 96), "color": Color(0.62, 0.78, 0.88, 1), "z": -49},
			{"name": "WindowCrossH", "pos": Vector2(140, 180), "size": Vector2(182, 5), "color": Color(0.42, 0.36, 0.3, 1), "z": -48},
			{"name": "WindowCrossV", "pos": Vector2(228, 134), "size": Vector2(6, 96), "color": Color(0.42, 0.36, 0.3, 1), "z": -48},
			{"name": "PlanePoster", "pos": Vector2(108, 238), "size": Vector2(96, 58), "color": Color(0.45, 0.68, 0.82, 1), "z": -44},
			{"kind": "line", "name": "PlanePosterTapeA", "from": Vector2(112, 236), "to": Vector2(132, 244), "width": 4.0, "color": Color(0.86, 0.78, 0.56, 0.7), "z": -43},
			{"kind": "line", "name": "PlanePosterTapeB", "from": Vector2(184, 236), "to": Vector2(204, 244), "width": 4.0, "color": Color(0.86, 0.78, 0.56, 0.7), "z": -43},
			{"kind": "line", "name": "PixelPlaneWing", "from": Vector2(126, 266), "to": Vector2(180, 250), "width": 5.0, "color": Color(0.82, 0.86, 0.72, 0.72), "z": -43},
			{"kind": "line", "name": "PixelPlaneBody", "from": Vector2(136, 276), "to": Vector2(190, 276), "width": 5.0, "color": Color(0.36, 0.5, 0.66, 0.72), "z": -43},
			{"name": "SmallPosterA", "pos": Vector2(216, 236), "size": Vector2(42, 40), "color": Color(0.72, 0.58, 0.42, 1), "z": -44},
			{"name": "SmallPosterB", "pos": Vector2(270, 236), "size": Vector2(44, 52), "color": Color(0.34, 0.45, 0.58, 1), "z": -44},
			{"kind": "ellipse", "name": "WallToyMedalA", "pos": Vector2(222, 210), "size": Vector2(20, 20), "color": Color(0.68, 0.58, 0.26, 1), "z": -43},
			{"kind": "ellipse", "name": "WallToyMedalB", "pos": Vector2(250, 214), "size": Vector2(18, 18), "color": Color(0.5, 0.7, 0.42, 1), "z": -43},
			{"kind": "line", "name": "PaperBirdA", "from": Vector2(82, 214), "to": Vector2(104, 204), "width": 4.0, "color": Color(0.82, 0.48, 0.24, 1), "z": -43},
			{"kind": "line", "name": "PaperBirdB", "from": Vector2(104, 204), "to": Vector2(126, 214), "width": 4.0, "color": Color(0.36, 0.68, 0.82, 1), "z": -43},
			{"name": "BedBase", "pos": Vector2(28, 378), "size": Vector2(126, 24), "color": Color(0.38, 0.3, 0.22, 1), "z": 405},
			{"name": "BedBlanketTop", "pos": Vector2(30, 352), "size": Vector2(126, 18), "color": Color(0.48, 0.56, 0.62, 1), "z": 389},
			{"name": "BedBlanketFront", "pos": Vector2(30, 370), "size": Vector2(126, 20), "color": Color(0.34, 0.42, 0.5, 1), "z": 391},
			{"name": "BedStripeA", "pos": Vector2(36, 358), "size": Vector2(112, 3), "color": Color(0.68, 0.7, 0.66, 0.72), "z": 392},
			{"name": "BedStripeB", "pos": Vector2(36, 378), "size": Vector2(112, 3), "color": Color(0.64, 0.66, 0.62, 0.62), "z": 392},
			{"name": "PillowNew", "pos": Vector2(38, 338), "size": Vector2(42, 16), "color": Color(0.78, 0.76, 0.66, 1), "z": 391},
			{"name": "StudyDeskTop", "pos": Vector2(338, 350), "size": Vector2(108, 10), "color": Color(0.62, 0.58, 0.48, 1), "z": 369},
			{"name": "StudyDeskFront", "pos": Vector2(338, 360), "size": Vector2(108, 16), "color": Color(0.48, 0.44, 0.36, 1), "z": 376},
			{"name": "DeskLegLeft", "pos": Vector2(350, 376), "size": Vector2(8, 34), "color": Color(0.36, 0.32, 0.27, 1), "z": 411},
			{"name": "DeskLegRight", "pos": Vector2(430, 376), "size": Vector2(8, 34), "color": Color(0.36, 0.32, 0.27, 1), "z": 411},
			{"name": "HomeworkBook", "pos": Vector2(356, 336), "size": Vector2(42, 18), "color": Color(0.78, 0.75, 0.62, 1), "z": 370},
			{"name": "BlueSuitcase", "pos": Vector2(226, 364), "size": Vector2(34, 52), "color": Color(0.24, 0.42, 0.58, 1), "z": 417},
			{"name": "ToyRobotBody", "pos": Vector2(298, 342), "size": Vector2(28, 42), "color": Color(0.52, 0.63, 0.68, 1), "z": 385},
			{"name": "ToyRobotHead", "pos": Vector2(301, 322), "size": Vector2(22, 20), "color": Color(0.62, 0.72, 0.76, 1), "z": 386},
			{"name": "PlantPot", "pos": Vector2(404, 326), "size": Vector2(28, 28), "color": Color(0.5, 0.28, 0.18, 1), "z": 356},
			{"name": "PlantLeafA", "pos": Vector2(398, 304), "size": Vector2(16, 28), "color": Color(0.22, 0.48, 0.32, 1), "z": 357},
			{"name": "PlantLeafB", "pos": Vector2(418, 300), "size": Vector2(18, 32), "color": Color(0.26, 0.54, 0.35, 1), "z": 357},
			{"kind": "line", "name": "BedroomBaseLine", "from": Vector2(25, 340), "to": Vector2(485, 340), "width": 3.0, "color": Color(0.28, 0.32, 0.32, 0.44), "z": -38},
			{"kind": "line", "name": "CeilingPanelLineA", "from": Vector2(112, 4), "to": Vector2(128, 48), "width": 2.0, "color": Color(0.22, 0.28, 0.32, 0.2), "z": -40},
			{"kind": "line", "name": "CeilingPanelLineB", "from": Vector2(370, 2), "to": Vector2(352, 48), "width": 2.0, "color": Color(0.22, 0.28, 0.32, 0.2), "z": -40},
			{"kind": "line", "name": "TileLineA", "from": Vector2(28, 382), "to": Vector2(482, 376), "width": 2.0, "color": Color(0.46, 0.46, 0.42, 0.32), "z": 50},
			{"kind": "line", "name": "TileLineB", "from": Vector2(18, 424), "to": Vector2(492, 414), "width": 2.0, "color": Color(0.43, 0.43, 0.39, 0.28), "z": 50},
			{"name": "WindowLightPatchA", "pos": Vector2(94, 252), "size": Vector2(132, 28), "color": Color(0.9, 0.84, 0.64, 0.08), "z": 58},
			{"name": "WindowLightPatchB", "pos": Vector2(248, 246), "size": Vector2(110, 26), "color": Color(0.9, 0.84, 0.64, 0.06), "z": 58},
			{"name": "WindowLightPatchFloorA", "pos": Vector2(110, 330), "size": Vector2(112, 22), "color": Color(0.88, 0.82, 0.62, 0.06), "z": 58},
			{"name": "WindowLightPatchFloorB", "pos": Vector2(252, 324), "size": Vector2(96, 20), "color": Color(0.88, 0.82, 0.62, 0.05), "z": 58},
			{"kind": "line", "name": "BlanketFoldA", "from": Vector2(42, 366), "to": Vector2(146, 358), "width": 2.0, "color": Color(0.24, 0.32, 0.4, 0.5), "z": 392},
			{"kind": "line", "name": "BlanketFoldB", "from": Vector2(46, 382), "to": Vector2(152, 374), "width": 2.0, "color": Color(0.24, 0.32, 0.4, 0.42), "z": 392},
			{"name": "DeskLampBase", "pos": Vector2(406, 332), "size": Vector2(26, 8), "color": Color(0.38, 0.34, 0.3, 1), "z": 371},
			{"kind": "line", "name": "DeskLampNeck", "from": Vector2(414, 332), "to": Vector2(396, 312), "width": 3.0, "color": Color(0.36, 0.32, 0.28, 1), "z": 371},
			{"name": "DeskLampShade", "pos": Vector2(386, 304), "size": Vector2(26, 14), "color": Color(0.78, 0.62, 0.34, 1), "z": 372},
			{"kind": "line", "name": "PencilOnDesk", "from": Vector2(356, 332), "to": Vector2(388, 326), "width": 2.0, "color": Color(0.74, 0.44, 0.2, 1), "z": 371},
			{"name": "RobotChest", "pos": Vector2(304, 352), "size": Vector2(16, 10), "color": Color(0.82, 0.72, 0.32, 1), "z": 387},
			{"name": "RobotEyeLeft", "pos": Vector2(306, 329), "size": Vector2(4, 4), "color": Color(0.18, 0.24, 0.3, 1), "z": 387},
			{"name": "RobotEyeRight", "pos": Vector2(314, 329), "size": Vector2(4, 4), "color": Color(0.18, 0.24, 0.3, 1), "z": 387},
			{"kind": "ellipse", "name": "RobotWheelLeft", "pos": Vector2(300, 380), "size": Vector2(8, 8), "color": Color(0.26, 0.32, 0.36, 1), "z": 388},
			{"kind": "ellipse", "name": "RobotWheelRight", "pos": Vector2(318, 380), "size": Vector2(8, 8), "color": Color(0.26, 0.32, 0.36, 1), "z": 388},
			{"name": "PosterPinA", "pos": Vector2(112, 242), "size": Vector2(5, 5), "color": Color(0.72, 0.62, 0.42, 1), "z": -43},
			{"name": "PosterPinB", "pos": Vector2(196, 242), "size": Vector2(5, 5), "color": Color(0.72, 0.62, 0.42, 1), "z": -43},
		],
		"foreground": [
			{"name": "ForegroundBedShadow", "pos": Vector2(0, 430), "size": Vector2(180, 50), "color": Color(0.09, 0.08, 0.07, 0.46), "z": 104},
			{"name": "ForegroundDeskShadow", "pos": Vector2(330, 420), "size": Vector2(140, 48), "color": Color(0.1, 0.11, 0.1, 0.34), "z": 104},
		],
	})


# ============================================================
# 可互动物品
# ============================================================

func _add_interactable_objects() -> void:
	var bed := InteractableObject.new()
	bed.position = Vector2(27, 391)
	bed.object_name = "Bed"
	bed.description = "一张小木床，被子叠得整整齐齐。"
	bed.collision_w = 93
	bed.collision_h = 22
	add_child(bed)

	var desk := InteractableObject.new()
	desk.position = Vector2(338, 368)
	desk.object_name = "Desk"
	desk.description = "桌上放着课本和作业本，铅笔滚到了桌角。"
	desk.collision_w = 112
	desk.collision_h = 22
	add_child(desk)

	var window_obj := InteractableObject.new()
	window_obj.position = Vector2(132, 180)
	window_obj.object_name = "Window"
	window_obj.description = "窗外能看到村子的屋顶和远处的鱼塘，天很蓝。"
	window_obj.collision_w = 198
	window_obj.collision_h = 60
	add_child(window_obj)

	var suitcase := InteractableObject.new()
	suitcase.position = Vector2(226, 380)
	suitcase.object_name = "Suitcase"
	suitcase.description = "蓝色行李箱还没完全收好，像是在提醒你刚来到这里。"
	suitcase.collision_w = 42
	suitcase.collision_h = 40
	add_child(suitcase)

	var posters := InteractableObject.new()
	posters.position = Vector2(108, 270)
	posters.object_name = "Posters"
	posters.description = "墙上的飞机和机器人贴纸有点幼稚，却让这个小房间终于像自己的地方。"
	posters.collision_w = 206
	posters.collision_h = 36
	add_child(posters)

	var toy_robot := InteractableObject.new()
	toy_robot.position = Vector2(292, 360)
	toy_robot.object_name = "ToyRobot"
	toy_robot.description = "铁皮机器人站得很直，胸口的颜色有点掉漆，像是在替你守着房间。"
	toy_robot.collision_w = 40
	toy_robot.collision_h = 34
	add_child(toy_robot)

	var homework := InteractableObject.new()
	homework.position = Vector2(352, 348)
	homework.object_name = "HomeworkBook"
	homework.description = "作业本摊在桌上，铅笔压着还没写完的一行字。"
	homework.collision_w = 88
	homework.collision_h = 24
	add_child(homework)

	var window_light := InteractableObject.new()
	window_light.position = Vector2(150, 306)
	window_light.object_name = "WindowLight"
	window_light.description = "窗格的影子落在地上，一块一块的亮，像可以踩上去。"
	window_light.collision_w = 190
	window_light.collision_h = 56
	add_child(window_light)


# ============================================================
# 碰撞体
# ============================================================

func _add_wall_collisions() -> void:
	_add_hitbox("WallLeftTop", Vector2(0, 0), Vector2(27, 280))
	_add_hitbox("WallLeftBot", Vector2(0, 340), Vector2(27, 140))
	_add_hitbox("WallRightTop", Vector2(483, 0), Vector2(27, 280))
	_add_hitbox("WallRightBot", Vector2(483, 340), Vector2(27, 140))


func _add_hitbox(obj_name: String, pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = obj_name
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	shape.position = size / 2.0
	body.add_child(shape)
	add_child(body)
