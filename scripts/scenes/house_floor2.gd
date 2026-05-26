## 职责：二楼场景控制器——管理对话暂停/恢复玩家
extends Node2D


const SPAWN_POINTS := {
	"from_1f_up": Vector2(85, 335),
	"from_3f_down": Vector2(560, 335),
}
@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	_apply_textures()
	_setup_post_process()
	_add_wall_collisions()
	_add_pause_menu()
	_apply_spawn()
	player.add_to_group("player")
	_bind_all_npcs()
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)


func _apply_spawn() -> void:
	var sid := SceneManager.get_pending_spawn()
	if sid.is_empty():
		return
	var pos: Vector2 = SPAWN_POINTS.get(sid, Vector2.ZERO)
	if pos != Vector2.ZERO:
		player.position = pos


func _add_pause_menu() -> void:
	add_child(load("res://scenes/ui/pause_menu.tscn").instantiate())


func _setup_post_process() -> void:
	var shader := load("res://shaders/post_process.gdshader") as Shader
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("vignette_intensity", 0.15)
	mat.set_shader_parameter("tint_color", Color(1.0, 0.9, 0.75, 0.1))

	var overlay := ColorRect.new()
	overlay.name = "PostProcess"
	overlay.material = mat
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_index = 1000
	add_child(overlay)

	overlay.size = Vector2(640, 480)


func _apply_textures() -> void:
	var rules := {
		"Cousin2Room": [TextureSetup.Pattern.NOISE, 80.0, 0.06],
		"UncleRoom": [TextureSetup.Pattern.NOISE, 80.0, 0.06],
		"GrandparentsRoom": [TextureSetup.Pattern.NOISE, 80.0, 0.06],
		"BackWall": [TextureSetup.Pattern.NOISE, 100.0, 0.06],
		"LeftWall": [TextureSetup.Pattern.NOISE, 100.0, 0.05],
		"RightWall": [TextureSetup.Pattern.NOISE, 100.0, 0.05],
		"Floor": [TextureSetup.Pattern.WOOD_H, 80.0, 0.1],
	}
	TextureSetup.apply_by_name(self, rules)


func _bind_all_npcs() -> void:
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


func _add_wall_collisions() -> void:
	_add_static_body("WallLeft", Vector2(0, 0), Vector2(16, 480))
	_add_static_body("WallRight", Vector2(624, 0), Vector2(16, 480))


func _add_static_body(obj_name: String, pos: Vector2, size: Vector2) -> void:
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
