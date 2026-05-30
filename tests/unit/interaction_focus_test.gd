extends GdUnitTestSuite

const InteractionFocusScript := preload("res://scripts/triggers/interaction_focus.gd")

var _far_emitted := false
var _near_emitted := false


func after_test() -> void:
	DialogueManager.current_state = DialogueManager.State.IDLE
	_far_emitted = false
	_near_emitted = false


func test_focus_prefers_closest_in_range_candidate() -> void:
	var player: Node2D = auto_free(Node2D.new())
	player.position = Vector2.ZERO
	player.add_to_group("player")
	add_child(player)

	var far: InteractableObject = auto_free(InteractableObject.new())
	far.position = Vector2(120, 0)
	far.object_name = "FarCupboard"
	far._in_range = true
	add_child(far)

	var near: InteractableObject = auto_free(InteractableObject.new())
	near.position = Vector2(20, 0)
	near.object_name = "NearCup"
	near._in_range = true
	add_child(near)
	await get_tree().process_frame

	assert_that(InteractionFocusScript.get_focused_candidate(get_tree(), player.global_position)).is_equal(near)


func test_only_focused_interactable_emits_when_ranges_overlap() -> void:
	var player: Node2D = auto_free(Node2D.new())
	player.position = Vector2.ZERO
	player.add_to_group("player")
	add_child(player)

	var far: InteractableObject = auto_free(InteractableObject.new())
	far.position = Vector2(120, 0)
	far.object_name = "FarCupboard"
	far.description = "远一点的柜子"
	far._in_range = true
	add_child(far)

	var near: InteractableObject = auto_free(InteractableObject.new())
	near.position = Vector2(20, 0)
	near.object_name = "NearCup"
	near.description = "近一点的杯子"
	near._in_range = true
	add_child(near)
	await get_tree().process_frame

	far.dialogue_request.connect(func(_source: Node, _event_data: Dictionary) -> void:
		_far_emitted = true
	)
	near.dialogue_request.connect(func(_source: Node, _event_data: Dictionary) -> void:
		_near_emitted = true
	)

	far._on_player_interact()
	near._on_player_interact()

	assert_bool(_far_emitted).is_false()
	assert_bool(_near_emitted).is_true()


func test_crowded_room_hotspots_are_staggered() -> void:
	var floor1 := FileAccess.get_file_as_string("res://scripts/scenes/house_floor1.gd")
	var floor2 := FileAccess.get_file_as_string("res://scripts/scenes/house_floor2.gd")
	var floor3 := FileAccess.get_file_as_string("res://scripts/scenes/house_floor3.gd")

	assert_that(floor1).contains("table.position = Vector2(392, 392)")
	assert_that(floor1).contains("tableware.position = Vector2(526, 350)")
	assert_that(floor2).contains("grandparents.collision_w = 52")
	assert_that(floor2).contains("uncle.collision_w = 52")
	assert_that(floor3).contains("desk.position = Vector2(356, 382)")
	assert_that(floor3).contains("homework.position = Vector2(348, 338)")
	assert_that(floor3).contains("window_light.position = Vector2(234, 310)")


func test_courtyard_npcs_are_spread_across_life_anchors() -> void:
	var scene := FileAccess.get_file_as_string("res://scenes/main.tscn")

	assert_that(scene).contains("[node name=\"Uncle\"")
	assert_that(scene).contains("position = Vector2(300, 430)")
	assert_that(scene).contains("[node name=\"Cousin2\"")
	assert_that(scene).contains("position = Vector2(690, 410)")
	assert_that(scene).contains("[node name=\"Xiaoming\"")
	assert_that(scene).contains("position = Vector2(1040, 420)")
