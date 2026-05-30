## 职责：一楼场景控制器——大屋生活区（房间结构在tscn中）
extends "res://scripts/scenes/area_controller_base.gd"

const InteriorStageBuilderScript := preload("res://scripts/scenes/interior_stage_builder.gd")

const SPAWN_POINTS := {
	"from_outside": Vector2(200, 370),
	"from_2f_down": Vector2(650, 370),
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
		"vignette_intensity": 0.2,
		"tint_color": Color(1.0, 0.9, 0.75, 0.12),
		"size": Vector2(750, 480),
	}


# ============================================================
# 可互动物品
# ============================================================

func _rebuild_visual_stage() -> void:
	InteriorStageBuilderScript.rebuild(self, {
		"width": 750.0,
		"height": 480.0,
		"ceiling_h": 52.0,
		"floor_y": 340.0,
		"wall": 30.0,
		"side_bottom": 8.0,
		"palette": {
			"ceiling": Color(0.24, 0.2, 0.16, 1),
			"back_wall": Color(0.63, 0.56, 0.44, 1),
			"side_wall": Color(0.37, 0.31, 0.24, 1),
			"floor": Color(0.42, 0.32, 0.22, 1),
		},
		"lights": [
			{"name": "TopSmokeShadow", "pos": Vector2(0, 0), "size": Vector2(750, 118), "color": Color(0.08, 0.06, 0.04, 0.34), "z": 58},
			{"name": "KitchenWarmGlow", "pos": Vector2(92, 178), "size": Vector2(226, 154), "color": Color(0.92, 0.62, 0.34, 0.16), "z": 56},
			{"name": "DoorCoolFalloff", "pos": Vector2(555, 96), "size": Vector2(126, 250), "color": Color(0.28, 0.22, 0.18, 0.28), "z": 57},
			{"name": "ForegroundWarmVignette", "pos": Vector2(0, 404), "size": Vector2(750, 76), "color": Color(0.08, 0.05, 0.03, 0.4), "z": 92},
		],
		"items": [
			{"name": "LeftExitDoorDark", "pos": Vector2(8, 196), "size": Vector2(54, 144), "color": Color(0.2, 0.15, 0.11, 1), "z": -76},
			{"name": "LeftExitDoorPanel", "pos": Vector2(18, 210), "size": Vector2(34, 128), "color": Color(0.39, 0.29, 0.19, 1), "z": -68},
			{"name": "RightStairDoorDark", "pos": Vector2(690, 198), "size": Vector2(48, 142), "color": Color(0.19, 0.14, 0.1, 1), "z": -76},
			{"name": "RightStairDoorPanel", "pos": Vector2(698, 211), "size": Vector2(28, 126), "color": Color(0.33, 0.25, 0.17, 1), "z": -68},
			{"name": "SmokeStainedWall", "pos": Vector2(92, 92), "size": Vector2(170, 178), "color": Color(0.18, 0.13, 0.1, 0.18), "z": -60},
			{"name": "OldStoveBody", "pos": Vector2(86, 266), "size": Vector2(124, 60), "color": Color(0.28, 0.24, 0.2, 1), "z": 332},
			{"name": "StoveTop", "pos": Vector2(96, 252), "size": Vector2(104, 16), "color": Color(0.16, 0.13, 0.11, 1), "z": 333},
			{"name": "SteamColumn", "pos": Vector2(132, 206), "size": Vector2(26, 54), "color": Color(0.78, 0.7, 0.58, 0.18), "z": 54},
			{"name": "ShelvesFrame", "pos": Vector2(248, 126), "size": Vector2(118, 190), "color": Color(0.42, 0.3, 0.18, 1), "z": 315},
			{"name": "ShelvesInner", "pos": Vector2(258, 140), "size": Vector2(98, 164), "color": Color(0.25, 0.19, 0.14, 1), "z": 316},
			{"name": "ShelfLine1", "pos": Vector2(258, 178), "size": Vector2(98, 5), "color": Color(0.5, 0.38, 0.23, 1), "z": 317},
			{"name": "ShelfLine2", "pos": Vector2(258, 224), "size": Vector2(98, 5), "color": Color(0.5, 0.38, 0.23, 1), "z": 317},
			{"name": "BowlsStack", "pos": Vector2(278, 152), "size": Vector2(42, 18), "color": Color(0.72, 0.64, 0.48, 1), "z": 318},
			{"name": "FoldedCloth", "pos": Vector2(274, 194), "size": Vector2(56, 14), "color": Color(0.49, 0.38, 0.27, 1), "z": 318},
			{"name": "BackCalendar", "pos": Vector2(430, 138), "size": Vector2(54, 70), "color": Color(0.78, 0.68, 0.52, 1), "z": -50},
			{"name": "BackCalendarRed", "pos": Vector2(430, 138), "size": Vector2(54, 12), "color": Color(0.58, 0.2, 0.16, 1), "z": -49},
			{"name": "OldRadioBody", "pos": Vector2(502, 152), "size": Vector2(62, 34), "color": Color(0.2, 0.17, 0.16, 1), "z": -48},
			{"name": "OldRadioScreen", "pos": Vector2(512, 160), "size": Vector2(34, 12), "color": Color(0.58, 0.42, 0.72, 0.82), "z": -47},
			{"kind": "line", "name": "OldRadioWaveA", "from": Vector2(516, 166), "to": Vector2(540, 166), "width": 2.0, "color": Color(0.86, 0.68, 0.9, 0.7), "z": -46},
			{"kind": "ellipse", "name": "OldRadioKnob", "pos": Vector2(548, 162), "size": Vector2(8, 8), "color": Color(0.74, 0.66, 0.54, 1), "z": -46},
			{"name": "FamilyPhotoA", "pos": Vector2(610, 160), "size": Vector2(30, 38), "color": Color(0.58, 0.42, 0.52, 0.86), "z": -50},
			{"name": "FamilyPhotoB", "pos": Vector2(644, 176), "size": Vector2(28, 34), "color": Color(0.64, 0.5, 0.38, 0.86), "z": -50},
			{"name": "FamilyPhotoGlow", "pos": Vector2(598, 192), "size": Vector2(86, 58), "color": Color(0.64, 0.38, 0.68, 0.16), "z": 57},
			{"name": "CeilingFanBox", "pos": Vector2(318, 42), "size": Vector2(112, 28), "color": Color(0.72, 0.66, 0.56, 1), "z": -72},
			{"kind": "line", "name": "CeilingFanSlot", "from": Vector2(334, 46), "to": Vector2(414, 46), "width": 3.0, "color": Color(0.32, 0.26, 0.2, 0.72), "z": -71},
			{"name": "RoundTableTop", "pos": Vector2(430, 364), "size": Vector2(150, 24), "color": Color(0.44, 0.31, 0.19, 1), "z": 388},
			{"name": "RoundTableLeg", "pos": Vector2(496, 386), "size": Vector2(16, 42), "color": Color(0.32, 0.23, 0.15, 1), "z": 429},
			{"name": "SmallStoolLeft", "pos": Vector2(392, 392), "size": Vector2(42, 16), "color": Color(0.35, 0.25, 0.17, 1), "z": 409},
			{"name": "WaterTank", "pos": Vector2(600, 262), "size": Vector2(54, 70), "color": Color(0.46, 0.5, 0.45, 1), "z": 333},
			{"kind": "line", "name": "BackWallBaseLine", "from": Vector2(32, 340), "to": Vector2(718, 340), "width": 3.0, "color": Color(0.22, 0.16, 0.11, 0.65), "z": -38},
			{"kind": "line", "name": "CeilingSmokeSeam", "from": Vector2(44, 52), "to": Vector2(706, 52), "width": 2.0, "color": Color(0.11, 0.08, 0.06, 0.38), "z": -39},
			{"kind": "line", "name": "FloorBoardLineA", "from": Vector2(48, 374), "to": Vector2(704, 362), "width": 2.0, "color": Color(0.27, 0.2, 0.14, 0.56), "z": 50},
			{"kind": "line", "name": "FloorBoardLineB", "from": Vector2(34, 408), "to": Vector2(720, 394), "width": 2.0, "color": Color(0.25, 0.18, 0.12, 0.5), "z": 50},
			{"kind": "line", "name": "FloorBoardLineC", "from": Vector2(28, 444), "to": Vector2(724, 430), "width": 2.0, "color": Color(0.21, 0.15, 0.1, 0.46), "z": 50},
			{"name": "StoveAshShadow", "pos": Vector2(78, 326), "size": Vector2(146, 18), "color": Color(0.08, 0.055, 0.035, 0.32), "z": 344},
			{"name": "StoveFireMouth", "pos": Vector2(122, 290), "size": Vector2(48, 16), "color": Color(0.7, 0.28, 0.16, 0.42), "z": 334},
			{"kind": "line", "name": "WokRim", "from": Vector2(104, 252), "to": Vector2(192, 252), "width": 5.0, "color": Color(0.08, 0.07, 0.06, 1), "z": 334},
			{"name": "ShelfJarA", "pos": Vector2(294, 238), "size": Vector2(18, 28), "color": Color(0.62, 0.54, 0.38, 1), "z": 318},
			{"name": "ShelfJarB", "pos": Vector2(320, 236), "size": Vector2(16, 30), "color": Color(0.36, 0.44, 0.38, 1), "z": 318},
			{"kind": "line", "name": "ShelfChopsticksA", "from": Vector2(284, 292), "to": Vector2(342, 284), "width": 2.0, "color": Color(0.68, 0.54, 0.34, 1), "z": 319},
			{"kind": "line", "name": "ShelfChopsticksB", "from": Vector2(286, 298), "to": Vector2(344, 290), "width": 2.0, "color": Color(0.64, 0.48, 0.3, 1), "z": 319},
			{"name": "TableRiceBowl", "pos": Vector2(466, 354), "size": Vector2(26, 12), "color": Color(0.78, 0.72, 0.6, 1), "z": 389},
			{"kind": "ellipse", "name": "TableRiceBowlRim", "pos": Vector2(464, 350), "size": Vector2(30, 12), "color": Color(0.86, 0.8, 0.66, 1), "z": 390},
			{"name": "TableGreensPlate", "pos": Vector2(504, 352), "size": Vector2(34, 14), "color": Color(0.28, 0.48, 0.28, 1), "z": 389},
			{"kind": "ellipse", "name": "TableGreensPlateRim", "pos": Vector2(500, 348), "size": Vector2(42, 16), "color": Color(0.46, 0.58, 0.34, 1), "z": 390},
			{"name": "TableEnamelCup", "pos": Vector2(546, 344), "size": Vector2(18, 22), "color": Color(0.72, 0.78, 0.74, 1), "z": 389},
			{"kind": "ellipse", "name": "TableCupMouth", "pos": Vector2(544, 340), "size": Vector2(22, 8), "color": Color(0.88, 0.84, 0.72, 1), "z": 390},
			{"name": "WaterTankHighlight", "pos": Vector2(612, 272), "size": Vector2(8, 48), "color": Color(0.72, 0.76, 0.66, 0.32), "z": 334},
		],
		"foreground": [
			{"name": "ForegroundDaybed", "pos": Vector2(-12, 406), "size": Vector2(268, 52), "color": Color(0.13, 0.09, 0.06, 0.78), "z": 103},
			{"kind": "line", "name": "ForegroundDaybedStripeA", "from": Vector2(10, 418), "to": Vector2(230, 414), "width": 2.0, "color": Color(0.46, 0.4, 0.31, 0.42), "z": 105},
			{"kind": "line", "name": "ForegroundDaybedStripeB", "from": Vector2(12, 434), "to": Vector2(238, 430), "width": 2.0, "color": Color(0.46, 0.4, 0.31, 0.38), "z": 105},
			{"kind": "line", "name": "ForegroundDaybedStripeC", "from": Vector2(14, 450), "to": Vector2(246, 446), "width": 2.0, "color": Color(0.46, 0.4, 0.31, 0.34), "z": 105},
			{"name": "ForegroundTableEdge", "pos": Vector2(522, 426), "size": Vector2(210, 46), "color": Color(0.13, 0.09, 0.06, 0.78), "z": 104},
			{"name": "ForegroundChairBack", "pos": Vector2(604, 376), "size": Vector2(54, 88), "color": Color(0.09, 0.065, 0.045, 0.7), "z": 103},
			{"name": "ForegroundTableLegShadow", "pos": Vector2(650, 404), "size": Vector2(18, 70), "color": Color(0.07, 0.05, 0.035, 0.72), "z": 105},
		],
	})


func _add_interactable_objects() -> void:
	var tv := InteractableObject.new()
	tv.position = Vector2(430, 138)
	tv.object_name = "Calendar"
	tv.description = "墙上的挂历停在农历日期，红字节日被外婆用铅笔圈了起来。"
	tv.collision_w = 54
	tv.collision_h = 70
	add_child(tv)

	var shelves := InteractableObject.new()
	shelves.position = Vector2(248, 250)
	shelves.object_name = "Shelves"
	shelves.description = "碗柜里放着碗筷和剩菜，有些年头了。"
	shelves.collision_w = 118
	shelves.collision_h = 66
	add_child(shelves)

	var stove := InteractableObject.new()
	stove.position = Vector2(86, 310)
	stove.object_name = "Stove"
	stove.description = "灶台边缘被烟熏得发黑，锅里还留着一点热气。"
	stove.collision_w = 124
	stove.collision_h = 22
	add_child(stove)

	var table := InteractableObject.new()
	table.position = Vector2(392, 392)
	table.object_name = "RoundTable"
	table.description = "圆桌上有几道家常菜的痕迹，桌面被擦得发亮。"
	table.collision_w = 118
	table.collision_h = 24
	table.blocks_player = false
	add_child(table)

	var water_tank := InteractableObject.new()
	water_tank.position = Vector2(600, 320)
	water_tank.object_name = "WaterTank"
	water_tank.description = "水缸边缘有一圈白白的水痕，外婆总说盖子要压紧，别让灰落进去。"
	water_tank.collision_w = 54
	water_tank.collision_h = 24
	add_child(water_tank)

	var tableware := InteractableObject.new()
	tableware.position = Vector2(526, 350)
	tableware.object_name = "Tableware"
	tableware.description = "碗里还留着一点饭粒，搪瓷杯上的蓝边已经磕掉了一小块。"
	tableware.collision_w = 58
	tableware.collision_h = 18
	tableware.blocks_player = false
	add_child(tableware)

	var radio := InteractableObject.new()
	radio.position = Vector2(502, 174)
	radio.object_name = "OldRadio"
	radio.description = "旧收音机的屏幕泛着紫光，里面的杂音像从很远的地方传来。"
	radio.collision_w = 62
	radio.collision_h = 24
	add_child(radio)

	var daybed := InteractableObject.new()
	daybed.position = Vector2(18, 414)
	daybed.object_name = "Daybed"
	daybed.description = "竹榻横在前面，夏天傍晚大家会坐在这里吹风、剥花生。"
	daybed.collision_w = 210
	daybed.collision_h = 28
	daybed.blocks_player = false
	add_child(daybed)


# ============================================================
# 碰撞体
# ============================================================

func _add_wall_collisions() -> void:
	_add_hitbox("WallLeftTop", Vector2(0, 0), Vector2(32, 280))
	_add_hitbox("WallLeftBot", Vector2(0, 340), Vector2(32, 140))
	_add_hitbox("WallRightTop", Vector2(718, 0), Vector2(32, 280))
	_add_hitbox("WallRightBot", Vector2(718, 340), Vector2(32, 140))


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
