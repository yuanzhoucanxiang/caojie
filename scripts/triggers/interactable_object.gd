## 职责：可互动物品——玩家靠近按E触发描述文本，复用对话气泡系统
## 谁使用它：场景控制器在 _ready() 中创建并调用 setup()
## 它使用谁：DialogueManager（通过 dialogue_request 信号，_bind_all_npcs 自动连接）

extends StaticBody2D

class_name InteractableObject

signal dialogue_request

var description_text: String = ""
var prompt_text: String = "按 E 查看"
var _in_range: bool = false


func setup(obj_name: String, desc: String, w: float, h: float, prompt: String = "按 E 查看") -> void:
	name = obj_name
	description_text = desc
	prompt_text = prompt
	collision_layer = 1
	collision_mask = 0

	var phys_shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, h)
	phys_shape.shape = rect
	phys_shape.position = Vector2(w / 2.0, 0.0)
	add_child(phys_shape)

	var area := Area2D.new()
	area.name = "InteractionZone"
	var det_shape := CollisionShape2D.new()
	var det_rect := RectangleShape2D.new()
	det_rect.size = Vector2(w + 30, h + 30)
	det_shape.shape = det_rect
	det_shape.position = Vector2(w / 2.0, 0.0)
	area.add_child(det_shape)
	add_child(area)

	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)


func _ready() -> void:
	await get_tree().process_frame
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node and player_node.has_signal("interact_pressed"):
		player_node.interact_pressed.connect(_on_player_interact)


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		_in_range = true
		queue_redraw()


func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		_in_range = false
		queue_redraw()


func _draw() -> void:
	if not _in_range:
		return
	var font := ThemeDB.fallback_font
	var pos := Vector2.ZERO
	pos.y -= 30
	draw_string(font, pos, prompt_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)


func _on_player_interact() -> void:
	if not _in_range:
		return
	var event_data := {
		"id": "",
		"text": description_text,
		"expression": "neutral",
		"choices": [{"text": "好的", "effects": {}}],
	}
	dialogue_request.emit(self, event_data)
