## 职责：二楼场景控制器——走廊（房间结构在tscn中）
extends "res://scripts/scenes/area_controller_base.gd"

const InteriorStageBuilderScript := preload("res://scripts/scenes/interior_stage_builder.gd")

const SPAWN_POINTS := {
	"from_1f_up": Vector2(85, 370),
	"from_3f_down": Vector2(560, 370),
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
		"vignette_intensity": 0.18,
		"tint_color": Color(1.0, 0.86, 0.7, 0.12),
		"size": Vector2(640, 480),
	}


# ============================================================
# 可互动物品
# ============================================================

func _rebuild_visual_stage() -> void:
	InteriorStageBuilderScript.rebuild(self, {
		"width": 640.0,
		"height": 480.0,
		"ceiling_h": 46.0,
		"floor_y": 340.0,
		"wall": 25.0,
		"side_bottom": 5.0,
		"palette": {
			"ceiling": Color(0.25, 0.23, 0.2, 1),
			"back_wall": Color(0.62, 0.57, 0.48, 1),
			"side_wall": Color(0.34, 0.3, 0.25, 1),
			"floor": Color(0.4, 0.32, 0.23, 1),
		},
		"lights": [
			{"name": "NarrowHallTopShade", "pos": Vector2(0, 0), "size": Vector2(640, 72), "color": Color(0.07, 0.055, 0.04, 0.32), "z": 58},
			{"name": "ThinWindowLight", "pos": Vector2(110, 204), "size": Vector2(210, 54), "color": Color(0.78, 0.66, 0.48, 0.07), "z": 56},
			{"name": "DoorwayFalloff", "pos": Vector2(444, 104), "size": Vector2(170, 238), "color": Color(0.12, 0.095, 0.075, 0.22), "z": 57},
			{"name": "LowForegroundHaze", "pos": Vector2(0, 404), "size": Vector2(640, 76), "color": Color(0.08, 0.06, 0.045, 0.34), "z": 92},
		],
		"items": [
			{"name": "GrandparentsDoorFrame", "pos": Vector2(60, 126), "size": Vector2(124, 214), "color": Color(0.36, 0.28, 0.2, 1), "z": -62},
			{"name": "GrandparentsDoorPanel", "pos": Vector2(70, 140), "size": Vector2(104, 198), "color": Color(0.52, 0.42, 0.3, 1), "z": -61},
			{"name": "GrandparentsDoorMat", "pos": Vector2(74, 342), "size": Vector2(94, 16), "color": Color(0.34, 0.4, 0.28, 1), "z": 360},
			{"name": "UncleDoorFrame", "pos": Vector2(258, 120), "size": Vector2(124, 220), "color": Color(0.31, 0.25, 0.2, 1), "z": -62},
			{"name": "UncleDoorPanel", "pos": Vector2(268, 134), "size": Vector2(104, 204), "color": Color(0.42, 0.34, 0.25, 1), "z": -61},
			{"name": "AwardPaper1", "pos": Vector2(220, 112), "size": Vector2(42, 28), "color": Color(0.75, 0.66, 0.46, 1), "z": -52},
			{"name": "AwardPaper2", "pos": Vector2(386, 112), "size": Vector2(40, 28), "color": Color(0.72, 0.62, 0.42, 1), "z": -52},
			{"name": "CousinDoorFrame", "pos": Vector2(456, 126), "size": Vector2(118, 214), "color": Color(0.28, 0.22, 0.18, 1), "z": -62},
			{"name": "CousinDoorPanel", "pos": Vector2(466, 140), "size": Vector2(98, 198), "color": Color(0.39, 0.3, 0.22, 1), "z": -61},
			{"name": "CrookedDrawing1", "pos": Vector2(474, 164), "size": Vector2(34, 24), "color": Color(0.54, 0.46, 0.36, 1), "z": -50},
			{"name": "CrookedDrawing2", "pos": Vector2(516, 182), "size": Vector2(30, 22), "color": Color(0.58, 0.49, 0.38, 1), "z": -50},
			{"name": "SoftWindowPatchLeft", "pos": Vector2(82, 218), "size": Vector2(164, 34), "color": Color(0.72, 0.62, 0.44, 0.08), "z": 56},
			{"name": "SoftWindowPatchRight", "pos": Vector2(444, 212), "size": Vector2(108, 38), "color": Color(0.68, 0.58, 0.42, 0.06), "z": 56},
			{"kind": "line", "name": "LeftDoorCharmString", "from": Vector2(118, 178), "to": Vector2(118, 252), "width": 2.0, "color": Color(0.42, 0.34, 0.24, 0.58), "z": -49},
			{"kind": "ellipse", "name": "LeftDoorCharmTop", "pos": Vector2(106, 196), "size": Vector2(24, 28), "color": Color(0.68, 0.52, 0.32, 0.92), "z": -48},
			{"kind": "ellipse", "name": "LeftDoorCharmBottom", "pos": Vector2(110, 230), "size": Vector2(18, 20), "color": Color(0.78, 0.66, 0.46, 0.9), "z": -48},
			{"kind": "ellipse", "name": "GrandparentsDoorKnob", "pos": Vector2(154, 254), "size": Vector2(8, 8), "color": Color(0.78, 0.64, 0.38, 1), "z": -48},
			{"kind": "ellipse", "name": "UncleDoorKnob", "pos": Vector2(352, 254), "size": Vector2(8, 8), "color": Color(0.74, 0.58, 0.34, 1), "z": -48},
			{"kind": "ellipse", "name": "CousinDoorKnob", "pos": Vector2(546, 254), "size": Vector2(8, 8), "color": Color(0.72, 0.56, 0.32, 1), "z": -48},
			{"name": "HallBench", "pos": Vector2(206, 368), "size": Vector2(92, 18), "color": Color(0.35, 0.25, 0.16, 1), "z": 387},
			{"name": "BenchLegLeft", "pos": Vector2(216, 386), "size": Vector2(8, 28), "color": Color(0.27, 0.19, 0.12, 1), "z": 415},
			{"name": "BenchLegRight", "pos": Vector2(278, 386), "size": Vector2(8, 28), "color": Color(0.27, 0.19, 0.12, 1), "z": 415},
			{"name": "DogMat", "pos": Vector2(474, 372), "size": Vector2(70, 22), "color": Color(0.3, 0.24, 0.18, 1), "z": 395},
			{"name": "CeilingWireA", "pos": Vector2(80, 58), "size": Vector2(200, 3), "color": Color(0.17, 0.14, 0.11, 1), "z": -40},
			{"name": "CeilingWireB", "pos": Vector2(352, 58), "size": Vector2(160, 3), "color": Color(0.17, 0.14, 0.11, 1), "z": -40},
			{"kind": "line", "name": "HallBaseLine", "from": Vector2(25, 340), "to": Vector2(615, 340), "width": 3.0, "color": Color(0.2, 0.15, 0.1, 0.62), "z": -38},
			{"kind": "line", "name": "HallFloorLineA", "from": Vector2(36, 372), "to": Vector2(604, 366), "width": 2.0, "color": Color(0.25, 0.18, 0.12, 0.5), "z": 50},
			{"kind": "line", "name": "HallFloorLineB", "from": Vector2(28, 414), "to": Vector2(612, 404), "width": 2.0, "color": Color(0.22, 0.16, 0.11, 0.48), "z": 50},
			{"name": "GrandparentsDoorNamePlate", "pos": Vector2(106, 154), "size": Vector2(30, 10), "color": Color(0.76, 0.66, 0.44, 1), "z": -50},
			{"name": "UncleDoorNamePlate", "pos": Vector2(308, 150), "size": Vector2(28, 10), "color": Color(0.68, 0.58, 0.42, 1), "z": -50},
			{"name": "CousinDoorSticker", "pos": Vector2(500, 222), "size": Vector2(24, 18), "color": Color(0.44, 0.58, 0.64, 1), "z": -50},
			{"kind": "line", "name": "GrandparentsDoorCrack", "from": Vector2(84, 210), "to": Vector2(98, 282), "width": 2.0, "color": Color(0.24, 0.17, 0.11, 0.6), "z": -48},
			{"kind": "line", "name": "UncleDoorLightSeam", "from": Vector2(370, 146), "to": Vector2(370, 334), "width": 2.0, "color": Color(0.48, 0.36, 0.22, 0.16), "z": -48},
			{"kind": "line", "name": "CousinDoorLightSeam", "from": Vector2(466, 152), "to": Vector2(466, 334), "width": 2.0, "color": Color(0.48, 0.36, 0.22, 0.14), "z": -48},
			{"kind": "line", "name": "AwardPaper1Top", "from": Vector2(220, 112), "to": Vector2(262, 112), "width": 2.0, "color": Color(0.42, 0.22, 0.12, 1), "z": -49},
			{"kind": "line", "name": "AwardPaper2Top", "from": Vector2(386, 112), "to": Vector2(426, 112), "width": 2.0, "color": Color(0.42, 0.22, 0.12, 1), "z": -49},
			{"name": "BenchShadow", "pos": Vector2(194, 390), "size": Vector2(118, 14), "color": Color(0.08, 0.055, 0.035, 0.36), "z": 396},
			{"name": "UmbrellaHandle", "pos": Vector2(42, 304), "size": Vector2(8, 68), "color": Color(0.16, 0.12, 0.09, 1), "z": 372},
			{"name": "UmbrellaCloth", "pos": Vector2(30, 292), "size": Vector2(32, 18), "color": Color(0.32, 0.38, 0.34, 1), "z": 373},
			{"kind": "ellipse", "name": "DogMatSoftEdge", "pos": Vector2(468, 368), "size": Vector2(82, 28), "color": Color(0.22, 0.17, 0.12, 0.72), "z": 396},
		],
		"foreground": [
			{"name": "ForegroundStairShadowLeft", "pos": Vector2(0, 420), "size": Vector2(120, 60), "color": Color(0.08, 0.055, 0.035, 0.66), "z": 104},
			{"name": "ForegroundStairShadowRight", "pos": Vector2(540, 420), "size": Vector2(100, 60), "color": Color(0.08, 0.055, 0.035, 0.66), "z": 104},
		],
	})


func _add_interactable_objects() -> void:
	var grandparents := InteractableObject.new()
	grandparents.position = Vector2(70, 320)
	grandparents.object_name = "GrandparentsRoomDoor"
	grandparents.description = "外婆房间门缝里有淡淡的药油味，床边大概还放着针线盒。"
	grandparents.collision_w = 104
	grandparents.collision_h = 26
	add_child(grandparents)

	var uncle := InteractableObject.new()
	uncle.position = Vector2(268, 320)
	uncle.object_name = "UncleRoomDoor"
	uncle.description = "舅舅舅妈的房门收拾得很规整，墙上的奖状已经有些发黄。"
	uncle.collision_w = 104
	uncle.collision_h = 26
	add_child(uncle)

	var cousin := InteractableObject.new()
	cousin.position = Vector2(466, 320)
	cousin.object_name = "CousinRoomDoor"
	cousin.description = "二表哥门上贴着歪歪扭扭的画，门口还有一张旧垫子。"
	cousin.collision_w = 98
	cousin.collision_h = 26
	add_child(cousin)

	var awards := InteractableObject.new()
	awards.position = Vector2(218, 116)
	awards.object_name = "AwardPapers"
	awards.description = "奖状被贴得很高，纸边已经发黄，但红字还很醒目。"
	awards.collision_w = 210
	awards.collision_h = 34
	add_child(awards)

	var umbrella := InteractableObject.new()
	umbrella.position = Vector2(30, 336)
	umbrella.object_name = "Umbrella"
	umbrella.description = "一把旧伞靠在墙边，伞骨有些歪，像是经历过很多场急雨。"
	umbrella.collision_w = 40
	umbrella.collision_h = 36
	add_child(umbrella)

	var hanging_charm := InteractableObject.new()
	hanging_charm.position = Vector2(104, 214)
	hanging_charm.object_name = "DoorCharm"
	hanging_charm.description = "门上的小挂饰轻轻晃着，颜色已经晒淡，还是被擦得很干净。"
	hanging_charm.collision_w = 36
	hanging_charm.collision_h = 42
	add_child(hanging_charm)


# ============================================================
# 碰撞体
# ============================================================

func _add_wall_collisions() -> void:
	_add_hitbox("WallLeftTop", Vector2(0, 0), Vector2(32, 280))
	_add_hitbox("WallLeftBot", Vector2(0, 340), Vector2(32, 140))
	_add_hitbox("WallRightTop", Vector2(608, 0), Vector2(32, 280))
	_add_hitbox("WallRightBot", Vector2(608, 340), Vector2(32, 140))


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
