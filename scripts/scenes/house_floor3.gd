## 职责：三楼场景控制器——主角房间、天台入口
extends Node2D

@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	player.add_to_group("player")
	_bind_all_npcs()
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)


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
