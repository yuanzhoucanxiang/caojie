extends CanvasLayer

@onready var dim_background: ColorRect = $UIContainer/DimBackground
@onready var dialogue_box: Panel = $UIContainer/DialogueBox
@onready var npc_name_label: Label = $UIContainer/DialogueBox/NPCName
@onready var dialogue_text_label: Label = $UIContainer/DialogueBox/DialogueText
@onready var choice_container: VBoxContainer = $UIContainer/DialogueBox/ChoiceContainer

var _current_choices: Array = []


func _ready() -> void:
	hide_panel()


func start_dialogue(npc_name: String, event_data: Dictionary) -> void:
	npc_name_label.text = npc_name
	dialogue_text_label.text = event_data.get("text", "...")
	_current_choices = event_data.get("choices", [])

	for child in choice_container.get_children():
		child.queue_free()

	for i in range(_current_choices.size()):
		var choice: Dictionary = _current_choices[i]
		var button: Button = Button.new()
		button.text = choice.get("text", "选项%d" % (i + 1))
		button.custom_minimum_size = Vector2(300, 36)
		button.pressed.connect(_on_choice_pressed.bind(i))
		choice_container.add_child(button)

	show_panel()


func _on_choice_pressed(choice_index: int) -> void:
	hide_panel()
	DialogueManager.on_choice_selected(choice_index, _current_choices)


func show_panel() -> void:
	dim_background.visible = true
	dialogue_box.visible = true
	if choice_container.get_child_count() > 0:
		choice_container.get_child(0).grab_focus()


func hide_panel() -> void:
	dim_background.visible = false
	dialogue_box.visible = false
