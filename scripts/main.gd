## 职责：主场景控制器——绑定NPC、监听对话信号暂停/恢复玩家
## 谁使用它：Godot 引擎（自动加载此场景）
## 它使用谁：DialogueManager、Player、所有 NPC

extends Node2D

const SPAWN_POINTS := {
	"from_house": Vector2(1370, 385),
}

@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	_apply_textures()
	_setup_post_process()
	_add_collisions()
	_add_pause_menu()
	_apply_spawn()
	player.add_to_group("player")
	_bind_all_npcs()
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)


func _setup_post_process() -> void:
	var shader := load("res://shaders/post_process.gdshader") as Shader
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("vignette_intensity", 0.25)
	mat.set_shader_parameter("tint_color", Color(1.0, 0.92, 0.82, 0.08))

	var overlay := ColorRect.new()
	overlay.name = "PostProcess"
	overlay.material = mat
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_index = 1000
	add_child(overlay)

	overlay.size = Vector2(1710, 900)


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


func _add_collisions() -> void:
	# 建筑（深度面 y≈360）
	_collide_at_bottom("House", 214, 240, Vector2(190, 20))
	_collide_at_bottom("OldHouse", 113, 93, Vector2(100, 16))
	# 树/井/设施
	_collide_at_bottom("YardTree", 18, 0, Vector2(12, 12))
	_collide_at_bottom("YardWell", 28, 0, Vector2(22, 12))
	_collide_at_bottom("Clothesline", 56, 0, Vector2(50, 12))
	_add_static_body_at(Vector2(793, 417), Vector2(56, 12))
	_add_static_body_at(Vector2(1000.5, 473), Vector2(133, 12))
	_add_static_body_at(Vector2(1353.5, 500), Vector2(173, 12))


func _collide_at_bottom(
	parent_path: String, body_w: float, body_h: float, foot_size: Vector2,
) -> void:
	var parent := get_node_or_null(parent_path)
	if not parent:
		return
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = foot_size
	shape.shape = rect
	shape.position = Vector2(body_w / 2.0, body_h - foot_size.y / 2.0)
	body.add_child(shape)
	parent.add_child(body)


func _add_static_body_at(world_center: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = world_center
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	add_child(body)


func _apply_spawn() -> void:
	var sid := SceneManager.get_pending_spawn()
	if sid.is_empty():
		return
	var pos: Vector2 = SPAWN_POINTS.get(sid, Vector2.ZERO)
	if pos != Vector2.ZERO:
		player.position = pos


func _add_pause_menu() -> void:
	add_child(load("res://scenes/ui/pause_menu.tscn").instantiate())


func _bind_all_npcs() -> void:
	## 自动查找场景中所有 NPCBase 子类，连接它们的 dialogue_request 信号
	for child in get_children():
		if child.has_signal("dialogue_request"):
			child.dialogue_request.connect(
				func(npc, data): DialogueManager.start_dialogue(npc, data)
			)


func _on_dialogue_started() -> void:
	player.set_physics_process(false)
	player.set_process(false)


func _on_dialogue_finished() -> void:
	player.set_physics_process(true)
	player.set_process(true)
