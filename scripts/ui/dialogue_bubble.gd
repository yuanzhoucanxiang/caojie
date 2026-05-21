## 职责：漫画式说话气泡——根据NPC屏幕位置自动定位，显示对话文本和表情占位
## 谁使用它：DialogueManager（创建和管理气泡实例）
## 它使用谁：无

class_name DialogueBubble
extends Control

var _bg: PanelContainer
var _label: Label
var _expr_rect: ColorRect
var _expr_label: Label
var _tail: ColorRect


func setup(speaker_screen_pos: Vector2, text: String, expr: String = "normal") -> void:
	# 气泡尺寸
	var bubble_width: float = 280.0
	var bubble_height: float = 80.0

	# 背景面板
	_bg = PanelContainer.new()
	_bg.custom_minimum_size = Vector2(bubble_width, bubble_height)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.95, 0.93, 0.88, 0.95)
	style.border_color = Color(0.5, 0.4, 0.3, 1)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	_bg.add_theme_stylebox_override("panel", style)
	add_child(_bg)

	# 内部水平布局
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	_bg.add_child(hbox)

	# 表情占位（彩色方块）
	_expr_rect = ColorRect.new()
	_expr_rect.custom_minimum_size = Vector2(40, 40)
	_expr_rect.color = _get_expression_color(expr)
	hbox.add_child(_expr_rect)

	# 表情文字标签
	_expr_label = Label.new()
	_expr_label.text = _get_expression_label(expr)
	_expr_label.add_theme_font_size_override("font_size", 9)
	_expr_rect.add_child(_expr_label)

	# 对话文本
	_label = Label.new()
	_label.text = text
	_label.custom_minimum_size = Vector2(bubble_width - 70, 0)
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hbox.add_child(_label)

	# 气泡尾巴（三角形用一个旋转45度的方块代替）
	_tail = ColorRect.new()
	_tail.custom_minimum_size = Vector2(12, 12)
	_tail.color = style.border_color
	add_child(_tail)

	# 定位气泡
	_position_bubble(speaker_screen_pos)

	# 弹出动画
	_popup_animation()


func _position_bubble(speaker_pos: Vector2) -> void:
	var screen_h = 360.0  # viewport 高度
	var screen_w = 640.0  # viewport 宽度

	var bubble_w = 280.0
	var bubble_h = 80.0

	# 气泡在 NPC 上方
	var x = speaker_pos.x - bubble_w / 2
	var y = speaker_pos.y - bubble_h - 30

	# 限制不超出屏幕
	x = clampf(x, 5.0, screen_w - bubble_w - 5)
	y = clampf(y, 5.0, screen_h - bubble_h - 5)

	_bg.position = Vector2(x, y)

	# 尾巴指向 NPC
	var tail_x = clampf(speaker_pos.x - 6, x + 10, x + bubble_w - 22)
	_tail.position = Vector2(tail_x, y + bubble_h)


func _popup_animation() -> void:
	scale = Vector2.ZERO
	pivot_offset = Vector2(140, 40)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.08).set_ease(Tween.EASE_IN)


func remove_bubble() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.1).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()


func _get_expression_color(expr: String) -> Color:
	match expr:
		"smile": return Color(0.9, 0.75, 0.5, 1)
		"grin": return Color(0.5, 0.8, 0.5, 1)
		"worry": return Color(0.7, 0.7, 0.8, 1)
		"tired": return Color(0.6, 0.55, 0.5, 1)
		"kind": return Color(0.9, 0.6, 0.6, 1)
		"angry": return Color(0.9, 0.4, 0.4, 1)
		"cool": return Color(0.5, 0.6, 0.8, 1)
		_: return Color(0.8, 0.75, 0.7, 1)  # normal


func _get_expression_label(expr: String) -> String:
	match expr:
		"smile": return "微笑"
		"grin": return "咧嘴"
		"worry": return "担心"
		"tired": return "疲惫"
		"kind": return "温柔"
		"angry": return "生气"
		"cool": return "淡定"
		_: return "普通"
