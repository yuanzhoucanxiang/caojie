extends Node2D

@onready var dialogue_ui: CanvasLayer = $DialogueUI
@onready var player: CharacterBody2D = $Player
@onready var grandmother: StaticBody2D = $Grandmother


func _ready() -> void:
	grandmother.dialogue_triggered.connect(_on_dialogue_triggered)
	dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)
	player.add_to_group("player")


func _on_dialogue_triggered(npc_name: String, event_data: Dictionary) -> void:
	player.set_physics_process(false)
	player.set_process(false)
	dialogue_ui.start_dialogue(npc_name, event_data)


func _on_dialogue_finished() -> void:
	player.set_physics_process(true)
	player.set_process(true)
