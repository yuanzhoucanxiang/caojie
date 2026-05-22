## 职责：主场景控制器——绑定NPC、监听对话信号暂停/恢复玩家
## 谁使用它：Godot 引擎（自动加载此场景）
## 它使用谁：DialogueManager、Player、所有 NPC

extends Node2D

var _foreground_data: Array[Dictionary] = []

@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	_apply_textures()
	_setup_post_process()
	_setup_foreground_transparency()
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

	overlay.size = Vector2(1710, 480)


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
		"ForegroundPost": [TextureSetup.Pattern.WOOD_V, 40.0, 0.1],
		"OldHouseEdge": [TextureSetup.Pattern.NOISE, 50.0, 0.06],
		"FarHills": [TextureSetup.Pattern.NOISE, 150.0, 0.04],
		"MidHills": [TextureSetup.Pattern.NOISE, 120.0, 0.05],
		"Sky": [TextureSetup.Pattern.NOISE, 200.0, 0.03],
		"YardGround": [TextureSetup.Pattern.DIRT, 80.0, 0.1],
	}
	TextureSetup.apply_by_name(self, rules)


func _setup_foreground_transparency() -> void:
	var fg_names := PackedStringArray([
		"ForegroundTree", "ForegroundBush", "ForegroundBush2",
		"ForegroundPost", "OldHouseEdge",
		"CloseFence", "CloseGrassL", "CloseGrassR",
		"YardTree", "OldHouse", "YardWell", "Clothesline", "ChickenCoop",
	])
	for node_name in fg_names:
		var node := get_node_or_null(node_name)
		if not node:
			continue
		var bounds := _compute_world_bounds(node)
		_foreground_data.append({
			node = node,
			bounds = bounds,
			faded = false,
		})


func _compute_world_bounds(node: Node) -> Rect2:
	if node is ColorRect:
		var cr := node as ColorRect
		var parent_pos := Vector2.ZERO
		if node.get_parent() is Node2D:
			parent_pos = (node.get_parent() as Node2D).position
		return Rect2(
			parent_pos.x + cr.offset_left, parent_pos.y + cr.offset_top,
			cr.offset_right - cr.offset_left, cr.offset_bottom - cr.offset_top,
		)
	# Node2D — 计算所有子节点的包围盒
	var nd := node as Node2D
	var min_x := INF; var min_y := INF
	var max_x := -INF; var max_y := -INF
	for child in nd.get_children():
		if child is ColorRect:
			var cr := child as ColorRect
			min_x = minf(min_x, cr.offset_left)
			min_y = minf(min_y, cr.offset_top)
			max_x = maxf(max_x, cr.offset_right)
			max_y = maxf(max_y, cr.offset_bottom)
	if min_x == INF:
		return Rect2()
	return Rect2(
		nd.position.x + min_x, nd.position.y + min_y,
		max_x - min_x, max_y - min_y,
	)


func _physics_process(_delta: float) -> void:
	if not player:
		return
	var pp := player.position
	for data in _foreground_data:
		var node: Node = data["node"]
		var bounds: Rect2 = data["bounds"]
		var inside := bounds.has_point(pp)
		if data["faded"] != inside:
			data["faded"] = inside
			_tween_transparency(node, 0.35 if inside else 1.0)


func _tween_transparency(node: Node, target: float) -> void:
	if node is CanvasItem:
		var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(node as CanvasItem, "modulate:a", target, 0.2)
	for child in node.get_children():
		_tween_transparency(child, target)


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
