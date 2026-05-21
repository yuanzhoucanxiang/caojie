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


func _ready() -> void:
	# 创建 CanvasLayer 用于显示气泡（最高层）
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 10
	add_child(_canvas_layer)


func start_dialogue(npc: Node, event_data: Dictionary) -> void:
	if current_state != State.IDLE:
		return

	_current_npc = npc
	_current_event_id = event_data.get("id", "")
	_current_choices = event_data.get("choices", [])
	current_state = State.SHOWING_SPEECH
	dialogue_started.emit()

	# 获取 NPC 在屏幕上的位置
	var screen_pos = _world_to_screen(npc.global_position)

	# 创建说话气泡
	var expr: String = event_data.get("expression", "normal")
	_current_bubble = _create_speech_bubble(screen_pos, event_data.get("text", "..."), expr)

	# 显示"按E继续"提示
	_show_advance_hint()


func _input(event: InputEvent) -> void:
	if current_state == State.SHOWING_SPEECH:
		if event.is_action_pressed("interact"):
			_on_advance_from_speech()
	elif current_state == State.SHOWING_CHOICES:
		# 键盘选择：数字键或方向键
		if event.is_action_pressed("move_up"):
			_navigate_choices(-1)
		elif event.is_action_pressed("move_down"):
			_navigate_choices(1)
		elif event.is_action_pressed("interact"):
			_confirm_choice()


func _on_advance_from_speech() -> void:
	# 移除说话气泡
	if _current_bubble:
		_current_bubble.remove_bubble()
		_current_bubble = null

	# 移除提示
	_remove_advance_hint()

	# 显示选项或结束对话
	if _current_choices.size() > 0:
		current_state = State.SHOWING_CHOICES
		_show_choice_bubbles()
	else:
		_finish_dialogue()


func _show_choice_bubbles() -> void:
	_choice_bubbles.clear()
	var npc_screen_pos = _world_to_screen(_current_npc.global_position)

	for i in range(_current_choices.size()):
		var choice_data: Dictionary = _current_choices[i]
		var bubble = ChoiceBubble.new()
		bubble.setup(i, choice_data.get("text", "选项%d" % (i + 1)), _current_choices.size())
		bubble.choice_clicked.connect(_on_choice_clicked)
		_canvas_layer.add_child(bubble)
		_choice_bubbles.append(bubble)

	# 高亮第一个选项
	if _choice_bubbles.size() > 0:
		_choice_bubbles[0].highlight()


func _on_choice_clicked(index: int) -> void:
	if current_state != State.SHOWING_CHOICES:
		return
	_apply_choice(index)


func _navigate_choices(direction: int) -> void:
	if _choice_bubbles.is_empty():
		return

	# 找到当前高亮的
	var current = 0
	for i in range(_choice_bubbles.size()):
		if _choice_bubbles[i]._is_selected:
			current = i
			break

	# 取消高亮
	_choice_bubbles[current].unhighlight()

	# 新位置
	var new_index = (current + direction + _choice_bubbles.size()) % _choice_bubbles.size()
	_choice_bubbles[new_index].highlight()


func _confirm_choice() -> void:
	# 找到当前高亮的选项
	for i in range(_choice_bubbles.size()):
		if _choice_bubbles[i]._is_selected:
			_apply_choice(i)
			return
	# 如果没找到，默认选第一个
	_apply_choice(0)


func _apply_choice(index: int) -> void:
	var chosen: Dictionary = _current_choices[index]
	var effects: Dictionary = chosen.get("effects", {})

	# 应用属性变化
	for attr_name in effects:
		GameState.change_attribute(attr_name, effects[attr_name])

	# 标记事件完成
	if not _current_event_id.is_empty():
		GameState.complete_event(_current_event_id)

	# 移除所有选项气泡
	for bubble in _choice_bubbles:
		bubble.remove_bubble()
	_choice_bubbles.clear()

	_finish_dialogue()


func _finish_dialogue() -> void:
	current_state = State.IDLE
	_current_event_id = ""
	_current_npc = null
	_current_choices = []
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
