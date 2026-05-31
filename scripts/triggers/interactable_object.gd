## 职责：可互动物品——玩家靠近按E触发描述文本或轻量行动事件，复用对话气泡系统
## 谁使用它：场景中实例化，Inspector 里填参数即可
## 它使用谁：DialogueManager（通过 dialogue_request 信号，AreaControllerBase 自动连接）、GameState（条件检查、事件标记）

class_name InteractableObject
extends StaticBody2D

signal dialogue_request(source_node: Node, event_data: Dictionary)

const InteractionFocusScript := preload("res://scripts/triggers/interaction_focus.gd")

@export var object_name: String = ""
@export_multiline var description: String = ""
@export var prompt: String = "按 E 查看"
@export var collision_w: float = 50.0
@export var collision_h: float = 30.0
@export var blocks_player: bool = true
@export var interaction_priority: int = 0

## 行动事件——有 event_id 时走事件逻辑，否则走普通查看
@export var event_id: String = ""
@export_multiline var event_text: String = ""
@export var event_conditions: Array[String] = []
@export var event_choices: Array[Dictionary] = []
@export_multiline var completed_description: String = ""
@export var repeatable: bool = false

var _in_range: bool = false


func _ready() -> void:
	InteractionFocusScript.register(self)
	if object_name != "":
		name = object_name
	collision_layer = 1 if blocks_player else 0
	collision_mask = 0

	var phys_shape := CollisionShape2D.new()
	phys_shape.name = "CollisionShape2D"
	var rect := RectangleShape2D.new()
	rect.size = Vector2(collision_w, collision_h)
	phys_shape.shape = rect
	phys_shape.position = Vector2(collision_w / 2.0, 0.0)
	add_child(phys_shape)

	var area := Area2D.new()
	area.name = "InteractionZone"
	var det_shape := CollisionShape2D.new()
	var det_rect := RectangleShape2D.new()
	det_rect.size = Vector2(collision_w + 30, collision_h + 30)
	det_shape.shape = det_rect
	det_shape.position = Vector2(collision_w / 2.0, 0.0)
	area.add_child(det_shape)
	add_child(area)

	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)

	await get_tree().process_frame
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node and player_node.has_signal("interact_pressed"):
		player_node.interact_pressed.connect(_on_player_interact)


func _on_area_entered(a: Area2D) -> void:
	if a.get_parent().is_in_group("player"):
		_in_range = true
		queue_redraw()


func _on_area_exited(a: Area2D) -> void:
	if a.get_parent().is_in_group("player"):
		_in_range = false
		queue_redraw()


func _draw() -> void:
	if not _in_range:
		return
	if not InteractionFocusScript.is_focused(self):
		return
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(0, -30), prompt, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)


func _on_player_interact() -> void:
	if DialogueManager.is_dialogue_active():
		return
	if not _in_range:
		return
	if not InteractionFocusScript.is_focused(self):
		return
	# 有 event_id 时走行动事件逻辑
	if not event_id.is_empty():
		_try_action_event()
		return
	var event_data := {
		"id": "",
		"text": description,
		"expression": "neutral",
		"choices": [{"text": "好的", "effects": {}}],
	}
	dialogue_request.emit(self, event_data)


func _try_action_event() -> void:
	# 非 repeatable 且已完成 → 显示完成描述或普通描述
	if not repeatable and GameState.is_event_completed(event_id):
		var desc: String = completed_description if not completed_description.is_empty() else description
		dialogue_request.emit(self, {
			"id": "",
			"text": desc,
			"expression": "neutral",
			"choices": [{"text": "好的", "effects": {}}],
		})
		return
	# 检查条件
	if not _check_event_conditions():
		return
	# 条件满足，发出行动事件
	var fallback := [{"text": "好的", "effects": {}}]
	var choices: Array = event_choices if not event_choices.is_empty() else fallback
	dialogue_request.emit(self, {
		"id": event_id,
		"text": event_text,
		"expression": "neutral",
		"choices": choices,
	})


func _check_event_conditions() -> bool:
	for cond: String in event_conditions:
		if cond.begins_with("event_completed:"):
			var eid: String = cond.replace("event_completed:", "")
			if not GameState.is_event_completed(eid):
				return false
		elif cond.begins_with("attr:"):
			var rest: String = cond.replace("attr:", "")
			var parts: Array = rest.split(">=")
			if parts.size() == 2:
				var attr_name: String = parts[0].strip_edges()
				var min_val: int = int(parts[1].strip_edges())
				if not GameState.check_attribute(attr_name, min_val):
					return false
	return true


func _process(_delta: float) -> void:
	if _in_range:
		queue_redraw()


func is_player_in_interaction_range() -> bool:
	return _in_range


func get_interaction_priority() -> int:
	return interaction_priority


func get_interaction_anchor() -> Vector2:
	return to_global(Vector2(collision_w / 2.0, 0.0))
