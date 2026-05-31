## 职责：NPC基类——交互区域检测、提示显示、事件条件匹配、发出对话请求
## 谁使用它：Main（自动绑定）、Player（通过 interact_pressed 广播信号）
## 它使用谁：GameState（条件检查）、DialogueManager（通过信号间接调用）

class_name NPCBase
extends StaticBody2D

signal dialogue_request(npc_node: Node, event_data: Dictionary)

const InteractionFocusScript := preload("res://scripts/triggers/interaction_focus.gd")

const SPRITE_SIZE: Vector2 = Vector2(32, 54)
const DEPTH_MIN_Y: float = 360.0
const DEPTH_MAX_Y: float = 520.0
const SCALE_MIN: float = 0.85
const SCALE_MAX: float = 1.0

@export var npc_id: String = ""
@export var npc_name: String = ""
@export var sprite_color: Color = Color(0.933, 0.533, 0.6, 1)
@export var npc_body_size: Vector2 = Vector2(34, 60)
@export var prompt_offset_y: float = 72.0
@export var default_text: String = "..."
@export var default_expression: String = "normal"
@export var interaction_priority: int = 20

var _in_range: bool = false

@onready var interaction_zone: Area2D = $InteractionZone


func _draw() -> void:
	_draw_scale_placeholder()
	if _in_range and InteractionFocusScript.is_focused(self):
		var font: Font = ThemeDB.fallback_font
		draw_string(font, Vector2(-44, -prompt_offset_y), "按 E 对话", HORIZONTAL_ALIGNMENT_CENTER, -1, 12)


func _draw_scale_placeholder() -> void:
	var w := npc_body_size.x
	var h := npc_body_size.y
	var head_r := clampf(w * 0.28, 8.0, 13.0)
	var head_center := Vector2(0, -h + head_r + 1.0)
	var shoulder_w := w * 0.76
	var body_top := head_center.y + head_r - 2.0
	var body_bottom := -16.0
	var leg_w := w * 0.22
	var leg_h := 18.0

	draw_circle(head_center, head_r, sprite_color.lightened(0.18))
	draw_rect(Rect2(-shoulder_w / 2.0, body_top, shoulder_w, body_bottom - body_top), sprite_color)
	draw_rect(Rect2(-w * 0.27, body_bottom, leg_w, leg_h), sprite_color.darkened(0.18))
	draw_rect(Rect2(w * 0.05, body_bottom, leg_w, leg_h), sprite_color.darkened(0.18))
	draw_rect(Rect2(-w * 0.34, -3.0, w * 0.32, 3.0), sprite_color.darkened(0.35))
	draw_rect(Rect2(w * 0.02, -3.0, w * 0.32, 3.0), sprite_color.darkened(0.35))


func _ready() -> void:
	InteractionFocusScript.register(self)
	_add_body_collision()
	_update_depth_scale()
	_update_depth_sort()
	interaction_zone.area_entered.connect(_on_area_entered)
	interaction_zone.area_exited.connect(_on_area_exited)
	# 延迟一帧等场景树就绪，然后注册到玩家
	_register_to_player()


func _add_body_collision() -> void:
	var body_collision = CollisionShape2D.new()
	var body_shape = RectangleShape2D.new()
	body_shape.size = Vector2(maxf(npc_body_size.x * 0.56, 20.0), 8)
	body_collision.shape = body_shape
	body_collision.position = Vector2(0, -4)
	body_collision.name = "BodyCollision"
	add_child(body_collision)


func _process(_delta: float) -> void:
	_update_depth_scale()
	_update_depth_sort()
	if _in_range:
		queue_redraw()


func _register_to_player() -> void:
	await get_tree().process_frame
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node and player_node.has_signal("interact_pressed"):
		player_node.interact_pressed.connect(_on_player_interact)


func _on_player_interact() -> void:
	if DialogueManager.is_dialogue_active():
		return
	if not _in_range:
		return
	if not InteractionFocusScript.is_focused(self):
		return
	var event: Dictionary = _get_available_event()
	if not event.is_empty():
		dialogue_request.emit(self, event)
	else:
		var fallback: Dictionary = {
			"id": "",
			"text": default_text,
			"expression": default_expression,
			"choices": [{"text": "好的", "effects": {}}]
		}
		dialogue_request.emit(self, fallback)


func _update_depth_scale() -> void:
	var t: float = clampf((position.y - DEPTH_MIN_Y) / (DEPTH_MAX_Y - DEPTH_MIN_Y), 0.0, 1.0)
	var s: float = lerp(SCALE_MIN, SCALE_MAX, t)
	scale = Vector2(s, s)


func _update_depth_sort() -> void:
	z_index = int(position.y)


## 子类重写此方法，返回该NPC的事件列表
func _get_events() -> Array[Dictionary]:
	return []


func _get_available_event() -> Dictionary:
	for event in _get_events():
		var event_id: String = event.get("id", "")
		var repeatable: bool = event.get("repeatable", false)
		if not repeatable and not event_id.is_empty() and GameState.is_event_completed(event_id):
			continue
		if _check_conditions(event.get("conditions", [])):
			return event
	return {}


func _check_conditions(conditions: Array) -> bool:
	for cond: String in conditions:
		if cond.begins_with("event_completed:"):
			var event_id: String = cond.replace("event_completed:", "")
			if not GameState.is_event_completed(event_id):
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


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		_in_range = true
		queue_redraw()


func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		_in_range = false
		queue_redraw()


func is_player_in_interaction_range() -> bool:
	return _in_range


func get_interaction_priority() -> int:
	return interaction_priority


func get_interaction_anchor() -> Vector2:
	return global_position
