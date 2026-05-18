extends CanvasLayer

signal dialogue_finished()

@onready var dim_background: ColorRect = $UIContainer/DimBackground
@onready var dialogue_box: Panel = $UIContainer/DialogueBox
@onready var npc_name_label: Label = $UIContainer/DialogueBox/NPCName
@onready var dialogue_text_label: Label = $UIContainer/DialogueBox/DialogueText
@onready var choice_container: VBoxContainer = $UIContainer/DialogueBox/ChoiceContainer

var _current_event_id: String = ""


func _ready() -> void:
	hide_panel()


func start_dialogue(npc_name: String, event_data: Dictionary) -> void:
	npc_name_label.text = npc_name
	dialogue_text_label.text = event_data.get("text", "...")
	_current_event_id = event_data.get("id", "")

	for child in choice_container.get_children():
		child.queue_free()

	var choices: Array = event_data.get("choices", [])
	for i in range(choices.size()):
		var choice: Dictionary = choices[i]
		var button: Button = Button.new()
		button.text = choice.get("text", "选项%d" % (i + 1))
		button.custom_minimum_size = Vector2(300, 36)
		button.pressed.connect(_on_choice_pressed.bind(i, choices))
		choice_container.add_child(button)

	show_panel()


func _on_choice_pressed(choice_index: int, choices: Array) -> void:
	var chosen: Dictionary = choices[choice_index]
	var effects: Dictionary = chosen.get("effects", {})

	for attr_name in effects:
		GameState.change_attribute(attr_name, effects[attr_name])

	if not _current_event_id.is_empty():
		GameState.complete_event(_current_event_id)

	hide_panel()
	dialogue_finished.emit()


func show_panel() -> void:
	dim_background.visible = true
	dialogue_box.visible = true
	if choice_container.get_child_count() > 0:
		choice_container.get_child(0).grab_focus()


func hide_panel() -> void:
	dim_background.visible = false
	dialogue_box.visible = false
