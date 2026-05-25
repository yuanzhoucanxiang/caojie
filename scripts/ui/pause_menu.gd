## 职责：暂停菜单——ESC 呼出，保存/设置/退出
## 谁使用它：所有游戏场景（main + house_floor1/2/3）
## 它使用谁：SceneManager

extends CanvasLayer


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	%SaveButton.pressed.connect(_on_save)
	%SettingsButton.pressed.connect(_on_settings)
	%QuitButton.pressed.connect(_on_quit)
	for btn: Button in [%SaveButton, %SettingsButton, %QuitButton]:
		btn.pressed.connect(AudioManager.play_sfx.bind("SFX/ui_click.ogg"))


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
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
	print("【暂停】设置（暂未实现）")
	_close()


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
