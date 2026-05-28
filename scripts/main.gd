## 职责：主场景控制器——绑定NPC、监听对话信号暂停/恢复玩家
## 谁使用它：Godot 引擎（自动加载此场景）
## 它使用谁：DialogueManager、Player、所有 NPC

extends "res://scripts/scenes/area_controller_base.gd"

const SPAWN_POINTS := {
	"from_house": Vector2(1370, 385),
	"from_3f_rooftop": Vector2(1370, 385),
}

const COLLISION_THRESHOLD: float = 25.0

var _collision_bodies: Array[Dictionary] = []

func _ready() -> void:
	_apply_textures()
	_add_depth_collisions()
	setup_area_common()


func get_spawn_points() -> Dictionary:
	return SPAWN_POINTS


func get_post_process_config() -> Dictionary:
	return {
		"vignette_intensity": 0.25,
		"tint_color": Color(1.0, 0.92, 0.82, 0.08),
		"size": Vector2(1710, 900),
	}


func _apply_textures() -> void:
	var rules := {
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
	# 大屋 ground_y=360
	_add_body("House", 214, 240, 360)
	# 老屋 ground_y=360
	_add_body("OldHouse", 113, 93, 360)
	# 龙眼树 ground_y=360
	_add_body("YardTree", 16, 0, 360)
	_add_body("Tree1", 12, 0, 400)
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
