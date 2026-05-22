## 职责：主场景控制器——绑定NPC、监听对话信号暂停/恢复玩家
## 谁使用它：Godot 引擎（自动加载此场景）
## 它使用谁：DialogueManager、Player、所有 NPC

extends Node2D

@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	_setup_post_process()
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

	var size := get_viewport().get_visible_rect().size
	overlay.size = size


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
