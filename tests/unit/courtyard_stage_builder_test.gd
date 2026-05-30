extends GdUnitTestSuite


func test_rebuild_hides_legacy_placeholders_and_adds_reference_stage_nodes() -> void:
	var parent: Node2D = auto_free(Node2D.new())
	var old_sky: ColorRect = ColorRect.new()
	old_sky.name = "Sky"
	parent.add_child(old_sky)
	var house: Node2D = Node2D.new()
	house.name = "House"
	parent.add_child(house)
	var old_house_body: ColorRect = ColorRect.new()
	old_house_body.name = "HouseBody"
	house.add_child(old_house_body)

	if not FileAccess.file_exists("res://scripts/scenes/courtyard_stage_builder.gd"):
		assert_bool(false).override_failure_message("courtyard_stage_builder.gd should exist").is_true()
		return
	var builder: Script = load("res://scripts/scenes/courtyard_stage_builder.gd")
	assert_that(builder).is_not_null()

	builder.rebuild(parent, {
		"items": [
			{"name": "CourtyardMainHouse", "pos": Vector2(380, 104), "size": Vector2(244, 256), "color": Color(0.62, 0.5, 0.38, 1), "z": 330},
			{"name": "CourtyardOldHouse", "pos": Vector2(660, 246), "size": Vector2(190, 114), "color": Color(0.66, 0.52, 0.34, 1), "z": 332},
			{"kind": "ellipse", "name": "CourtyardWell", "pos": Vector2(470, 372), "size": Vector2(92, 28), "color": Color(0.5, 0.46, 0.36, 1), "z": 398},
			{"kind": "line", "name": "CourtyardClothesline", "from": Vector2(760, 278), "to": Vector2(1010, 268), "width": 3.0, "color": Color(0.2, 0.16, 0.12, 0.75), "z": 345},
			{"name": "CourtyardVisualMarker", "pos": Vector2(0, 0), "size": Vector2(32, 32), "color": Color(0.2, 0.18, 0.14, 1), "z": 860},
		],
	})

	assert_that(old_sky.visible).is_false()
	assert_that(old_house_body.visible).is_false()
	assert_that(parent.get_node_or_null("CourtyardMainHouse")).is_not_null()
	assert_that(parent.get_node_or_null("CourtyardOldHouse")).is_not_null()
	assert_that(parent.get_node_or_null("CourtyardWell")).is_not_null()
	assert_that(parent.get_node_or_null("CourtyardClothesline")).is_not_null()
	assert_that(parent.get_node_or_null("CourtyardVisualMarker")).is_not_null()


func test_rebuild_adds_sprite_stage_item_from_texture() -> void:
	var parent: Node2D = auto_free(Node2D.new())
	var builder: Script = load("res://scripts/scenes/courtyard_stage_builder.gd")

	builder.rebuild(parent, {
		"items": [
			{
				"kind": "sprite",
				"name": "CourtyardMainHouse",
				"texture": "res://assets/sprites/Scenes/courtyard/main_house.png",
				"pos": Vector2(337, 81),
				"size": Vector2(313, 272),
				"color": Color(1, 1, 1, 1),
				"z": 328,
			},
		],
	})

	var sprite := parent.get_node_or_null("CourtyardMainHouse")
	assert_that(sprite).is_instanceof(Sprite2D)
	if sprite is Sprite2D:
		assert_that((sprite as Sprite2D).texture).is_not_null()
		assert_that((sprite as Sprite2D).centered).is_false()


func test_main_courtyard_script_uses_reference_composition_hooks() -> void:
	var source: String = FileAccess.get_file_as_string("res://scripts/main.gd")

	assert_bool(source.contains("CourtyardStageBuilderScript.rebuild")).is_true()
	assert_bool(source.contains("CourtyardWell")).is_true()
	assert_bool(source.contains("CourtyardClothesline")).is_true()


func test_courtyard_stage_does_not_use_temporary_foreground_tree_shadow() -> void:
	var source: String = FileAccess.get_file_as_string("res://scripts/main.gd")

	assert_bool(source.contains("CourtyardForegroundShade")).is_false()
	assert_bool(source.contains("CourtyardForegroundLeaf")).is_false()
	assert_bool(source.contains("CourtyardForegroundBranch")).is_false()


func test_courtyard_camera_keeps_intimate_default_zoom() -> void:
	var source: String = FileAccess.get_file_as_string("res://scripts/autoload/scene_manager.gd")

	assert_bool(source.contains("\"courtyard\": {")).is_true()
	assert_bool(source.contains("\"zoom\": 1.25")).is_true()
	assert_bool(source.contains("\"offset\": Vector2(0, -150)")).is_true()
	assert_bool(source.contains("\"depth_scale\": {\"min\": 0.78, \"max\": 1.08}")).is_true()
	assert_bool(source.contains("\"player_bounds\": {\"left\": 32, \"right\": 1680, \"top\": 350, \"bottom\": 520}")).is_true()


func test_main_courtyard_uses_open_2_5d_stage_anchors() -> void:
	var source: String = FileAccess.get_file_as_string("res://scripts/main.gd")

	assert_bool(source.contains("\"CourtyardYardGround\", \"pos\": Vector2(0, 368)")).is_true()
	assert_bool(source.contains("CourtyardYardPerspectiveFar")).is_true()
	assert_bool(source.contains("CourtyardYardPerspectiveNear")).is_true()
	assert_bool(source.contains("CourtyardOpenPlayBand")).is_true()
	assert_bool(source.contains("CourtyardMainHouse")).is_true()
	assert_bool(source.contains("CourtyardOldHouse")).is_true()


func test_main_courtyard_places_buildings_on_far_ground_footline() -> void:
	var source: String = FileAccess.get_file_as_string("res://scripts/main.gd")

	assert_bool(FileAccess.file_exists("res://assets/sprites/Scenes/courtyard/main_house.png")).is_true()
	assert_bool(FileAccess.file_exists("res://assets/sprites/Scenes/courtyard/old_house.png")).is_true()
	assert_bool(source.contains("\"CourtyardRearGroundApron\", \"pos\": Vector2(0, 348), \"size\": Vector2(1710, 54)")).is_true()
	assert_bool(source.contains("CourtyardMainHouseContactShadow")).is_true()
	assert_bool(source.contains("CourtyardMainHouseGroundLip")).is_true()
	assert_bool(source.contains("CourtyardOldHouseContactShadow")).is_true()
	assert_bool(source.contains("CourtyardOldHouseGroundLip")).is_true()
	assert_bool(source.contains("\"CourtyardOldHouseContactShadow\", \"pos\": Vector2(726, 340), \"size\": Vector2(262, 32), \"color\": Color(0.18, 0.13, 0.09, 0.3)")).is_true()
	assert_bool(source.contains("\"kind\": \"sprite\", \"name\": \"CourtyardMainHouse\"")).is_true()
	assert_bool(source.contains("\"texture\": \"res://assets/sprites/Scenes/courtyard/main_house.png\"")).is_true()
	assert_bool(source.contains("\"pos\": Vector2(333, 73), \"size\": Vector2(322, 280)")).is_true()
	assert_bool(source.contains("\"CourtyardMainHouseGroundLip\", \"pos\": Vector2(346, 348), \"size\": Vector2(298, 10), \"color\": Color(0.2, 0.14, 0.09, 0.26)")).is_true()
	assert_bool(source.contains("\"kind\": \"sprite\", \"name\": \"CourtyardOldHouse\"")).is_true()
	assert_bool(source.contains("\"texture\": \"res://assets/sprites/Scenes/courtyard/old_house.png\"")).is_true()
	assert_bool(source.contains("\"pos\": Vector2(718, 169), \"size\": Vector2(270, 184)")).is_true()
	assert_bool(source.contains("\"CourtyardOldHouseGroundLip\", \"pos\": Vector2(736, 347), \"size\": Vector2(232, 12), \"color\": Color(0.2, 0.14, 0.09, 0.32)")).is_true()
	assert_bool(source.contains("_add_body(\"House\", 240, 246, 348)")).is_true()
	assert_bool(source.contains("_add_body(\"OldHouse\", 198, 82, 348)")).is_true()


func test_main_courtyard_uses_v3_art_perspective_details() -> void:
	var source: String = FileAccess.get_file_as_string("res://scripts/main.gd")

	assert_bool(source.contains("CourtyardGroundPerspectiveLineA")).is_true()
	assert_bool(source.contains("\"kind\": \"sprite\", \"name\": \"CourtyardMainHouse\"")).is_true()
	assert_bool(source.contains("res://assets/sprites/Scenes/courtyard/main_house.png")).is_true()
	assert_bool(source.contains("\"kind\": \"sprite\", \"name\": \"CourtyardOldHouse\"")).is_true()
	assert_bool(source.contains("res://assets/sprites/Scenes/courtyard/old_house.png")).is_true()
	assert_bool(source.contains("CourtyardPowerLineA")).is_true()
	assert_bool(source.contains("CourtyardPottedPlantA")).is_true()
