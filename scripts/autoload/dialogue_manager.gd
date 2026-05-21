## 职责：全局对话调度——接收NPC对话请求，驱动UI显示，管理对话状态
## 谁使用它：所有 NPC（通过 dialogue_request 信号）、Main（监听开始/结束信号）
## 它使用谁：GameState（应用属性变化）、DialogueUI（显示对话）

extends Node

signal dialogue_started
signal dialogue_finished

enum State { IDLE, SHOWING_SPEECH, SHOWING_CHOICES }
var current_state: State = State.IDLE

var _current_event_id: String = ""
var _current_npc: Node = null


func start_dialogue(npc: Node, event_data: Dictionary) -> void:
	## 开始一次对话。NPC 调用此方法传入事件数据。
	if current_state != State.IDLE:
		return

	_current_npc = npc
	_current_event_id = event_data.get("id", "")
	current_state = State.SHOWING_SPEECH
	dialogue_started.emit()

	# 获取 DialogueUI 节点（在 main 场景中）
	var dialogue_ui = _get_dialogue_ui()
	if dialogue_ui == null:
		push_error("DialogueManager: 找不到 DialogueUI 节点")
		_finish_dialogue()
		return

	# 显示对话
	var npc_name: String = ""
	if npc and npc.has_method("get"):
		npc_name = npc.get("npc_name") if npc.get("npc_name") else ""
	dialogue_ui.start_dialogue(npc_name, event_data)

	# 切换到选择状态
	current_state = State.SHOWING_CHOICES


func on_choice_selected(choice_index: int, choices: Array) -> void:
	## 玩家选择了某个选项。由 DialogueUI 调用。
	if current_state != State.SHOWING_CHOICES:
		return

	var chosen: Dictionary = choices[choice_index]
	var effects: Dictionary = chosen.get("effects", {})

	# 应用属性变化
	for attr_name in effects:
		GameState.change_attribute(attr_name, effects[attr_name])

	# 标记事件完成
	if not _current_event_id.is_empty():
		GameState.complete_event(_current_event_id)

	_finish_dialogue()


func _finish_dialogue() -> void:
	current_state = State.IDLE
	_current_event_id = ""
	_current_npc = null
	dialogue_finished.emit()


func _get_dialogue_ui() -> Node:
	## 在场景树中查找 DialogueUI 节点
	var main = get_tree().current_scene
	if main:
		return main.get_node_or_null("DialogueUI")
	return null


func is_dialogue_active() -> bool:
	return current_state != State.IDLE
