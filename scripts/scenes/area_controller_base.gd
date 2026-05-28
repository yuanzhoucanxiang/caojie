## 职责：区域场景控制器基类——统一出生点、暂停菜单、后处理、对话绑定
## 谁使用它：main.gd、house_floor1/2/3.gd 等区域控制器
## 它使用谁：SceneManager、DialogueManager、PauseMenu

class_name AreaControllerBase
extends Node2D

const PAUSE_MENU_SCENE := preload("res://scenes/ui/pause_menu.tscn")
const POST_PROCESS_SHADER := preload("res://shaders/post_process.gdshader")

var player: CharacterBody2D


func setup_area_common() -> void:
	_resolve_player()
	_setup_post_process()
	_add_pause_menu()
	_apply_spawn()
	_register_player()
	_bind_dialogue_sources()
	_connect_dialogue_pause()


func get_spawn_points() -> Dictionary:
	return {}


func get_post_process_config() -> Dictionary:
	return {}


func _resolve_player() -> void:
	player = get_node_or_null("Player") as CharacterBody2D
	if player == null:
		push_warning("%s 缺少 Player 节点，区域通用初始化会跳过玩家相关逻辑。" % name)


func _setup_post_process() -> void:
	var config := get_post_process_config()
	if config.is_empty():
		return

	var mat := ShaderMaterial.new()
	mat.shader = POST_PROCESS_SHADER
	mat.set_shader_parameter("vignette_intensity", config.get("vignette_intensity", 0.2))
	mat.set_shader_parameter("tint_color", config.get("tint_color", Color(0.95, 0.9, 0.8, 0.1)))

	var overlay := ColorRect.new()
	overlay.name = "PostProcess"
	overlay.material = mat
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_index = 1000
	add_child(overlay)
	overlay.size = config.get("size", get_viewport().get_visible_rect().size)


func _add_pause_menu() -> void:
	add_child(PAUSE_MENU_SCENE.instantiate())


func _apply_spawn() -> void:
	if player == null:
		return

	var sid := SceneManager.get_pending_spawn()
	if sid.is_empty():
		return

	var spawn_points := get_spawn_points()
	if not spawn_points.has(sid):
		push_warning("区域 %s 缺少出生点：%s" % [name, sid])
		return

	player.position = spawn_points[sid]


func _register_player() -> void:
	if player != null:
		player.add_to_group("player")


func _bind_dialogue_sources() -> void:
	var callback := Callable(self, "_on_dialogue_request")
	for child in find_children("*", "", true, false):
		if child.has_signal("dialogue_request") and not child.dialogue_request.is_connected(callback):
			child.dialogue_request.connect(callback)


func _connect_dialogue_pause() -> void:
	var started := Callable(self, "_on_dialogue_started")
	var finished := Callable(self, "_on_dialogue_finished")
	if not DialogueManager.dialogue_started.is_connected(started):
		DialogueManager.dialogue_started.connect(started)
	if not DialogueManager.dialogue_finished.is_connected(finished):
		DialogueManager.dialogue_finished.connect(finished)


func _on_dialogue_request(source_node: Node, event_data: Dictionary) -> void:
	DialogueManager.start_dialogue(source_node, event_data)


func _on_dialogue_started() -> void:
	if player == null:
		return
	player.set_physics_process(false)
	player.set_process(false)


func _on_dialogue_finished() -> void:
	if player == null:
		return
	player.set_physics_process(true)
	player.set_process(true)
