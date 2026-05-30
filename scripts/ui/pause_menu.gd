## 职责：暂停菜单——ESC 呼出，保存/设置/退出
## 谁使用它：所有游戏场景（main + house_floor1/2/3）
## 它使用谁：SceneManager、SaveManager、AudioManager

extends CanvasLayer

var _settings_panel: Control
var _main_box: Control


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	_main_box = %MenuBox
	%SaveButton.pressed.connect(_on_save)
	%SettingsButton.pressed.connect(_on_settings)
	%QuitButton.pressed.connect(_on_quit)
	for btn: Button in [%SaveButton, %SettingsButton, %QuitButton]:
		btn.pressed.connect(AudioManager.play_sfx.bind("SFX/ui_click.ogg"))
	_build_settings_panel()


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if DialogueManager.is_dialogue_active() and not visible:
		get_viewport().set_input_as_handled()
		return
	if _settings_panel and _settings_panel.visible:
		_hide_settings()
		get_viewport().set_input_as_handled()
		return
	if visible:
		_close()
	else:
		_open()
	get_viewport().set_input_as_handled()


func _open() -> void:
	show()
	get_tree().paused = true
	%SaveButton.grab_focus()


func _close() -> void:
	hide()
	get_tree().paused = false


func _on_save() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		SaveManager.save_game(player.position, SceneManager.get_current_area())
	_close()


func _on_settings() -> void:
	_main_box.hide()
	_settings_panel.show()


func _hide_settings() -> void:
	_settings_panel.hide()
	_main_box.show()


func _on_quit() -> void:
	print("【暂停】退出到标题")
	hide()
	get_tree().paused = false
	var timer := get_tree().create_timer(0.08)
	timer.timeout.connect(_do_quit)


func _do_quit() -> void:
	SceneManager.change_to_packed(
		load("res://scenes/ui/title_screen.tscn"),
		"title",
		Color(0.3, 0.25, 0.18),
	)


func _build_settings_panel() -> void:
	_settings_panel = Control.new()
	_settings_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_settings_panel.hide()
	add_child(_settings_panel)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.add_theme_constant_override("separation", 8)
	_settings_panel.add_child(box)

	var title := Label.new()
	title.text = "设置"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.92, 0.82, 0.6))
	box.add_child(title)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 10)
	box.add_child(gap)

	_add_slider(box, "BGM 音量", AudioManager.bgm_volume_db, func(v): AudioManager.bgm_volume_db = v)
	_add_slider(box, "SFX 音量", AudioManager.sfx_volume_db, func(v): AudioManager.sfx_volume_db = v)

	var gap2 := Control.new()
	gap2.custom_minimum_size = Vector2(0, 10)
	box.add_child(gap2)

	var back := Button.new()
	back.text = "返回"
	back.add_theme_font_size_override("font_size", 15)
	back.add_theme_color_override("font_color", Color(0.9, 0.85, 0.75))
	back.pressed.connect(_hide_settings)
	back.pressed.connect(AudioManager.play_sfx.bind("SFX/ui_click.ogg"))
	box.add_child(back)


func _add_slider(parent: Control, label_text: String, initial: float, callback: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)

	var label := Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.8, 0.75, 0.65))
	row.add_child(label)

	var slider := HSlider.new()
	slider.custom_minimum_size = Vector2(120, 0)
	slider.min_value = -40.0
	slider.max_value = 0.0
	slider.step = 1.0
	slider.value = initial
	slider.value_changed.connect(callback)
	row.add_child(slider)

	var val_label := Label.new()
	val_label.text = str(int(initial)) + "dB"
	val_label.add_theme_font_size_override("font_size", 12)
	val_label.add_theme_color_override("font_color", Color(0.6, 0.55, 0.48))
	row.add_child(val_label)

	slider.value_changed.connect(func(v: float): val_label.text = str(int(v)) + "dB")
