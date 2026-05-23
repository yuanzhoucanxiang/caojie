## 职责：三楼场景控制器——主角房间、天台入口
extends Node2D


const SPAWN_POINTS := {
	"from_2f_up": Vector2(75, 335),
}
@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	_apply_textures()
	_setup_post_process()
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
	mat.set_shader_parameter("vignette_intensity", 0.3)
	mat.set_shader_parameter("tint_color", Color(1.0, 0.88, 0.72, 0.14))

	var overlay := ColorRect.new()
	overlay.name = "PostProcess"
	overlay.material = mat
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_index = 1000
	add_child(overlay)

	overlay.size = Vector2(510, 480)


func _apply_textures() -> void:
	var rules := {
		"WindowFrame": [TextureSetup.Pattern.WOOD_V, 40.0, 0.1],
		"Window": [TextureSetup.Pattern.NOISE, 80.0, 0.03],
		"Desk": [TextureSetup.Pattern.WOOD_H, 50.0, 0.12],
		"Bed": [TextureSetup.Pattern.WOOD_H, 60.0, 0.1],
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
