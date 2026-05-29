extends GdUnitTestSuite

const InteriorStageBuilderScript := preload("res://scripts/scenes/interior_stage_builder.gd")


func test_rebuild_hides_legacy_and_adds_stage_nodes() -> void:
	var parent: Node2D = auto_free(Node2D.new())
	var old_wall: Polygon2D = Polygon2D.new()
	old_wall.name = "StructBackWall"
	parent.add_child(old_wall)

	InteriorStageBuilderScript.rebuild(parent, {
		"width": 100.0,
		"height": 80.0,
		"ceiling_h": 10.0,
		"floor_y": 50.0,
		"wall": 5.0,
		"side_bottom": 2.0,
		"palette": {},
		"items": [
			{"name": "TestDesk", "pos": Vector2(10, 20), "size": Vector2(30, 10), "color": Color(0.4, 0.3, 0.2, 1), "z": 3},
			{"kind": "line", "name": "TestFloorLine", "from": Vector2(5, 52), "to": Vector2(95, 52), "width": 2.0, "color": Color(0.2, 0.16, 0.12, 1), "z": 4},
			{"kind": "ellipse", "name": "TestCupRim", "pos": Vector2(42, 18), "size": Vector2(12, 8), "color": Color(0.7, 0.62, 0.5, 1), "z": 5},
		],
	})

	assert_that(old_wall.visible).is_false()
	assert_that(parent.get_node_or_null("StageBackWall")).is_not_null()
	assert_that(parent.get_node_or_null("TestDesk")).is_not_null()
	assert_that(parent.get_node_or_null("TestFloorLine")).is_not_null()
	assert_that(parent.get_node_or_null("TestCupRim")).is_not_null()


func test_house_interiors_keep_front_stage_proportions() -> void:
	var scene_scripts: PackedStringArray = [
		"res://scripts/scenes/house_floor1.gd",
		"res://scripts/scenes/house_floor2.gd",
		"res://scripts/scenes/house_floor3.gd",
	]
	for script_path in scene_scripts:
		var source: String = FileAccess.get_file_as_string(script_path)
		assert_bool(source.contains("WindowGrid")).is_false()
		assert_bool(source.contains("LightGrid")).is_false()
		_assert_ceiling_height_in_range(script_path, source)
		_assert_door_frames_match_child_scale(script_path, source)


func _assert_ceiling_height_in_range(_script_path: String, source: String) -> void:
	var ceiling_regex: RegEx = RegEx.new()
	ceiling_regex.compile("\"ceiling_h\":\\s*([0-9.]+)")
	var result: RegExMatch = ceiling_regex.search(source)
	assert_that(result).is_not_null()
	var ceiling_h: float = float(result.get_string(1))
	assert_float(ceiling_h).is_between(44.0, 56.0)


func _assert_door_frames_match_child_scale(_script_path: String, source: String) -> void:
	var door_regex: RegEx = RegEx.new()
	door_regex.compile("\"name\":\\s*\"[^\"]*DoorFrame\"[^\\n]*\"size\":\\s*Vector2\\([0-9.]+,\\s*([0-9.]+)\\)")
	for result in door_regex.search_all(source):
		var door_h: float = float(result.get_string(1))
		assert_float(door_h).is_less_equal(170.0)
