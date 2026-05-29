extends GdUnitTestSuite


func before_test() -> void:
	GameState.reset()


func test_completed_one_shot_event_is_skipped() -> void:
	var npc: NPCBase = auto_free(load("res://scripts/npcs/npc_grandmother.gd").new())

	GameState.complete_event("gm_event_1")
	var event: Dictionary = npc._get_available_event()

	assert_that(event.get("id", "")).is_equal("gm_event_2")
