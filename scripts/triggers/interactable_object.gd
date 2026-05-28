## 职责：可互动物品——玩家靠近按E触发描述文本，复用对话气泡系统
## 谁使用它：场景中实例化，Inspector 里填参数即可
## 它使用谁：DialogueManager（通过 dialogue_request 信号，AreaControllerBase 自动连接）

class_name InteractableObject
extends StaticBody2D

signal dialogue_request(source_node: Node, event_data: Dictionary)

@export var object_name: String = ""
@export_multiline var description: String = ""
@export var prompt: String = "按 E 查看"
@export var collision_w: float = 50.0
@export var collision_h: float = 30.0
@export var blocks_player: bool = true

var _in_range: bool = false


func _ready() -> void:
	if object_name != "":
		name = object_name
	collision_layer = 1 if blocks_player else 0
	collision_mask = 0

	var phys_shape := CollisionShape2D.new()
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
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(0, -30), prompt, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)


func _on_player_interact() -> void:
	if not _in_range:
		return
	var event_data := {
		"id": "",
		"text": description,
		"expression": "neutral",
		"choices": [{"text": "好的", "effects": {}}],
	}
	dialogue_request.emit(self, event_data)
