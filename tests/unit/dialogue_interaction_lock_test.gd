extends GdUnitTestSuite


func before_test() -> void:
	DialogueManager.current_state = DialogueManager.State.IDLE


func after_test() -> void:
	DialogueManager.current_state = DialogueManager.State.IDLE


func test_interactable_object_ignores_interact_while_dialogue_is_active() -> void:
	var obj: InteractableObject = auto_free(InteractableObject.new())
	obj.description = "桌上放着一只旧茶杯。"
	obj._in_range = true
	var emitted := false
	obj.dialogue_request.connect(func(_source: Node, _event_data: Dictionary) -> void:
		emitted = true
	)

	DialogueManager.current_state = DialogueManager.State.SHOWING_SPEECH
	obj._on_player_interact()

	assert_bool(emitted).is_false()


func test_npc_ignores_interact_while_dialogue_is_active() -> void:
	var npc: NPCBase = auto_free(NPCBase.new())
	npc.default_text = "先把当前这句话说完。"
	npc._in_range = true
	var emitted := false
	npc.dialogue_request.connect(func(_source: Node, _event_data: Dictionary) -> void:
		emitted = true
	)

	DialogueManager.current_state = DialogueManager.State.SHOWING_SPEECH
	npc._on_player_interact()

	assert_bool(emitted).is_false()


func test_transition_trigger_checks_dialogue_lock_before_scene_transition() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/triggers/transition_trigger.gd")

	assert_that(source).contains("DialogueManager.is_dialogue_active()")


func test_player_exposes_explicit_input_lock() -> void:
	var player: CharacterBody2D = auto_free(load("res://scenes/player.tscn").instantiate())
	add_child(player)
	await get_tree().process_frame

	player.set_input_locked(true)

	assert_bool(player.is_input_locked()).is_true()
	assert_that(player.velocity).is_equal(Vector2.ZERO)


func test_player_uses_dialogue_state_as_global_input_guard() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/player/player.gd")

	assert_that(source).contains("DialogueManager.is_dialogue_active()")


func test_pause_menu_ignores_cancel_while_dialogue_is_active() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/ui/pause_menu.gd")

	assert_that(source).contains("DialogueManager.is_dialogue_active()")


func test_area_controller_unlocks_player_after_finish_frame() -> void:
	var area: AreaControllerBase = auto_free(AreaControllerBase.new())
	var player: CharacterBody2D = auto_free(load("res://scenes/player.tscn").instantiate())
	area.player = player
	add_child(area)
	area.add_child(player)
	await get_tree().process_frame

	area._on_dialogue_started()
	assert_bool(player.call("is_input_locked")).is_true()

	area._on_dialogue_finished()
	assert_bool(player.call("is_input_locked")).is_true()

	await get_tree().physics_frame
	assert_bool(player.call("is_input_locked")).is_false()
