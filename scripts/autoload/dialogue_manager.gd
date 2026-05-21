## 职责：全局对话调度——接收NPC对话请求，创建漫画气泡UI，管理对话状态机
## 谁使用它：所有 NPC（通过 dialogue_request 信号）、Main（监听开始/结束信号）
## 它使用谁：DialogueBubble、ChoiceBubble、GameState

extends Node

signal dialogue_started
signal dialogue_finished

enum State { IDLE, SHOWING_SPEECH, SHOWING_CHOICES }
var current_state: State = State.IDLE

var _current_event_id: String = ""
var _current_npc: Node = null
var _current_choices: Array = []
var _canvas_layer: CanvasLayer
var _current_bubble: Control = null
var _choice_bubbles: Array = []
var _advance_hint: Label = null
var _selected_index: int = 0


func _ready() -> void:
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 10
	add_child(_canvas_layer)


func start_dialogue(npc: Node, event_data: Dictionary) -> void:
	if current_state != State.IDLE:
		return

	_current_npc = npc
	_current_event_id = event_data.get("id", "")
	_current_choices = event_data.get("choices", [])
	_selected_index = 0
	current_state = State.SHOWING_SPEECH
	dialogue_started.emit()

	var screen_pos = _world_to_screen(npc.global_position)
	var expr: String = event_data.get("expression", "normal")
	_current_bubble = _create_speech_bubble(screen_pos, event_data.get("text", "..."), expr)
	_show_advance_hint()


func _process(_delta: float) -> void:
	if current_state == State.SHOWING_SPEECH:
		if Input.is_action_just_pressed("interact"):
			_advance_from_speech()

	elif current_state == State.SHOWING_CHOICES:
		if Input.is_action_just_pressed("move_left"):
			_navigate_choices(-1)
		elif Input.is_action_just_pressed("move_right"):
			_navigate_choices(1)
		elif Input.is_action_just_pressed("interact"):
			_apply_choice(_selected_index)


func _input(event: InputEvent) -> void:
	# 鼠标点击处理
	if current_state == State.SHOWING_SPEECH:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_advance_from_speech()
	elif current_state == State.SHOWING_CHOICES:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var clicked_index = _get_choice_at_position(event.position)
			if clicked_index >= 0:
				_apply_choice(clicked_index)


func _advance_from_speech() -> void:
	if _current_bubble:
		_current_bubble.remove_bubble()
		_current_bubble = null
	_remove_advance_hint()

	if _current_choices.size() > 0:
		current_state = State.SHOWING_CHOICES
		_show_choice_bubbles()
	else:
		_finish_dialogue()


func _show_choice_bubbles() -> void:
	_choice_bubbles.clear()
	_selected_index = 0

	for i in range(_current_choices.size()):
		var choice_data: Dictionary = _current_choices[i]
		var bubble = ChoiceBubble.new()
		bubble.setup(i, choice_data.get("text", "选项%d" % (i + 1)), _current_choices.size())
		_canvas_layer.add_child(bubble)
		_choice_bubbles.append(bubble)

	if _choice_bubbles.size() > 0:
		_choice_bubbles[0].highlight()


func _navigate_choices(direction: int) -> void:
	if _choice_bubbles.is_empty():
		return

	_choice_bubbles[_selected_index].unhighlight()
	_selected_index = (_selected_index + direction + _choice_bubbles.size()) % _choice_bubbles.size()
	_choice_bubbles[_selected_index].highlight()


func _apply_choice(index: int) -> void:
	var chosen: Dictionary = _current_choices[index]
	var effects: Dictionary = chosen.get("effects", {})

	for attr_name in effects:
		GameState.change_attribute(attr_name, effects[attr_name])

	if not _current_event_id.is_empty():
		GameState.complete_event(_current_event_id)

	for bubble in _choice_bubbles:
		bubble.remove_bubble()
	_choice_bubbles.clear()

	_finish_dialogue()


func _get_choice_at_position(screen_pos: Vector2) -> int:
	for i in range(_choice_bubbles.size()):
		var bubble = _choice_bubbles[i]
		var rect = Rect2(bubble.global_position, bubble.size)
		if rect.has_point(screen_pos):
			return i
	return -1


func _finish_dialogue() -> void:
	current_state = State.IDLE
	_current_event_id = ""
	_current_npc = null
	_current_choices = []
	_selected_index = 0
	dialogue_finished.emit()


func _create_speech_bubble(screen_pos: Vector2, text: String, expr: String) -> DialogueBubble:
	var bubble = DialogueBubble.new()
	bubble.setup(screen_pos, text, expr)
	_canvas_layer.add_child(bubble)
	return bubble


func _show_advance_hint() -> void:
	_advance_hint = Label.new()
	_advance_hint.text = "按 E 继续"
	_advance_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_advance_hint.position = Vector2(260, 330)
	_advance_hint.add_theme_font_size_override("font_size", 11)
	_canvas_layer.add_child(_advance_hint)


func _remove_advance_hint() -> void:
	if _advance_hint:
		_advance_hint.queue_free()
		_advance_hint = null


func _world_to_screen(world_pos: Vector2) -> Vector2:
	var camera = get_viewport().get_camera_2d()
	if camera:
		var viewport_size = get_viewport().get_visible_rect().size
		return world_pos - camera.global_position + viewport_size / 2.0
	return world_pos


func is_dialogue_active() -> bool:
	return current_state != State.IDLE
