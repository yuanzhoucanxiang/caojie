## 职责：一楼室内场景控制器——管理对话暂停/恢复玩家
extends Node2D

@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	player.add_to_group("player")
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	# 应用室内镜头
	SceneManager._apply_camera_config("house_floor1")


func _on_dialogue_started() -> void:
	player.set_physics_process(false)
	player.set_process(false)


func _on_dialogue_finished() -> void:
	player.set_physics_process(true)
	player.set_process(true)
