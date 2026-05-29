extends GdUnitTestSuite


func test_non_blocking_interactable_keeps_detection_without_physics_layer() -> void:
	var obj: InteractableObject = auto_free(InteractableObject.new())
	obj.object_name = "ReadableTableware"
	obj.blocks_player = false
	obj.collision_w = 80
	obj.collision_h = 24

	add_child(obj)
	await get_tree().process_frame

	assert_that(obj.collision_layer).is_equal(0)
	assert_that(obj.get_node_or_null("CollisionShape2D")).is_not_null()
	assert_that(obj.get_node_or_null("InteractionZone")).is_not_null()
