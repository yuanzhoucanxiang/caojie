extends StaticBody2D

signal dialogue_triggered(npc_name: String, event_data: Dictionary)

@export var npc_id: String = "grandmother"
@export var npc_name: String = "奶奶"

const SPRITE_SIZE: Vector2 = Vector2(24, 42)
const SPRITE_COLOR: Color = Color(0.933, 0.533, 0.6, 1)

const DEPTH_MIN_Y: float = 150.0
const DEPTH_MAX_Y: float = 270.0
const SCALE_MIN: float = 0.65
const SCALE_MAX: float = 1.0

@onready var interaction_zone: Area2D = $InteractionZone

var _show_prompt: bool = false


func _draw() -> void:
	draw_rect(Rect2(-SPRITE_SIZE.x / 2, -SPRITE_SIZE.y, SPRITE_SIZE.x, SPRITE_SIZE.y), SPRITE_COLOR)
	if _show_prompt:
		var font: Font = ThemeDB.fallback_font
		draw_string(font, Vector2(-40, -50), "按 E 对话", HORIZONTAL_ALIGNMENT_CENTER, -1, 12)


func _ready() -> void:
	_update_depth_scale()
	interaction_zone.area_entered.connect(_on_area_entered)
	interaction_zone.area_exited.connect(_on_area_exited)


func _update_depth_scale() -> void:
	var t: float = clampf((position.y - DEPTH_MIN_Y) / (DEPTH_MAX_Y - DEPTH_MIN_Y), 0.0, 1.0)
	var s: float = lerp(SCALE_MIN, SCALE_MAX, t)
	scale = Vector2(s, s)


func _get_events() -> Array[Dictionary]:
	return [
		{
			"id": "event_1",
			"conditions": [],
			"text": "乖孙，过来帮奶奶择菜。",
			"choices": [
				{
					"text": "好的奶奶！",
					"effects": {"懂事": 1, "亲密": 1}
				},
				{
					"text": "我想出去玩...",
					"effects": {"好奇": 1, "亲密": -1}
				}
			]
		},
		{
			"id": "event_2",
			"conditions": ["event_completed:event_1"],
			"text": "来，奶奶给你讲个故事。从前啊……",
			"choices": [
				{
					"text": "认真听奶奶讲",
					"effects": {"懂事": 1, "亲密": 1}
				},
				{
					"text": "追着问各种问题",
					"effects": {"好奇": 1, "勤劳": -1}
				}
			]
		},
		{
			"id": "event_3",
			"conditions": ["event_completed:event_2"],
			"text": "院子的菜该浇水了，你要不要来试试？",
			"choices": [
				{
					"text": "积极帮忙！",
					"effects": {"勤劳": 1, "体力": 1, "亲密": 1}
				},
				{
					"text": "装作没听见……",
					"effects": {"懂事": -1}
				}
			]
		}
	]


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		_show_prompt = true
		queue_redraw()


func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		_show_prompt = false
		queue_redraw()


func trigger_dialogue() -> void:
	var event: Dictionary = _get_available_event()
	if not event.is_empty():
		dialogue_triggered.emit(npc_name, event)
	else:
		var fallback: Dictionary = {
			"id": "",
			"text": "乖孙，今天没有特别的事。去找点事做吧。",
			"choices": [
				{"text": "好的奶奶", "effects": {}}
			]
		}
		dialogue_triggered.emit(npc_name, fallback)


func _get_available_event() -> Dictionary:
	for event in _get_events():
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
