## 职责：游戏标题界面——新游戏/继续/退出
## 谁使用它：title_screen.tscn
## 它使用谁：SceneManager、GameState、SaveManager

extends Control

var _confirm_panel: Control


func _ready() -> void:
	%StartButton.grab_focus()
	%StartButton.pressed.connect(_on_start)
	%ContinueButton.pressed.connect(_on_continue)
	%QuitButton.pressed.connect(_on_quit)
	if SaveManager.has_save():
		%ContinueButton.disabled = false
	_do_fade_in()


func _on_start() -> void:
	if _confirm_panel and _confirm_panel.visible:
		return
	_show_confirm()


func _show_confirm() -> void:
	_confirm_panel = Control.new()
	_confirm_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_confirm_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_confirm_panel)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.05, 0.04, 0.03, 0.55)
	_confirm_panel.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_confirm_panel.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(260, 0)
	center.add_child(card)

	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.14, 0.11, 0.07, 0.95)
	card_style.border_width_left = 2
	card_style.border_width_right = 2
	card_style.border_width_top = 2
	card_style.border_width_bottom = 2
	card_style.border_color = Color(0.42, 0.35, 0.22)
	card_style.set_corner_radius_all(8)
	card_style.content_margin_left = 20
	card_style.content_margin_right = 20
	card_style.content_margin_top = 18
	card_style.content_margin_bottom = 16
	card.add_theme_stylebox_override("panel", card_style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	card.add_child(vbox)

	var title := Label.new()
	title.text = "新游戏"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.92, 0.82, 0.6))
	vbox.add_child(title)

	var gap1 := Control.new()
	gap1.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(gap1)

	var body := Label.new()
	body.text = "开始新游戏将覆盖现有存档，\n确定要继续吗？"
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD
	body.add_theme_font_size_override("font_size", 14)
	body.add_theme_color_override("font_color", Color(0.65, 0.6, 0.5))
	vbox.add_child(body)

	var gap2 := Control.new()
	gap2.custom_minimum_size = Vector2(0, 14)
	vbox.add_child(gap2)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 12)
	vbox.add_child(hbox)

	var cancel_btn := _make_button("取消", false)
	cancel_btn.custom_minimum_size = Vector2(80, 0)
	cancel_btn.pressed.connect(_hide_confirm)
	hbox.add_child(cancel_btn)

	var confirm_btn := _make_button("确定", true)
	confirm_btn.custom_minimum_size = Vector2(80, 0)
	confirm_btn.pressed.connect(_do_start_new_game)
	hbox.add_child(confirm_btn)

	confirm_btn.grab_focus()


func _hide_confirm() -> void:
	if _confirm_panel:
		_confirm_panel.queue_free()
		_confirm_panel = null
	%StartButton.grab_focus()


func _do_start_new_game() -> void:
	GameState.reset()
	SceneManager.change_to_packed(
		load("res://scenes/main.tscn"),
		"courtyard",
		Color(0.3, 0.25, 0.18),
	)


func _make_button(text: String, primary: bool) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 14)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.32, 0.25, 0.15, 0.9) if primary else Color(0.16, 0.13, 0.09, 0.8)
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_width_top = 2
	normal.border_width_bottom = 2
	normal.border_color = Color(0.58, 0.45, 0.28) if primary else Color(0.32, 0.28, 0.2)
	normal.set_corner_radius_all(4)
	btn.add_theme_stylebox_override("normal", normal)
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.42, 0.33, 0.2, 0.9) if primary else Color(0.22, 0.18, 0.12, 0.8)
	hover.border_color = Color(0.7, 0.55, 0.35) if primary else Color(0.4, 0.35, 0.25)
	hover.border_width_left = 2
	hover.border_width_right = 2
	hover.border_width_top = 2
	hover.border_width_bottom = 2
	hover.set_corner_radius_all(4)
	btn.add_theme_stylebox_override("hover", hover)
	var fc := Color(0.92, 0.85, 0.7) if primary else Color(0.6, 0.55, 0.48)
	btn.add_theme_color_override("font_color", fc)
	btn.add_theme_color_override("font_hover_color", Color(0.95, 0.9, 0.78))
	return btn


func _on_continue() -> void:
	SaveManager.load_and_transition()


func _on_quit() -> void:
	get_tree().quit()


func _do_fade_in() -> void:
	modulate.a = 0.0
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "modulate:a", 1.0, 0.6)
