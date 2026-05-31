extends GdUnitTestSuite


func test_courtyard_npcs_use_player_sixty_pixel_scale() -> void:
	var cases := [
		["res://scenes/npcs/npc_xiaoming.tscn", Vector2(34, 60), 72.0],
		["res://scenes/npcs/npc_cousin2.tscn", Vector2(38, 74), 86.0],
		["res://scenes/npcs/npc_uncle.tscn", Vector2(42, 84), 96.0],
		["res://scenes/npcs/npc_grandmother.tscn", Vector2(42, 78), 90.0],
		["res://scenes/npcs/npc_aunt.tscn", Vector2(40, 82), 94.0],
	]

	for spec in cases:
		var scene: PackedScene = load(spec[0])
		var npc: Node = auto_free(scene.instantiate())
		add_child(npc)
		await get_tree().process_frame

		assert_that(npc.get("npc_body_size")).is_equal(spec[1])
		assert_that(npc.get("prompt_offset_y")).is_equal(spec[2])
