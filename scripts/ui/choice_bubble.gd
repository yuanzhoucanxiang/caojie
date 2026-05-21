## 职责：漫画式选项气泡——从玩家旁边冒出，支持点击选择
## 谁使用它：DialogueManager（创建和管理选项气泡）
## 它使用谁：无

class_name ChoiceBubble
extends PanelContainer

signal choice_clicked(index: int)

var _index: int = 0
var _is_selected: bool = false
var _anim_delay: float = 0.0


func setup(index: int, text: String, total_choices: int) -> void:
	_index = index

	var bubble_width: float = 200.0
	var bubble_height: float = 36.0

	custom_minimum_size = Vector2(bubble_width, bubble_height)

	# 文本
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)

	# 背景样式
	_update_style(false)

	# 定位：在玩家上方水平排列
	var player_screen_x = 280.0
	var start_x = player_screen_x - (total_choices * (bubble_width + 10)) / 2 + bubble_width / 2
	var x = start_x + index * (bubble_width + 10)
	var y = 280.0 - (total_choices - 1 - index) * (bubble_height + 6)
	position = Vector2(x - bubble_width / 2, y)

	# 动画延迟
	_anim_delay = index * 0.06
	scale = Vector2.ZERO
	pivot_offset = Vector2(bubble_width / 2, bubble_height / 2)


func _ready() -> void:
	if _anim_delay > 0:
		await get_tree().create_timer(_anim_delay).timeout
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.06).set_ease(Tween.EASE_IN)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		choice_clicked.emit(_index)


func highlight() -> void:
	_is_selected = true
	_update_style(true)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.08)


func unhighlight() -> void:
	_is_selected = false
	_update_style(false)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.05)


func _update_style(highlighted: bool) -> void:
	var style = StyleBoxFlat.new()
	if highlighted:
		style.bg_color = Color(0.95, 0.85, 0.5, 0.95)
		style.border_color = Color(0.6, 0.5, 0.2, 1)
	else:
		style.bg_color = Color(0.95, 0.93, 0.88, 0.9)
		style.border_color = Color(0.5, 0.4, 0.3, 1)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	add_theme_stylebox_override("panel", style)


func remove_bubble() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.08).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()
