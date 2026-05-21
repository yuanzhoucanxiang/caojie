## 职责：场景切换触发器——玩家靠近时显示提示，按E触发场景切换
## 谁使用它：挂载到场景边界的 Area2D 节点上
## 它使用谁：SceneManager、Player（监听 interact_pressed 信号）

extends StaticBody2D

@export var target_scene: String = ""
@export var target_area_id: String = "courtyard"
@export var transition_color: Color = Color(0.95, 0.93, 0.88)
@export var prompt_text: String = "按 E 进入"
@export var object_label: String = "门"

@onready var trigger_zone: Area2D = $TriggerZone

var _in_range: bool = false


func _draw() -> void:
	# 画一个简单的门形占位（棕色长方形）
	draw_rect(Rect2(-10, -50, 20, 50), Color(0.45, 0.3, 0.15))
	draw_rect(Rect2(-12, -52, 24, 4), Color(0.5, 0.35, 0.2))

	if _in_range:
		var font: Font = ThemeDB.fallback_font
		draw_string(font, Vector2(-40, -60), prompt_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 12)


func _ready() -> void:
	trigger_zone.area_entered.connect(_on_area_entered)
	trigger_zone.area_exited.connect(_on_area_exited)
	_register_to_player()


func _register_to_player() -> void:
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("interact_pressed"):
		player.interact_pressed.connect(_on_player_interact)


func _on_player_interact() -> void:
	if _in_range and not SceneManager.is_transitioning():
		if target_scene != "":
			SceneManager.change_scene(target_scene, target_area_id, transition_color)


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		_in_range = true
		queue_redraw()


func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		_in_range = false
		queue_redraw()
